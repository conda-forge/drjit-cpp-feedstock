@echo on

set CMAKE_ARGS=%CMAKE_ARGS% -DDRJIT_NATIVE_FLAGS=

%PYTHON% -m pip install . -vv --no-deps --no-build-isolation
if errorlevel 1 exit 1
