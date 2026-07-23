// @ts-check

const PACKAGES_ROOT = "src/packages";
const INTERNALS = `^${PACKAGES_ROOT}/[^/]+/[^/]+/`;
const TEST_FILES = `^${PACKAGES_ROOT}/[^/]+/.+\\.(test|spec)\\.[^/]+$`;

/** @type {import("dependency-cruiser").IConfiguration} */
module.exports = {
  forbidden: [
    {
      name: "entrypoint-boundary-from-app",
      comment: "App code reaches packages only through root entry points.",
      severity: "error",
      from: { pathNot: `^${PACKAGES_ROOT}/` },
      to: { path: `${INTERNALS}|${TEST_FILES}` },
    },
    {
      name: "entrypoint-boundary-across-packages",
      comment: "Packages reach other packages only through root entry points.",
      severity: "error",
      from: { path: `^${PACKAGES_ROOT}/([^/]+)/` },
      to: {
        path: INTERNALS,
        pathNot: `^${PACKAGES_ROOT}/$1/`,
      },
    },
    {
      name: "tests-through-entrypoints",
      comment: "Co-located tests exercise package behavior through root entry points.",
      severity: "error",
      from: { path: TEST_FILES },
      to: { path: INTERNALS },
    },
    {
      name: "test-files-are-private",
      comment: "Test modules are not an importable package surface.",
      severity: "error",
      from: {},
      to: { path: TEST_FILES },
    },
    {
      name: "no-circular",
      comment: "Package dependency cycles are forbidden.",
      severity: "error",
      from: {},
      to: { circular: true },
    },
  ],
  options: {
    doNotFollow: { path: "node_modules" },
    tsConfig: { fileName: "tsconfig.json" },
    enhancedResolveOptions: {
      extensions: [".ts", ".tsx", ".js", ".jsx", ".json"],
    },
  },
};
