import type { CSSProperties, ReactNode } from "react";
import { interpolate, spring, useCurrentFrame, useVideoConfig } from "remotion";
import { theme } from "../theme";

type BigTextProps = {
  children: ReactNode;
  delay?: number;
  size?: number;
  color?: string;
  weight?: number;
  style?: CSSProperties;
};

export const BigText: React.FC<BigTextProps> = ({
  children,
  delay = 0,
  size = 96,
  color = theme.text,
  weight = 800,
  style,
}) => {
  const frame = useCurrentFrame();
  const { fps } = useVideoConfig();
  const scale = spring({
    frame: frame - delay,
    fps,
    config: { damping: 14, stiffness: 120 },
  });
  const opacity = interpolate(frame - delay, [0, 12], [0, 1], {
    extrapolateLeft: "clamp",
    extrapolateRight: "clamp",
  });

  return (
    <div
      style={{
        fontSize: size,
        fontWeight: weight,
        color,
        letterSpacing: -1.5,
        lineHeight: 1.1,
        transform: `scale(${0.92 + scale * 0.08})`,
        opacity,
        fontFamily: theme.sans,
        ...style,
      }}
    >
      {children}
    </div>
  );
};
