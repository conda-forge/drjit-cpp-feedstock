#!/bin/bash

set -euxo pipefail

if [[ "${target_platform}" == osx-* ]]; then
  # See https://conda-forge.org/docs/maintainer/knowledge_base.html#newer-c-features-with-old-sdk
  CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
fi

# Py3.14 stubgen fix: ensure typing.Optional exists in drjit after import
if $PYTHON - <<'PY'; import sys; print(int(sys.version_info >= (3,14))); PY | grep -q 1; then
  INIT="$SRC_DIR/drjit/__init__.py"
  if [ -f "$INIT" ]; then
    # Re-introduce Optional *after* any 'del overload, Optional'
    printf '\n# conda-forge: restore Optional for Py3.14 stubgen\nfrom typing import Optional as _cf_Optional\nOptional = _cf_Optional\n' >> "$INIT"
  fi
fi

$PYTHON -m pip install . -vv --no-deps --no-build-isolation
