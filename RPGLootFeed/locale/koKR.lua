--@strip-comments@
---@type string, table
local _, ns = ...

---@class G_RLF
local G_RLF = ns

local L = LibStub("AceLocale-3.0"):NewLocale(G_RLF.localeName, "koKR")
if not L then
	return
end

--- Place newest translations/locale keys at the top, wrapped in --#region and --#endregion for the version number that they were added in.
--- You may translate these comments, but do not translate "region" or "endregion" as they are used by the localization tool to determine where to place the translations.
--- To add translations, simply uncomment the line(s) and replace the English text after the equal sign (=) with the translated value.

--#region 1.0.0 - 1.22.0
-- L["Abbreviate Total"] = "Abbreviate Total"
-- L["AbbreviateTotalDesc"] = "Abbreviate the total money amount in the Loot Feed (for gold over 1000)"
-- L["About"] = "About"
-- L["AboutDesc"] = "About the addon and its author"
-- L["AboutTitle"] = "Thank you for using RPGLootFeed!"
-- L["Accountant Mode"] = "Accountant Mode"
-- L["AccountantModeDesc"] = "Show the negative money amounts in parentheses instead of a negative sign."
-- L["AddLootAlertUnavailable"] = "LootAlertSystem:AddAlert was unavailable for > 30 seconds, Loot Toasts could not be disabled :("
-- L["AddMoneyAlertUnavailable"] = "MoneyAlertSystem:AddAlert was unavailable for > 30 seconds, Money Alerts could not be disabled :("
-- L["Alerts"] = "Alerts"
-- L["Anchor Point"] = "Anchor Point"
-- L["Anchor Relative To"] = "Anchor Relative To"
-- L["AnchorPointDesc"] = "Where on the screen to base the loot feed positioning (also impacts sizing direction)"
-- L["Angle Brackets"] = "<Angle Brackets>"
-- L["Animations"] = "Animations"
-- L["AnimationsDesc"] = "Customize the animations of the loot feed."
-- L["Artifact"] = "Artifact"
-- L["Auction House Source"] = "Auction House Source"
-- L["Auction Price"] = "Auction Price"
-- L["Auctionator"] = "Auctionator"
-- L["AuctionHouseSourceDesc"] = "Select the source addon for Auction House pricing information"
-- L["Author"] = "This addon is created and maintained by McTalian."
-- L["AuthorGitHub"] = "GitHub (copy/paste below)"
-- L["Background"] = "Background"
-- L["Background Gradient End"] = "Background Gradient End"
-- L["Background Gradient Start"] = "Background Gradient Start"
-- L["BagBar"] = "BagBar"
-- L["Bars"] = "|Bars|"
-- L["Base Duration"] = "Base Duration"
-- L["BaseDurationDesc"] = "The number of seconds the hover animation will take."
-- L["Better Than Equipped Sound"] = "Better Than Equipped Sound"
-- L["BetterThanEquippedSoundDesc"] = "The sound to play when an item better than what you have equipped is looted"
-- L["BillionAbbrev"] = "B"
-- L["Blizzard UI"] = "Blizzard UI"
-- L["BlizzUIDesc"] = "Override behavior of Blizzard-related UI elements"
-- L["BossBannerAlertUnavailable"] = "BossBanner:OnEvent was unavailable for > 30 seconds, Boss Banner elements could not be disabled :("
-- L["Bottom"] = "Bottom"
-- L["Bottom Left"] = "Bottom Left"
-- L["Bottom Right"] = "Bottom Right"
-- L["Center"] = "Center"
-- L["Chat"] = "Chat"
-- L["Clear rows"] = "Clear rows"
-- L["Close"] = "Close"
-- L["Common"] = "Common"
-- L["Copy Sizing from Main Frame"] = "Copy Sizing from Main Frame"
-- L["Copy Styling from Main Frame"] = "Copy Styling from Main Frame"
-- L["CopySizingFromMainFrameDesc"] = "Copy the sizing settings from the main loot feed to the party loot feed."
-- L["CopyStylingFromMainFrameDesc"] = "Copy the styling settings from the main loot frame to the party loot frame."
-- L["Credits"] = "%sSpecial thanks to all translation contributors!%s"
-- L["Curly Braces"] = "{Curly Braces}"
-- L["Currency Config"] = "Currency Config"
-- L["Currency messages Disabled"] = "Currency messages Disabled"
-- L["Currency Options"] = "Currency Options"
-- L["Currency Total Text Color"] = "Currency Total Text Color"
-- L["Currency Total Text Options"] = "Currency Total Text Options"
-- L["Currency Total Text Wrap Character"] = "Currency Total Text Wrap Character"
-- L["CurrencyTotalTextColorDesc"] = "The color of the currency total text in the loot feed."
-- L["CurrencyTotalTextWrapCharDesc"] = "The characters to wrap the currency total text with."
-- L["Current Level Color"] = "Current Level Color"
-- L["Current Level Options"] = "Current Level Options"
-- L["Current Level Text Wrap Character"] = "Current Level Text Wrap Character"
-- L["CurrentLevelColorDesc"] = "The color of the current level text in the loot feed."
-- L["CurrentLevelTextWrapCharDesc"] = "The characters to wrap the current level text with."
-- L["Custom Fonts"] = "Custom Fonts"
-- L["CustomFontsDesc"] = "Customize the font face, font sizing, and font flags to personalize the loot feed."
-- L["Default Rep Text Color"] = "Default Rep Text Color"
-- L["Dialog"] = "Dialog"
-- L["Disable All BossBanner"] = "Disable All BossBanner"
-- L["Disable All BossBanner Loot"] = "Disable All BossBanner Loot"
-- L["Disable Automatic Exit"] = "Disable Automatic Exit"
-- L["Disable Boss Banner Elements"] = "Disable Boss Banner Elements"
-- L["Disable Currency Chat Messages"] = "Disable Currency Chat Messages"
-- L["Disable Experience Chat Messages"] = "Disable Experience Chat Messages"
-- L["Disable Highlight"] = "Disable Highlight"
-- L["Disable Loot Chat Messages"] = "Disable Loot Chat Messages"
-- L["Disable Loot Toasts"] = "Disable Loot Toasts"
-- L["Disable Money Alerts"] = "Disable Money Alerts"
-- L["Disable Money Chat Messages"] = "Disable Money Chat Messages"
-- L["Disable Party/Raid Loot"] = "Disable Party/Raid Loot"
-- L["Disable Reputation Chat Messages"] = "Disable Reputation Chat Messages"
-- L["Disable Skill Chat Messages"] = "Disable Skill Chat Messages"
-- L["DisableAutomaticExitDesc"] = "If checked, the loot feed will not automatically remove rows after a set duration. You will need to right-click the rows to remove them."
-- L["DisableBossBannerDesc"] = "Override the Boss Banner. Completely hide it, only hide the loot portion, or only hide your loot or your party's loot."
-- L["DisableCurrencyChatMessagesDesc"] = "Disables Currency Chat Messages in all chat windows."
-- L["DisableExperienceChatMessagesDesc"] = "Disables Experience Chat Messages in all chat windows."
-- L["DisableHighlightDesc"] = "If checked, don't highlight a row's border when you loot the same item again and the quanity is updated."
-- L["DisableLootChatMessagesDesc"] = "Disables Loot Chat Messages in all chat windows."
-- L["DisableLootToastDesc"] = "The boxes that appear at the bottom of the screen when you loot special items"
-- L["DisableMoneyAlertsDesc"] = "The boxes that appear at the bottom of the screen when you receive money, for example world quest rewards"
-- L["DisableMoneyChatMessagesDesc"] = "Disables Money Chat Messages in all chat windows."
-- L["DisableReputationChatMessagesDesc"] = "Disables Reputation Chat Messages in all chat windows."
-- L["DisableSkillChatMessagesDesc"] = "Disables Skill/Trade Skill/Profession Chat Messages in all chat windows."
-- L["Do not disable BossBanner"] = "Do not disable BossBanner"
-- L["Down"] = "Down"
-- L["Drag to Move"] = "Drag to Move"
-- L["Duration (seconds)"] = "%s Show Duration"
-- L["DurationDesc"] = "The number of seconds to show the personal loot row of %s quality before it begins to exit. (0 to use animation settings default)"
-- L["Enable Auto Loot"] = "Enable Auto Loot"
-- L["Enable Currency in Feed"] = "Enable Currency in Feed"
-- L["Enable Currency Total Text"] = "Enable Currency Total Text"
-- L["Enable Experience in Feed"] = "Enable Experience in Feed"
-- L["Enable Hover Animation"] = "Enable Hover Animation"
-- L["Enable Item Count Text"] = "Enable Item Count Text"
-- L["Enable Item Loot in Feed"] = "Enable Item Loot in Feed"
-- L["Enable Item/Currency Tooltips"] = "Enable Item/Currency Tooltips"
-- L["Enable Loot History"] = "Enable Loot History"
-- L["Enable Money in Feed"] = "Enable Money in Feed"
-- L["Enable Party Loot in Feed"] = "Enable Party Loot in Feed"
-- L["Enable Professions in Feed"] = "Enable Professions in Feed"
-- L["Enable Reputation in Feed"] = "Enable Reputation in Feed"
-- L["Enable Reputation Level"] = "Enable Reputation Level"
-- L["Enable Row Borders"] = "Enable Row Borders"
-- L["Enable Secondary Row Text"] = "Enable Secondary Row Text"
-- L["Enable Top Left Icon Text"] = "Enable Top Left Icon Text"
-- L["Enable Travel Points in Feed"] = "Enable Travel Points in Feed"
-- L["EnableAutoLootDesc"] = "Set the default setting so that auto loot is enabled when logging into any character"
-- L["EnableCurrencyDesc"] = "Show currency such as Flightstones, Honor, Drake's Awakened Crest, etc. in the Loot Feed"
-- L["EnableCurrencyTotalTextDesc"] = "Show the total amount of currency on the current character in the Loot Feed"
-- L["EnableHoverAnimationDesc"] = "If checked, hovering over a row will highlight it."
-- L["EnableItemCountTextDesc"] = "Show the your total count (bags, bank, etc.) of the looted item in the Loot Feed"
-- L["EnableItemLootDesc"] = "Show looted items in the Loot Feed"
-- L["EnableLootHistoryDesc"] = "Store a history of looted items and display them in a separate frame"
-- L["EnableMoneyDesc"] = "Show money, like Gold, Silver, Copper, in the Loot Feed"
-- L["EnablePartyLootDesc"] = "Show party/raid looted items in the Loot Feed"
-- L["EnableProfDesc"] = "Show profession skill gains in the Loot Feed"
-- L["EnableRepDesc"] = "Show reputation gains in the Loot Feed"
-- L["EnableRepLevelDesc"] = "Show the reputation level in the loot feed."
-- L["EnableRowBordersDesc"] = "If checked, show borders around each row in the loot feed."
-- L["EnableSecondaryRowTextDesc"] = "If checked, show secondary row text, such as item level, secondary stats, vendor price, etc. if applicable."
-- L["EnableTooltipsDesc"] = "Enable showing Item/Currency Tooltips on mouseover, never shows in combat."
-- L["EnableTopLeftIconTextDesc"] = "If checked, text in the upper left of the icons may show, for example item level of equipment."
-- L["EnableTravelPointsDesc"] = "Show travel points (activities completed to earn Trader Tender) in the Loot Feed"
-- L["EnableXPDesc"] = "Show experience gains in the Loot Feed"
-- L["Enter Animation Duration"] = "Enter Animation Duration"
-- L["Enter Animation Type"] = "Enter Animation Type"
-- L["EnterAnimationDurationDesc"] = "The number of seconds the enter animation will take."
-- L["EnterAnimationTypeDesc"] = "The type of animation to use when a new row is added to the loot feed."
-- L["Epic"] = "Epic"
-- L["Exit Animation Duration"] = "Exit Animation Duration"
-- L["Exit Animation Type"] = "Exit Animation Type"
-- L["ExitAnimationDurationDesc"] = "The number of seconds the exit animation will take."
-- L["ExitAnimationTypeDesc"] = "The type of animation to use when a row is removed from the loot feed."
-- L["Experience Config"] = "Experience Config"
-- L["Experience Options"] = "Experience Options"
-- L["Experience Text Color"] = "Experience Text Color"
-- L["ExperienceTextColorDesc"] = "The color of the experience text in the loot feed."
-- L["Fade"] = "Fade"
-- L["Fade Out Delay"] = "Fade Out Delay"
-- L["FadeOutDelayDesc"] = "The number of seconds to show the loot row before it fades out."
-- L["Features"] = "Features"
-- L["FeaturesDesc"] = "Enable or Disable different RPGLootFeed features"
-- L["Feed Width"] = "Feed Width"
-- L["FeedWidthDesc"] = "The width of the loot feed parent frame"
-- L["Font"] = "Font"
-- L["Font Face"] = "Font Face"
-- L["Font Flags"] = "Font Flags"
-- L["Font Size"] = "Font Size"
-- L["FontDesc"] = "The font object for the loot text."
-- L["FontFaceDesc"] = "The style of the text that will show in the loot feed."
-- L["FontFlagsDesc"] = "The flags to apply to the loot feed text."
-- L["FontSizeDesc"] = "The size of he loot feed text in \"points\"."
-- L["Frame Strata"] = "Frame Strata"
-- L["FrameStrataDesc"] = "Adjust the strata (screen depth, z-index, etc.) of the loot feed frame"
-- L["GitHubIssuesLink"] = "GitHub Issues (copy/paste below)"
-- L["GradientEndDesc"] = "The end color of the row background gradient."
-- L["GradientStartDesc"] = "The start color of the row background gradient."
-- L["Grow Up"] = "Grow Up"
-- L["GrowUpDesc"] = "The feed will grow up (down if unchecked) as new items are added"
-- L["Heirloom"] = "Heirloom"
-- L["Hide Loot History Tab"] = "Hide Loot History Tab"
-- L["Hide Server Names"] = "Hide Server Names"
-- L["HideLootHistoryTabDesc"] = "Hide the loot history tab attached to the Loot Feed"
-- L["HideServerNamesDesc"] = "Hide server names in the Party Loot Feed"
-- L["High"] = "High"
-- L["Highlight Items Better Than Equipped"] = "Highlight Items Better Than Equipped"
-- L["Highlight Items with Tertiary Stats or Sockets"] = "Highlight Items with Tertiary Stats or Sockets"
-- L["Highlight Legendary Items"] = "Highlight Legendary Items"
-- L["Highlight Mounts"] = "Highlight Mounts"
-- L["HighlightBetterThanEquippedDesc"] = "Highlight items that are better than what you have equipped in the Loot Feed"
-- L["HighlightLegendaryDesc"] = "Highlight Legendary items in the Loot Feed"
-- L["HighlightMountsDesc"] = "Highlight Mounts in the Loot Feed"
-- L["HighlightTertiaryOrSocketDesc"] = "Highlight items with tertiary stats or sockets in the Loot Feed"
-- L["Hover Alpha"] = "Hover Alpha"
-- L["Hover Animation"] = "Hover Animation"
-- L["HoverAlphaDesc"] = "The alpha of the row highlight when hovered over."
-- L["HoverAnimationDesc"] = "Customize animations when hovering over a row in the loot feed."
-- L["IconSizeDesc"] = "The size of the icons in each item 'row' in the loot feed"
-- L["Ignore Item IDs"] = "Ignore Item IDs"
-- L["IgnoreItemIDsDesc"] = "Enter a comma-separated list of item IDs to ignore in the Party Loot Feed"
-- L["Issues"] = "Please report this issue @ github: McTalian/RPGLootFeed"
-- L["IssuesAndRequests"] = "You can also report any issues or feature requests on the GitHub issues page."
-- L["Item Count Text"] = "Item Count Text"
-- L["Item Count Text Color"] = "Item Count Text Color"
-- L["Item Count Text Wrap Character"] = "Item Count Text Wrap Character"
-- L["Item Highlights"] = "Item Highlights"
-- L["Item Loot Config"] = "Item Loot Config"
-- L["Item Loot messages Disabled"] = "Item Loot messages Disabled"
-- L["Item Loot Options"] = "Item Loot Options"
-- L["Item Loot Sounds"] = "Item Loot Sounds"
-- L["Item Quality Filter"] = "Item Quality Filter"
-- L["Item Secondary Text Options"] = "Item Secondary Text Options"
-- L["ItemCountTextColorDesc"] = "The color of the item count text in the loot feed."
-- L["ItemCountTextWrapCharDesc"] = "The character to wrap the item count text with."
-- L["ItemHighlightsDesc"] = "Highlight items in the Loot Feed based on certain criteria"
-- L["ItemQualityFilterDesc"] = "Check which qualities you would like to show in the Loot Feed."
-- L["JoinDiscord"] = "Join the Discord Community (copy/paste below)"
-- L["JoinDiscordDesc"] = "Join the RPGLootFeed Discord Community for support, feedback, suggestions, and for news on the latest updates."
-- L["LauncherLeftClick"] = "|cffeda55fClick|r to open addon config menu."
-- L["LauncherRightClick"] = "|cffeda55fRight-click|r to open a quick-menu."
-- L["Left"] = "Left"
-- L["Left Align"] = "Left Align"
-- L["LeftAlignDesc"] = "Left align row content (right align if unchecked)"
-- L["Legendary"] = "Legendary"
-- L["Legendary Sound"] = "Legendary Sound"
-- L["LegendarySoundDesc"] = "The sound to play when a legendary item is looted"
-- L["Loop Update Highlight"] = "Loop Update Highlight"
-- L["LoopUpdateHighlightDesc"] = "If checked, the highlight animation will loop when the quantity is updated."
-- L["Loot Feeds"] = "Loot Feeds"
-- L["Loot History"] = "Loot History"
-- L["Loot History Size"] = "Loot History Size"
-- L["Loot Item Height"] = "Loot Item Height"
-- L["Loot Item Icon Size"] = "Loot Item Icon Size"
-- L["Loot Item Padding"] = "Loot Item Padding"
-- L["LootHistorySizeDesc"] = "The maximum number of items to store in the loot history"
-- L["Low"] = "Low"
-- L["Maximum Rows to Display"] = "Maximum Rows to Display"
-- L["MaxRowsDesc"] = "The maximum number of loot items to display in the feed"
-- L["Medium"] = "Medium"
-- L["MillionAbbrev"] = "M"
-- L["Minimap"] = "Minimap"
-- L["Miscellaneous"] = "Miscellaneous"
-- L["Money Config"] = "Money Config"
-- L["Money Loot Sound"] = "Money Loot Sound"
-- L["Money messages Disabled"] = "Money messages Disabled"
-- L["Money Options"] = "Money Options"
-- L["Money Total Options"] = "Money Total Options"
-- L["MoneyLootSoundDesc"] = "Override the default money loot sound with a custom sound."
-- L["Monochrome"] = "Monochrome"
-- L["Mount Sound"] = "Mount Sound"
-- L["MountSoundDesc"] = "The sound to play when a mount is looted"
-- L["New version available"] = "New version available: %s"
-- L["None"] = "None"
-- L["Only Disable My BossBanner Loot"] = "Only Disable My BossBanner Loot"
-- L["Only Epic and Above in Instance"] = "Only Epic and Above in Instance"
-- L["Only Epic and Above in Raid"] = "Only Epic and Above in Raid"
-- L["OnlyEpicAndAboveInInstanceDesc"] = "Only show Epic and above items in the Party Loot Feed in an instance group"
-- L["OnlyEpicAndAboveInRaidDesc"] = "Only show Epic and above items in the Party Loot Feed in a raid group"
-- L["OnlyShiftOnEnterDesc"] = "Only show the tooltip if Shift is held as you mouseover the item/currency."
-- L["Outline"] = "Outline"
-- L["Override Money Loot Sound"] = "Override Money Loot Sound"
-- L["OverrideMoneyLootSoundDesc"] = "If checked, use a custom sound for money loot."
-- L["Parentheses"] = "(Parentheses)"
-- L["Party Item Quality Filter"] = "Party Item Quality Filter"
-- L["Party Loot"] = "Party Loot"
-- L["Party Loot Config"] = "Party Loot Config"
-- L["Party Loot Frame Positioning"] = "Party Loot Frame Positioning"
-- L["Party Loot Frame Sizing"] = "Party Loot Frame Sizing"
-- L["Party Loot Frame Styling"] = "Party Loot Frame Styling"
-- L["Party Loot History"] = "Party Loot History"
-- L["Party Loot Options"] = "Party Loot Options"
-- L["PartyItemQualityFilterDesc"] = "Check which qualities you would like to show in the Party Loot Feed."
-- L["PartyLootFrameDesc"] = "Position and anchor the party loot feed."
-- L["PartyLootFrameSizeDesc"] = "Customize the sizing of the party loot feed and its elements."
-- L["PartyLootFrameStyleDesc"] = "Style the party loot frame's feed and its elements with custom colors, alignment, etc."
-- L["Pending Items"] = "%s pending items"
-- L["Play Sound for Items Better Than Equipped"] = "Play Sound for Items Better Than Equipped"
-- L["Play Sound for Legendary Items"] = "Play Sound for Legendary Items"
-- L["Play Sound for Mounts"] = "Play Sound for Mounts"
-- L["PlayerFrame"] = "PlayerFrame"
-- L["PlaySoundForBetterDesc"] = "Play a sound when an item better than what you have equipped is looted"
-- L["PlaySoundForLegendaryDesc"] = "Play a sound when a legendary item is looted"
-- L["PlaySoundForMountsDesc"] = "Play a sound when a mount is looted"
-- L["Poor"] = "Poor"
-- L["Positioning"] = "Positioning"
-- L["PositioningDesc"] = "Position and anchor the loot feed."
-- L["Prices for Sellable Items"] = "Prices for Sellable Items"
-- L["PricesForSellableItemsDesc"] = "Select which price to show for sellable items in the Loot Feed"
-- L["Profession Config"] = "Profession Config"
-- L["Profession Options"] = "Profession Options"
-- L["Rare"] = "Rare"
-- L["RelativeToDesc"] = "Select a frame to anchor the loot feed to"
-- L["Rep messages Disabled"] = "Rep messages Disabled"
-- L["RepColorDesc"] = "The default color of the reputation text in the loot feed. Overridden by faction colors."
-- L["RepLevelColorDesc"] = "The color of the reputation level text in the loot feed."
-- L["RepLevelWrapCharDesc"] = "The characters to wrap the reputation level text with."
-- L["Reputation Config"] = "Reputation Config"
-- L["Reputation Level Color"] = "Reputation Level Color"
-- L["Reputation Level Options"] = "Reputation Level Options"
-- L["Reputation Level Wrap Character"] = "Reputation Level Wrap Character"
-- L["Reputation Options"] = "Reputation Options"
-- L["Reset All Duration Overrides"] = "Reset All Duration Overrides"
-- L["ResetAllDurationOverridesDesc"] = "Reset all duration overrides to the default value"
-- L["Right"] = "Right"
-- L["Row Border Color"] = "Row Border Color"
-- L["Row Border Thickness"] = "Row Border Thickness"
-- L["Row Borders"] = "Row Borders"
-- L["Row Enter Animation"] = "Row Enter Animation"
-- L["Row Exit Animation"] = "Row Exit Animation"
-- L["RowBorderColorDesc"] = "The color of the row border."
-- L["RowBordersDesc"] = "Customize the row borders."
-- L["RowBorderThicknessDesc"] = "The thickness of the row border."
-- L["RowEnterAnimationDesc"] = "Customize the enter animations of the loot feed rows."
-- L["RowExitAnimationDesc"] = "Customize the exit animations of the loot feed rows."
-- L["RowHeightDesc"] = "The height of each item 'row' in the loot feed"
-- L["RowPaddingDesc"] = "The amount of space between item 'rows' in the loot feed"
-- L["Screen"] = "Screen"
-- L["Secondary Font Size"] = "Secondary Font Size"
-- L["Secondary Text Alpha"] = "Secondary Text Alpha"
-- L["SecondaryFontSizeDesc"] = "The size of the secondary text in the loot feed in \"points\"."
-- L["SecondaryTextAlphaDesc"] = "The alpha of the reputation secondary text in the loot feed."
-- L["Separate Frame"] = "Separate Frame"
-- L["SeparateFrameDesc"] = "Show party/raid looted items in a separate frame"
-- L["Shadow Color"] = "Shadow Color"
-- L["Shadow Offset X"] = "Shadow Offset X"
-- L["Shadow Offset Y"] = "Shadow Offset Y"
-- L["ShadowColorDesc"] = "The color of the shadow behind the loot feed text."
-- L["ShadowOffsetHelp"] = "Negative values for shadows to the left or below text. -1 is usually desired for font sizes 8-10. Set both offsets to 0 to disable shadow."
-- L["ShadowOffsetXDesc"] = "The horizontal offset of the shadow behind the loot feed text. Negative values for shadows to the left of text. -1 is usually desired for font sizes 8-10. 0 to disable horizontal shadow."
-- L["ShadowOffsetYDesc"] = "The vertical offset of the shadow behind the loot feed text. Negative values for shadows below text. -1 is usually desired for font sizes 8-10. 0 to disable vertical shadow."
-- L["Show Current Level"] = "Show Current Level"
-- L["Show Minimap Icon"] = "Show Minimap Icon"
-- L["Show Money Total"] = "Show Money Total"
-- L["Show only when SHIFT is held"] = "Show only when SHIFT is held"
-- L["Show Skill Change"] = "Show Skill Change"
-- L["ShowCurrentLevelDesc"] = "Show your current level in XP gain rows."
-- L["ShowMinimapIconDesc"] = "Show the RPGLootFeed minimap icon"
-- L["ShowMoneyTotalDesc"] = "Show the total amount of money on the current character in the Loot Feed"
-- L["ShowSkillChangeDesc"] = "Show the change in skill levels."
-- L["Sizing"] = "Sizing"
-- L["SizingDesc"] = "Customize the sizing of the feed and its elements."
-- L["Skill Change Options"] = "Skill Change Options"
-- L["Skill messages Disabled"] = "Skill messages Disabled"
-- L["Skill Text Color"] = "Skill Text Color"
-- L["Skill Text Wrap Character"] = "Skill Text Wrap Character"
-- L["SkillColorDesc"] = "The color of the skill text in the loot feed."
-- L["SkillTextWrapCharDesc"] = "The characters to wrap the skill text with."
-- L["Slide"] = "Slide"
-- L["Slide Direction"] = "Slide Direction"
-- L["SlideDirectionDesc"] = "The direction for the row to travel during a slide animation."
-- L["Socket"] = "Socket"
-- L["Spaces"] = " Spaces "
-- L["Square Brackets"] = "[Square Brackets]"
-- L["Styling"] = "Styling"
-- L["StylingDesc"] = "Style the feed and its elements with custom colors, alignment, etc."
-- L["Test Mode Disabled"] = "Test Mode Disabled"
-- L["Test Mode Enabled"] = "Test Mode Enabled"
-- L["Thick Outline"] = "Thick Outline"
-- L["ThousandAbbrev"] = "K"
-- L["TipsLink"] = "Tips appreciated, never expected |T166311:0|t (copy/paste below)"
-- L["Toggle Loot History"] = "Toggle Loot History"
-- L["Toggle Test Mode"] = "Toggle Test Mode"
-- L["Tooltip"] = "Tooltip"
-- L["Tooltip Options"] = "Tooltip Options"
-- L["Top"] = "Top"
-- L["Top Left"] = "Top Left"
-- L["Top Left Icon Font Size"] = "Top Left Icon Font Size"
-- L["Top Left Icon Text Color"] = "Top Left Icon Text Color"
-- L["Top Left Icon Text Options"] = "Top Left Icon Text Options"
-- L["Top Right"] = "Top Right"
-- L["TopLeftIconFontSizeDesc"] = "The size of the top left icon text in the loot feed in \"points\"."
-- L["TopLeftIconTextColorDesc"] = "The color of the top left icon text in the loot feed."
-- L["Travel Point Options"] = "Travel Point Options"
-- L["Travel Points Config"] = "Travel Points Config"
-- L["Travel Points Text Color"] = "Travel Points Text Color"
-- L["TravelPointsTextColorDesc"] = "The color of the travel points text in the loot feed."
-- L["TSM"] = "TSM"
-- L["UIParent"] = "UIParent"
-- L["Uncommon"] = "Uncommon"
-- L["Up"] = "Up"
-- L["Update Animation Duration"] = "Update Animation Duration"
-- L["Update Animations"] = "Update Animations"
-- L["UpdateAnimationDurationDesc"] = "The number of seconds the update animation will take."
-- L["UpdateAnimationsDesc"] = "Customize animations when the quantity is updated on an existing row in the loot feed."
-- L["Use Class Colors for Borders"] = "Use Class Colors for Borders"
-- L["Use Font Objects"] = "Use Font Objects"
-- L["Use Quality Color"] = "Use Quality Color"
-- L["UseClassColorsForBordersDesc"] = "If checked, use class colors for the row borders."
-- L["UseFontObjectsDesc"] = "If checked, use a font object to determine font face and font size."
-- L["UseQualityColorDesc"] = "If checked, the top left icon text will use the item quality color."
-- L["Vendor Price"] = "Vendor Price"
-- L["Version"] = "RPGLootFeed Version: %s"
-- L["View Notifications"] = "View %d Notifications"
-- L["Welcome"] = "Welcome! Use /rlf to view options."
-- L["X Offset"] = "X Offset"
-- L["XOffsetDesc"] = "Adjust the loot feed left (negative) or right (positive)"
-- L["XP"] = "XP"
-- L["XP messages Disabled"] = "XP messages Disabled"
-- L["Y Offset"] = "Y Offset"
-- L["YOffsetDesc"] = "Adjust the loot feed down (negative) or up (positive)"
-- L["You have Notifications"] = "You have %d Notifications"
--#endregion
