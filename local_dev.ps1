# (!) Must run in an elevated Powershell 7.1 (or newer) prompt from the Windows side

# Running this will allow your changes in WSL to be reflected and testable in the game
# without manually moving files around.
# You will still need to package up your changes into the .release/RPGLootFeed directory
# (using .release/local.sh in this repo)

# This script only needs to be run one time and any subsequent local builds will be visible in
# WoW after a /reload

# To undo this, simply delete the RPGLootFeed link/folder in your WoW addons directory

# Be sure to replace your WSL Distro (Debian) and your username (mctalian) in the following command
New-Item -ItemType SymbolicLink -Target "\\wsl.localhost\Debian\home\mctalian\Projects\RPGLootFeed\.release\RPGLootFeed" -Path "C:\Program Files (x86)\World of Warcraft\_retail_\Interface\AddOns\RPGLootFeed"
