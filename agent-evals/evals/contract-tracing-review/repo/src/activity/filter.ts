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

const summaryContains = (record: ActivityRecord, value: string): boolean =>
  record.summary.toLocaleLowerCase().includes(value.trim().toLocaleLowerCase());

export const matchesActivity = (
  record: ActivityRecord,
  filter: ActivityFilter,
): boolean => {
  if (filter.targetKind && !summaryContains(record, filter.targetKind)) {
    return false;
  }
  if (filter.targetId && !summaryContains(record, filter.targetId)) {
    return false;
  }
  if (filter.ruleName && !summaryContains(record, filter.ruleName)) {
    return false;
  }
  if (filter.text && !summaryContains(record, filter.text)) {
    return false;
  }
  return true;
};
