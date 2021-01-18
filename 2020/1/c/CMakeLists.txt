cmake_minimum_required(VERSION 3.10)

project(solution)

include_directories(../../../lib/c/include/)
add_subdirectory(../../../lib/c/ ./build/)

add_executable(solution src/app.c)
target_link_libraries(solution adventlib)