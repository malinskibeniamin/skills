import type { ReactNode } from "react";
import { AbsoluteFill, interpolate, useCurrentFrame } from "remotion";
import { theme } from "../theme";

type SceneProps = {
  children: ReactNode;
  background?: string;
  fadeIn?: number;
  fadeOut?: number;
  totalFrames: number;
};

export const Scene: React.FC<SceneProps> = ({
  children,
  background = theme.bg,
  fadeIn = 10,
  fadeOut = 10,
  totalFrames,
}) => {
  const frame = useCurrentFrame();
  const opacity = interpolate(
    frame,
    [0, fadeIn, totalFrames - fadeOut, totalFrames],
    [0, 1, 1, 0],
    { extrapolateLeft: "clamp", extrapolateRight: "clamp" },
  );

  return (
    <AbsoluteFill
      style={{
        background,
        opacity,
        alignItems: "center",
        justifyContent: "center",
        padding: 80,
        fontFamily: theme.sans,
        color: theme.text,
      }}
    >
      {children}
    </AbsoluteFill>
  );
};
