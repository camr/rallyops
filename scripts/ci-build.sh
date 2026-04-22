#!/usr/bin/env bash
set -euo pipefail

PROJECT_PATH="${PROJECT_PATH:-rallyops.xcodeproj}"
SCHEME="${SCHEME:-rallyops}"
CONFIGURATION="${CONFIGURATION:-Release}"
DESTINATION="${DESTINATION:-generic/platform=iOS Simulator}"
DERIVED_DATA_PATH="${DERIVED_DATA_PATH:-${RUNNER_TEMP:-/tmp}/rallyops-derived-data}"

if ! RUNTIMES_OUTPUT="$(xcrun simctl list runtimes 2>/dev/null)"; then
  echo "error: unable to query simulator runtimes via xcrun simctl." >&2
  echo "hint: ensure Xcode command line tools are selected and CoreSimulator is available." >&2
  exit 1
fi

if ! printf "%s\n" "$RUNTIMES_OUTPUT" | grep -qE "^iOS [0-9]"; then
  echo "error: no iOS simulator runtime is installed." >&2
  echo "hint: install one with 'xcodebuild -downloadPlatform iOS' and retry." >&2
  exit 1
fi

xcodebuild \
  -project "$PROJECT_PATH" \
  -scheme "$SCHEME" \
  -configuration "$CONFIGURATION" \
  -destination "$DESTINATION" \
  -derivedDataPath "$DERIVED_DATA_PATH" \
  CODE_SIGNING_ALLOWED=NO \
  CODE_SIGNING_REQUIRED=NO \
  CODE_SIGN_IDENTITY="" \
  build
