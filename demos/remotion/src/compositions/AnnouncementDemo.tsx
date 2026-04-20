import { AbsoluteFill, Sequence, interpolate, spring, useCurrentFrame, useVideoConfig } from "remotion";
import { BigText } from "../components/BigText";
import { Terminal } from "../components/Terminal";
import { TypedLine } from "../components/TypedLine";
import { theme } from "../theme";

/**
 * ~70s announcement video for Slack / Twitter / LinkedIn launch.
 * Mirrors the structure of the announcement thread. Ruthless cut
 * to the highest-signal beats.
 *
 *  S1  0-180     (6s)  Hook: "Don't remember any of them"
 *  S2  180-420   (8s)  Progressive disclosure: auto-load on file match
 *  S3  420-630   (7s)  Three commands. Done.
 *  S4  630-900   (9s)  Stats triad
 *  S5  900-1320  (14s) Category grid (59 checks, broken down)
 *  S6  1320-1620 (10s) Real catch: git reset --hard blocked
 *  S7  1620-1860 (8s)  Multi-harness (Claude Code + Codex + Desktop)
 *  S8  1860-2100 (8s)  CTA
 */
export const AnnouncementDemo: React.FC = () => {
  return (
    <AbsoluteFill style={{ background: theme.bg, fontFamily: theme.sans }}>
      <Sequence from={0} durationInFrames={180}>
        <HookScene />
      </Sequence>
      <Sequence from={180} durationInFrames={240}>
        <ProgressiveDisclosureScene />
      </Sequence>
      <Sequence from={420} durationInFrames={210}>
        <InstallScene />
      </Sequence>
      <Sequence from={630} durationInFrames={270}>
        <StatsScene />
      </Sequence>
      <Sequence from={900} durationInFrames={420}>
        <CategoryGridScene />
      </Sequence>
      <Sequence from={1320} durationInFrames={300}>
        <RealCatchScene />
      </Sequence>
      <Sequence from={1620} durationInFrames={240}>
        <HarnessScene />
      </Sequence>
      <Sequence from={1860} durationInFrames={240}>
        <CtaScene />
      </Sequence>
    </AbsoluteFill>
  );
};

// ── S1: Hook ─────────────────────────────────────────────────────
const HookScene: React.FC = () => {
  const frame = useCurrentFrame();
  const opacity = interpolate(frame, [0, 15, 165, 180], [0, 1, 1, 0], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });
  return (
    <AbsoluteFill style={{ opacity, alignItems: "center", justifyContent: "center", padding: 100 }}>
      <BigText size={120} color={theme.textMuted}>
        59 checks.
      </BigText>
      <BigText size={120} color={theme.textMuted} delay={20}>
        24 hooks.
      </BigText>
      <BigText size={120} color={theme.textMuted} delay={40}>
        Dozens of skills.
      </BigText>
      <BigText size={140} color={theme.accent} delay={80}>
        Don't remember any of them.
      </BigText>
    </AbsoluteFill>
  );
};

// ── S2: Progressive disclosure ───────────────────────────────────
const ProgressiveDisclosureScene: React.FC = () => {
  const frame = useCurrentFrame();
  const opacity = interpolate(frame, [0, 15, 225, 240], [0, 1, 1, 0], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });
  const files = [
    { name: "route.tsx", skill: "tanstack-router", delay: 30 },
    { name: "store.ts", skill: "zustand", delay: 90 },
    { name: "user.test.tsx", skill: "tdd", delay: 150 },
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
      <BigText size={72}>Skills auto-load on file match.</BigText>
      <div style={{ display: "flex", flexDirection: "column", gap: 22, width: 1300 }}>
        {files.map((file) => {
          const fileOp = interpolate(frame - file.delay, [0, 15], [0, 1], {
            extrapolateLeft: "clamp",
            extrapolateRight: "clamp",
          });
          const arrowOp = interpolate(frame - file.delay, [20, 40], [0, 1], {
            extrapolateLeft: "clamp",
            extrapolateRight: "clamp",
          });
          const skillOp = interpolate(frame - file.delay, [40, 55], [0, 1], {
            extrapolateLeft: "clamp",
            extrapolateRight: "clamp",
          });
          return (
            <div
              key={file.name}
              style={{
                display: "flex",
                alignItems: "center",
                gap: 24,
                opacity: fileOp,
                fontFamily: theme.mono,
                fontSize: 36,
              }}
            >
              <div
                style={{
                  background: theme.bgElev,
                  border: `1px solid ${theme.border}`,
                  borderRadius: 8,
                  padding: "14px 24px",
                  color: theme.text,
                  minWidth: 400,
                }}
              >
                {file.name}
              </div>
              <div style={{ opacity: arrowOp, color: theme.textMuted, fontSize: 42 }}>→</div>
              <div
                style={{
                  opacity: skillOp,
                  background: theme.bgElev,
                  border: `1px solid ${theme.success}`,
                  borderRadius: 8,
                  padding: "14px 24px",
                  color: theme.success,
                }}
              >
                /{file.skill} loaded
              </div>
            </div>
          );
        })}
      </div>
      <div style={{ fontSize: 32, color: theme.textMuted, marginTop: 20 }}>
        Evals guarantee the right one fires.
      </div>
    </AbsoluteFill>
  );
};

// ── S3: Install ──────────────────────────────────────────────────
const InstallScene: React.FC = () => {
  const frame = useCurrentFrame();
  const opacity = interpolate(frame, [0, 15, 195, 210], [0, 1, 1, 0], {
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
      <BigText size={84}>Setup: once per repo</BigText>
      <Terminal title="claude-code" style={{ width: 1500 }}>
        <TypedLine
          text="/plugin marketplace add malinskibeniamin/skills"
          startFrame={0}
          prefix=">"
          color={theme.accent}
        />
        <TypedLine
          text="/plugin install frontend-skills@skills"
          startFrame={45}
          prefix=">"
          color={theme.accent}
        />
        <TypedLine text="/reload-plugins" startFrame={90} prefix=">" color={theme.accent} />
        <div
          style={{
            marginTop: 18,
            opacity: interpolate(frame, [140, 165], [0, 1], {
              extrapolateLeft: "clamp",
              extrapolateRight: "clamp",
            }),
            color: theme.success,
          }}
        >
          ✓ 24 hooks + all skills active. Ready.
        </div>
      </Terminal>
    </AbsoluteFill>
  );
};

// ── S4: Stats triad ──────────────────────────────────────────────
const StatsScene: React.FC = () => {
  const frame = useCurrentFrame();
  const opacity = interpolate(frame, [0, 15, 255, 270], [0, 1, 1, 0], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });
  const stats = [
    { value: "0", unit: "LLM tokens", color: theme.success, delay: 20 },
    { value: "~80ms", unit: "latency (TS/React)", color: theme.accent, delay: 70 },
    { value: "100%", unit: "deterministic", color: theme.purple, delay: 120 },
  ];
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
      <BigText size={80}>Hooks are bash. Not AI.</BigText>
      <div style={{ display: "flex", gap: 60, marginTop: 10 }}>
        {stats.map((s) => (
          <StatCard key={s.unit} {...s} frame={frame} />
        ))}
      </div>
      <div style={{ fontSize: 34, color: theme.textMuted, marginTop: 20 }}>
        Battle-tested on real codebase (ADP UI).
      </div>
    </AbsoluteFill>
  );
};

const StatCard: React.FC<{
  value: string;
  unit: string;
  color: string;
  delay: number;
  frame: number;
}> = ({ value, unit, color, delay, frame }) => {
  const op = interpolate(frame - delay, [0, 20], [0, 1], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });
  return (
    <div
      style={{
        background: theme.bgElev,
        border: `2px solid ${color}`,
        borderRadius: 14,
        padding: "32px 48px",
        minWidth: 360,
        textAlign: "center",
        opacity: op,
      }}
    >
      <div style={{ fontSize: 96, fontWeight: 800, color, letterSpacing: -2, lineHeight: 1 }}>{value}</div>
      <div style={{ fontSize: 28, color: theme.textMuted, marginTop: 10 }}>{unit}</div>
    </div>
  );
};

// ── S5: Category grid ────────────────────────────────────────────
const CategoryGridScene: React.FC = () => {
  const frame = useCurrentFrame();
  const opacity = interpolate(frame, [0, 15, 405, 420], [0, 1, 1, 0], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });
  const cats: Array<{ name: string; count: number; note: string; color: string }> = [
    { name: "React & TypeScript", count: 25, note: "unsafe casts, unsafe HTML injection, class components…", color: theme.accent },
    { name: "UI Registry", count: 17, note: "raw buttons, Chakra ban, CodeBlock, AlertDialog nudges", color: theme.success },
    { name: "ConnectRPC & Protobuf", count: 11, note: "create(Schema), PlainMessage, Timestamp wkt", color: theme.purple },
    { name: "TanStack Router", count: 9, note: "hard navigation, untyped hooks, URLSearchParams", color: theme.warning },
    { name: "Accessibility", count: 5, note: "image alt text, combobox ARIA, icon-only aria-label", color: "#f472b6" },
    { name: "Zustand", count: 3, note: "create double-parens, useShallow, persist", color: "#06b6d4" },
    { name: "Tailwind", count: 2, note: "raw hex colors, forced specificity overrides", color: "#fbbf24" },
    { name: "Env", count: 2, note: "raw env access, secret leaks", color: theme.danger },
  ];
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
      <BigText size={72}>What gets caught -- every edit</BigText>
      <div
        style={{
          display: "grid",
          gridTemplateColumns: "1fr 1fr",
          gap: 20,
          width: 1600,
        }}
      >
        {cats.map((c, idx) => {
          const delay = 30 + idx * 25;
          const op = interpolate(frame - delay, [0, 18], [0, 1], {
            extrapolateLeft: "clamp",
            extrapolateRight: "clamp",
          });
          const slide = interpolate(frame - delay, [0, 18], [30, 0], {
            extrapolateLeft: "clamp",
            extrapolateRight: "clamp",
          });
          return (
            <div
              key={c.name}
              style={{
                opacity: op,
                transform: `translateY(${slide}px)`,
                background: theme.bgElev,
                border: `1px solid ${c.color}`,
                borderLeft: `6px solid ${c.color}`,
                borderRadius: 10,
                padding: "18px 24px",
                display: "flex",
                alignItems: "center",
                gap: 24,
              }}
            >
              <div style={{ fontSize: 64, fontWeight: 800, color: c.color, minWidth: 100 }}>{c.count}</div>
              <div style={{ flex: 1 }}>
                <div style={{ fontSize: 30, fontWeight: 700, color: theme.text }}>{c.name}</div>
                <div style={{ fontSize: 22, color: theme.textMuted, marginTop: 4 }}>{c.note}</div>
              </div>
            </div>
          );
        })}
      </div>
      <div
        style={{
          fontSize: 36,
          fontWeight: 800,
          color: theme.accent,
          opacity: interpolate(frame, [280, 320], [0, 1], {
            extrapolateLeft: "clamp",
            extrapolateRight: "clamp",
          }),
        }}
      >
        74+ checks. Zero config. Zero LLM tokens.
      </div>
    </AbsoluteFill>
  );
};

// ── S6: Real catch -- git reset --hard ───────────────────────────
const RealCatchScene: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  const opacity = interpolate(frame, [0, 15, 285, 300], [0, 1, 1, 0], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });
  const blockScale = spring({
    frame: frame - 110,
    fps,
    config: { damping: 12, stiffness: 110 },
  });
  const blockOp = interpolate(frame, [100, 130], [0, 1], {
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
        gap: 30,
      }}
    >
      <BigText size={64}>Real catch -- April 1, 2026</BigText>
      <Terminal title="claude-code" style={{ width: 1500 }}>
        <TypedLine text="I need to clean up the branch before merging." startFrame={0} prefix="#" />
        <TypedLine
          text="$ git reset --hard HEAD~5"
          startFrame={35}
          prefix=">"
          color={theme.danger}
        />
      </Terminal>
      <div
        style={{
          opacity: blockOp,
          transform: `scale(${0.92 + blockScale * 0.08})`,
          background: "#2d1114",
          border: `2px solid ${theme.danger}`,
          borderRadius: 12,
          padding: "24px 36px",
          fontFamily: theme.mono,
          color: theme.text,
          fontSize: 28,
          width: 1500,
        }}
      >
        <div style={{ color: theme.danger, fontWeight: 700, marginBottom: 8 }}>
          ⛔ BLOCKED -- enforce-toolchain.sh
        </div>
        <div style={{ color: theme.textMuted, fontSize: 24 }}>
          Destructive command. `git reset --hard` will discard commits. Confirm intent explicitly
          or use a safer alternative (git revert, git stash).
        </div>
      </div>
      <div
        style={{
          fontSize: 32,
          color: theme.textMuted,
          opacity: interpolate(frame, [200, 240], [0, 1], {
            extrapolateLeft: "clamp",
            extrapolateRight: "clamp",
          }),
        }}
      >
        Claude tried to nuke 5 commits on April Fool's. Hook caught it.
      </div>
    </AbsoluteFill>
  );
};

// ── S7: Multi-harness ────────────────────────────────────────────
const HarnessScene: React.FC = () => {
  const frame = useCurrentFrame();
  const opacity = interpolate(frame, [0, 15, 225, 240], [0, 1, 1, 0], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });
  const harnesses = [
    { name: "Claude Code", sub: "CLI + IDE", delay: 20 },
    { name: "Codex", sub: "Electron + CLI", delay: 60 },
    { name: "Claude Desktop", sub: "Mac / Windows", delay: 100 },
  ];
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
      <BigText size={80}>Works across harnesses</BigText>
      <div style={{ display: "flex", gap: 40 }}>
        {harnesses.map((h) => {
          const op = interpolate(frame - h.delay, [0, 20], [0, 1], {
            extrapolateLeft: "clamp",
            extrapolateRight: "clamp",
          });
          return (
            <div
              key={h.name}
              style={{
                opacity: op,
                background: theme.bgElev,
                border: `1px solid ${theme.border}`,
                borderRadius: 14,
                padding: "36px 48px",
                minWidth: 380,
                textAlign: "center",
              }}
            >
              <div style={{ fontSize: 44, fontWeight: 800, color: theme.text }}>{h.name}</div>
              <div style={{ fontSize: 26, color: theme.textMuted, marginTop: 10 }}>{h.sub}</div>
              <div style={{ fontSize: 28, color: theme.success, marginTop: 24 }}>✓ hooks</div>
              <div style={{ fontSize: 28, color: theme.success, marginTop: 4 }}>✓ skills</div>
            </div>
          );
        })}
      </div>
      <div style={{ fontSize: 30, color: theme.textMuted, marginTop: 20 }}>
        `codex-compat` ports every hook. `AGENTS.md` replaces PostCompact.
      </div>
    </AbsoluteFill>
  );
};

// ── S8: CTA ──────────────────────────────────────────────────────
const CtaScene: React.FC = () => {
  const frame = useCurrentFrame();
  const opacity = interpolate(frame, [0, 15, 225, 240], [0, 1, 1, 0], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });
  return (
    <AbsoluteFill
      style={{ opacity, alignItems: "center", justifyContent: "center", flexDirection: "column", gap: 28 }}
    >
      <BigText size={120} color={theme.accent}>
        Ship clean PRs.
      </BigText>
      <BigText size={120} delay={20}>
        Every edit. Zero tokens.
      </BigText>
      <div
        style={{
          marginTop: 40,
          fontFamily: theme.mono,
          fontSize: 42,
          color: theme.text,
          background: theme.bgElev,
          border: `2px solid ${theme.accent}`,
          padding: "22px 40px",
          borderRadius: 14,
          opacity: interpolate(frame, [60, 90], [0, 1], {
            extrapolateLeft: "clamp",
            extrapolateRight: "clamp",
          }),
        }}
      >
        github.com/malinskibeniamin/skills
      </div>
      <div
        style={{
          fontSize: 28,
          color: theme.textMuted,
          marginTop: 10,
          opacity: interpolate(frame, [120, 150], [0, 1], {
            extrapolateLeft: "clamp",
            extrapolateRight: "clamp",
          }),
        }}
      >
        /plugin marketplace add malinskibeniamin/skills
      </div>
    </AbsoluteFill>
  );
};
