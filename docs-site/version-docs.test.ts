import { describe, expect, test } from "bun:test";
import { mkdir, mkdtemp, readFile, rm, writeFile } from "node:fs/promises";
import { tmpdir } from "node:os";
import { join } from "node:path";
import { fileURLToPath } from "node:url";

import {
  pinSnapshotLinksInText,
  runVersionDocs,
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

  test("rejects duplicate snapshots even when force is explicit", async () => {
    const root = await mkdtemp(join(tmpdir(), "version-docs-"));
    const marker = join(root, "blume-invoked");
    const blume = join(root, "blume");

    try {
      await mkdir(join(root, "content", "v4.38.0"), { recursive: true });
      await writeFile(blume, "#!/bin/sh\nprintf invoked > blume-invoked\n", {
        mode: 0o755,
      });

      const exitCode = await runVersionDocs({
        arguments_: ["v4.38.0"],
        blume,
        root,
      });

      expect(exitCode).toBe(1);
      expect(await Bun.file(marker).exists()).toBeFalse();

      const forcedExitCode = await runVersionDocs({
        arguments_: ["--force", "v4.38.0"],
        blume,
        root,
      });

      expect(forcedExitCode).toBe(1);
      expect(await Bun.file(marker).exists()).toBeFalse();
    } finally {
      await rm(root, { force: true, recursive: true });
    }
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
