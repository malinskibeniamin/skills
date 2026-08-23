export interface AccountLoaderArguments {
  abortController: AbortController;
}

export type FetchAccount = (options: {
  signal?: AbortSignal;
}) => Promise<unknown>;

export const loadAccount = (
  _arguments: AccountLoaderArguments,
  fetchAccount: FetchAccount,
) => fetchAccount({});
