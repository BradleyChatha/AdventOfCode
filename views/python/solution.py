from time import perf_counter_ns

def read_file(file_name: str) -> str:
    with open(file_name, "r") as file:
        return file.read()

input_1: str = read_file("../input1.txt")
input_2: str = read_file("../input2.txt")

def solution(input: str):
    part1(input)
    part2(input)

def part1(input: str):
    return

def part2(input: str):
    return

time_start = perf_counter_ns()
solution(input_1)
print("Time: %d nsecs" % (perf_counter_ns() - time_start))