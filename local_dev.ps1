# (!) Must run in an elevated Powershell 7.1 (or newer) prompt from the Windows side

# Running this will allow your changes in WSL to be reflected and testable in the game
# without manually moving files around.
# You will still need to package up your changes into the .release directory
# (using .release/local.sh in this repo)
# NOTE: Any brand new files will need to be staged in git for .release/local.sh to see it.

# This script only needs to be run one time and any subsequent local builds will be visible in
# WoW after a /reload

# To undo this, simply delete this addon's link/folder in your WoW addons directory and
# redownload / manually copy the addon.

$scriptDirectory = Split-Path -Parent $MyInvocation.MyCommand.Path

# Find the .toc file and extract the addon name
$addonName = Get-ChildItem -Path $scriptDirectory -Filter *.toc | Select-Object -First 1 | ForEach-Object { $_.BaseName }

$sourcePath = "$scriptDirectory\.release\$addonName"
$destPaths = @(
    "C:\Program Files (x86)\World of Warcraft\_retail_\Interface\AddOns\$addonName",
    "C:\Program Files (x86)\World of Warcraft\_classic_era_\Interface\AddOns\$addonName"
)

Write-Host $sourcePath

foreach ($destPath in $destPaths) {
    if (Test-Path (Split-Path -Parent $destPath)) {
        if (Test-Path $destPath) {
            Remove-Item $destPath -Recurse -Force
            Write-Host "Directory deleted: $destPath"
        }

        New-Item -ItemType SymbolicLink -Target "$sourcePath" -Path "$destPath"
        Write-Host "Symbolic link created from $sourcePath to $destPath"
    }
}