#!/bin/bash

set -euxo pipefail

if [[ "${target_platform}" == osx-* ]]; then
  # See https://conda-forge.org/docs/maintainer/knowledge_base.html#newer-c-features-with-old-sdk
  CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
fi

# Py3.14 stubgen fix: ensure Optional is defined in drjit/__init__.py
if $PYTHON - <<'PY'; import sys; print(int(sys.version_info >= (3,14))); PY | grep -q 1; then
  INIT="$SRC_DIR/drjit/__init__.py"
  if [ -f "$INIT" ] && ! grep -q "from typing import Optional" "$INIT"; then
    { echo 'from typing import Optional  # added by recipe for Py3.14 stubgen'; cat "$INIT"; } > "$INIT.new" \
      && mv "$INIT.new" "$INIT"
  fi
fi

$PYTHON -m pip install . -vv --no-deps --no-build-isolation
