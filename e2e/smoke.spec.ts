import { expect, test } from "@playwright/test";

test("abre a visão geral em modo demo", async ({ page }) => {
  await page.goto("/");
  await expect(page.getByRole("heading", { name: "Visão geral" })).toBeVisible();
  await expect(page.getByText("modo demo")).toBeVisible();
});

test("navega para Integrações", async ({ page }) => {
  await page.goto("/");
  await page.getByRole("link", { name: "Integrações" }).click();
  await expect(page.getByRole("heading", { name: "Integrações" })).toBeVisible();
});
