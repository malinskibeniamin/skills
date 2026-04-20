import { AbsoluteFill, Sequence, interpolate, spring, useCurrentFrame, useVideoConfig } from "remotion";
import { BigText } from "../components/BigText";
import { theme } from "../theme";

/**
 * ~25s wow-factor reel for README inline GIF embed.
 * Three hero beats, each a single big number or quote, flashed fast.
 * Rendered as GIF -- autoplays on GitHub README, zero click required.
 *
 *  B1  0-210   (7s)  "3 weeks saved" -- /grill-me on autoform proto
 *  B2  210-420 (7s)  "4 waves, 13 phases, 1 skill" -- /development-lifecycle
 *  B3  420-600 (6s)  "force-push to main? blocked." -- hook save
 *  B4  600-750 (5s)  Closer -- 100% deterministic + CTA
 */
export const WowFactorDemo: React.FC = () => {
  return (
    <AbsoluteFill style={{ background: theme.bg, fontFamily: theme.sans }}>
      <Sequence from={0} durationInFrames={210}>
        <GrillWin />
      </Sequence>
      <Sequence from={210} durationInFrames={210}>
        <LifecycleWin />
      </Sequence>
      <Sequence from={420} durationInFrames={180}>
        <HookSave />
      </Sequence>
      <Sequence from={600} durationInFrames={150}>
        <Closer />
      </Sequence>
    </AbsoluteFill>
  );
};

// ── B1: /grill-me saved 3 weeks ──────────────────────────────────
const GrillWin: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  const opacity = interpolate(frame, [0, 10, 195, 210], [0, 1, 1, 0], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });
  const bigScale = spring({
    frame: frame - 30,
    fps,
    config: { damping: 10, stiffness: 90 },
  });
  return (
    <AbsoluteFill
      style={{
        opacity,
        alignItems: "center",
        justifyContent: "center",
        flexDirection: "column",
        gap: 24,
        padding: 80,
      }}
    >
      <div
        style={{
          fontFamily: theme.mono,
          fontSize: 48,
          color: theme.purple,
          fontWeight: 700,
        }}
      >
        /grill-me
      </div>
      <div
        style={{
          fontSize: 220,
          fontWeight: 800,
          color: theme.text,
          letterSpacing: -6,
          lineHeight: 1,
          transform: `scale(${0.85 + bigScale * 0.15})`,
        }}
      >
        3 weeks
      </div>
      <div style={{ fontSize: 54, fontWeight: 700, color: theme.accent, marginTop: -10 }}>
        of wasted work -- prevented
      </div>
      <div
        style={{
          fontSize: 32,
          color: theme.textMuted,
          marginTop: 16,
          opacity: interpolate(frame, [80, 120], [0, 1], {
            extrapolateLeft: "clamp",
            extrapolateRight: "clamp",
          }),
        }}
      >
        100+ questions on autoform proto coupling. Plan revised before code written.
      </div>
    </AbsoluteFill>
  );
};

// ── B2: /development-lifecycle shipped 13 phases ─────────────────
const LifecycleWin: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  const opacity = interpolate(frame, [0, 10, 195, 210], [0, 1, 1, 0], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });
  const bigScale = spring({
    frame: frame - 30,
    fps,
    config: { damping: 10, stiffness: 90 },
  });
  return (
    <AbsoluteFill
      style={{
        opacity,
        alignItems: "center",
        justifyContent: "center",
        flexDirection: "column",
        gap: 18,
        padding: 80,
      }}
    >
      <div
        style={{
          fontFamily: theme.mono,
          fontSize: 44,
          color: theme.accent,
          fontWeight: 700,
        }}
      >
        /development-lifecycle
      </div>
      <div
        style={{
          fontSize: 180,
          fontWeight: 800,
          color: theme.text,
          letterSpacing: -5,
          lineHeight: 1,
          transform: `scale(${0.85 + bigScale * 0.15})`,
        }}
      >
        4 waves · 13 phases
      </div>
      <div style={{ fontSize: 50, fontWeight: 700, color: theme.success, marginTop: 8 }}>
        shipped end-to-end
      </div>
      <div
        style={{
          fontSize: 30,
          color: theme.textMuted,
          marginTop: 14,
          opacity: interpolate(frame, [80, 120], [0, 1], {
            extrapolateLeft: "clamp",
            extrapolateRight: "clamp",
          }),
        }}
      >
        adp-ui-llm-provider-cards: Understand → Plan → Grill → TDD → Verify → Review.
      </div>
    </AbsoluteFill>
  );
};

// ── B3: Force-push to main blocked ───────────────────────────────
const HookSave: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  const opacity = interpolate(frame, [0, 10, 165, 180], [0, 1, 1, 0], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });
  const blockScale = spring({
    frame: frame - 40,
    fps,
    config: { damping: 10, stiffness: 100 },
  });
  return (
    <AbsoluteFill
      style={{
        opacity,
        alignItems: "center",
        justifyContent: "center",
        flexDirection: "column",
        gap: 24,
        padding: 80,
      }}
    >
      <div
        style={{
          fontFamily: theme.mono,
          fontSize: 52,
          color: theme.danger,
          background: "#2d1114",
          border: `2px solid ${theme.danger}`,
          borderRadius: 12,
          padding: "22px 40px",
        }}
      >
        $ git push --force origin main
      </div>
      <div
        style={{
          fontSize: 180,
          fontWeight: 800,
          color: theme.danger,
          letterSpacing: -4,
          transform: `scale(${0.85 + blockScale * 0.15})`,
        }}
      >
        ⛔ BLOCKED
      </div>
      <div style={{ fontSize: 44, fontWeight: 700, color: theme.text, marginTop: 8 }}>
        Redirected to PR flow. Zero friction.
      </div>
      <div
        style={{
          fontSize: 30,
          color: theme.textMuted,
          marginTop: 10,
          opacity: interpolate(frame, [80, 110], [0, 1], {
            extrapolateLeft: "clamp",
            extrapolateRight: "clamp",
          }),
        }}
      >
        enforce-toolchain.sh caught it before git saw it.
      </div>
    </AbsoluteFill>
  );
};

// ── B4: Closer ───────────────────────────────────────────────────
const Closer: React.FC = () => {
  const frame = useCurrentFrame();
  const opacity = interpolate(frame, [0, 10, 135, 150], [0, 1, 1, 0], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });
  return (
    <AbsoluteFill
      style={{
        opacity,
        alignItems: "center",
        justifyContent: "center",
        flexDirection: "column",
        gap: 20,
      }}
    >
      <BigText size={100} color={theme.accent}>
        100% deterministic.
      </BigText>
      <BigText size={100} delay={15}>
        Zero LLM tokens.
      </BigText>
      <div
        style={{
          marginTop: 24,
          fontFamily: theme.mono,
          fontSize: 36,
          color: theme.text,
          background: theme.bgElev,
          border: `2px solid ${theme.accent}`,
          borderRadius: 12,
          padding: "18px 34px",
          opacity: interpolate(frame, [50, 80], [0, 1], {
            extrapolateLeft: "clamp",
            extrapolateRight: "clamp",
          }),
        }}
      >
        github.com/malinskibeniamin/skills
      </div>
    </AbsoluteFill>
  );
};
