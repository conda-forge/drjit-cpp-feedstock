#!/bin/bash

set -exo pipefail

if [[ "${target_platform}" == osx-* ]]; then
  # See https://conda-forge.org/docs/maintainer/knowledge_base.html#newer-c-features-with-old-sdk
  CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
fi

if [[ "${target_platform}" == *aarch64 || "${target_platform}" == *ppc64le ]]; then
  ENABLE_LLVM=OFF
else
  ENABLE_LLVM=ON
fi

if [[ ${cuda_compiler_version} != "None" ]]; then
  ENABLE_CUDA=ON
else
  ENABLE_CUDA=OFF
fi

if [[ "${CONDA_BUILD_CROSS_COMPILATION:-}" != "1" ]]; then
  DRJIT_ENABLE_TESTS=ON
else
  DRJIT_ENABLE_TESTS=OFF
fi

cmake $SRC_DIR \
  ${CMAKE_ARGS} \
  -G Ninja \
  -B build \
  -DBUILD_SHARED_LIBS=ON \
  -DCMAKE_BUILD_TYPE=Release \
  -DDRJIT_ENABLE_CUDA=$ENABLE_CUDA \
  -DDRJIT_ENABLE_LLVM=$ENABLE_LLVM \
  -DDRJIT_ENABLE_PYTHON=OFF \
  -DDRJIT_ENABLE_TESTS=$DRJIT_ENABLE_TESTS \
  -DDRJIT_USE_SYSTEM_NANOBIND=OFF \
  -DDRJIT_USE_SYSTEM_ROBIN_MAP=OFF \
  -DSKBUILD=OFF

cmake --build build --parallel

if [[ "${CONDA_BUILD_CROSS_COMPILATION:-}" != "1" || "${CROSSCOMPILING_EMULATOR}" != "" ]]; then
  ctest --test-dir build --output-on-failure
fi

cmake --install build --strip
