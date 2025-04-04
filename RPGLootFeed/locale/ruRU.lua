---@type string, G_RLF
local _, G_RLF = ...

local L = LibStub("AceLocale-3.0"):NewLocale(G_RLF.localeName, "ruRU")
if not L then
	return
end

-- Сообщения в окне чата
L["Welcome"] = "Добро пожаловать! Используйте /rlf для просмотра настроек."
L["AddLootAlertUnavailable"] = "LootAlertSystem:AddAlert был недоступен более 30 секунд, уведомления о добыче не могут быть отключены :("
L["AddMoneyAlertUnavailable"] = "MoneyAlertSystem:AddAlert был недоступен более 30 секунд, уведомления о золоте не могут быть отключены :("
L["BossBannerAlertUnavailable"] = "BossBanner:OnEvent был недоступен более 30 секунд, элементы баннера босса не могут быть отключены :("
L["Issues"] = "Пожалуйста, сообщите об этой проблеме на github: McTalian/RPGLootFeed"
L["Test Mode Enabled"] = "Тестовый режим включен"
L["Test Mode Disabled"] = "Тестовый режим отключен"
L["Item Loot messages Disabled"] = "Сообщения о добыче предметов отключены"
L["Currency messages Disabled"] = "Сообщения о валюте отключены"
L["Money messages Disabled"] = "Сообщения о золоте отключены"
L["XP messages Disabled"] = "Сообщения об опыте отключены"
L["Rep messages Disabled"] = "Сообщения о репутации отключены"

-- Символы для обертывания текста количества
L["Spaces"] = " Пробелы "
L["Parentheses"] = "(Круглые скобки)"
L["Square Brackets"] = "[Квадратные скобки]"
L["Curly Braces"] = "{Фигурные скобки}"
L["Angle Brackets"] = "<Угловые скобки>"
L["Bars"] = "|Полосы|"

-- Опыт
L["XP"] = "Опыт"

L["Close"] = "Закрыть"
L["LauncherLeftClick"] = "|cffeda55fНажать|r чтобы открыть меню конфигурации аддона."
L["LauncherRightClick"] = "|cffeda55fПКМ|r чтобы открыть быстрое меню."

-- Настройки
L["Toggle Test Mode"] = "Переключить тестовый режим"
L["Clear rows"] = "Очистить строки"
L["Toggle Loot History"] = "Переключить историю добычи"

-- Настройки - Группа функций
L["Features"] = "Функции"
L["FeaturesDesc"] = "Включите или отключите различные функции RPGLootFeed"
L["Loot Feeds"] = "Лента добычи"
L["Miscellaneous"] = "Разное"
L["Show Minimap Icon"] = "Показать значок на миникарте"
L["ShowMinimapIconDesc"] = "Показать значок RPGLootFeed на мини-карте"
L["Enable Loot History"] = "Включить историю добычи"
L["Loot History"] = "История Добычи"
L["EnableLootHistoryDesc"] = "Сохранять историю добытых предметов и отображать их в отдельном окне"
L["Loot History Size"] = "Размер истории добычи"
L["LootHistorySizeDesc"] = "Максимальное количество предметов для хранения в истории добычи"
L["Hide Loot History Tab"] = "Скрыть вкладку истории добычи"
L["HideLootHistoryTabDesc"] = "Скрыть вкладку истории добычи, прикрепленную к ленте добычи"
L["Enable Party Loot in Feed"] = "Включить добычу группы в ленту"
L["EnablePartyLootDesc"] = "Показывать добытые предметы группы/рейда в ленте добычи"
L["Enable Item Loot in Feed"] = "Включить добычу предметов в ленту"
L["EnableItemLootDesc"] = "Показывать добытые предметы в ленте добычи"
L["Item Loot Config"] = "Настройка добычи предметов"
L["Item Loot Options"] = "Опции добычи предметов"
L["Item Count Text"] = "Текст количества предметов"
L["Enable Item Count Text"] = "Включить текст количества предметов"
L["EnableItemCountTextDesc"] = "Показывать общее количество (в сумках, банке и т.д.) добытого предмета в ленте добычи"
L["Item Count Text Wrap Character"] = "Предмет Количество Текст Сворачивание Персонаж"
L["ItemCountTextWrapCharDesc"] = "Персонаж для обертывания текста количества предметов."
L["Item Count Text Color"] = "Цвет текста количества предметов"
L["ItemCountTextColorDesc"] = "Цвет текста количества предметов в ленте добычи."
L["Item Secondary Text Options"] = "Опции вторичного текста предметов"
L["Prices for Sellable Items"] = "Цены для продаваемых предметов"
L["PricesForSellableItemsDesc"] = "Выберите, какую цену показывать для продаваемых предметов в ленте добычи"
L["None"] = "Нет"
L["Vendor Price"] = "Цена у продавца"
L["Auctionator"] = "Auctionator"
L["TSM"] = "TSM"
L["Auction House Source"] = "Источник аукцион"
L["AuctionHouseSourceDesc"] = "Выберите аддон для получения информации о ценах на аукционе"
L["Auction Price"] = "Цена на аукционе"
L["Item Quality Filter"] = "Фильтр качества предметов"
L["ItemQualityFilterDesc"] = "Выберите, какие качества предметов показывать в ленте добычи."
L["Poor"] = "Обычный"
L["Common"] = "Обычный"
L["Uncommon"] = "Необычный"
L["Rare"] = "Редкий"
L["Epic"] = "Эпический"
L["Legendary"] = "Легендарный"
L["Artifact"] = "Артефакт"
L["Heirloom"] = "Наследие"
L["Item Highlights"] = "Подсветка предметов"
L["ItemHighlightsDesc"] = "Подсвечивать предметы в ленте добычи на основе определенных критериев"
L["Highlight Mounts"] = "Подсвечивать маунтов"
L["HighlightMountsDesc"] = "Подсвечивать маунтов в ленте добычи"
L["Highlight Legendary Items"] = "Подсвечивать легендарные предметы"
L["HighlightLegendaryDesc"] = "Подсвечивать легендарные предметы в ленте добычи"
L["Highlight Items Better Than Equipped"] = "Подсвечивать предметы лучше экипированных"
L["HighlightBetterThanEquippedDesc"] = "Подсвечивать предметы, которые лучше тех, что у вас надето, в ленте добычи"
L["Play Sound for Mounts"] = "Воспроизвести звук для средства передвижения"
L["PlaySoundForMountsDesc"] = "Воспроизвести звук при получении средства передвижения"
L["Mount Sound"] = "Звук средства передвижения"
L["MountSoundDesc"] = "Звук, который проигрывается при получении средства передвижения"
L["Play Sound for Legendary Items"] = "Воспроизвести звук для легендарных предметов"
L["PlaySoundForLegendaryDesc"] = "Воспроизвести звук при получении легендарного предмета"
L["Legendary Sound"] = "Легендарный звук"
L["LegendarySoundDesc"] = "Звук, который проигрывается при получении легендарного предмета"
L["Play Sound for Items Better Than Equipped"] = "Воспроизвести звук для предметов, которые лучше, чем ваши"
L["PlaySoundForBetterDesc"] = "Воспроизводить звук, когда получаете предмет, который лучше того, что у вас экипирован"
L["Better Than Equipped Sound"] = "Звук для предметов лучше чем у вас"
L["BetterThanEquippedSoundDesc"] = "Звук, который проигрывается, когда получаете предмет, который лучше того, что у вас экипирован"
L["Item Loot Sounds"] = "Звуки добычи предметов"
L["Party Loot Config"] = "Настройка добычи группы"
L["Party Loot Options"] = "Опции добычи группы"
L["Party Item Quality Filter"] = "Фильтр качества предметов группы"
L["PartyItemQualityFilterDesc"] = "Выберите, какие качества предметов показывать в ленте добычи группы."
L["Only Epic and Above in Raid"] = "Только эпическое и выше в рейде"
L["OnlyEpicAndAboveInRaidDesc"] = "Показывать только эпические и выше предметы в ленте добычи группы в рейде"
L["Only Epic and Above in Instance"] = "Только эпическое и выше в подземелье"
L["OnlyEpicAndAboveInInstanceDesc"] = "Показывать только эпические и выше предметы в ленте добычи группы в подземелье"
L["Enable Currency in Feed"] = "Включить валюту в ленту"
L["EnableCurrencyDesc"] = "Показывать валюту, такую как Камни полета, Честь, Пробужденный гребень дракона и т.д. в ленте добычи"
L["Currency Config"] = "Настройка валюты"
L["Currency Options"] = "Опции валюты"
L["Currency Total Text Options"] = "Опции текста общего количества валюты"
L["Enable Currency Total Text"] = "Включить текст общего количества валюты"
L["EnableCurrencyTotalTextDesc"] = "Показывать общее количество валюты на текущем персонаже в ленте добычи"
L["Currency Total Text Color"] = "Цвет текста общего количества валюты"
L["CurrencyTotalTextColorDesc"] = "Цвет текста общего количества валюты в ленте добычи."
L["Currency Total Text Wrap Character"] = "Символ обертывания текста общего количества валюты"
L["CurrencyTotalTextWrapCharDesc"] = "Символы для обертывания текста общего количества валюты."
L["Enable Item/Currency Tooltips"] = "Включить подсказки для предметов/валюты"
L["EnableTooltipsDesc"] = "Включить отображение подсказок для предметов/валюты при наведении курсора, никогда не показывать в бою."
L["Tooltip Options"] = "Опции подсказок"
L["Show only when SHIFT is held"] = "Показывать только при удержании SHIFT"
L["OnlyShiftOnEnterDesc"] = "Показывать подсказку только если удерживается Shift при наведении на предмет/валюту."
L["Enable Money in Feed"] = "Включить деньги в ленту"
L["EnableMoneyDesc"] = "Показывать деньги, такие как золото, серебро, медь, в ленте добычи"
L["Money Config"] = "Настройка денег"
L["Money Options"] = "Опции денег"
L["Money Total Options"] = "Опции общего количества денег"
L["ShowMoneyTotalDesc"] = "Показывать общее количество денег на текущем персонаже в ленте добычи"
L["Abbreviate Total"] = "Сокращать общее количество"
L["AbbreviateTotalDesc"] = "Сокращать общее количество денег в ленте добычи (для золота свыше 1000)"
L["Show Money Total"] = "Показывать общее количество денег"
L["BillionAbbrev"] = "Млрд"
L["MillionAbbrev"] = "Млн"
L["ThousandAbbrev"] = "Тыс"
L["Accountant Mode"] = "Режим бухгалтера"
L["AccountantModeDesc"] = "Показывать отрицательные суммы денег в скобках вместо знака минус."
L["Money Loot Sound"] = "Звук добычи золота"
L["Override Money Loot Sound"] = "Переопределить звук добычи золота"
L["MoneyLootSoundDesc"] = "Замените стандартный звук добычи золота на собственный звук."
L["OverrideMoneyLootSoundDesc"] = "Если отмечено, использовать пользовательский звук для добычи золота."
L["Enable Experience in Feed"] = "Включить опыт в ленту"
L["EnableXPDesc"] = "Показывать получение опыта в ленте добычи"
L["Experience Config"] = "Настройка опыта"
L["Experience Options"] = "Опции опыта"
L["Experience Text Color"] = "Цвет текста опыта"
L["ExperienceTextColorDesc"] = "Цвет текста опыта в ленте добычи."
L["Current Level Options"] = "Опции текущего уровня"
L["Show Current Level"] = "Показывать текущий уровень"
L["ShowCurrentLevelDesc"] = "Показывать ваш текущий уровень в строках получения опыта."
L["Current Level Color"] = "Цвет текущего уровня"
L["CurrentLevelColorDesc"] = "Цвет текста текущего уровня в ленте добычи."
L["Current Level Text Wrap Character"] = "Персонаж обертывания текста текущего уровня"
L["CurrentLevelTextWrapCharDesc"] = "Персонажи для обертывания текста текущего уровня."
L["Enable Reputation in Feed"] = "Включить репутацию в ленту"
L["EnableRepDesc"] = "Показывать получение репутации в ленте добычи"
L["Reputation Config"] = "Настройка репутации"
L["Reputation Options"] = "Опции репутации"
L["Default Rep Text Color"] = "Цвет текста репутации по умолчанию"
L["RepColorDesc"] = "Цвет текста репутации по умолчанию в ленте добычи. Переопределяется цветами фракций."
L["Secondary Text Alpha"] = "Прозрачность вторичного текста"
L["SecondaryTextAlphaDesc"] = "Прозрачность вторичного текста репутации в ленте добычи."
L["Reputation Level Options"] = "Опции уровня репутации"
L["Enable Reputation Level"] = "Включить уровень репутации"
L["EnableRepLevelDesc"] = "Показывать уровень репутации в ленте добычи."
L["Reputation Level Color"] = "Цвет уровня репутации"
L["RepLevelColorDesc"] = "Цвет текста уровня репутации в ленте добычи."
L["Reputation Level Wrap Character"] = "Персонаж обертывания текста уровня репутации"
L["RepLevelWrapCharDesc"] = "Персонаж для обертывания текста уровня репутации."
L["Profession Config"] = "Настройка профессий"
L["Profession Options"] = "Опции профессий"
L["Enable Professions in Feed"] = "Включить профессии в ленту"
L["EnableProfDesc"] = "Показывать повышение навыков профессий в ленте добычи"
L["Skill Change Options"] = "Опции изменения навыков"
L["Show Skill Change"] = "Показывать изменение навыков"
L["ShowSkillChangeDesc"] = "Показывать изменение уровня навыков."
L["Skill Text Color"] = "Цвет текста навыков"
L["SkillColorDesc"] = "Цвет текста навыков в ленте добычи."
L["Skill Text Wrap Character"] = "Персонаж обертывания текста навыков"
L["SkillTextWrapCharDesc"] = "Персонажи для обертывания текста навыков."

-- Настройки - Группа позиционирования
L["Positioning"] = "Позиционирование"
L["Drag to Move"] = "Перетащите для перемещения"
L["PositioningDesc"] = "Позиционируйте и закрепите ленту добычи."
L["Anchor Relative To"] = "Закрепить относительно"
L["RelativeToDesc"] = "Выберите фрейм для закрепления ленты добычи"
L["Screen"] = "Экран"
L["UIParent"] = "UIParent"
L["PlayerFrame"] = "Фрейм игрока"
L["Minimap"] = "Миникарта"
L["BagBar"] = "Панель сумок"
L["Anchor Point"] = "Точка закрепления"
L["AnchorPointDesc"] = "Где на экране закрепить ленту добычи (также влияет на направление изменения размера)"
L["Top Left"] = "Верхний левый"
L["Top Right"] = "Верхний правый"
L["Bottom Left"] = "Нижний левый"
L["Bottom Right"] = "Нижний правый"
L["Top"] = "Верх"
L["Bottom"] = "Низ"
L["Left"] = "Лево"
L["Right"] = "Право"
L["Down"] = "Вниз"
L["Up"] = "Вверх"
L["Center"] = "Центр"
L["X Offset"] = "Смещение по X"
L["XOffsetDesc"] = "Настройте смещение ленты добычи влево (отрицательное) или вправо (положительное)"
L["Y Offset"] = "Смещение по Y"
L["YOffsetDesc"] = "Настройте смещение ленты добычи вниз (отрицательное) или вверх (положительное)"
L["Frame Strata"] = "Слой фрейма"
L["FrameStrataDesc"] = "Настройте слой (глубину экрана, z-индекс и т.д.) фрейма ленты добычи"
L["Background"] = "Фон"
L["Low"] = "Низкий"
L["Medium"] = "Средний"
L["High"] = "Высокий"
L["Dialog"] = "Диалог"
L["Tooltip"] = "Подсказка"

-- Настройки - Группа размеров
L["Sizing"] = "Размеры"
L["SizingDesc"] = "Настройте размеры ленты и ее элементов."
L["Feed Width"] = "Ширина ленты"
L["FeedWidthDesc"] = "Ширина родительского фрейма ленты добычи"
L["Maximum Rows to Display"] = "Максимальное количество строк для отображения"
L["MaxRowsDesc"] = "Максимальное количество предметов добычи для отображения в ленте"
L["Loot Item Height"] = "Высота строки добычи"
L["RowHeightDesc"] = "Высота каждой строки в ленте добычи"
L["Loot Item Icon Size"] = "Размер иконки предмета добычи"
L["IconSizeDesc"] = "Размер иконок в каждой строке ленты добычи"
L["Loot Item Padding"] = "Отступ между строками добычи"
L["RowPaddingDesc"] = "Расстояние между строками в ленте добычи"

-- Настройки - Группа стилей
L["Styling"] = "Стили"
L["StylingDesc"] = "Настройте стиль ленты и ее элементов с помощью пользовательских цветов, выравнивания и т.д."
L["Left Align"] = "Выравнивание по левому краю"
L["LeftAlignDesc"] = "Выравнивать содержимое строк по левому краю (по правому, если не отмечено)"
L["Grow Up"] = "Рост вверх"
L["GrowUpDesc"] = "Лента будет расти вверх (вниз, если не отмечено) по мере добавления новых предметов"
L["Background Gradient Start"] = "Начало градиента фона"
L["GradientStartDesc"] = "Начальный цвет градиента фона строки."
L["Background Gradient End"] = "Конец градиента фона"
L["GradientEndDesc"] = "Конечный цвет градиента фона строки."
L["Row Borders"] = "Границы строк"
L["RowBordersDesc"] = "Настройте границы строк."
L["Enable Row Borders"] = "Включить границы строк"
L["EnableRowBordersDesc"] = "Если отмечено, показывать границы вокруг каждой строки в ленте добычи."
L["Row Border Thickness"] = "Толщина границы строки"
L["RowBorderThicknessDesc"] = "Толщина границы строки."
L["Row Border Color"] = "Цвет границы строки"
L["RowBorderColorDesc"] = "Цвет границы строки."
L["Use Class Colors for Borders"] = "Использовать цвета классов для границ"
L["UseClassColorsForBordersDesc"] = "Если отмечено, использовать цвета классов для границ строк."
L["Enable Secondary Row Text"] = "Включить вторичный текст строки"
L["EnableSecondaryRowTextDesc"] = "Если отмечено, показывать вторичный текст строки, такой как уровень предмета, второстепенные характеристики, цена у продавца и т.д., если применимо."
L["Use Font Objects"] = "Использовать объекты шрифтов"
L["UseFontObjectsDesc"] = "Если отмечено, использовать объект шрифта для определения типа и размера шрифта."
L["Font"] = "Шрифт"
L["FontDesc"] = "Объект шрифта для текста добычи."
L["Custom Fonts"] = "Пользовательские шрифты"
L["CustomFontsDesc"] = "Настройте тип, размер и флаги шрифта для персонализации ленты добычи."
L["Font Face"] = "Тип шрифта"
L["FontFaceDesc"] = "Стиль текста, который будет отображаться в ленте добычи."
L["Font Size"] = "Размер шрифта"
L["FontSizeDesc"] = "Размер текста ленты добычи в \"пунктах\"."
L["Font Flags"] = "Флаги шрифтов"
L["FontFlagsDesc"] = "Флаги, применяемые к тексту ленты добычи."
L["Outline"] = "Контур"
L["Thick Outline"] = "Толстый контур"
L["Monochrome"] = "Монохромный"
L["Shadow Color"] = "Цвет тени"
L["ShadowColorDesc"] = "Цвет тени позади текста ленты добычи."
L["ShadowOffsetHelp"] = "Отрицательные значения для теней слева или снизу текста. -1 обычно желательно для размеров шрифта 8-10. Установите оба смещения на 0, чтобы отключить тень."
L["Shadow Offset X"] = "Смещение тени по оси X"
L["ShadowOffsetXDesc"] = "Горизонтальное смещение тени за текстом ленты добычи. Отрицательные значения для теней слева от текста. -1 обычно желательно для размеров шрифта 8-10. 0 для отключения горизонтальной тени."
L["Shadow Offset Y"] = "Смещение тени по оси Y"
L["ShadowOffsetYDesc"] = "Вертикальное смещение тени за текстом ленты добычи. Отрицательные значения для теней под текстом. -1 обычно желательно для размеров шрифта 8-10. 0 для отключения вертикальной тени."
L["Secondary Font Size"] = "Размер вторичного шрифта"
L["SecondaryFontSizeDesc"] = "Размер вторичного текста в ленте добычи в \"пунктах\"."

-- Настройки - Группа анимаций
L["Animations"] = "Анимации"
L["AnimationsDesc"] = "Настройте анимации ленты добычи."
L["Row Enter Animation"] = "Анимация появления строки"
L["RowEnterAnimationDesc"] = "Настройте анимацию появления строк в ленте добычи."
L["Enter Animation Type"] = "Тип анимации появления"
L["EnterAnimationTypeDesc"] = "Тип анимации, используемой при добавлении новой строки в ленту добычи."
L["Enter Animation Duration"] = "Длительность анимации появления"
L["EnterAnimationDurationDesc"] = "Количество секунд, которое займет анимация появления."
L["Exit Animation Type"] = "Тип анимации выхода"
L["ExitAnimationTypeDesc"] = "Тип анимации, используемый при удалении строки из ленты добычи."
L["Exit Animation Duration"] = "Продолжительность анимации выхода"
L["ExitAnimationDurationDesc"] = "Количество секунд, которое займет анимация выхода."
L["Row Exit Animation"] = "Анимация исчезновения строки"
L["RowExitAnimationDesc"] = "Настройте анимацию исчезновения строк в ленте добычи."
L["Fade"] = "Исчезновение"
L["Slide"] = "Скольжение"
L["Slide Direction"] = "Направление скольжения"
L["SlideDirectionDesc"] = "Направление, в котором строка будет двигаться во время анимации скольжения."
L["Fade Out Delay"] = "Задержка исчезновения"
L["FadeOutDelayDesc"] = "Количество секунд, в течение которых строка будет отображаться перед исчезновением."
L["Hover Animation"] = "Анимация при наведении"
L["HoverAnimationDesc"] = "Настройте анимацию при наведении курсора на строку в ленте добычи."
L["Enable Hover Animation"] = "Включить анимацию при наведении"
L["EnableHoverAnimationDesc"] = "Если этот флажок установлен, при наведении курсора на строку она будет выделена."
L["Hover Alpha"] = "Прозрачность наведения"
L["HoverAlphaDesc"] = "Альфа-канал строки подсвечивается при наведении курсора."
L["Base Duration"] = "Базовая продолжительность"
L["BaseDurationDesc"] = "Количество секунд, которое займет анимация наведения."
L["Update Animations"] = "Обновление анимации"
L["UpdateAnimationsDesc"] = "Настройте анимацию при обновлении количества в существующей строке в ленте добычи."
L["Disable Highlight"] = "Отключить выделение"
L["DisableHighlightDesc"] = "Если этот флажок установлен, граница строки не будет выделяться при повторном получении того же предмета и обновлении его количества."
L["Update Animation Duration"] = "Обновление продолжительности анимации"
L["UpdateAnimationDurationDesc"] = "Количество секунд, которое займет анимация обновления."
L["Loop Update Highlight"] = "Выделение обновления цикла"
L["LoopUpdateHighlightDesc"] = "Если этот флажок установлен, анимация подсветки будет повторяться при обновлении количества."

-- Настройки - Группа интерфейса Blizzard
L["Blizzard UI"] = "Интерфейс Blizzard"
L["BlizzUIDesc"] = "Переопределить поведение элементов интерфейса Blizzard"
L["Disable Loot Toasts"] = "Отключить уведомления о добыче"
L["DisableLootToastDesc"] = "Окна, которые появляются внизу экрана, когда вы добываете особые предметы"
L["Disable Money Alerts"] = "Отключить уведомления о деньгах"
L["DisableMoneyAlertsDesc"] = "Окна, которые появляются внизу экрана, когда вы получаете деньги, например, награды за мировые задания"
L["Enable Auto Loot"] = "Включить автоматический сбор добычи"
L["EnableAutoLootDesc"] = "Установить настройку по умолчанию, чтобы автоматический сбор добычи был включен при входе в игру на любом персонаже"
L["Alerts"] = "Уведомления"
L["Disable Boss Banner Elements"] = "Отключить элементы баннера босса"
L["DisableBossBannerDesc"] = "Переопределить баннер босса. Полностью скрыть его, скрыть только часть с добычей или только вашу добычу или добычу вашей группы."
L["Do not disable BossBanner"] = "Не отключать баннер босса"
L["Disable All BossBanner"] = "Отключить весь баннер босса"
L["Disable All BossBanner Loot"] = "Отключить всю добычу баннера босса"
L["Only Disable My BossBanner Loot"] = "Отключить только мою добычу баннера босса"
L["Disable Party/Raid Loot"] = "Отключить добычу группы/рейда"
L["Chat"] = "Чат"
L["Disable Loot Chat Messages"] = "Отключить сообщения о добыче в чате"
L["DisableLootChatMessagesDesc"] = "Отключает сообщения о добыче во всех окнах чата."
L["Disable Currency Chat Messages"] = "Отключить сообщения о валюте в чате"
L["DisableCurrencyChatMessagesDesc"] = "Отключает сообщения о валюте во всех окнах чата."
L["Disable Money Chat Messages"] = "Отключить сообщения о деньгах в чате"
L["DisableMoneyChatMessagesDesc"] = "Отключает сообщения о деньгах во всех окнах чата."
L["Disable Experience Chat Messages"] = "Отключить сообщения об опыте в чате"
L["DisableExperienceChatMessagesDesc"] = "Отключает сообщения об опыте во всех окнах чата."
L["Disable Reputation Chat Messages"] = "Отключить сообщения о репутации в чате"
L["DisableReputationChatMessagesDesc"] = "Отключает сообщения о репутации во всех окнах чата."
