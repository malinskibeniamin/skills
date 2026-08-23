import { expect, test } from "bun:test";
import { join } from "node:path";

const repositoryRoot = join(import.meta.dir, "..");

test("registers optional discovery that preserves settled context for grilling", async () => {
  const skill = await Bun.file(join(import.meta.dir, "SKILL.md")).text();
  const grilling = await Bun.file(
    join(repositoryRoot, "grilling", "SKILL.md"),
  ).text();
  const manifest = await Bun.file(
    join(repositoryRoot, ".claude-plugin", "plugin.json"),
  ).json();

  expect(skill).toMatch(/^name: brain-dump$/m);
  expect(skill).toMatch(/optional/i);
  expect(skill).toMatch(/monologue|unstructured thoughts/i);
  expect(skill).toMatch(/links?|articles?|files?/i);
  expect(skill).toMatch(/multiple|several/i);
  expect(skill).toMatch(/opportunit(?:y|ies)/i);
  expect(skill).toMatch(/do not ask.*repeat|never ask.*repeat/is);
  expect(skill).toMatch(/## Brain dump brief/);
  expect(skill).toMatch(/## Answer ledger/);
  expect(skill).toMatch(/## Opportunity map/);
  expect(skill).toMatch(/## Grilling handoff/);
  expect(skill).toMatch(/return.*chat/i);
  expect(skill).toContain("/grilling");

  expect(grilling).toContain("/brain-dump");
  expect(grilling).toMatch(/answer\s+ledger/i);
  expect(grilling).toMatch(/do not ask.*again|never re-ask/is);
  expect(manifest.skills).toContain("./brain-dump/");
});
