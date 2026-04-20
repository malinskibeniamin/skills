import type { CSSProperties, ReactNode } from "react";
import { theme } from "../theme";

type TerminalProps = {
  title?: string;
  children: ReactNode;
  style?: CSSProperties;
};

export const Terminal: React.FC<TerminalProps> = ({ title = "claude-code", children, style }) => {
  return (
    <div
      style={{
        background: theme.bgElev,
        borderRadius: 12,
        border: `1px solid ${theme.border}`,
        overflow: "hidden",
        fontFamily: theme.mono,
        color: theme.text,
        boxShadow: "0 20px 60px rgba(0,0,0,0.45)",
        ...style,
      }}
    >
      <div
        style={{
          display: "flex",
          alignItems: "center",
          gap: 10,
          padding: "14px 18px",
          background: "#21262d",
          borderBottom: `1px solid ${theme.border}`,
        }}
      >
        <Dot color="#ff5f57" />
        <Dot color="#febc2e" />
        <Dot color="#28c840" />
        <span
          style={{
            marginLeft: 14,
            fontSize: 16,
            color: theme.textMuted,
            fontFamily: theme.sans,
          }}
        >
          {title}
        </span>
      </div>
      <div style={{ padding: "22px 26px", fontSize: 22, lineHeight: 1.55 }}>{children}</div>
    </div>
  );
};

const Dot: React.FC<{ color: string }> = ({ color }) => (
  <span
    style={{
      width: 12,
      height: 12,
      borderRadius: "50%",
      background: color,
      display: "inline-block",
    }}
  />
);
