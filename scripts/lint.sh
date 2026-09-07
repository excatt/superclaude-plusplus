#!/usr/bin/env bash
# Local equivalent of .github/workflows/ci.yml — run before pushing.
set -uo pipefail
cd "$(dirname "${BASH_SOURCE[0]}")/.." || exit 1
# Shell files to lint (statusline.sh is vendored cc-statusline, linted upstream)
lint_targets=()
for f in scripts/*.sh scripts/lib/*.sh tests/hooks/run.sh; do
  [[ "$f" == scripts/statusline.sh ]] || lint_targets+=("$f")
done
rc=0
if command -v shellcheck >/dev/null 2>&1; then
  echo "▶ shellcheck"; shellcheck -S warning -x "${lint_targets[@]}" || rc=1
else
  echo "▶ shellcheck: not installed (brew install shellcheck) — skipped"
fi
echo "▶ python syntax"; python3 -m py_compile scripts/*.py || rc=1
echo "▶ config-doctor";  bash scripts/config-doctor.sh --quiet || rc=1
echo "▶ hook tests";     bash tests/hooks/run.sh | tail -1 || rc=1
exit $rc
