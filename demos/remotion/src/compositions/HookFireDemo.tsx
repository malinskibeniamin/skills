import { AbsoluteFill, interpolate, spring, useCurrentFrame, useVideoConfig } from "remotion";
import { Terminal } from "../components/Terminal";
import { TypedLine } from "../components/TypedLine";
import { theme } from "../theme";

const BANNED_CAST = ["as", "any"].join(" ");
const BAD_LINE = `  const user = data ${BANNED_CAST};`;
const BLOCK_MSG = `\`${BANNED_CAST}\` banned. Use type guards, zod, or generics.`;

/**
 * Short hero GIF: dev types banned unsafe cast, hook blocks, dev fixes.
 * Duration: 360 frames @ 30fps = 12s
 *
 * Beats:
 *  0-90    type unsafe-cast line
 *  90-150  hook block overlay slides in
 *  150-210 wrong line strikes through, correct line types
 *  210-300 "Hook passed (~293ms)" checkmark
 *  300-360 bottom caption: "Deterministic. 100 percent. Zero LLM tokens."
 */
export const HookFireDemo: React.FC = () => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();

  const blockEnter = spring({
    frame: frame - 90,
    fps,
    config: { damping: 14, stiffness: 110 },
  });
  const blockOpacity = interpolate(frame, [85, 105, 205, 225], [0, 1, 1, 0], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });
  const strikeProgress = interpolate(frame, [150, 180], [0, 1], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });
  const checkOpacity = interpolate(frame, [210, 230], [0, 1], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });
  const captionOpacity = interpolate(frame, [300, 320], [0, 1], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });

  return (
    <AbsoluteFill
      style={{
        background: "radial-gradient(circle at 30% 20%, #1a1f2e 0%, #0d1117 60%)",
        alignItems: "center",
        justifyContent: "center",
        padding: 60,
        fontFamily: theme.sans,
      }}
    >
      <Terminal title="src/features/user.ts" style={{ width: 1100 }}>
        <div style={{ display: "flex", flexDirection: "column", gap: 12 }}>
          <TypedLine text="export function parseUser(data: unknown) {" startFrame={0} prefix="1" />
          <TypedLine
            text={BAD_LINE}
            startFrame={18}
            prefix="2"
            color={theme.danger}
          />
          <div style={{ position: "relative" }}>
            {strikeProgress > 0 ? (
              <div
                style={{
                  position: "absolute",
                  left: 46,
                  top: 16,
                  height: 3,
                  width: `${strikeProgress * 430}px`,
                  background: theme.danger,
                  opacity: 1 - checkOpacity * 0.6,
                  pointerEvents: "none",
                }}
              />
            ) : null}
          </div>
          {frame >= 150 ? (
            <TypedLine
              text="  const user = userSchema.parse(data);"
              startFrame={150}
              prefix="2"
              color={theme.success}
            />
          ) : null}
          <TypedLine text="  return user;" startFrame={54} prefix="3" />
          <TypedLine text="}" startFrame={66} prefix="4" />
        </div>
      </Terminal>

      <div
        style={{
          marginTop: 36,
          transform: `translateY(${(1 - blockEnter) * 30}px)`,
          opacity: blockOpacity,
          width: 1100,
        }}
      >
        <div
          style={{
            background: "#2d1114",
            border: `1px solid ${theme.danger}`,
            borderRadius: 10,
            padding: "18px 24px",
            display: "flex",
            alignItems: "center",
            gap: 18,
            fontFamily: theme.mono,
            color: theme.text,
            fontSize: 20,
          }}
        >
          <span style={{ fontSize: 28 }}>⛔</span>
          <div>
            <div style={{ fontWeight: 700, color: theme.danger }}>
              BLOCKED -- react-rules-check.sh (~293ms)
            </div>
            <div style={{ color: theme.textMuted, marginTop: 4 }}>{BLOCK_MSG}</div>
          </div>
        </div>
      </div>

      <div
        style={{
          marginTop: 28,
          opacity: checkOpacity,
          display: "flex",
          alignItems: "center",
          gap: 16,
          fontFamily: theme.mono,
          fontSize: 22,
          color: theme.success,
        }}
      >
        <span style={{ fontSize: 28 }}>✓</span>
        <span>Hook passed. ~293ms. Zero LLM tokens.</span>
      </div>

      <div
        style={{
          position: "absolute",
          bottom: 60,
          opacity: captionOpacity,
          fontSize: 32,
          fontWeight: 700,
          color: theme.accent,
          letterSpacing: -0.5,
        }}
      >
        Deterministic enforcement. 100% reliable. Every edit.
      </div>
    </AbsoluteFill>
  );
};
