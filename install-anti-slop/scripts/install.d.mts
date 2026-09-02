export type InstallOptions = {
  readonly cwd?: string;
  readonly destination?: string;
  readonly force?: boolean;
  readonly linter?: "biome" | "oxlint";
};

export declare function installAntiSlop(options?: InstallOptions): string;
