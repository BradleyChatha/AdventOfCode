import sys
sys.path.append("../../../lib/python")

from entrypoint import advent_entry

def solution(input: str):
    numbers_sorted = sorted([int(line) for line in input.splitlines()])
    part1(numbers_sorted)
    part2(numbers_sorted)

def part1(numbers_sorted: list) -> None:
    value = next(((num1 * (2020 - num1)) for num1 in numbers_sorted if (2020 - num1) in numbers_sorted), None)
    if value is None:
        raise Exception("Could not find answer")
    print("Part 1:", value)

def part2(numbers_sorted: list) -> None:
    for num1 in numbers_sorted:
        value = next(
            (num2 * (2020 - num1 - num2))
            for num2
            in numbers_sorted
            if (2020 - num1 - num2) in numbers_sorted
        )

        if value is None:
            continue

        print("Part 2:", num1 * value)
        return

    return

advent_entry(solution)