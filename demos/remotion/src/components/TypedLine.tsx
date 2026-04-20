import { useCurrentFrame } from "remotion";
import { theme } from "../theme";

type TypedLineProps = {
  text: string;
  startFrame: number;
  charsPerFrame?: number;
  color?: string;
  prefix?: string;
  cursor?: boolean;
};

export const TypedLine: React.FC<TypedLineProps> = ({
  text,
  startFrame,
  charsPerFrame = 0.6,
  color,
  prefix,
  cursor = true,
}) => {
  const frame = useCurrentFrame();
  const elapsed = Math.max(0, frame - startFrame);
  const visibleCount = Math.min(text.length, Math.floor(elapsed * charsPerFrame));
  const visible = text.slice(0, visibleCount);
  const typing = visibleCount < text.length && elapsed > 0;
  const showCursor = cursor && typing && Math.floor(frame / 15) % 2 === 0;

  if (elapsed <= 0) {
    return null;
  }

  return (
    <div style={{ display: "flex", gap: 10, color: color ?? theme.text }}>
      {prefix ? <span style={{ color: theme.textMuted }}>{prefix}</span> : null}
      <span>
        {visible}
        {showCursor ? <span style={{ opacity: 0.8 }}>▋</span> : null}
      </span>
    </div>
  );
};
