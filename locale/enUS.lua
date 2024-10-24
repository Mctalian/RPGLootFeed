local _, G_RLF = ...

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

-- CHAT_MSG_MONEY
L["Gold"] = true
L["Silver"] = true
L["Copper"] = true

-- Experience
L["XP"] = true

-- ConfigOptions
L["Toggle Test Mode"] = true
L["Clear rows"] = true
L["Toggle Area"] = true
L["Toggle Loot History"] = true

-- ConfigOptions - Features Group
L["Features"] = true
L["FeaturesDesc"] = "Enable or Disable different RPGLootFeed features"
L["Enable Loot History"] = true
L["EnableLootHistoryDesc"] = "Store a history of looted items and display them in a separate frame"
L["Loot History Size"] = true
L["LootHistorySizeDesc"] = "The maximum number of items to store in the loot history"
L["Enable Party Loot in Feed"] = true
L["EnablePartyLootDesc"] = "Show party/raid looted items in the Loot Feed"
L["Enable Item Loot in Feed"] = true
L["EnableItemLootDesc"] = "Show looted items in the Loot Feed"
L["Item Loot Config"] = true
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
L["Enable Currency in Feed"] = true
L["EnableCurrencyDesc"] = "Show currency such as Flightstones, Honor, Drake's Awakened Crest, etc. in the Loot Feed"
L["Enable Item/Currency Tooltips"] = true
L["EnableTooltipsDesc"] = "Enable showing Item/Currency Tooltips on mouseover, never shows in combat."
L["Tooltip Options"] = true
L["Show only when SHIFT is held"] = true
L["OnlyShiftOnEnterDesc"] = "Only show the tooltip if Shift is held as you mouseover the item/currency."
L["Enable Money in Feed"] = true
L["EnableMoneyDesc"] = "Show money, like Gold, Silver, Copper, in the Loot Feed"
L["Enable Experience in Feed"] = true
L["EnableXPDesc"] = "Show experience gains in the Loot Feed"
L["Enable Reputation in Feed"] = true
L["EnableRepDesc"] = "Show reputation gains in the Loot Feed"

-- ConfigOptions - Positioning Group
L["Toggle Test Mode"] = true
L["Clear rows"] = true
L["Toggle Area"] = true
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
L["Row Styling"] = true
L["StylingDesc"] = "Style the feed and its elements with custom colors, alignment, etc."
L["Left Align"] = true
L["LeftAlignDesc"] = "Left align row content (right align if unchecked)"
L["Grow Up"] = true
L["GrowUpDesc"] = "The feed will grow up (down if unchecked) as new items are added"
L["Background Gradient Start"] = true
L["GradientStartDesc"] = "The start color of the row background gradient."
L["Background Gradient End"] = true
L["GradientEndDesc"] = "The end color of the row background gradient."
L["Disable Row Highlight"] = true
L["DisableRowHighlightDesc"] = "If checked, don't highlight a row when you loot the same item again and the quanity is updated."
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
L["FontSizeDesc"] = "The size of the loot feed text in \"points\"."
L["Secondary Font Size"] = true
L["SecondaryFontSizeDesc"] = "The size of the secondary text in the loot feed in \"points\"."

-- ConfigOptions - Timing Group
L["Timing"] = true
L["TimingDesc"] = "Adjust fade out delays and other timing-related options."
L["Fade Out Delay"] = true
L["FadeOutDelayDesc"] = "The number of seconds to show the loot row before it fades out."

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
