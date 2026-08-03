import { describe, expect, test } from "bun:test";
import { mkdtemp, mkdir, rm, writeFile } from "node:fs/promises";
import { tmpdir } from "node:os";
import { join } from "node:path";

import { createSkillSource } from "./skill-source.ts";

const REPOSITORY_URL = "https://github.com/malinskibeniamin/skills";

describe("skill docs source", () => {
  test("publishes every canonical skill from its existing SKILL.md", async () => {
    const repositoryRoot = join(import.meta.dir, "..");
    const source = createSkillSource({
      branch: "main",
      repositoryRoot,
      repositoryUrl: REPOSITORY_URL,
    });

    const { diagnostics, entries } = await source.load();
    const skillEntries = entries.filter((entry) => entry.ref !== "index.mdx");
    const skillNames = skillEntries.map((entry) => entry.data.title);
    const canonicalSkillFiles = await Array.fromAsync(
      new Bun.Glob("*/SKILL.md").scan({
        cwd: repositoryRoot,
        onlyFiles: true,
      }),
    );

    expect(diagnostics).toEqual([]);
    expect(skillNames).toContain("/accessibility");
    expect(skillNames).toContain("/writing-for-agents");
    expect(skillNames).toHaveLength(canonicalSkillFiles.length);
    expect(new Set(skillNames).size).toBe(skillNames.length);

    const landing = entries.find((entry) => entry.ref === "index.mdx");
    expect(landing?.body.text).toContain(
      `Browse all ${canonicalSkillFiles.length} skills`,
    );
    for (const entry of skillEntries) {
      expect(landing?.body.text).toContain(`href="/${entry.slug}"`);
      expect(entry.data.description).toBeString();
      expect(entry.data.description).not.toHaveLength(0);
      expect(entry.raw).not.toMatch(/^---[\s\S]*?\n---\s*# /);
    }
  });

  test("keeps quoted metadata and points relative references at GitHub", async () => {
    const repositoryRoot = await mkdtemp(join(tmpdir(), "skill-docs-"));

    try {
      const skillDirectory = join(repositoryRoot, "sample-skill");
      await mkdir(skillDirectory);
      await writeFile(
        join(skillDirectory, "SKILL.md"),
        `---
name: sample-skill
description: "Use it when a plan needs \\"proof\\"."
---
# Sample skill

Read [REFERENCE.md](REFERENCE.md) before acting.
`,
      );

      const source = createSkillSource({
        branch: "next",
        repositoryRoot,
        repositoryUrl: REPOSITORY_URL,
      });
      const { entries } = await source.load();
      const page = entries.find((entry) => entry.ref !== "index.mdx");

      expect(page?.data).toEqual({
        description: 'Use it when a plan needs "proof".',
        sidebar: { label: "/sample-skill" },
        title: "/sample-skill",
      });
      expect(page?.slug).toBe("skills/sample-skill");
      expect(page?.body.text).toContain(
        `${REPOSITORY_URL}/blob/next/sample-skill/REFERENCE.md`,
      );
      expect(page?.editUrl).toBe(
        `${REPOSITORY_URL}/edit/next/sample-skill/SKILL.md`,
      );
    } finally {
      await rm(repositoryRoot, { force: true, recursive: true });
    }
  });
});
