import { describe, expect, test } from "bun:test";

import {
  filterSkills,
  serializeSkillSearchMarkdown,
  type SkillSearchItem,
} from "./skill-search.ts";

const skills: SkillSearchItem[] = [
  {
    description:
      "React accessibility guidance for keyboard and focus behavior.",
    name: "accessibility",
  },
  {
    description: "Review PostgreSQL schemas, indexes, and transactions.",
    name: "postgresql",
  },
  {
    description: "Review a diff for evidence-backed defects.",
    name: "review",
  },
];

describe("skill search", () => {
  test("filters by skill name or description without case sensitivity", () => {
    expect(
      filterSkills(skills, "/POSTGRES").map((skill) => skill.name),
    ).toEqual(["postgresql"]);
    expect(
      filterSkills(skills, "keyboard focus").map((skill) => skill.name),
    ).toEqual(["accessibility"]);
  });

  test("returns every skill for an empty query and none for a miss", () => {
    expect(filterSkills(skills, "   ")).toEqual(skills);
    expect(filterSkills(skills, "kubernetes")).toEqual([]);
  });

  test("keeps the interactive directory readable as Markdown", () => {
    expect(serializeSkillSearchMarkdown(skills)).toBe(
      "- [/accessibility](/skills/accessibility) — React accessibility guidance for keyboard and focus behavior.\n" +
        "- [/postgresql](/skills/postgresql) — Review PostgreSQL schemas, indexes, and transactions.\n" +
        "- [/review](/skills/review) — Review a diff for evidence-backed defects.",
    );
    expect(serializeSkillSearchMarkdown([{ name: "broken" }])).toBeNull();
  });
});
