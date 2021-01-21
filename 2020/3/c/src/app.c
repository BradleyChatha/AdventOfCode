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

int main(void)
{
    if(!loadFileAsSlice("../../input1.txt", &g_input1)) return -1;
    if(!loadFileAsSlice("../../input2.txt", &g_input2)) return -1;
    return solve();
}

size_t countTrees(const Slice input, const size_t deltaX, const size_t deltaY);
int part1(const Slice input);
int part2(const Slice input);

int solve()
{
    return !part1(g_input1) && !part2(g_input1);
}

size_t countTrees(const Slice input, const size_t deltaX, const size_t deltaY)
{
    // Seems kind of boring to essentially do a translation of the D version, so we'll go for something slightly different.
    size_t lineCount     = 1;
    size_t charsPerLine  = 0;
    for(size_t i = 0; i < input.length; i++)
    {
        charsPerLine += (lineCount == 1);
        lineCount    += ((const char*)input.ptr)[i] == '\n';
    }
    
    // Support for archaic files that use CRLF
    const size_t offsetPerLine = charsPerLine;
    charsPerLine -= ((const char*)input.ptr)[charsPerLine-1] == '\r';
    charsPerLine--; // Uncount the \n
    //charsPerLine--; // idk but this makes it work, so...

    size_t cursorX = deltaX;
    size_t cursorY = deltaY;
    size_t treeCount = 0;

    while(cursorY < lineCount)
    {
        const size_t index = (offsetPerLine * cursorY) + cursorX;
        treeCount += ((const char*)input.ptr)[index] == '#';

        cursorX = (cursorX + deltaX) % charsPerLine;
        cursorY += deltaY;
    }

    return treeCount;
}

int part1(const Slice input)
{
    printf("Part 1: %lld\n", countTrees(input, 3, 1));
    return 0;
}

int part2(const Slice input)
{
    printf("Part 2: %lld\n",
        countTrees(input, 1, 1) *
        countTrees(input, 3, 1) *
        countTrees(input, 5, 1) *
        countTrees(input, 7, 1) *
        countTrees(input, 1, 2)
    );
    return 0;
}