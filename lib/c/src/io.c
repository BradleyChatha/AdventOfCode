#include "../include/adventlib/io.h"
#include <stdio.h>
#include <stdlib.h>

bool loadFileAsSlice(char* fileName, Slice* slice)
{
    printf("Loading input file: %s\n", fileName);

    FILE* file;
    fopen_s(&file, fileName, "r");
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

    size_t read = fread(slice->ptr, 1, slice->length, file);
    fclose(file);

    if(read != slice->length)
    {
        free(slice->ptr);
        printf("Could not read in the text in its entirety");
        return false;
    }

    ((char*)slice->ptr)[slice->length] = '\0'; // Just in case we use some standard C string functions.
    return true;
}