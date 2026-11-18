class BaoCli < Formula
  desc "Local wiki and repository navigation for the skills harness"
  homepage "https://github.com/malinskibeniamin/skills/tree/main/packages/bao"
  # Pin just the three bundled inputs, not the full skills and docs archive.
  url "https://raw.githubusercontent.com/malinskibeniamin/skills/45e0c99d2198d2c7d600c028d2b2f51c09b4ac71/packages/bao/src/cli.ts"
  version "0.1.0"
  sha256 "ab6a409f65f502462c6890d2f71936efb5a4b863d2bd35077b8f253661fdce86"
  license "MIT"

  depends_on "bun"

  conflicts_with "bao", because: "both install a bao executable"
  conflicts_with "openbao", because: "both install a bao executable"

  resource "doctor" do
    url "https://raw.githubusercontent.com/malinskibeniamin/skills/45e0c99d2198d2c7d600c028d2b2f51c09b4ac71/packages/bao/src/doctor.ts"
    sha256 "37925b02c9511eaffc807769783c437713f9953d36c8dc8c7730a3a4ae88a151"
  end

  resource "wiki" do
    url "https://raw.githubusercontent.com/malinskibeniamin/skills/45e0c99d2198d2c7d600c028d2b2f51c09b4ac71/wiki/scripts/wiki.ts"
    sha256 "b796fbbeac2ce1dcecb6add0f823a63ac9d3578ed10f437228eee441f061677f"
  end

  def install
    (buildpath/"packages/bao/src").install "cli.ts"
    (buildpath/"packages/bao/src").install resource("doctor")
    (buildpath/"wiki/scripts").install resource("wiki")

    bun = Formula["bun"].opt_bin/"bun"
    system bun, "build", "packages/bao/src/cli.ts", "--target=bun", "--outfile=bao.js"
    libexec.install "bao.js"
    (bin/"bao").write_env_script bun, [%("#{libexec}/bao.js")], {}
  end

  test do
    assert_match "Usage: bao", shell_output("#{bin}/bao --help")
    system bin/"bao", "wiki", "--home", "home", "init"
    (testpath/"note.md").write "Packaged wiki smoke test."
    system bin/"bao", "wiki", "--home", "home", "ingest", "smoke",
                      "--title", "Smoke test", "--source", "Formula test", "--file", "note.md"
    assert_match "Packaged wiki smoke test.", shell_output("#{bin}/bao wiki --home home search packaged")
    system bin/"bao", "repo", "--home", "home", "add", "app",
                      "--path", testpath, "--summary", "Formula test checkout"
    assert_match "Formula test checkout", shell_output("#{bin}/bao repo --home home list")
  end
end
