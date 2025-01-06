# (!) Must run in an elevated Powershell 7.1 (or newer) prompt from the Windows side.

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

if ($IsWindows) {
    $wowBasePath = "C:\Program Files (x86)\World of Warcraft"
} else {
    $wowBasePath = "/mnt/c/Program Files (x86)/World of Warcraft"
}

# Enumerate all subdirectories that match the _* pattern
$wowDirectories = Get-ChildItem -Path $wowBasePath -Directory -Filter "_*"

$destPaths = @()
foreach ($dir in $wowDirectories) {
    if ($IsWindows) {
        $flavor = $dir.FullName -replace "C:\\Program Files \(x86\)\\World of Warcraft\\", ""
    } else {
        $flavor = $dir.FullName -replace "/mnt/c/Program Files \(x86\)/World of Warcraft/", ""
    }

    $flavor = $dir.FullName -replace "C:\\Program Files \(x86\)\\World of Warcraft\\", ""
    Write-Host "Found WoW directory: $($flavor)" -ForegroundColor Green

    if ($IsWindows) {
        $destPath = "$($dir.FullName)\Interface\AddOns\$addonName"
    } else {
        $destPath = "$($dir.FullName)/Interface/AddOns/$addonName"
    }

    if (Test-Path (Split-Path -Parent $destPath)) {
        if (Test-Path $destPath) {
            Remove-Item $destPath -Recurse -Force > $null
            Write-Host "`tDirectory deleted in $flavor" -ForegroundColor Yellow
        }

        # Check if we are on Windows or WSL and create the appropriate symlink
        if ($IsWindows) {
            New-Item -ItemType SymbolicLink -Target "$sourcePath" -Path "$destPath" > $null
            Write-Host "`tWindows symbolic link created for $flavor" -ForegroundColor Cyan
        } else {
            # On WSL, use Linux-style symlink
            $destPathWindows = $destPath -replace "/mnt/c/Program Files \(x86\)/", "C:\\"
            cmd.exe /C mklink /D "$destPathWindows" "$sourcePath"
            Write-Host "`tWSL symbolic link created for $flavor" -ForegroundColor Cyan
        }
    } else {
        Write-Host "`tParent directory does not exist: $(Split-Path -Parent $destPath)" -ForegroundColor Red
    }
}
