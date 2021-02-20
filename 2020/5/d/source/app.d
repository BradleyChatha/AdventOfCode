module app;

import std;
import advent;

void main(string[] args)
{
    adventEntrypoint(args, &solve);

    writefln("Part 1: %s\nPart 2: %s", part1Answer, part2Answer);
}

enum ROWS = 128;
enum COLUMNS = 8;

size_t part1Answer;
size_t part2Answer;

void solve(string input)
{
    ubyte[ROWS] seatOccupiedBitmask;

    size_t toIndex(size_t row, size_t col)
    {
        return (COLUMNS * row) + col;
    }

    foreach(line; input.lineSplitter)
    {
        int[2] rowVector = [0, ROWS];
        int[2] colVector = [0, COLUMNS];

        foreach(ch; line)
        {
            const rowDiff = rowVector[1] - rowVector[0];
            const colDiff = colVector[1] - colVector[0];
            switch(ch)
            {
                case 'F': rowVector[1] -= rowDiff / 2; break;
                case 'B': rowVector[0] += rowDiff / 2; break;
                case 'R': colVector[0] += colDiff / 2; break;
                case 'L': colVector[1] -= colDiff / 2; break;

                default: assert(false, ""~ch);
            }
        }

        debug rowVector[1]--;
        debug colVector[1]--;
        assert(rowVector[0] == rowVector[1], rowVector.to!string);
        assert(colVector[0] == colVector[1], colVector.to!string);

        const index = toIndex(rowVector[0], colVector[0]);
        if(index > part1Answer)
            part1Answer = index;

        seatOccupiedBitmask[rowVector[0]] |= (1 << colVector[0]);
    }

    // I don't completely understand why, but the D version is getting slightly different mask results than the other versions.
    // So while the other versions have to skip the first non-empty, non-full byte, the D version doesn't need to skip it.
    foreach(i, mask; seatOccupiedBitmask)
    {
        if(mask == 0 || mask == 255)
            continue;

        size_t col;
        while(mask & 1)
        {
            col++;
            mask >>= 1;
        }

        part2Answer = (8 * i) + col;
        break;
    }
}