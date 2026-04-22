const DEFAULT_TIMEOUT = 10000;
const BUNDLE_ID = 'dev.camr.rallyops';

export class AppHelper {
  /**
   * Reset app to clean state by terminating and relaunching.
   */
  static async resetApp(): Promise<void> {
    await driver.terminateApp(BUNDLE_ID);
    await driver.activateApp(BUNDLE_ID);
  }

  /**
   * Wait for an element identified by its accessibility ID.
   * Uses the `~accessibilityId` WDIO selector syntax for XCUITest.
   */
  static async waitForElement(
    accessibilityId: string,
    timeout: number = DEFAULT_TIMEOUT
  ): Promise<WebdriverIO.Element> {
    const element = await $(`~${accessibilityId}`);
    await element.waitForDisplayed({ timeout });
    return element;
  }

  /**
   * Tap an element identified by its accessibility ID.
   */
  static async tapElement(accessibilityId: string): Promise<void> {
    const element = await AppHelper.waitForElement(accessibilityId);
    await element.click();
  }

  /**
   * Type text into an element identified by its accessibility ID.
   */
  static async typeIntoElement(
    accessibilityId: string,
    text: string
  ): Promise<void> {
    const element = await AppHelper.waitForElement(accessibilityId);
    await element.click();
    await element.addValue(text);
  }

  /**
   * Clear existing text and type new text into an element identified by its accessibility ID.
   */
  static async clearAndType(
    accessibilityId: string,
    text: string
  ): Promise<void> {
    const element = await AppHelper.waitForElement(accessibilityId);
    await element.click();
    await element.clearValue();
    await element.addValue(text);
  }

  /**
   * Check whether an element exists without throwing if it is absent.
   * Returns true if the element is displayed within the timeout, false otherwise.
   */
  static async elementExists(
    accessibilityId: string,
    timeout: number = DEFAULT_TIMEOUT
  ): Promise<boolean> {
    try {
      const element = await $(`~${accessibilityId}`);
      await element.waitForDisplayed({ timeout });
      return true;
    } catch {
      return false;
    }
  }

  /**
   * Tap a tab bar button by its label (e.g., "Today", "Milestones", "Core Values").
   */
  static async tapTab(label: string): Promise<void> {
    const tabButton = await $(
      `//XCUIElementTypeTabBar[@name="Tab Bar"]/XCUIElementTypeButton[@label="${label}"]`
    );
    await tabButton.waitForDisplayed({ timeout: 30000 });
    await tabButton.click();
  }

  /**
   * Swipe left on an element (e.g., to reveal delete button).
   */
  static async swipeLeft(element: WebdriverIO.Element): Promise<void> {
    // Try mobile: swipe which is the standard XCUITest command
    await driver.execute('mobile: swipe', {
      direction: 'left',
      elementId: element.elementId,
    });
    await driver.pause(1000);
  }

  /**
   * Complete the first launch onboarding walkthrough.
   * If the app is already on the main screen, it does nothing.
   */
  static async completeOnboarding(): Promise<void> {
    const isOnboarding = await AppHelper.elementExists(
      'onboarding-next-button',
      5000
    );

    if (isOnboarding) {
      // Step 0: Welcome
      await AppHelper.tapElement('onboarding-next-button');

      // Step 1: Core Value
      await AppHelper.waitForElement('onboarding-name-field');
      await AppHelper.tapElement('onboarding-next-button');

      // Step 2: Milestone
      await AppHelper.waitForElement('onboarding-milestone-field');
      await AppHelper.tapElement('onboarding-next-button');

      // Step 3: Task
      await AppHelper.waitForElement('onboarding-task-field');
      await AppHelper.tapElement('onboarding-next-button');

      // Step 4: Habit
      await AppHelper.waitForElement('onboarding-habit-field');
      await AppHelper.tapElement('onboarding-next-button');

      // Wait for main screen (LandingPageView)
      await AppHelper.waitForElement('today-tab');
    }
  }
}
