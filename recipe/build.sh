#!/bin/bash

set -euxo pipefail

if [[ "${target_platform}" == osx-* ]]; then
  # See https://conda-forge.org/docs/maintainer/knowledge_base.html#newer-c-features-with-old-sdk
  CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
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
  -DCMAKE_INSTALL_PREFIX=$PREFIX \
  -DCMAKE_PREFIX_PATH=$PREFIX \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_LIBDIR=lib \
  -DDRJIT_ENABLE_JIT=OFF \
  -DDRJIT_ENABLE_AUTODIFF=OFF \
  -DDRJIT_ENABLE_PYTHON=OFF \
  -DDRJIT_ENABLE_TESTS=$DRJIT_ENABLE_TESTS \
  -DDRJIT_USE_SYSTEM_ROBIN_MAP=ON

cmake --build build --parallel

if [[ "${CONDA_BUILD_CROSS_COMPILATION:-}" != "1" ]]; then
  ctest --test-dir build --output-on-failure
fi

cmake --build build --target install
