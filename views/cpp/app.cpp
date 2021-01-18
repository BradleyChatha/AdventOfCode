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

void solve()
{
    
}