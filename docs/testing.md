# Testing

The project includes unit tests in `rallyopsTests/` and UI tests in `rallyopsUITests/`.

## Unit Tests

### CreateMilestoneValidatorTests

Tests for `CreateMilestoneValidator`:

| Test | Description |
|------|--------------|
| `testValidate_validMilestone_doesNotThrow` | Valid milestone (name, core value, future deadline) passes |
| `testValidate_emptyName_throwsInvalidName` | Empty name throws `invalidName` |
| `testValidate_nilCoreValue_throwsInvalidCoreValue` | No core value throws `invalidCoreValue` |
| `testValidate_pastDeadline_throwsInvalidDeadline` | Past deadline throws `invalidDeadline` |
| `testValidate_deadlineExactlyNow_throwsInvalidDeadline` | Deadline = now throws `invalidDeadline` |
| `testErrorDescription_*` | Error messages for each case |

Uses in-memory SwiftData container and sample `CoreValue`.

### DateHelpersTests

Tests for date utilities in `Principle.swift`:

#### dateFromString

| Test | Description |
|------|-------------|
| `testDateFromString_validFormat_returnsParsedDate` | `"dd-mm-yyyy"` (e.g. `"15-06-2024"`) parses correctly |
| `testDateFromString_invalidFormat_returnsDateNow` | Invalid string returns `Date.now` |
| `testDateFromString_emptyString_returnsDateNow` | Empty string returns `Date.now` |
| `testDateFromString_wrongFormat_returnsDateNow` | Wrong format (e.g. `"yyyy-mm-dd"`) returns `Date.now` |

#### until(days:)

| Test | Description |
|------|-------------|
| `testUntil_positiveDays_returnsFutureDate` | Positive days → future date |
| `testUntil_negativeDays_returnsPastDate` | Negative days → past date |
| `testUntil_zeroDays_returnsApproximatelyNow` | Zero days → ~now |

## Running Tests

```bash
xcodebuild test -scheme rallyops -destination 'platform=iOS Simulator,name=iPhone 16'
```

Or use the **Test** action (⌘U) in Xcode.

## CI Build Command

Use the script below for CI-safe app builds:

```bash
./scripts/ci-build.sh
```

The script:
- Checks that an iOS Simulator runtime is available.
- Uses a deterministic DerivedData path (`$RUNNER_TEMP` when available, otherwise `/tmp`).
- Disables code signing so the build can run in CI without signing credentials.

Optional overrides:

```bash
PROJECT_PATH=rallyops.xcodeproj SCHEME=rallyops CONFIGURATION=Release DESTINATION='generic/platform=iOS Simulator' DERIVED_DATA_PATH=/tmp/rallyops-derived-data ./scripts/ci-build.sh
```
