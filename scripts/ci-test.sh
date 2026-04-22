#!/usr/bin/env bash
set -euo pipefail

# ── Configuration ───────────────────────────────────────────────
PROJECT_PATH="${PROJECT_PATH:-rallyops.xcodeproj}"
SCHEME="${SCHEME:-rallyops}"
CONFIGURATION="${CONFIGURATION:-Release}"
DERIVED_DATA_PATH="${DERIVED_DATA_PATH:-${RUNNER_TEMP:-/tmp}/rallyops-derived-data}"
DEVICE_NAME="${DEVICE_NAME:-}"
IOS_VERSION="${IOS_VERSION:-}"
REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"

APP_PATH="$DERIVED_DATA_PATH/Build/Products/Release-iphonesimulator/rallyops.app"

# ── Build ───────────────────────────────────────────────────────
echo "→ Building app..."
"$REPO_ROOT/scripts/ci-build.sh"

# ── Boot simulator ───────────────────────────────────────────────
echo "→ Finding simulator..."
SIM_UDID=$(xcrun simctl list devices available -j \
  | python3 -c "
import json, sys
data = json.load(sys.stdin)
ios_version = '$IOS_VERSION'
device_name = '$DEVICE_NAME'
# If no version specified, find any available
if not ios_version:
    for runtime, devices in data['devices'].items():
        if 'iOS' in runtime:
            for d in devices:
                if d['isAvailable']:
                    print(d['udid'])
                    exit()
else:
    for runtime, devices in data['devices'].items():
        if 'iOS-' + ios_version in runtime or 'iOS ' + ios_version in runtime:
            for d in devices:
                name_match = not device_name or (device_name and device_name in d['name'])
                if name_match and d['isAvailable']:
                    print(d['udid'])
                    exit()
" 2>/dev/null | head -1)

if [ -z "$SIM_UDID" ]; then
  echo "error: could not find simulator '$DEVICE_NAME' with iOS $IOS_VERSION" >&2
  exit 1
fi

echo "→ Booting simulator $SIM_UDID..."
xcrun simctl boot "$SIM_UDID" 2>/dev/null || true  # ignore 'already booted'

trap 'echo "→ Shutting down simulator..."; xcrun simctl shutdown "$SIM_UDID" 2>/dev/null || true' EXIT

# ── Install Appium deps ──────────────────────────────────────────
# Note: appium/wdio.conf.ts should include the JUnit reporter for CI artifact
# collection: add ['junit', { outputDir: './test-results' }] to the reporters
# array. Test results are uploaded from appium/test-results/ by the CI workflow.
echo "→ Installing Appium test dependencies..."
cd "$REPO_ROOT/appium"
npm ci

echo "→ Ensuring XCUITest driver is installed..."
npx appium driver install xcuitest 2>/dev/null || npx appium driver update xcuitest 2>/dev/null || true

# ── Run tests ────────────────────────────────────────────────────
echo "→ Running Appium tests..."
GOALS_APP_PATH="$APP_PATH" npm test

echo "✓ Appium tests complete."
