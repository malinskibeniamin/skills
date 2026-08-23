import { describe, expect, test, vi } from "vitest";
import {
  installNavigationEffects,
  type NavigationEvent,
  type NavigationEventRouter,
} from "./navigation-effects";

describe("navigation effects", () => {
  test("tracks resolution but waits for rendered content before DOM work", () => {
    const listeners = new Map<NavigationEvent, () => void>();
    const router: NavigationEventRouter = {
      subscribe: (event, listener) => {
        listeners.set(event, listener);
        return () => listeners.delete(event);
      },
    };
    const trackPageView = vi.fn();
    const focusPageHeading = vi.fn();

    installNavigationEffects(router, { focusPageHeading, trackPageView });
    listeners.get("onResolved")?.();

    expect(trackPageView).toHaveBeenCalledOnce();
    expect(focusPageHeading).not.toHaveBeenCalled();

    listeners.get("onRendered")?.();
    expect(focusPageHeading).toHaveBeenCalledOnce();
  });
});
