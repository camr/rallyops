import { AppHelper } from '../helpers/AppHelper';

describe('Smoke Test', () => {
  it('app launches and Today tab is visible', async () => {
    await AppHelper.completeOnboarding();
    const todayTab = await AppHelper.waitForElement('today-tab', 30000);
    await expect(todayTab).toBeDisplayed();
  });
});
