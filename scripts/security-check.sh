#!/usr/bin/env bash
set -euo pipefail

swift test

grep -RInE '(sk-[A-Za-z0-9_-]{20,}|gh[pousr]_[A-Za-z0-9_]{20,}|AIza[0-9A-Za-z_-]{20,}|-----BEGIN ((RSA|EC|OPENSSH) )?PRIVATE KEY-----)' \
  --exclude-dir=.git \
  --exclude-dir=.build \
  --exclude=repo-hygiene.yml \
  . && {
    echo "Potential secret detected."
    exit 1
  }

test -d tests/security/prompt-injection-fixtures
test "$(find tests/security/prompt-injection-fixtures -name '*.eml' -o -name '*.txt' | wc -l)" -gt 0

echo "Security checks passed."
