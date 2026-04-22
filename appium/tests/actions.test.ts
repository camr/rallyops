import { AppHelper } from '../helpers/AppHelper';

describe('Actions E2E', () => {
  const milestoneName = 'Action Test Milestone';
  const actionName = 'Action One';

  it('performs full action lifecycle', async () => {
    await AppHelper.resetApp();
    await AppHelper.completeOnboarding();
    
    // LANDING: Verify focus header
    const header = await $(`-ios class chain:**/XCUIElementTypeStaticText[\`label CONTAINS "Daily Focus"\`]`);
    await expect(header).toBeDisplayed();

    // NAVIGATE: To Milestones
    await AppHelper.tapTab('Milestones');
    
    // CREATE MILESTONE
    await AppHelper.tapElement('milestone-add-button');
    await AppHelper.clearAndType('milestone-create-name-field', milestoneName);
    
    const picker = await $('~milestone-create-core-value-picker');
    await picker.click();
    await driver.pause(1000);
    const menuOption = await $(`-ios class chain:**/XCUIElementTypeButton[\`label == "Healthy Relationships"\`]`);
    await menuOption.click();
    await driver.pause(1000);
    
    await AppHelper.tapElement('milestone-create-save-button');
    await driver.pause(3000);
    
    // OPEN MILESTONE
    const milestoneRow = await $(`-ios class chain:**/XCUIElementTypeAny[\`label == "${milestoneName}"\`]`);
    await milestoneRow.waitForDisplayed({ timeout: 10000 });
    await milestoneRow.click();
    
    // ADD ACTION
    await AppHelper.tapElement('milestone-add-action-habit-button');
    await AppHelper.clearAndType('action-create-name-field', actionName);
    await AppHelper.tapElement('action-create-save-button');
    await driver.pause(2000);
    
    // VERIFY & TOGGLE
    const checkbox = await $(`~action-checkbox-${actionName}`);
    await checkbox.waitForDisplayed({ timeout: 10000 });
    await checkbox.click();
    await driver.pause(1000);
    
    // DELETE
    const actionRow = await $(`-ios class chain:**/XCUIElementTypeAny[\`label == "${actionName}"\`]`);
    await actionRow.click();
    
    await AppHelper.tapElement('Edit');
    await AppHelper.tapElement('action-edit-delete-button');
    
    const confirmButton = await $('~Delete');
    await confirmButton.click();
    await driver.pause(2000);
    
    // VERIFY DELETED
    const deletedRow = await $(`-ios class chain:**/XCUIElementTypeAny[\`label == "${actionName}"\`]`);
    await expect(deletedRow).not.toBeDisplayed();
  });
});
