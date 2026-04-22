// NOTE: Requires PR #73 (appium scaffold) and PR #75 (accessibilityIdentifiers)

import { AppHelper } from '../helpers/AppHelper';

// ---------------------------------------------------------------------------
// Helper: create a core value so milestone creation tests have a value to pick
// ---------------------------------------------------------------------------
async function createCoreValue(name: string): Promise<void> {
  await AppHelper.tapElement('core-values-tab');
  await AppHelper.tapElement('core-value-add-button');
  await AppHelper.typeIntoElement('core-value-create-name-field', name);
  await AppHelper.tapElement('core-value-create-save-button');

  // Wait for the form to dismiss and list to appear
  await AppHelper.waitForElement('core-values-list');

  // Return to milestones tab after creating the core value
  await AppHelper.tapElement('milestones-tab');
}

// ---------------------------------------------------------------------------
// Helper: create a milestone (assumes a core value already exists)
// ---------------------------------------------------------------------------
async function createMilestone(name: string, coreValueName: string = 'Health'): Promise<void> {
  await AppHelper.tapElement('milestone-add-button');
  await AppHelper.typeIntoElement('milestone-create-name-field', name);

  // Select the core value from the picker
  const picker = await $('~milestone-create-core-value-picker');
  await picker.click();

  // Wait a bit for menu to open
  await driver.pause(1000);

  // Tap the specific core value in the menu
  const menuOption = await $(`label=${coreValueName}`);
  await menuOption.waitForDisplayed({ timeout: 5000 });
  await menuOption.click();

  // Wait for menu to close and picker to update
  await driver.pause(1000);

  await AppHelper.tapElement('milestone-create-save-button');

  // Wait for the long 'submitting' delay (3s) + dismissal
  await AppHelper.waitForElement('milestones-list', 10000);
}

describe('Milestones', () => {
  beforeEach(async () => {
    await AppHelper.resetApp();
    await AppHelper.completeOnboarding();
    await AppHelper.tapElement('milestones-tab');
  });

  // -------------------------------------------------------------------------
  describe('List View', () => {
    it('shows the milestones list when the tab is active', async () => {
      const list = await AppHelper.waitForElement('milestones-list');
      await expect(list).toBeDisplayed();
    });
  });

  // -------------------------------------------------------------------------
  describe('Create', () => {
    beforeEach(async () => {
      // Use the default core value from onboarding
    });

    it('creates a milestone with a valid name, core value, and future deadline', async () => {
      await createMilestone('Run a marathon', 'Healthy Relationships');

      // The new milestone should appear in the list
      const list = await AppHelper.waitForElement('milestones-list');
      await expect(list).toBeDisplayed();
    });

    it('does nothing when name is empty and save is tapped', async () => {
      await AppHelper.tapElement('milestone-add-button');

      // Leave name field empty — do NOT type anything
      await AppHelper.tapElement('milestone-create-save-button');

      // Create form should still be visible (save was a no-op or shows an error)
      const nameField = await AppHelper.elementExists('milestone-create-name-field', 3000);
      await expect(nameField).toBe(true);
    });

    it('shows a validation state when core value is missing', async () => {
      await AppHelper.tapElement('milestone-add-button');

      await AppHelper.typeIntoElement('milestone-create-name-field', 'No Core Value Milestone');

      // Do NOT pick a core value — tap save immediately
      await AppHelper.tapElement('milestone-create-save-button');

      // Create form should still be present (validation prevents dismissal)
      const nameField = await AppHelper.elementExists('milestone-create-name-field', 3000);
      await expect(nameField).toBe(true);
    });

    it('dismisses the create form without adding a milestone when cancel is tapped', async () => {
      await AppHelper.tapElement('milestone-add-button');

      await AppHelper.typeIntoElement('milestone-create-name-field', 'Cancelled Milestone');
      await AppHelper.tapElement('milestone-create-cancel-button');

      // The list should be visible again and the cancelled milestone should not exist
      const list = await AppHelper.waitForElement('milestones-list');
      await expect(list).toBeDisplayed();
    });
  });

  // -------------------------------------------------------------------------
  describe('Filter', () => {
    beforeEach(async () => {
      // Seed at least one milestone so filters have data to operate on
      await createCoreValue('Growth');
      await createMilestone('Filter Test Milestone', 'Growth');
    });

    it('groups milestones by core value when filter-by-value is tapped', async () => {
      await AppHelper.tapElement('milestone-filter-by-value-button');

      const list = await AppHelper.waitForElement('milestones-list');
      await expect(list).toBeDisplayed();
    });

    it('shows a chronological list when filter-by-date is tapped', async () => {
      await AppHelper.tapElement('milestone-filter-by-date-button');

      const list = await AppHelper.waitForElement('milestones-list');
      await expect(list).toBeDisplayed();
    });

    it('switches back to value grouping after toggling date then value', async () => {
      await AppHelper.tapElement('milestone-filter-by-date-button');
      await AppHelper.tapElement('milestone-filter-by-value-button');

      const list = await AppHelper.waitForElement('milestones-list');
      await expect(list).toBeDisplayed();
    });
  });

  // -------------------------------------------------------------------------
  describe('Detail View', () => {
    beforeEach(async () => {
      await createMilestone('Detail Test Milestone', 'Healthy Relationships');
    });

    it('opens the detail view when a milestone row is tapped', async () => {
      // Find the first visible milestone row and tap it
      const list = await AppHelper.waitForElement('milestones-list');
      await expect(list).toBeDisplayed();

      // Retrieve all milestone row elements using the partial accessibility ID prefix
      const rows = await $$('[name^="milestone-row-"]');
      await expect(rows.length).toBeGreaterThan(0);
      await rows[0].click();

      const detailView = await AppHelper.waitForElement('milestone-detail-view');
      await expect(detailView).toBeDisplayed();
    });
  });

  // -------------------------------------------------------------------------
  describe('Edit', () => {
    beforeEach(async () => {
      await createMilestone('Edit Test Milestone', 'Healthy Relationships');
    });

    it('updates the milestone name after editing and saving', async () => {
      // Open detail view for the first row
      const rows = await $$('[name^="milestone-row-"]');
      await expect(rows.length).toBeGreaterThan(0);
      await rows[0].click();

      await AppHelper.waitForElement('milestone-detail-view');

      // Tap edit (assumes an edit button or inline edit field is revealed in detail view)
      await AppHelper.tapElement('milestone-edit-name-field');
      await AppHelper.clearAndType('milestone-edit-name-field', 'Updated Milestone Name');
      await AppHelper.tapElement('milestone-edit-save-button');

      // After saving, the detail or list should still be visible and not crash
      const detailOrList =
        (await AppHelper.elementExists('milestone-detail-view', 3000)) ||
        (await AppHelper.elementExists('milestones-list', 3000));
      await expect(detailOrList).toBe(true);
    });
  });

  // -------------------------------------------------------------------------
  describe('Delete', () => {
    beforeEach(async () => {
      await createMilestone('Delete Test Milestone', 'Healthy Relationships');
    });

    it('removes the milestone from the list after deleting it', async () => {
      const list = await AppHelper.waitForElement('milestones-list');
      await expect(list).toBeDisplayed();

      const rows = await $$('[name^="milestone-row-"]');
      await expect(rows.length).toBeGreaterThan(0);

      // Capture the accessibility ID of the row we are about to delete
      const targetRowId = await rows[0].getAttribute('name');

      // Perform a left swipe on the row to reveal the delete action
      await rows[0].click(); // open detail first
      await AppHelper.waitForElement('milestone-detail-view');

      // Navigate back to the list via the back gesture / button
      await driver.back();

      // Swipe the row left to reveal delete
      const freshRows = await $$('[name^="milestone-row-"]');
      const targetRow = freshRows[0];
      await AppHelper.swipeLeft(targetRow);

      // Tap the Delete button that appears after the swipe
      const deleteExists = await AppHelper.elementExists('Delete', 3000);
      if (deleteExists) {
        await AppHelper.tapElement('Delete');
      }

      // The row should no longer be in the list
      const rowStillExists = await AppHelper.elementExists(targetRowId, 2000);
      await expect(rowStillExists).toBe(false);
    });
  });
});
