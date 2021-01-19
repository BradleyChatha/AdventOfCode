#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>
#include <assert.h>
#include <adventlib/algs.h>
#include <adventlib/types.h>
#include <adventlib/io.h>

Slice g_input1;
Slice g_input2;

int solve();

int main(void)
{
    if(!loadFileAsSlice("../../input1.txt", &g_input1)) return -1;
    if(!loadFileAsSlice("../../input2.txt", &g_input2)) return -1;
    return solve();
}

bool part1(Slice input);
bool part2(Slice input);
bool parsePolicies(Slice input);

Slice g_policies;
size_t g_policiesCursor;

int solve()
{
    if(!parsePolicies(g_input1)) return -1;
    if(!part1(g_input1)) return -1;
    if(!part2(g_input1)) return -1;
    return 0;
}

typedef struct Policy
{
    int lower;
    int upper;
    char character;
    Slice password;
} Policy;

bool lineToPolicy(Slice line, Policy* policy)
{
    #define MODE_LOWER 0
    #define MODE_UPPER 1
    #define MODE_CHARACTER 2
    #define MODE_PASSWORD 3
    int mode = MODE_LOWER;

    size_t start = 0;
    char* chars = (char*)line.ptr;
    for(size_t i = 0; i < line.length; i++)
    {
        switch(mode)
        {
            case MODE_LOWER:
                while(i < line.length && chars[i] != '-') i++;
                chars[i] = '\0'; // Set '-' to 0, for atoi.
                policy->lower = atoi(chars + start);
                start = i + 1;
                mode = MODE_UPPER;
                break;

            case MODE_UPPER:
                while(i < line.length && chars[i] != ' ') i++;
                chars[i] = '\0'; // Set ' ' to 0, for atoi.
                policy->upper = atoi(chars + start);
                start = i + 1;
                mode = MODE_CHARACTER;
                break;

            case MODE_CHARACTER:
                policy->character = chars[i++];
                if(i >= line.length || chars[i++] != ':')
                {
                    printf("Expected ':' after policy character.\n");
                    return false;
                }
                else if(i >= line.length || chars[i] != ' ')
                {
                    printf("Expected ' ' after ':' after policy character.\n");
                    return false;
                }

                start = i + 1;
                mode = MODE_PASSWORD;
                break;

            case MODE_PASSWORD:
                goto ExitForLoop;

            default: assert(false); break;
        }
    }
    ExitForLoop:

    if(mode != MODE_PASSWORD)
    {
        printf("Invalid line: %.*s\n", (int)line.length, (char*)line.ptr);
        return false;
    }

    policy->password.ptr = line.ptr + start;
    policy->password.length = line.length - start;
    return true;
}

bool parseAndAdd(Slice value, void* _)
{
    return lineToPolicy(value, &((Policy*)g_policies.ptr)[g_policiesCursor++]);
}

bool count(Slice _, void* __)
{
    g_policies.length++;
    return true;
}

bool parsePolicies(Slice input)
{
    if(!splitAndApply(input, '\n', NULL, &count))
        return false;

    g_policies.ptr = malloc(g_policies.length * sizeof(Policy));
    if(g_policies.ptr == NULL)
    {
        printf("Memory allocation failed.");
        return false;
    }

    return splitAndApply(input, '\n', NULL, &parseAndAdd);
}

bool part1(Slice input)
{
    int valid = 0;

    for(int i = 0; i < g_policies.length; i++)
    {
        const Policy policy = ((Policy*)g_policies.ptr)[i];

        int count = 0;
        for(int j = 0; j < policy.password.length; j++)
            count += ((char*)policy.password.ptr)[j] == policy.character;

        valid += (count >= policy.lower && count <= policy.upper);
    }

    printf("Part 1: %d\n", valid);
    return true;
}

bool part2(Slice input)
{ 
    int valid = 0;

    for(int i = 0; i < g_policies.length; i++)
    {
        const Policy policy = ((Policy*)g_policies.ptr)[i];
        const char* chars = (const char*)policy.password.ptr;
        valid += (chars[policy.lower-1] == policy.character ^ chars[policy.upper-1] == policy.character);
    }

    printf("Part 2: %d\n", valid);
    return true;
}