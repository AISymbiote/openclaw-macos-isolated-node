#!/usr/bin/env bash
set -euo pipefail

SERVICE_USER="${SERVICE_USER:-svc_openclaw}"
SERVICE_HOME="${SERVICE_HOME:-/Users/${SERVICE_USER}}"
OPENCLAW_BIN="${OPENCLAW_BIN:-${SERVICE_HOME}/.local/npm/bin/openclaw}"

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <openclaw-subcommand...>"
  echo "Example: $0 channels status --probe"
  exit 2
fi

if [[ ! -x "${OPENCLAW_BIN}" ]]; then
  echo "[FAIL] openclaw binary not found: ${OPENCLAW_BIN}"
  exit 1
fi

# Run from service home to avoid uv_cwd EACCES when caller's cwd is not readable by service user.
exec sudo -u "${SERVICE_USER}" zsh -lc "cd '${SERVICE_HOME}' && export HOME='${SERVICE_HOME}' PATH='${SERVICE_HOME}/.local/npm/bin:'\$PATH; '${OPENCLAW_BIN}' \"\$@\"" -- "$@"
