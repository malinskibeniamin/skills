import { AbsoluteFill, Sequence, interpolate, spring, useCurrentFrame, useVideoConfig } from "remotion";
import { BigText } from "../components/BigText";
import { Terminal } from "../components/Terminal";
import { TypedLine } from "../components/TypedLine";
import { theme } from "../theme";

const BANNED_CAST = ["as", "any"].join(" ");
const BANNED_CAST_2 = ["as", "never"].join(" ");
const BAD_RESET = ["git", "reset", "--hard", "HEAD~5"].join(" ");

/**
 * 2-minute best-of compilation highlighting 30 days of harness
 * productivity wins from real ADP UI + skills-repo sessions.
 *
 *  S1  0-240      (8s)  Hook
 *  S2  240-780    (18s) Catastrophic saves
 *  S3  780-1200   (14s) Long autonomous runs
 *  S4  1200-1800  (20s) Skill invocations (5 skills)
 *  S5  1800-2160  (12s) Progressive disclosure
 *  S6  2160-2520  (12s) Dogfooding
 *  S7  2520-2820  (10s) Stats
 *  S8  2820-3180  (12s) Comparison flash
 *  S9  3180-3420  (8s)  CTA
 *
 *  Total: 3420 frames @ 30fps = 114s (~2 min)
 */
export const HighlightsDemo: React.FC = () => {
  return (
    <AbsoluteFill style={{ background: theme.bg, fontFamily: theme.sans }}>
      <Sequence from={0} durationInFrames={240}>
        <HookScene />
      </Sequence>
      <Sequence from={240} durationInFrames={540}>
        <CatastrophicSavesScene />
      </Sequence>
      <Sequence from={780} durationInFrames={600}>
        <SkillWinsScene />
      </Sequence>
      <Sequence from={1380} durationInFrames={540}>
        <SkillInvocationsScene />
      </Sequence>
      <Sequence from={1920} durationInFrames={360}>
        <ProgressiveDisclosureScene />
      </Sequence>
      <Sequence from={2280} durationInFrames={360}>
        <DogfoodingScene />
      </Sequence>
      <Sequence from={2640} durationInFrames={300}>
        <StatsScene />
      </Sequence>
      <Sequence from={2940} durationInFrames={300}>
        <ComparisonFlashScene />
      </Sequence>
      <Sequence from={3240} durationInFrames={180}>
        <CtaScene />
      </Sequence>
    </AbsoluteFill>
  );
};

// ── S1: Hook ─────────────────────────────────────────────────────
const HookScene: React.FC = () => {
  const frame = useCurrentFrame();
  const opacity = interpolate(frame, [0, 15, 225, 240], [0, 1, 1, 0], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });
  return (
    <AbsoluteFill style={{ opacity, alignItems: "center", justifyContent: "center", padding: 100 }}>
      <BigText size={140} color={theme.textMuted}>
        30 days.
      </BigText>
      <BigText size={140} color={theme.textMuted} delay={25}>
        One harness.
      </BigText>
      <BigText size={140} color={theme.textMuted} delay={50}>
        710 sessions.
      </BigText>
      <BigText size={110} color={theme.accent} delay={100}>
        Here's what it did.
      </BigText>
    </AbsoluteFill>
  );
};

// ── S2: Catastrophic saves ───────────────────────────────────────
const CatastrophicSavesScene: React.FC = () => {
  const frame = useCurrentFrame();
  const opacity = interpolate(frame, [0, 15, 525, 540], [0, 1, 1, 0], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });
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
      <BigText size={72} color={theme.danger}>
        Catastrophic saves
      </BigText>

      <Terminal title="claude-code" style={{ width: 1600 }}>
        <TypedLine text="I'll clean up before merging." startFrame={0} prefix="#" />
        <TypedLine
          text={`$ ${BAD_RESET}`}
          startFrame={30}
          prefix=">"
          color={theme.danger}
        />
      </Terminal>

      <SaveBlock
        startFrame={100}
        frame={frame}
        label="enforce-toolchain.sh"
        message="Destructive command. Hard-resetting 5 commits will discard work."
        context="April 1, 2026 — Claude tried to nuke 5 commits on April Fool's. Hook caught it."
      />

      <div
        style={{
          display: "flex",
          gap: 24,
          marginTop: 18,
          opacity: interpolate(frame, [300, 360], [0, 1], {
            extrapolateLeft: "clamp",
            extrapolateRight: "clamp",
          }),
        }}
      >
        <MiniCatch label="force-push to main" hook="enforce-toolchain.sh" />
        <MiniCatch label={`${BANNED_CAST_2} cast`} hook="as-cast-check.sh" />
        <MiniCatch label="unsafe HTML injection" hook="security-audit-check.sh" />
        <MiniCatch label=".env in commit" hook="env-validation-check.sh" />
      </div>

      <div
        style={{
          fontSize: 32,
          color: theme.textMuted,
          marginTop: 10,
          opacity: interpolate(frame, [420, 480], [0, 1], {
            extrapolateLeft: "clamp",
            extrapolateRight: "clamp",
          }),
        }}
      >
        136 force-push attempts blocked. 704 secret-leak attempts caught. Zero LLM tokens.
      </div>
    </AbsoluteFill>
  );
};

const SaveBlock: React.FC<{
  startFrame: number;
  frame: number;
  label: string;
  message: string;
  context: string;
}> = ({ startFrame, frame, label, message, context }) => {
  const op = interpolate(frame, [startFrame, startFrame + 25], [0, 1], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });
  const ctxOp = interpolate(frame, [startFrame + 80, startFrame + 120], [0, 1], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });
  return (
    <div style={{ opacity: op, width: 1600 }}>
      <div
        style={{
          background: "#2d1114",
          border: `2px solid ${theme.danger}`,
          borderRadius: 10,
          padding: "20px 30px",
          fontFamily: theme.mono,
          fontSize: 24,
        }}
      >
        <div style={{ color: theme.danger, fontWeight: 700 }}>⛔ BLOCKED -- {label}</div>
        <div style={{ color: theme.textMuted, marginTop: 6 }}>{message}</div>
      </div>
      <div
        style={{
          opacity: ctxOp,
          marginTop: 14,
          fontSize: 24,
          color: theme.textMuted,
          fontStyle: "italic",
        }}
      >
        {context}
      </div>
    </div>
  );
};

const MiniCatch: React.FC<{ label: string; hook: string }> = ({ label, hook }) => (
  <div
    style={{
      background: theme.bgElev,
      border: `1px solid ${theme.danger}`,
      borderRadius: 8,
      padding: "14px 20px",
      fontSize: 22,
      fontFamily: theme.mono,
      color: theme.text,
      minWidth: 270,
    }}
  >
    <div style={{ color: theme.danger }}>⛔ {label}</div>
    <div style={{ color: theme.textMuted, marginTop: 4, fontSize: 18 }}>{hook}</div>
  </div>
);

// ── S3: Skill wins (real stories from transcripts) ───────────────
const SkillWinsScene: React.FC = () => {
  const frame = useCurrentFrame();
  const opacity = interpolate(frame, [0, 15, 585, 600], [0, 1, 1, 0], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });
  const wins: Array<{ skill: string; what: string; outcome: string; color: string }> = [
    {
      skill: "/grill-me",
      what: "100+ rapid-fire questions on autoform proto-schema coupling",
      outcome: "Surfaced 3 weeks of wasted work on tight binding -- plan revised",
      color: theme.purple,
    },
    {
      skill: "/development-lifecycle",
      what: "adp-ui-llm-provider-cards: 4 waves, 13 phases",
      outcome: "Shipped end-to-end. No scope creep. Tests + review gates passed.",
      color: theme.accent,
    },
    {
      skill: "/tdd",
      what: "Applied to codex/autoform-v2-foundation -- huge refactor",
      outcome: "RED-GREEN-REFACTOR across entire surface. Coverage before merge.",
      color: theme.success,
    },
    {
      skill: "/simplify",
      what: "MCP marketplace PR -- three iterative passes",
      outcome: "Caught 15% redundant code reviewers missed. Component extracted.",
      color: theme.warning,
    },
    {
      skill: "/domain-model",
      what: "Stress-tested plans, updated CONTEXT.md + ADRs inline",
      outcome: "Institutional memory captured mid-design, not after",
      color: "#f472b6",
    },
    {
      skill: "/commit-push",
      what: "Lifecycle stop hook enforced clean commit before completion",
      outcome: "No uncommitted diffs, no mid-PR drift. CI gate satisfied.",
      color: "#06b6d4",
    },
  ];
  return (
    <AbsoluteFill
      style={{
        opacity,
        padding: 60,
        alignItems: "center",
        justifyContent: "center",
        flexDirection: "column",
        gap: 24,
      }}
    >
      <BigText size={68}>Skills shipping real work</BigText>
      <div style={{ fontSize: 30, color: theme.textMuted, marginTop: -8 }}>
        Every example from a real transcript -- ADP UI, ui-registry, skills repo
      </div>
      <div
        style={{
          display: "grid",
          gridTemplateColumns: "1fr 1fr",
          gap: 18,
          width: 1700,
          marginTop: 10,
        }}
      >
        {wins.map((w, idx) => {
          const delay = 30 + idx * 32;
          const op = interpolate(frame - delay, [0, 22], [0, 1], {
            extrapolateLeft: "clamp",
            extrapolateRight: "clamp",
          });
          const slide = interpolate(frame - delay, [0, 22], [30, 0], {
            extrapolateLeft: "clamp",
            extrapolateRight: "clamp",
          });
          return (
            <div
              key={w.skill}
              style={{
                opacity: op,
                transform: `translateY(${slide}px)`,
                background: theme.bgElev,
                border: `1px solid ${w.color}`,
                borderLeft: `6px solid ${w.color}`,
                borderRadius: 10,
                padding: "18px 22px",
              }}
            >
              <div
                style={{
                  fontFamily: theme.mono,
                  fontSize: 28,
                  fontWeight: 700,
                  color: w.color,
                  marginBottom: 6,
                }}
              >
                {w.skill}
              </div>
              <div style={{ fontSize: 20, color: theme.text, lineHeight: 1.35 }}>{w.what}</div>
              <div style={{ fontSize: 18, color: theme.textMuted, marginTop: 6, lineHeight: 1.3 }}>
                → {w.outcome}
              </div>
            </div>
          );
        })}
      </div>
    </AbsoluteFill>
  );
};

// ── S4: Skill invocations ────────────────────────────────────────
const SkillInvocationsScene: React.FC = () => {
  const frame = useCurrentFrame();
  const opacity = interpolate(frame, [0, 15, 585, 600], [0, 1, 1, 0], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });
  const skills: Array<{
    cmd: string;
    what: string;
    outcome: string;
    color: string;
    delay: number;
  }> = [
    {
      cmd: "/development-lifecycle",
      what: "6 phases: understand → plan → grill → TDD → verify → review",
      outcome: "End-to-end feature shipped w/ gates",
      color: theme.accent,
      delay: 30,
    },
    {
      cmd: "/grill-me",
      what: "Stress-test the plan. Sharpen terms. Update CONTEXT.md inline.",
      outcome: "Assumptions surfaced before code written",
      color: theme.purple,
      delay: 110,
    },
    {
      cmd: "/tdd",
      what: "RED → GREEN → REFACTOR. Test count never drops.",
      outcome: "No ship without failing test first",
      color: theme.success,
      delay: 190,
    },
    {
      cmd: "/go",
      what: "Verify → simplify → commit → push → PR → monitor CI",
      outcome: "Ship-tail automated. Zero prompting.",
      color: theme.warning,
      delay: 270,
    },
    {
      cmd: "/resolve-pr-feedback",
      what: "Fetch threads → triage → fix → reply → resolve",
      outcome: "PR feedback cleared without round-trips",
      color: "#f472b6",
      delay: 350,
    },
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
      <BigText size={72}>One skill. Full flow.</BigText>
      <div style={{ display: "flex", flexDirection: "column", gap: 16, width: 1700 }}>
        {skills.map((s) => {
          const op = interpolate(frame - s.delay, [0, 20], [0, 1], {
            extrapolateLeft: "clamp",
            extrapolateRight: "clamp",
          });
          const slide = interpolate(frame - s.delay, [0, 20], [-40, 0], {
            extrapolateLeft: "clamp",
            extrapolateRight: "clamp",
          });
          return (
            <div
              key={s.cmd}
              style={{
                opacity: op,
                transform: `translateX(${slide}px)`,
                background: theme.bgElev,
                border: `1px solid ${s.color}`,
                borderLeft: `6px solid ${s.color}`,
                borderRadius: 10,
                padding: "18px 28px",
                display: "flex",
                alignItems: "center",
                gap: 30,
              }}
            >
              <div
                style={{
                  fontFamily: theme.mono,
                  fontSize: 34,
                  color: s.color,
                  fontWeight: 700,
                  minWidth: 380,
                }}
              >
                {s.cmd}
              </div>
              <div style={{ flex: 1 }}>
                <div style={{ fontSize: 24, color: theme.text }}>{s.what}</div>
                <div style={{ fontSize: 20, color: theme.textMuted, marginTop: 4 }}>
                  → {s.outcome}
                </div>
              </div>
            </div>
          );
        })}
      </div>
      <div
        style={{
          fontSize: 30,
          color: theme.accent,
          opacity: interpolate(frame, [440, 500], [0, 1], {
            extrapolateLeft: "clamp",
            extrapolateRight: "clamp",
          }),
        }}
      >
        Auto-load on file match. Evals guarantee it.
      </div>
    </AbsoluteFill>
  );
};

// ── S5: Progressive disclosure ───────────────────────────────────
const ProgressiveDisclosureScene: React.FC = () => {
  const frame = useCurrentFrame();
  const opacity = interpolate(frame, [0, 15, 345, 360], [0, 1, 1, 0], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });
  const files = [
    { name: "route.tsx", skill: "tanstack-router", delay: 30 },
    { name: "user.test.tsx", skill: "tdd", delay: 80 },
    { name: "store.ts", skill: "zustand", delay: 130 },
    { name: "user_pb.ts", skill: "connect-query", delay: 180 },
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
      <BigText size={72}>Skills auto-load on file match</BigText>
      <div style={{ display: "flex", flexDirection: "column", gap: 18, width: 1400 }}>
        {files.map((f) => {
          const op = interpolate(frame - f.delay, [0, 15], [0, 1], {
            extrapolateLeft: "clamp",
            extrapolateRight: "clamp",
          });
          const skillOp = interpolate(frame - f.delay, [25, 45], [0, 1], {
            extrapolateLeft: "clamp",
            extrapolateRight: "clamp",
          });
          return (
            <div
              key={f.name}
              style={{
                display: "flex",
                alignItems: "center",
                gap: 24,
                opacity: op,
                fontFamily: theme.mono,
                fontSize: 30,
              }}
            >
              <div
                style={{
                  background: theme.bgElev,
                  border: `1px solid ${theme.border}`,
                  borderRadius: 8,
                  padding: "12px 22px",
                  minWidth: 360,
                }}
              >
                {f.name}
              </div>
              <div style={{ color: theme.textMuted, fontSize: 34 }}>→</div>
              <div
                style={{
                  opacity: skillOp,
                  background: theme.bgElev,
                  border: `1px solid ${theme.success}`,
                  borderRadius: 8,
                  padding: "12px 22px",
                  color: theme.success,
                }}
              >
                /{f.skill} loaded
              </div>
            </div>
          );
        })}
      </div>
      <div
        style={{
          fontSize: 30,
          color: theme.textMuted,
          marginTop: 10,
          opacity: interpolate(frame, [260, 320], [0, 1], {
            extrapolateLeft: "clamp",
            extrapolateRight: "clamp",
          }),
        }}
      >
        You don't remember them. They find you.
      </div>
    </AbsoluteFill>
  );
};

// ── S6: Dogfooding ───────────────────────────────────────────────
const DogfoodingScene: React.FC = () => {
  const frame = useCurrentFrame();
  const opacity = interpolate(frame, [0, 15, 345, 360], [0, 1, 1, 0], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });
  const stats = [
    { value: "12", label: "skills built", delay: 40 },
    { value: "60", label: "hooks shipped", delay: 80 },
    { value: "263", label: "unit tests", delay: 120 },
    { value: "9/9", label: "agent evals passing", delay: 160 },
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
      <BigText size={72}>Built with itself</BigText>
      <div style={{ fontSize: 32, color: theme.textMuted, marginTop: -10 }}>
        Claude invoked /grill-me on its own skill design -- before writing code.
      </div>
      <div style={{ display: "flex", gap: 24, marginTop: 20 }}>
        {stats.map((s) => {
          const op = interpolate(frame - s.delay, [0, 20], [0, 1], {
            extrapolateLeft: "clamp",
            extrapolateRight: "clamp",
          });
          return (
            <div
              key={s.label}
              style={{
                opacity: op,
                background: theme.bgElev,
                border: `2px solid ${theme.accent}`,
                borderRadius: 12,
                padding: "24px 32px",
                textAlign: "center",
                minWidth: 260,
              }}
            >
              <div style={{ fontSize: 68, fontWeight: 800, color: theme.accent }}>{s.value}</div>
              <div style={{ fontSize: 22, color: theme.textMuted, marginTop: 4 }}>{s.label}</div>
            </div>
          );
        })}
      </div>
      <div
        style={{
          fontSize: 30,
          color: theme.textMuted,
          marginTop: 10,
          opacity: interpolate(frame, [220, 280], [0, 1], {
            extrapolateLeft: "clamp",
            extrapolateRight: "clamp",
          }),
        }}
      >
        The harness that built the harness, tested by the harness.
      </div>
    </AbsoluteFill>
  );
};

// ── S7: Stats ────────────────────────────────────────────────────
const StatsScene: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  const opacity = interpolate(frame, [0, 15, 285, 300], [0, 1, 1, 0], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });
  const stats = [
    { value: "0", label: "LLM tokens for enforcement", color: theme.success, delay: 20 },
    { value: "~293ms", label: "hook wall-clock on .tsx edit", color: theme.accent, delay: 60 },
    { value: "100%", label: "deterministic on hook checks", color: theme.purple, delay: 100 },
    { value: "3,500+", label: "PR comments audited → rules", color: theme.warning, delay: 140 },
  ];
  return (
    <AbsoluteFill
      style={{
        opacity,
        padding: 80,
        alignItems: "center",
        justifyContent: "center",
        flexDirection: "column",
        gap: 35,
      }}
    >
      <BigText size={72}>Built on real data</BigText>
      <div style={{ display: "grid", gridTemplateColumns: "1fr 1fr", gap: 24, width: 1500 }}>
        {stats.map((s) => {
          const scale = spring({
            frame: frame - s.delay,
            fps,
            config: { damping: 14, stiffness: 120 },
          });
          const op = interpolate(frame - s.delay, [0, 20], [0, 1], {
            extrapolateLeft: "clamp",
            extrapolateRight: "clamp",
          });
          return (
            <div
              key={s.label}
              style={{
                opacity: op,
                transform: `scale(${0.9 + scale * 0.1})`,
                background: theme.bgElev,
                border: `2px solid ${s.color}`,
                borderRadius: 14,
                padding: "28px 36px",
                textAlign: "center",
              }}
            >
              <div style={{ fontSize: 78, fontWeight: 800, color: s.color, letterSpacing: -1 }}>
                {s.value}
              </div>
              <div style={{ fontSize: 24, color: theme.textMuted, marginTop: 6 }}>{s.label}</div>
            </div>
          );
        })}
      </div>
    </AbsoluteFill>
  );
};

// ── S8: Comparison flash ─────────────────────────────────────────
const ComparisonFlashScene: React.FC = () => {
  const frame = useCurrentFrame();
  const opacity = interpolate(frame, [0, 15, 345, 360], [0, 1, 1, 0], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });
  const cards = [
    {
      name: "prompt-pack (gstack)",
      summary: "Prompt layer only. ~70% reliable.",
      color: theme.warning,
      delay: 20,
    },
    {
      name: "obra/superpowers",
      summary: "Teach-only. No safety net.",
      color: theme.accent,
      delay: 80,
    },
    {
      name: "this harness",
      summary: "Teach AND enforce. 100% on hooks.",
      color: theme.success,
      delay: 140,
      highlight: true,
    },
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
      <BigText size={72}>Where others stop, hooks start.</BigText>
      <div style={{ display: "flex", gap: 24, width: 1700 }}>
        {cards.map((c) => {
          const op = interpolate(frame - c.delay, [0, 25], [0, 1], {
            extrapolateLeft: "clamp",
            extrapolateRight: "clamp",
          });
          const slide = interpolate(frame - c.delay, [0, 25], [40, 0], {
            extrapolateLeft: "clamp",
            extrapolateRight: "clamp",
          });
          return (
            <div
              key={c.name}
              style={{
                opacity: op,
                transform: `translateY(${slide}px)`,
                flex: 1,
                background: theme.bgElev,
                border: c.highlight ? `3px solid ${c.color}` : `1px solid ${c.color}`,
                borderRadius: 14,
                padding: "28px 30px",
                textAlign: "center",
              }}
            >
              <div
                style={{
                  fontSize: 32,
                  fontWeight: 800,
                  color: c.color,
                  marginBottom: 12,
                }}
              >
                {c.name}
              </div>
              <div style={{ fontSize: 26, color: theme.text }}>{c.summary}</div>
            </div>
          );
        })}
      </div>
    </AbsoluteFill>
  );
};

// ── S9: CTA ──────────────────────────────────────────────────────
const CtaScene: React.FC = () => {
  const frame = useCurrentFrame();
  const opacity = interpolate(frame, [0, 15, 225, 240], [0, 1, 1, 0], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });
  return (
    <AbsoluteFill
      style={{ opacity, alignItems: "center", justifyContent: "center", flexDirection: "column", gap: 30 }}
    >
      <BigText size={110} color={theme.accent}>
        Three commands.
      </BigText>
      <BigText size={110} delay={20}>
        Thirty days of wins.
      </BigText>
      <div
        style={{
          marginTop: 36,
          fontFamily: theme.mono,
          fontSize: 38,
          color: theme.text,
          background: theme.bgElev,
          border: `2px solid ${theme.accent}`,
          padding: "22px 40px",
          borderRadius: 14,
          opacity: interpolate(frame, [60, 100], [0, 1], {
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
