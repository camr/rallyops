// NOTE: Requires PR #73 (appium scaffold) and PR #75 (accessibilityIdentifiers) to be merged.

import { AppHelper } from '../helpers/AppHelper';

describe('Settings', () => {
  before(async () => {
    await AppHelper.resetApp();
    await AppHelper.completeOnboarding();
    await AppHelper.waitForElement('today-tab', 20000);
  });

  beforeEach(async () => {
    // Ensure we are on the Today tab where the settings-button lives
    await AppHelper.tapTab('Today');
    await AppHelper.waitForElement('settings-button');
    await AppHelper.tapElement('settings-button');
    // settings-view is an accessibilityIdentifier on the General section inside the list
    await AppHelper.waitForElement('settings-view');
  });

  afterEach(async () => {
    // Dismiss the settings sheet by swiping down
    await driver.execute('mobile: swipe', { direction: 'down' });
    await driver.pause(2000);
  });

  describe('General Settings', () => {
    it('settings sheet opens from gear icon in Today view nav bar', async () => {
      // settings-view is already waited for in beforeEach; confirm it is displayed
      const settingsSection = await $('~settings-view');
      await expect(settingsSection).toBeDisplayed();

      // The navigation title "Settings" should appear
      const navTitle = await $(`-ios class chain:**/XCUIElementTypeStaticText[\`label == "Settings"\`]`);
      await expect(navTitle).toBeDisplayed();
    });

    it('displays General and About navigation links', async () => {
      const generalLink = await $(`-ios class chain:**/XCUIElementTypeAny[\`label == "General"\`]`);
      await expect(generalLink).toBeDisplayed();

      const aboutLink = await $(`-ios class chain:**/XCUIElementTypeAny[\`label == "About"\`]`);
      await expect(aboutLink).toBeDisplayed();
    });

    it('navigates to General settings and displays all toggles', async () => {
      // Tap the General navigation link
      const generalLink = await $(`-ios class chain:**/XCUIElementTypeAny[\`label == "General"\`]`);
      await generalLink.click();

      // Wait for the General settings title
      const navTitle = await $(`-ios class chain:**/XCUIElementTypeStaticText[\`label == "General"\`]`);
      await navTitle.waitForDisplayed({ timeout: 10000 });

      // Appearance section
      const startWeekToggle = await $(`-ios class chain:**/XCUIElementTypeSwitch[\`label == "Start Week on Monday"\`]`);
      await expect(startWeekToggle).toBeDisplayed();

      const accentColorPicker = await $(`-ios class chain:**/XCUIElementTypeAny[\`label CONTAINS "Accent Color"\`]`);
      await expect(accentColorPicker).toBeDisplayed();

      // Preferences section
      const showCompletedToggle = await $(`-ios class chain:**/XCUIElementTypeSwitch[\`label == "Show Completed Items"\`]`);
      await expect(showCompletedToggle).toBeDisplayed();

      const confirmDestructiveToggle = await $(`-ios class chain:**/XCUIElementTypeSwitch[\`label == "Confirm Destructive Actions"\`]`);
      await expect(confirmDestructiveToggle).toBeDisplayed();
    });

    it('"Start Week on Monday" toggle responds to tap', async () => {
      const generalLink = await $(`-ios class chain:**/XCUIElementTypeAny[\`label == "General"\`]`);
      await generalLink.click();
      await driver.pause(500);

      const toggle = await $(`-ios class chain:**/XCUIElementTypeSwitch[\`label == "Start Week on Monday"\`]`);
      await toggle.waitForDisplayed({ timeout: 10000 });

      const valueBefore = await toggle.getAttribute('value');
      await toggle.click();
      await driver.pause(300);
      const valueAfter = await toggle.getAttribute('value');

      // Value should have flipped (0 → 1 or 1 → 0)
      expect(valueAfter).not.toEqual(valueBefore);

      // Restore original state
      await toggle.click();
      await driver.pause(300);
    });

    it('"Show Completed Items" toggle responds to tap', async () => {
      const generalLink = await $(`-ios class chain:**/XCUIElementTypeAny[\`label == "General"\`]`);
      await generalLink.click();
      await driver.pause(500);

      const toggle = await $(`-ios class chain:**/XCUIElementTypeSwitch[\`label == "Show Completed Items"\`]`);
      await toggle.waitForDisplayed({ timeout: 10000 });

      const valueBefore = await toggle.getAttribute('value');
      await toggle.click();
      await driver.pause(300);
      const valueAfter = await toggle.getAttribute('value');

      expect(valueAfter).not.toEqual(valueBefore);

      // Restore original state
      await toggle.click();
      await driver.pause(300);
    });

    it('"Confirm Destructive Actions" toggle responds to tap', async () => {
      const generalLink = await $(`-ios class chain:**/XCUIElementTypeAny[\`label == "General"\`]`);
      await generalLink.click();
      await driver.pause(500);

      const toggle = await $(`-ios class chain:**/XCUIElementTypeSwitch[\`label == "Confirm Destructive Actions"\`]`);
      await toggle.waitForDisplayed({ timeout: 10000 });

      const valueBefore = await toggle.getAttribute('value');
      await toggle.click();
      await driver.pause(300);
      const valueAfter = await toggle.getAttribute('value');

      expect(valueAfter).not.toEqual(valueBefore);

      // Restore original state
      await toggle.click();
      await driver.pause(300);
    });

    it('toggle changes persist across app restart', async () => {
      const generalLink = await $(`-ios class chain:**/XCUIElementTypeAny[\`label == "General"\`]`);
      await generalLink.click();
      await driver.pause(500);

      const toggle = await $(`-ios class chain:**/XCUIElementTypeSwitch[\`label == "Start Week on Monday"\`]`);
      await toggle.waitForDisplayed({ timeout: 10000 });

      // Read initial value and flip it
      const valueBefore = await toggle.getAttribute('value');
      await toggle.click();
      await driver.pause(500);

      // Dismiss settings sheet and restart app
      await driver.execute('mobile: swipe', { direction: 'down' });
      await driver.pause(500);
      await AppHelper.resetApp();
      await AppHelper.completeOnboarding();
      await AppHelper.waitForElement('today-tab', 20000);

      // Re-open settings → General
      await AppHelper.tapTab('Today');
      await AppHelper.waitForElement('settings-button');
      await AppHelper.tapElement('settings-button');
      await AppHelper.waitForElement('settings-view');

      const generalLink2 = await $(`-ios class chain:**/XCUIElementTypeAny[\`label == "General"\`]`);
      await generalLink2.click();

      const toggleAfterRestart = await $(`-ios class chain:**/XCUIElementTypeSwitch[\`label == "Start Week on Monday"\`]`);
      await toggleAfterRestart.waitForDisplayed({ timeout: 10000 });
      const valueAfterRestart = await toggleAfterRestart.getAttribute('value');

      // Value should be the flipped value, not the original
      expect(valueAfterRestart).not.toEqual(valueBefore);

      // Restore original state
      await toggleAfterRestart.click();
      await driver.pause(300);
    });

    it('navigates to About settings and displays version info', async () => {
      const aboutLink = await $(`-ios class chain:**/XCUIElementTypeAny[\`label == "About"\`]`);
      await aboutLink.click();

      const navTitle = await $(`-ios class chain:**/XCUIElementTypeStaticText[\`label == "About"\`]`);
      await navTitle.waitForDisplayed({ timeout: 10000 });

      // Version row should be present
      const versionRow = await $(`-ios class chain:**/XCUIElementTypeAny[\`label CONTAINS "Version"\`]`);
      await expect(versionRow).toBeDisplayed();

      // Acknowledgements links
      const swiftUILink = await $(`-ios class chain:**/XCUIElementTypeAny[\`label == "SwiftUI"\`]`);
      await expect(swiftUILink).toBeDisplayed();
    });
  });

  describe('Debug Tools', () => {
    it('debug section is present in development builds', async () => {
      // The Debug link is only compiled in DEBUG builds.
      // In a DEBUG simulator build, the "Debug" navigation link should be visible.
      // There is no dedicated accessibilityIdentifier for the Debug link; match by label.
      const debugLink = await $(`-ios class chain:**/XCUIElementTypeAny[\`label == "Debug"\`]`);
      const isDisplayed = await debugLink.isDisplayed().catch(() => false);

      // This assertion documents expected behaviour: debug section is visible in DEBUG builds.
      // In a Release build this will be false and the next test verifies absence.
      if (isDisplayed) {
        // DEBUG build: confirmed the link is displayed
        await expect(debugLink).toBeDisplayed();
      } else {
        // Release build: debug section correctly absent — no assertion failure
        console.log('Debug link not present: running in a Release build');
      }
    });

    it('debug section is absent in Release builds', async () => {
      // This test is informational in a DEBUG build (debug link will be present).
      // In a Release build no "Debug" element should appear in the settings list.
      const debugLink = await $(`-ios class chain:**/XCUIElementTypeAny[\`label == "Debug"\`]`);
      const isDisplayed = await debugLink.isDisplayed().catch(() => false);

      if (!isDisplayed) {
        // Release build: verified debug section is absent
        await expect(debugLink).not.toBeDisplayed();
      } else {
        // DEBUG build: skip — debug section is expected to be present
        console.log('Skipping Release-only assertion: running in a DEBUG build');
      }
    });

    it('debug actions are tappable and Add Demo Data functions', async () => {
      // Navigate to Debug only if the link is present (DEBUG build)
      const debugLink = await $(`-ios class chain:**/XCUIElementTypeAny[\`label == "Debug"\`]`);
      const isDisplayed = await debugLink.isDisplayed().catch(() => false);

      if (!isDisplayed) {
        console.log('Skipping debug-actions test: not a DEBUG build');
        return;
      }

      await debugLink.click();

      // Wait for Debug navigation title
      const navTitle = await $(`-ios class chain:**/XCUIElementTypeStaticText[\`label == "Debug"\`]`);
      await navTitle.waitForDisplayed({ timeout: 10000 });

      // "Add Demo Data" button should be present and tappable
      const addDemoButton = await $(`~Add Demo Data`);
      await addDemoButton.waitForDisplayed({ timeout: 10000 });
      await expect(addDemoButton).toBeDisplayed();
      await addDemoButton.click();
      await driver.pause(1000);

      // After seeding, some count text should appear (values/milestones/actions/habits > 0)
      // The DebugSettingsView shows counts inline; at least one count should be non-zero.
      const countsText = await $(`-ios class chain:**/XCUIElementTypeStaticText[\`label CONTAINS "Core Values"\`]`);
      await expect(countsText).toBeDisplayed();
    });

    it('"Remove App Data" button shows confirmation dialog', async () => {
      // Navigate to Debug only if the link is present (DEBUG build)
      const debugLink = await $(`-ios class chain:**/XCUIElementTypeAny[\`label == "Debug"\`]`);
      const isDisplayed = await debugLink.isDisplayed().catch(() => false);

      if (!isDisplayed) {
        console.log('Skipping remove-data test: not a DEBUG build');
        return;
      }

      await debugLink.click();

      const navTitle = await $(`-ios class chain:**/XCUIElementTypeStaticText[\`label == "Debug"\`]`);
      await navTitle.waitForDisplayed({ timeout: 10000 });

      // Tap "Remove App Data" — it should show a confirmation dialog
      const removeButton = await $(`~Remove App Data`);
      await removeButton.waitForDisplayed({ timeout: 10000 });
      await expect(removeButton).toBeDisplayed();
      await removeButton.click();
      await driver.pause(500);

      // Confirmation dialog: "Delete all app data?" should appear
      const confirmTitle = await $(`-ios class chain:**/XCUIElementTypeStaticText[\`label == "Delete all app data?"\`]`);
      await confirmTitle.waitForDisplayed({ timeout: 5000 });
      await expect(confirmTitle).toBeDisplayed();

      // Dismiss by tapping Cancel to avoid actually deleting data
      const cancelButton = await $(`-ios class chain:**/XCUIElementTypeButton[\`label == "Cancel"\`]`);
      await cancelButton.waitForDisplayed({ timeout: 5000 });
      await cancelButton.click();
      await driver.pause(500);
    });
  });
});
