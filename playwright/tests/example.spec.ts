import { test, expect } from '@playwright/test';

test('has title', async ({ page }) => {
  await page.goto('https://aksquackersbank.eastus.cloudapp.azure.com/');

  // Expect a title "to contain" a substring.
  await expect(page).toHaveTitle(/Quackers Bank/);
});

test('get health link', async ({ page }) => {
  await page.goto('https://aksquackersbank.eastus.cloudapp.azure.com/');

  // Click the get Health.
  await page.getByRole('link', { name: 'Health' }).click();

  // Expects page to have a heading with the name of Frontend, Accounts API and Transactions API.
  await expect(page.getByRole('heading', { name: 'Frontend' })).toBeVisible();
  await expect(page.getByRole('heading', { name: 'Accounts API' })).toBeVisible();
  await expect(page.getByRole('heading', { name: 'Transactions API' })).toBeVisible();

  await expect(page.getByText('accounts api is healthy')).toBeVisible();
  await expect(page.getByText('transactions api is healthy')).toBeVisible();
});
