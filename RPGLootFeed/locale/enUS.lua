---@type string, table
local _, ns = ...

---@class G_RLF
local G_RLF = ns

---@class RLF_Locale
local L = LibStub("AceLocale-3.0"):NewLocale(G_RLF.localeName, "enUS", true)

-- Chat Window Printing
L["Welcome"] = "Welcome! Use /rlf to view options."
L["AddLootAlertUnavailable"] = "LootAlertSystem:AddAlert was unavailable for > 30 seconds, Loot Toasts could not be disabled :("
L["AddMoneyAlertUnavailable"] = "MoneyAlertSystem:AddAlert was unavailable for > 30 seconds, Money Alerts could not be disabled :("
L["BossBannerAlertUnavailable"] = "BossBanner:OnEvent was unavailable for > 30 seconds, Boss Banner elements could not be disabled :("
L["Issues"] = "Please report this issue @ github: McTalian/RPGLootFeed"
L["Test Mode Enabled"] = "Test Mode Enabled"
L["Test Mode Disabled"] = "Test Mode Disabled"
L["Item Loot messages Disabled"] = "Item Loot messages Disabled"
L["Currency messages Disabled"] = "Currency messages Disabled"
L["Money messages Disabled"] = "Money messages Disabled"
L["XP messages Disabled"] = "XP messages Disabled"
L["Rep messages Disabled"] = "Rep messages Disabled"

-- Count Text Wrap Character
L["Spaces"] = " Spaces "
L["Parentheses"] = "(Parentheses)"
L["Square Brackets"] = "[Square Brackets]"
L["Curly Braces"] = "{Curly Braces}"
L["Angle Brackets"] = "<Angle Brackets>"
L["Bars"] = "|Bars|"

-- Experience
L["XP"] = "XP"

L["Close"] = "Close"
L["LauncherLeftClick"] = "|cffeda55fClick|r to open addon config menu."
L["LauncherRightClick"] = "|cffeda55fRight-click|r to open a quick-menu."
L["Socket"] = "Socket"

-- ConfigOptions
L["Toggle Test Mode"] = "Toggle Test Mode"
L["Clear rows"] = "Clear rows"
L["Toggle Loot History"] = "Toggle Loot History"

-- ConfigOptions - Features Group
L["Features"] = "Features"
L["FeaturesDesc"] = "Enable or Disable different RPGLootFeed features"
L["Loot Feeds"] = "Loot Feeds"
L["Miscellaneous"] = "Miscellaneous"
L["Show Minimap Icon"] = "Show Minimap Icon"
L["ShowMinimapIconDesc"] = "Show the RPGLootFeed minimap icon"
L["Enable Loot History"] = "Enable Loot History"
L["Loot History"] = "Loot History"
L["Party Loot History"] = "Party Loot History"
L["EnableLootHistoryDesc"] = "Store a history of looted items and display them in a separate frame"
L["Loot History Size"] = "Loot History Size"
L["LootHistorySizeDesc"] = "The maximum number of items to store in the loot history"
L["Hide Loot History Tab"] = "Hide Loot History Tab"
L["HideLootHistoryTabDesc"] = "Hide the loot history tab attached to the Loot Feed"
L["Enable Party Loot in Feed"] = "Enable Party Loot in Feed"
L["EnablePartyLootDesc"] = "Show party/raid looted items in the Loot Feed"
L["Enable Item Loot in Feed"] = "Enable Item Loot in Feed"
L["EnableItemLootDesc"] = "Show looted items in the Loot Feed"
L["Item Loot Config"] = "Item Loot Config"
L["Item Loot Options"] = "Item Loot Options"
L["Item Count Text"] = "Item Count Text"
L["Enable Item Count Text"] = "Enable Item Count Text"
L["EnableItemCountTextDesc"] = "Show the your total count (bags, bank, etc.) of the looted item in the Loot Feed"
L["Item Count Text Wrap Character"] = "Item Count Text Wrap Character"
L["ItemCountTextWrapCharDesc"] = "The character to wrap the item count text with."
L["Item Count Text Color"] = "Item Count Text Color"
L["ItemCountTextColorDesc"] = "The color of the item count text in the loot feed."
L["Item Secondary Text Options"] = "Item Secondary Text Options"
L["Prices for Sellable Items"] = "Prices for Sellable Items"
L["PricesForSellableItemsDesc"] = "Select which price to show for sellable items in the Loot Feed"
L["None"] = "None"
L["Vendor Price"] = "Vendor Price"
L["Auctionator"] = "Auctionator"
L["TSM"] = "TSM"
L["Auction House Source"] = "Auction House Source"
L["AuctionHouseSourceDesc"] = "Select the source addon for Auction House pricing information"
L["Auction Price"] = "Auction Price"
L["Item Quality Filter"] = "Item Quality Filter"
L["ItemQualityFilterDesc"] = "Check which qualities you would like to show in the Loot Feed."
L["Poor"] = "Poor"
L["Common"] = "Common"
L["Uncommon"] = "Uncommon"
L["Rare"] = "Rare"
L["Epic"] = "Epic"
L["Legendary"] = "Legendary"
L["Artifact"] = "Artifact"
L["Heirloom"] = "Heirloom"
L["Duration (seconds)"] = "%s Show Duration"
L["DurationDesc"] = "The number of seconds to show the personal loot row of %s quality before it begins to exit. (0 to use animation settings default)"
L["Reset All Duration Overrides"] = "Reset All Duration Overrides"
L["ResetAllDurationOverridesDesc"] = "Reset all duration overrides to the default value"
L["Item Highlights"] = "Item Highlights"
L["ItemHighlightsDesc"] = "Highlight items in the Loot Feed based on certain criteria"
L["Highlight Mounts"] = "Highlight Mounts"
L["HighlightMountsDesc"] = "Highlight Mounts in the Loot Feed"
L["Highlight Legendary Items"] = "Highlight Legendary Items"
L["HighlightLegendaryDesc"] = "Highlight Legendary items in the Loot Feed"
L["Highlight Items Better Than Equipped"] = "Highlight Items Better Than Equipped"
L["HighlightBetterThanEquippedDesc"] = "Highlight items that are better than what you have equipped in the Loot Feed"
L["Highlight Items with Tertiary Stats or Sockets"] = "Highlight Items with Tertiary Stats or Sockets"
L["HighlightTertiaryOrSocketDesc"] = "Highlight items with tertiary stats or sockets in the Loot Feed"
L["Play Sound for Mounts"] = "Play Sound for Mounts"
L["PlaySoundForMountsDesc"] = "Play a sound when a mount is looted"
L["Mount Sound"] = "Mount Sound"
L["MountSoundDesc"] = "The sound to play when a mount is looted"
L["Play Sound for Legendary Items"] = "Play Sound for Legendary Items"
L["PlaySoundForLegendaryDesc"] = "Play a sound when a legendary item is looted"
L["Legendary Sound"] = "Legendary Sound"
L["LegendarySoundDesc"] = "The sound to play when a legendary item is looted"
L["Play Sound for Items Better Than Equipped"] = "Play Sound for Items Better Than Equipped"
L["PlaySoundForBetterDesc"] = "Play a sound when an item better than what you have equipped is looted"
L["Better Than Equipped Sound"] = "Better Than Equipped Sound"
L["BetterThanEquippedSoundDesc"] = "The sound to play when an item better than what you have equipped is looted"
L["Item Loot Sounds"] = "Item Loot Sounds"
L["Party Loot"] = "Party Loot"
L["Party Loot Config"] = "Party Loot Config"
L["Party Loot Options"] = "Party Loot Options"
L["Separate Frame"] = "Separate Frame"
L["SeparateFrameDesc"] = "Show party/raid looted items in a separate frame"
L["Party Loot Frame Positioning"] = "Party Loot Frame Positioning"
L["PartyLootFrameDesc"] = "Position and anchor the party loot feed."
L["Party Loot Frame Sizing"] = "Party Loot Frame Sizing"
L["PartyLootFrameSizeDesc"] = "Customize the sizing of the party loot feed and its elements."
L["Copy Sizing from Main Frame"] = "Copy Sizing from Main Frame"
L["CopySizingFromMainFrameDesc"] = "Copy the sizing settings from the main loot feed to the party loot feed."
L["Party Loot Frame Styling"] = "Party Loot Frame Styling"
L["PartyLootFrameStyleDesc"] = "Style the party loot frame's feed and its elements with custom colors, alignment, etc."
L["Copy Styling from Main Frame"] = "Copy Styling from Main Frame"
L["CopyStylingFromMainFrameDesc"] = "Copy the styling settings from the main loot frame to the party loot frame."
L["Hide Server Names"] = "Hide Server Names"
L["HideServerNamesDesc"] = "Hide server names in the Party Loot Feed"
L["Party Item Quality Filter"] = "Party Item Quality Filter"
L["PartyItemQualityFilterDesc"] = "Check which qualities you would like to show in the Party Loot Feed."
L["Only Epic and Above in Raid"] = "Only Epic and Above in Raid"
L["OnlyEpicAndAboveInRaidDesc"] = "Only show Epic and above items in the Party Loot Feed in a raid group"
L["Only Epic and Above in Instance"] = "Only Epic and Above in Instance"
L["OnlyEpicAndAboveInInstanceDesc"] = "Only show Epic and above items in the Party Loot Feed in an instance group"
L["Ignore Item IDs"] = "Ignore Item IDs"
L["IgnoreItemIDsDesc"] = "Enter a comma-separated list of item IDs to ignore in the Party Loot Feed"
L["Enable Currency in Feed"] = "Enable Currency in Feed"
L["EnableCurrencyDesc"] = "Show currency such as Flightstones, Honor, Drake's Awakened Crest, etc. in the Loot Feed"
L["Currency Config"] = "Currency Config"
L["Currency Options"] = "Currency Options"
L["Currency Total Text Options"] = "Currency Total Text Options"
L["Enable Currency Total Text"] = "Enable Currency Total Text"
L["EnableCurrencyTotalTextDesc"] = "Show the total amount of currency on the current character in the Loot Feed"
L["Currency Total Text Color"] = "Currency Total Text Color"
L["CurrencyTotalTextColorDesc"] = "The color of the currency total text in the loot feed."
L["Currency Total Text Wrap Character"] = "Currency Total Text Wrap Character"
L["CurrencyTotalTextWrapCharDesc"] = "The characters to wrap the currency total text with."
L["Enable Item/Currency Tooltips"] = "Enable Item/Currency Tooltips"
L["EnableTooltipsDesc"] = "Enable showing Item/Currency Tooltips on mouseover, never shows in combat."
L["Tooltip Options"] = "Tooltip Options"
L["Show only when SHIFT is held"] = "Show only when SHIFT is held"
L["OnlyShiftOnEnterDesc"] = "Only show the tooltip if Shift is held as you mouseover the item/currency."
L["Enable Money in Feed"] = "Enable Money in Feed"
L["EnableMoneyDesc"] = "Show money, like Gold, Silver, Copper, in the Loot Feed"
L["Money Config"] = "Money Config"
L["Money Options"] = "Money Options"
L["Money Total Options"] = "Money Total Options"
L["ShowMoneyTotalDesc"] = "Show the total amount of money on the current character in the Loot Feed"
L["Abbreviate Total"] = "Abbreviate Total"
L["AbbreviateTotalDesc"] = "Abbreviate the total money amount in the Loot Feed (for gold over 1000)"
L["Show Money Total"] = "Show Money Total"
L["BillionAbbrev"] = "B"
L["MillionAbbrev"] = "M"
L["ThousandAbbrev"] = "K"
L["Accountant Mode"] = "Accountant Mode"
L["AccountantModeDesc"] = "Show the negative money amounts in parentheses instead of a negative sign."
L["Money Loot Sound"] = "Money Loot Sound"
L["Override Money Loot Sound"] = "Override Money Loot Sound"
L["MoneyLootSoundDesc"] = "Override the default money loot sound with a custom sound."
L["OverrideMoneyLootSoundDesc"] = "If checked, use a custom sound for money loot."
L["Enable Experience in Feed"] = "Enable Experience in Feed"
L["EnableXPDesc"] = "Show experience gains in the Loot Feed"
L["Experience Config"] = "Experience Config"
L["Experience Options"] = "Experience Options"
L["Experience Text Color"] = "Experience Text Color"
L["ExperienceTextColorDesc"] = "The color of the experience text in the loot feed."
L["Current Level Options"] = "Current Level Options"
L["Show Current Level"] = "Show Current Level"
L["ShowCurrentLevelDesc"] = "Show your current level in XP gain rows."
L["Current Level Color"] = "Current Level Color"
L["CurrentLevelColorDesc"] = "The color of the current level text in the loot feed."
L["Current Level Text Wrap Character"] = "Current Level Text Wrap Character"
L["CurrentLevelTextWrapCharDesc"] = "The characters to wrap the current level text with."
L["Enable Reputation in Feed"] = "Enable Reputation in Feed"
L["EnableRepDesc"] = "Show reputation gains in the Loot Feed"
L["Reputation Config"] = "Reputation Config"
L["Reputation Options"] = "Reputation Options"
L["Default Rep Text Color"] = "Default Rep Text Color"
L["RepColorDesc"] = "The default color of the reputation text in the loot feed. Overridden by faction colors."
L["Secondary Text Alpha"] = "Secondary Text Alpha"
L["SecondaryTextAlphaDesc"] = "The alpha of the reputation secondary text in the loot feed."
L["Reputation Level Options"] = "Reputation Level Options"
L["Enable Reputation Level"] = "Enable Reputation Level"
L["EnableRepLevelDesc"] = "Show the reputation level in the loot feed."
L["Reputation Level Color"] = "Reputation Level Color"
L["RepLevelColorDesc"] = "The color of the reputation level text in the loot feed."
L["Reputation Level Wrap Character"] = "Reputation Level Wrap Character"
L["RepLevelWrapCharDesc"] = "The characters to wrap the reputation level text with."
L["Profession Config"] = "Profession Config"
L["Profession Options"] = "Profession Options"
L["Enable Professions in Feed"] = "Enable Professions in Feed"
L["EnableProfDesc"] = "Show profession skill gains in the Loot Feed"
L["Skill Change Options"] = "Skill Change Options"
L["Show Skill Change"] = "Show Skill Change"
L["ShowSkillChangeDesc"] = "Show the change in skill levels."
L["Skill Text Color"] = "Skill Text Color"
L["SkillColorDesc"] = "The color of the skill text in the loot feed."
L["Skill Text Wrap Character"] = "Skill Text Wrap Character"
L["SkillTextWrapCharDesc"] = "The characters to wrap the skill text with."
L["Travel Points Config"] = "Travel Points Config"
L["Enable Travel Points in Feed"] = "Enable Travel Points in Feed"
L["EnableTravelPointsDesc"] = "Show travel points (activities completed to earn Trader Tender) in the Loot Feed"
L["Travel Point Options"] = "Travel Point Options"
L["Travel Points Text Color"] = "Travel Points Text Color"
L["TravelPointsTextColorDesc"] = "The color of the travel points text in the loot feed."

-- ConfigOptions - Positioning Group
L["Positioning"] = "Positioning"
L["Drag to Move"] = "Drag to Move"
L["PositioningDesc"] = "Position and anchor the loot feed."
L["Anchor Relative To"] = "Anchor Relative To"
L["RelativeToDesc"] = "Select a frame to anchor the loot feed to"
L["Screen"] = "Screen"
L["UIParent"] = "UIParent"
L["PlayerFrame"] = "PlayerFrame"
L["Minimap"] = "Minimap"
L["BagBar"] = "BagBar"
L["Anchor Point"] = "Anchor Point"
L["AnchorPointDesc"] = "Where on the screen to base the loot feed positioning (also impacts sizing direction)"
L["Top Left"] = "Top Left"
L["Top Right"] = "Top Right"
L["Bottom Left"] = "Bottom Left"
L["Bottom Right"] = "Bottom Right"
L["Top"] = "Top"
L["Bottom"] = "Bottom"
L["Left"] = "Left"
L["Right"] = "Right"
L["Down"] = "Down"
L["Up"] = "Up"
L["Center"] = "Center"
L["X Offset"] = "X Offset"
L["XOffsetDesc"] = "Adjust the loot feed left (negative) or right (positive)"
L["Y Offset"] = "Y Offset"
L["YOffsetDesc"] = "Adjust the loot feed down (negative) or up (positive)"
L["Frame Strata"] = "Frame Strata"
L["FrameStrataDesc"] = "Adjust the strata (screen depth, z-index, etc.) of the loot feed frame"
L["Background"] = "Background"
L["Low"] = "Low"
L["Medium"] = "Medium"
L["High"] = "High"
L["Dialog"] = "Dialog"
L["Tooltip"] = "Tooltip"

-- ConfigOptions - Sizing Group
L["Sizing"] = "Sizing"
L["SizingDesc"] = "Customize the sizing of the feed and its elements."
L["Feed Width"] = "Feed Width"
L["FeedWidthDesc"] = "The width of the loot feed parent frame"
L["Maximum Rows to Display"] = "Maximum Rows to Display"
L["MaxRowsDesc"] = "The maximum number of loot items to display in the feed"
L["Loot Item Height"] = "Loot Item Height"
L["RowHeightDesc"] = "The height of each item 'row' in the loot feed"
L["Loot Item Icon Size"] = "Loot Item Icon Size"
L["IconSizeDesc"] = "The size of the icons in each item 'row' in the loot feed"
L["Loot Item Padding"] = "Loot Item Padding"
L["RowPaddingDesc"] = "The amount of space between item 'rows' in the loot feed"

-- ConfigOptions - Styling Group
L["Styling"] = "Styling"
L["StylingDesc"] = "Style the feed and its elements with custom colors, alignment, etc."
L["Left Align"] = "Left Align"
L["LeftAlignDesc"] = "Left align row content (right align if unchecked)"
L["Grow Up"] = "Grow Up"
L["GrowUpDesc"] = "The feed will grow up (down if unchecked) as new items are added"
L["Background Gradient Start"] = "Background Gradient Start"
L["GradientStartDesc"] = "The start color of the row background gradient."
L["Background Gradient End"] = "Background Gradient End"
L["GradientEndDesc"] = "The end color of the row background gradient."
L["Row Borders"] = "Row Borders"
L["RowBordersDesc"] = "Customize the row borders."
L["Enable Row Borders"] = "Enable Row Borders"
L["EnableRowBordersDesc"] = "If checked, show borders around each row in the loot feed."
L["Row Border Thickness"] = "Row Border Thickness"
L["RowBorderThicknessDesc"] = "The thickness of the row border."
L["Row Border Color"] = "Row Border Color"
L["RowBorderColorDesc"] = "The color of the row border."
L["Use Class Colors for Borders"] = "Use Class Colors for Borders"
L["UseClassColorsForBordersDesc"] = "If checked, use class colors for the row borders."
L["Enable Secondary Row Text"] = "Enable Secondary Row Text"
L["EnableSecondaryRowTextDesc"] = "If checked, show secondary row text, such as item level, secondary stats, vendor price, etc. if applicable."
L["Use Font Objects"] = "Use Font Objects"
L["UseFontObjectsDesc"] = "If checked, use a font object to determine font face and font size."
L["Font"] = "Font"
L["FontDesc"] = "The font object for the loot text."
L["Custom Fonts"] = "Custom Fonts"
L["CustomFontsDesc"] = "Customize the font face, font sizing, and font flags to personalize the loot feed."
L["Font Face"] = "Font Face"
L["FontFaceDesc"] = "The style of the text that will show in the loot feed."
L["Font Size"] = "Font Size"
L["FontSizeDesc"] = "The size of he loot feed text in \"points\"."
L["Font Flags"] = "Font Flags"
L["FontFlagsDesc"] = "The flags to apply to the loot feed text."
L["Outline"] = "Outline"
L["Thick Outline"] = "Thick Outline"
L["Monochrome"] = "Monochrome"
L["Shadow Color"] = "Shadow Color"
L["ShadowColorDesc"] = "The color of the shadow behind the loot feed text."
L["ShadowOffsetHelp"] = "Negative values for shadows to the left or below text. -1 is usually desired for font sizes 8-10. Set both offsets to 0 to disable shadow."
L["Shadow Offset X"] = "Shadow Offset X"
L["ShadowOffsetXDesc"] = "The horizontal offset of the shadow behind the loot feed text. Negative values for shadows to the left of text. -1 is usually desired for font sizes 8-10. 0 to disable horizontal shadow."
L["Shadow Offset Y"] = "Shadow Offset Y"
L["ShadowOffsetYDesc"] = "The vertical offset of the shadow behind the loot feed text. Negative values for shadows below text. -1 is usually desired for font sizes 8-10. 0 to disable vertical shadow."
L["Secondary Font Size"] = "Secondary Font Size"
L["SecondaryFontSizeDesc"] = "The size of the secondary text in the loot feed in \"points\"."

-- ConfigOptions - Animations Group
L["Animations"] = "Animations"
L["AnimationsDesc"] = "Customize the animations of the loot feed."
L["Row Enter Animation"] = "Row Enter Animation"
L["RowEnterAnimationDesc"] = "Customize the enter animations of the loot feed rows."
L["Enter Animation Type"] = "Enter Animation Type"
L["EnterAnimationTypeDesc"] = "The type of animation to use when a new row is added to the loot feed."
L["Enter Animation Duration"] = "Enter Animation Duration"
L["EnterAnimationDurationDesc"] = "The number of seconds the enter animation will take."
L["Exit Animation Type"] = "Exit Animation Type"
L["ExitAnimationTypeDesc"] = "The type of animation to use when a row is removed from the loot feed."
L["Exit Animation Duration"] = "Exit Animation Duration"
L["ExitAnimationDurationDesc"] = "The number of seconds the exit animation will take."
L["Row Exit Animation"] = "Row Exit Animation"
L["RowExitAnimationDesc"] = "Customize the exit animations of the loot feed rows."
L["Fade"] = "Fade"
L["Slide"] = "Slide"
L["Slide Direction"] = "Slide Direction"
L["SlideDirectionDesc"] = "The direction for the row to travel during a slide animation."
L["Fade Out Delay"] = "Fade Out Delay"
L["FadeOutDelayDesc"] = "The number of seconds to show the loot row before it fades out."
L["Hover Animation"] = "Hover Animation"
L["HoverAnimationDesc"] = "Customize animations when hovering over a row in the loot feed."
L["Enable Hover Animation"] = "Enable Hover Animation"
L["EnableHoverAnimationDesc"] = "If checked, hovering over a row will highlight it."
L["Hover Alpha"] = "Hover Alpha"
L["HoverAlphaDesc"] = "The alpha of the row highlight when hovered over."
L["Base Duration"] = "Base Duration"
L["BaseDurationDesc"] = "The number of seconds the hover animation will take."
L["Update Animations"] = "Update Animations"
L["UpdateAnimationsDesc"] = "Customize animations when the quantity is updated on an existing row in the loot feed."
L["Disable Highlight"] = "Disable Highlight"
L["DisableHighlightDesc"] = "If checked, don't highlight a row's border when you loot the same item again and the quanity is updated."
L["Update Animation Duration"] = "Update Animation Duration"
L["UpdateAnimationDurationDesc"] = "The number of seconds the update animation will take."
L["Loop Update Highlight"] = "Loop Update Highlight"
L["LoopUpdateHighlightDesc"] = "If checked, the highlight animation will loop when the quantity is updated."

-- ConfigOptions - Blizzard UI Group
L["Blizzard UI"] = "Blizzard UI"
L["BlizzUIDesc"] = "Override behavior of Blizzard-related UI elements"
L["Disable Loot Toasts"] = "Disable Loot Toasts"
L["DisableLootToastDesc"] = "The boxes that appear at the bottom of the screen when you loot special items"
L["Disable Money Alerts"] = "Disable Money Alerts"
L["DisableMoneyAlertsDesc"] = "The boxes that appear at the bottom of the screen when you receive money, for example world quest rewards"
L["Enable Auto Loot"] = "Enable Auto Loot"
L["EnableAutoLootDesc"] = "Set the default setting so that auto loot is enabled when logging into any character"
L["Alerts"] = "Alerts"
L["Disable Boss Banner Elements"] = "Disable Boss Banner Elements"
L["DisableBossBannerDesc"] = "Override the Boss Banner. Completely hide it, only hide the loot portion, or only hide your loot or your party's loot."
L["Do not disable BossBanner"] = "Do not disable BossBanner"
L["Disable All BossBanner"] = "Disable All BossBanner"
L["Disable All BossBanner Loot"] = "Disable All BossBanner Loot"
L["Only Disable My BossBanner Loot"] = "Only Disable My BossBanner Loot"
L["Disable Party/Raid Loot"] = "Disable Party/Raid Loot"
L["Chat"] = "Chat"
L["Disable Loot Chat Messages"] = "Disable Loot Chat Messages"
L["DisableLootChatMessagesDesc"] = "Disables Loot Chat Messages in all chat windows."
L["Disable Currency Chat Messages"] = "Disable Currency Chat Messages"
L["DisableCurrencyChatMessagesDesc"] = "Disables Currency Chat Messages in all chat windows."
L["Disable Money Chat Messages"] = "Disable Money Chat Messages"
L["DisableMoneyChatMessagesDesc"] = "Disables Money Chat Messages in all chat windows."
L["Disable Experience Chat Messages"] = "Disable Experience Chat Messages"
L["DisableExperienceChatMessagesDesc"] = "Disables Experience Chat Messages in all chat windows."
L["Disable Reputation Chat Messages"] = "Disable Reputation Chat Messages"
L["DisableReputationChatMessagesDesc"] = "Disables Reputation Chat Messages in all chat windows."

return L
