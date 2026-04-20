import { Composition } from "remotion";
import { AnnouncementDemo } from "./compositions/AnnouncementDemo";
import { ExplainerDemo } from "./compositions/ExplainerDemo";
import { HookFireDemo } from "./compositions/HookFireDemo";

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
    </>
  );
};
