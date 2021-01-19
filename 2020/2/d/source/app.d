module app;
            
import std;

string INPUT1;
string INPUT2;

void main()
{
    INPUT1 = std.file.readText("../input1.txt");
    INPUT2 = std.file.readText("../input2.txt");
    
    solve();
}

void solve()
{
    part1(INPUT1);
    part2(INPUT1);
}

void part1(string input)
{
    // Matches:
    //  [1] = Lower bound
    //  [2] = Upper bound
    //  [3] = Character to look for
    //  [4] = Password
    // Fun fact for those stalking this project: ctRegex takes a regex string, and at compile time directly translates it into D.
    //                                           This allowed D for a while to boast one of the fastest Regex engines, since it'd be
    //                                           optimised by the compiler as well.
    const pattern = ctRegex!(`(\d+)-(\d+)\s(\w):\s(.+)`);
    const result = input
                  .splitter('\n')
                  .map!(line => line.matchFirst(pattern))
                  .tee!((capture){ assert(!capture.empty, "regex failed"); })
                  .filter!((capture)
                  {
                      const lower = capture[1].to!uint;
                      const upper = capture[2].to!uint;
                      const letterCount = capture[4].count(capture[3][0]);
                      return letterCount >= lower && letterCount <= upper;
                  })
                  .count();

    writeln("Part 1: ", result);
}

void part2(string input)
{
    // Matches:
    //  [1] = Lower bound
    //  [2] = Upper bound
    //  [3] = Character to look for
    //  [4] = Password
    const pattern = ctRegex!(`(\d+)-(\d+)\s(\w):\s(.+)`);
    const result = input
                  .splitter('\n')
                  .map!(line => line.matchFirst(pattern))
                  .tee!((capture){ assert(!capture.empty, "regex failed"); })
                  .filter!((capture)
                  {
                      const lower = capture[1].to!uint - 1;
                      const upper = capture[2].to!uint - 1;
                      const ch    = capture[3][0];
                      return (capture[4][lower] == ch) ^ (capture[4][upper] == ch);
                  })
                  .count();

    writeln("Part 2: ", result);
}