/+dub.sdl:
	name "scaffolder"
	dependency "jcli" version="0.11.0"
+/
module scaffolder;

import std, jcli;

enum SolutionType
{
	ERROR,
	d
}

struct Scafollder
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
	return new CommandLineInterface!scaffolder().parseAndExecute(args);
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
	
	private Scafollder[SolutionType] _scaffolders;
	this(ICommandLineInterface cli)
	{
		this._scaffolders = [
			SolutionType.d: Scafollder(&scaffoldDProject)
		];
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
			ScaffoldFile("dub.sdl", "name \"solution\""),
			ScaffoldFile(".gitignore", ".dub/\n*.exe"),
			ScaffoldFile("source/app.d", `module app;
			
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
}`)
		]
	);
}