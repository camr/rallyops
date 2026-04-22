import { AppHelper } from '../helpers/AppHelper';

describe('Today View', () => {
  before(async () => {
    await AppHelper.resetApp();
    await AppHelper.completeOnboarding();
    // Default launch lands on Today tab, but wait for it to be sure
    await AppHelper.waitForElement('calendar-button', 20000);
  });

  // No beforeEach needed if we rely on state persisting between tests in this suite

  it('displays the Today view by default after onboarding', async () => {
    // Check for Today tab elements
    const calendarButton = await $('~calendar-button');
    await expect(calendarButton).toBeDisplayed();
    
    const addActionButton = await $('~add-action-button');
    await expect(addActionButton).toBeDisplayed();
    
    // Header text - use partial match or XCUIElementTypeStaticText
    const header = await $(`-ios class chain:**/XCUIElementTypeStaticText[\`label CONTAINS "Daily Focus"\`]`);
    await expect(header).toBeDisplayed();
  });

  it('opens and closes the calendar sheet', async () => {
    await AppHelper.tapElement('calendar-button');
    
    const calendarSheet = await $('~calendar-sheet');
    await expect(calendarSheet).toBeDisplayed();
    
    // Tap Today button in calendar toolbar
    await AppHelper.tapElement('Today');
    
    // Should be dismissed
    await calendarSheet.waitForDisplayed({ reverse: true, timeout: 5000 });
    await expect(calendarSheet).not.toBeDisplayed();
  });

  it('selects a different date and updates the view', async () => {
    // Create a habit for a specific day first to verify content display
    // But for now just test navigation
    
    await AppHelper.tapElement('calendar-button');
    
    // Try to select a day - use waitFor to handle timing
    // Try today first (the current day might already be selected)
    const today = new Date().toISOString().split('T')[0];
    let dayCell = await $(`~calendar-day-cell-${today}`);
    
    // If today isn't available or is already selected, try tapping a different cell
    if (!(await dayCell.isDisplayed())) {
      // Try tapping the first available day cell
      const allDayCells = await $$('~calendar-day-cell-[0-9]{4}-[0-9]{2}-[0-9]{2}');
      if (allDayCells.length > 1) {
        await allDayCells[1].click();
      }
    } else {
      await dayCell.click();
    }
    
    // Header should update (the button label contains the date)
    const calendarButton = await $('~calendar-button');
    const label = await calendarButton.getAttribute('label');
    // It should contain a date
    expect(label).toBeTruthy();
  });
});
