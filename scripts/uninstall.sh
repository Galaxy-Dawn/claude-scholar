#!/usr/bin/env bash
set -euo pipefail
if [[ $# -eq 1 && $1 == /* ]] && command -v cygpath >/dev/null; then
  set -- "$(cygpath -w "$1")"
fi
exec node "$(dirname "$0")/install.cjs" uninstall "$@"
