# RallyOps

Your command center for epic road rallies — from route planning to checkpoint tracking.

## Overview

**RallyOps** is a SwiftUI + SwiftData application for iOS and macOS that serves as a central location to set up, manage, and run the road rally of your dreams. The app helps you organize:

1. **Routes** — Plan detailed routes with waypoints, special stages, and transit sections
2. **Checkpoints** — Define time controls, photo challenges, and scoring zones
3. **Participants** — Manage driver/co-driver teams and vehicle information
4. **Schedules** — Build rally timelines with start times, legs, and service parks

## Features

- 🗺️ **Route Planning** — Create multi-leg routes with GPS coordinates and road books
- ⏱️ **Time Controls** — Set up regularity stages with target times and penalties
- 📸 **Photo Challenges** — Define mystery photo checkpoints and verification
- 🏁 **Scoring System** — Automatic calculation of penaltites and standings
- 📱 **Offline Support** — Download rally data for areas with no cell coverage
- 🎨 **Cohesive Design** — Unified theme system with adaptive light/dark modes
- 💾 **SwiftData Persistence** — Local-first data storage with iCloud sync

## Tech Stack

- **Language:** Swift
- **UI Framework:** SwiftUI
- **Persistence:** SwiftData
- **Platforms:** iOS, macOS
- **Architecture:** MVVM with SwiftData models

## Getting Started

### Prerequisites

- Xcode 15.0+
- iOS 17.0+ / macOS 14.0+

### Installation

1. Clone the repository
2. Open `rallyops.xcodeproj` in Xcode
3. Build and run on your preferred platform

### First Launch

The app includes an onboarding flow that guides you through:

1. Creating your first rally event
2. Adding a route with waypoints
3. Setting up checkpoints and time controls

## Project Structure

```
rallyops/
├── Models/           # SwiftData models and extensions
├── Views/            # SwiftUI views and components
├── Theme/            # Design system (AppTheme)
└── RallyOpsApp.swift # App entry point

docs/                 # Documentation
tests/                # Unit and UI tests
```

## Documentation

Full documentation is available in the [`docs/`](docs/) folder:

- [Architecture Overview](docs/architecture.md)
- [Routes](docs/routes.md)
- [Checkpoints](docs/checkpoints.md)
- [Participants](docs/participants.md)
- [Scoring](docs/scoring.md)

## Development

### Running Tests

```bash
# Run all tests
cmd+U in Xcode

# Run specific test suite
xcodebuild test -scheme rallyops -destination 'platform=iOS Simulator,name=iPhone 15'
```

### Code Style

The project follows standard Swift conventions and uses SwiftUI best practices. Key principles:

- Prefer composition over inheritance
- Use computed properties for derived state
- Keep views small and focused
- Leverage SwiftData relationships

## Contributing

This is a personal project, but suggestions and bug reports are welcome via issues.

For information about commit message conventions, code style, and development workflow, see [CONTRIBUTING.md](CONTRIBUTING.md).

## License

See LICENSE file for details.

## Author

Cameron Rivers
