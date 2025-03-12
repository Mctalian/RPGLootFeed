---@class AceGUIButtonWidget: AceGUIWidgetBase
---@field public SetText fun(self: AceGUIButtonWidget, text: string): nil
---@field public SetDisabled fun(self: AceGUIButtonWidget, flag: boolean): nil
---@field public SetCallback fun(self: AceGUIButtonWidget, event: "OnClick"|"OnEnter"|"OnLeave", func: function): nil
-- Callbacks: OnClick, OnEnter, OnLeave

---@class AceGUICheckBoxWidget: AceGUIWidgetBase
---@field public SetValue fun(self: AceGUICheckBoxWidget, flag: boolean): nil
---@field public GetValue fun(self: AceGUICheckBoxWidget): boolean
---@field public SetType fun(self: AceGUICheckBoxWidget, type: "radio"|"checkbox"): nil
---@field public ToggleChecked fun(self: AceGUICheckBoxWidget): nil
---@field public SetLabel fun(self: AceGUICheckBoxWidget, text: string): nil
---@field public SetTriState fun(self: AceGUICheckBoxWidget, state: boolean): nil
---@field public SetDisabled fun(self: AceGUICheckBoxWidget, flag: boolean): nil
---@field public SetDescription fun(self: AceGUICheckBoxWidget, description: string): nil
---@field public SetImage fun(self: AceGUICheckBoxWidget, path: string, ...): nil
---@field public SetCallback fun(self: AceGUICheckBoxWidget, event: "OnValueChanged"|"OnEnter"|"OnLeave", func: function): nil
-- Callbacks: OnValueChanged, OnEnter, OnLeave

---@class AceGUIColorPickerWidget: AceGUIWidgetBase
---@field public SetColor fun(self: AceGUIColorPickerWidget, r: number, g: number, b: number, a: number): nil
---@field public SetLabel fun(self: AceGUIColorPickerWidget, text: string): nil
---@field public SetHasAlpha fun(self: AceGUIColorPickerWidget, flag: boolean): nil
---@field public SetDisabled fun(self: AceGUIColorPickerWidget, flag: boolean): nil
---@field public SetCallback fun(self: AceGUIColorPickerWidget, event: "OnValueChanged"|"OnValueConfirmed"|"OnEnter"|"OnLeave", func: function): nil
-- Callbacks: OnValueChanged, OnValueConfirmed, OnEnter, OnLeave

---@class AceGUIDropdownWidget: AceGUIWidgetBase
---@field public SetValue fun(self: AceGUIDropdownWidget, key: any): nil
---@field public SetList fun(self: AceGUIDropdownWidget, table: table, order?: table): nil
---@field public SetText fun(self: AceGUIDropdownWidget, text: string): nil
---@field public SetLabel fun(self: AceGUIDropdownWidget, text: string): nil
---@field public AddItem fun(self: AceGUIDropdownWidget, key: any, value: any): nil
---@field public SetMultiselect fun(self: AceGUIDropdownWidget, flag: boolean): nil
---@field public GetMultiselect fun(self: AceGUIDropdownWidget): boolean
---@field public SetItemValue fun(self: AceGUIDropdownWidget, key: any, value: any): nil
---@field public SetItemDisabled fun(self: AceGUIDropdownWidget, key: any, flag: boolean): nil
---@field public SetDisabled fun(self: AceGUIDropdownWidget, flag: boolean): nil
---@field public SetCallback fun(self: AceGUIDropdownWidget, event: "OnValueChanged"|"OnEnter"|"OnLeave", func: function): nil
-- Callbacks: OnValueChanged, OnEnter, OnLeave

---@class AceGUIEditBoxWidget: AceGUIWidgetBase
---@field public SetText fun(self: AceGUIEditBoxWidget, text: string): nil
---@field public GetText fun(self: AceGUIEditBoxWidget): string
---@field public SetLabel fun(self: AceGUIEditBoxWidget, text: string): nil
---@field public SetDisabled fun(self: AceGUIEditBoxWidget, flag: boolean): nil
---@field public DisableButton fun(self: AceGUIEditBoxWidget, flag: boolean): nil
---@field public SetMaxLetters fun(self: AceGUIEditBoxWidget, num: number): nil
---@field public SetFocus fun(self: AceGUIEditBoxWidget): nil
---@field public HighlightText fun(self: AceGUIEditBoxWidget, start: number, end_: number): nil
---@field public SetCallback fun(self: AceGUIEditBoxWidget, event: "OnTextChanged"|"OnEnterPressed"|"OnEnter"|"OnLeave", func: function): nil
-- Callbacks: OnTextChanged, OnEnterPressed, OnEnter, OnLeave

---@class AceGUIHeadingWidget: AceGUIWidgetBase
---@field public SetText fun(self: AceGUIHeadingWidget, text: string): nil
-- No callbacks

---@class AceGUIIconWidget: AceGUIWidgetBase
---@field public SetImage fun(self: AceGUIIconWidget, image: string, ...): nil
---@field public SetImageSize fun(self: AceGUIIconWidget, width: number, height: number): nil
---@field public SetLabel fun(self: AceGUIIconWidget, text: string): nil
---@field public SetCallback fun(self: AceGUIIconWidget, event: "OnClick"|"OnEnter"|"OnLeave", func: function): nil
-- Callbacks: OnClick, OnEnter, OnLeave

---@class AceGUIInteractiveLabelWidget: AceGUIWidgetBase
---@field public SetText fun(self: AceGUIInteractiveLabelWidget, text: string): nil
---@field public SetColor fun(self: AceGUIInteractiveLabelWidget, r: number, g: number, b: number): nil
---@field public SetFont fun(self: AceGUIInteractiveLabelWidget, font: string, height: number, flags: string): nil
---@field public SetFontObject fun(self: AceGUIInteractiveLabelWidget, font: any): nil
---@field public SetImage fun(self: AceGUIInteractiveLabelWidget, image: string, ...): nil
---@field public SetImageSize fun(self: AceGUIInteractiveLabelWidget, width: number, height: number): nil
---@field public SetHighlight fun(self: AceGUIInteractiveLabelWidget, ...): nil
---@field public SetHighlightTexCoord fun(self: AceGUIInteractiveLabelWidget, ...): nil
---@field public SetCallback fun(self: AceGUIInteractiveLabelWidget, event: "OnClick"|"OnEnter"|"OnLeave", func: function): nil
-- Callbacks: OnClick, OnEnter, OnLeave

---@class AceGUIKeybindingWidget: AceGUIWidgetBase
---@field public SetKey fun(self: AceGUIKeybindingWidget, key: string): nil
---@field public GetKey fun(self: AceGUIKeybindingWidget): string
---@field public SetLabel fun(self: AceGUIKeybindingWidget, text: string): nil
---@field public SetDisabled fun(self: AceGUIKeybindingWidget, flag: boolean): nil
---@field public SetCallback fun(self: AceGUIKeybindingWidget, event: "OnKeyChanged"|"OnEnter"|"OnLeave", func: function): nil
-- Callbacks: OnKeyChanged, OnEnter, OnLeave

---@class AceGUILabelWidget: AceGUIWidgetBase
---@field public SetText fun(self: AceGUILabelWidget, text: string): nil
---@field public SetColor fun(self: AceGUILabelWidget, r: number, g: number, b: number): nil
---@field public SetFont fun(self: AceGUILabelWidget, font: string, height: number, flags: string): nil
---@field public SetFontObject fun(self: AceGUILabelWidget, font: any): nil
---@field public SetImage fun(self: AceGUILabelWidget, image: string, ...): nil
---@field public SetImageSize fun(self: AceGUILabelWidget, width: number, height: number): nil
-- No callbacks

---@class AceGUIMultiLineEditBoxWidget: AceGUIWidgetBase
---@field public SetText fun(self: AceGUIMultiLineEditBoxWidget, text: string): nil
---@field public GetText fun(self: AceGUIMultiLineEditBoxWidget): string
---@field public SetLabel fun(self: AceGUIMultiLineEditBoxWidget, text: string): nil
---@field public SetNumLines fun(self: AceGUIMultiLineEditBoxWidget, num: number): nil
---@field public SetDisabled fun(self: AceGUIMultiLineEditBoxWidget, flag: boolean): nil
---@field public SetMaxLetters fun(self: AceGUIMultiLineEditBoxWidget, num: number): nil
---@field public DisableButton fun(self: AceGUIMultiLineEditBoxWidget, flag: boolean): nil
---@field public SetFocus fun(self: AceGUIMultiLineEditBoxWidget): nil
---@field public HighlightText fun(self: AceGUIMultiLineEditBoxWidget, start: number, end_: number): nil
---@field public SetCallback fun(self: AceGUIMultiLineEditBoxWidget, event: "OnTextChanged"|"OnEnterPressed"|"OnEnter"|"OnLeave", func: function): nil
-- Callbacks: OnTextChanged, OnEnterPressed, OnEnter, OnLeave

---@class AceGUISliderWidget: AceGUIWidgetBase
---@field public SetValue fun(self: AceGUISliderWidget, value: number): nil
---@field public GetValue fun(self: AceGUISliderWidget): number
---@field public SetSliderValues fun(self: AceGUISliderWidget, min: number, max: number, step: number): nil
---@field public SetIsPercent fun(self: AceGUISliderWidget, flag: boolean): nil
---@field public SetLabel fun(self: AceGUISliderWidget, text: string): nil
---@field public SetDisabled fun(self: AceGUISliderWidget, flag: boolean): nil
---@field public SetCallback fun(self: AceGUISliderWidget, event: "OnValueChanged"|"OnMouseUp"|"OnEnter"|"OnLeave", func: function): nil
-- Callbacks: OnValueChanged, OnMouseUp, OnEnter, OnLeave

---@class AceGUIDropdownGroupContainer: AceGUIContainerBase
---@field public SetTitle fun(self: AceGUIDropdownGroupContainer, text: string): nil
---@field public SetGroupList fun(self: AceGUIDropdownGroupContainer, table: table, order?: table): nil
---@field public SetGroup fun(self: AceGUIDropdownGroupContainer, key: any): nil
---@field public SetDropdownWidth fun(self: AceGUIDropdownGroupContainer, width: number): nil
---@field public SetStatusTable fun(self: AceGUIDropdownGroupContainer, table: table): nil
---@field public SetCallback fun(self: AceGUIDropdownGroupContainer, event: "OnGroupSelected", func: function): nil
-- Callbacks: OnGroupSelected

---@class AceGUIFrameContainer: AceGUIContainerBase
---@field public SetTitle fun(self: AceGUIFrameContainer, text: string): nil
---@field public SetStatusText fun(self: AceGUIFrameContainer, text: string): nil
---@field public SetStatusTable fun(self: AceGUIFrameContainer, table: table): nil
---@field public ApplyStatus fun(self: AceGUIFrameContainer): nil
---@field public OnAcquite fun(self: AceGUIFrameContainer): nil
---@field public OnRelease fun(self: AceGUIFrameContainer): nil
---@field public OnWidthSet fun(self: AceGUIFrameContainer, width: number): nil
---@field public OnHeightSet fun(self: AceGUIFrameContainer, height: number): nil
---@field public SetTitle fun(self: AceGUIFrameContainer, title: string): nil
---@field public SetStatusText fun(self: AceGUIFrameContainer, text: string): nil
---@field public Hide fun(self: AceGUIFrameContainer): nil
---@field public Show fun(self: AceGUIFrameContainer): nil
---@field public EnableResize fun(self: AceGUIFrameContainer, state: boolean): nil
---@field public SetStatusTable fun(self: AceGUIFrameContainer, status: table): nil
---@field public ApplyStatus fun(self: AceGUIFrameContainer): nil
---@field public SetCallback fun(self: AceGUIFrameContainer, event: "OnClose"|"OnEnterStatusBar"|"OnLeaveStatusBar", func: function): nil
-- Callbacks: OnClose, OnEnterStatusBar, OnLeaveStatusBar

---@class AceGUIInlineGroupContainer: AceGUIContainerBase
---@field public SetTitle fun(self: AceGUIInlineGroupContainer, text: string): nil
-- No callbacks

---@class AceGUIScrollFrameContainer: AceGUIContainerBase
---@field public SetScroll fun(self: AceGUIScrollFrameContainer, value: number): nil
---@field public SetStatusTable fun(self: AceGUIScrollFrameContainer, table: table): nil
-- No callbacks

---@class AceGUISimpleGroupContainer: AceGUIContainerBase
-- No additional APIs or callbacks

---@class AceGUITabGroupContainer: AceGUIContainerBase
---@field public SetTitle fun(self: AceGUITabGroupContainer, text: string): nil
---@field public SetTabs fun(self: AceGUITabGroupContainer, table: table): nil
---@field public SelectTab fun(self: AceGUITabGroupContainer, key: any): nil
---@field public SetStatusTable fun(self: AceGUITabGroupContainer, table: table): nil
---@field public SetCallback fun(self: AceGUITabGroupContainer, event: "OnGroupSelected"|"OnTabEnter"|"OnTabLeave", func: function): nil
-- Callbacks: OnGroupSelected, OnTabEnter, OnTabLeave

---@class AceGUITreeGroupContainer: AceGUIContainerBase
---@field public SetTree fun(self: AceGUITreeGroupContainer, tree: table): nil
---@field public SelectByPath fun(self: AceGUITreeGroupContainer, ...): nil
---@field public SelectByValue fun(self: AceGUITreeGroupContainer, uniquevalue: any): nil
---@field public EnableButtonTooltips fun(self: AceGUITreeGroupContainer, flag: boolean): nil
---@field public SetStatusTable fun(self: AceGUITreeGroupContainer, table: table): nil
---@field public SetCallback fun(self: AceGUITreeGroupContainer, event: "OnGroupSelected"|"OnTreeResize"|"OnButtonEnter"|"OnButtonLeave", func: function): nil
-- Callbacks: OnGroupSelected, OnTreeResize, OnButtonEnter, OnButtonLeave
