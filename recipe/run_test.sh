#!/bin/bash

set -euxo pipefail

if [[ "${target_platform}" == *ppc64le* ]]; then
  CXXFLAGS="${CXXFLAGS} -DNO_WARN_X86_INTRINSICS"
fi

if [[ "${target_platform}" == *aarch64 || "${target_platform}" == *ppc64le ]]; then
  ENABLE_LLVM=OFF
else
  ENABLE_LLVM=ON
fi

cmake tests \
  ${CMAKE_ARGS} \
  -G Ninja \
  -B tests/build \
  -DBUILD_SHARED_LIBS=ON \
  -DCMAKE_BUILD_TYPE=Release \
  -DENABLE_LLVM=$ENABLE_LLVM

cmake --build tests/build --parallel
