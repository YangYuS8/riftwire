#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GODOT_BIN="${GODOT_BIN:-godot}"

cd "$ROOT_DIR"
"$ROOT_DIR/tools/bootstrap.sh"

mkdir -p test-results

"$GODOT_BIN" --headless --editor --quit --path .
"$GODOT_BIN" --headless --path . -s addons/gut/gut_cmdln.gd \
  -gconfig=res://.gutconfig.json \
  -gexit
