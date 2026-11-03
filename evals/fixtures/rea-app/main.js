import { percentOf } from "./math.js";

export function addPercent(base, percentage) {
  return base + percentOf(base, percentage);
}
