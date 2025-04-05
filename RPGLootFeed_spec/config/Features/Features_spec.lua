local nsMocks = require("RPGLootFeed_spec._mocks.Internal.addonNamespace")
local assert = require("luassert")
local busted = require("busted")
local io = require("io")
local before_each = busted.before_each
local describe = busted.describe
local it = busted.it
local setup = busted.setup
local _ = require("luassert.match")._

describe("Features module", function()
	describe("load order", function()
		it("loads after ConfigOptions", function()
			local ns = nsMocks:unitLoadedAfter(nsMocks.LoadSections.ConfigOptions)
			local features = assert(loadfile("RPGLootFeed/config/Features/Features.lua"))("TestAddon", ns)
			---@diagnostic disable-next-line: redundant-parameter
			assert.is_not_nil(features, "ConfigOptions should be loaded before Features")
		end)
	end)

	---@type test_G_RLF, number, table<number, string>
	local ns, lastFeature, reverseMap
	before_each(function()
		reverseMap = {}
		-- Define the global G_RLF
		ns = nsMocks:unitLoadedAfter(nsMocks.LoadSections.All)
		-- Load the list module before each test
		assert(loadfile("RPGLootFeed/config/Features/Features.lua"))("TestAddon", ns)
		lastFeature = 0
		for k, v in pairs(ns.mainFeatureOrder) do
			if v > lastFeature then
				lastFeature = v
			end
			reverseMap[v] = k
		end
	end)

	it("has parity with th FeatureModules enum", function()
		local featureModules = ns.FeatureModule
		local featureOrder = ns.mainFeatureOrder

		local numberOfFeatureModules = 0
		for _, _ in pairs(featureModules) do
			numberOfFeatureModules = numberOfFeatureModules + 1
		end
		local numberOfFeatureOrder = 0
		for _, _ in pairs(featureOrder) do
			numberOfFeatureOrder = numberOfFeatureOrder + 1
		end
		assert.equal(
			numberOfFeatureModules,
			numberOfFeatureOrder,
			"FeatureModules and mainFeatureOrder should have the same number of elements"
		)
	end)

	it("has a config for each loaded feature in features.xml", function()
		-- Open file in read mode
		local file = io.open("RPGLootFeed/Features/features.xml", "r")
		if not file then
			assert.is_not_nil(file)
			return
		end

		local featureImports = 0
		for line in file:lines() do
			if line:find("file=") then
				-- Skip lines that do not contain "file="
				if not (line:find('file="_Internals')) then
					featureImports = featureImports + 1
				end
			end
		end

		-- Close the file
		file:close()

		assert.equal(
			lastFeature,
			featureImports,
			"Number of feature imports in features.xml should match the number of features in mainFeatureOrder"
		)
	end)

	describe("enable features", function()
		local featureToggles = {}
		before_each(function()
			local orderLookup = {}
			for _, orderValue in pairs(ns.mainFeatureOrder) do
				orderLookup[orderValue] = true
			end

			local groupOptions = ns.options.args.features.args
			for k, v in pairs(groupOptions) do
				if type(v) == "table" and v.type == "toggle" and v.order and orderLookup[v.order] then
					featureToggles[v.order] = v
				end
			end
		end)

		it("has a toggle for each feature", function()
			for i = 1, lastFeature do
				assert.is_not_nil(featureToggles[i])
			end
		end)

		it("has a set handler that calls Enable Module when value is true", function()
			local stubEnableModule = stub(ns.RLF, "EnableModule")
			for _, v in pairs(featureToggles) do
				---@diagnostic disable-next-line: redundant-parameter
				assert.is_not_nil(v.set, v.name .. " should have a set handler")
				v.set(nil, true)
			end

			assert.stub(stubEnableModule).was.called(8)
			---@diagnostic disable: undefined-field
			assert.equal(ns.FeatureModule.ItemLoot, stubEnableModule.calls[1].vals[2])
			assert.equal(ns.FeatureModule.PartyLoot, stubEnableModule.calls[2].vals[2])
			assert.equal(ns.FeatureModule.Currency, stubEnableModule.calls[3].vals[2])
			assert.equal(ns.FeatureModule.Money, stubEnableModule.calls[4].vals[2])
			assert.equal(ns.FeatureModule.Experience, stubEnableModule.calls[5].vals[2])
			assert.equal(ns.FeatureModule.Reputation, stubEnableModule.calls[6].vals[2])
			assert.equal(ns.FeatureModule.Profession, stubEnableModule.calls[7].vals[2])
			assert.equal(ns.FeatureModule.TravelPoints, stubEnableModule.calls[8].vals[2])
			---@diagnostic enable: undefined-field
		end)

		it("has a set handler that calls Disable Module when value is false", function()
			local stubDisabeModule = stub(ns.RLF, "DisableModule")
			for _, v in pairs(featureToggles) do
				---@diagnostic disable-next-line: redundant-parameter
				assert.is_not_nil(v.set, v.name .. " should have a set handler")
				v.set(nil, false)
			end

			assert.stub(stubDisabeModule).was.called(8)
			---@diagnostic disable: undefined-field
			assert.equal(ns.FeatureModule.ItemLoot, stubDisabeModule.calls[1].vals[2])
			assert.equal(ns.FeatureModule.PartyLoot, stubDisabeModule.calls[2].vals[2])
			assert.equal(ns.FeatureModule.Currency, stubDisabeModule.calls[3].vals[2])
			assert.equal(ns.FeatureModule.Money, stubDisabeModule.calls[4].vals[2])
			assert.equal(ns.FeatureModule.Experience, stubDisabeModule.calls[5].vals[2])
			assert.equal(ns.FeatureModule.Reputation, stubDisabeModule.calls[6].vals[2])
			assert.equal(ns.FeatureModule.Profession, stubDisabeModule.calls[7].vals[2])
			assert.equal(ns.FeatureModule.TravelPoints, stubDisabeModule.calls[8].vals[2])
			---@diagnostic enable: undefined-field
		end)
	end)
end)
