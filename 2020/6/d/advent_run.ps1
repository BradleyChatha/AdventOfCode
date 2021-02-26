param (
    [switch] $Release = $false
)

if ($Release)
{
    & dub run -b release
}
else
{
    & dub run
}