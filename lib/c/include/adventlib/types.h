#pragma once

#include <stdint.h>

typedef struct Slice
{
    void*  ptr;
    size_t length;
} Slice;