// Capture an inert pointer, active-control outline, and readable click ring in
// the real footage. Never change app layout, focus, or pointer hit testing.
(() => {
  if (window.__prVideoCursor) return;
  window.__prVideoCursor = true;
  const mount = () => {
    const overlay = (name, styles) => {
      const element = document.createElement("div");
      element.setAttribute("aria-hidden", "true");
      element.dataset.prVideoOverlay = name;
      Object.assign(element.style, {
        position: "fixed",
        left: "0",
        top: "0",
        pointerEvents: "none",
        boxSizing: "border-box",
        zIndex: "2147483647",
        ...styles,
      });
      document.documentElement.append(element);
      return element;
    };
    const reducedMotion = matchMedia(
      "(prefers-reduced-motion: reduce)",
    ).matches;
    const outline = overlay("target", {
      border: "3px solid #ef4444",
      borderRadius: "10px",
      boxShadow: "0 0 0 2px #fff",
      opacity: "0",
    });
    const ring = overlay("click", {
      width: "48px",
      height: "48px",
      border: "3px solid #ef4444",
      borderRadius: "50%",
      boxShadow: "0 0 0 2px #fff",
      opacity: "0",
    });
    const cursor = overlay("cursor", {
      width: "28px",
      height: "36px",
      transform: "translate(-60px, -60px)",
      transition: reducedMotion ? "none" : "transform 350ms ease-out",
      filter: "drop-shadow(0 1px 2px #000)",
    });
    const svg = document.createElementNS("http://www.w3.org/2000/svg", "svg");
    svg.setAttribute("viewBox", "0 0 28 36");
    svg.setAttribute("width", "28");
    svg.setAttribute("height", "36");
    const arrow = document.createElementNS(
      "http://www.w3.org/2000/svg",
      "path",
    );
    arrow.setAttribute("d", "M2 2V28L9 22L15 33L21 30L15 20L25 18Z");
    arrow.setAttribute("fill", "#ef4444");
    arrow.setAttribute("stroke", "#fff");
    arrow.setAttribute("stroke-width", "2");
    arrow.setAttribute("stroke-linejoin", "round");
    svg.append(arrow);
    cursor.append(svg);

    let target = null;
    let inputMode = "keyboard";
    let clickAnimation;
    const updateTarget = () => {
      const box = target?.isConnected ? target.getBoundingClientRect() : null;
      outline.style.opacity = box?.width && box?.height ? "1" : "0";
      if (!box) return;
      Object.assign(outline.style, {
        left: `${box.left - 6}px`,
        top: `${box.top - 6}px`,
        width: `${box.width + 12}px`,
        height: `${box.height + 12}px`,
      });
    };
    const markTarget = (element) => {
      if (!(element instanceof Element)) return;
      target =
        element.closest(
          "button, input, textarea, select, a, [role=button], [role=combobox], [contenteditable]",
        ) || element;
      updateTarget();
    };
    const moveTo = (x, y) => {
      cursor.style.transform = `translate(${x}px, ${y}px)`;
    };
    const focusTarget = () => {
      const box = target?.getBoundingClientRect();
      if (!box) return;
      moveTo(
        target.matches("input, textarea, [contenteditable]")
          ? box.right - Math.min(28, box.width / 2)
          : box.left + box.width / 2,
        box.top + box.height / 2,
      );
    };
    const pulse = (x, y) => {
      clickAnimation?.cancel();
      ring.style.left = `${x}px`;
      ring.style.top = `${y}px`;
      clickAnimation = ring.animate(
        [
          {
            opacity: 1,
            transform: `translate(-50%, -50%) scale(${reducedMotion ? 1 : 0.55})`,
          },
          {
            offset: 0.55,
            opacity: 1,
            transform: `translate(-50%, -50%) scale(${reducedMotion ? 1 : 1.1})`,
          },
          {
            opacity: 0,
            transform: `translate(-50%, -50%) scale(${reducedMotion ? 1 : 1.6})`,
          },
        ],
        { duration: 900, easing: "ease-out" },
      );
    };
    addEventListener(
      "mousemove",
      (event) => moveTo(event.clientX, event.clientY),
      true,
    );
    addEventListener(
      "focusin",
      (event) => {
        markTarget(event.target);
        if (inputMode === "keyboard") focusTarget();
      },
      true,
    );
    addEventListener(
      "pointerdown",
      (event) => {
        inputMode = "pointer";
        moveTo(event.clientX, event.clientY);
        markTarget(event.target);
        pulse(event.clientX, event.clientY);
      },
      true,
    );
    addEventListener(
      "keydown",
      (event) => {
        inputMode = "keyboard";
        markTarget(event.target);
        focusTarget();
        if (
          (event.key === "Enter" || event.key === " ") &&
          target?.matches(
            "button, a, input[type=checkbox], input[type=radio], [role=button], [role=checkbox], [role=switch], [role=menuitem]",
          )
        ) {
          const box = target?.getBoundingClientRect();
          if (box) pulse(box.left + box.width / 2, box.top + box.height / 2);
        }
      },
      true,
    );
    addEventListener(
      "input",
      (event) => {
        markTarget(event.target);
        focusTarget();
      },
      true,
    );
    addEventListener("scroll", updateTarget, { capture: true, passive: true });
    addEventListener("resize", updateTarget, { passive: true });
    new MutationObserver(updateTarget).observe(document.documentElement, {
      childList: true,
      subtree: true,
    });
  };
  if (document.documentElement) mount();
  else addEventListener("DOMContentLoaded", mount, { once: true });
})();
