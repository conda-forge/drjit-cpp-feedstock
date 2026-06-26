#!/bin/bash

set -euxo pipefail

if [[ "${target_platform}" == osx-* ]]; then
  # See https://conda-forge.org/docs/maintainer/knowledge_base.html#newer-c-features-with-old-sdk
  CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
fi

if [[ "${cuda_compiler_version:-None}" != "None" ]]; then
  export CMAKE_ARGS="${CMAKE_ARGS:-} -DDRJIT_ENABLE_CUDA=ON -DDRJIT_ENABLE_OPTIX=ON"
else
  export CMAKE_ARGS="${CMAKE_ARGS:-} -DDRJIT_ENABLE_CUDA=OFF -DDRJIT_ENABLE_OPTIX=OFF"
fi

if [[ "${CONDA_BUILD_CROSS_COMPILATION:-}" == "1" ]]; then
  export CMAKE_ARGS="${CMAKE_ARGS:-} -DDRJIT_ENABLE_STUBS=OFF"
else
  export CMAKE_ARGS="${CMAKE_ARGS:-} -DDRJIT_ENABLE_STUBS=ON"
fi

$PYTHON -m pip install . -vv --no-deps --no-build-isolation
