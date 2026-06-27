cmake_minimum_required(VERSION 3.10)

option(ENABLE_LLVM "Enable LLVM backend" OFF)
option(ENABLE_CUDA "Enable CUDA backend" OFF)
set(EXPECT_DRJIT_LLVM_MAJOR "" CACHE STRING "Expected Dr.Jit runtime LLVM major")
set(EXPECT_CONSUMER_LLVM_MAJOR "" CACHE STRING "Expected unrelated consumer LLVM major")

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

project(drjit-example LANGUAGES CXX)

enable_testing()

if(EXPECT_CONSUMER_LLVM_MAJOR)
  find_package(LLVM CONFIG REQUIRED)
  if(LLVM_PACKAGE_VERSION)
    string(REGEX MATCH "^[0-9]+" CONSUMER_LLVM_MAJOR "${LLVM_PACKAGE_VERSION}")
  else()
    set(CONSUMER_LLVM_MAJOR "${LLVM_VERSION_MAJOR}")
  endif()
  if(NOT "${CONSUMER_LLVM_MAJOR}" STREQUAL "${EXPECT_CONSUMER_LLVM_MAJOR}")
    message(FATAL_ERROR
      "Expected consumer LLVM ${EXPECT_CONSUMER_LLVM_MAJOR}, found ${LLVM_PACKAGE_VERSION}")
  endif()
endif()

find_package(drjit CONFIG REQUIRED)

add_executable(half_smoke half_smoke.cpp)
target_link_libraries(half_smoke PRIVATE drjit)
add_test(NAME half_smoke COMMAND half_smoke)

add_executable(half half.cpp)
target_link_libraries(half PRIVATE drjit)

if(ENABLE_LLVM)
  add_executable(jit_llvm jit_llvm.cpp)
  target_link_libraries(jit_llvm PRIVATE drjit-core drjit)
  if(EXPECT_DRJIT_LLVM_MAJOR)
    target_compile_definitions(jit_llvm PRIVATE EXPECT_DRJIT_LLVM_MAJOR=${EXPECT_DRJIT_LLVM_MAJOR})
  endif()
  if(EXPECT_CONSUMER_LLVM_MAJOR)
    target_compile_definitions(jit_llvm PRIVATE EXPECT_CONSUMER_LLVM_MAJOR=${EXPECT_CONSUMER_LLVM_MAJOR})
  endif()
  add_test(NAME jit_llvm COMMAND jit_llvm)
endif()

if(ENABLE_CUDA)
  add_executable(jit_cuda jit_cuda.cpp)
  target_link_libraries(jit_cuda PRIVATE drjit-core drjit)
endif()
