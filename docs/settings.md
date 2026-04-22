# Settings

Settings are available as a sheet from the Today view toolbar, and on macOS as the native **Settings** menu item.

## Main Settings View

- **General** — Opens `GeneralSettingsView`
- **About** — Opens `AboutSettingsView`
- **Debug** — Opens `DebugSettingsView`

## General Settings View

- Toggle preferences saved with `@AppStorage`:
  - Show Completed Items
  - Start Week on Monday
  - Confirm Destructive Actions
- Notes that preferences are stored locally on device.

## About Settings View

- App summary text
- Version and build number from app bundle (`CFBundleShortVersionString` + `CFBundleVersion`)
- Acknowledgements links:
  - SwiftUI
  - SwiftData
  - SF Symbols
- Support note for project feedback

## Debug Settings View

Useful for development and testing.

### Statistics

Displays counts:

- Core Values
- Milestones
- Actions
- Habits

### Actions

#### Add Demo Data

- Inserts sample Core Values, Milestones, Actions, and Habits
- Same data as `Previewer.addSampleData`
- Includes relationships (e.g., habits with check-ins)

#### Remove App Data

- **Remove App Data** button with confirmation
- Deletes all `CoreValue` instances (cascade removes milestones, actions, habits)
- Message: "This action cannot be undone."

## Platforms

- **iOS:** Sheet from Today view
- **macOS:** Shown in **Settings** via `Settings { SettingsView() }` in `RallyOpsApp`
