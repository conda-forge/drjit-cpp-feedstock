#!/bin/bash

set -euxo pipefail

if [[ "${target_platform}" == *ppc64le* ]]; then
  CXXFLAGS="${CXXFLAGS} -DNO_WARN_X86_INTRINSICS"
fi

cmake tests \
  ${CMAKE_ARGS} \
  -G Ninja \
  -B tests/build \
  -DBUILD_SHARED_LIBS=ON \
  -DCMAKE_BUILD_TYPE=Release

cmake --build tests/build --parallel
