module app;

import advent;

void main(string[] args)
{
    adventEntrypoint(args, &solve);
}

void solve(string input)
{
    part1(input);
    part2(input);
}

void part1(string input)
{
    bool[char] answerSet;
    size_t sum;

    foreach(line; input.lineSplitter)
    {
        if(line.length == 0)
        {
            sum += answerSet.length;
            answerSet.clear();
            continue;
        }

        foreach(ch; line)
            answerSet[ch] = true;
    }

    if(answerSet.length > 0)
        sum += answerSet.length;

    writeln("Part 1: ", sum);
}

void part2(string input)
{
    alias Set = bool[char];
    Set[] setPerPerson;
    size_t sum;

    void addToSum()
    {
        foreach(answerChar; iota('a', 'z'+1))
            sum += setPerPerson.all!(set => (cast(char)answerChar in set) !is null) ? 1 : 0;

        setPerPerson.length = 0;
    }

    foreach(line; input.lineSplitter)
    {
        if(line.length == 0)
        {
            addToSum();
            continue;
        }

        Set set;
        foreach(ch; line)
            set[ch] = true;

        setPerPerson ~= set;
    }

    if(setPerPerson.length > 0)
        addToSum();

    writeln("Part 2: ", sum);
}