import { expect, test } from "bun:test";
import { groupSkills } from "./skill-groups.ts";

test("workflow groups keep every skill once, including new and unknown skills", () => {
  const skills = [
    "review",
    "a-new-skill",
    "tdd",
    "grilling",
    "development-lifecycle",
  ].map((name) => ({ name, description: name }));
  const groups = groupSkills(skills, "en");
  expect(groups.map((group) => group.title)).toEqual([
    "Before you build",
    "Build the work",
    "Verify and refine",
    "The toolbox",
  ]);
  expect(
    groups.flatMap((group) => group.skills.map((skill) => skill.name)),
  ).toEqual([
    "grilling",
    "development-lifecycle",
    "tdd",
    "review",
    "a-new-skill",
  ]);
  expect(groupSkills([], "en")).toEqual([]);
});

test("workflow headings follow the reader's language", () => {
  const skills = [{ name: "tdd", description: "Test" }];
  expect(groupSkills(skills, "pl")[0]?.title).toBe("Sprawdź i dopracuj");
  expect(groupSkills(skills, "zh-CN")[0]?.title).toBe("验证与完善");
  expect(groupSkills(skills, "zh-TW")[0]?.title).toBe("驗證與打磨");
  expect(groupSkills(skills, "unknown")[0]?.title).toBe("Verify and refine");
});
