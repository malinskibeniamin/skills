import { Composition } from "remotion";
import { AnnouncementDemo } from "./compositions/AnnouncementDemo";
import { ComparisonDemo } from "./compositions/ComparisonDemo";
import { ExplainerDemo } from "./compositions/ExplainerDemo";
import { HighlightsDemo } from "./compositions/HighlightsDemo";
import { HookFireDemo } from "./compositions/HookFireDemo";
import { WowFactorDemo } from "./compositions/WowFactorDemo";

export const Root: React.FC = () => {
  return (
    <>
      <Composition
        id="AnnouncementDemo"
        component={AnnouncementDemo}
        durationInFrames={2100}
        fps={30}
        width={1920}
        height={1080}
      />
      <Composition
        id="ComparisonDemo"
        component={ComparisonDemo}
        durationInFrames={1500}
        fps={30}
        width={1920}
        height={1080}
      />
      <Composition
        id="HighlightsDemo"
        component={HighlightsDemo}
        durationInFrames={3420}
        fps={30}
        width={1920}
        height={1080}
      />
      <Composition
        id="ExplainerDemo"
        component={ExplainerDemo}
        durationInFrames={1800}
        fps={30}
        width={1920}
        height={1080}
      />
      <Composition
        id="HookFireDemo"
        component={HookFireDemo}
        durationInFrames={360}
        fps={30}
        width={1280}
        height={720}
      />
      <Composition
        id="WowFactorDemo"
        component={WowFactorDemo}
        durationInFrames={750}
        fps={30}
        width={1280}
        height={720}
      />
    </>
  );
};
