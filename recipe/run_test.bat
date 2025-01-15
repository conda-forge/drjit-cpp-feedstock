@echo on

cmake tests ^
  %CMAKE_ARGS% ^
  -B tests/build ^
  -DBUILD_SHARED_LIBS=ON
if errorlevel 1 exit 1

cmake --build build --parallel --config Release
if errorlevel 1 exit 1
