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

if [[ ${cuda_compiler_version} != "None" ]]; then
  ENABLE_CUDA=ON
else
  ENABLE_CUDA=OFF
fi

EXTRA_CMAKE_ARGS=""
if [[ "${target_platform}" == "linux-64" && "${cuda_compiler_version}" == "None" ]]; then
  EXTRA_CMAKE_ARGS="-DEXPECT_CONSUMER_LLVM_MAJOR=20"
fi

cmake tests \
  ${CMAKE_ARGS} \
  -G Ninja \
  -B tests/build \
  -DBUILD_SHARED_LIBS=ON \
  -DCMAKE_BUILD_TYPE=Release \
  -DENABLE_LLVM=$ENABLE_LLVM \
  -DENABLE_CUDA=$ENABLE_CUDA \
  ${EXTRA_CMAKE_ARGS}

cmake --build tests/build --parallel

export LD_LIBRARY_PATH="${PREFIX}/lib:${LD_LIBRARY_PATH:-}"
export DYLD_FALLBACK_LIBRARY_PATH="${PREFIX}/lib:${DYLD_FALLBACK_LIBRARY_PATH:-}"
ctest --test-dir tests/build --output-on-failure
