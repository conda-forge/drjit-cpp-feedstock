#!/bin/bash

set -euxo pipefail

if [[ "${target_platform}" == osx-* ]]; then
  # See https://conda-forge.org/docs/maintainer/knowledge_base.html#newer-c-features-with-old-sdk
  CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
  # Dr.Jit 1.4.0's Metal backend needs macOS 15 APIs. Enable it only on osx-arm64,
  # where the recipe raises the SDK and deployment target for Apple Silicon GPUs.
  if [[ "${target_platform}" == "osx-arm64" ]]; then
    export CMAKE_ARGS="${CMAKE_ARGS:-} -DDRJIT_ENABLE_METAL=ON"
  else
    export CMAKE_ARGS="${CMAKE_ARGS:-} -DDRJIT_ENABLE_METAL=OFF"
  fi
fi

if [[ "${cuda_compiler_version:-None}" != "None" ]]; then
  export CMAKE_ARGS="${CMAKE_ARGS:-} -DDRJIT_ENABLE_CUDA=ON -DDRJIT_ENABLE_OPTIX=ON"
else
  export CMAKE_ARGS="${CMAKE_ARGS:-} -DDRJIT_ENABLE_CUDA=OFF -DDRJIT_ENABLE_OPTIX=OFF"
fi

export CMAKE_ARGS="${CMAKE_ARGS:-} -DDRJIT_NATIVE_FLAGS= -DDRJIT_DYNAMIC_LLVM=OFF"

if [[ "${CONDA_BUILD_CROSS_COMPILATION:-}" == "1" ]]; then
  export CMAKE_ARGS="${CMAKE_ARGS:-} -DDRJIT_ENABLE_STUBS=OFF"
else
  export CMAKE_ARGS="${CMAKE_ARGS:-} -DDRJIT_ENABLE_STUBS=ON"
fi

$PYTHON -m pip install . -vv --no-deps --no-build-isolation
