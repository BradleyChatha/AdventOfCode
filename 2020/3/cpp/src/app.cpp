#include <fstream>
#include <iostream>
#include <sstream>
#include <filesystem>

std::string g_input1;
std::string g_input2;

std::string readText(const std::string& file)
{
    if(!std::filesystem::exists(file))
        throw std::exception("File does not exist");

    auto fstream = std::ifstream(file);
    auto sstream = std::stringstream();
    sstream << fstream.rdbuf();

    return sstream.str();
}

void solve();

int main(void)
{
    try
    {
        g_input1 = readText("../../input1.txt");
        g_input2 = readText("../../input2.txt");

        solve();
        return 0;
    }
    catch(const std::exception& e)
    {
        std::cerr << "ERROR: " << e.what() << '\n';
        return -1;
    }
}

uint64_t countTrees(const std::string& input, const size_t deltaX, const size_t deltaY);
void part1(const std::string& input);
void part2(const std::string& input);

void solve()
{
    auto const& input = g_input1;
    part1(input);
    part2(input);
}

uint64_t countTrees(const std::string& input, const size_t deltaX, const size_t deltaY)
{
    const size_t newLinePos = input.find('\n');
    if(newLinePos == std::string::npos)
        throw "No new line was found.";

    const size_t charsPerLine = newLinePos - (input.find('\r') != std::string::npos);

    size_t cursorX = deltaX;
    size_t skipCount = deltaY + 1;
    size_t treeCount = 0;
    size_t start = 0;
    size_t end = newLinePos;
    int endForReals = 0;

    while(endForReals != 2)
    {
        auto const str = input.substr(start, end - start);

        skipCount--;
        if(skipCount == 0)
        {
            treeCount += str[cursorX] == '#';
            cursorX = (cursorX + deltaX) % charsPerLine;
            skipCount = deltaY;
        }
        
        start = end + 1;
        end = (endForReals == 0) ? input.find('\n', start) : std::string::npos;
        endForReals += (end == std::string::npos);
    }

    return treeCount;
}

void part1(const std::string& input)
{
    std::cout << "Part 1: " << countTrees(input, 3, 1) << std::endl;
}

void part2(const std::string& input)
{
    // Gotta love C++'s fetish for abusing operators.
    std::cout << "Part 2: " 
    <<
        countTrees(input, 1, 1) *
        countTrees(input, 3, 1) *
        countTrees(input, 5, 1) *
        countTrees(input, 7, 1) *
        countTrees(input, 1, 2)
    << std::endl;
}