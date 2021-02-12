#include <windows.h>
#include <profileapi.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>
#include <adventlib/algs.h>
#include <adventlib/types.h>
#include <adventlib/io.h>

Slice g_input1;
Slice g_input2;

int solve();

int main()
{
    if(!loadFileAsSlice("../../input1.txt", &g_input1)) return -1;
    if(!loadFileAsSlice("../../input2.txt", &g_input2)) return -1;
    
    LARGE_INTEGER before, after;

    if(!QueryPerformanceCounter(&before)) return -1;
    int result = solve();
    if(!QueryPerformanceCounter(&after)) return -1;

    printf("Time: %lld us\n", after.QuadPart - before.QuadPart);
}

int solve()
{
    return 0;
}