#include <fstream>
#include <iostream>
#include <sstream>
#include <filesystem>
#include <ranges>
#include <unordered_map>
#include <unordered_set>
#include <functional>
#include <charconv>

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

// The string_views are into the global input variables, so the actual memory source will always outlive the string_views
using Passport = std::unordered_map<std::string_view, std::string_view>;

std::vector<Passport> g_passports;

void parsePassports(const std::string& input);
void part1();
void part2();

void solve()
{
    parsePassports(g_input1);
    part1();
    part2();
}

void parsePassportLine(std::string_view line, Passport& passport)
{
    bool loop = true;
    while(loop)
    {
        size_t end = line.find(':');
        if(end == std::string::npos)
            throw "Could not find colon";

        const auto name = line.substr(0, end);
        line = line.substr(end + 1);

        end = line.find(' ');
        if(end == std::string::npos)
        {
            loop = false;
            end = SIZE_MAX;
        }

        const auto value = line.substr(0, end);
        if(loop)
        {
            line = line.substr(end);
            while(line.front() == ' ') line = line.substr(1);
        }

        passport[name] = value;
    }
}

void parsePassports(const std::string& input)
{
    std::string_view view = {input};
    Passport current = {};

    size_t end = view.find('\n');
    bool loop = end != std::string::npos;
    while(loop)
    {
        if(end == std::string::npos)
            loop = false; // We'll still process this line, otherwise we'd just skip it.

        const auto line = view.substr(0, end);
        if(line.length() == 0)
        {
            g_passports.push_back(current);
            current = {};

            view = view.substr(1);
            end = view.find('\n');
            continue;
        }

        parsePassportLine(line, current);

        if(end != std::string::npos)
        {
            view = view.substr(end + 1); // Skip the new line.
            end = view.find('\n');
        }
    }
    g_passports.push_back(current);
}

bool hasAllRequiredEntries(const Passport& passport)
{
    static const std::unordered_set<std::string_view> ENTRY_NAMES = 
    {
        "byr", "iyr", "eyr", "hgt", "hcl", "ecl", "pid"
    };

    auto namesSet = ENTRY_NAMES;
    for(auto& [key, _] : passport)
        namesSet.erase(key);

    return namesSet.size() == 0;
}

bool hasEntriesAndValidValues(const Passport& passport)
{
    if(!hasAllRequiredEntries(passport))
        return false;

    static const auto isBetween = [](const std::string_view str, int lower, int upper)
    {  
        int result;
        const auto fromCharsResult = std::from_chars(str.data(), str.data() + str.length(), result);
        if(fromCharsResult.ec == std::errc::invalid_argument || fromCharsResult.ec == std::errc::result_out_of_range)
            throw "Conversion failed";
        return result >= lower && result <= upper;
    };

    static std::unordered_map<std::string_view, std::function<bool(const std::string_view)>> validators;
    if(validators.size() == 0)
    {
        validators.emplace("cid", [](const std::string_view str){ return true; });
        validators.emplace("byr", [](const std::string_view str){ return isBetween(str, 1920, 2002); });
        validators.emplace("iyr", [](const std::string_view str){ return isBetween(str, 2010, 2020); });
        validators.emplace("eyr", [](const std::string_view str){ return isBetween(str, 2020, 2030); });
        validators.emplace("hgt", [](const std::string_view str)
        {
            if(str.length() < 2)
                return false;

            int lower;
            int upper;

            if(str.substr(str.size() - 2) == "in")
            {
                lower = 59;
                upper = 76;
            }
            else if(str.substr(str.size() - 2) == "cm")
            {
                lower = 150;
                upper = 193;
            }
            else
                return false;

            return isBetween(str, lower, upper);
        });
        validators.emplace("hcl", [](const std::string_view str)
        {
            int _;
            auto substr = str.substr(1);
            return str.length() == 7 
                && str[0] == '#' 
                && std::all_of(substr.begin(), substr.end(), [](const char c){ return (c >= '0' && c <= '9') || (c >= 'a' && c <= 'f'); });
        });
        validators.emplace("ecl", [](const std::string_view str)
        {
            static std::vector<std::string> EYE_COLOURS = {"amb", "blu", "brn", "gry", "grn", "hzl", "oth"};
            return std::find(EYE_COLOURS.begin(), EYE_COLOURS.end(), str) != EYE_COLOURS.end();
        });
        validators.emplace("pid", [](const std::string_view str)
        {
            int _;
            return str.length() == 9 
                && std::from_chars(str.data(), str.data() + str.length(), _).ec != std::errc::invalid_argument;
        });
    }

    for(auto const& [key, value] : passport)
    {
        if(!validators[key](value))
            return false;
    }

    return true;
}

void part1()
{
    std::cout << "Part 1: " << std::count_if(g_passports.begin(), g_passports.end(), hasAllRequiredEntries) << std::endl;
}

void part2()
{
    std::cout << "Part 2: " << std::count_if(g_passports.begin(), g_passports.end(), hasEntriesAndValidValues) << std::endl;
}