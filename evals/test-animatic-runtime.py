"""Public CLI regressions; stub external tools, not retry/cache decisions."""

import json
import os
import shlex
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path


SCRIPT = Path(__file__).resolve().parents[1] / "vendor/mattpocock/upstream/skills/in-progress/animatic/scripts/animatic.mjs"


class RuntimeTest(unittest.TestCase):
    def setUp(self):
        scratch = tempfile.TemporaryDirectory()
        self.addCleanup(scratch.cleanup)
        self.root = Path(scratch.name)
        self.bins = self.root / "bin"
        self.bins.mkdir()
        self.record = self.root / "attempts"
        self.env = {**os.environ, "PATH": str(self.bins) + os.pathsep + os.environ["PATH"],
                    "ANIMATIC_HOME": str(self.root / "cache"), "RECORD": str(self.record), "FAIL_UNTIL": "100"}
        (self.root / "image.png").touch()
        self.storyboard = self.root / "storyboard.json"
        self.storyboard.write_text(json.dumps([{"say": "First sentence. Complete narration.", "image": "image.png"}]))
        self.voice = self.root / "voice.py"
        self.voice.write_text('''import json, os, pathlib, re, sys, wave
record = pathlib.Path(os.environ['RECORD'])
attempts = int(record.read_text()) + 1 if record.exists() else 1
record.write_text(str(attempts))
if sys.argv[1] == 'sapi':
    match = re.search(r"ReadAllText\\('([^']+)'", sys.argv[-1])
    outputs = [job['out'] for job in json.loads(pathlib.Path(match[1]).read_text())]
else:
    outputs = [sys.argv[1] + '.wav']
for output in outputs:
    with wave.open(output, 'wb') as audio:
        audio.setparams((1, 2, 48000, 0, 'NONE', 'not compressed'))
        audio.writeframes(b'\\x00\\x10' * 4800)
sys.exit(1 if attempts <= int(os.environ['FAIL_UNTIL']) else 0)
''')
        ffmpeg = self.bins / "ffmpeg"
        ffmpeg.write_text(f"#!{sys.executable}\nimport shutil, sys\nshutil.copyfile(sys.argv[sys.argv.index('-i') + 1], sys.argv[-1])\n")
        ffmpeg.chmod(0o755)

    def speak(self, *flags):
        return subprocess.run(["node", str(SCRIPT), "speak", str(self.storyboard), *flags],
                              env=self.env, text=True, capture_output=True, timeout=30)

    def assert_failed_without_cached_audio(self, result):
        self.assertNotEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertIn("voice failed 4 times", result.stderr)
        self.assertEqual(self.record.read_text(), "4", "A readable partial take must still be retried")
        self.assertEqual(list((self.root / "build/voice").iterdir()), [], "Failed output must not become cached narration")

    def test_command_failure_discards_partial_take_then_recovers_and_caches_success(self):
        command = f"{shlex.quote(sys.executable)} {shlex.quote(str(self.voice))} {{out}}"
        flags = ("--tts-command", command)
        self.assert_failed_without_cached_audio(self.speak(*flags))
        self.env["FAIL_UNTIL"] = "5"  # First retry fails; the next attempt succeeds.
        result = self.speak(*flags)
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertEqual(self.record.read_text(), "6")
        self.assertEqual(len(list((self.root / "build/voice").glob("*.wav"))), 1)
        self.assertFalse(list((self.root / "build/voice").glob("*.src*")))
        cached = self.speak(*flags)
        self.assertEqual(cached.returncode, 0, cached.stdout + cached.stderr)
        self.assertIn("1 cached", cached.stdout)
        self.assertEqual(self.record.read_text(), "6", "Successful narration should remain reusable")

    def test_sapi_failure_retries_even_when_it_wrote_a_readable_wav(self):
        sapi = self.bins / "powershell.exe"
        sapi.write_text(f"#!{sys.executable}\nimport runpy, sys\nsys.argv[1:1] = ['sapi']\nrunpy.run_path({str(self.voice)!r}, run_name='__main__')\n")
        sapi.chmod(0o755)
        self.assert_failed_without_cached_audio(self.speak("--engine", "sapi"))


class FrameCacheTest(unittest.TestCase):
    def test_linked_asset_edit_revisits_custom_html_but_keeps_self_contained_cache(self):
        with tempfile.TemporaryDirectory() as scratch:
            root = Path(scratch)
            package = root / "cache/node_modules/playwright"
            package.mkdir(parents=True)
            # Execute the real page callbacks against an empty DOM. This fixture
            # records renderer visits/screenshots; it does not render CSS or PNGs.
            (package / "index.js").write_text('''const fs = require('node:fs');
const vm = require('node:vm');
exports.chromium = { launch: async () => ({
  newPage: async () => ({
    on() {}, async setContent() {}, async goto() {}, async close() {},
    async evaluate(fn) {
      return vm.runInNewContext('(' + fn.toString() + ')()', {
        document: { fonts: { ready: Promise.resolve() }, querySelectorAll: () => [], querySelector: () => null }
      });
    },
    async screenshot({path}) {
      fs.writeFileSync(path, 'fixture screenshot');
      fs.appendFileSync(process.env.RECORD, JSON.stringify(path) + '\\n');
    }
  }), async close() {}
}) };
''')
            css = root / "house.css"
            css.write_text("body { background: red; }")
            html = root / "browser.html"
            html.write_text('<!doctype html><link rel="stylesheet" href="./house.css"><body>Frame</body>')
            image = root / "image.png"
            image.write_bytes(b"first image")
            storyboard = root / "storyboard.json"
            storyboard.write_text(json.dumps([{"html": "browser.html", "seconds": 1}, {"image": "image.png", "seconds": 1}]))
            record = root / "screenshots.jsonl"
            env = {**os.environ, "ANIMATIC_HOME": str(root / "cache"), "RECORD": str(record)}

            def render():
                result = subprocess.run(["node", str(SCRIPT), "render", str(storyboard)],
                                        env=env, text=True, capture_output=True, timeout=15)
                self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
                return [Path(json.loads(line)).name for line in record.read_text().splitlines()]

            self.assertCountEqual(render(), ["01.png", "02.png"])
            html_before = html.read_bytes()
            css.write_text("body { background: blue; }")
            self.assertEqual(html.read_bytes(), html_before, "Only the linked asset changed")
            self.assertCountEqual(render(), ["01.png", "02.png", "01.png"],
                                  "Custom HTML must be re-rendered; embedded image bytes may stay cached")
            image.write_bytes(b"revised image")
            self.assertCountEqual(render(), ["01.png", "02.png", "01.png", "01.png", "02.png"])


if __name__ == "__main__":
    unittest.main()
