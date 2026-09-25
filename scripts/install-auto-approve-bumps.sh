#!/bin/sh
set -eu

# Bundle scripts/auto-approve-bumps.ts into ~/.local/libexec and run it every
# 2 minutes as a LaunchAgent, so it survives worktree cleanup. Rerun after
# changing the script; pass --uninstall to remove it.

label="com.malinskibeniamin.auto-approve-bumps"
plist="$HOME/Library/LaunchAgents/$label.plist"
bundle="$HOME/.local/libexec/auto-approve-bumps.js"
log="$HOME/Library/Logs/auto-approve-bumps.log"
domain="gui/$(id -u)"

launchctl bootout "$domain/$label" 2>/dev/null || true

if [ "${1:-}" = "--uninstall" ]; then
	rm -f "$plist" "$bundle"
	echo "Removed $label"
	exit 0
fi

bun_bin=$(command -v bun)
gh_dir=$(dirname "$(command -v gh)")
root=$(cd "$(dirname "$0")/.." && pwd)

mkdir -p "$(dirname "$bundle")" "$(dirname "$plist")" "$(dirname "$log")"
"$bun_bin" build "$root/scripts/auto-approve-bumps.ts" --target=bun --outfile "$bundle" >/dev/null

cat >"$plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
	<key>Label</key><string>$label</string>
	<key>ProgramArguments</key>
	<array>
		<string>$bun_bin</string>
		<string>$bundle</string>
		<string>--approve</string>
	</array>
	<key>EnvironmentVariables</key>
	<dict><key>PATH</key><string>$gh_dir:/usr/bin:/bin</string></dict>
	<key>StartInterval</key><integer>120</integer>
	<key>RunAtLoad</key><true/>
	<key>StandardOutPath</key><string>$log</string>
	<key>StandardErrorPath</key><string>$log</string>
</dict>
</plist>
EOF

launchctl bootstrap "$domain" "$plist"
echo "Installed $label; log: $log"
