module app;
            
import std;
import std.datetime.stopwatch : StopWatch2 = StopWatch;

string INPUT1;
string INPUT2;

void main()
{
    INPUT1 = std.file.readText("../input1.txt");
    INPUT2 = std.file.readText("../input2.txt");

    auto timer = StopWatch2(AutoStart.yes);
    solve();
    writeln("Time: ", timer.peek().total!"usecs", " us");
}

// D version is gonna be a bit boring and go with hash tables.

struct Passport
{
    string[string] entries; // "ecl:gry" -> ["ecl"] = "gry"
}

void solve()
{
    auto passports = parsePassports(INPUT1);
    part1(passports);
    part2(passports);
}

Passport[] parsePassports(string input)
{
    Passport[] passports;
    passports.reserve(1000);

    Passport current;
    foreach(entries; input.splitter('\n')                       // ecl:gry ecl:blu\necl:grn -> [ecl:gry ecl:blu, ecl:grn]
                          .map!(line => line.splitter(' '))     // [ecl:gry ecl:blu, ecl:grn] -> [[ecl:gry, ecl:blu], [ecl:grn]]
                          .map!(entry => 
                               entry.map!(e => e.splitter(':')) // [[ecl:gry, ecl:blu], [ecl:grn]] -> [[ecl, gry], [ecl, blu], [ecl, grn]]
                           )
    )
    {
        if(entries.empty)
        {
            passports ~= current;
            current = Passport.init;
            continue;
        }

        foreach(entryNameAndValue; entries)
        {
            const name = entryNameAndValue.front;
            entryNameAndValue.popFront();
            enforce(!entryNameAndValue.empty, "Invalid input.");
            
            current.entries[name] = entryNameAndValue.front();
        }
    }

    if(current != Passport.init)
        passports ~= current;

    return passports;
}

void part1(const Passport[] passports)
{
    writeln("Part 1: ", passports.filterValidPassports.walkLength);
}

void part2(const Passport[] passports)
{
    writeln("Part 2: ",
        passports
        .filterValidPassports
        .filter!(p => p.entries.byKeyValue.all!isValidEntry)
        .walkLength
    );
}

bool isValidEntry(KVP)(KVP kvp)
{
    switch(kvp.key)
    {
        case "byr": return kvp.value.length == 4 && kvp.value.to!int >= 1920 && kvp.value.to!int <= 2002;
        case "iyr": return kvp.value.length == 4 && kvp.value.to!int >= 2010 && kvp.value.to!int <= 2020;
        case "eyr": return kvp.value.length == 4 && kvp.value.to!int >= 2020 && kvp.value.to!int <= 2030;
        case "hgt":
            return (kvp.value[$-2..$] == "cm")
                   ? kvp.value[0..$-2].to!int >= 150 && kvp.value[0..$-2].to!int <= 193
                   : (kvp.value[$-2..$] == "in")
                     ? kvp.value[0..$-2].to!int >= 59 && kvp.value[0..$-2].to!int <= 76
                     : false;
        case "hcl": return kvp.value[0] == '#' && kvp.value[1..$].all!(ch => (ch >= '0' && ch <= '9') || (ch >= 'a' && ch <= 'f'));
        case "ecl": return ["amb", "blu", "brn", "gry", "grn", "hzl", "oth"].canFind(kvp.value);
        case "pid": return kvp.value.length == 9 && kvp.value.all!isDigit;
        case "cid": return true;

        default: throw new Exception("Unexpected entry name: "~kvp.key);
    }
}

auto filterValidPassports(const Passport[] passports)
{
    const EXPECTED = ["byr", "iyr", "eyr", "hgt", "hcl", "ecl", "pid", "cid"];
    return passports.filter!((p)
                    {
                        const expectedCount = EXPECTED.filter!(str => (str in p.entries) !is null).walkLength;
                        return expectedCount == EXPECTED.length 
                            || (expectedCount == EXPECTED.length - 1 && ("cid" in p.entries) is null);
                    });
}