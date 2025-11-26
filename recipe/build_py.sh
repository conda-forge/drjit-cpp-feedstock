#!/bin/bash

set -euxo pipefail

if [[ "${target_platform}" == osx-* ]]; then
  # See https://conda-forge.org/docs/maintainer/knowledge_base.html#newer-c-features-with-old-sdk
  CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
fi

if [[ "${CONDA_BUILD_CROSS_COMPILATION:-}" == "1" ]]; then
  export CMAKE_ARGS="${CMAKE_ARGS:-} -DDRJIT_ENABLE_STUBS=OFF"
fi

$PYTHON -m pip install . -vv --no-deps --no-build-isolation
