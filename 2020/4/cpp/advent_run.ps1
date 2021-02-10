& cmake -B build -G Ninja
& cmake --build build
Push-Location ./build/
& ./solution.exe
Pop-Location