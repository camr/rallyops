#!/bin/bash
# Setup git hooks for the RallyOps project
# Copies hooks from hooks/ to .git/hooks/ and sets executable permissions

set -e

REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null)
if [ -z "$REPO_ROOT" ]; then
    echo "Error: not inside a git repository"
    exit 1
fi

HOOKS_SRC="$REPO_ROOT/hooks"
HOOKS_DST="$REPO_ROOT/.git/hooks"

if [ ! -d "$HOOKS_SRC" ]; then
    echo "Error: hooks/ directory not found at $HOOKS_SRC"
    exit 1
fi

mkdir -p "$HOOKS_DST"

for hook in "$HOOKS_SRC"/*; do
    hook_name=$(basename "$hook")
    cp "$hook" "$HOOKS_DST/$hook_name"
    chmod +x "$HOOKS_DST/$hook_name"
    echo "Installed $hook_name"
done

echo "All hooks installed successfully."
