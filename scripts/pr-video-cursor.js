// Headless recordings have no pointer. Draw one that glides to each pointer or
// focus target (right edge, clear of typed text) and pulses on click.
(() => {
  if (window.__prVideoCursor) return;
  window.__prVideoCursor = true;
  const mount = () => {
    const dot = document.createElement("div");
    dot.setAttribute("aria-hidden", "true");
    Object.assign(dot.style, {
      position: "fixed",
      left: "0",
      top: "0",
      width: "18px",
      height: "18px",
      margin: "-9px 0 0 -9px",
      borderRadius: "50%",
      background: "rgba(239, 68, 68, 0.85)",
      border: "2px solid #fff",
      boxShadow: "0 0 0 1px rgba(0, 0, 0, 0.4)",
      pointerEvents: "none",
      zIndex: "2147483647",
      transform: "translate(-40px, -40px)",
      transition: "transform 350ms ease-out, scale 120ms ease-out",
    });
    document.documentElement.append(dot);
    const moveTo = (x, y) => {
      dot.style.transform = `translate(${x}px, ${y}px)`;
    };
    addEventListener(
      "mousemove",
      (event) => moveTo(event.clientX, event.clientY),
      true,
    );
    addEventListener(
      "focusin",
      (event) => {
        const box = event.target.getBoundingClientRect?.();
        if (box)
          moveTo(
            box.left + Math.max(box.width - 16, box.width / 2),
            box.top + box.height / 2,
          );
      },
      true,
    );
    addEventListener(
      "mousedown",
      () => {
        dot.style.scale = "1.8";
      },
      true,
    );
    addEventListener(
      "mouseup",
      () => {
        dot.style.scale = "1";
      },
      true,
    );
  };
  if (document.documentElement) mount();
  else addEventListener("DOMContentLoaded", mount, { once: true });
})();
