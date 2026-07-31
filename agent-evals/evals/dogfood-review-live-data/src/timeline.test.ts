import { describe, expect, it } from "vitest";

import { buildTimeline, type TimelineEvent } from "./timeline";

describe("buildTimeline", () => {
  it("deduplicates a replayed event", () => {
    const events: TimelineEvent[] = [
      {
        id: "event-1",
        tenantId: "tenant-a",
        occurredAt: "2026-07-31T12:00:00Z",
      },
      {
        id: "event-1",
        tenantId: "tenant-a",
        occurredAt: "2026-07-31T11:00:00Z",
      },
      {
        id: "event-2",
        tenantId: "tenant-a",
        occurredAt: "2026-07-31T10:00:00Z",
      },
    ];

    expect(buildTimeline(events).map((event) => event.id)).toEqual([
      "event-1",
      "event-2",
    ]);
  });
});
