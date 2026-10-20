#!/bin/sh
# Installs the pinned Bend release into $BEND_HOME (default ~/.bend) after
# verifying its sha256. bend-lang.com/install.sh always serves the latest
# release; pinning keeps proofs from breaking on an upstream bump. To upgrade,
# copy VER and the four sums from that release's notes, then rerun laws/check.sh.
# BEND_MIRROR points at a release mirror for networks that cannot reach GitHub.
set -eu

VER="2.0.37"
SHA_DARWIN_ARM64="846d25ccf0c12d5d1e5e648c0b3ba4c8397fdb852812ac00ef8135998f8e194b"
SHA_DARWIN_X64="93eea3f54b7b91f28ea15a1b9f2d825afa58c1fcd417c11024a62f8c3506b813"
SHA_LINUX_ARM64="b65d452e5c68a4c486e353220d4298ba5d76f535db47109a7d76ffdf72efafb1"
SHA_LINUX_X64="84c32465a39bc9ac315eade23f470cb8db03153dc860f89564fcfec153c3e445"

case "$(uname -s)-$(uname -m)" in
  Darwin-arm64) target=darwin-arm64 sum=$SHA_DARWIN_ARM64 ;;
  Darwin-x86_64) target=darwin-x64 sum=$SHA_DARWIN_X64 ;;
  Linux-aarch64 | Linux-arm64) target=linux-arm64 sum=$SHA_LINUX_ARM64 ;;
  Linux-x86_64) target=linux-x64 sum=$SHA_LINUX_X64 ;;
  *) echo "bend: unsupported platform $(uname -s)-$(uname -m)" >&2; exit 1 ;;
esac

home=${BEND_HOME:-$HOME/.bend}
if [ -x "$home/bin/bend" ] && "$home/bin/bend" version 2>/dev/null | grep -qF "$VER"; then
  echo "bend $VER already installed at $home"
  exit 0
fi

name="bend-$VER-$target.tar.gz"
mirror=${BEND_MIRROR:-https://github.com/bendlang/bend/releases/download}
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
curl --proto '=https,file' --tlsv1.2 -fsSL --retry 3 -o "$tmp/$name" "$mirror/v$VER/$name"
if command -v sha256sum >/dev/null 2>&1; then
  actual=$(sha256sum "$tmp/$name" | cut -d' ' -f1)
else
  actual=$(shasum -a 256 "$tmp/$name" | cut -d' ' -f1)
fi
if [ "$actual" != "$sum" ]; then
  echo "bend: $name sha256 is $actual, expected $sum; not installed" >&2
  exit 1
fi
# The release is packed on macOS; GNU tar warns about its Apple xattr headers.
if tar --version 2>/dev/null | grep -q 'GNU tar'; then
  tar --warning=no-unknown-keyword -xzf "$tmp/$name" -C "$tmp"
else
  tar -xzf "$tmp/$name" -C "$tmp"
fi
mkdir -p "$home/bin"
rm -rf "$home/bend2" "$home/guide"
mv "$tmp/bend/bend2" "$tmp/bend/guide" "$home/"
# The binary goes last: until it reports $VER, a rerun repairs a partial install.
mv -f "$tmp/bend/bin/bend" "$home/bin/bend"
echo "installed bend $VER at $home/bin/bend"
