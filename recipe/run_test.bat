@echo on

cmake tests ^
  %CMAKE_ARGS% ^
  -B tests/build ^
  -DBUILD_SHARED_LIBS=ON ^
  -DENABLE_LLVM=ON
if errorlevel 1 exit 1

cmake --build tests/build --parallel --config Release
if errorlevel 1 exit 1
