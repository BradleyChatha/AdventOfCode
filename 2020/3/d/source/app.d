module app;

import advent;

void main(string[] args)
{
    adventEntrypoint(args, &solve);
}

alias SkipEveryOtherLine = Flag!"skip";

void solve(string input)
{
    auto lines = input.splitter('\n').map!chomp;
    const charsPerLine = lines.front.length;
    assert(lines.all!(l => l.length == charsPerLine), "Not all lines have the same length.");

    part1(lines, charsPerLine);
    part2(lines, charsPerLine);
}

void part1(RangeT)(RangeT lines, const size_t charsPerLine)
{
    writeln("Part 1: ", countTrees(lines, charsPerLine, 3, SkipEveryOtherLine.no));
}

void part2(RangeT)(RangeT lines, const size_t charsPerLine)
{
    with(SkipEveryOtherLine)
    writeln("Part 2: ",
        [
            tuple(1, no),
            tuple(3, no),
            tuple(5, no),
            tuple(7, no),
            tuple(1, yes)
        ]
        .map!(t => countTrees(lines, charsPerLine, t[0], t[1]))
        .fold!((a, b) => a * b)(cast(size_t)1)
    );
}

size_t countTrees(RangeT)(RangeT lines, const size_t charsPerLine, const size_t deltaX, const SkipEveryOtherLine skipEveryOtherLine)
{
    size_t cursorX  = deltaX;
    size_t cursorY  = 0;
    const treeCount = lines
                      .dropExactly(skipEveryOtherLine ? 2 : 1)
                      .filter!((line)
                      {
                          const oldCursorX = cursorX;
                          const oldCursorY = cursorY;
                          cursorX = (oldCursorY == 0) ? (cursorX + deltaX) % charsPerLine : cursorX;
                          cursorY = (cursorY + 1) % (skipEveryOtherLine ? 2 : 1);

                          return oldCursorY == 0 && line[oldCursorX] == '#';
                      })
                      .count();
    return treeCount;
}