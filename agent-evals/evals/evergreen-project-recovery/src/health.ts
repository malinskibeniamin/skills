export interface ProjectItem {
  status: "active" | "blocked" | "completed";
  updatedAt: string;
}

export const projectHealth = (
  items: ProjectItem[],
  cutoff: string,
): "healthy" | "stale" => {
  const cutoffTime = Date.parse(cutoff);
  return items.some((item) => Date.parse(item.updatedAt) < cutoffTime)
    ? "stale"
    : "healthy";
};
