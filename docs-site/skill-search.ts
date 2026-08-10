export interface SkillSearchItem {
  description: string;
  name: string;
}

export interface SkillSearchMessages {
  all: (count: number) => string;
  emptyDescription: string;
  emptyTitle: string;
  label: string;
  matches: (count: number, query: string) => string;
  placeholder: string;
}

const ENGLISH_MESSAGES: SkillSearchMessages = {
  all: (count) => `Showing all ${count} skills.`,
  emptyDescription: "Try a skill name, technology, or task.",
  emptyTitle: "No skills found",
  label: "Search skills",
  matches: (count, query) =>
    `${count} ${count === 1 ? "skill matches" : "skills match"} “${query}”.`,
  placeholder: "Try “review”, “React”, or “PostgreSQL”",
};

const MESSAGES_BY_LOCALE: Record<string, SkillSearchMessages> = {
  pl: {
    all: (count) => `Wyświetlanie wszystkich umiejętności: ${count}.`,
    emptyDescription: "Spróbuj nazwy umiejętności, technologii lub zadania.",
    emptyTitle: "Nie znaleziono umiejętności",
    label: "Wyszukaj umiejętności",
    matches: (count, query) => `Liczba wyników dla „${query}”: ${count}.`,
    placeholder: "Spróbuj „review”, „React” lub „PostgreSQL”",
  },
  "zh-CN": {
    all: (count) => `显示全部 ${count} 项技能。`,
    emptyDescription: "请尝试输入技能名称、技术或任务。",
    emptyTitle: "未找到技能",
    label: "搜索技能",
    matches: (count, query) => `“${query}”的匹配结果：${count} 项。`,
    placeholder: "试试“review”、“React”或“PostgreSQL”",
  },
  "zh-TW": {
    all: (count) => `顯示全部 ${count} 項技能。`,
    emptyDescription: "請嘗試輸入技能名稱、技術或任務。",
    emptyTitle: "找不到技能",
    label: "搜尋技能",
    matches: (count, query) => `「${query}」的符合結果：${count} 項。`,
    placeholder: "試試「review」、「React」或「PostgreSQL」",
  },
};

export const skillSearchMessages = (locale: string): SkillSearchMessages =>
  MESSAGES_BY_LOCALE[locale] ?? ENGLISH_MESSAGES;

export const skillHref = (locale: string, skillName: string): string =>
  locale === "en" ? `/skills/${skillName}` : `/${locale}/skills/${skillName}`;

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

export const serializeSkillSearchMarkdown = (
  value: unknown,
  locale = "en",
): string | null => {
  if (!Array.isArray(value) || !value.every(isSkillSearchItem)) {
    return null;
  }

  return value
    .map(
      (skill) =>
        `- [/${skill.name}](${skillHref(locale, skill.name)}) — ${skill.description}`,
    )
    .join("\n");
};
