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
L["Test Mode Enabled"] = true
L["Test Mode Disabled"] = true
L["Item Loot messages Disabled"] = true
L["Currency messages Disabled"] = true
L["Money messages Disabled"] = true
L["XP messages Disabled"] = true
L["Rep messages Disabled"] = true

-- Count Text Wrap Character
L["Spaces"] = " Spaces "
L["Parentheses"] = "(Parentheses)"
L["Square Brackets"] = "[Square Brackets]"
L["Curly Braces"] = "{Curly Braces}"
L["Angle Brackets"] = "<Angle Brackets>"
L["Bars"] = "|Bars|"

-- Experience
L["XP"] = true

L["Close"] = true
L["LauncherLeftClick"] = "|cffeda55fClick|r to open addon config menu."
L["LauncherRightClick"] = "|cffeda55fRight-click|r to open a quick-menu."

-- ConfigOptions
L["Toggle Test Mode"] = true
L["Clear rows"] = true
L["Toggle Loot History"] = true

-- ConfigOptions - Features Group
L["Features"] = true
L["FeaturesDesc"] = "Enable or Disable different RPGLootFeed features"
L["Loot Feeds"] = true
L["Miscellaneous"] = true
L["Show Minimap Icon"] = true
L["ShowMinimapIconDesc"] = "Show the RPGLootFeed minimap icon"
L["Enable Loot History"] = true
L["Loot History"] = true
L["Party Loot History"] = true
L["EnableLootHistoryDesc"] = "Store a history of looted items and display them in a separate frame"
L["Loot History Size"] = true
L["LootHistorySizeDesc"] = "The maximum number of items to store in the loot history"
L["Hide Loot History Tab"] = true
L["HideLootHistoryTabDesc"] = "Hide the loot history tab attached to the Loot Feed"
L["Enable Party Loot in Feed"] = true
L["EnablePartyLootDesc"] = "Show party/raid looted items in the Loot Feed"
L["Enable Item Loot in Feed"] = true
L["EnableItemLootDesc"] = "Show looted items in the Loot Feed"
L["Item Loot Config"] = true
L["Item Loot Options"] = true
L["Item Count Text"] = true
L["Enable Item Count Text"] = true
L["EnableItemCountTextDesc"] = "Show the your total count (bags, bank, etc.) of the looted item in the Loot Feed"
L["Item Count Text Wrap Character"] = true
L["ItemCountTextWrapCharDesc"] = "The character to wrap the item count text with."
L["Item Count Text Color"] = true
L["ItemCountTextColorDesc"] = "The color of the item count text in the loot feed."
L["Item Secondary Text Options"] = true
L["Prices for Sellable Items"] = true
L["PricesForSellableItemsDesc"] = "Select which price to show for sellable items in the Loot Feed"
L["None"] = true
L["Vendor Price"] = true
L["Auctionator"] = true
L["TSM"] = true
L["Auction House Source"] = true
L["AuctionHouseSourceDesc"] = "Select the source addon for Auction House pricing information"
L["Auction Price"] = true
L["Item Quality Filter"] = true
L["ItemQualityFilterDesc"] = "Check which qualities you would like to show in the Loot Feed."
L["Poor"] = true
L["Common"] = true
L["Uncommon"] = true
L["Rare"] = true
L["Epic"] = true
L["Legendary"] = true
L["Artifact"] = true
L["Heirloom"] = true
L["Item Highlights"] = true
L["ItemHighlightsDesc"] = "Highlight items in the Loot Feed based on certain criteria"
L["Highlight Mounts"] = true
L["HighlightMountsDesc"] = "Highlight Mounts in the Loot Feed"
L["Highlight Legendary Items"] = true
L["HighlightLegendaryDesc"] = "Highlight Legendary items in the Loot Feed"
L["Highlight Items Better Than Equipped"] = true
L["HighlightBetterThanEquippedDesc"] = "Highlight items that are better than what you have equipped in the Loot Feed"
L["Play Sound for Mounts"] = true
L["PlaySoundForMountsDesc"] = "Play a sound when a mount is looted"
L["Mount Sound"] = true
L["MountSoundDesc"] = "The sound to play when a mount is looted"
L["Play Sound for Legendary Items"] = true
L["PlaySoundForLegendaryDesc"] = "Play a sound when a legendary item is looted"
L["Legendary Sound"] = true
L["LegendarySoundDesc"] = "The sound to play when a legendary item is looted"
L["Play Sound for Items Better Than Equipped"] = true
L["PlaySoundForBetterDesc"] = "Play a sound when an item better than what you have equipped is looted"
L["Better Than Equipped Sound"] = true
L["BetterThanEquippedSoundDesc"] = "The sound to play when an item better than what you have equipped is looted"
L["Item Loot Sounds"] = true
L["Party Loot"] = true
L["Party Loot Config"] = true
L["Party Loot Options"] = true
L["Separate Frame"] = true
L["SeparateFrameDesc"] = "Show party/raid looted items in a separate frame"
L["Hide Server Names"] = true
L["HideServerNamesDesc"] = "Hide server names in the Party Loot Feed"
L["Party Item Quality Filter"] = true
L["PartyItemQualityFilterDesc"] = "Check which qualities you would like to show in the Party Loot Feed."
L["Only Epic and Above in Raid"] = true
L["OnlyEpicAndAboveInRaidDesc"] = "Only show Epic and above items in the Party Loot Feed in a raid group"
L["Only Epic and Above in Instance"] = true
L["OnlyEpicAndAboveInInstanceDesc"] = "Only show Epic and above items in the Party Loot Feed in an instance group"
L["Ignore Item IDs"] = true
L["IgnoreItemIDsDesc"] = "Enter a comma-separated list of item IDs to ignore in the Party Loot Feed"
L["Enable Currency in Feed"] = true
L["EnableCurrencyDesc"] = "Show currency such as Flightstones, Honor, Drake's Awakened Crest, etc. in the Loot Feed"
L["Currency Config"] = true
L["Currency Options"] = true
L["Currency Total Text Options"] = true
L["Enable Currency Total Text"] = true
L["EnableCurrencyTotalTextDesc"] = "Show the total amount of currency on the current character in the Loot Feed"
L["Currency Total Text Color"] = true
L["CurrencyTotalTextColorDesc"] = "The color of the currency total text in the loot feed."
L["Currency Total Text Wrap Character"] = true
L["CurrencyTotalTextWrapCharDesc"] = "The characters to wrap the currency total text with."
L["Enable Item/Currency Tooltips"] = true
L["EnableTooltipsDesc"] = "Enable showing Item/Currency Tooltips on mouseover, never shows in combat."
L["Tooltip Options"] = true
L["Show only when SHIFT is held"] = true
L["OnlyShiftOnEnterDesc"] = "Only show the tooltip if Shift is held as you mouseover the item/currency."
L["Enable Money in Feed"] = true
L["EnableMoneyDesc"] = "Show money, like Gold, Silver, Copper, in the Loot Feed"
L["Money Config"] = true
L["Money Options"] = true
L["Money Total Options"] = true
L["ShowMoneyTotalDesc"] = "Show the total amount of money on the current character in the Loot Feed"
L["Abbreviate Total"] = true
L["AbbreviateTotalDesc"] = "Abbreviate the total money amount in the Loot Feed (for gold over 1000)"
L["Show Money Total"] = true
L["BillionAbbrev"] = "B"
L["MillionAbbrev"] = "M"
L["ThousandAbbrev"] = "K"
L["Accountant Mode"] = true
L["AccountantModeDesc"] = "Show the negative money amounts in parentheses instead of a negative sign."
L["Money Loot Sound"] = true
L["Override Money Loot Sound"] = true
L["MoneyLootSoundDesc"] = "Override the default money loot sound with a custom sound."
L["OverrideMoneyLootSoundDesc"] = "If checked, use a custom sound for money loot."
L["Enable Experience in Feed"] = true
L["EnableXPDesc"] = "Show experience gains in the Loot Feed"
L["Experience Config"] = true
L["Experience Options"] = true
L["Experience Text Color"] = true
L["ExperienceTextColorDesc"] = "The color of the experience text in the loot feed."
L["Current Level Options"] = true
L["Show Current Level"] = true
L["ShowCurrentLevelDesc"] = "Show your current level in XP gain rows."
L["Current Level Color"] = true
L["CurrentLevelColorDesc"] = "The color of the current level text in the loot feed."
L["Current Level Text Wrap Character"] = true
L["CurrentLevelTextWrapCharDesc"] = "The characters to wrap the current level text with."
L["Enable Reputation in Feed"] = true
L["EnableRepDesc"] = "Show reputation gains in the Loot Feed"
L["Reputation Config"] = true
L["Reputation Options"] = true
L["Default Rep Text Color"] = true
L["RepColorDesc"] = "The default color of the reputation text in the loot feed. Overridden by faction colors."
L["Secondary Text Alpha"] = true
L["SecondaryTextAlphaDesc"] = "The alpha of the reputation secondary text in the loot feed."
L["Reputation Level Options"] = true
L["Enable Reputation Level"] = true
L["EnableRepLevelDesc"] = "Show the reputation level in the loot feed."
L["Reputation Level Color"] = true
L["RepLevelColorDesc"] = "The color of the reputation level text in the loot feed."
L["Reputation Level Wrap Character"] = true
L["RepLevelWrapCharDesc"] = "The characters to wrap the reputation level text with."
L["Profession Config"] = true
L["Profession Options"] = true
L["Enable Professions in Feed"] = true
L["EnableProfDesc"] = "Show profession skill gains in the Loot Feed"
L["Skill Change Options"] = true
L["Show Skill Change"] = true
L["ShowSkillChangeDesc"] = "Show the change in skill levels."
L["Skill Text Color"] = true
L["SkillColorDesc"] = "The color of the skill text in the loot feed."
L["Skill Text Wrap Character"] = true
L["SkillTextWrapCharDesc"] = "The characters to wrap the skill text with."

-- ConfigOptions - Positioning Group
L["Positioning"] = true
L["Drag to Move"] = true
L["PositioningDesc"] = "Position and anchor the loot feed."
L["Anchor Relative To"] = true
L["RelativeToDesc"] = "Select a frame to anchor the loot feed to"
L["Screen"] = true
L["UIParent"] = true
L["PlayerFrame"] = true
L["Minimap"] = true
L["BagBar"] = true
L["Anchor Point"] = true
L["AnchorPointDesc"] = "Where on the screen to base the loot feed positioning (also impacts sizing direction)"
L["Top Left"] = true
L["Top Right"] = true
L["Bottom Left"] = true
L["Bottom Right"] = true
L["Top"] = true
L["Bottom"] = true
L["Left"] = true
L["Right"] = true
L["Down"] = true
L["Up"] = true
L["Center"] = true
L["X Offset"] = true
L["XOffsetDesc"] = "Adjust the loot feed left (negative) or right (positive)"
L["Y Offset"] = true
L["YOffsetDesc"] = "Adjust the loot feed down (negative) or up (positive)"
L["Frame Strata"] = true
L["FrameStrataDesc"] = "Adjust the strata (screen depth, z-index, etc.) of the loot feed frame"
L["Background"] = true
L["Low"] = true
L["Medium"] = true
L["High"] = true
L["Dialog"] = true
L["Tooltip"] = true

-- ConfigOptions - Sizing Group
L["Sizing"] = true
L["SizingDesc"] = "Customize the sizing of the feed and its elements."
L["Feed Width"] = true
L["FeedWidthDesc"] = "The width of the loot feed parent frame"
L["Maximum Rows to Display"] = true
L["MaxRowsDesc"] = "The maximum number of loot items to display in the feed"
L["Loot Item Height"] = true
L["RowHeightDesc"] = "The height of each item 'row' in the loot feed"
L["Loot Item Icon Size"] = true
L["IconSizeDesc"] = "The size of the icons in each item 'row' in the loot feed"
L["Loot Item Padding"] = true
L["RowPaddingDesc"] = "The amount of space between item 'rows' in the loot feed"

-- ConfigOptions - Styling Group
L["Styling"] = true
L["StylingDesc"] = "Style the feed and its elements with custom colors, alignment, etc."
L["Left Align"] = true
L["LeftAlignDesc"] = "Left align row content (right align if unchecked)"
L["Grow Up"] = true
L["GrowUpDesc"] = "The feed will grow up (down if unchecked) as new items are added"
L["Background Gradient Start"] = true
L["GradientStartDesc"] = "The start color of the row background gradient."
L["Background Gradient End"] = true
L["GradientEndDesc"] = "The end color of the row background gradient."
L["Row Borders"] = true
L["RowBordersDesc"] = "Customize the row borders."
L["Enable Row Borders"] = true
L["EnableRowBordersDesc"] = "If checked, show borders around each row in the loot feed."
L["Row Border Thickness"] = true
L["RowBorderThicknessDesc"] = "The thickness of the row border."
L["Row Border Color"] = true
L["RowBorderColorDesc"] = "The color of the row border."
L["Use Class Colors for Borders"] = true
L["UseClassColorsForBordersDesc"] = "If checked, use class colors for the row borders."
L["Enable Secondary Row Text"] = true
L["EnableSecondaryRowTextDesc"] = "If checked, show secondary row text, such as item level, secondary stats, vendor price, etc. if applicable."
L["Use Font Objects"] = true
L["UseFontObjectsDesc"] = "If checked, use a font object to determine font face and font size."
L["Font"] = true
L["FontDesc"] = "The font object for the loot text."
L["Custom Fonts"] = true
L["CustomFontsDesc"] = "Customize the font face, font sizing, and font flags to personalize the loot feed."
L["Font Face"] = true
L["FontFaceDesc"] = "The style of the text that will show in the loot feed."
L["Font Size"] = true
L["FontSizeDesc"] = "The size of he loot feed text in \"points\"."
L["Font Flags"] = true
L["FontFlagsDesc"] = "The flags to apply to the loot feed text."
L["Outline"] = true
L["Thick Outline"] = true
L["Monochrome"] = true
L["Shadow Color"] = true
L["ShadowColorDesc"] = "The color of the shadow behind the loot feed text."
L["ShadowOffsetHelp"] = "Negative values for shadows to the left or below text. -1 is usually desired for font sizes 8-10. Set both offsets to 0 to disable shadow."
L["Shadow Offset X"] = true
L["ShadowOffsetXDesc"] = "The horizontal offset of the shadow behind the loot feed text. Negative values for shadows to the left of text. -1 is usually desired for font sizes 8-10. 0 to disable horizontal shadow."
L["Shadow Offset Y"] = true
L["ShadowOffsetYDesc"] = "The vertical offset of the shadow behind the loot feed text. Negative values for shadows below text. -1 is usually desired for font sizes 8-10. 0 to disable vertical shadow."
L["Secondary Font Size"] = true
L["SecondaryFontSizeDesc"] = "The size of the secondary text in the loot feed in \"points\"."

-- ConfigOptions - Animations Group
L["Animations"] = true
L["AnimationsDesc"] = "Customize the animations of the loot feed."
L["Row Enter Animation"] = true
L["RowEnterAnimationDesc"] = "Customize the enter animations of the loot feed rows."
L["Enter Animation Type"] = true
L["EnterAnimationTypeDesc"] = "The type of animation to use when a new row is added to the loot feed."
L["Enter Animation Duration"] = true
L["EnterAnimationDurationDesc"] = "The number of seconds the enter animation will take."
L["Exit Animation Type"] = true
L["ExitAnimationTypeDesc"] = "The type of animation to use when a row is removed from the loot feed."
L["Exit Animation Duration"] = true
L["ExitAnimationDurationDesc"] = "The number of seconds the exit animation will take."
L["Row Exit Animation"] = true
L["RowExitAnimationDesc"] = "Customize the exit animations of the loot feed rows."
L["Fade"] = true
L["Slide"] = true
L["Slide Direction"] = true
L["SlideDirectionDesc"] = "The direction for the row to travel during a slide animation."
L["Fade Out Delay"] = true
L["FadeOutDelayDesc"] = "The number of seconds to show the loot row before it fades out."
L["Hover Animation"] = true
L["HoverAnimationDesc"] = "Customize animations when hovering over a row in the loot feed."
L["Enable Hover Animation"] = true
L["EnableHoverAnimationDesc"] = "If checked, hovering over a row will highlight it."
L["Hover Alpha"] = true
L["HoverAlphaDesc"] = "The alpha of the row highlight when hovered over."
L["Base Duration"] = true
L["BaseDurationDesc"] = "The number of seconds the hover animation will take."
L["Update Animations"] = true
L["UpdateAnimationsDesc"] = "Customize animations when the quantity is updated on an existing row in the loot feed."
L["Disable Highlight"] = true
L["DisableHighlightDesc"] = "If checked, don't highlight a row's border when you loot the same item again and the quanity is updated."
L["Update Animation Duration"] = true
L["UpdateAnimationDurationDesc"] = "The number of seconds the update animation will take."
L["Loop Update Highlight"] = true
L["LoopUpdateHighlightDesc"] = "If checked, the highlight animation will loop when the quantity is updated."

-- ConfigOptions - Blizzard UI Group
L["Blizzard UI"] = true
L["BlizzUIDesc"] = "Override behavior of Blizzard-related UI elements"
L["Disable Loot Toasts"] = true
L["DisableLootToastDesc"] = "The boxes that appear at the bottom of the screen when you loot special items"
L["Disable Money Alerts"] = true
L["DisableMoneyAlertsDesc"] = "The boxes that appear at the bottom of the screen when you receive money, for example world quest rewards"
L["Enable Auto Loot"] = true
L["EnableAutoLootDesc"] = "Set the default setting so that auto loot is enabled when logging into any character"
L["Alerts"] = true
L["Disable Boss Banner Elements"] = true
L["DisableBossBannerDesc"] = "Override the Boss Banner. Completely hide it, only hide the loot portion, or only hide your loot or your party's loot."
L["Do not disable BossBanner"] = true
L["Disable All BossBanner"] = true
L["Disable All BossBanner Loot"] = true
L["Only Disable My BossBanner Loot"] = true
L["Disable Party/Raid Loot"] = true
L["Chat"] = true
L["Disable Loot Chat Messages"] = true
L["DisableLootChatMessagesDesc"] = "Disables Loot Chat Messages in all chat windows."
L["Disable Currency Chat Messages"] = true
L["DisableCurrencyChatMessagesDesc"] = "Disables Currency Chat Messages in all chat windows."
L["Disable Money Chat Messages"] = true
L["DisableMoneyChatMessagesDesc"] = "Disables Money Chat Messages in all chat windows."
L["Disable Experience Chat Messages"] = true
L["DisableExperienceChatMessagesDesc"] = "Disables Experience Chat Messages in all chat windows."
L["Disable Reputation Chat Messages"] = true
L["DisableReputationChatMessagesDesc"] = "Disables Reputation Chat Messages in all chat windows."
