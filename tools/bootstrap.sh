#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
GODOT_BIN="${GODOT_BIN:-godot}"
EXPECTED_VERSION="4.7.1"

cd "$ROOT_DIR"

if ! command -v "$GODOT_BIN" >/dev/null 2>&1; then
  printf 'error: Godot executable not found: %s\n' "$GODOT_BIN" >&2
  printf 'set GODOT_BIN=/path/to/godot when the executable is not named godot.\n' >&2
  exit 1
fi

actual_version="$($GODOT_BIN --version)"
if [[ "$actual_version" != "$EXPECTED_VERSION"* ]]; then
  printf 'error: expected Godot %s, found %s\n' "$EXPECTED_VERSION" "$actual_version" >&2
  exit 1
fi

git submodule update --init --recursive

printf 'Riftwire development environment is ready.\n'
printf 'Godot: %s\n' "$actual_version"
printf 'GUT commit: %s\n' "$(git -C addons/gut rev-parse --short HEAD)"
