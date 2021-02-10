#include "../include/adventlib/types.h"

Slice sliceOf(void* ptr, const size_t start, const size_t count)
{
    Slice s;
    s.ptr = ptr + start;
    s.length = count;

    return s;
}