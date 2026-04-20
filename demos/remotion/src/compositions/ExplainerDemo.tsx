import { AbsoluteFill, Sequence, interpolate, spring, useCurrentFrame, useVideoConfig } from "remotion";
import { BigText } from "../components/BigText";
import { Terminal } from "../components/Terminal";
import { TypedLine } from "../components/TypedLine";
import { theme } from "../theme";

const BANNED = ["as", "any"].join(" ");
const BAD_CODE_LINE = `const user = data ${BANNED};`;

/**
 * ~60s explainer video. Tells the story:
 *
 *  Scene 1  0-150    (5s)  Hook -- "3-5 review cycles. Every PR."
 *  Scene 2  150-420  (9s)  Problem -- Claude writes banned patterns
 *  Scene 3  420-660  (8s)  Cost -- 15-30k tokens wasted per PR
 *  Scene 4  660-960  (10s) Reveal -- hooks block at write time
 *  Scene 5  960-1200 (8s)  Install -- three commands, that's it
 *  Scene 6  1200-1500 (10s) Four layers diagram
 *  Scene 7  1500-1710 (7s)  Proof -- real audit numbers
 *  Scene 8  1710-1800 (3s)  CTA
 */
export const ExplainerDemo: React.FC = () => {
  return (
    <AbsoluteFill style={{ background: theme.bg, fontFamily: theme.sans }}>
      <Sequence from={0} durationInFrames={150}>
        <HookScene />
      </Sequence>
      <Sequence from={150} durationInFrames={270}>
        <ProblemScene />
      </Sequence>
      <Sequence from={420} durationInFrames={240}>
        <CostScene />
      </Sequence>
      <Sequence from={660} durationInFrames={300}>
        <RevealScene />
      </Sequence>
      <Sequence from={960} durationInFrames={240}>
        <InstallScene />
      </Sequence>
      <Sequence from={1200} durationInFrames={300}>
        <LayersScene />
      </Sequence>
      <Sequence from={1500} durationInFrames={210}>
        <ProofScene />
      </Sequence>
      <Sequence from={1710} durationInFrames={90}>
        <CtaScene />
      </Sequence>
    </AbsoluteFill>
  );
};

// ── Scene 1: Hook question ───────────────────────────────────────
const HookScene: React.FC = () => {
  const frame = useCurrentFrame();
  const opacity = interpolate(frame, [0, 15, 135, 150], [0, 1, 1, 0], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });
  return (
    <AbsoluteFill style={{ opacity, alignItems: "center", justifyContent: "center", padding: 100 }}>
      <BigText size={140} color={theme.text}>
        3-5 review cycles.
      </BigText>
      <BigText size={140} color={theme.danger} delay={24}>
        Every PR.
      </BigText>
      <div style={{ marginTop: 40, fontSize: 36, color: theme.textMuted, opacity: frame > 80 ? 1 : 0 }}>
        Sound familiar?
      </div>
    </AbsoluteFill>
  );
};

// ── Scene 2: Problem -- Claude writes banned patterns ────────────
const ProblemScene: React.FC = () => {
  const frame = useCurrentFrame();
  const opacity = interpolate(frame, [0, 15, 255, 270], [0, 1, 1, 0], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });
  return (
    <AbsoluteFill
      style={{
        opacity,
        padding: 100,
        alignItems: "center",
        justifyContent: "center",
        flexDirection: "column",
        gap: 40,
      }}
    >
      <BigText size={72}>Without enforcement, Claude:</BigText>
      <div
        style={{
          display: "flex",
          flexDirection: "column",
          gap: 22,
          fontFamily: theme.mono,
          fontSize: 40,
          color: theme.danger,
        }}
      >
        <FadeLine delay={10}>• writes {BANNED}</FadeLine>
        <FadeLine delay={45}>• skips tests</FadeLine>
        <FadeLine delay={80}>• forgets `alt`, ARIA, keyboard handlers</FadeLine>
        <FadeLine delay={115}>• imports from legacy libs</FadeLine>
        <FadeLine delay={150}>• commits with no scope</FadeLine>
      </div>
      <div style={{ fontSize: 32, color: theme.textMuted, marginTop: 20 }}>
        Humans catch it in review. Loop restarts.
      </div>
    </AbsoluteFill>
  );
};

const FadeLine: React.FC<{ children: React.ReactNode; delay: number }> = ({ children, delay }) => {
  const frame = useCurrentFrame();
  const opacity = interpolate(frame - delay, [0, 15], [0, 1], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });
  return <div style={{ opacity }}>{children}</div>;
};

// ── Scene 3: Cost breakdown ──────────────────────────────────────
const CostScene: React.FC = () => {
  const frame = useCurrentFrame();
  const opacity = interpolate(frame, [0, 15, 225, 240], [0, 1, 1, 0], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });
  const barLeft = interpolate(frame, [30, 90], [0, 100], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });
  const barRight = interpolate(frame, [100, 160], [0, 4], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });
  return (
    <AbsoluteFill
      style={{
        opacity,
        padding: 100,
        alignItems: "center",
        justifyContent: "center",
        flexDirection: "column",
        gap: 50,
      }}
    >
      <BigText size={84}>Token cost per violation</BigText>
      <div style={{ display: "flex", gap: 80, marginTop: 20 }}>
        <CostBar label="Without hooks" tokens="~3,000" width={barLeft} color={theme.danger} note="5 review rounds" />
        <CostBar label="With hooks" tokens="~50" width={barRight} color={theme.success} note="1 edit. 1 fix." />
      </div>
      <div style={{ fontSize: 34, color: theme.textMuted, marginTop: 30 }}>
        Per PR: 15-30k tokens wasted → ~500-2k with hooks.
      </div>
    </AbsoluteFill>
  );
};

const CostBar: React.FC<{
  label: string;
  tokens: string;
  width: number;
  color: string;
  note: string;
}> = ({ label, tokens, width, color, note }) => (
  <div style={{ display: "flex", flexDirection: "column", gap: 12, alignItems: "flex-start", width: 600 }}>
    <div style={{ fontSize: 32, color: theme.textMuted }}>{label}</div>
    <div
      style={{
        width: `${width}%`,
        minWidth: 60,
        height: 80,
        background: color,
        borderRadius: 8,
        transition: "width 0.2s",
      }}
    />
    <div style={{ fontSize: 54, fontWeight: 800, color }}>{tokens} tokens</div>
    <div style={{ fontSize: 24, color: theme.textMuted }}>{note}</div>
  </div>
);

// ── Scene 4: Reveal -- hooks fire at write time ──────────────────
const RevealScene: React.FC = () => {
  const frame = useCurrentFrame();
  const opacity = interpolate(frame, [0, 15, 285, 300], [0, 1, 1, 0], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });
  const blockOp = interpolate(frame, [90, 110], [0, 1], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });
  return (
    <AbsoluteFill
      style={{
        opacity,
        padding: 100,
        alignItems: "center",
        justifyContent: "center",
        flexDirection: "column",
        gap: 40,
      }}
    >
      <BigText size={72}>Hooks block at write time. ~293ms.</BigText>
      <Terminal title="src/features/user.ts" style={{ width: 1400 }}>
        <TypedLine text="export function parseUser(data: unknown) {" startFrame={0} prefix="1" />
        <TypedLine text={`  ${BAD_CODE_LINE}`} startFrame={18} prefix="2" color={theme.danger} />
      </Terminal>
      <div
        style={{
          opacity: blockOp,
          background: "#2d1114",
          border: `1px solid ${theme.danger}`,
          borderRadius: 10,
          padding: "22px 30px",
          fontFamily: theme.mono,
          color: theme.danger,
          fontSize: 28,
          marginTop: -20,
        }}
      >
        ⛔ BLOCKED -- react-rules-check.sh -- {BANNED} banned. Use type guards or zod.
      </div>
      <div style={{ fontSize: 32, color: theme.textMuted }}>Deterministic. 100% reliable. Zero LLM tokens.</div>
    </AbsoluteFill>
  );
};

// ── Scene 5: Install ─────────────────────────────────────────────
const InstallScene: React.FC = () => {
  const frame = useCurrentFrame();
  const opacity = interpolate(frame, [0, 15, 225, 240], [0, 1, 1, 0], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });
  return (
    <AbsoluteFill
      style={{
        opacity,
        padding: 100,
        alignItems: "center",
        justifyContent: "center",
        flexDirection: "column",
        gap: 50,
      }}
    >
      <BigText size={84}>Install in three commands</BigText>
      <Terminal title="claude-code" style={{ width: 1400 }}>
        <TypedLine
          text="/plugin marketplace add malinskibeniamin/skills"
          startFrame={0}
          prefix=">"
          color={theme.accent}
        />
        <TypedLine
          text="/plugin install frontend-skills@skills"
          startFrame={60}
          prefix=">"
          color={theme.accent}
        />
        <TypedLine text="/reload-plugins" startFrame={120} prefix=">" color={theme.accent} />
        <div
          style={{
            marginTop: 20,
            opacity: interpolate(frame, [170, 200], [0, 1], {
              extrapolateLeft: "clamp",
              extrapolateRight: "clamp",
            }),
            color: theme.success,
          }}
        >
          ✓ Skills, hooks, agents active. Done.
        </div>
      </Terminal>
    </AbsoluteFill>
  );
};

// ── Scene 6: Four layers ─────────────────────────────────────────
const LayersScene: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  const opacity = interpolate(frame, [0, 15, 285, 300], [0, 1, 1, 0], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });

  const layers: Array<{ name: string; what: string; color: string }> = [
    { name: "Skills", what: "Workflow guidance, on demand", color: theme.accent },
    { name: "Hooks", what: "100% deterministic, every edit", color: theme.success },
    { name: "Agents", what: "Specialized review + verify", color: theme.purple },
    { name: "Sandcastle / Routines", what: "Batch + scheduled automation", color: theme.warning },
  ];

  return (
    <AbsoluteFill
      style={{
        opacity,
        padding: 100,
        alignItems: "center",
        justifyContent: "center",
        flexDirection: "column",
        gap: 40,
      }}
    >
      <BigText size={80}>Four layers, one outcome</BigText>
      <div style={{ display: "flex", flexDirection: "column", gap: 24, width: 1400 }}>
        {layers.map((layer, idx) => {
          const delay = 30 + idx * 30;
          const scale = spring({ frame: frame - delay, fps, config: { damping: 14, stiffness: 110 } });
          const lineOp = interpolate(frame - delay, [0, 15], [0, 1], {
            extrapolateLeft: "clamp",
            extrapolateRight: "clamp",
          });
          return (
            <div
              key={layer.name}
              style={{
                display: "flex",
                alignItems: "center",
                gap: 30,
                opacity: lineOp,
                transform: `translateX(${(1 - scale) * -30}px)`,
                background: theme.bgElev,
                border: `1px solid ${layer.color}`,
                borderRadius: 10,
                padding: "20px 30px",
              }}
            >
              <div
                style={{
                  width: 14,
                  height: 14,
                  borderRadius: 4,
                  background: layer.color,
                }}
              />
              <div style={{ fontSize: 40, fontWeight: 700, color: theme.text, minWidth: 460 }}>{layer.name}</div>
              <div style={{ fontSize: 30, color: theme.textMuted }}>{layer.what}</div>
            </div>
          );
        })}
      </div>
      <div style={{ fontSize: 30, color: theme.textMuted, marginTop: 20 }}>
        Compose via `/frontend-starter-kit`. Everything auto-wired.
      </div>
    </AbsoluteFill>
  );
};

// ── Scene 7: Proof ───────────────────────────────────────────────
const ProofScene: React.FC = () => {
  const frame = useCurrentFrame();
  const opacity = interpolate(frame, [0, 15, 195, 210], [0, 1, 1, 0], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });
  const stats = [
    { big: "3,500+", small: "PR review comments audited" },
    { big: "60", small: "PostToolUse hooks shipped" },
    { big: "34", small: "React rules enforced every edit" },
    { big: "~293ms", small: "Hook wall-clock per edit" },
  ];
  return (
    <AbsoluteFill
      style={{
        opacity,
        padding: 100,
        alignItems: "center",
        justifyContent: "center",
        flexDirection: "column",
        gap: 40,
      }}
    >
      <BigText size={80}>Built from real data</BigText>
      <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 30, width: 1300 }}>
        {stats.map((s, idx) => (
          <div
            key={s.big}
            style={{
              background: theme.bgElev,
              border: `1px solid ${theme.border}`,
              borderRadius: 12,
              padding: "30px 36px",
              opacity: interpolate(frame - (30 + idx * 22), [0, 15], [0, 1], {
                extrapolateLeft: "clamp",
                extrapolateRight: "clamp",
              }),
            }}
          >
            <div style={{ fontSize: 84, fontWeight: 800, color: theme.accent, letterSpacing: -2 }}>{s.big}</div>
            <div style={{ fontSize: 28, color: theme.textMuted, marginTop: 4 }}>{s.small}</div>
          </div>
        ))}
      </div>
    </AbsoluteFill>
  );
};

// ── Scene 8: CTA ─────────────────────────────────────────────────
const CtaScene: React.FC = () => {
  const frame = useCurrentFrame();
  const opacity = interpolate(frame, [0, 12, 75, 90], [0, 1, 1, 0], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });
  return (
    <AbsoluteFill
      style={{ opacity, alignItems: "center", justifyContent: "center", flexDirection: "column", gap: 30 }}
    >
      <BigText size={120} color={theme.accent}>
        Ship clean PRs.
      </BigText>
      <BigText size={120}>From the first edit.</BigText>
      <div
        style={{
          marginTop: 30,
          fontFamily: theme.mono,
          fontSize: 42,
          color: theme.text,
          background: theme.bgElev,
          border: `1px solid ${theme.border}`,
          padding: "20px 36px",
          borderRadius: 12,
        }}
      >
        github.com/malinskibeniamin/skills
      </div>
    </AbsoluteFill>
  );
};
