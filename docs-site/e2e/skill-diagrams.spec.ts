import { expect, test } from "@playwright/test";
import { readdir, readFile } from "node:fs/promises";
import { join } from "node:path";

// One public SVG per layout family. Catalog-wide native integrity and geometry
// live in skill-diagram-native.test.ts; these guard the actual font/layout render.
const directory = join(import.meta.dirname, "../public/diagrams/skills");
const representatives = new Map<string, string>();
for (const file of (await readdir(directory)).sort()) {
  if (!file.endsWith(".excalidraw")) continue;
  const scene: { diagramKind: string } = JSON.parse(
    await readFile(join(directory, file), "utf8"),
  );
  if (!representatives.has(scene.diagramKind)) {
    representatives.set(scene.diagramKind, file.replace(".excalidraw", ""));
  }
}
for (const [kind, name] of representatives) {
  test(`skill diagram render: ${kind}`, async ({ page }) => {
    const response = await page.goto(`/diagrams/skills/${name}.svg`);
    expect(response?.ok()).toBe(true);
    const svg = page.locator("svg");
    await expect(svg.locator("title")).toContainText(`/${name}`);
    await page.evaluate(() => document.fonts.ready);
    await expect(svg).toHaveScreenshot(`${kind}.png`);
  });
}

test("archived skill diagram remains viewable and editable", async ({
  page,
}) => {
  await page.goto("/v4.38.0/skills/resolving-merge-conflicts");
  const diagram = page.getByRole("img", {
    name: "Diagram of the /resolving-merge-conflicts skill",
  });
  await expect(diagram).toBeVisible();
  const source = await page.request.get(
    "/diagrams/skills/resolving-merge-conflicts.excalidraw",
  );
  expect(source.ok()).toBe(true);
  const scene: { elements: unknown[] } = await source.json();
  expect(scene.elements.length).toBeGreaterThan(0);
  await expect(diagram).toHaveScreenshot("archived-merge-conflicts.png");
});
