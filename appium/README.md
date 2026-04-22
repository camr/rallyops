# RallyOps Appium Tests

Automated UI tests for the RallyOps iOS app using [WebDriverIO](https://webdriver.io/) (WDIO) with the Appium 2 XCUITest driver.

## Prerequisites

- **Node.js 18+** — [nodejs.org](https://nodejs.org/)
- **Appium 2** — installed globally or managed via the WDIO Appium service
- **appium-xcuitest-driver** — Appium driver for iOS/XCUITest automation
- **Xcode** with iOS simulators — install via the Mac App Store

## Setup

### 1. Install Node dependencies

```bash
cd appium
npm install
```

### 2. Install the XCUITest Appium driver

```bash
npx appium driver install xcuitest
```

## Building the App

Build the RallyOps app for the iOS Simulator using the CI build script from the repo root:

```bash
./scripts/ci-build.sh
```

This produces the `.app` bundle at:
```
/tmp/rallyops-derived-data/Build/Products/Release-iphonesimulator/rallyops.app
```

## Running Tests

### Run all tests

```bash
npm test
```

### Run with a custom app path

```bash
GOALS_APP_PATH=/path/to/rallyops.app npm test
```

### Run the smoke test only

```bash
npm run test:smoke
```

## Configuration

The test configuration lives in `wdio.conf.ts`. Key settings:

| Setting | Value |
|---|---|
| Platform | iOS Simulator |
| Device | iPhone 16 |
| iOS Version | 18.0 |
| Framework | Mocha |
| Test timeout | 60 000 ms |

The `GOALS_APP_PATH` environment variable overrides the default app path used by `ci-build.sh`.

## Project Structure

```
appium/
  helpers/
    AppHelper.ts      # Base helper class for element interactions
  tests/
    smoke.test.ts     # Smoke test — verifies app launches and Today tab is visible
  wdio.conf.ts        # WebDriverIO configuration
  tsconfig.json       # TypeScript configuration
  package.json        # Node dependencies and scripts
```
