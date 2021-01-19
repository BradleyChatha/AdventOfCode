Wanted to try a different parsing method for each language:

D version uses regex for parsing. The entire process is D-ified into a range pipeline.

C version uses a custom parser. (mostly because strtok is too weird)

C++ version uses string splitting. (implemented as .find + .substr). I wanted to use ranges, but the windows STL doesn't implement std::ranges::views::split yet :(