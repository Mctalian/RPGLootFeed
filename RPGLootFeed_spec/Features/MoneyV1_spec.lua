-- local nsMocks = require("RPGLootFeed_spec._mocks.Internal.addonNamespace")
-- local assert = require("luassert")
-- local match = require("luassert.match")
-- local busted = require("busted")
-- local before_each = busted.before_each
-- local describe = busted.describe
-- local it = busted.it
-- local mock = busted.mock
-- local spy = busted.spy
-- local stub = busted.stub

-- describe("Money module", function()
-- 	local _ = match._
-- 	local MoneyModule, ns, fnMocks

-- 	before_each(function()
-- 		fnMocks = require("RPGLootFeed_spec._mocks.WoWGlobals.Functions")
-- 		ns = nsMocks:unitLoadedAfter(nsMocks.LoadSections.All)
-- 		-- Load the LootDisplayProperties module to populate `ns`
-- 		assert(loadfile("RPGLootFeed/Features/_Internals/LootDisplayProperties.lua"))("TestAddon", ns)

-- 		-- Ensure `ns` has been populated correctly by LootDisplayProperties
-- 		assert.is_not_nil(ns.InitializeLootDisplayProperties)
-- 		-- Load the list module before each test
-- 		MoneyModule = assert(loadfile("RPGLootFeed/Features/Money.lua"))("TestAddon", ns)
-- 	end)

-- 	it("Money:OnInitialize enables or disables the module based on global moneyFeed", function()
-- 		ns.db.global.money.enabled = true
-- 		local spyEnable = spy.on(MoneyModule, "Enable")
-- 		MoneyModule:OnInitialize()
-- 		assert.spy(spyEnable).was.called(1)

-- 		ns.db.global.money.enabled = false
-- 		local spyDisable = spy.on(MoneyModule, "Disable")
-- 		MoneyModule:OnInitialize()
-- 		assert.spy(spyDisable).was.called(1)
-- 	end)

-- 	it("Money:OnEnable registers events and sets startingMoney", function()
-- 		stub(MoneyModule, "RegisterEvent")
-- 		local stubGetMoney = fnMocks.GetMoney.returns(1000)

-- 		MoneyModule:OnEnable()

-- 		assert.stub(MoneyModule.RegisterEvent).was.called_with(_, "PLAYER_MONEY")
-- 		assert.stub(MoneyModule.RegisterEvent).was.called_with(_, "PLAYER_ENTERING_WORLD")
-- 		assert.equal(MoneyModule.startingMoney, 1000)

-- 		MoneyModule.RegisterEvent:revert()
-- 	end)

-- 	it("Money:OnDisable unregisters events", function()
-- 		stub(MoneyModule, "UnregisterEvent")

-- 		MoneyModule:OnDisable()

-- 		assert.stub(MoneyModule.UnregisterEvent).was.called_with(_, "PLAYER_MONEY")
-- 		assert.stub(MoneyModule.UnregisterEvent).was.called_with(_, "PLAYER_ENTERING_WORLD")

-- 		MoneyModule.UnregisterEvent:revert()
-- 	end)

-- 	it("Money:PLAYER_ENTERING_WORLD sets startingMoney", function()
-- 		fnMocks.GetMoney.returns(2000)

-- 		MoneyModule:PLAYER_ENTERING_WORLD("PLAYER_ENTERING_WORLD")

-- 		assert.equal(MoneyModule.startingMoney, 2000)
-- 	end)

-- 	it("Money:PLAYER_MONEY updates startingMoney and creates a new element", function()
-- 		fnMocks.GetMoney.returns(3000)
-- 		local elementMock = mock(MoneyModule.Element, false)
-- 		local elementShowSpy, elementPlaySoundSpy
-- 		local stubInitializeLootDisplayProperties = stub(ns, "InitializeLootDisplayProperties", function(e)
-- 			elementShowSpy = spy.on(e, "Show")
-- 		end)

-- 		MoneyModule.startingMoney = 1000
-- 		MoneyModule:PLAYER_MONEY("PLAYER_MONEY")

-- 		assert.equal(MoneyModule.startingMoney, 3000)
-- 		assert.spy(elementMock.new).was.called_with(MoneyModule.Element, 2000)
-- 		assert.spy(elementShowSpy).was.called(1)

-- 		stubInitializeLootDisplayProperties:revert()
-- 	end)

-- 	describe("Money.Element", function()
-- 		local C_CurrencyInfoMock

-- 		before_each(function()
-- 			-- Set up default configuration
-- 			ns.db.global.money.enableIcon = true
-- 			ns.db.global.money.accountantMode = false
-- 			ns.db.global.money.showMoneyTotal = true
-- 			ns.db.global.money.abbreviateTotal = false
-- 			ns.db.global.misc.hideAllIcons = false

-- 			-- Mock C_CurrencyInfo
-- 			C_CurrencyInfoMock = {
-- 				GetCoinTextureString = stub().returns("5|TInterface\\MoneyFrame\\UI-GoldIcon:0:0:2:0|t 0|TInterface\\MoneyFrame\\UI-SilverIcon:0:0:2:0|t 0|TInterface\\MoneyFrame\\UI-CopperIcon:0:0:2:0|t")
-- 			}
-- 			_G.C_CurrencyInfo = C_CurrencyInfoMock
-- 		end)

-- 		describe("element creation", function()
-- 			it("creates element with correct basic properties", function()
-- 				local element = MoneyModule.Element:new(1000)

-- 				assert.is_not_nil(element)
-- 				assert.equal("Money", element.type)
-- 				assert.equal("MONEY_LOOT", element.key)
-- 				assert.equal(1000, element.quantity)
-- 				assert.equal(ns.DefaultIcons.MONEY, element.icon)
-- 				assert.equal(ns.ItemQualEnum.Poor, element.quality)
-- 			end)

-- 			it("returns nil when quantity is nil", function()
-- 				local element = MoneyModule.Element:new(nil)
-- 				assert.is_nil(element)
-- 			end)

-- 			it("returns nil when quantity is not provided", function()
-- 				local element = MoneyModule.Element:new()
-- 				assert.is_nil(element)
-- 			end)

-- 			it("hides icon when enableIcon is false", function()
-- 				ns.db.global.money.enableIcon = false
-- 				local element = MoneyModule.Element:new(1000)
-- 				assert.is_nil(element.icon)
-- 			end)

-- 			it("hides icon when hideAllIcons is true", function()
-- 				ns.db.global.misc.hideAllIcons = true
-- 				local element = MoneyModule.Element:new(1000)
-- 				assert.is_nil(element.icon)
-- 			end)
-- 		end)

-- 		describe("textFn behavior", function()
-- 			it("generates positive money text without existing quantity", function()
-- 				C_CurrencyInfoMock.GetCoinTextureString.returns("5|TInterface\\MoneyFrame\\UI-GoldIcon:0:0:2:0|t")
-- 				local element = MoneyModule.Element:new(50000) -- 5 gold

-- 				local result = element.textFn()

-- 				assert.spy(C_CurrencyInfoMock.GetCoinTextureString).was.called_with(50000)
-- 				assert.equal("5|TInterface\\MoneyFrame\\UI-GoldIcon:0:0:2:0|t", result)
-- 			end)

-- 			it("generates negative money text", function()
-- 				C_CurrencyInfoMock.GetCoinTextureString.returns("5|TInterface\\MoneyFrame\\UI-GoldIcon:0:0:2:0|t")
-- 				local element = MoneyModule.Element:new(-50000) -- -5 gold

-- 				local result = element.textFn()

-- 				assert.spy(C_CurrencyInfoMock.GetCoinTextureString).was.called_with(50000) -- absolute value
-- 				assert.equal("-5|TInterface\\MoneyFrame\\UI-GoldIcon:0:0:2:0|t", result)
-- 			end)

-- 			it("handles existing quantity correctly", function()
-- 				C_CurrencyInfoMock.GetCoinTextureString.returns("10|TInterface\\MoneyFrame\\UI-GoldIcon:0:0:2:0|t")
-- 				local element = MoneyModule.Element:new(50000) -- 5 gold

-- 				local result = element.textFn(50000) -- existing 5 gold

-- 				assert.spy(C_CurrencyInfoMock.GetCoinTextureString).was.called_with(100000) -- total 10 gold
-- 				assert.equal("10|TInterface\\MoneyFrame\\UI-GoldIcon:0:0:2:0|t", result)
-- 			end)

-- 			it("generates accountant mode text with parentheses", function()
-- 				ns.db.global.money.accountantMode = true
-- 				C_CurrencyInfoMock.GetCoinTextureString.returns("5|TInterface\\MoneyFrame\\UI-GoldIcon:0:0:2:0|t")
-- 				local element = MoneyModule.Element:new(50000)

-- 				local result = element.textFn()

-- 				assert.equal("(5|TInterface\\MoneyFrame\\UI-GoldIcon:0:0:2:0|t)", result)
-- 			end)

-- 			it("handles negative total with existing quantity", function()
-- 				C_CurrencyInfoMock.GetCoinTextureString.returns("2|TInterface\\MoneyFrame\\UI-GoldIcon:0:0:2:0|t")
-- 				local element = MoneyModule.Element:new(-50000) -- -5 gold

-- 				local result = element.textFn(30000) -- existing 3 gold, total -2 gold

-- 				assert.spy(C_CurrencyInfoMock.GetCoinTextureString).was.called_with(20000) -- absolute value
-- 				assert.equal("-2|TInterface\\MoneyFrame\\UI-GoldIcon:0:0:2:0|t", result)
-- 			end)
-- 		end)

-- 		describe("secondaryTextFn behavior", function()
-- 			before_each(function()
-- 				fnMocks.GetMoney.returns(1500000) -- 150 gold
-- 			end)

-- 			it("returns empty when showMoneyTotal is false", function()
-- 				ns.db.global.money.showMoneyTotal = false
-- 				local element = MoneyModule.Element:new(1000)

-- 				local result = element.secondaryTextFn()

-- 				assert.is_nil(result)
-- 			end)

-- 			it("shows current money total", function()
-- 				C_CurrencyInfoMock.GetCoinTextureString.returns("150|TInterface\\MoneyFrame\\UI-GoldIcon:0:0:2:0|t")
-- 				local element = MoneyModule.Element:new(1000)

-- 				local result = element.secondaryTextFn()

-- 				assert.spy(C_CurrencyInfoMock.GetCoinTextureString).was.called_with(1500000)
-- 				assert.equal("    150|TInterface\\MoneyFrame\\UI-GoldIcon:0:0:2:0|t", result)
-- 			end)

-- 			it("truncates silver and copper for large amounts", function()
-- 				fnMocks.GetMoney.returns(12345678) -- 1234 gold 56 silver 78 copper
-- 				C_CurrencyInfoMock.GetCoinTextureString.returns("1234|TInterface\\MoneyFrame\\UI-GoldIcon:0:0:2:0|t")
-- 				local element = MoneyModule.Element:new(1000)

-- 				local result = element.secondaryTextFn()

-- 				assert.spy(C_CurrencyInfoMock.GetCoinTextureString).was.called_with(12340000) -- truncated to 1234 gold
-- 				assert.equal("    1234|TInterface\\MoneyFrame\\UI-GoldIcon:0:0:2:0|t", result)
-- 			end)

-- 			describe("abbreviation behavior", function()
-- 				before_each(function()
-- 					ns.db.global.money.abbreviateTotal = true
-- 					-- Mock localization
-- 					ns.L = {
-- 						["ThousandAbbrev"] = "K",
-- 						["MillionAbbrev"] = "M",
-- 						["BillionAbbrev"] = "B"
-- 					}
-- 				end)

-- 				it("abbreviates thousands", function()
-- 					fnMocks.GetMoney.returns(15000000) -- 1500 gold
-- 					C_CurrencyInfoMock.GetCoinTextureString.returns("1500|TInterface\\MoneyFrame\\UI-GoldIcon:0:0:2:0|t")
-- 					local element = MoneyModule.Element:new(1000)

-- 					local result = element.secondaryTextFn()

-- 					assert.equal("    1.50K|TInterface\\MoneyFrame\\UI-GoldIcon:0:0:2:0|t", result)
-- 				end)

-- 				it("abbreviates millions", function()
-- 					fnMocks.GetMoney.returns(25000000000) -- 2,500,000 gold
-- 					C_CurrencyInfoMock.GetCoinTextureString.returns("2500000|TInterface\\MoneyFrame\\UI-GoldIcon:0:0:2:0|t")
-- 					local element = MoneyModule.Element:new(1000)

-- 					local result = element.secondaryTextFn()

-- 					assert.equal("    2.50M|TInterface\\MoneyFrame\\UI-GoldIcon:0:0:2:0|t", result)
-- 				end)

-- 				it("abbreviates billions", function()
-- 					fnMocks.GetMoney.returns(35000000000000) -- 3,500,000,000 gold (3.5 billion copper)
-- 					C_CurrencyInfoMock.GetCoinTextureString.returns("3500000000|TInterface\\MoneyFrame\\UI-GoldIcon:0:0:2:0|t")
-- 					local element = MoneyModule.Element:new(1000)

-- 					local result = element.secondaryTextFn()

-- 					assert.equal("    3.50B|TInterface\\MoneyFrame\\UI-GoldIcon:0:0:2:0|t", result)
-- 				end)

-- 				it("does not abbreviate amounts under 1000", function()
-- 					fnMocks.GetMoney.returns(5000000) -- 500 gold
-- 					C_CurrencyInfoMock.GetCoinTextureString.returns("500|TInterface\\MoneyFrame\\UI-GoldIcon:0:0:2:0|t")
-- 					local element = MoneyModule.Element:new(1000)

-- 					local result = element.secondaryTextFn()

-- 					assert.equal("    500|TInterface\\MoneyFrame\\UI-GoldIcon:0:0:2:0|t", result)
-- 				end)
-- 			end)
-- 		end)

-- 		describe("sound functionality", function()
-- 			local stubPlaySoundFile
-- 			before_each(function()
-- 				stubPlaySoundFile = stub(_G, "PlaySoundFile").returns(true, 12345)
-- 				ns.db.global.money.overrideMoneyLootSound = true
-- 				ns.db.global.money.moneyLootSound = "Interface\\AddOns\\RPGLootFeed\\Sounds\\Pickup_Gold_04.ogg"
-- 			end)

-- 			it("plays sound when enabled", function()
-- 				local element = MoneyModule.Element:new(1000)

-- 				element:PlaySoundIfEnabled()

-- 				assert.stub(stubPlaySoundFile).was.called(1)
-- 			end)

-- 			it("does not play sound when override is disabled", function()
-- 				ns.db.global.money.overrideMoneyLootSound = false
-- 				local element = MoneyModule.Element:new(1000)

-- 				element:PlaySoundIfEnabled()

-- 				assert.stub(stubPlaySoundFile).was.not_called()
-- 			end)

-- 			it("does not play sound when path is empty", function()
-- 				ns.db.global.money.moneyLootSound = ""
-- 				local element = MoneyModule.Element:new(1000)

-- 				element:PlaySoundIfEnabled()

-- 				assert.stub(stubPlaySoundFile).was.not_called()
-- 			end)
-- 		end)
-- 	end)
-- end)
