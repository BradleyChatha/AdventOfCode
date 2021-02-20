import sys
sys.path.append("../../../lib/python")

from entrypoint import advent_entry

def solution(input: str):
    input_lines = input.splitlines()
    part1(input_lines)
    part2(input_lines)

def part1(input_lines: str):
    print("Part 1:", countTrees(input_lines, 3, 1))

def part2(input_lines: str):
    print("Part 2:",
        countTrees(input_lines, 1, 1) *
        countTrees(input_lines, 3, 1) *
        countTrees(input_lines, 5, 1) *
        countTrees(input_lines, 7, 1) *
        countTrees(input_lines, 1, 2)
    )

def countTrees(input_lines: str, delta_x: int, delta_y: int) -> int:
    count = 0
    cursor_x = delta_x
    cursor_y = delta_y

    while cursor_y < len(input_lines):
        if input_lines[cursor_y][cursor_x] == '#':
            count += 1

        cursor_x = (cursor_x + delta_x) % len(input_lines[0])
        cursor_y += delta_y

    return count

advent_entry(solution)