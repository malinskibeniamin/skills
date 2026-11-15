"""Exercise calibration's private workspace through the real CLI, without installing tools."""

import json
import os
import stat
import subprocess
import tempfile
import unittest
from pathlib import Path


SCRIPT = Path(__file__).resolve().parents[1] / "vendor/mattpocock/upstream/skills/in-progress/animatic/scripts/animatic.mjs"


class CalibrationTest(unittest.TestCase):
    def test_private_workspace_and_cleanup_for_both_engines_and_failure(self):
        for engine, fail in (("say", False), ("sapi", False), ("say", True), ("sapi", True)):
            with self.subTest(engine=engine, fail=fail), tempfile.TemporaryDirectory() as scratch:
                root = Path(scratch)
                shared, home, bins = (root / name for name in ("shared", "cache", "bin"))
                for directory in (shared, home, bins):
                    directory.mkdir()
                shared.chmod(0o777)
                executable = root / "chromium"
                executable.touch()
                for name, code in (("shiki", "module.exports = {};"), ("playwright", f"exports.chromium = {{ executablePath: () => {json.dumps(str(executable))} }};")):
                    package = home / "node_modules" / name
                    package.mkdir(parents=True)
                    (package / "index.js").write_text(code)
                fixture = '''#!/usr/bin/env python3
import json, os, pathlib, re, shutil, stat, sys
args = sys.argv[1:]
name = pathlib.Path(sys.argv[0]).name
if args == ['-version']:
    sys.exit(0)
if name == 'ffprobe':
    print('2.5')
elif name == 'ffmpeg':
    shutil.copyfile(args[args.index('-i') + 1], args[-1])
else:
    if name == 'say':
        source = pathlib.Path(args[args.index('-f') + 1])
        outputs = [args[args.index('-o') + 1]]
    else:
        match = re.search(r"ReadAllText\\('([^']+)'", args[-1])
        if not match:
            print('fixture voice')
            sys.exit(0)
        source = pathlib.Path(match[1])
        outputs = [job['out'] for job in json.loads(source.read_text())]
    with open(os.environ['RECORD'], 'a') as log:
        log.write(json.dumps({'dir': str(source.parent), 'mode': stat.S_IMODE(source.parent.stat().st_mode), 'file_mode': stat.S_IMODE(source.stat().st_mode)}) + '\\n')
    if os.environ['FAIL_VOICE'] == '1':
        sys.exit(1)
    for output in outputs:
        pathlib.Path(output).write_bytes(b'fixture audio')
'''
                for name in ("say", "powershell.exe", "powershell", "ffmpeg", "ffprobe"):
                    binary = bins / name
                    binary.write_text(fixture)
                    binary.chmod(0o755)
                record = root / "record.jsonl"
                env = {**os.environ, "PATH": str(bins) + os.pathsep + os.environ["PATH"],
                       "ANIMATIC_HOME": str(home), "TMPDIR": str(shared), "TMP": str(shared), "TEMP": str(shared),
                       "RECORD": str(record), "FAIL_VOICE": "1" if fail else "0"}
                result = subprocess.run(["node", str(SCRIPT), "setup", "--engine", engine, "--voice", "fixture"],
                                        env=env, umask=0, text=True, capture_output=True, timeout=30)
                self.assertEqual(result.returncode == 0, not fail, result.stdout + result.stderr)
                observations = [json.loads(line) for line in record.read_text().splitlines()]
                self.assertTrue(observations)
                for observation in observations:
                    directory = Path(observation["dir"])
                    self.assertEqual(directory.parent, shared, "Calibration must create its own temp directory")
                    self.assertEqual(observation["mode"], stat.S_IRWXU, "Narration must be private even with a shared TMPDIR")
                    self.assertEqual(observation["file_mode"], 0o600, "Narration text and SAPI jobs must be owner-only")
                    self.assertFalse(directory.exists(), "Success and failure must both remove the private workspace")
                self.assertEqual(list(shared.iterdir()), [], "Calibration left files in shared temp storage")


if __name__ == "__main__":
    unittest.main()
