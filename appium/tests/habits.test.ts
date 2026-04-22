import { AppHelper } from '../helpers/AppHelper';

describe('Habits', () => {
  const milestoneName = 'Habit Test Milestone';
  const habitName = 'Read for 30 mins';

  beforeEach(async () => {
    await AppHelper.resetApp();
    await AppHelper.completeOnboarding();
    
    // Ensure we have a milestone to attach the habit to
    await AppHelper.tapTab('Milestones');
    await AppHelper.tapElement('milestone-add-button');
    await AppHelper.typeIntoElement('milestone-create-name-field', milestoneName);
    
    // Select default core value
    const picker = await $('~milestone-create-core-value-picker');
    await picker.click();
    await driver.pause(1000);
    const menuOption = await $(`-ios class chain:**/XCUIElementTypeButton[\`label == "Healthy Relationships"\`]`);
    await menuOption.waitForDisplayed({ timeout: 5000 });
    await menuOption.click();
    await driver.pause(1000);
    
    await AppHelper.tapElement('milestone-create-save-button');
    await driver.pause(3000); // Wait for dismissal and animation
    
    try {
      await AppHelper.waitForElement('milestones-list', 15000);
    } catch (e) {
      const source = await driver.getPageSource();
      console.log('Failed to find milestones-list. Page source:');
      console.log(source);
      throw e;
    }
  });

  it('creates a new habit for a milestone', async () => {
    // Open the milestone
    const milestoneRow = await $(`-ios class chain:**/XCUIElementTypeAny[\`label == "${milestoneName}"\`]`);
    await milestoneRow.click();
    
    // Tap the Add button in milestone detail
    await AppHelper.tapElement('milestone-add-action-habit-button');
    
    // Switch to Habit type
    const habitSegment = await $(`-ios class chain:**/XCUIElementTypeButton[\`label == "Habit"\`]`);
    await habitSegment.click();
    
    // Fill in habit details
    await AppHelper.clearAndType('habit-create-name-field', habitName);
    
    // Select some days
    await AppHelper.tapElement('habit-edit-day-mon');
    await AppHelper.tapElement('habit-edit-day-wed');
    await AppHelper.tapElement('habit-edit-day-fri');
    
    // Save
    await AppHelper.tapElement('habit-create-save-button');
    
    // Verify it appears in the milestone detail
    const habitCard = await $(`-ios class chain:**/XCUIElementTypeAny[\`label == "${habitName}"\`]`);
    await expect(habitCard).toBeDisplayed();
  });

  it('edits an existing habit name', async () => {
    // Create a habit first
    await createHabitForMilestone(milestoneName, habitName);
    
    // Open habit detail
    const habitRow = await $(`-ios class chain:**/XCUIElementTypeAny[\`label == "${habitName}"\`]`);
    await habitRow.click();
    
    // Tap Edit
    await AppHelper.tapElement('Edit');
    
    // Change name
    const newName = 'Read for 60 mins';
    await AppHelper.clearAndType('habit-edit-name-field', newName);
    
    // Save
    await AppHelper.tapElement('habit-edit-save-button');
    
    // Verify name updated in detail view
    const detailHeader = await $('~habit-detail-view');
    await expect(detailHeader).toHaveText(newName);
  });

  it('deletes a habit from the habit detail view', async () => {
    // Create a habit first
    await createHabitForMilestone(milestoneName, habitName);
    
    // Open habit detail
    const habitRow = await $(`-ios class chain:**/XCUIElementTypeAny[\`label == "${habitName}"\`]`);
    await habitRow.click();
    
    // Tap Edit
    await AppHelper.tapElement('Edit');
    
    // Tap Delete Habit button in Edit view
    await AppHelper.tapElement('habit-edit-delete-button');
    
    // Confirm in dialog
    const confirmButton = await $('~Delete');
    await confirmButton.waitForDisplayed({ timeout: 5000 });
    await confirmButton.click();
    
    // Wait for animation and dismissal
    await driver.pause(2000);
    
    // Verify it's gone from the milestone detail view
    const deletedHabit = await $(`~habit-card-${habitName}`);
    await expect(deletedHabit).not.toBeDisplayed();
  });

  it('correctly saves and displays the habit day schedule', async () => {
    // Open the milestone
    const milestoneRow = await $(`-ios class chain:**/XCUIElementTypeAny[\`label == "${milestoneName}"\`]`);
    await milestoneRow.click();
    
    // Tap the Add button in milestone detail
    await AppHelper.tapElement('milestone-add-action-habit-button');
    
    // Switch to Habit type
    const habitSegment = await $(`-ios class chain:**/XCUIElementTypeButton[\`label == "Habit"\`]`);
    await habitSegment.click();
    
    // Fill in habit details
    const scheduleHabitName = 'Morning Yoga';
    await AppHelper.clearAndType('habit-create-name-field', scheduleHabitName);
    
    // Select Tue, Thu, Sat
    // Note: identifiers were added as mon, tue, wed, thu, fri, sat, sun
    await AppHelper.tapElement('habit-edit-day-tue');
    await AppHelper.tapElement('habit-edit-day-thu');
    await AppHelper.tapElement('habit-edit-day-sat');
    
    // Save
    await AppHelper.tapElement('habit-create-save-button');
    await driver.pause(1000);
    
    // Open the habit detail
    const habitCard = await $(`~habit-card-${scheduleHabitName}`);
    await habitCard.click();
    
    // Verify the days in detail view
    const tueCircle = await $('~habit-day-circle-tue');
    const thuCircle = await $('~habit-day-circle-thu');
    const satCircle = await $('~habit-day-circle-sat');
    
    await expect(tueCircle).toBeDisplayed();
    await expect(thuCircle).toBeDisplayed();
    await expect(satCircle).toBeDisplayed();
    
    // Clean up
    await driver.back();
  });
});

async function createHabitForMilestone(milestone: string, habit: string) {
  const milestoneRow = await $(`-ios class chain:**/XCUIElementTypeAny[\`label == "${milestone}"\`]`);
  await milestoneRow.click();
  await AppHelper.tapElement('milestone-add-action-habit-button');
  const habitSegment = await $(`-ios class chain:**/XCUIElementTypeButton[\`label == "Habit"\`]`);
  await habitSegment.click();
  await AppHelper.typeIntoElement('habit-create-name-field', habit);
  await AppHelper.tapElement('habit-edit-day-mon');
  await AppHelper.tapElement('habit-create-save-button');
  // Wait for list to update
  await driver.pause(1000);
}
