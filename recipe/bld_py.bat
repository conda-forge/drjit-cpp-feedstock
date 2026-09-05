@echo on

if "%cuda_compiler_version%" == "None" (
    set ENABLE_CUDA=OFF
) else (
    set ENABLE_CUDA=ON
)

set CMAKE_ARGS=%CMAKE_ARGS% -DDRJIT_NATIVE_FLAGS= -DDRJIT_ENABLE_CUDA=%ENABLE_CUDA% -DDRJIT_ENABLE_OPTIX=%ENABLE_CUDA%

%PYTHON% -m pip install . -vv --no-deps --no-build-isolation
if errorlevel 1 exit 1
