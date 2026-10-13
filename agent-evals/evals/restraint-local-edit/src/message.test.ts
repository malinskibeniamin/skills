import { expect, test } from "bun:test";
import { loginError } from "./message";

test("login errors spell password correctly", () => {
  expect(loginError()).toBe("Incorrect password");
});
