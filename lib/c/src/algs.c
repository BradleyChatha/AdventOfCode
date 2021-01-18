#include "../include/adventlib/algs.h"

bool splitAndApply(Slice string, char delim, void* context, bool (*func)(Slice value, void* context))
{
    size_t start = 0;
    for(size_t i = 0; i < string.length; i++)
    {
        if(((char*)string.ptr)[i] == delim)
        {
            Slice slice;
            slice.ptr = string.ptr + start;
            slice.length = start - i;

            if(!func(slice, context)) return false;
            start = i;
        }
    }

    if(start < string.length - 1)
    {
        Slice slice;
        slice.ptr = string.ptr + start;
        slice.length = start - string.length;

        func(slice, context);
    }

    return true;
}

int i32Compare(void* _, const void* a, const void* b)
{
    const int ai = *(const int*)a;
    const int bi = *(const int*)b;

    if(ai < bi)
        return -1;
    else if(ai > bi)
        return 1;
    else
        return 0;
}