#!/usr/bin/env bash
set -euo pipefail

ROOT=$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
python3 - "$ROOT" <<'PY'
from __future__ import annotations

import ast
import sys
from pathlib import Path

root = Path(sys.argv[1])
excluded = {'.git', 'node_modules', 'dist', 'build', 'coverage', '__pycache__'}
count = 0
for path in sorted(root.rglob('*.py')):
    rel = path.relative_to(root)
    if any(part in excluded for part in rel.parts):
        continue
    ast.parse(path.read_text(encoding='utf-8'), filename=str(rel))
    count += 1
print(f'check-python-syntax: clean ({count} file(s))')
PY
