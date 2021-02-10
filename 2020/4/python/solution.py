def read_file(file_name: str) -> str:
    with open(file_name, "r") as file:
        return file.read()

input_1: str = read_file("../input1.txt")
input_2: str = read_file("../input2.txt")

validators = {
    # Python has some of the most random fucking syntax, but I love it.
    "byr": lambda str: len(str) == 4 and 1920 <= int(str) <= 2002,
    "iyr": lambda str: len(str) == 4 and 2010 <= int(str) <= 2020,
    "eyr": lambda str: len(str) == 4 and 2020 <= int(str) <= 2030,
    "hgt": lambda str: (str[-2:] == "cm" and 150 <= int(str[:-2]) <= 193) or (str[-2:] == "in" and 59 <= int(str[:-2]) <= 76),
    "hcl": lambda string: string[0] == '#' and all(('0' <= ch <= '9') or ('a' <= ch <= 'f') for ch in string[1:]), # str -> string because comprehension has weird lookup rules.
    "ecl": lambda str: str in ["amb", "blu", "brn", "gry", "grn", "hzl", "oth"],
    "pid": lambda str: len(str) == 9 and str.isnumeric(),
    "cid": lambda _: True
}

def solution(input: str):
    passports = parsePassports(input)
    part1(passports)
    part2(passports)

def parsePassports(input: str) -> list:
    passports = []

    # I tried to turn this into a massive comprehension chain, but my brain melted.
    # You're welcome.
    for lines in [lines for lines in input.split("\n\n")]:
        passport = {}
        for infoPairs in [line.split(' ') for line in lines.splitlines()]:
            for pair in infoPairs:
                split = pair.split(':')
                passport[split[0]] = split[1]
        passports.append(passport)

    return passports

def passportValuesAreValid(passport: dict) -> bool:
    return all([validators[key](value) for key, value in passport.items()])

def part1(passports: dict):
    print("Part 1:", sum([
        1 for passport in passports
        if set(["byr", "iyr", "eyr", "hgt", "hcl", "ecl", "pid"]) - set(passport.keys()) == set()
    ]))

def part2(passports: dict):
    print("Part 2:", sum([
        1 for passport in passports
        if (set(["byr", "iyr", "eyr", "hgt", "hcl", "ecl", "pid"]) - set(passport.keys()) == set())
        and passportValuesAreValid(passport)
    ]))

solution(input_1)