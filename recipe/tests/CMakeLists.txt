cmake_minimum_required(VERSION 3.10)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

project(adaptivecpp-example)

find_package(drjit CONFIG REQUIRED)

add_executable(half half.cpp)
target_link_libraries(half PRIVATE drjit)

add_executable(jit_llvm jit_llvm.cpp)
target_link_libraries(jit_llvm PRIVATE drjit)
