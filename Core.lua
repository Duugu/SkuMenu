---@diagnostic disable: undefined-field, undefined-doc-name, undefined-doc-param

---------------------------------------------------------------------------------------------------------------------------------------
local MODULE_NAME = "SkuMenu"
local ADDON_NAME = ...

SkuMenu.L = LibStub("AceLocale-3.0"):GetLocale("SkuMenu", false)
SkuMenu.Loc = SkuMenu.L["locale"]
SkuMenu.Locs = {"enUS", "deDE",}

---------------------------------------------------------------------------------------------------------------------------------------
SkuMenu.debug = false
function dprint(...)
	if SkuMenu.debug == true then
		print("Debug:", ...)
	end
end
