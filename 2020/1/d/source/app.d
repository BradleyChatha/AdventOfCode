module app;
			
import std;

string INPUT1;
string INPUT2;

void main()
{
	INPUT1 = std.file.readText("../input1.txt");
	INPUT2 = std.file.readText("../input2.txt");
	
    auto numbers = INPUT1.splitter('\n').map!(s => s.to!long).array;
    numbers.sort();

	writeln("Part 1: ", solve(numbers));
    writeln("Part 2: ", solve2(numbers));
}

long solve(const long[] numbers)
{
    foreach(number; numbers)
    {
        const required = 2020 - number;
        if(numbers.assumeSorted.contains(required)) // Binary search
            return number * required;
    }

    assert(false, "Could not find solution.");
}

long solve2(const long[] numbers)
{
    const lowestNumber = numbers.assumeSorted[0];

    foreach(number; numbers.retro)
    {
        // Skip numbers that are too large when added together with any other number.
        if(number + lowestNumber > 2020)
            continue;

        foreach(secondNumber; numbers)
        {
            const resultWithTwoNums = number + secondNumber;
            if(resultWithTwoNums > 2020) // Short circuit since this pair and any future pairs with the first number will always be invalid now.
                break;

            const thirdNumber = 2020 - resultWithTwoNums;
            if(numbers.assumeSorted.contains(thirdNumber))
                return number * secondNumber * thirdNumber;
        }
    }

    assert(false, "Could not find solution.");
}