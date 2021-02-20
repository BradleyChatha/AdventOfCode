#include <windows.h>
#include <profileapi.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>
#include <adventlib/algs.h>
#include <adventlib/types.h>
#include <adventlib/io.h>
#include <adventlib/entrypoint.h>

bool part1();
bool part2();
bool parseNumbers();
bool sortNumbers();

Slice g_numbers;
size_t g_numbersCursor = 0;

int solve(Slice input)
{
    if(!parseNumbers(input)) return -1;
    if(!sortNumbers()) return -1;
    if(!part1()) return -1;
    if(!part2()) return -1;
    return 0;
}

bool part1()
{
    const int* numbers = (const int*)g_numbers.ptr;
    for(int i = 0; i < g_numbers.length; i++)
    {
        const int currNum = numbers[i];
        if(currNum > 2020)
            continue;

        const int partnerNum = 2020 - currNum;
        void* result = bsearch_s(
            &partnerNum, 
            numbers + (sizeof(int) * i), // So the binary search only includes numbers that we haven't already checked.
            g_numbers.length - i, 
            sizeof(int), 
            &i32Compare, 
            NULL
        );
        
        if(!result)
            continue;

        printf("Part 1: %d\n", currNum * partnerNum);
        return true;
    }

    printf("Part 1 failed to find an answers.\n");
    return false;
}

bool part2()
{
    const int* numbers = (const int*)g_numbers.ptr;
    for(int i = g_numbers.length - 1; i >= 0; i--)
    {
        const int currNum = numbers[i];
        if(currNum > 2020)
            continue;

        for(int j = 0; j < i; j++)
        {
            const int secondNum = numbers[j];
            if(currNum + secondNum > 2020)
                break;

            const int thirdNum = 2020 - (currNum + secondNum);
            void* result = bsearch_s(
                &thirdNum, 
                numbers + (sizeof(int) * j),
                g_numbers.length - i, 
                sizeof(int), 
                &i32Compare, 
                NULL
            );

            if(!result)
                continue;

            printf("Part 2: %d\n", currNum * secondNum * thirdNum);
            return true;
        }
    }

    printf("Part 2 failed to find an answers.\n");
    return false;
}

bool sortNumbers()
{
    qsort_s(
        g_numbers.ptr, g_numbers.length, sizeof(int),
        &i32Compare,
        NULL
    );

    return true;
}

bool addNumberToList(Slice str, void* __)
{
    // Set the new line into a null terminator, ready for atoi.
    ((char*)str.ptr)[str.length] = '\0';
    
    // atoi Uses 0 as an error value, so we'll just special case a genuine 0
    if(str.length == 1 && ((char*)str.ptr)[0] == '0')
    {
        ((int*)g_numbers.ptr)[g_numbersCursor++] = 0;
        return true;
    }

    int result = atoi((char*)str.ptr);
    if(result == 0)
    {
        printf("Conversion failed for: %s\n", (char*)str.ptr);
        return false;
    }

    ((int*)g_numbers.ptr)[g_numbersCursor++] = result;
    return true;
}

bool countNumberOfLines(Slice _, void* __)
{
    g_numbers.length++;
    return true;
}

bool parseNumbers(Slice input)
{
    if(!splitAndApply(input, '\n', NULL, &countNumberOfLines))
        return false;

    g_numbers.ptr = malloc(g_numbers.length * sizeof(int));
    if(!g_numbers.ptr)
    {
        printf("Out of memory.\n");
        return false;
    }

    return splitAndApply(
        input,
        '\n',
        NULL,
        &addNumberToList
    );
}