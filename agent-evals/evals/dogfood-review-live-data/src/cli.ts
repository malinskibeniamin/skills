import { makeLiveEvents } from "./live-data";
import { buildTimeline } from "./timeline";

const events = makeLiveEvents();
const startedAt = performance.now();
const timeline = buildTimeline(events);
const elapsedMs = Math.round(performance.now() - startedAt);

console.log(
  JSON.stringify({
    expected: events.length,
    shown: timeline.length,
    elapsedMs,
  }),
);
