// Dependency-free provider validation: these scripts also run from installed plugins.
export type ObjectValue = Record<string, unknown>;
export function object(value: unknown): ObjectValue {
  if (!value || typeof value !== "object" || Array.isArray(value))
    throw new Error("Malformed provider response");
  return value as ObjectValue;
}
export function text(value: unknown): string {
  if (typeof value !== "string") throw new Error("Missing provider string");
  return value;
}
export function flag(value: unknown): boolean {
  if (typeof value !== "boolean") throw new Error("Missing provider boolean");
  return value;
}
export function list(value: unknown): unknown[] {
  if (!Array.isArray(value)) throw new Error("Missing provider list");
  return value;
}
export function count(value: unknown): number {
  if (typeof value !== "number" || !Number.isInteger(value) || value < 0)
    throw new Error("Missing provider count");
  return value;
}
