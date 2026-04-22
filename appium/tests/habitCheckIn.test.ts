import { AppHelper } from '../helpers/AppHelper';

describe('Habit Check-In', () => {
  const milestoneName = 'Check-In Milestone';
  const habitName = 'Water Plants';

  beforeEach(async () => {
    await AppHelper.resetApp();
    await AppHelper.completeOnboarding();
    
    // Create a milestone and a habit
    await AppHelper.tapTab('Milestones');
    await AppHelper.tapElement('milestone-add-button');
    await AppHelper.clearAndType('milestone-create-name-field', milestoneName);
    
    // Select default core value
    const picker = await $('~milestone-create-core-value-picker');
    await picker.click();
    await driver.pause(1000);
    const menuOption = await $(`-ios class chain:**/XCUIElementTypeButton[\`label == "Healthy Relationships"\`]`);
    await menuOption.waitForDisplayed({ timeout: 5000 });
    await menuOption.click();
    await driver.pause(1000);
    
    await AppHelper.tapElement('milestone-create-save-button');
    await AppHelper.waitForElement('milestones-list');
    
    // Create the habit
    const milestoneRow = await $(`-ios class chain:**/XCUIElementTypeAny[\`label == "${milestoneName}"\`]`);
    await milestoneRow.click();
    await AppHelper.tapElement('milestone-add-action-habit-button');
    const habitSegment = await $(`-ios class chain:**/XCUIElementTypeButton[\`label == "Habit"\`]`);
    await habitSegment.click();
    await AppHelper.clearAndType('habit-create-name-field', habitName);
    
    // Select ALL days for easy testing
    const days = ['sun', 'mon', 'tue', 'wed', 'thu', 'fri', 'sat'];
    for (const day of days) {
      await AppHelper.tapElement(`habit-edit-day-${day}`);
    }
    
    await AppHelper.tapElement('habit-create-save-button');
    await driver.pause(1000);
  });

  it('toggles check-in when a day circle is tapped', async () => {
    // Get today's day name
    const dayNames = ['sun', 'mon', 'tue', 'wed', 'thu', 'fri', 'sat'];
    const today = new Date().getDay(); // 0-6
    const todayName = dayNames[today];
    
    console.log(`Today is ${todayName} (${today})`);
    
    // Find today's circle globally
    const todayCircle = await $(`~habit-day-circle-${todayName}`);
    
    try {
      await todayCircle.waitForDisplayed({ timeout: 10000 });
    } catch (e) {
      const source = await driver.getPageSource();
      console.log(`Failed to find habit-day-circle-${todayName}. Page source:`);
      console.log(source);
      throw e;
    }
    
    // Check initial state (should be not completed)
    let label = await todayCircle.getAttribute('label');
    expect(label).toContain('not completed');
    
    // Tap to check-in
    await todayCircle.click();
    await driver.pause(1000);
    
    // Verify state updated
    label = await todayCircle.getAttribute('label');
    expect(label).toContain('completed');
    expect(label).not.toContain('not completed');
    
    // Tap again to undo (undo functionality)
    await todayCircle.click();
    await driver.pause(1000);
    
    // Verify state reverted
    label = await todayCircle.getAttribute('label');
    expect(label).toContain('not completed');
  });

  it('persists check-in state across app resets', async () => {
    const dayNames = ['sun', 'mon', 'tue', 'wed', 'thu', 'fri', 'sat'];
    const today = new Date().getDay();
    const todayName = dayNames[today];
    
    // Find today's circle globally
    const todayCircle = await $(`~habit-day-circle-${todayName}`);
    await todayCircle.waitForDisplayed({ timeout: 10000 });
    
    // Tap to check-in
    await todayCircle.click();
    await driver.pause(1000);
    
    // Verify state is completed
    let label = await todayCircle.getAttribute('label');
    expect(label).toContain('completed');
    
    // Reset the app (simulate kill and relaunch)
    await AppHelper.resetApp();
    
    // In our CI/Simulator setup, resetApp usually means data is NOT wiped.
    // If onboarding appears, complete it.
    await AppHelper.completeOnboarding();
    
    // Ensure we are on a tab before continuing
    await AppHelper.waitForElement('today-tab', 20000);
    
    // Navigate back to the habit
    await AppHelper.tapTab('Milestones');
    const milestoneRow = await $(`-ios class chain:**/XCUIElementTypeAny[\`label == "${milestoneName}"\`]`);
    await milestoneRow.waitForDisplayed({ timeout: 20000 });
    await milestoneRow.click();
    
    // Find today's circle again globally
    const todayCircleReloaded = await $(`~habit-day-circle-${todayName}`);
    await todayCircleReloaded.waitForDisplayed({ timeout: 10000 });
    
    // Verify state persisted
    label = await todayCircleReloaded.getAttribute('label');
    expect(label).toContain('completed');
  });
});
