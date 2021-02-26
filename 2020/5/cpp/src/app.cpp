#include <stdint.h>
#include <iostream>
#include <adventlibpp/entrypoint.hpp>

#define ROW_MAX 128
#define COL_MAX 8
#define NON_FULL_BYTES_TO_SKIP 3

size_t g_part1Answer;
size_t g_part2Answer;

void printAnswers()
{
    std::cout << "Part 1: " << g_part1Answer << '\n' << "Part 2: " << g_part2Answer << std::endl;
}

inline int toIndex(const int row, const int col)
{
    return (row * COL_MAX) + col;
}

void solve(const std::string& input)
{
    uint8_t seatMask[ROW_MAX] = {};
    
    int rowVector[2] = {0, ROW_MAX};
    int colVector[2] = {0, COL_MAX};

    for(size_t charIndex = 0; charIndex < input.length(); charIndex++)
    {
        const char ch = input[charIndex];
        const int rowDiff = rowVector[1] - rowVector[0];
        const int colDiff = colVector[1] - colVector[0];

        switch(ch)
        {
            case 'F': rowVector[1] -= rowDiff / 2; break;
            case 'B': rowVector[0] += rowDiff / 2; break;
            case 'R': colVector[0] += colDiff / 2; break;
            case 'L': colVector[1] -= colDiff / 2; break;
            default: throw "Invalid char"; break;
            
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
}