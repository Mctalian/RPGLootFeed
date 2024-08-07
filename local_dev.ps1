# Must run in an elevated Powershell 7.1 (or newer) prompt from the Windows side
New-Item -ItemType SymbolicLink -Target "\\wsl.localhost\Debian\home\mctalian\Projects\RPGLootFeed\.release\RPGLootFeed" -Path "C:\Program Files (x86)\World of Warcraft\_retail_\Interface\AddOns\RPGLootFeed"
