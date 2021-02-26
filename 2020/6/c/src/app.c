#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>
#include <intrin.h>
#include <adventlib/algs.h>
#include <adventlib/types.h>
#include <adventlib/io.h>
#include <adventlib/entrypoint.h>

#define MAX_PEOPLE_PER_SET 20

int32_t g_part1;
int32_t g_part2;

void printAnswers()
{
    printf("Part 1: %d\nPart 2: %d\n", g_part1, g_part2);
}

int solve(Slice input)
{
    input.ptr = realloc(input.ptr, input.length);
    if(input.ptr == NULL)
        return -1;

    ((char*)input.ptr)[input.length] = '\n';
    ((char*)input.ptr)[input.length + 1] = '\n';
    input.length += 2; 

    int32_t part1Set = 0;
    int32_t part2Set = 0;
    int32_t part2SetList[MAX_PEOPLE_PER_SET] = {};
    int32_t part2SetCount = 0;
    bool wasLastCharANewLine = FALSE;

    for(size_t i = 0; i < input.length; i++)
    {
        const char ch = ((const char*)input.ptr)[i];

        if(ch == '\n')
        {
            if(wasLastCharANewLine)
            {
                int32_t mask = 0xFFFFFFFF;
                for(int setListI = 0; setListI < part2SetCount; setListI++)
                    mask &= part2SetList[setListI];
                g_part1 += __popcntd(part1Set);
                g_part2 += __popcntd(mask);

                wasLastCharANewLine = FALSE;
                part1Set = 0;
                part2SetCount = 0;
                continue;
            }
            
            wasLastCharANewLine = TRUE;
            part2SetList[part2SetCount++] = part2Set;
            part2Set = 0;
            continue;
        }

        const int32_t charAsBitmask = 1 << (ch - 'a');
        part1Set |= charAsBitmask;
        part2Set |= charAsBitmask;
        wasLastCharANewLine = FALSE;
    }

    return 0;
}