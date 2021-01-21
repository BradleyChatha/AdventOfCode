#pragma once

#include <stdint.h>
#include <stdbool.h>
#include <stddef.h>
#include "types.h"

bool splitAndApply(Slice string, char delim, void* context, bool (*func)(Slice value, void* context));
int i32Compare(void* _, const void* a, const void* b);