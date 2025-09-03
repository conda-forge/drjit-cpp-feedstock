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

echo === Verifying installation files ===
REM Check that essential files were installed correctly
if not exist "%PREFIX%\Library\include\drjit\fwd.h" (
    echo ERROR: drjit\fwd.h not found!
    exit 1
)
if not exist "%PREFIX%\Library\include\drjit-core\macros.h" (
    echo ERROR: drjit-core\macros.h not found!
    exit 1
)
if not exist "%PREFIX%\Library\share\cmake\drjit\drjitConfig.cmake" (
    echo ERROR: drjitConfig.cmake not found!
    exit 1
)
echo ✓ All required installation files found

echo === Test binaries built ===
dir tests\build\Release\

echo === Running basic tests ===
REM Run the half precision test
echo Running half precision test...
tests\build\Release\half.exe
if errorlevel 1 exit 1

echo === Running relocatable CMake targets test ===
REM This is the key test that verifies the relocatable targets fix
echo Running test_relocatable_targets (CRITICAL for CMake target relocatability)...
if exist "tests\build\Release\test_relocatable_targets.exe" (
    tests\build\Release\test_relocatable_targets.exe
    if errorlevel 1 exit 1
) else (
    echo ERROR: test_relocatable_targets.exe not found!
    echo Available executables:
    dir tests\build\Release\*.exe
    exit 1
)

if "%ENABLE_LLVM%" == "ON" (
    echo === Running LLVM JIT test ===
    if exist "tests\build\Release\jit_llvm.exe" (
        tests\build\Release\jit_llvm.exe
        if errorlevel 1 exit 1
    ) else (
        echo WARNING: jit_llvm.exe not found (ENABLE_LLVM=%ENABLE_LLVM%)
    )
)

if "%ENABLE_CUDA%" == "ON" (
    echo === Running CUDA JIT test ===
    if exist "tests\build\Release\jit_cuda.exe" (
        tests\build\Release\jit_cuda.exe
        if errorlevel 1 exit 1
    ) else (
        echo WARNING: jit_cuda.exe not found (ENABLE_CUDA=%ENABLE_CUDA%)
    )
)

echo === All tests completed successfully! ===
