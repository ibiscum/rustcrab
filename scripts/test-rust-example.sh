#!/usr/bin/env bash

set -euo pipefail

if [[ $# -lt 2 ]]; then
  echo "Usage: scripts/test-rust-example.sh <chapter> <project> [-- <cargo test args...>]"
  echo "Example: scripts/test-rust-example.sh chapter-2 arrays"
  exit 1
fi

chapter="$1"
project="$2"
shift 2

sanitize() {
  printf '%s' "$1" \
    | tr '[:upper:]' '[:lower:]' \
    | sed -E 's/[^a-z0-9]+/_/g; s/_+/_/g; s/^_+//; s/_+$//'
}

chapter_s="$(sanitize "$chapter")"
project_s="$(sanitize "$project")"

if [[ -z "$chapter_s" || -z "$project_s" ]]; then
  echo "Error: chapter and project must contain at least one alphanumeric character."
  exit 1
fi

pkg="${chapter_s}_${project_s}"
member_path="book-compendium/${chapter}/${project}"

if [[ ! -f "${member_path}/Cargo.toml" ]]; then
  echo "Error: workspace member not found at ${member_path}"
  exit 1
fi

if [[ $# -gt 0 && "$1" == "--" ]]; then
  shift
fi

cargo test -p "$pkg" "$@"
