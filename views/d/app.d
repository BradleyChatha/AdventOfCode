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
    writeln("HOLA");
}