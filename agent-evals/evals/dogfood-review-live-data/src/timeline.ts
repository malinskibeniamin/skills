export type TimelineEvent = {
  id: string;
  tenantId: string;
  occurredAt: string;
};

export const buildTimeline = (events: TimelineEvent[]): TimelineEvent[] => {
  const ordered = [...events].sort((left, right) =>
    right.occurredAt.localeCompare(left.occurredAt),
  );
  const unique: TimelineEvent[] = [];
  for (const event of ordered) {
    if (unique.some((candidate) => candidate.id === event.id)) {
      continue;
    }
    unique.push(event);
  }
  return unique;
};
