#include "../include/adventlib/io.h"
#include <stdio.h>
#include <stdlib.h>

bool loadFileAsSlice(char* fileName, Slice* slice)
{
    printf("Loading input file: %s\n", fileName);

    FILE* file;
    fopen_s(&file, fileName, "rb"); // Note: Windows handles "r" weirdly, but handles byte mode perfectly fine.
    if(!file)
    {
        printf("Could not open file.\n");
        return false;
    }

    fseek(file, 0, SEEK_END);
    slice->length = ftell(file);
    fseek(file, 0, SEEK_SET);

    slice->ptr = malloc(slice->length + 1);
    if(!slice->ptr)
    {
        fclose(file);
        printf("Not enough memory.\n");
        return false;
    }

    size_t read = 0;
    while(read < slice->length)
    {
        const size_t result = fread(slice->ptr + read, 1, slice->length - read, file);
        if(result == 0)
        {
            printf("Error while reading file.\n");
            fclose(file);
            free(slice->ptr);
            return false;
        }
        read += result;
    }
    fclose(file);

    if(read != slice->length)
    {
        free(slice->ptr);
        printf("Could not read in the text in its entirety. Expected %s bytes but got %s bytes.\n", slice->length, read);
        return false;
    }

    ((char*)slice->ptr)[slice->length] = '\0'; // Just in case we use some standard C string functions.
    return true;
}