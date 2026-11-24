#!/usr/bin/env bash
set -euo pipefail
if command -v cygpath >/dev/null; then
  if [[ ${OPENCODE_DIR:-} == /* ]]; then export OPENCODE_DIR="$(cygpath -w "$OPENCODE_DIR")"; fi
  if [[ ${OPENCODE_CONFIG_DIR:-} == /* ]]; then export OPENCODE_CONFIG_DIR="$(cygpath -w "$OPENCODE_CONFIG_DIR")"; fi
  if [[ ${XDG_CONFIG_HOME:-} == /* ]]; then export XDG_CONFIG_HOME="$(cygpath -w "$XDG_CONFIG_HOME")"; fi
fi
exec node "$(dirname "$0")/install.cjs" install
