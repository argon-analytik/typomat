#!/usr/bin/env bash
set -euo pipefail

check() {
  local script="$1"
  local expected="$2"
  local actual

  actual="$(mktemp)"
  perl "$script" < examples/test-text.md > "$actual"
  diff -u "$expected" "$actual"
  rm -f "$actual"
}

check scripts/swiss-diplomat.pl examples/expected-swiss.md
check scripts/german-diplomat.pl examples/expected-german.md
check scripts/german-guillemets-diplomat.pl examples/expected-german-guillemets.md

echo "All Typomat tests passed."
