cmake_minimum_required(VERSION 3.10)

project(solution)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED true)

include_directories(../../../lib/cpp/include/)
add_executable(solution src/app.cpp)