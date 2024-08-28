local L = LibStub("AceLocale-3.0"):NewLocale(G_RLF.localeName, "zhCN")
if not L then
	return
end

-- 聊天窗口打印
L["Welcome"] = "欢迎！使用/rlf来查看选项。"
L["AddLootAlertUnavailable"] = "LootAlertSystem:AddAlert超过30秒不可用，无法禁用战利品提示。"
L["BossBannerAlertUnavailable"] = "BossBanner:OnEvent超过30秒不可用，无法禁用Boss Banner元素。"
L["Issues"] = "请在github上报告此问题：McTalian/RPGLootFeed"
L["Test Mode Enabled"] = "测试模式已启用"
L["Test Mode Disabled"] = "测试模式已禁用"
L["Item Loot messages Disabled"] = "物品战利品消息已禁用"
L["Currency messages Disabled"] = "货币消息已禁用"
L["Money messages Disabled"] = "金钱消息已禁用"
L["XP messages Disabled"] = "经验值消息已禁用"
L["Rep messages Disabled"] = "声望消息已禁用"

-- 货币聊天消息
L["Gold"] = "金币"
L["Silver"] = "银币"
L["Copper"] = "铜币"

-- 经验值
L["XP"] = "经验值"

-- 配置选项
L["Toggle Test Mode"] = "切换测试模式"
L["Clear rows"] = "清除信息流"
L["Toggle Area"] = "切换区域"

-- 配置选项 - 功能组
L["Features"] = "功能"
L["FeaturesDesc"] = "启用或禁用不同的RPGLootFeed功能"
L["Enable Item Loot in Feed"] = "在信息流中启用物品战利品"
L["EnableItemLootDesc"] = "在战利品信息流中显示战利品物品"
L["Enable Currency in Feed"] = "在信息流中启用货币"
L["EnableCurrencyDesc"] = "在战利品信息流中显示货币，例如飞行石、荣誉、德拉克觉醒纹章等"
L["Enable Money in Feed"] = "在信息流中启用金钱"
L["EnableMoneyDesc"] = "在战利品信息流中显示金钱，如金币、银币、铜币"
L["Enable Experience in Feed"] = "在信息流中启用经验值"
L["EnableXPDesc"] = "在战利品信息流中显示经验值收益"
L["Enable Reputation in Feed"] = "在信息流中启用声望"
L["EnableRepDesc"] = "在战利品信息流中显示声望收益"

-- 配置选项 - 定位组
L["Toggle Test Mode"] = "切换测试模式"
L["Clear rows"] = "清除行"
L["Toggle Area"] = "切换区域"
L["Positioning"] = "定位"
L["PositioningDesc"] = "定位并锚定战利品信息流。"
L["Anchor Relative To"] = "相对于"
L["RelativeToDesc"] = "选择一个框架作为战利品信息流的锚点"
L["Anchor Point"] = "锚点"
L["AnchorPointDesc"] = "屏幕上战利品信息流定位的基准点（也影响大小方向）"
L["Top Left"] = "左上"
L["Top Right"] = "右上"
L["Bottom Left"] = "左下"
L["Bottom Right"] = "右下"
L["Top"] = "顶部"
L["Bottom"] = "底部"
L["Left"] = "左侧"
L["Right"] = "右侧"
L["Center"] = "中心"
L["X Offset"] = "X偏移"
L["XOffsetDesc"] = "调整战利品信息流向左（负值）或向右（正值）"
L["Y Offset"] = "Y偏移"
L["YOffsetDesc"] = "调整战利品信息流向下（负值）或向上（正值）"

-- 配置选项 - 尺寸组
L["Sizing"] = "尺寸"
L["SizingDesc"] = "自定义信息流及其元素的尺寸。"
L["Feed Width"] = "信息流宽度"
L["FeedWidthDesc"] = "战利品信息流父框架的宽度"
L["Maximum Rows to Display"] = "最大显示行数"
L["MaxRowsDesc"] = "在信息流中显示的战利品项目的最大数量"
L["Loot Item Height"] = "战利品项目高度"
L["RowHeightDesc"] = "战利品信息流中每个项目“行”的高度"
L["Loot Item Icon Size"] = "战利品项目图标大小"
L["IconSizeDesc"] = "战利品信息流中每个项目“行”的图标大小"
L["Loot Item Padding"] = "战利品项目间距"
L["RowPaddingDesc"] = "战利品信息流中项目“行”之间的空间量"

-- 配置选项 - 样式组
L["Styling"] = "样式"
L["Row Styling"] = "行样式"
L["StylingDesc"] = "使用自定义颜色、对齐方式等来设置信息流及其元素的样式。"
L["Left Align"] = "左对齐"
L["LeftAlignDesc"] = "左对齐行内容（如果未选中，则右对齐）"
L["Background Gradient Start"] = "背景渐变开始"
L["GradientStartDesc"] = "行背景渐变的起始颜色。"
L["Background Gradient End"] = "背景渐变结束"
L["GradientEndDesc"] = "行背景渐变的结束颜色。"
L["Font"] = "字体"
L["FontDesc"] = "战利品文本的字体对象。"

-- 配置选项 - 定时组
L["Timing"] = "定时"
L["TimingDesc"] = "调整淡出延迟和其他与时间相关的选项。"
L["Fade Out Delay"] = "淡出延迟"
L["FadeOutDelayDesc"] = "战利品行显示的秒数，之后开始淡出。"

-- 配置选项 - 暴雪UI组
L["Blizzard UI"] = "暴雪用户界面"
L["BlizzUIDesc"] = "覆盖暴雪相关UI元素的行为"
L["Disable Loot Toasts"] = "禁用战利品提示"
L["DisableLootToastDesc"] = "当你拾取特殊物品时，在屏幕底部出现的提示框"
L["Enable Auto Loot"] = "启用自动拾取"
L["EnableAutoLootDesc"] = "设置默认设置，以便在登录任何角色时自动拾取处于启用状态"
L["Alerts"] = "警报"
L["Disable Boss Banner Elements"] = "禁用Boss Banner元素"
L["DisableBossBannerDesc"] =
	"覆盖Boss Banner。完全隐藏它，只隐藏战利品部分，或者只隐藏你的战利品或你的队伍的战利品。"
L["Do not disable BossBanner"] = "不禁用BossBanner"
L["Disable All BossBanner"] = "禁用所有BossBanner"
L["Disable All BossBanner Loot"] = "禁用所有BossBanner战利品"
L["Only Disable My BossBanner Loot"] = "只禁用我的BossBanner战利品"
L["Disable Party/Raid Loot"] = "禁用队伍/团队战利品"
L["Chat"] = "聊天"
L["Disable Loot Chat Messages"] = "禁用战利品聊天消息"
L["DisableLootChatMessagesDesc"] = "在所有聊天窗口中禁用战利品聊天消息。"
L["Disable Currency Chat Messages"] = "禁用货币聊天消息"
L["DisableCurrencyChatMessagesDesc"] = "在所有聊天窗口中禁用货币聊天消息。"
L["Disable Money Chat Messages"] = "禁用金钱聊天消息"
L["DisableMoneyChatMessagesDesc"] = "在所有聊天窗口中禁用金钱聊天消息。"
L["Disable Experience Chat Messages"] = "禁用经验聊天消息"
L["DisableExperienceChatMessagesDesc"] = "在所有聊天窗口中禁用经验聊天消息。"
L["Disable Reputation Chat Messages"] = "禁用声望聊天消息"
L["DisableReputationChatMessagesDesc"] = "在所有聊天窗口中禁用声望聊天消息。"
