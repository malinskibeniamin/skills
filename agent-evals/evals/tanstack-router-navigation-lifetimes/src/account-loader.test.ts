import { expect, test, vi } from "vitest";
import { loadAccount } from "./account-loader";

test("forwards the Router-owned loader signal", async () => {
  const abortController = new AbortController();
  const fetchAccount = vi.fn().mockResolvedValue({ id: "account-1" });

  await loadAccount({ abortController }, fetchAccount);

  expect(fetchAccount).toHaveBeenCalledWith({ signal: abortController.signal });
});
