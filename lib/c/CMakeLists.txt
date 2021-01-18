cmake_minimum_required(VERSION 3.10)

project(adventlib)
include_directories(./include/)

add_library(
    adventlib
    src/algs.c
    src/types.c
    src/io.c
)