#!/bin/bash

set -euxo pipefail

if [[ "${target_platform}" == osx-* ]]; then
  # See https://conda-forge.org/docs/maintainer/knowledge_base.html#newer-c-features-with-old-sdk
  CXXFLAGS="${CXXFLAGS} -D_LIBCPP_DISABLE_AVAILABILITY"
fi

if [[ "${CONDA_BUILD_CROSS_COMPILATION:-}" != "1" ]]; then
  skbuild=OFF
else
  skbuild=ON
fi

cmake $SRC_DIR \
  ${CMAKE_ARGS} \
  -G Ninja \
  -B build \
  -DCMAKE_INSTALL_PREFIX=$PREFIX \
  -DCMAKE_PREFIX_PATH=$PREFIX \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_LIBDIR=lib \
  -DDRJIT_ENABLE_AUTODIFF=OFF \
  -DDRJIT_ENABLE_CUDA=OFF \
  -DDRJIT_ENABLE_LLVM=OFF \
  -DDRJIT_ENABLE_PYTHON=OFF \
  -DDRJIT_ENABLE_TESTS=OFF \
  -DDRJIT_USE_SYSTEM_NANOBIND=OFF \
  -DDRJIT_USE_SYSTEM_ROBIN_MAP=ON \
  -DSKBUILD=$skbuild

cmake --build build --parallel

if [[ "${CONDA_BUILD_CROSS_COMPILATION:-}" != "1" ]]; then
  ctest --test-dir build --output-on-failure
fi

cmake --install build
