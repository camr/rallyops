// NOTE: Requires PR #73 (appium scaffold) and PR #75 (accessibilityIdentifiers) to be merged

import { AppHelper } from '../helpers/AppHelper';

describe('Core Values', () => {
  beforeEach(async () => {
    await AppHelper.resetApp();
    await AppHelper.completeOnboarding();
    await AppHelper.tapElement('core-values-tab');
  });

  // ------------------------------------------------------------------ //
  // List View
  // ------------------------------------------------------------------ //
  describe('List View', () => {
    it('shows the core-values-list after tapping the Core Values tab', async () => {
      const list = await AppHelper.waitForElement('core-values-list');
      await expect(list).toBeDisplayed();
    });
  });

  // ------------------------------------------------------------------ //
  // Create
  // ------------------------------------------------------------------ //
  describe('Create', () => {
    /**
     * Open the create form. The app is expected to expose a "+" / add button
     * on the Core Values list screen with accessibility ID "core-value-add-button"
     * OR navigate automatically. Adjust if the app uses a different trigger.
     */
    async function openCreateForm(): Promise<void> {
      // Try a common "add" button first; skip navigation if the form opens
      // automatically (e.g. empty-state CTA).
      const addExists = await AppHelper.elementExists('core-value-add-button', 3000);
      if (addExists) {
        await AppHelper.tapElement('core-value-add-button');
      }
    }

    it('saves a new value with valid name and description and shows it in the list', async () => {
      await openCreateForm();

      await AppHelper.typeIntoElement('core-value-create-name-field', 'Health');
      await AppHelper.typeIntoElement(
        'core-value-create-description-field',
        'Physical and mental wellbeing'
      );
      await AppHelper.tapElement('core-value-create-save-button');

      // Verify the list is shown again after saving.
      const list = await AppHelper.waitForElement('core-values-list');
      await expect(list).toBeDisplayed();

      // Locate the newly created value by its label text.
      const newRow = await $('-ios class chain:**/XCUIElementTypeAny[`label == "Health"`]');
      await expect(newRow).toBeDisplayed();
    });

    it('does not save (or shows validation error) when name field is empty', async () => {
      await openCreateForm();

      // Leave name blank, type only in the description field.
      await AppHelper.typeIntoElement(
        'core-value-create-description-field',
        'A description without a name'
      );
      await AppHelper.tapElement('core-value-create-save-button');

      // After tapping save with an empty name the form should either:
      //   (a) remain visible (save did nothing), or
      //   (b) show a validation error element.
      // We assert that the list is NOT the current top-level view — the form is
      // still in front — OR that a validation error is displayed.
      const formStillVisible = await AppHelper.elementExists(
        'core-value-create-name-field',
        3000
      );
      const validationError = await AppHelper.elementExists(
        'core-value-create-validation-error',
        2000
      );
      expect(formStillVisible || validationError).toBe(true);
    });

    it('does not add a new value when the create form is cancelled', async () => {
      await openCreateForm();

      await AppHelper.typeIntoElement('core-value-create-name-field', 'ShouldNotAppear');
      await AppHelper.tapElement('core-value-create-cancel-button');

      // List should be visible again.
      const list = await AppHelper.waitForElement('core-values-list');
      await expect(list).toBeDisplayed();

      // The typed value should not appear in the list.
      const cancelledRow = await $('-ios class chain:**/XCUIElementTypeAny[`label == "ShouldNotAppear"`]');
      await expect(cancelledRow).not.toBeDisplayed();
    });

    it('saves a new value whose name contains special characters (emoji)', async () => {
      await openCreateForm();

      const emojiName = '🌱 Growth';
      await AppHelper.typeIntoElement('core-value-create-name-field', emojiName);
      await AppHelper.tapElement('core-value-create-save-button');

      // Confirm we returned to the list.
      const list = await AppHelper.waitForElement('core-values-list');
      await expect(list).toBeDisplayed();

      // Locate by label containing the emoji.
      const emojiRow = await $('-ios class chain:**/XCUIElementTypeAny[`label CONTAINS "🌱"`]');
      await expect(emojiRow).toBeDisplayed();
    });
  });

  // ------------------------------------------------------------------ //
  // Detail View
  // ------------------------------------------------------------------ //
  describe('Detail View', () => {
    /**
     * Creates a known value so detail-view tests have something to tap.
     */
    async function createAndNavigateToValue(name: string): Promise<void> {
      const addExists = await AppHelper.elementExists('core-value-add-button', 3000);
      if (addExists) {
        await AppHelper.tapElement('core-value-add-button');
      }
      await AppHelper.typeIntoElement('core-value-create-name-field', name);
      await AppHelper.tapElement('core-value-create-save-button');
      await AppHelper.waitForElement('core-values-list');
    }

    it('shows the detail view when a row is tapped', async () => {
      await createAndNavigateToValue('Integrity');

      // Tap the row by label since the row ID is dynamic.
      const row = await $('-ios class chain:**/XCUIElementTypeAny[`label == "Integrity"`]');
      await row.click();

      const detailView = await AppHelper.waitForElement('core-value-detail-view');
      await expect(detailView).toBeDisplayed();
    });

    it('shows the correct name in the detail view', async () => {
      await createAndNavigateToValue('Courage');

      const row = await $('-ios class chain:**/XCUIElementTypeAny[`label == "Courage"`]');
      await row.click();

      await AppHelper.waitForElement('core-value-detail-view');

      // The name "Courage" should be visible somewhere inside the detail view.
      const nameLabel = await $('-ios class chain:**/XCUIElementTypeAny[`label == "Courage"`]');
      await expect(nameLabel).toBeDisplayed();
    });
  });

  // ------------------------------------------------------------------ //
  // Edit
  // ------------------------------------------------------------------ //
  describe('Edit', () => {
    /**
     * Helper: creates a value, opens its detail, then taps the edit button.
     * Assumes the edit button is reachable from the detail view via the label "Edit".
     */
    async function openEditForm(originalName: string): Promise<void> {
      // Create the value.
      const addExists = await AppHelper.elementExists('core-value-add-button', 3000);
      if (addExists) {
        await AppHelper.tapElement('core-value-add-button');
      }
      await AppHelper.typeIntoElement('core-value-create-name-field', originalName);
      await AppHelper.tapElement('core-value-create-save-button');
      await AppHelper.waitForElement('core-values-list');

      // Open detail view.
      const row = await $(`-ios class chain:**/XCUIElementTypeAny[\`label == "${originalName}"\`]`);
      await row.click();
      await AppHelper.waitForElement('core-value-detail-view');

      // Tap the Edit navigation button (standard iOS "Edit" bar button).
      const editButton = await $('~Edit');
      await editButton.click();
    }

    it('updates the name and shows the updated name after saving', async () => {
      await openEditForm('Perseverance');

      await AppHelper.clearAndType('core-value-edit-name-field', 'Resilience');
      await AppHelper.tapElement('core-value-edit-save-button');

      // After save, detail or list should show the new name.
      const updatedLabel = await $('-ios class chain:**/XCUIElementTypeAny[`label == "Resilience"`]');
      await expect(updatedLabel).toBeDisplayed();

      // Old name should no longer be visible.
      const oldLabel = await $('-ios class chain:**/XCUIElementTypeAny[`label == "Perseverance"`]');
      await expect(oldLabel).not.toBeDisplayed();
    });

    it('leaves the name unchanged when editing is cancelled', async () => {
      await openEditForm('Kindness');

      await AppHelper.clearAndType('core-value-edit-name-field', 'ShouldNotBeSaved');

      // Tap the standard iOS "Cancel" bar button.
      const cancelButton = await $('~Cancel');
      await cancelButton.click();

      // Detail view should still show the original name.
      const originalLabel = await $('-ios class chain:**/XCUIElementTypeAny[`label == "Kindness"`]');
      await expect(originalLabel).toBeDisplayed();
    });
  });

  // ------------------------------------------------------------------ //
  // Delete
  // ------------------------------------------------------------------ //
  describe('Delete', () => {
    /**
     * Creates a value and returns to the list view.
     */
    async function createValue(name: string): Promise<void> {
      const addExists = await AppHelper.elementExists('core-value-add-button', 3000);
      if (addExists) {
        await AppHelper.tapElement('core-value-add-button');
      }
      await AppHelper.typeIntoElement('core-value-create-name-field', name);
      await AppHelper.tapElement('core-value-create-save-button');
      await AppHelper.waitForElement('core-values-list');
    }

    it('removes the value from the list after a swipe-to-delete gesture', async () => {
      const valueName = 'ToBeDeleted';
      await createValue(valueName);

      // Locate the row by label and perform a left swipe to reveal the Delete action.
      const row = await $(`-ios class chain:**/XCUIElementTypeAny[\`label == "${valueName}"\`]`);
      await expect(row).toBeDisplayed();

      // Swipe left on the row to reveal the delete button.
      await AppHelper.swipeLeft(row);

      // Tap the system "Delete" button that appears after swipe.
      const deleteButton = await $('~Delete');
      await deleteButton.waitForDisplayed({ timeout: 5000 });
      await deleteButton.click();

      // Confirm the row is gone from the list.
      const deletedRow = await $(`-ios class chain:**/XCUIElementTypeAny[\`label == "${valueName}"\`]`);
      await expect(deletedRow).not.toBeDisplayed();
    });
  });
});
