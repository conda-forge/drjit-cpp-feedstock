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

echo "=== CMake Configuration Phase ==="
echo "CMAKE_ARGS: ${CMAKE_ARGS}"
echo "ENABLE_LLVM: ${ENABLE_LLVM}"
echo "ENABLE_CUDA: ${ENABLE_CUDA}"
echo "PREFIX: ${PREFIX}"

# Show what drjit files are available before cmake
echo "=== Available drjit files before cmake ==="
find $PREFIX -name "*drjit*" -type f | head -20

echo "=== Running cmake configuration ==="
cmake tests \
  ${CMAKE_ARGS} \
  -G Ninja \
  -B tests/build \
  -DBUILD_SHARED_LIBS=ON \
  -DCMAKE_BUILD_TYPE=Release \
  -DENABLE_LLVM=$ENABLE_LLVM \
  -DENABLE_CUDA=$ENABLE_CUDA || {
    echo "ERROR: CMake configuration failed!"
    echo "=== CMake Error Details ==="
    cat tests/build/CMakeFiles/CMakeError.log 2>/dev/null || echo "No CMakeError.log found"
    cat tests/build/CMakeFiles/CMakeOutput.log 2>/dev/null || echo "No CMakeOutput.log found"
    exit 1
}

echo "=== CMake build phase ==="
cmake --build tests/build --parallel || {
    echo "ERROR: CMake build failed!"
    exit 1
}

echo "=== Verifying installation files ==="
# Check that essential files were installed correctly
test -f $PREFIX/include/drjit/fwd.h || { echo "ERROR: drjit/fwd.h not found!"; exit 1; }
test -f $PREFIX/include/drjit-core/macros.h || { echo "ERROR: drjit-core/macros.h not found!"; exit 1; }
test -f $PREFIX/share/cmake/drjit/drjitConfig.cmake || { echo "ERROR: drjitConfig.cmake not found!"; exit 1; }
echo "✓ All required installation files found"

echo "=== Test binaries built ==="
ls -la tests/build/

echo "=== Running basic tests ==="
# Run the half precision test
echo "Running half precision test..."
./tests/build/half

echo "=== Running relocatable CMake targets test ==="
# This is the key test that verifies the relocatable targets fix
echo "Running test_relocatable_targets (CRITICAL for CMake target relocatability)..."
if [[ -f "./tests/build/test_relocatable_targets" ]]; then
    ./tests/build/test_relocatable_targets
else
    echo "ERROR: test_relocatable_targets executable not found!"
    echo "Available executables:"
    find tests/build -type f -executable
    exit 1
fi

if [[ "$ENABLE_LLVM" == "ON" ]]; then
    echo "=== Running LLVM JIT test ==="
    if [[ -f "./tests/build/jit_llvm" ]]; then
        ./tests/build/jit_llvm
    else
        echo "WARNING: jit_llvm executable not found (ENABLE_LLVM=$ENABLE_LLVM)"
    fi
fi

if [[ "$ENABLE_CUDA" == "ON" ]]; then
    echo "=== Running CUDA JIT test ==="
    if [[ -f "./tests/build/jit_cuda" ]]; then
        ./tests/build/jit_cuda
    else
        echo "WARNING: jit_cuda executable not found (ENABLE_CUDA=$ENABLE_CUDA)"
    fi
fi

echo "=== All tests completed successfully! ==="
