#include <fstream>
#include <iostream>
#include <sstream>
#include <filesystem>
#include <algorithm>
#include <vector>
#include <ranges>

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

std::vector<int> g_numbers;
void parseNumbers(const std::string& input, std::vector<int>& numbers);
void part1();
void part2();

void solve()
{
    parseNumbers(g_input1, g_numbers);
    part1();
    part2();
}

void parseNumbers(const std::string& input, std::vector<int>& numbers)
{
    // TFW Microsoft haven't fully implemented std::ranges so I can't use the one part of it I need.
    size_t start = 0;
    size_t end = input.find('\n');
    while(end != std::string::npos)
    {
        auto numStr = input.substr(start, (end - start));
        numbers.push_back(std::stoi(numStr));

        start = end + 1; // + 1 so we skip over the \n
        end = input.find('\n', start);
    }

    if(start < input.length())
        numbers.push_back(std::stoi(input.substr(start, (input.length() - start))));

    std::sort(numbers.begin(), numbers.end());
}

void part1()
{
    for(auto firstNum : g_numbers | std::views::filter([](int n){ return n < 2020; }))
    {
        const int secondNum = 2020 - firstNum;
        if(!std::binary_search(g_numbers.begin(), g_numbers.end(), secondNum))
            continue;

        std::cout << "Part 1: " << firstNum * secondNum << std::endl;
        return;
    }

    throw std::exception("Part 1 could not find an answer");
}

void part2()
{
    size_t i = 0;
    for(auto firstNum : g_numbers | std::views::filter([](int n){ return n < 2020; }))
    {
        for(auto secondNum : g_numbers | std::views::drop(i)
                                       | std::views::filter([=](int n){ return n + firstNum < 2020; }))
        {
            const auto thirdNum = 2020 - (firstNum + secondNum);
            if(!std::binary_search(g_numbers.begin(), g_numbers.end(), thirdNum))
                continue;
            
            std::cout << "Part 2: " << firstNum * secondNum * thirdNum << std::endl;
            return;
        }
        i++;
    }

    throw std::exception("Part 2 could not find an answer");
}