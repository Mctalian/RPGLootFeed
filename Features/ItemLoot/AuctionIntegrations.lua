local addonName, G_RLF = ...

local AuctionIntegrations = {}
local Integ_Auctionator = {}
local Integ_TSM = {}
local Integ_Nil = {}

function AuctionIntegrations:Init()
	if self.initialized then
		return
	end

	self.initialized = true
	local possibleIntegrations = { Integ_Auctionator, Integ_TSM }
	self.nilIntegration = Integ_Nil
	self.activeIntegrations = {}
	self.activeIntegration = nil

	self.numActiveIntegrations = 0
	for _, integration in ipairs(possibleIntegrations) do
		if integration:Init() then
			self.activeIntegrations[integration:ToString()] = integration
			self.numActiveIntegrations = self.numActiveIntegrations + 1
		end
	end

	G_RLF:LogDebug("Active AH integrations: " .. self.numActiveIntegrations)

	local ahSource = G_RLF.db.global.auctionHouseSource

	if self.numActiveIntegrations == 1 then
		for _, integration in pairs(self.activeIntegrations) do
			self.activeIntegration = integration
		end
	elseif ahSource then
		if ahSource == Integ_Nil:ToString() then
			self.activeIntegration = self.nilIntegration
		end
		self.activeIntegration = self.activeIntegrations[ahSource]
		if not self.activeIntegration then
			self.activeIntegration = self.nilIntegration
		end
	end

	if self.activeIntegration and ahSource ~= self.activeIntegration:ToString() then
		G_RLF.db.global.auctionHouseSource = self.activeIntegration:ToString()
	end
end

function AuctionIntegrations:GetAHPrice(itemLink)
	if self.activeIntegration then
		return self.activeIntegration:GetAHPrice(itemLink)
	end

	return nil
end

function Integ_Nil:Init()
	return true
end

function Integ_Nil:ToString()
	return G_RLF.L["None"]
end

function Integ_Nil:GetAHPrice(itemLink)
	return nil
end

function Integ_Auctionator:Init()
	if Auctionator and Auctionator.API and Auctionator.API.v1 and Auctionator.API.v1.GetAuctionPriceByItemLink then
		Auctionator.API.v1.RegisterForDBUpdate(addonName, function()
			G_RLF:LogDebug("Auctionator DB updated")
		end)
		return true
	end

	return false
end

function Integ_Auctionator:ToString()
	return G_RLF.L["Auctionator"]
end

function Integ_Auctionator:GetAHPrice(itemLink)
	local price = Auctionator.API.v1.GetAuctionPriceByItemLink(addonName, itemLink)
	if price then
		return price
	end

	return nil
end

function Integ_TSM:Init()
	return TSM_API ~= nil
end

function Integ_TSM:ToString()
	return G_RLF.L["TSM"]
end

function Integ_TSM:GetAHPrice(itemLink)
	if TSM_API and TSM_API.ToItemString and TSM_API.GetCustomPriceValue then
		local itemString = TSM_API.Item:ToItemString(itemLink)
		if itemString then
			local marketValue = TSM_API:GetCustomPriceValue("DBMarket", itemString)
			if marketValue then
				return marketValue
			end
		end
	end

	return nil
end

G_RLF.AuctionIntegrations = AuctionIntegrations

return AuctionIntegrations
