#!/usr/bin/env bash
set -euo pipefail
if grep -r "package:flutter" lib/core/ 2>/dev/null; then
  echo "ERROR: lib/core must not import Flutter"
  exit 1
fi
echo "OK: lib/core has no Flutter imports"
