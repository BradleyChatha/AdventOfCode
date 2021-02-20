import sys
sys.path.append("../../../lib/python")

from entrypoint import advent_entry

part1 = 0
part2 = 0

def toIndex(row: int, col: int):
    return (8 * row) + col

def solution(input: str):
    global part1
    global part2

    seatMask = [0] * 128 # Python, just keep on being Python.
    for line in input.splitlines():
        rowVect = [0, 128]
        colVect = [0, 8]

        for char in line:
            rowDiff = rowVect[1] - rowVect[0]
            colDiff = colVect[1] - colVect[0]
            if char == 'F':
                rowVect[1] -= rowDiff // 2
            elif char == 'B':
                rowVect[0] += rowDiff // 2
            elif char == 'R':
                colVect[0] += colDiff // 2
            elif char == 'L':
                colVect[1] -= colDiff // 2
            else:
                raise "Bad character"
        
        rowVect[1] -= 1
        colVect[1] -= 1
        assert rowVect[0] == rowVect[1]
        assert colVect[0] == colVect[1]

        index = toIndex(rowVect[0], colVect[0])
        if index > part1:
            part1 = index

        seatMask[rowVect[0]] |= (1 << colVect[0])

    # Interestingly, like the D version, we're getting a different bitmask from the C and ASM versions, so we can skip an additional check.
    for row in range(0, len(seatMask)):
        rowMask = seatMask[row]
        if rowMask == 0 or rowMask == 255:
            continue

        col = 0
        while rowMask & 1:
            rowMask >>= 1
            col += 1

        part2 = toIndex(row, col)
        break

advent_entry(solution)
print("Part 1: %d\nPart 2: %d" % (part1, part2))