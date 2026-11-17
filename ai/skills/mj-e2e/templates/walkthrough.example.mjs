// e2e/<feature>/walkthrough.mjs: the manifest's steps as a script, for scripts/run.mjs.
// One step() per manifest step, same ids. Each step does its action; run.mjs takes the screenshot
// after it, so end a step on the screen the manifest's `expect` describes.
// Use role/text locators (getByRole, getByLabel, getByText) over CSS, and Playwright's
// auto-waiting expectations instead of sleeps.

export default async function walkthrough({ page, step, baseURL, expect }) {
  await step('open-basket', 'Open the basket', async () => {
    await page.goto(`${baseURL}/basket`);
    await expect(page.getByRole('heading', { name: 'Basket' })).toBeVisible();
  });

  await step('apply-valid', 'Apply a valid code', async () => {
    await page.getByLabel('Discount code').fill('SAVE10');
    await page.getByRole('button', { name: 'Apply' }).click();
    await expect(page.getByText('Discount (SAVE10)')).toBeVisible();
  });

  await step('apply-invalid', 'An invalid code is refused', async () => {
    await page.getByLabel('Discount code').fill('NOPE');
    await page.getByRole('button', { name: 'Apply' }).click();
    await expect(page.getByText("That code isn't valid")).toBeVisible();
  });

  await step('checkout-carries-discount', 'Checkout keeps the discount', async () => {
    await page.getByLabel('Discount code').fill('SAVE10');
    await page.getByRole('button', { name: 'Apply' }).click();
    await page.getByRole('link', { name: 'Checkout' }).click();
    await expect(page.getByText('£27.00')).toBeVisible();
  }, { fullPage: true });
}
