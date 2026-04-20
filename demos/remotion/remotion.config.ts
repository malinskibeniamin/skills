import { Config } from "@remotion/cli/config";

Config.setVideoImageFormat("jpeg");
Config.setConcurrency(4);
Config.setOverwriteOutput(true);
Config.setEntryPoint("./src/index.ts");
