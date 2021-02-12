param (
    [switch] $Release = $false
)

if ($Release -eq $false)
{
    & cmake -B build -G Ninja
    & cmake --build build
    Push-Location ./build/
}
else
{
    & cmake -DCMAKE_BUILD_TYPE=Release -B release -G Ninja
    & cmake --build release
    Push-Location ./release/
}

& ./solution.exe
Pop-Location