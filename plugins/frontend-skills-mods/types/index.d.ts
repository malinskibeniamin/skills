export type ContextReading = {
  tokens: number;
  window: number;
  percent: number;
} | null;

declare module "claude-code" {
  interface PluginState {
    "frontend-skills-mods": {
      context: ContextReading;
      lastSkill: string | null;
    };
  }
}
