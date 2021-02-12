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

void solve()
{
    writeln("HOLA");
}