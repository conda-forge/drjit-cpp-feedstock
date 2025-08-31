@echo on

if "%cuda_compiler_version%" == "None" (
    set ENABLE_CUDA=OFF
) else (
    set ENABLE_CUDA=ON
)

cmake %SRC_DIR% ^
  %CMAKE_ARGS% ^
  -B build ^
  -DBUILD_SHARED_LIBS=ON ^
  -DDRJIT_ENABLE_CUDA=%ENABLE_CUDA% ^
  -DDRJIT_ENABLE_LLVM=ON ^
  -DDRJIT_ENABLE_PYTHON=OFF ^
  -DDRJIT_ENABLE_TESTS=OFF ^
  -DDRJIT_USE_SYSTEM_NANOBIND=OFF ^
  -DDRJIT_USE_SYSTEM_ROBIN_MAP=ON ^
  -DSKBUILD=OFF
if errorlevel 1 exit 1

cmake --build build --parallel --config Release
if errorlevel 1 exit 1

ctest --test-dir build --output-on-failure --build-config Release
if errorlevel 1 exit 1

cmake --install build --config Release
if errorlevel 1 exit 1
