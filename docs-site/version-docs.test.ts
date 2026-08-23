import { describe, expect, test } from "bun:test";
import { readFile } from "node:fs/promises";
import { fileURLToPath } from "node:url";

import {
  pinSnapshotLinksInText,
  versionIdFromArguments,
} from "./version-docs.ts";

describe("docs version command", () => {
  test("pins generated links to the archived version", () => {
    expect(versionIdFromArguments(["v4.38.0"])).toBe("v4.38.0");
    expect(versionIdFromArguments(["--force", "v4.38.0"])).toBe("v4.38.0");
    expect(
      pinSnapshotLinksInText(
        "https://github.com/malinskibeniamin/skills/blob/main/tdd/REFERENCE.md",
        "v4.38.0",
      ),
    ).toBe(
      "https://github.com/malinskibeniamin/skills/blob/v4.38.0/tdd/REFERENCE.md",
    );
  });

  test("leaves current docs on main when listing versions", () => {
    expect(versionIdFromArguments([])).toBeUndefined();
  });

  test("keeps archived skill links pinned to their release tags", async () => {
    const mutableLinks: string[] = [];
    const archiveFiles = new Bun.Glob("v*/**/*.{md,mdx}").scan({
      absolute: true,
      cwd: fileURLToPath(new URL("./content", import.meta.url)),
    });

    for await (const archiveFile of archiveFiles) {
      if (
        (await readFile(archiveFile, "utf8")).includes(
          "github.com/malinskibeniamin/skills/blob/main/",
        )
      ) {
        mutableLinks.push(archiveFile);
      }
    }

    expect(mutableLinks).toEqual([]);
  });
});
