export interface SkillSearchItem {
  description: string;
  name: string;
}

const isSkillSearchItem = (value: unknown): value is SkillSearchItem =>
  typeof value === "object" &&
  value !== null &&
  "description" in value &&
  typeof value.description === "string" &&
  value.description.length > 0 &&
  "name" in value &&
  typeof value.name === "string" &&
  value.name.length > 0;

const queryTokens = (query: string): string[] =>
  query.trim().toLocaleLowerCase().split(/\s+/).filter(Boolean);

export const filterSkills = (
  skills: SkillSearchItem[],
  query: string,
): SkillSearchItem[] => {
  const tokens = queryTokens(query);
  if (tokens.length === 0) {
    return skills;
  }

  return skills.filter((skill) => {
    const searchable =
      `/${skill.name} ${skill.description}`.toLocaleLowerCase();
    return tokens.every((token) => searchable.includes(token));
  });
};

export const serializeSkillSearchMarkdown = (value: unknown): string | null => {
  if (!Array.isArray(value) || !value.every(isSkillSearchItem)) {
    return null;
  }

  return value
    .map(
      (skill) =>
        `- [/${skill.name}](/skills/${skill.name}) — ${skill.description}`,
    )
    .join("\n");
};
