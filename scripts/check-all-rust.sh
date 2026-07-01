#!/usr/bin/env bash

set -euo pipefail

run_clippy=true
declare -a excludes=()

usage() {
  echo "Usage: scripts/check-all-rust.sh [--no-clippy] [--exclude <package>]..."
  echo "Example: scripts/check-all-rust.sh --exclude chapter_13_11_tokio_basics"
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --no-clippy)
      run_clippy=false
      shift
      ;;
    --exclude)
      if [[ $# -lt 2 ]]; then
        echo "Error: --exclude requires a package name."
        usage
        exit 1
      fi
      excludes+=("$2")
      shift 2
      ;;
    --exclude=*)
      excludes+=("${1#*=}")
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Error: unknown argument '$1'"
      usage
      exit 1
      ;;
  esac
done

if ! command -v jq >/dev/null 2>&1; then
  echo "Error: jq is required by scripts/check-all-rust.sh"
  exit 1
fi

mapfile -t packages < <(cargo metadata --no-deps --format-version 1 | jq -r '.packages[].name' | sort)

if [[ ${#packages[@]} -eq 0 ]]; then
  echo "No Rust workspace packages found."
  exit 0
fi

is_excluded() {
  local pkg="$1"
  local ex
  for ex in "${excludes[@]}"; do
    if [[ "$pkg" == "$ex" ]]; then
      return 0
    fi
  done
  return 1
}

declare -a checked_ok=()
declare -a check_fail=()

echo "==> cargo check per package"
for pkg in "${packages[@]}"; do
  if is_excluded "$pkg"; then
    echo "[skip] $pkg (excluded)"
    continue
  fi

  echo "[check] $pkg"
  if cargo check -p "$pkg" >/dev/null; then
    checked_ok+=("$pkg")
  else
    check_fail+=("$pkg")
  fi
done

declare -a clippy_fail=()

if [[ "$run_clippy" == true ]]; then
  if cargo clippy --version >/dev/null 2>&1; then
    echo "==> cargo clippy per package"
    for pkg in "${checked_ok[@]}"; do
      echo "[clippy] $pkg"
      if ! cargo clippy -p "$pkg" --all-targets >/dev/null; then
        clippy_fail+=("$pkg")
      fi
    done
  else
    echo "Skipping clippy: rustup component 'clippy' is not installed."
    echo "Install with: rustup component add clippy"
  fi
fi

echo
echo "Summary"
echo "Checked packages OK: ${#checked_ok[@]}"
echo "Check failures: ${#check_fail[@]}"
echo "Clippy failures: ${#clippy_fail[@]}"

if [[ ${#check_fail[@]} -gt 0 ]]; then
  echo "Packages failing cargo check:"
  printf '%s\n' "${check_fail[@]}"
fi

if [[ ${#clippy_fail[@]} -gt 0 ]]; then
  echo "Packages failing cargo clippy:"
  printf '%s\n' "${clippy_fail[@]}"
fi

if [[ ${#check_fail[@]} -gt 0 || ${#clippy_fail[@]} -gt 0 ]]; then
  exit 1
fi
