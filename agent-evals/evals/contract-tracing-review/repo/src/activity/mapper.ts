import type { ActivityRecord } from "./filter";

export type ActionInput = {
  actorId: string;
  operation: string;
  targetKind: string;
  targetId: string;
  ruleName: string;
};

export const toActivityRecord = (input: ActionInput): ActivityRecord => ({
  actor: { id: input.actorId },
  target: { kind: input.targetKind, id: input.targetId },
  rule: { name: input.ruleName },
  summary: `${input.actorId} ${input.operation} ${input.targetKind}/${input.targetId} — allowed by ${input.ruleName}`,
});
