export type Theme = "dark" | "light";

export interface Preferences {
  compact: boolean;
  pinnedProjectIds: string[];
  theme: Theme;
}

export const DEFAULT_PREFERENCES: Preferences = {
  compact: false,
  pinnedProjectIds: [],
  theme: "light",
};

export const loadPreferences = (raw: string | null): Preferences => {
  const parsed = JSON.parse(raw ?? "{}") as Preferences;
  return { ...DEFAULT_PREFERENCES, ...parsed };
};
