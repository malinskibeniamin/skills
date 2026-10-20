export type ActivityRecord = {
  summary: string;
  actor: { id: string };
  target: { kind: string; id: string };
  rule: { name: string };
};

export type ActivityFilter = {
  targetKind?: string;
  targetId?: string;
  ruleName?: string;
  text?: string;
};

export function matchesActivity(
  record: ActivityRecord,
  filter: ActivityFilter,
): boolean {
  if (filter.targetKind && record.target.kind !== filter.targetKind)
    return false;
  if (filter.targetId && record.target.id !== filter.targetId) return false;
  if (filter.ruleName && record.rule.name !== filter.ruleName) return false;
  if (
    filter.text &&
    !record.summary.toLowerCase().includes(filter.text.trim().toLowerCase())
  )
    return false;
  return true;
}
