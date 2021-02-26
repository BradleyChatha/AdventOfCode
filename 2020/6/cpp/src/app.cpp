#include <string>
#include <stdint.h>
#include <iostream>
#include <set>
#include <algorithm>
#include <vector>
#include <adventlibpp/entrypoint.hpp>

int32_t g_part1;
int32_t g_part2;

void printAnswers()
{
    std::cout << "Part 1: " << g_part1 << '\n' << "Part 2: " << g_part2 << std::endl;
}

void solve(const std::string& input)
{
    std::string_view inputAsView(input);
    std::set<char> part1Set;
    std::set<char> part2Set;
    std::vector<std::set<char>> part2SetList;

    size_t start = 0;
    size_t end = inputAsView.find('\n');
    int doExtraLoop = 2;
    while(doExtraLoop || end != std::string::npos)
    {
        std::string_view line = "";

        if(end == std::string::npos)
        {
            line = inputAsView.substr(start);
            doExtraLoop--;
        }
        else
        {
            line = inputAsView.substr(start, end - start);
            start = end + 1;
            end = inputAsView.find('\n', start);
        }

        if(line.length() == 0 || !doExtraLoop)
        {
            g_part1 += part1Set.size();
            part1Set.clear();
            
            for(char c = 'a'; c <= 'z'; c++)
            {
                bool addToSum = true;
                for(auto& set : part2SetList)
                {
                    if(!set.contains(c))
                    {
                        addToSum = false;
                        break;
                    }
                }

                if(addToSum)
                    g_part2++;

                continue;
            }
            part2SetList.clear();
            part2Set.clear();

            continue;
        }

        for(const auto ch : line)
        {
            part1Set.emplace(ch);
            part2Set.emplace(ch);
        }

        part2SetList.push_back(part2Set);
        part2Set.clear();
    }
}