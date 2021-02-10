#pragma once

#include <stdint.h>

typedef struct Slice
{
    void*  ptr;
    size_t length;
} Slice;

Slice sliceOf(void* ptr, const size_t start, const size_t count);