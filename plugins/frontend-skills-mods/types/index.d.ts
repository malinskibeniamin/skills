export type ContextReading = {
  tokens: number;
  window: number;
  percent: number;
} | null;

export type DeskView = "proof" | "skills" | "replay";

export type CheckKind = "types" | "lint" | "tests" | "mods";
export type ProofReceipt = {
  toolId: string;
  outcome: "pending" | "passed" | "failed" | "denied" | "incomplete";
  fingerprint: string | null;
  changedDuringCheck: boolean;
};

export type SkillObservation = {
  name: string;
  provenance: string;
  outcome:
    | "succeeded"
    | "failed"
    | "denied"
    | "loaded read-only"
    | "forked (launched; outcome unknown)"
    | "forked (completed)";
};

export type SkillsState = { entries: SkillObservation[]; generation: number };

export type ReplayEntry = {
  path: string;
  toolId: string;
  provenance: string;
  turn: string;
  diff: string;
  truncated: boolean;
};
export type ReplayState = {
  entries: ReplayEntry[];
  index: number;
  generation: number;
  excluded: number;
};

declare module "claude-code" {
  interface PluginState {
    "frontend-skills-mods": {
      context: ContextReading;
      deskView: DeskView;
      repository: string | null;
      proof: StateFamily<ProofReceipt>;
      lastSkill: string | null;
      skills: SkillsState;
      turn: string;
      replay: ReplayState;
    };
  }
}
