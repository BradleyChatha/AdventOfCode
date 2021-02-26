#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>
#include <adventlib/algs.h>
#include <adventlib/types.h>
#include <adventlib/io.h>
#include <adventlib/entrypoint.h>

#define ROW_MAX 128
#define COL_MAX 8
#define NON_FULL_BYTES_TO_SKIP 3

size_t g_part1Answer;
size_t g_part2Answer;

void printAnswers()
{
    printf("Part 1: %lld\nPart 2: %lld\n", g_part1Answer, g_part2Answer);
}

inline int toIndex(const int row, const int col)
{
    return (row * COL_MAX) + col;
}

int solve(Slice input)
{
    uint8_t seatMask[ROW_MAX] = {};
    
    int rowVector[2] = {0, ROW_MAX};
    int colVector[2] = {0, COL_MAX};

    for(size_t charIndex = 0; charIndex < input.length; charIndex++)
    {
        const char ch = ((const char*)input.ptr)[charIndex];
        const int rowDiff = rowVector[1] - rowVector[0];
        const int colDiff = colVector[1] - colVector[0];

        switch(ch)
        {
            case 'F': rowVector[1] -= rowDiff / 2; break;
            case 'B': rowVector[0] += rowDiff / 2; break;
            case 'R': colVector[0] += colDiff / 2; break;
            case 'L': colVector[1] -= colDiff / 2; break;
            case '\n':
                const int index = toIndex(rowVector[0], colVector[0]);
                if(index > g_part1Answer)
                    g_part1Answer = index;

                seatMask[rowVector[0]] |= (1 << colVector[0]);

                rowVector[0] = 0;
                rowVector[1] = ROW_MAX;
                colVector[0] = 0;
                colVector[1] = COL_MAX;
                break;

            default: abort();
        }
    }

    int foundCount = 0;
    for(size_t row = 0; row < ROW_MAX; row++)
    {
        uint8_t rowMask = seatMask[row];
        if(rowMask == 0 || rowMask == 255)
            continue;

        foundCount++;
        if(foundCount < NON_FULL_BYTES_TO_SKIP)    
            continue;

        size_t col = 0;
        while(rowMask & 1)
        {
            col++;
            rowMask >>= 1;
        }

        g_part2Answer = toIndex(row, col);
        break;
    }

    return 0;
}