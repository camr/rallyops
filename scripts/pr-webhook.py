#!/usr/bin/env python3
"""
pr-webhook.py — Local webhook server for GitHub PR merge events.

Receives forwarded events from n8n (via Tailscale) and on each merge:
  1. Runs `td approve <id>` to close the task
  2. Fetches origin, syncs local main, and deletes the local branch

Usage:
    python3 scripts/pr-webhook.py [--port PORT]

Accepts two payload shapes:
  - Raw GitHub pull_request webhook (action=closed, merged=true)
  - Simplified n8n payload: {"branch": "<branch-name>"}
"""

import argparse
import json
import logging
import re
import subprocess
import threading
import time
from http.server import BaseHTTPRequestHandler, HTTPServer
from pathlib import Path

PORT = 3456
REPO_DIR = Path(__file__).resolve().parent.parent
TD_BIN = "/Users/camr/go/bin/td"
TD_ID_RE = re.compile(r'\btd-[0-9a-f]{6}\b')

# Serialises all git operations across concurrent webhook threads.
# Prevents multiple background threads from running git simultaneously,
# which would cause index.lock conflicts.
_GIT_LOCK = threading.Lock()

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [pr-webhook] %(levelname)s %(message)s",
    datefmt="%Y-%m-%dT%H:%M:%S",
)
log = logging.getLogger(__name__)


def extract_merge_info(payload: dict) -> tuple[str, str] | None:
    """Return (td_id, branch) for a merged PR, or None to skip."""
    branch = None

    if "pull_request" in payload:
        # Raw GitHub webhook payload
        if payload.get("action") != "closed":
            log.debug("Ignoring action=%s", payload.get("action"))
            return None
        pr = payload["pull_request"]
        if not pr.get("merged"):
            log.debug("PR closed but not merged, ignoring")
            return None
        branch = pr["head"]["ref"]
    elif "branch" in payload:
        # Simplified payload sent by n8n
        branch = payload["branch"]
    else:
        log.warning("Unrecognised payload shape: %s", list(payload.keys()))
        return None

    match = TD_ID_RE.search(branch)
    if not match:
        log.warning("No td-* ID found in branch: %s", branch)
        return None
    return match.group(), branch


def approve_task(td_id: str) -> tuple[bool, str]:
    """Run `td approve <id>`. Returns (success, message)."""
    try:
        result = subprocess.run(
            [TD_BIN, "approve", td_id],
            cwd=REPO_DIR,
            capture_output=True,
            text=True,
            timeout=15,
        )
        output = (result.stdout + result.stderr).strip()
        if result.returncode == 0:
            log.info("td approve %s → %s", td_id, output or "ok")
            return True, output or "approved"
        else:
            msg = f"td exited {result.returncode}: {output}"
            log.error("td approve %s failed — %s", td_id, msg)
            return False, msg
    except subprocess.TimeoutExpired:
        msg = "td approve timed out after 15s"
        log.error("td approve %s — %s", td_id, msg)
        return False, msg
    except FileNotFoundError:
        msg = f"td binary not found at {TD_BIN}"
        log.error(msg)
        return False, msg


def _run_git(*cmd, retries: int = 4, retry_delay: float = 2.0) -> subprocess.CompletedProcess:
    """Run a git command, retrying if another process holds the index lock."""
    for attempt in range(retries):
        r = subprocess.run(list(cmd), cwd=REPO_DIR, capture_output=True, text=True)
        if r.returncode == 128 and "index.lock" in r.stderr and attempt < retries - 1:
            log.warning("git index locked by another process, retrying in %.0fs (attempt %d/%d)…",
                        retry_delay, attempt + 1, retries)
            time.sleep(retry_delay)
            continue
        return r
    return r  # return last result after exhausting retries


def find_worktree_path(branch: str) -> Path | None:
    """Return the path of the worktree checked out to branch, or None.

    Parses `git worktree list --porcelain` output which looks like:
      worktree /path/to/worktree
      HEAD <sha>
      branch refs/heads/<branch>
    """
    r = _run_git("git", "worktree", "list", "--porcelain")
    if r.returncode != 0:
        return None
    current_path: Path | None = None
    for line in r.stdout.splitlines():
        if line.startswith("worktree "):
            current_path = Path(line[len("worktree "):].strip())
        elif line.startswith("branch "):
            ref = line[len("branch "):].strip()
            if ref == f"refs/heads/{branch}" and current_path and current_path != REPO_DIR:
                return current_path
    return None


def git_cleanup(branch: str) -> tuple[bool, list[str]]:
    """Remove worktree, sync main, and delete the merged local branch.

    Acquires _GIT_LOCK so concurrent webhook events never run git in parallel.
    Each git call retries on index.lock contention from external processes.

    Steps:
      1. git fetch origin
      2. Remove the task worktree (if present) — must happen before branch delete
      3. If on the task branch in the main worktree, switch to main first
      4. git merge --ff-only origin/main
      5. git branch -d <branch>  (skipped if not local)
    """
    with _GIT_LOCK:
        steps = []

        # 1. Fetch
        r = _run_git("git", "fetch", "origin")
        if r.returncode != 0:
            return False, [f"git fetch failed: {r.stderr.strip()}"]
        steps.append("fetched origin")

        # 2. Remove the task worktree — git refuses to delete a branch that is
        #    checked out in a worktree, so this must come before branch deletion.
        wt_path = find_worktree_path(branch)
        if wt_path:
            r = _run_git("git", "worktree", "remove", str(wt_path))
            if r.returncode == 0:
                steps.append(f"removed worktree {wt_path}")
            else:
                # Worktree may have untracked files; force-remove since the
                # branch is already merged and committed work is safe in git.
                log.warning("worktree remove failed (%s), retrying with --force", r.stderr.strip())
                r2 = _run_git("git", "worktree", "remove", "--force", str(wt_path))
                if r2.returncode == 0:
                    steps.append(f"force-removed worktree {wt_path}")
                else:
                    log.error("Could not remove worktree %s: %s", wt_path, r2.stderr.strip())
                    steps.append(f"worktree remove failed: {r2.stderr.strip()}")
        else:
            steps.append("no worktree found for branch, skipping")

        # 3. Check if branch exists locally — nothing to do if already gone
        r = _run_git("git", "branch", "--list", branch)
        if not r.stdout.strip():
            steps.append(f"{branch}: not found locally, skipping delete")
            return True, steps

        # 4. If currently on the task branch in the main worktree, move to main
        r = _run_git("git", "rev-parse", "--abbrev-ref", "HEAD")
        current = r.stdout.strip()
        if current == branch:
            r = _run_git("git", "checkout", "main")
            if r.returncode != 0:
                return False, steps + [f"git checkout main failed: {r.stderr.strip()}"]
            steps.append("checked out main")

        # 5. Fast-forward local main to origin/main
        r = _run_git("git", "merge", "--ff-only", "origin/main")
        if r.returncode == 0:
            steps.append("synced main to origin/main")
        else:
            log.warning("Could not fast-forward main: %s", r.stderr.strip())
            steps.append("main sync skipped (not fast-forwardable)")

        # 6. Delete the local branch
        r = _run_git("git", "branch", "-d", branch)
        if r.returncode == 0:
            steps.append(f"deleted local branch {branch}")
        else:
            log.warning("Could not delete %s: %s", branch, r.stderr.strip())
            steps.append(f"branch delete skipped: {r.stderr.strip()}")

        return True, steps


class WebhookHandler(BaseHTTPRequestHandler):
    def do_POST(self):
        length = int(self.headers.get("Content-Length", 0))
        body = self.rfile.read(length)

        try:
            payload = json.loads(body)
        except json.JSONDecodeError as exc:
            log.error("Bad JSON: %s", exc)
            self._respond(400, {"status": "error", "reason": f"invalid JSON: {exc}"})
            return

        info = extract_merge_info(payload)

        if info is None:
            self._respond(200, {"status": "skipped", "reason": "no td-* ID found or event not a merge"})
            return

        td_id, branch = info

        # Respond immediately so n8n doesn't time out waiting on git/td operations.
        # Actual work runs in a background thread; results appear in the log.
        self._respond(202, {"status": "accepted", "task": td_id, "branch": branch})
        threading.Thread(target=self._process, args=(td_id, branch), daemon=True).start()

    def _process(self, td_id: str, branch: str):
        approved, approve_msg = approve_task(td_id)
        if not approved:
            log.error("Skipping git cleanup for %s due to approve failure", td_id)
            return
        ok, steps = git_cleanup(branch)
        log.info("cleanup %s: %s", "ok" if ok else "failed", " | ".join(steps))

    def do_GET(self):
        # Health check
        self._respond(200, {"status": "ok", "service": "pr-webhook"})

    def _respond(self, status: int, body: dict):
        encoded = json.dumps(body).encode()
        self.send_response(status)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(encoded)))
        self.end_headers()
        self.wfile.write(encoded)

    def log_message(self, fmt, *args):  # silence default access log
        log.debug(fmt, *args)


def main():
    parser = argparse.ArgumentParser(description="PR merge webhook → td approve")
    parser.add_argument("--port", type=int, default=PORT)
    args = parser.parse_args()

    server = HTTPServer(("0.0.0.0", args.port), WebhookHandler)
    log.info("Listening on :%d  (repo: %s)", args.port, REPO_DIR)
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        log.info("Stopped.")


if __name__ == "__main__":
    main()
