# Xcode Cloud + TestFlight Setup

One-time setup to enable automatic TestFlight builds on every merge to `main`.

## Prerequisites

- Apple Developer account (paid, $99/yr) linked to Xcode
- App Store Connect access for `dev.camr.rallyops`

## Project facts

| Field | Value |
|---|---|
| Scheme | `rallyops` |
| Bundle ID | `dev.camr.rallyops` |
| Team ID | `5YV6ME78QV` |
| Deployment target | iOS 17.4 |
| Dependencies | None (pure SwiftUI + SwiftData) |

---

## Step 1 — Sign in to Xcode

**Xcode → Settings → Accounts** → click **+** → add your Apple ID.

---

## Step 2 — Create the Xcode Cloud workflow

1. Open `rallyops.xcodeproj` in Xcode.
2. **Product → Xcode Cloud → Create Workflow**
3. Select scheme **`rallyops`** and click **Next**.

### Start condition

| Setting | Value |
|---|---|
| Trigger | Branch Changes |
| Branch | `main` |

Optionally add a second trigger for **Pull Request Changes** to catch regressions before merge.

### Actions

**Add an Archive action:**

| Setting | Value |
|---|---|
| Platform | iOS |
| Deployment Target | iOS 17.4 |
| Distribution | TestFlight (Internal Testing) |
| Increment Build Number | Use Xcode Cloud build number |

**Add a Test action (optional but recommended):**

| Setting | Value |
|---|---|
| Scheme | `rallyops` |
| Destination | iPhone (latest simulator) |

### Post-actions

Add a **TestFlight** post-action → Internal Group → add yourself as a tester.

---

## Step 3 — First run

Click **Save** and then **Start Build**. On first run Xcode Cloud will:

1. Ask you to register the App Store Connect app record for `dev.camr.rallyops` — approve it.
2. Request access to your repo — approve it.
3. Build, archive, and push to TestFlight automatically.

---

## Step 4 — Install on your phone

1. Open **TestFlight** on your iPhone.
2. Accept the tester invite email.
3. Tap **Install** next to *rallyops*.

After the initial setup every push to `main` will trigger a new build that lands in TestFlight within ~15–20 minutes.

---

## CI scripts

The `ci_scripts/` directory contains hook scripts that Xcode Cloud executes automatically:

| Script | When it runs |
|---|---|
| `ci_post_clone.sh` | After the repo is cloned — installs the commit-msg hook |
| `ci_pre_xcodebuild.sh` | Before each xcodebuild action — logs build metadata |

No changes to these scripts are needed for normal operation.

---

## Troubleshooting

**Build fails with signing error** — verify the Team ID (`5YV6ME78QV`) in *Signing & Capabilities* matches the Developer account in Xcode settings.

**TestFlight build never appears** — check that the Archive action has *Distribution: TestFlight (Internal Testing)* and that you accepted the tester invite.

**`ci_post_clone.sh` fails** — confirm that `hooks/commit-msg` exists in the repo root and is executable.
