#include <windows.h>
#include <profileapi.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdbool.h>
#include <adventlib/algs.h>
#include <adventlib/types.h>
#include <adventlib/io.h>

#define INITIAL_ARRAY_SIZE 64

Slice g_input1;
Slice g_input2;

int solve();

int main(void)
{
    if(!loadFileAsSlice("../../input1.txt", &g_input1)) return -1;
    if(!loadFileAsSlice("../../input2.txt", &g_input2)) return -1;
    
    LARGE_INTEGER before, after;

    if(!QueryPerformanceCounter(&before)) return -1;
    int result = solve();
    if(!QueryPerformanceCounter(&after)) return -1;

    printf("Time: %lld us\n", after.QuadPart - before.QuadPart);
}

typedef enum EntryType
{
    UNKNOWN = 0,
    et_byr,
    et_iyr,
    et_eyr,
    et_hgt,
    et_hcl,
    et_ecl,
    et_pid,
    et_cid,

    et_COUNT
} EntryType;

typedef struct Entry
{
    EntryType type;
    Slice value;
} Entry;

typedef struct Passport
{
    Entry entries[et_COUNT];
} Passport;

Slice g_passports; // Dynamic array.

void debugPrint();
bool passportHasRequiredEntries(const Passport* passport);
bool passportEntriesAreCorrect(const Passport* passport);
EntryType sliceToEntryType(const Slice input);
int parsePassports(const Slice input);
int part1();
int part2();

int solve()
{
    int result = !(!parsePassports(g_input1) && !part1() && !part2());
    //debugPrint();

    if(g_passports.ptr)
        free(g_passports.ptr);

    return result;
}

void debugPrint()
{
    const Passport EMPTY = {};
    const Passport* ptr = (const Passport*)g_passports.ptr;

    for(size_t i = 0; i < g_passports.length; i++)
    {
        const Passport passport = ptr[i];
        const Passport passport2 = ptr[i+1];
        if(memcmp(&passport, &EMPTY, sizeof(Passport)) == 0)
            break;

        if(i == 183)
            int __ = 0;

        printf("%lld: ", i);
        for(size_t j = 1; j < et_COUNT; j++)
        {
            if(passport.entries[j].type == UNKNOWN)
                printf("%s ", "NULL");
            else
                printf("%.*s ", (int)passport.entries[j].value.length, (const char*)passport.entries[j].value.ptr);
        }
        printf("\n");
    }
}

EntryType sliceToEntryType(const Slice input)
{
    if(input.length != 3)
        return UNKNOWN;

    const char* ptr = (const char*)input.ptr;

    // Sue me
    if(!strncmp(ptr, "byr", 3)) return et_byr;
    if(!strncmp(ptr, "iyr", 3)) return et_iyr;
    if(!strncmp(ptr, "eyr", 3)) return et_eyr;
    if(!strncmp(ptr, "hgt", 3)) return et_hgt;
    if(!strncmp(ptr, "hcl", 3)) return et_hcl;
    if(!strncmp(ptr, "ecl", 3)) return et_ecl;
    if(!strncmp(ptr, "pid", 3)) return et_pid;
    if(!strncmp(ptr, "cid", 3)) return et_cid;

    return UNKNOWN;
}

bool passportHasRequiredEntries(const Passport* passport)
{
    // Skip the 0th (UNKNOWN) and last (CID, optional) entries.
    for(size_t i = 1; i < et_COUNT - 1; i++)
    {
        if(passport->entries[i].type == UNKNOWN)
            return false;
    }

    return true;
}

// bother values are inclusive.
bool sliceToIntAndInRange(Slice input, int lower, int upper)
{
    // This is safe:
    //      We no longer need to iterate over the characters, so we can modify these whitespace chars as we please.
    //      As mentioned, these characters will always be some form of whitespace, and for the very last value, it'll just
    //      be the input string's null terminator anyway.
    ((char*)input.ptr)[input.length] = '\0';
    int value = atoi((const char*)input.ptr);

    return value >= lower && value <= upper;
}

bool passportEntriesAreCorrect(const Passport* passport)
{
    const char* EYE_COLOURS[7] = 
    {
        "amb",
        "blu",
        "brn",
        "gry",
        "grn",
        "hzl",
        "oth"
    };

    for(EntryType type = 1; type < et_COUNT; type++)
    {
        Entry entry = passport->entries[type];
        const char* valuePtr = (const char*)entry.value.ptr;

        if(valuePtr)
            ((char*)valuePtr)[entry.value.length] = '\0'; // Safe to do (see sliceToInAnInRange comment), this is just so the debugger shows shit properly - so we break constness for a second.

        switch(entry.type)
        {
            case et_cid: break;
            case UNKNOWN: break;

            case et_byr: if(entry.value.length != 4 || !sliceToIntAndInRange(entry.value, 1920, 2002)) return false; break;
            case et_iyr: if(entry.value.length != 4 || !sliceToIntAndInRange(entry.value, 2010, 2020)) return false; break;
            case et_eyr: if(entry.value.length != 4 || !sliceToIntAndInRange(entry.value, 2020, 2030)) return false; break;

            case et_hgt:
                if(entry.value.length < 2)
                    return false;

                const char* lastTwoChars = valuePtr + (entry.value.length - 2);
                if(!strncmp(lastTwoChars, "in", 2))
                {
                    entry.value.length -= 2;
                    if(!sliceToIntAndInRange(entry.value, 59, 76))
                        return false;
                    break;
                }
                else if(!strncmp(lastTwoChars, "cm", 2))
                {
                    entry.value.length -= 2;
                    if(!sliceToIntAndInRange(entry.value, 150, 193))
                        return false;
                    break;
                }

                return false;

            case et_hcl:
                if(entry.value.length != 7 || valuePtr[0] != '#')
                    return false;

                for(int i = 1; i < 7; i++)
                {
                    const char ch = valuePtr[i];
                    if(!((ch >= '0' && ch <= '9') || (ch >= 'a' && ch <= 'f')))
                        return false;
                }

                break;

            case et_ecl:
                if(entry.value.length != 3)
                    return false;
                
                bool isValid = false;

                for(int i = 0; i < (sizeof(EYE_COLOURS) / sizeof(EYE_COLOURS[0])); i++)
                {
                    if(!strncmp(valuePtr, EYE_COLOURS[i], 3))
                    {
                        isValid = true;
                        break;
                    }
                }

                if(isValid)
                    break;
                else
                    return false;

            case et_pid:
                if(entry.value.length != 9)
                    return false;

                for(int i = 0; i < entry.value.length; i++)
                {
                    const char ch = valuePtr[i];
                    if(!(ch >= '0' && ch <= '9'))
                        return false;
                }
                
                break;

            default:
                printf("ERROR: Bad type %d\n", entry.type);
                exit(-1);
        }
    }

    return true;
}

int parsePassports(const Slice input)
{
    g_passports.ptr = calloc(INITIAL_ARRAY_SIZE, sizeof(Passport));
    g_passports.length = INITIAL_ARRAY_SIZE;
    if(!g_passports.ptr)
    {
        printf("Memory allocation failed!\n");
        return -1;
    }

    size_t inputCursor = 0;
    size_t arrayCursor = 0;
    bool isEmptyLine   = true;

    Passport current = {};

    while(inputCursor < input.length)
    {
        // Skip whitespace.
        while(inputCursor < input.length && ((const char*)input.ptr)[inputCursor] == ' ')
            inputCursor++;

        // Push the current passport into the array.
        if(((const char*)input.ptr)[inputCursor] == '\n')
        {
            inputCursor++;

            if(!isEmptyLine)
            {
                isEmptyLine = true;
                continue;
            }

            // Grow the array if needed.
            if(arrayCursor >= g_passports.length)
            {
                const size_t oldLength = g_passports.length;
                g_passports.length *= 2;

                void* newPtr = calloc(g_passports.length, sizeof(Passport));
                if(!newPtr)
                {
                    printf("Memory reallocation failed!\n");
                    return -1;
                }

                memcpy(newPtr, g_passports.ptr, oldLength * sizeof(Passport));
                free(g_passports.ptr);
                g_passports.ptr = newPtr;
            }

            ((Passport*)g_passports.ptr)[arrayCursor++] = current;
            memset(&current, 0, sizeof(Passport));
            continue;
        }

        isEmptyLine = false;

        // Error checking
        if(input.length - inputCursor < 4)
        {
            printf("Did not detect EOF, and 4 more characters were expected.\n");
            return -1;
        }

        // Otherwise it should just be the name of the next entry.
        // Assumption: Entry name is always exactly 3 characters long.
        Slice name = sliceOf(input.ptr, inputCursor, 3);
        inputCursor += 3;

        // Next is the semi-colon
        if(((const char*)input.ptr)[inputCursor++] != ':')
        {
            printf("Expected a semi-colon.\n");
            return -1;
        }

        // Now we just read until EOF or whitespace to get the value.
        const size_t start = inputCursor;
        while(inputCursor < input.length)
        {
            const char ch = ((const char*)input.ptr)[inputCursor];
            if(ch == ' ' || ch == '\n')
                break;

            inputCursor++; // This is down here because we don't actually want to skip over any whitespace because it has special logic in the case of new lines.
        }

        Slice value = sliceOf(input.ptr, start, inputCursor - start);
        Entry entry = { sliceToEntryType(name), value };
        current.entries[entry.type] = entry;
    }

    // Assumption: There's enough space left in the array.
    //             I'm lazy...
    ((Passport*)g_passports.ptr)[arrayCursor] = current;

    return 0;
}

int part1()
{
    size_t count = 0;

    for(size_t i = 0; i < g_passports.length; i++)
        count += passportHasRequiredEntries(&((const Passport*)g_passports.ptr)[i]);

    printf("Part 1: %lld\n", count);
    return 0;
}

int part2()
{
    size_t count = 0;

    for(size_t i = 0; i < g_passports.length; i++)
    {
        const Passport* ptr = &((const Passport*)g_passports.ptr)[i];
        count += passportHasRequiredEntries(ptr) && passportEntriesAreCorrect(ptr);
    }

    printf("Part 2: %lld\n", count);
    return 0;
}