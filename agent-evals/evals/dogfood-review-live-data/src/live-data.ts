import type { TimelineEvent } from "./timeline";

export const makeLiveEvents = (eventsPerTenant = 10_000): TimelineEvent[] => {
  const events: TimelineEvent[] = [];
  for (const tenantId of ["tenant-a", "tenant-b"]) {
    for (let index = 0; index < eventsPerTenant; index += 1) {
      events.push({
        id: `event-${index}`,
        tenantId,
        occurredAt: `2026-07-31T12:${String(index % 60).padStart(2, "0")}:00Z`,
      });
    }
  }
  return events;
};
