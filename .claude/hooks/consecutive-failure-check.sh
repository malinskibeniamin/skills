#!/bin/bash
# PostToolUse observes success; PostToolUseFailure owns failure advisories.
# Keep the existing registration while sharing parsing and reset state.
exec bash "$(dirname "$0")/post-tool-failure.sh" --success-only
