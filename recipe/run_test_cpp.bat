@echo on

if "%cuda_compiler_version%" == "None" (
    set ENABLE_CUDA=OFF
) else (
    set ENABLE_CUDA=ON
)

cmake tests ^
  %CMAKE_ARGS% ^
  -B tests/build ^
  -DBUILD_SHARED_LIBS=ON ^
  -DENABLE_LLVM=ON ^
  -DENABLE_CUDA=%ENABLE_CUDA% ^
if errorlevel 1 exit 1

cmake --build tests/build --parallel --config Release
if errorlevel 1 exit 1
