#pragma once

#include <windows.h>
#include <profileapi.h>
#include <stdio.h>
#include <stdlib.h>
#include "types.h"
#include "io.h"

Slice g_input1;
Slice g_input2;

int solve(Slice input);
void printAnswers();

int main(void)
{
    if(!loadFileAsSlice("../../input1.txt", &g_input1)) return -1;
    if(!loadFileAsSlice("../../input2.txt", &g_input2)) return -1;
    
    LARGE_INTEGER before, after;

    if(!QueryPerformanceCounter(&before)) return -1;
    int result = solve(g_input1);
    if(!QueryPerformanceCounter(&after)) return -1;
    
    printAnswers();
    printf("Time: %lld us\n", after.QuadPart - before.QuadPart);
}