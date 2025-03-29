---@class AceAddon
---@field public GetAddon fun(self: AceAddon, name: string, silent: boolean): AceAddon
---@field public IterateAddonStatus fun(self: AceAddon): fun(): string, boolean
---@field public IterateAddons fun(self: AceAddon): fun(): string, AceAddon
---@field public NewAddon fun(self: AceAddon, name: string, ...: string): AceAddon
---@field public Disable fun(self: AceAddon): nil
---@field public DisableModule fun(self: AceAddon, name: string): nil
---@field public Enable fun(self: AceAddon): nil
---@field public EnableModule fun(self: AceAddon, name: string): nil
---@field public GetModule fun(self: AceAddon, name: string): table
---@field public GetName fun(self: AceAddon): string
---@field public IsEnabled fun(self: AceAddon): boolean
---@field public IterateModules fun(self: AceAddon): fun(): string, AceAddon
---@field public NewModule fun(self: AceAddon, name: string, ...: string): AceAddon
---@field public SetDefaultModuleLibraries fun(self: AceAddon, ...: string): nil
---@field public SetDefaultModulePrototype fun(self: AceAddon, prototype: table): nil
---@field public SetDefaultModuleState fun(self: AceAddon, state: boolean): nil
---@field public SetEnabledState fun(self: AceAddon, state: boolean): nil

---@class AceBucket
---@field public RegisterBucketEvent fun(self: AceBucket, event: string, interval: number, method: string|function): string
---@field public RegisterBucketMessage fun(self: AceBucket, message: string, interval: number, method: string|function): string
---@field public UnregisterAllBuckets fun(self: AceBucket): nil
---@field public UnregisterBucket fun(self: AceBucket, handle: string): nil

---@class AceComm
---@field public RegisterComm fun(self: AceComm, prefix: string, method: string|function): nil
---@field public SendCommMessage fun(self: AceComm, prefix: string, text: string, distribution: string, target: string, prio: string): nil

---@class AceConfig
---@field public RegisterOptionsTable fun(self: AceConfig, name: string, options: table, slashCommand: string|function|table): nil

---@class AceConfigCmd
---@field public CreateChatCommand fun(self: AceConfigCmd, slashCommand: string, appName: string): nil
---@field public GetChatCommand fun(self: AceConfigCmd, slashCommand: string): table
---@field public HandleCommand fun(self: AceConfigCmd, slashCommand: string, appName: string, input: string): nil

---@class AceConfigDialog
---@field public AddToBlizOptions fun(self: AceConfigDialog, appName: string, title: string, parent?: string, ...?: string): Frame, string
---@field public Close fun(self: AceConfigDialog, appName: string): nil
---@field public CloseAll fun(self: AceConfigDialog): nil
---@field public Open fun(self: AceConfigDialog, appName: string, ...: string): nil
---@field public SetDefaultSize fun(self: AceConfigDialog, appName: string, width: number, height: number): nil
---@field public OpenFrames table<string, Frame>

---@alias methodname string

---@class AceConfigOptionsTable
---@field public type "execute" | "input" | "toggle" | "range" | "select" | "multiselect" | "color" | "keybinding" | "header" | "description" | "group"
---@field public name string|function
---@field public desc string|function
---@field public descStyle nil
---@field public validate methodname|function|boolean
---@field public confirm methodname|function|boolean
---@field public order number|methodname|function
---@field public disabled methodname|function|boolean
---@field public hidden methodname|function|boolean
---@field public guiHidden boolean
---@field public dialogHidden boolean
---@field public dropdownHidden boolean
---@field public cmdHidden boolean
---@field public icon string|function
---@field public iconCoords table|methodname|function
---@field public handler table
---@field public width "double" | "half" | "full" | "normal" | number

---@class OptionsTableExecute: AceConfigOptionsTable
---@field public type "execute"
---@field public func methodname|function
---@field public image string|function
---@field public imageCoords table|methodname|function
---@field public imageWidth number
---@field public imageHeight number

---@class OptionsTableInput: AceConfigOptionsTable
---@field public type "input"
---@field public get methodname|function
---@field public set methodname|function
---@field public multiline boolean|number
---@field public pattern string
---@field public usage string

---@class OptionsTableToggle: AceConfigOptionsTable
---@field public type "toggle"
---@field public get methodname|function
---@field public set methodname|function
---@field public tristate boolean

---@class OptionsTableRange: AceConfigOptionsTable
---@field public type "range"
---@field public get methodname|function
---@field public set methodname|function
---@field public min number
---@field public max number
---@field public softMin number
---@field public softMax number
---@field public step number
---@field public bigStep number
---@field public isPercent boolean

---@class OptionsTableSelect: AceConfigOptionsTable
---@field public type "select"
---@field public get methodname|function
---@field public set methodname|function
---@field public values table<any, string>|function
---@field public sorting any[]|function
---@field public style "dropdown" | "radio"

---@class OptionsTableMultiSelect: AceConfigOptionsTable
---@field public type "multiselect"
---@field public get methodname|function
---@field public set methodname|function
---@field public values table<any, string>|function
---@field public tristate boolean

---@class OptionsTableColor: AceConfigOptionsTable
---@field public type "color"
---@field public get methodname|function
---@field public set methodname|function
---@field public hasAlpha boolean

---@class OptionsTableKeybinding: AceConfigOptionsTable
---@field public type "keybinding"
---@field public get methodname|function
---@field public set methodname|function

---@class OptionsTableHeader: AceConfigOptionsTable
---@field public type "header"
---@field public name string

---@class OptionsTableDescription: AceConfigOptionsTable
---@field public type "description"
---@field public name string
---@field public fontSize "small" | "medium" | "large"
---@field public image string|function
---@field public imageCoords table|methodname|function
---@field public imageWidth number
---@field public imageHeight number

---@class OptionsTableGroup: AceConfigOptionsTable
---@field public type "group"
---@field public args table<string, AceConfigOptionsTable>
---@field public plugins table<string, any>
---@field public childGroups "tab" | "tree" | "select"
---@field public inline boolean
---@field public cmdInline boolean
---@field public dialogInline boolean
---@field public dropdownInline boolean
---@field public guiInline boolean

---@class AceConfigRegistry
---@field public GetOptionsTable fun(self: AceConfigRegistry, appName: string, uiType: "cmd" | "dropdown" | "dialog", uiName: string): function|table
---@field public IterateOptionsTables fun(self: AceConfigRegistry): fun(): string, function
---@field public NotifyChange fun(self: AceConfigRegistry, appName: string): nil
---@field public RegisterOptionsTable fun(self: AceConfigRegistry, appName: string, options: AceConfigOptionsTable, skipValidation: boolean): nil
---@field public ValidateOptionsTable fun(self: AceConfigRegistry, options: table, name: string, errlvl: number): nil

---@class AceConsole
---@field public GetArgs fun(self: AceConsole, raw: string, numargs: number, startpos: number): (string|nil)[]
---@field public IterateChatCommands fun(self: AceConsole): fun(): any, any
---@field public Print fun(self: AceConsole, chatFrame: any, ...: string): nil
---@field public Printf fun(self: AceConsole, chatFrame: any, fmt: string, ...: string): nil
---@field public RegisterChatCommand fun(self: AceConsole, command: string, func: string|function, persist?: boolean): nil
---@field public UnregisterChatCommand fun(self: AceConsole, command: string): nil

---@class CustomDB:AceDB
---@field public char table
---@field public realm table
---@field public class table
---@field public race table
---@field public faction table
---@field public factionrealm table
---@field public locale table
---@field public global table
---@field public profile table
---@field public CopyProfile fun(self: CustomDB, name: string, silent: boolean): nil
---@field public DeleteProfile fun(self: CustomDB, name: string, silent: boolean): nil
---@field public GetCurrentProfile fun(self: CustomDB): string
---@field public GetNamespace fun(self: CustomDB, namespace: string, silent: boolean): table|nil
---@field public GetProfiles fun(self: CustomDB, tbl: table): table
---@field public RegisterDefaults fun(self: CustomDB, defaults: table): nil
---@field public RegisterNamespace fun(self: CustomDB, namespace: string, defaults: table): CustomDB
---@field public ResetDB fun(self: CustomDB, profile: string): nil
---@field public ResetProfile fun(self: CustomDB, noChildren: boolean, noCallbacks: boolean): nil
---@field public SetProfile fun(self: CustomDB, name: string): nil

---@class AceDB
---@field public New fun(self: AceDB, dbName: string, defaults: table, defaultProfile: boolean): CustomDB

---@class AceDBOptions
---@field public GetOptionsTable fun(self: AceDBOptions, db: CustomDB, noDefaultProfiles: boolean): AceConfigOptionsTable

---@class AceEvent
---@field public RegisterEvent fun(self: AceEvent, event: string, callback?: methodname|function, arg?: any): nil
---@field public RegisterMessage fun(self: AceEvent, message: string, callback: methodname|function, arg: any): nil
---@field public SendMessage fun(self: AceEvent, message: string, ...: any): nil
---@field public UnregisterEvent fun(self: AceEvent, event: string): nil
---@field public UnregisterMessage fun(self: AceEvent, message: string): nil

---@class AceGUI
---@field public ClearFocus fun(self: AceGUI): nil
---@field public Create fun(self: AceGUI, type: string): AceGUIButtonWidget | AceGUICheckBoxWidget | AceGUIColorPickerWidget | AceGUIDropdownWidget | AceGUIEditBoxWidget | AceGUIFrameContainer | AceGUIHeadingWidget | AceGUIInteractiveLabelWidget | AceGUIKeybindingWidget | AceGUIMultiLineEditBoxWidget  | AceGUISliderWidget | AceGUIDropdownGroupContainer | AceGUIFrameContainer | AceGUIInlineGroupContainer | AceGUIScrollFrameContainer | AceGUITabGroupContainer | AceGUITreeGroupContainer
---@field public GetLayout fun(self: AceGUI, Name: string): function
---@field public GetNextWidgetNum fun(self: AceGUI, type: string): number
---@field public GetWidgetCount fun(self: AceGUI, type: string): number
---@field public GetWidgetVersion fun(self: AceGUI, type: string): number
---@field public RegisterAsContainer fun(self: AceGUI, widget: table): nil
---@field public RegisterAsWidget fun(self: AceGUI, widget: table): nil
---@field public RegisterLayout fun(self: AceGUI, Name: string, LayoutFunc: function): nil
---@field public RegisterWidgetType fun(self: AceGUI, Name: string, Constructor: function, Version: number): nil
---@field public Release fun(self: AceGUI, widget: AceGUIWidgetBase): nil
---@field public SetFocus fun(self: AceGUI, widget: AceGUIWidgetBase): nil

---@class CustomGUI:AceGUI

---@class AceGUIWidgetBase
---@field public SetCallback fun(self: AceGUIWidgetBase, name: string, func: function): nil
---@field public SetWidth fun(self: AceGUIWidgetBase, width: number): nil
---@field public SetRelativeWidth fun(self: AceGUIWidgetBase, width: number): nil
---@field public SetHeight fun(self: AceGUIWidgetBase, height: number): nil
---@field public IsVisible fun(self: AceGUIWidgetBase): boolean
---@field public IsShown fun(self: AceGUIWidgetBase): boolean
---@field public Release fun(self: AceGUIWidgetBase): nil
---@field public SetPoint fun(self: AceGUIWidgetBase, ...): nil
---@field public ClearAllPoints fun(self: AceGUIWidgetBase): nil
---@field public GetNumPoints fun(self: AceGUIWidgetBase): number
---@field public GetPoint fun(self: AceGUIWidgetBase, ...): any
---@field public GetUserDataTable fun(self: AceGUIWidgetBase): table
---@field public SetUserData fun(self: AceGUIWidgetBase, key: string, value: any): nil
---@field public GetUserData fun(self: AceGUIWidgetBase, key: string): any
---@field public SetFullHeight fun(self: AceGUIWidgetBase, isFull: boolean): nil
---@field public IsFullHeight fun(self: AceGUIWidgetBase): boolean
---@field public SetFullWidth fun(self: AceGUIWidgetBase, isFull: boolean): nil
---@field public IsFullWidth fun(self: AceGUIWidgetBase): boolean

---@class AceGUIContainerBase: AceGUIWidgetBase
---@field public AddChild fun(self: AceGUIContainerBase, widget: AceGUIWidgetBase, beforeWidget?: AceGUIWidgetBase): nil
---@field public SetLayout fun(self: AceGUIContainerBase, layout: "Flow"|"List"|"Fill"): nil
---@field public SetAutoAdjustHeight fun(self: AceGUIContainerBase, flag: boolean): nil
---@field public ReleaseChildren fun(self: AceGUIContainerBase): nil
---@field public DoLayout fun(self: AceGUIContainerBase): nil
---@field public PauseLayout fun(self: AceGUIContainerBase): nil
---@field public ResumeLayout fun(self: AceGUIContainerBase): nil

---@class AceHook
---@field public Hook fun(self: AceHook, object: any|string, method: string, handler?: string|function, hookSecure?: boolean): nil
---@field public HookScript fun(self: AceHook, frame: table, script: string, handler?: string|function): nil
---@field public IsHooked fun(self: AceHook, obj: any|string, method?: string): boolean
---@field public RawHook fun(self: AceHook, object: any|string, method: string, handler?: string|function, hookSecure?: boolean): nil
---@field public RawHookScript fun(self: AceHook, frame: table, script: string, handler?: string|function): nil
---@field public SecureHook fun(self: AceHook, object: any|string, method: string, handler?: string|function): nil
---@field public SecureHookScript fun(self: AceHook, frame: table, script: string, handler?: string|function): nil
---@field public Unhook fun(self: AceHook, obj: any|string, method?: string): nil
---@field public UnhookAll fun(self: AceHook): nil
---@field public hooks table<string, function> | table<string, table<string, function>>

---@class AceLocale
---@field public GetLocale fun(self: AceLocale, application: string, silent?: boolean): table
---@field public NewLocale fun(self: AceLocale, application: string, locale: string, isDefault?: boolean, silent?: boolean|"raw"): table|nil

---@class AceSerializer
---@field public Deserialize fun(self: AceSerializer, str: string): boolean, ...
---@field public Serialize fun(self: AceSerializer, ...): string

---@class AceTimer
---@field public CancelAllTimers fun(self: AceTimer): nil
---@field public CancelTimer fun(self: AceTimer, id: any): nil
---@field public ScheduleRepeatingTimer fun(self: AceTimer, func: string|function, delay: number, ...): any
---@field public ScheduleTimer fun(self: AceTimer, func: string|function, delay: number, ...): any
---@field public TimeLeft fun(self: AceTimer, id: any): number

---@class TSM_API
---@field public ToItemString fun(item: string)
---@field public GetCustomPriceValue fun(priceSource: string, itemString: string)
