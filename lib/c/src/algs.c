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
            slice.length = i - start;

            // Special case: If the file uses Windows' version of new lines, then we'll cut it out.
            if(delim == '\n' && i > 0 && ((char*)string.ptr)[i-1] == '\r')
                slice.length--;

            if(!func(slice, context)) return false;
            start = i + 1;
        }
    }

    if(start < string.length - 1)
    {
        Slice slice;
        slice.ptr = string.ptr + start;
        slice.length = string.length - start;

        return func(slice, context);
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