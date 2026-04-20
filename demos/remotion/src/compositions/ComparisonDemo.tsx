import { AbsoluteFill, Sequence, interpolate, spring, useCurrentFrame, useVideoConfig } from "remotion";
import { BigText } from "../components/BigText";
import { theme } from "../theme";

/**
 * ~50s comparison video: skills harness vs prompt-packs (gstack-style)
 * vs obra/superpowers. Shows where each approach intervenes and why
 * deterministic enforcement wins.
 *
 *  S1  0-180     (6s)  Title -- "Why not just use..."
 *  S2  180-450   (9s)  Approach 1: Prompt-packs (gstack)
 *  S3  450-720   (9s)  Approach 2: obra/superpowers
 *  S4  720-990   (9s)  Approach 3: this harness
 *  S5  990-1320  (11s) Side-by-side scorecard
 *  S6  1320-1500 (6s)  Close -- "Teach AND enforce"
 */
export const ComparisonDemo: React.FC = () => {
  return (
    <AbsoluteFill style={{ background: theme.bg, fontFamily: theme.sans }}>
      <Sequence from={0} durationInFrames={180}>
        <TitleScene />
      </Sequence>
      <Sequence from={180} durationInFrames={270}>
        <GstackScene />
      </Sequence>
      <Sequence from={450} durationInFrames={270}>
        <SuperpowersScene />
      </Sequence>
      <Sequence from={720} durationInFrames={270}>
        <HarnessScene />
      </Sequence>
      <Sequence from={990} durationInFrames={330}>
        <ScorecardScene />
      </Sequence>
      <Sequence from={1320} durationInFrames={180}>
        <CloseScene />
      </Sequence>
    </AbsoluteFill>
  );
};

// ── S1: Title ────────────────────────────────────────────────────
const TitleScene: React.FC = () => {
  const frame = useCurrentFrame();
  const opacity = interpolate(frame, [0, 15, 165, 180], [0, 1, 1, 0], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });
  return (
    <AbsoluteFill style={{ opacity, alignItems: "center", justifyContent: "center", padding: 100 }}>
      <BigText size={120}>Why not just use...</BigText>
      <BigText size={84} color={theme.textMuted} delay={30}>
        a prompt-pack? superpowers?
      </BigText>
      <div
        style={{
          marginTop: 30,
          fontSize: 32,
          color: theme.textMuted,
          opacity: interpolate(frame, [90, 120], [0, 1], {
            extrapolateLeft: "clamp",
            extrapolateRight: "clamp",
          }),
        }}
      >
        Fair question. Let's compare where each intervenes.
      </div>
    </AbsoluteFill>
  );
};

// ── S2: Prompt-pack (gstack) ─────────────────────────────────────
const GstackScene: React.FC = () => {
  const frame = useCurrentFrame();
  const opacity = interpolate(frame, [0, 15, 255, 270], [0, 1, 1, 0], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });
  return (
    <ApproachPanel
      opacity={opacity}
      frame={frame}
      title="Prompt-pack (gstack-style)"
      subtitle="Big system prompt bundled with rules"
      layer="Prompt layer only"
      layerColor={theme.warning}
      pros={["Easy to share", "Works in any harness", "No install"]}
      cons={[
        "3-15k tokens per prompt",
        "Probabilistic (LLM may skip)",
        "No enforcement at edit time",
        "Can't fail CI or block Stop",
      ]}
      verdict="~70% reliability. Good for style nudges, weak for safety."
    />
  );
};

// ── S3: obra/superpowers ─────────────────────────────────────────
const SuperpowersScene: React.FC = () => {
  const frame = useCurrentFrame();
  const opacity = interpolate(frame, [0, 15, 255, 270], [0, 1, 1, 0], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });
  return (
    <ApproachPanel
      opacity={opacity}
      frame={frame}
      title="obra/superpowers"
      subtitle="Workflow skills (TDD, debug, plan, write-a-skill…)"
      layer="Prompt layer only (skills injected on demand)"
      layerColor={theme.accent}
      pros={[
        "Great workflow patterns",
        "Stack-agnostic",
        "Rich skill library",
        "Low token overhead per skill",
      ]}
      cons={[
        "Still probabilistic (~70%)",
        "No edit-time blocking",
        "No Stop gate",
        "Claude forgets mid-session",
      ]}
      verdict="Excellent teacher. No safety net when Claude forgets."
    />
  );
};

// ── S4: This harness ─────────────────────────────────────────────
const HarnessScene: React.FC = () => {
  const frame = useCurrentFrame();
  const opacity = interpolate(frame, [0, 15, 255, 270], [0, 1, 1, 0], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });
  return (
    <ApproachPanel
      opacity={opacity}
      frame={frame}
      title="this harness"
      subtitle="Skills + deterministic hooks at every boundary"
      layer="Prompt → Edit → Stop → CI → PR (all layers)"
      layerColor={theme.success}
      pros={[
        "100% reliable on hook checks",
        "0 LLM tokens for hook enforcement",
        "Blocks at edit time (~293ms)",
        "Stop gate: no ship without tests",
        "Codex + Claude Code compatible",
      ]}
      cons={[
        "Opinionated (React + Bun + TanStack)",
        "Medium setup (14 setup skills)",
        "Backend/non-React repos: limited fit",
      ]}
      verdict="Teach AND enforce. Probabilistic skills + deterministic bash."
    />
  );
};

const ApproachPanel: React.FC<{
  opacity: number;
  frame: number;
  title: string;
  subtitle: string;
  layer: string;
  layerColor: string;
  pros: string[];
  cons: string[];
  verdict: string;
}> = ({ opacity, frame, title, subtitle, layer, layerColor, pros, cons, verdict }) => {
  return (
    <AbsoluteFill
      style={{
        opacity,
        padding: 80,
        alignItems: "center",
        justifyContent: "center",
        flexDirection: "column",
        gap: 30,
      }}
    >
      <div style={{ textAlign: "center" }}>
        <BigText size={72}>{title}</BigText>
        <div style={{ fontSize: 32, color: theme.textMuted, marginTop: 12 }}>{subtitle}</div>
      </div>

      <div
        style={{
          padding: "16px 32px",
          background: theme.bgElev,
          border: `2px solid ${layerColor}`,
          borderRadius: 10,
          fontSize: 28,
          color: layerColor,
          fontFamily: theme.mono,
          opacity: interpolate(frame - 30, [0, 20], [0, 1], {
            extrapolateLeft: "clamp",
            extrapolateRight: "clamp",
          }),
        }}
      >
        intervenes at: {layer}
      </div>

      <div style={{ display: "flex", gap: 40, width: 1500, marginTop: 10 }}>
        <ProsCons
          items={pros}
          color={theme.success}
          label="pros"
          startFrame={60}
          frame={frame}
        />
        <ProsCons
          items={cons}
          color={theme.danger}
          label="cons"
          startFrame={60}
          frame={frame}
        />
      </div>

      <div
        style={{
          marginTop: 10,
          fontSize: 30,
          fontWeight: 700,
          color: theme.text,
          background: theme.bgElev,
          border: `1px solid ${theme.border}`,
          borderRadius: 10,
          padding: "18px 30px",
          maxWidth: 1400,
          textAlign: "center",
          opacity: interpolate(frame - 180, [0, 25], [0, 1], {
            extrapolateLeft: "clamp",
            extrapolateRight: "clamp",
          }),
        }}
      >
        {verdict}
      </div>
    </AbsoluteFill>
  );
};

const ProsCons: React.FC<{
  items: string[];
  color: string;
  label: string;
  startFrame: number;
  frame: number;
}> = ({ items, color, label, startFrame, frame }) => (
  <div style={{ flex: 1 }}>
    <div style={{ fontSize: 26, fontWeight: 700, color, marginBottom: 10, letterSpacing: 1 }}>
      {label.toUpperCase()}
    </div>
    <div style={{ display: "flex", flexDirection: "column", gap: 8 }}>
      {items.map((item, idx) => {
        const delay = startFrame + idx * 15;
        const op = interpolate(frame - delay, [0, 15], [0, 1], {
          extrapolateLeft: "clamp",
          extrapolateRight: "clamp",
        });
        return (
          <div
            key={item}
            style={{
              opacity: op,
              fontSize: 24,
              color: theme.text,
              background: theme.bgElev,
              borderLeft: `3px solid ${color}`,
              padding: "10px 16px",
              borderRadius: 4,
            }}
          >
            {label === "pros" ? "+ " : "− "}
            {item}
          </div>
        );
      })}
    </div>
  </div>
);

// ── S5: Scorecard ────────────────────────────────────────────────
const ScorecardScene: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  const opacity = interpolate(frame, [0, 15, 315, 330], [0, 1, 1, 0], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });

  const rows: Array<{ metric: string; gstack: string; superpowers: string; harness: string; highlight?: boolean }> = [
    { metric: "Reliability", gstack: "~70%", superpowers: "~70%", harness: "100% hooks / 90% skills", highlight: true },
    { metric: "Token overhead", gstack: "3-15k / prompt", superpowers: "~500 / skill", harness: "0 for hooks", highlight: true },
    { metric: "Catches at edit time", gstack: "✗", superpowers: "✗", harness: "✓ ~293ms", highlight: true },
    { metric: "Stop gate", gstack: "✗", superpowers: "✗", harness: "✓" },
    { metric: "Codex support", gstack: "N/A", superpowers: "✗", harness: "✓ first-class" },
    { metric: "Batch / cloud", gstack: "✗", superpowers: "✗", harness: "✓ Sandcastle + Routines" },
  ];

  return (
    <AbsoluteFill
      style={{
        opacity,
        padding: 60,
        alignItems: "center",
        justifyContent: "center",
        flexDirection: "column",
        gap: 30,
      }}
    >
      <BigText size={72}>Scorecard</BigText>
      <div
        style={{
          display: "grid",
          gridTemplateColumns: "1.6fr 1fr 1fr 1.4fr",
          gap: 0,
          width: 1700,
          border: `1px solid ${theme.border}`,
          borderRadius: 12,
          overflow: "hidden",
          fontSize: 26,
        }}
      >
        <Header label="" />
        <Header label="gstack" color={theme.warning} />
        <Header label="superpowers" color={theme.accent} />
        <Header label="this harness" color={theme.success} />

        {rows.map((row, idx) => {
          const delay = 40 + idx * 28;
          const op = interpolate(frame - delay, [0, 18], [0, 1], {
            extrapolateLeft: "clamp",
            extrapolateRight: "clamp",
          });
          const slide = interpolate(frame - delay, [0, 18], [40, 0], {
            extrapolateLeft: "clamp",
            extrapolateRight: "clamp",
          });
          return (
            <Row
              key={row.metric}
              metric={row.metric}
              gstack={row.gstack}
              superpowers={row.superpowers}
              harness={row.harness}
              highlight={!!row.highlight}
              opacity={op}
              translateY={slide}
            />
          );
        })}
      </div>
    </AbsoluteFill>
  );
};

const Header: React.FC<{ label: string; color?: string }> = ({ label, color }) => (
  <div
    style={{
      padding: "18px 20px",
      background: "#1f2a44",
      color: color ?? theme.textMuted,
      fontWeight: 800,
      borderBottom: `1px solid ${theme.border}`,
      textAlign: label ? "left" : undefined,
    }}
  >
    {label}
  </div>
);

const Row: React.FC<{
  metric: string;
  gstack: string;
  superpowers: string;
  harness: string;
  highlight: boolean;
  opacity: number;
  translateY: number;
}> = ({ metric, gstack, superpowers, harness, highlight, opacity, translateY }) => {
  const cellStyle: React.CSSProperties = {
    padding: "16px 20px",
    borderBottom: `1px solid ${theme.border}`,
    background: theme.bgElev,
    opacity,
    transform: `translateY(${translateY}px)`,
  };
  return (
    <>
      <div style={{ ...cellStyle, fontWeight: 700, color: theme.text }}>{metric}</div>
      <div style={{ ...cellStyle, color: theme.textMuted }}>{gstack}</div>
      <div style={{ ...cellStyle, color: theme.textMuted }}>{superpowers}</div>
      <div
        style={{
          ...cellStyle,
          color: highlight ? theme.success : theme.text,
          fontWeight: highlight ? 800 : 500,
        }}
      >
        {harness}
      </div>
    </>
  );
};

// ── S6: Close ────────────────────────────────────────────────────
const CloseScene: React.FC = () => {
  const frame = useCurrentFrame();
  const opacity = interpolate(frame, [0, 15, 165, 180], [0, 1, 1, 0], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });
  return (
    <AbsoluteFill
      style={{ opacity, alignItems: "center", justifyContent: "center", flexDirection: "column", gap: 30 }}
    >
      <BigText size={84} color={theme.textMuted}>
        Teach.
      </BigText>
      <BigText size={84} color={theme.textMuted} delay={20}>
        AND enforce.
      </BigText>
      <BigText size={100} color={theme.accent} delay={50}>
        Both. Not either.
      </BigText>
    </AbsoluteFill>
  );
};
