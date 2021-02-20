from typing import Callable
from time import perf_counter_ns

def read_file(file_name: str) -> str:
    with open(file_name, "r") as file:
        return file.read()

def advent_entry(solver: Callable[[str], None]):
    input_1 = read_file("../input1.txt")
    input_2 = read_file("../input2.txt")

    time_start = perf_counter_ns()
    solver(input_1)
    print("Time: %d nsecs" % (perf_counter_ns() - time_start))