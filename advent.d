/+dub.sdl:
    name "scaffolder"
    dependency "jcli" version="0.11.0"
+/
module advent;

import std, jcli;

enum SolutionType
{
    ERROR,
    c,
    cpp,
    d
}

struct Scaffolder
{
    void function(string dir) scaffold;
}

struct ScaffoldFile
{
    string path;
    string contents;
}

int main(string[] args)
{
    return new CommandLineInterface!advent().parseAndExecute(args);
}

Result!void yearValidator(int year)
{
    const YEAR_RANGE_START = 2015;
    const YEAR_RANGE_END   = 2020;
    return Result!void.failureIf(year < YEAR_RANGE_START || year > YEAR_RANGE_END, "Year is out of range.");
}

Result!void dayValidator(int day)
{
    const DAY_RANGE_START = 1;
    const DAY_RANGE_END   = 25;
    return Result!void.failureIf(day < DAY_RANGE_START || day > DAY_RANGE_END, "Day is out of range.");
}

string createYearDayPath(int year, int day)
{
    return "%s/%s/".format(year, day);
}

@Command("new day", "Creates the initial structure for a day")
struct NewDayCommand
{
    @CommandPositionalArg(0, "year", "Which year the day belongs to.")
    @PostValidate!yearValidator
    int year;
    
    @CommandPositionalArg(1, "day", "Which day to create the scaffolder for.")
    @PostValidate!dayValidator
    int day;
    
    int onExecute()
    {
        const path = createYearDayPath(year, day);
        if(path.exists)
        {
            writeln("Directory %s already exists".format(path).ansi.fg(Ansi4BitColour.red));
            return -1;
        }
        
        writefln("Creating directory %s", path);
        mkdirRecurse(path);
        
        const inputPlaceholderText = "ENTER YOUR PUZZLE INPUT HERE.";
        std.file.write(buildPath(path, "input1.txt"), inputPlaceholderText);
        std.file.write(buildPath(path, "input2.txt"), inputPlaceholderText);
        
        return 0;
    }
}

@Command("new solution", "Scaffolds a new project solution for a day.")
struct NewSolutionCommand
{
    @CommandPositionalArg(0, "year", "Which year the day belongs to.")
    @PostValidate!yearValidator
    int year;
    
    @CommandPositionalArg(1, "day", "Which day to create the scaffolder for.")
    @PostValidate!dayValidator
    int day;
    
    @CommandNamedArg("language|l", "The language to use.")
    SolutionType language;
    
    int onExecute()
    {
        const path = createYearDayPath(year, day).buildPath(this.language.to!string~"/");
        if(path.exists)
        {
            writeln("Directory %s already exists".format(path).ansi.fg(Ansi4BitColour.red));
            return -1;
        }
        
        writefln("Creating directory %s", path);
        mkdirRecurse(path);
        
        auto scaffolder = this._scaffolders[this.language];
        scaffolder.scaffold(path);
        
        return 0;
    }
    
    private Scaffolder[SolutionType] _scaffolders;
    this(ICommandLineInterface cli)
    {
        this._scaffolders = [
            SolutionType.c:   Scaffolder(&scaffoldCProject),
            SolutionType.cpp: Scaffolder(&scaffoldCppProject),
            SolutionType.d:   Scaffolder(&scaffoldDProject)
        ];
    }
}

@Command("run day", "Runs all language solutions for a day.")
struct RunDayCommand
{
    @CommandPositionalArg(0, "year", "Which year the day belongs to.")
    @PostValidate!yearValidator
    int year;
    
    @CommandPositionalArg(1, "day", "Which day to create the scaffolder for.")
    @PostValidate!dayValidator
    int day;

    static struct RunResult
    {
        string solutionName;
        string resultPart1;
        string resultPart2;
        
        string output;
        int statusCode;
    }

    int onExecute()
    {
        const path = createYearDayPath(year, day);
        if(!path.exists)
        {
            writeln(
                "Path %s does not exist, perhaps call `%s`?"
                .format(
                    path, 
                    "advent new day %s %s".format(year, day).ansi.fg(Ansi4BitColour.white)
                )
                .ansi.fg(Ansi4BitColour.red)
            );
            return -1;
        }

        auto runners = dirEntries(path, SpanMode.breadth)
                       .map!(d => d.name.buildPath("advent_run.ps1"))
                       .map!(s => s.replace('\\', '/'))
                       .filter!(s => s.exists)
                       .array;               
        auto results = new RunResult[runners.length];

        foreach(i, runner; runners.parallel(runners.length))
            results[i] = this.run(runner);

        const largestName = results.map!(r => r.solutionName.length).maxElement();
        const largestPart1 = results.map!(r => r.resultPart1.length).maxElement();
        const largestPart2 = results.map!(r => r.resultPart2.length).maxElement();
        
        foreach(result; results)
        {
            writefln(
                "%s: %s | %s",
                result.solutionName.padLeft(' ', largestName).to!string.ansi.fg(Ansi4BitColour.magenta),
                result.resultPart1.padLeft(' ', largestPart1).to!string.ansi.fg(Ansi4BitColour.green),
                result.resultPart2.padLeft(' ', largestPart2).to!string.ansi.fg(Ansi4BitColour.green),
            );
        }

        return 0;
    }

    RunResult run(string adventRunPath)
    {
        auto value = RunResult(adventRunPath.dirName.baseName);
        const results = executeShell(escapeShellCommand("powershell", "-ExecutionPolicy", "Bypass", "./advent_run.ps1"), null, Config.none, ulong.max, adventRunPath.dirName);
        value.output = results.output;
        value.statusCode = results.status;
        
        const regex1 = value.output.matchFirst(regex(`Part 1: (.+)`));
        const regex2 = value.output.matchFirst(regex(`Part 2: (.+)`));

        value.resultPart1 = (regex1.empty) ? "COULD NOT FIND" : regex1[1];
        value.resultPart2 = (regex2.empty) ? "COULD NOT FIND" : regex2[1];

        return value;
    }
}

void scaffoldFiles(string dir, ScaffoldFile[] files)
{
    foreach(file; files)
    {
        const path = buildPath(dir, file.path);
        mkdirRecurse(path.dirName);
        writefln("Outputting file %s", path);
        std.file.write(path, file.contents);
    }
}

void scaffoldDProject(string dir)
{
    scaffoldFiles(
        dir,
        [
            ScaffoldFile("dub.sdl",        "name \"solution\""),
            ScaffoldFile(".gitignore",     ".dub/\n*.exe"),
            ScaffoldFile("source/app.d",   import("d/app.d")),
            ScaffoldFile("advent_run.ps1", import("d/advent_run.ps1"))
        ]
    );
}

void scaffoldCProject(string dir)
{
    scaffoldFiles(
        dir,
        [
            ScaffoldFile(".gitignore",      import("c/.gitignore")),
            ScaffoldFile("advent_run.ps1",  import("c/advent_run.ps1")),
            ScaffoldFile("src/app.c",       import("c/app.c")),
            ScaffoldFile("CMakeLists.txt",  import("c/CMakeLists.txt"))
        ]
    );
}

void scaffoldCppProject(string dir)
{
    scaffoldFiles(
        dir,
        [
            ScaffoldFile(".gitignore",      import("cpp/.gitignore")),
            ScaffoldFile("advent_run.ps1",  import("cpp/advent_run.ps1")),
            ScaffoldFile("src/app.cpp",     import("cpp/app.cpp")),
            ScaffoldFile("CMakeLists.txt",  import("cpp/CMakeLists.txt"))
        ]
    );
}