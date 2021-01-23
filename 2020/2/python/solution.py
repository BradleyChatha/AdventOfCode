from collections import namedtuple

def read_file(file_name: str) -> str:
    with open(file_name, "r") as file:
        return file.read()

input_1: str = read_file("../input1.txt")
input_2: str = read_file("../input2.txt")

Policy = namedtuple("Policy", ["lower", "upper", "character", "password"])

def solution(input: str):
    policies = parse_policies(input)
    part1(policies)
    part2(policies)

def parse_policies(input: str) -> list:
    # Inefficient (multiple splits O(6n) could be a single O(n) pass), but looks funny.
    return [
        Policy(
            int(line.split(" ")[0].split("-")[0]),
            int(line.split(" ")[0].split("-")[1]),
            line.split(":")[0][-1],
            line.split(":")[1][1:]
        )
        for line in input.splitlines()
    ]

def part1(policies: list):
    # Again, inefficient (multiple counts O(2n)), but looks cool.
    valid_count = sum((
        1 for policy in policies
        if  policy.password.count(policy.character) >= policy.lower
        and policy.password.count(policy.character) <= policy.upper
    ))
    print("Part 1:", valid_count)

def part2(policies: list):
    # This however is O(n)
    valid_count = sum((
        1 for policy in policies
        if (policy.password[policy.lower-1] is policy.character)
        ^  (policy.password[policy.upper-1] is policy.character)
    ))
    print("Part 2:", valid_count)

# Why am I even caring about Big-O for a 1000-line file with about 30 characters per line? In python? idk myself, I just do sometimes.
solution(input_1)