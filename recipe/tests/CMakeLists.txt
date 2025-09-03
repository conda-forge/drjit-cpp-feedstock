cmake_minimum_required(VERSION 3.10)

option(ENABLE_LLVM "Enable LLVM backend" OFF)
option(ENABLE_CUDA "Enable CUDA backend" OFF)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

project(drjit-example)

find_package(drjit CONFIG REQUIRED)

add_executable(half half.cpp)
target_link_libraries(half PRIVATE drjit)

# Test relocatable CMake targets - this is the key test to verify the fix
# for hardcoded paths in drjit-core target
add_executable(test_relocatable_targets test_relocatable_targets.cpp)
target_link_libraries(test_relocatable_targets PRIVATE drjit)

# Always try to link drjit-core if it exists - this is the critical test
if(TARGET drjit-core)
  target_link_libraries(test_relocatable_targets PRIVATE drjit-core)
  message(STATUS "DrJit relocatable test: Found drjit-core target, linking...")

  # Enable LLVM backend by default if drjit-core exists
  target_compile_definitions(test_relocatable_targets PRIVATE DRJIT_ENABLE_LLVM)

  # Check for CUDA if enabled
  if(ENABLE_CUDA)
    target_compile_definitions(test_relocatable_targets PRIVATE DRJIT_ENABLE_CUDA)
  endif()
else()
  message(WARNING "DrJit relocatable test: drjit-core target not found! Test may not fully validate relocatable behavior.")
endif()

# Add debug information
message(STATUS "DrJit relocatable test configuration:")
message(STATUS "  - ENABLE_LLVM: ${ENABLE_LLVM}")
message(STATUS "  - ENABLE_CUDA: ${ENABLE_CUDA}")
message(STATUS "  - drjit-core target exists: ${TARGET drjit-core}")

if(ENABLE_LLVM)
  add_executable(jit_llvm jit_llvm.cpp)
  target_link_libraries(jit_llvm PRIVATE drjit-core drjit)
endif()

if(ENABLE_CUDA)
  add_executable(jit_cuda jit_cuda.cpp)
  target_link_libraries(jit_cuda PRIVATE drjit-core drjit)
endif()
