// Real input at the capture-overlay boundary; run by the existing media canary.
import { join } from "node:path";
import { type Browser, expect } from "@playwright/test";

export async function verifyCursorInput(browser: Browser, root: string) {
  const context = await browser.newContext({ hasTouch: true });
  try {
    await context.addInitScript({
      path: join(root, "scripts/pr-video-cursor.js"),
    });
    const page = await context.newPage();
    await page.goto(
      "data:text/html,<button onclick=\"this.textContent='Activated'\">Save</button>",
    );
    const cursor = page.locator('[data-pr-video-overlay="cursor"]');
    const ring = page.locator('[data-pr-video-overlay="click"]');
    const target = page.locator('[data-pr-video-overlay="target"]');
    await page.keyboard.press("Tab");
    await page.keyboard.press("Enter");
    await expect(page.getByRole("button")).toHaveText("Activated");
    await expect(target).toHaveCSS("opacity", "1");
    await expect(cursor).toHaveCSS("opacity", "0");
    await expect(ring).toHaveCSS("opacity", "0");

    await page.mouse.move(140, 90);
    await expect(cursor).toHaveCSS("opacity", "1");
    await expect(cursor).toHaveCSS("transform", "matrix(1, 0, 0, 1, 140, 90)");
    await page.mouse.down();
    await page.mouse.move(200, 110, { steps: 8 });
    expect(
      await cursor.evaluate((element) => getComputedStyle(element).transform),
    ).toBe("matrix(1, 0, 0, 1, 200, 110)");
    await page.mouse.up();

    await page.getByRole("button").tap();
    await expect(cursor).toHaveCSS("opacity", "0");
    // A real touch movement keeps the contact indicator under the finger.
    const cdp = await context.newCDPSession(page);
    await cdp.send("Input.dispatchTouchEvent", {
      type: "touchStart",
      touchPoints: [{ x: 100, y: 80 }],
    });
    await cdp.send("Input.dispatchTouchEvent", {
      type: "touchMove",
      touchPoints: [{ x: 110, y: 85 }],
    });
    await expect(ring).toHaveCSS("left", "110px");
    await expect(ring).toHaveCSS("top", "85px");
    await expect(ring).toHaveCSS("opacity", "1");
    await cdp.send("Input.dispatchTouchEvent", {
      type: "touchCancel",
      touchPoints: [],
    });
    await expect(ring).toHaveCSS("opacity", "0");
    await page.mouse.move(240, 130);
    await expect(cursor).toHaveCSS("opacity", "1");
    await expect(cursor).toHaveCSS("transform", "matrix(1, 0, 0, 1, 240, 130)");
    await expect(cursor).toHaveCSS("pointer-events", "none");
  } finally {
    await context.close();
  }
}
