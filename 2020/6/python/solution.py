import sys
sys.path.append("../../../lib/python")

from entrypoint import advent_entry

part1 = 0
part2 = 0

def solution(input: str):
    part1Set = set()
    part2Set = set()
    part2Sets = []

    def addToSum():
        global part1
        global part2

        part1 += len(part1Set)
        for char in range(ord('a'), ord('z')+1):
            addToSum = True
            for set_ in part2Sets:
                if not (chr(char) in set_):
                    addToSum = False
                    break
            if addToSum:
                part2 += 1        

    for line in input.splitlines():
        if len(line) == 0:
            addToSum()
            part1Set.clear()
            part2Set = set()
            part2Sets.clear()
            continue

        for char in line:
            part1Set.add(char)
            part2Set.add(char)

        part2Sets.append(part2Set)
        part2Set = set()
    addToSum()

advent_entry(solution)
print("Part 1: %d\nPart 2: %d" % (part1, part2))