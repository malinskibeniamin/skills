import type { Diagnostic } from "blume";

export interface FilesystemSourceEntry {
  body: { format: "md" | "mdx"; text: string };
  data: Record<string, unknown>;
  editUrl?: string;
  hash?: string;
  lastModified?: string;
  raw?: string;
  ref: string;
  slug?: string;
  sourcePath?: string;
}

export interface FilesystemSourceLoadResult {
  diagnostics: Diagnostic[];
  entries: FilesystemSourceEntry[];
}

export interface FilesystemSource {
  readonly contentRoot: string;
  readonly name: string;
  readonly prefix?: string;
  readonly staged: false;
  load: () => Promise<FilesystemSourceLoadResult>;
  read: (ref: string) => Promise<string>;
  validate: () => void;
  watch: (onChange: () => void) => () => void;
}

export interface FilesystemSourceOptions {
  exclude: string[];
  include: string[];
  missingCode?: string;
  name: string;
  prefix?: string;
  projectRoot: string;
  root: string;
}

/** Blume 1.4.2 omits declarations for its wildcard filesystem-source export. */
export declare const filesystemSource: (
  options: FilesystemSourceOptions,
) => FilesystemSource;
