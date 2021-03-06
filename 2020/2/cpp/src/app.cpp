#include <fstream>
#include <iostream>
#include <sstream>
#include <filesystem>
#include <ranges>
#include <windows.h>
#include <profileapi.h>
#include <adventlibpp/entrypoint.hpp>

struct Policy
{
    int lower;
    int upper;
    char character;
    std::string password;
};

std::vector<Policy> g_policies;

void parsePolicies(const std::string& input);
void part1();
void part2();

void solve(const std::string& input)
{
    parsePolicies(input);
    part1();
    part2();
}

void printAnswers(){}

void parseAndAddLine(const std::string& line)
{
    size_t oldSplitPos;
    size_t splitPos = line.find('-');
    if(splitPos == std::string::npos)
        throw "Bad line. Could not find '-'";

    const long lower = std::stoi(line.substr(0, splitPos));
    
    oldSplitPos = splitPos + 1;
    splitPos = line.find(' ');
    if(splitPos == std::string::npos)
        throw "Bad line. Could not find ' ' after '-'";

    const long upper = std::stoi(line.substr(oldSplitPos, splitPos - oldSplitPos));

    splitPos++;
    if(splitPos >= line.length())
        throw "Bad line. Premature end of line.";
    
    const char ch = line[splitPos++];

    if(splitPos >= line.length())
        throw "Bad line. Premature end of line.";
    if(line[splitPos++] != ':')
        throw "Bad line. Expected ':' after character";
    if(splitPos >= line.length())
        throw "Bad line. Premature end of line.";
    if(line[splitPos++] != ' ')
        throw "Bad line. Expected ' ' after ':'";

    const std::string password = line.substr(splitPos);

    g_policies.push_back(Policy{ lower, upper, ch, password });
}

void parsePolicies(const std::string& input)
{
    size_t start = 0;
    size_t end = input.find('\n');
    while(end != std::string::npos)
    {
        parseAndAddLine(input.substr(start, end - start));

        start = end + 1;
        end = input.find('\n', start);
    }

    if(start < input.length())
        parseAndAddLine(input.substr(start, input.length() - start));
}

void part1()
{
    const auto result = std::count_if(
        g_policies.begin(),
        g_policies.end(),
        [](Policy policy)
        {
            const auto charCount = std::count_if(
                policy.password.begin(),
                policy.password.end(), 
                [&](char c){ return c ==  policy.character; }
            );

            return charCount >= policy.lower && charCount <= policy.upper;
        }
    );

    std::cout << "Part 1: " << result << std::endl;
}

void part2()
{
    const auto result = std::count_if(
        g_policies.begin(),
        g_policies.end(),
        [](Policy policy)
        {
            return policy.password[policy.lower-1] == policy.character ^ policy.password[policy.upper-1] == policy.character;
        }
    );

    std::cout << "Part 2: " << result << std::endl;
}