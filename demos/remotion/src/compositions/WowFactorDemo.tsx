import { AbsoluteFill, Sequence, interpolate, spring, useCurrentFrame, useVideoConfig } from "remotion";
import { BigText } from "../components/BigText";
import { theme } from "../theme";

/**
 * ~25s wow-factor reel. Four punchy beats. Renders as GIF for
 * autoplay-on-GitHub README embed.
 *
 *  B1  0-210   (7s)  Review cycles slam -- 3-5 → 0-1
 *  B2  210-420 (7s)  Overnight ship -- "while you slept"
 *  B3  420-600 (6s)  Force-push to main blocked -- catastrophe averted
 *  B4  600-750 (5s)  Closer -- 0 tokens / 100% deterministic
 */
export const WowFactorDemo: React.FC = () => {
  return (
    <AbsoluteFill style={{ background: theme.bg, fontFamily: theme.sans }}>
      <Sequence from={0} durationInFrames={210}>
        <ReviewCyclesBeat />
      </Sequence>
      <Sequence from={210} durationInFrames={210}>
        <OvernightShipBeat />
      </Sequence>
      <Sequence from={420} durationInFrames={180}>
        <ForcePushBeat />
      </Sequence>
      <Sequence from={600} durationInFrames={150}>
        <CloserBeat />
      </Sequence>
    </AbsoluteFill>
  );
};

// ── B1: Review cycles slam ───────────────────────────────────────
const ReviewCyclesBeat: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  const opacity = interpolate(frame, [0, 10, 195, 210], [0, 1, 1, 0], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });
  const beforeBar = interpolate(frame, [25, 70], [0, 100], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });
  const afterBar = interpolate(frame, [85, 130], [0, 20], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });
  const numberScale = spring({
    frame: frame - 140,
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
        gap: 18,
        padding: 60,
      }}
    >
      <BigText size={54} color={theme.textMuted}>
        Human review cycles per PR
      </BigText>

      <div style={{ display: "flex", gap: 60, width: 1100, marginTop: 10, alignItems: "center" }}>
        <div style={{ flex: 1 }}>
          <div style={{ fontSize: 32, color: theme.danger, marginBottom: 10 }}>before</div>
          <div
            style={{
              height: 80,
              width: `${beforeBar}%`,
              background: theme.danger,
              borderRadius: 8,
              transition: "width 0.1s",
            }}
          />
          <div style={{ fontSize: 72, fontWeight: 800, color: theme.danger, marginTop: 8 }}>
            3-5 rounds
          </div>
        </div>
        <div style={{ flex: 1 }}>
          <div style={{ fontSize: 32, color: theme.success, marginBottom: 10 }}>after</div>
          <div
            style={{
              height: 80,
              width: `${afterBar}%`,
              minWidth: 40,
              background: theme.success,
              borderRadius: 8,
              transition: "width 0.1s",
            }}
          />
          <div style={{ fontSize: 72, fontWeight: 800, color: theme.success, marginTop: 8 }}>
            0-1 rounds
          </div>
        </div>
      </div>

      <div
        style={{
          fontSize: 40,
          fontWeight: 700,
          color: theme.accent,
          marginTop: 16,
          transform: `scale(${0.9 + numberScale * 0.1})`,
          opacity: interpolate(frame, [140, 170], [0, 1], {
            extrapolateLeft: "clamp",
            extrapolateRight: "clamp",
          }),
        }}
      >
        15-30k tokens wasted → 500-2k with hooks
      </div>
    </AbsoluteFill>
  );
};

// ── B2: Overnight ship ───────────────────────────────────────────
const OvernightShipBeat: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  const opacity = interpolate(frame, [0, 10, 195, 210], [0, 1, 1, 0], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });
  const headlineScale = spring({
    frame: frame - 15,
    fps,
    config: { damping: 12, stiffness: 100 },
  });
  return (
    <AbsoluteFill
      style={{
        opacity,
        alignItems: "center",
        justifyContent: "center",
        flexDirection: "column",
        gap: 16,
        padding: 80,
      }}
    >
      <div
        style={{
          fontSize: 128,
          fontWeight: 800,
          color: theme.text,
          letterSpacing: -3,
          lineHeight: 1,
          transform: `scale(${0.85 + headlineScale * 0.15})`,
        }}
      >
        While you slept,
      </div>
      <div
        style={{
          fontSize: 128,
          fontWeight: 800,
          color: theme.accent,
          letterSpacing: -3,
          lineHeight: 1,
          opacity: interpolate(frame, [50, 75], [0, 1], {
            extrapolateLeft: "clamp",
            extrapolateRight: "clamp",
          }),
        }}
      >
        Claude shipped.
      </div>

      <div
        style={{
          marginTop: 26,
          display: "flex",
          gap: 24,
          fontFamily: theme.mono,
          opacity: interpolate(frame, [95, 130], [0, 1], {
            extrapolateLeft: "clamp",
            extrapolateRight: "clamp",
          }),
        }}
      >
        <StatChip value="30h" label="unattended" color={theme.purple} />
        <StatChip value="13" label="phases" color={theme.success} />
        <StatChip value="4" label="waves" color={theme.warning} />
        <StatChip value="0" label="destructive cmds" color={theme.danger} />
      </div>

      <div
        style={{
          fontSize: 30,
          color: theme.textMuted,
          marginTop: 12,
          opacity: interpolate(frame, [130, 165], [0, 1], {
            extrapolateLeft: "clamp",
            extrapolateRight: "clamp",
          }),
        }}
      >
        adp-ui-llm-provider-cards -- PR opened, tests green, reviewer assigned.
      </div>
    </AbsoluteFill>
  );
};

const StatChip: React.FC<{ value: string; label: string; color: string }> = ({ value, label, color }) => (
  <div
    style={{
      background: theme.bgElev,
      border: `2px solid ${color}`,
      borderRadius: 10,
      padding: "14px 22px",
      textAlign: "center",
      minWidth: 200,
    }}
  >
    <div style={{ fontSize: 60, fontWeight: 800, color, letterSpacing: -1, lineHeight: 1 }}>{value}</div>
    <div style={{ fontSize: 22, color: theme.textMuted, marginTop: 4 }}>{label}</div>
  </div>
);

// ── B3: Force-push to main blocked ───────────────────────────────
const ForcePushBeat: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  const opacity = interpolate(frame, [0, 10, 165, 180], [0, 1, 1, 0], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });
  const stampScale = spring({
    frame: frame - 45,
    fps,
    config: { damping: 8, stiffness: 120 },
  });
  return (
    <AbsoluteFill
      style={{
        opacity,
        alignItems: "center",
        justifyContent: "center",
        flexDirection: "column",
        gap: 22,
        padding: 80,
      }}
    >
      <div style={{ fontSize: 40, color: theme.textMuted }}>4am. Branch in a bad state.</div>
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
          fontSize: 200,
          fontWeight: 800,
          color: theme.danger,
          letterSpacing: -5,
          transform: `scale(${0.8 + stampScale * 0.2}) rotate(${-4 + stampScale * 0}deg)`,
          opacity: interpolate(frame, [40, 70], [0, 1], {
            extrapolateLeft: "clamp",
            extrapolateRight: "clamp",
          }),
        }}
      >
        ⛔ BLOCKED
      </div>
      <div
        style={{
          fontSize: 38,
          fontWeight: 700,
          color: theme.success,
          marginTop: 6,
          opacity: interpolate(frame, [95, 125], [0, 1], {
            extrapolateLeft: "clamp",
            extrapolateRight: "clamp",
          }),
        }}
      >
        Production intact. PR flow auto-suggested.
      </div>
    </AbsoluteFill>
  );
};

// ── B4: Closer ───────────────────────────────────────────────────
const CloserBeat: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  const opacity = interpolate(frame, [0, 10, 135, 150], [0, 1, 1, 0], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });
  const stats = [
    { value: "60", label: "hooks", color: theme.accent, delay: 10 },
    { value: "74", label: "checks per edit", color: theme.success, delay: 30 },
    { value: "0", label: "LLM tokens", color: theme.purple, delay: 50 },
    { value: "100%", label: "deterministic", color: theme.warning, delay: 70 },
  ];
  return (
    <AbsoluteFill
      style={{
        opacity,
        alignItems: "center",
        justifyContent: "center",
        flexDirection: "column",
        gap: 18,
        padding: 60,
      }}
    >
      <BigText size={72} color={theme.text}>
        Every edit. Every turn.
      </BigText>
      <div style={{ display: "flex", gap: 16, marginTop: 10 }}>
        {stats.map((s) => {
          const scale = spring({
            frame: frame - s.delay,
            fps,
            config: { damping: 12, stiffness: 110 },
          });
          const op = interpolate(frame - s.delay, [0, 18], [0, 1], {
            extrapolateLeft: "clamp",
            extrapolateRight: "clamp",
          });
          return (
            <div
              key={s.label}
              style={{
                opacity: op,
                transform: `scale(${0.85 + scale * 0.15})`,
                background: theme.bgElev,
                border: `2px solid ${s.color}`,
                borderRadius: 12,
                padding: "22px 28px",
                textAlign: "center",
                minWidth: 200,
              }}
            >
              <div style={{ fontSize: 72, fontWeight: 800, color: s.color, letterSpacing: -1 }}>
                {s.value}
              </div>
              <div style={{ fontSize: 22, color: theme.textMuted, marginTop: 2 }}>{s.label}</div>
            </div>
          );
        })}
      </div>
      <div
        style={{
          marginTop: 16,
          fontFamily: theme.mono,
          fontSize: 32,
          color: theme.text,
          background: theme.bgElev,
          border: `2px solid ${theme.accent}`,
          borderRadius: 12,
          padding: "14px 30px",
          opacity: interpolate(frame, [90, 115], [0, 1], {
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
