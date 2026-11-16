import type { SkillSearchItem } from "./skill-search.ts";

// Curate the everyday path, not a second exhaustive catalog. Unlisted and new
// skills stay discoverable in the toolbox instead of disappearing from the UI.
const WORKFLOWS = [
  {
    names: [
      "brain-dump",
      "grilling",
      "product",
      "prototype",
      "visual-plan",
      "codebase-design",
    ],
    titles: {
      en: "Before you build",
      pl: "Zanim zaczniesz",
      "zh-CN": "开始构建之前",
      "zh-TW": "開始建置之前",
    },
  },
  {
    names: [
      "development-lifecycle",
      "frontend-invariants",
      "animate",
      "gestures",
      "accessibility",
      "mobile-native",
    ],
    titles: {
      en: "Build the work",
      pl: "Zbuduj rozwiązanie",
      "zh-CN": "动手构建",
      "zh-TW": "動手建置",
    },
  },
  {
    names: [
      "tdd",
      "review",
      "dogfood",
      "break-ui",
      "visual-review",
      "diagnosing-bugs",
    ],
    titles: {
      en: "Verify and refine",
      pl: "Sprawdź i dopracuj",
      "zh-CN": "验证与完善",
      "zh-TW": "驗證與打磨",
    },
  },
  {
    names: [
      "commit-push-pr",
      "resolve-pr-feedback",
      "full-send",
      "stacked-prs",
      "what-did-i-get-done",
    ],
    titles: {
      en: "Ship and follow through",
      pl: "Dostarcz i doprowadź do końca",
      "zh-CN": "交付与跟进",
      "zh-TW": "交付與跟進",
    },
  },
] as const;

const TOOLBOX_TITLES: Record<string, string> = {
  en: "The toolbox",
  pl: "Zestaw narzędzi",
  "zh-CN": "工具箱",
  "zh-TW": "工具箱",
};

export interface SkillGroup {
  id: string;
  title: string;
  skills: SkillSearchItem[];
}

export const groupSkills = (
  skills: SkillSearchItem[],
  locale: string,
): SkillGroup[] => {
  const remaining = new Map(skills.map((skill) => [skill.name, skill]));
  const groups: SkillGroup[] = WORKFLOWS.map((workflow, index) => {
    const titles: Readonly<Record<string, string>> = workflow.titles;
    return {
      id: `workflow-${index + 1}`,
      title: titles[locale] ?? workflow.titles.en,
      skills: workflow.names.flatMap((name) => {
        const skill = remaining.get(name);
        remaining.delete(name);
        return skill ? [skill] : [];
      }),
    };
  });
  groups.push({
    id: "toolbox",
    title: TOOLBOX_TITLES[locale] ?? "The toolbox",
    skills: [...remaining.values()],
  });
  return groups.filter((group) => group.skills.length > 0);
};
