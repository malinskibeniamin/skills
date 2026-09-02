export type InstallOptions = {
  readonly cwd?: string;
  readonly destination?: string;
  readonly force?: boolean;
};

export declare function installAntiSlop(options?: InstallOptions): string;
