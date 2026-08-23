export type NavigationEvent = "onRendered" | "onResolved";

export interface NavigationEventRouter {
  subscribe: (event: NavigationEvent, listener: () => void) => () => void;
}

export interface NavigationEffects {
  focusPageHeading: () => void;
  trackPageView: () => void;
}

export const installNavigationEffects = (
  router: NavigationEventRouter,
  effects: NavigationEffects,
) => {
  const unsubscribePageView = router.subscribe(
    "onResolved",
    effects.trackPageView,
  );
  const unsubscribeFocus = router.subscribe(
    "onResolved",
    effects.focusPageHeading,
  );

  return () => {
    unsubscribePageView();
    unsubscribeFocus();
  };
};
