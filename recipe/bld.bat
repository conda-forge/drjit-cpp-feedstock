@echo on

cmake %SRC_DIR% ^
  -B build ^
  -DCMAKE_INSTALL_PREFIX=%LIBRARY_PREFIX% ^
  -DCMAKE_PREFIX_PATH=%LIBRARY_PREFIX% ^
  -DDRJIT_ENABLE_AUTODIFF=OFF ^
  -DDRJIT_ENABLE_CUDA=OFF ^
  -DDRJIT_ENABLE_LLVM=OFF ^
  -DDRJIT_ENABLE_PYTHON=OFF ^
  -DDRJIT_ENABLE_TESTS=OFF ^
  -DDRJIT_USE_SYSTEM_NANOBIND=OFF ^
  -DDRJIT_USE_SYSTEM_ROBIN_MAP=ON ^
  -DSKBUILD=OFF

cmake --build build --parallel --config Release

ctest --test-dir build --output-on-failure --build-config Release

cmake --install build --config Release
