from time import perf_counter_ns

def read_file(file_name: str) -> str:
    with open(file_name, "r") as file:
        return file.read()

input_1: str = read_file("../input1.txt")
input_2: str = read_file("../input2.txt")

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

time_start = perf_counter_ns()
solution(input_1)
print("Time: %d nsecs" % (perf_counter_ns() - time_start))