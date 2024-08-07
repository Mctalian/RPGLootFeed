package = "RPGLootFeed"
version = "dev-1"
rockspec_format = "3.0"
source = {
   url = "*** please add URL for source tarball, zip or repository here ***"
}
description = {
   summary = "An addon for World of Warcraft that improves the looting experience by providing a \"feed\" similar to something you'd see in some open-world RPGs.",
   detailed = [[
An addon for World of Warcraft that improves the looting experience by providing a "feed" similar to something you'd see in some open-world RPGs.
]],
   homepage = "*** please enter a project homepage ***",
   license = "MIT"
}
dependencies = {
   "busted 2.2.0-1"
}
build = {
   type = "builtin",
   modules = {
      LootDisplay = "LootDisplay.lua",
      LootInfo = "LootInfo.lua",
      RPGLootFeed = "RPGLootFeed.lua",
      TestModeData = "TestModeData.lua"
   }
}
test = {
   type = "busted"
}
