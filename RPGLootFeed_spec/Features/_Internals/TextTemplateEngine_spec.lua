local nsMocks = require("RPGLootFeed_spec._mocks.Internal.addonNamespace")
local assert = require("luassert")
local match = require("luassert.match")
local busted = require("busted")
local before_each = busted.before_each
local describe = busted.describe
local it = busted.it
local spy = busted.spy
local stub = busted.stub

describe("TextTemplateEngine", function()
	local _ = match._
	local TextTemplateEngine, ns, fnMocks

	before_each(function()
		fnMocks = require("RPGLootFeed_spec._mocks.WoWGlobals.Functions")
		ns = nsMocks:unitLoadedAfter(nsMocks.LoadSections.All)

		-- Set up default configuration
		ns.db.global.money.accountantMode = false
		ns.db.global.money.showMoneyTotal = true
		ns.db.global.money.abbreviateTotal = false

		-- Mock localization
		ns.L = {
			["ThousandAbbrev"] = "K",
			["MillionAbbrev"] = "M",
			["BillionAbbrev"] = "B",
		}

		-- Mock C_CurrencyInfo
		local mockCurrencyInfo = {
			GetCoinTextureString = stub().returns("5|TInterface\\MoneyFrame\\UI-GoldIcon:0:0:2:0|t"),
		}
		_G.C_CurrencyInfo = mockCurrencyInfo

		-- Mock GetMoney
		fnMocks.GetMoney.returns(1500000) -- 150 gold

		-- Load the TextTemplateEngine module
		TextTemplateEngine = assert(loadfile("RPGLootFeed/Features/_Internals/TextTemplateEngine.lua"))("TestAddon", ns)
	end)

	describe("ProcessTemplate", function()
		it("processes simple templates with placeholders", function()
			local template = "Gained {amount} gold"
			local data = { quantity = 100, type = "Money" }

			local result = TextTemplateEngine:ProcessTemplate(template, data)

			assert.equal("Gained 100 gold", result)
		end)

		it("handles empty or nil templates", function()
			assert.equal("", TextTemplateEngine:ProcessTemplate("", {}))
			assert.equal("", TextTemplateEngine:ProcessTemplate(nil, {}))
		end)

		it("processes templates with multiple placeholders", function()
			local template = "{sign}{amount} total: {total}"
			local data = { quantity = 50, type = "Money" }

			local result = TextTemplateEngine:ProcessTemplate(template, data, 25)

			assert.equal("50 total: 75", result)
		end)

		it("handles negative amounts correctly", function()
			local template = "{sign}{absAmount}"
			local data = { quantity = -100, type = "Money" }

			local result = TextTemplateEngine:ProcessTemplate(template, data)

			assert.equal("-100", result)
		end)
	end)

	describe("CreateTemplateContext", function()
		it("creates basic context with amount and total", function()
			local data = { quantity = 150, type = "Money" }
			local existingQuantity = 50

			local context = TextTemplateEngine:CreateTemplateContext(data, existingQuantity)

			assert.equal(150, context.amount)
			assert.equal(200, context.total)
			assert.equal(50, context.existingQuantity)
			assert.equal("", context.sign)
			assert.equal(200, context.absTotal)
			assert.equal(150, context.absAmount)
		end)

		it("handles negative totals correctly", function()
			local data = { quantity = -200, type = "Money" }
			local existingQuantity = 50

			local context = TextTemplateEngine:CreateTemplateContext(data, existingQuantity)

			assert.equal(-150, context.total)
			assert.equal("-", context.sign)
			assert.equal(150, context.absTotal)
			assert.equal(200, context.absAmount)
		end)

		it("defaults existingQuantity to 0 when not provided", function()
			local data = { quantity = 100, type = "Money" }

			local context = TextTemplateEngine:CreateTemplateContext(data)

			assert.equal(0, context.existingQuantity)
			assert.equal(100, context.total)
		end)
	end)

	describe("context provider registration", function()
		it("allows registering context providers", function()
			local testProvider = function(context, data)
				context.testValue = "registered"
			end

			TextTemplateEngine:RegisterContextProvider("TestType", testProvider)

			assert.equal(testProvider, TextTemplateEngine.contextProviders["TestType"])
		end)

		it("uses registered context provider during template processing", function()
			-- Register a test provider
			TextTemplateEngine:RegisterContextProvider("TestType", function(context, data)
				context.customField = "custom_" .. data.quantity
			end)

			local data = { type = "TestType", quantity = 42 }
			local context = TextTemplateEngine:CreateTemplateContext(data)

			assert.equal("custom_42", context.customField)
		end)
	end)

	describe("AbbreviateNumber", function()
		it("abbreviates thousands", function()
			local result = TextTemplateEngine:AbbreviateNumber(1500)
			assert.equal("1.50K", result)
		end)

		it("abbreviates millions", function()
			local result = TextTemplateEngine:AbbreviateNumber(2500000)
			assert.equal("2.50M", result)
		end)

		it("abbreviates billions", function()
			local result = TextTemplateEngine:AbbreviateNumber(3500000000)
			assert.equal("3.50B", result)
		end)

		it("does not abbreviate numbers under 1000", function()
			local result = TextTemplateEngine:AbbreviateNumber(500)
			assert.equal("500", result)
		end)

		it("handles missing localization gracefully", function()
			ns.L = {} -- Clear localization
			local result = TextTemplateEngine:AbbreviateNumber(1500)
			assert.equal("1.50K", result) -- Should use fallback
		end)
	end)

	describe("ProcessAllTextElements", function()
		it("processes all text elements and returns row-indexed map", function()
			local elementData = {
				quantity = 50000,
				type = "Money",
				textElements = {
					[1] = {
						primary = { type = "primary", template = "{amount} copper" },
					},
					[2] = {
						context = { type = "context", template = "Total: {total}" },
					},
				},
			}

			local result = TextTemplateEngine:ProcessAllTextElements(elementData, 25000)

			assert.equal("50000 copper", result[1].primary)
			assert.equal("Total: 75000", result[2].context)
		end)

		it("handles empty text elements table", function()
			local elementData = {
				quantity = 50000,
				type = "Money",
				textElements = {},
			}

			local result = TextTemplateEngine:ProcessAllTextElements(elementData)

			assert.is_table(result)
			assert.equal(0, next(result) and 1 or 0) -- Empty table
		end)

		it("handles missing text elements", function()
			local elementData = {
				quantity = 50000,
				type = "Money",
			}

			local result = TextTemplateEngine:ProcessAllTextElements(elementData)

			assert.is_table(result)
			assert.equal(0, next(result) and 1 or 0) -- Empty table
		end)

		it("handles spacer text elements", function()
			local elementData = {
				quantity = 50000,
				type = "Money",
				textElements = {
					[1] = {
						spacer = { type = "spacer", spacerCount = 4 },
					},
				},
			}

			local result = TextTemplateEngine:ProcessAllTextElements(elementData)

			assert.equal("    ", result[1].spacer) -- Should be 4 spaces
		end)

		it("handles quantity text elements", function()
			local elementData = {
				quantity = 5,
				type = "ItemLoot",
				textElements = {
					[1] = {
						quantity = { type = "quantity", template = "{quantityText}" },
					},
				},
			}

			local result = TextTemplateEngine:ProcessAllTextElements(elementData)

			assert.equal("x5", result[1].quantity)
		end)

		it("handles totalCount text elements", function()
			local elementData = {
				quantity = 1,
				itemCount = 15,
				type = "ItemLoot",
				textElements = {
					[1] = {
						totalCount = { type = "totalCount", template = "{totalCountText}" },
					},
				},
			}

			local result = TextTemplateEngine:ProcessAllTextElements(elementData)

			assert.equal("(15)", result[1].totalCount)
		end)
	end)

	describe("formatting helpers", function()
		it("FormatQuantityText respects showOneQuantity setting", function()
			ns.db.global.misc.showOneQuantity = false
			local result = TextTemplateEngine:FormatQuantityText(1, "ItemLoot")
			assert.equal("", result)

			ns.db.global.misc.showOneQuantity = true
			local result2 = TextTemplateEngine:FormatQuantityText(1, "ItemLoot")
			assert.equal("x1", result2)
		end)

		it("FormatQuantityDisplay adds spacing", function()
			local result = TextTemplateEngine:FormatQuantityDisplay(5, "ItemLoot")
			assert.equal(" x5", result)

			-- When quantity text is empty, should return empty
			ns.db.global.misc.showOneQuantity = false
			local result2 = TextTemplateEngine:FormatQuantityDisplay(1, "ItemLoot")
			assert.equal("", result2)
		end)

		it("FormatTotalCountText formats inventory totals", function()
			local result = TextTemplateEngine:FormatTotalCountText(15, "ItemLoot")
			assert.equal("(15)", result)

			local result2 = TextTemplateEngine:FormatTotalCountText(0, "ItemLoot")
			assert.equal("", result2)

			local result3 = TextTemplateEngine:FormatTotalCountText(nil, "ItemLoot")
			assert.equal("", result3)
		end)

		it("ExtractItemName handles item links", function()
			local itemLink = "|cff0070dd|Hitem:12345:0:0:0:0:0:0:0:70:0:0:0:0|h[Epic Sword]|h|r"
			local result = TextTemplateEngine:ExtractItemName(itemLink)
			assert.equal("Epic Sword", result)

			local result2 = TextTemplateEngine:ExtractItemName("")
			assert.equal("", result2)

			local result3 = TextTemplateEngine:ExtractItemName("Plain Text")
			assert.equal("Plain Text", result3)
		end)
	end)

	describe("ProcessRowElements", function()
		it("processes row elements by index", function()
			local elementData = {
				quantity = 50,
				type = "TestType",
				textElements = {
					[1] = {
						primary = {
							type = "primary",
							template = "{amount}",
							order = 1,
						},
						spacer = {
							type = "spacer",
							spacerCount = 2,
							order = 2,
						},
						context = {
							type = "context",
							template = "Total: {total}",
							order = 3,
						},
					},
				},
			}

			local result = TextTemplateEngine:ProcessRowElements(1, elementData, 25)

			assert.equal("50  Total: 75", result)
		end)

		it("throws error for missing row", function()
			local elementData = { quantity = 50, type = "TestType" }

			assert.has_error(function()
				TextTemplateEngine:ProcessRowElements(1, elementData)
			end, "TestType: textElements row is nil for index: 1")
		end)

		it("throws error for missing textElements", function()
			local elementData = {
				quantity = 50,
				type = "TestType",
				textElements = {
					[2] = { primary = { type = "primary", template = "{amount}", order = 1 } },
				},
			}

			assert.has_error(function()
				TextTemplateEngine:ProcessRowElements(1, elementData)
			end, "TestType: textElements row is nil for index: 1")
		end)

		it("handles order conflicts by auto-incrementing", function()
			local elementData = {
				quantity = 50,
				type = "TestType",
				textElements = {
					[1] = {
						first = { type = "primary", template = "A", order = 1 },
						second = { type = "context", template = "B", order = 1 }, -- Same order
						third = { type = "spacer", spacerCount = 1, order = 1 }, -- Same order
					},
				},
			}

			local result = TextTemplateEngine:ProcessRowElements(1, elementData)

			-- Should have all three elements in some order (auto-incremented)
			assert.matches("A", result)
			assert.matches("B", result)
			assert.matches(" ", result) -- spacer
		end)

		it("handles mixed element types", function()
			local elementData = {
				quantity = 100,
				type = "TestType",
				textElements = {
					[1] = {
						suffix = {
							type = "context",
							template = "copper",
							order = 3,
						},
						amount = {
							type = "primary",
							template = "{amount}",
							order = 1,
						},
						space = {
							type = "spacer",
							spacerCount = 1,
							order = 2,
						},
					},
				},
			}

			local result = TextTemplateEngine:ProcessRowElements(1, elementData)

			assert.equal("100 copper", result)
		end)

		it("returns empty string when result is only whitespace", function()
			local elementData = {
				quantity = 100,
				type = "TestType",
				textElements = {
					[1] = {
						spacer1 = {
							type = "spacer",
							spacerCount = 2,
							order = 1,
						},
						emptyTemplate = {
							type = "context",
							template = "", -- Empty template
							order = 2,
						},
						spacer2 = {
							type = "spacer",
							spacerCount = 3,
							order = 3,
						},
					},
				},
			}

			local result = TextTemplateEngine:ProcessRowElements(1, elementData)

			-- Should return empty string since result would be "  " + "" + "   " = "     " (only whitespace)
			assert.equal("", result)
		end)
	end)
end)
