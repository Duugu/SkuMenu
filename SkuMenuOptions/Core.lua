---@diagnostic disable: undefined-field, undefined-doc-name, undefined-doc-param

---------------------------------------------------------------------------------------------------------------------------------------
local MODULE_NAME = "SkuMenu"
local L = SkuMenu.L
local _G = _G
local slower = string.lower
local ssplit = string.split

local tStartDebugTimestamp = GetTime() or 0

--SkuMenu = SkuMenu or LibStub("AceAddon-3.0"):NewAddon("SkuMenu", "AceConsole-3.0", "AceEvent-3.0")
SkuMenu.TTS = LibStub("SkuTTS-1.0"):Create("SkuMenu", false)
SkuMenu.Voice = LibStub("SkuVoice-1.0"):Create("SkuMenu", false)

SkuMenu.Menu = {}
SkuMenu.currentMenuPosition = nil
SkuMenu.MenuAccessKeysChars = {" ", "a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", "ö", "ü", "ä", "ß", "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "Ä", "Ö", "Ü", "shift-,",}
SkuMenu.MenuAccessKeysNumbers = {"1", "2", "3", "4", "5", "6", "7", "8", "9", "0"}

SkuMenu.WowTtsVoices = {}

SkuMenu.inCombat = false
SkuMenu.openMenuAfterCombat = false
SkuMenu.isMoving = false
SkuMenu.openMenuAfterMoving = false
SkuMenu.openMenuAfterPath = ""

SkuMenuMovement = {
	["Flags"] = {
		["MoveForward"] = false,
		["MoveBackward"] = false,
		["StrafeLeft"] = false,
		["StrafeRight"] = false,
		["Ascend"] = false,
		["Descend"] = false,
		["FollowUnit"] = false,
		["IsTurningOrAutorunningOrStrafing"] = false,
		},
	["LastPosition"] = {
		["x"] = 0,
		["y"] = 0,
		},
	["counter"] = 0,
}

SkuMenu.Keys = {}
SkuMenu.Keys.LocNames = {
	["CTRL"] = CTRL_KEY_TEXT,
	["BACKSPACE"] = KEY_BACKSPACE,
	["BACKSPACE_MAC"] = KEY_BACKSPACE_MAC,
	["DELETE"] = KEY_DELETE,
	["DELETE_MAC"] = KEY_DELETE_MAC,
	["DOWN"] = KEY_DOWN,
	["END"] = KEY_END,
	["ENTER"] = KEY_ENTER,
	["ENTER_MAC"] = KEY_ENTER_MAC,
	["ESCAPE"] = KEY_ESCAPE,
	["HOME"] = KEY_HOME,
	["INSERT"] = KEY_INSERT,
	["INSERT_MAC"] = KEY_INSERT_MAC,
	["LEFT"] = KEY_LEFT,
	["NUMLOCK"] = KEY_NUMLOCK,
	["NUMLOCK_MAC"] = KEY_NUMLOCK_MAC,
	["NUMPAD0"] = KEY_NUMPAD0,
	["NUMPAD1"] = KEY_NUMPAD1,
	["NUMPAD2"] = KEY_NUMPAD2,
	["NUMPAD3"] = KEY_NUMPAD3,
	["NUMPAD4"] = KEY_NUMPAD4,
	["NUMPAD5"] = KEY_NUMPAD5,
	["NUMPAD6"] = KEY_NUMPAD6,
	["NUMPAD7"] = KEY_NUMPAD7,
	["NUMPAD8"] = KEY_NUMPAD8,
	["NUMPAD9"] = KEY_NUMPAD9,
	["NUMPADDECIMAL"] = KEY_NUMPADDECIMAL,
	["NUMPADDIVIDE"] = KEY_NUMPADDIVIDE,
	["NUMPADMINUS"] = KEY_NUMPADMINUS,
	["NUMPADMULTIPLY"] = KEY_NUMPADMULTIPLY,
	["NUMPADPLUS"] = KEY_NUMPADPLUS,
	["PAGEDOWN"] = KEY_PAGEDOWN,
	["PAGEUP"] = KEY_PAGEUP,
	["PAUSE"] = KEY_PAUSE,
	["PAUSE_MAC"] = KEY_PAUSE_MAC,
	["PRINTSCREEN"] = KEY_PRINTSCREEN,
	["PRINTSCREEN_MAC"] = KEY_PRINTSCREEN_MAC,
	["RIGHT"] = KEY_RIGHT,
	["SCROLLLOCK"] = KEY_SCROLLLOCK,
	["SCROLLLOCK_MAC"] = KEY_SCROLLLOCK_MAC,
	["SPACE"] = KEY_SPACE,
	["TAB"] = KEY_TAB,
	["TILDE"] = KEY_TILDE,
	["'"] = L["Apostrophe"],
	["%+"] = L["Plus"],
	["´"] = L["Accent"],
	[","] = L["Comma"],
	["#"] = L["channel"],
}

---------------------------------------------------------------------------------------------------------------------------------------
SkuMenu.RegisteredPlugIns = {
	--[[
	["SkuAuras"] = {
		menuBuilder = function(aParentMenuItem)
			print("SkuAuras menuBuilder")
		end,
		getKeyBindsHandler = function()
			return
			{
				["SKU_AURAS_TEST_KEY"] = {
					key = "SHIFT-CTRL-A",
					desc = "Open SkuAuras Menu",
					handler = function()
						print("SKU_AURAS_TEST_KEY handler")
					end,
				}
			}
		end,
		setKeyBindsHandler = function(aUpdatedKeyBindsTable)
			print("SkuAuras setKeyBindsHandler", aUpdatedKeyBindsTable)

		end,
		profileChangedHandler = function(aChangedToProfileName)
			print("SkuAuras profileChangedHandler", aChangedToProfileName)
		end,
		profileCopiedHandler = function(aCopiedFromProfileName)
			print("SkuAuras profileCopiedHandler", aCopiedFromProfileName)
		end,
		profileResetHandler = function()
			print("SkuAuras profileResetHandler")
		end,
	},
	]]
}

---------------------------------------------------------------------------------------------------------------------------------------
function SkuMenu:RegisterPlugin(aPluginName, aPluginTable)
	print("RegisterPlugin", aPluginName, aPluginTable)
	if aPluginName and aPluginTable then
		SkuMenu.RegisteredPlugIns[aPluginName] = aPluginTable
	end
end

---------------------------------------------------------------------------------------------------------------------------------------
function SkuMenu:UnregisterPlugin(aPluginName)
	if aPluginName then
		SkuMenu.RegisteredPlugIns[aPluginName] = nil
	end
end

---------------------------------------------------------------------------------------------------------------------------------------
local options = {
name = "SkuMenu",
	handler = SkuMenu,
	type = "group",
	args = {},
	}

local defaults = {
	profile = {
		}
	}

---------------------------------------------------------------------------------------------------------------------------------------
function SkuMenu:CloseMenu()
	if SkuMenu:IsMenuOpen() == true then
		_G["OnSkuMenuMain"]:GetScript("OnClick")(_G["OnSkuMenuMain"], SkuMenu.db.profile["SkuMenu"].SkuKeyBinds["SKU_KEY_OPENMENU"].key)
		_G["SkuDebug"]:Hide()
	end
end

---------------------------------------------------------------------------------------------------------------------------------------
function SkuMenu:IsMenuOpen()
	if _G["OnSkuMenuMain"]:IsVisible() == true then
		return true
	end
	return false
end


---------------------------------------------------------------------------------------------------------------------------------------
function SkuMenu:GetMenuIndexAndBreadString(aMenuItem)
	local tTable = aMenuItem
	if tTable then
		local tBreadString = SkuMenu.currentMenuPosition.name
		local tIndexString = SkuMenu.currentMenuPosition.index
		while tTable.parent.name do
			tTable = tTable.parent
			tBreadString = tTable.name..","..tBreadString
			tIndexString = tTable.index..","..tIndexString
		end

		return tIndexString, tBreadString
	end
end

---------------------------------------------------------------------------------------------------------------------------------------
function SkuMenu:OpenMenuFromIndexString(aIndexString)
	local fields = {}
	for i in string.gmatch(aIndexString..",", "%d+,") do
		local tClean = string.gsub(i, ",", "")
		fields[#fields + 1] = tonumber(tClean)
	end

	if #SkuMenu.Menu == 0 or SkuMenu:IsMenuOpen() == false then
		_G["OnSkuMenuMain"]:GetScript("OnClick")(_G["OnSkuMenuMain"], SkuMenu.db.profile["SkuMenu"].SkuKeyBinds["SKU_KEY_OPENMENU"].key)
	end

	local tMenu = {}
	local tMenu = SkuMenu.Menu
	local tFoundMenuPos = nil
	local tNameString = ""
	for x = 1, #fields do
		if tMenu[fields[x]].children then
			if #tMenu[fields[x]].children == 0 then
				tMenu[fields[x]]:BuildChildren(tMenu[fields[x]])
			end
		end
		tFoundMenuPos = tMenu[fields[x]]
		tMenu[fields[x]].OnSelect(tMenu[fields[x]], true)
		tMenu = tMenu[fields[x]].children
		
		if tFoundMenuPos and tFoundMenuPos.name then
			tNameString = tNameString.." > "..tFoundMenuPos.name
		else
			return
		end
	end

	return true
end

---------------------------------------------------------------------------------------------------------------------------------------
function SkuMenu:GetMenuStringFromIndexString(aIndexString)
	local fields = {}
	for i in string.gmatch(aIndexString..",", "%d+,") do
		local tClean = string.gsub(i, ",", "")
		fields[#fields + 1] = tonumber(tClean)
	end

	if #SkuMenu.Menu == 0 or SkuMenu:IsMenuOpen() == false then
		_G["OnSkuMenuMain"]:GetScript("OnClick")(_G["OnSkuMenuMain"], SkuMenu.db.profile["SkuMenu"].SkuKeyBinds["SKU_KEY_OPENMENU"].key)
	end

	local tMenu = {}
	local tMenu = SkuMenu.Menu
	local tFoundMenuPos = nil
	local tNameString = ""
	for x = 1, #fields do
		if tMenu[fields[x]] then
			if tMenu[fields[x]].children then
				if #tMenu[fields[x]].children == 0 then
					tMenu[fields[x]]:BuildChildren(tMenu[fields[x]])
				end
			end
			tFoundMenuPos = tMenu[fields[x]]
			tMenu[fields[x]].OnSelect(tMenu[fields[x]], true)
			tMenu = tMenu[fields[x]].children
			if tFoundMenuPos and tFoundMenuPos.name then
				tNameString = tNameString.." > "..tFoundMenuPos.name
			else
				return
			end
		else
			return
		end
	end

	if tFoundMenuPos then
		return tNameString
	end
end

---------------------------------------------------------------------------------------------------------------------------------------
---@param input string
function SkuMenu:SlashFunc(input, aSilent)
	--print("++SkuMenu:SlashFunc(input)", input, aSilent)
	--SkuMenu.AceConfigDialog:Open("SkuMenu")

	if not input then
		return
	end

	input = input:gsub( ", ", ",")
	input = input:gsub( " ,", ",")

	input = slower(input)
	local sep, fields = ",", {}
	local pattern = string.format("([^%s]+)", sep)
	input:gsub(pattern, function(c) fields[#fields+1] = c end)

	if fields then
		if fields[1] == "version" then
			local name, title, notes, enabled, loadable, reason, security = GetAddOnInfo("SkuMenu")
			print(title)
		end


		
		if fields[1] == "netstats" then
			local bandwidthIn, bandwidthOut, latencyHome, latencyWorld = GetNetStats()
			print("bandwidthIn", bandwidthIn)
			print("bandwidthOut", bandwidthOut)
			print("latencyHome", latencyHome)
			print("latencyWorld", latencyWorld)
		end


		if fields[1] == "menuselect" then
			local tIndexString, tBreadString = SkuMenu:GetMenuIndexAndBreadString(SkuMenu.currentMenuPosition)
			SkuDispatcher:TriggerSkuEvent("SKU_SLASH_MENU_ITEM_SELECTED", tIndexString, tBreadString)
		end




		if fields[1] == L["short"] then
			
			if SkuMenu.inCombat == true then
				SkuMenu.openMenuAfterCombat = true
				SkuMenu.openMenuAfterPath = input
				return
			end
			if SkuMenu.isMoving == true then
				SkuMenu.openMenuAfterMoving = true
				SkuMenu.openMenuAfterPath = input
				return
			end
			
			if #SkuMenu.Menu == 0 or SkuMenu:IsMenuOpen() == false then
				_G["OnSkuMenuMain"]:GetScript("OnClick")(_G["OnSkuMenuMain"], SkuMenu.db.profile["SkuMenu"].SkuKeyBinds["SKU_KEY_OPENMENU"].key)
			end

			local tMenu = SkuMenu.Menu
			local tFoundMenuPos = nil

			for x = 2, #fields do
				for y = 1, #tMenu do
					if tMenu[y].children then
						if #tMenu[y].children == 0 then
							tMenu[y]:BuildChildren()
						end
					end

					if fields[x] == slower(tMenu[y].name) then
						tFoundMenuPos = tMenu[y]
						tMenu[y].OnSelect(tMenu[y], true)
						tMenu = tMenu[y].children
						break
					end
				end
			end

			if tFoundMenuPos then
				SkuMenu.currentMenuPosition = tFoundMenuPos
				if SkuMenu.currentMenuPosition.children then
					if #SkuMenu.currentMenuPosition.children > 0 then
						SkuMenu.currentMenuPosition:OnSelect()
						SkuMenu:VocalizeCurrentMenuName()--SkuMenu.currentMenuPosition:BuildChildren(SkuMenu.currentMenuPosition)
					else
						SkuMenu.currentMenuPosition:OnSelect()
						SkuMenu:CloseMenu()
					end
				else
					SkuMenu.currentMenuPosition:OnSelect()
					SkuMenu:CloseMenu()
				end
			end

		end
	end
end

---------------------------------------------------------------------------------------------------------------------------------------
function SkuMenu:OnProfileChanged()
	print("SkuMenu:OnProfileChanged")

	for i, v in pairs(SkuMenu.RegisteredPlugIns) do
		v:profileChangedHandler(aChangedToProfileName)
		--v.profileCopiedHandler(aCopiedFromProfileName)
		--v.profileResetHandler()
		--v:getKeyBindsHandler()
	end



	SkuMenu:SkuKeyBindsUpdate(true)
	

   

	if SkuMenu then
		SkuMenu:OnEnable()







	end

	SkuMenu:SkuKeyBindsUpdate()

	SkuMenu.Voice:OutputStringBTtts(L["Profil gewechselt"], false, true, 0.2, nil, nil, nil, 2)
end

---------------------------------------------------------------------------------------------------------------------------------------
function SkuMenu:OnProfileCopied()
	print("SkuMenu:OnProfileCopied")

	SkuMenu:SkuKeyBindsUpdate(true)






   if SkuMenu then
		SkuMenu:OnEnable()
	end

	SkuMenu:SkuKeyBindsUpdate()

	SkuMenu.Voice:OutputStringBTtts(L["Profil kopiert"], false, true, 0.2, nil, nil, nil, 2)
end

---------------------------------------------------------------------------------------------------------------------------------------
function SkuMenu:OnProfileReset()
	print("SkuMenu:OnProfileReset")

   SkuMenu:SkuKeyBindsResetBindings()
	SkuMenu:SkuKeyBindsUpdate(true)










   if SkuMenu then
		SkuMenu:OnEnable()
	end

	SkuMenu:SkuKeyBindsUpdate()

	SkuMenu.Voice:OutputStringBTtts(L["Profil zurückgesetzt"], false, true, 0.2, nil, nil, nil, 2)
end

---------------------------------------------------------------------------------------------------------------------------------------
function SkuMenu:CreateControlFrame()
	local ttime = 0
	local f = CreateFrame("Frame", "SkuMenuControl", UIParent)
	f:SetScript("OnUpdate", function(self, time)
		ttime = ttime + time
		if ttime > 0.1 then
			if SkuMenu.TTS:IsVisible() == true then
				if IsShiftKeyDown() == false and SkuMenu.TTS:IsAutoRead() ~= true then
					if SkuMenu.currentMenuPosition then
						if SkuMenu.currentMenuPosition.textFullInitial then
							SkuMenu.currentMenuPosition.textFull = SkuMenu.currentMenuPosition.textFullInitial
						end
						SkuMenu.currentMenuPosition.textFullInitial = nil
						SkuMenu.currentMenuPosition.links = {}
						SkuMenu.currentMenuPosition.linksSelected = 0
						SkuMenu.currentMenuPosition.currentLinkName = nil
						SkuMenu.currentMenuPosition.linksHistory = nil
					end
		
					SkuMenu.TTS:Output("", -1)
					--SkuMenu.TTS.MainFrame:Hide()
					SkuMenu.TTS:Hide()
				end
			end

			ttime = 0
		end

		--close debug panel
		if _G["SkuDebug"] then
			if _G["SkuDebug"]:IsVisible() == true then
				if (GetTime() - tStartDebugTimestamp) > 5 then
					_G["SkuDebug"]:Hide()
				end
			end
		end
	end)
end

---------------------------------------------------------------------------------------------------------------------------------------
local tCurrentOverviewPage
function SkuMenu:CreateMainFrame()
	local tFrame = CreateFrame("Button", "OnSkuMenuMain", UIParent, "UIPanelButtonTemplate")
	tFrame:SetSize(80, 22)
	tFrame:SetText("OnSkuMenuMain")
	tFrame:SetPoint("LEFT", UIParent, "RIGHT", 1500, 0)
	tFrame:SetPoint("CENTER")

	SkuMenu.TooltipReaderText = ""
	SkuMenu.InteractMove = false

	tFrame:SetScript("OnClick", function(self, a, b)


      --[[
		--monitor
		if a == SkuMenu.db.profile["SkuMenu"].SkuKeyBinds["SKU_KEY_ENABLEPARTYRAIDHEALTHMONITOR"].key then
			if UnitInRaid("player") then
				SkuMenu.db.char["SkuCore"].aq[SkuCore.talentSet].party.health2.enabled = false
				if SkuMenu.db.char["SkuCore"].aq[SkuCore.talentSet].raid.health2.enabled == true then
					SkuMenu.db.char["SkuCore"].aq[SkuCore.talentSet].raid.health2.enabled = false
					SkuMenu.db.char["SkuCore"].aq[SkuCore.talentSet].player.health.enabled = true
					print(L["Player health monitor enabled"])
				else
					SkuMenu.db.char["SkuCore"].aq[SkuCore.talentSet].raid.health2.enabled = true
					SkuMenu.db.char["SkuCore"].aq[SkuCore.talentSet].player.health.enabled = false
					print(L["Raid health monitor enabled"])
				end
			elseif UnitInParty("player") == true then
				SkuMenu.db.char["SkuCore"].aq[SkuCore.talentSet].raid.health2.enabled = false
				if SkuMenu.db.char["SkuCore"].aq[SkuCore.talentSet].party.health2.enabled == true then
					SkuMenu.db.char["SkuCore"].aq[SkuCore.talentSet].party.health2.enabled = false
					SkuMenu.db.char["SkuCore"].aq[SkuCore.talentSet].player.health.enabled = true
					print(L["Player health monitor enabled"])
				else
					SkuMenu.db.char["SkuCore"].aq[SkuCore.talentSet].party.health2.enabled = true
					SkuMenu.db.char["SkuCore"].aq[SkuCore.talentSet].player.health.enabled = false
					print(L["Party health monitor enabled"])
				end
			else
				SkuMenu.db.char["SkuCore"].aq[SkuCore.talentSet].raid.health2.enabled = false
				SkuMenu.db.char["SkuCore"].aq[SkuCore.talentSet].party.health2.enabled = false
				if SkuMenu.db.char["SkuCore"].aq[SkuCore.talentSet].player.health.enabled == true then
					SkuMenu.db.char["SkuCore"].aq[SkuCore.talentSet].player.health.enabled = false
					print(L["Player health monitor disabled"])
				else
					SkuMenu.db.char["SkuCore"].aq[SkuCore.talentSet].player.health.enabled = true
					print(L["Player health monitor enabled"])
				end
			end
		end
      

		--combat monitor
		if a == SkuMenu.db.profile["SkuMenu"].SkuKeyBinds["SKU_KEY_COMBATMONSETFOLLOWTARGET"].key then
			if SkuMenu.db.char["SkuCore"].aq[SkuCore.talentSet].combat.enabled == true then
				if UnitName("target") and UnitIsPlayer("target") then
					SkuMenu.db.char["SkuCore"].aq[SkuCore.talentSet].combat.friendly.oorUnitName = UnitName("target")
					SkuMenu.Voice:OutputStringBTtts(L["New follow unit"].." "..UnitName("target"), {overwrite = true, wait = true, doNotOverwrite = true, engine = 2})
				end
			end
		end

		if a == SkuMenu.db.profile["SkuMenu"].SkuKeyBinds["SKU_KEY_COMBATMONOUTPUTNUMBERINCOMBAT"].key then
			if SkuMenu.db.char["SkuCore"].aq[SkuCore.talentSet].combat.enabled == true then
				SkuMenu.Voice:OutputString(SkuCore.inOutCombatQueue.current.." "..L["In Combat"], true, true, 0.3, true)
			end
		end

      ]]


		if a == SkuMenu.db.profile["SkuMenu"].SkuKeyBinds["SKU_KEY_STOPTTSOUTPUT"].key then
			SkuMenu.Voice:StopOutputEmptyQueue(true, true)
		end

      
		if SkuMenu:IsPlayerMoving() == true then
			SkuMenu.openMenuAfterMoving = true
			return
		end
      


		if a == "SHIFT-UP" then 
			SkuMenu.TooltipReaderText = SkuMenu:UpdateOverviewText(tCurrentOverviewPage)
			if SkuMenu.TooltipReaderText then
				if SkuMenu.TooltipReaderText ~= "" then
					if not SkuMenu.TTS:IsVisible() then
						SkuMenu.TTS:Output(SkuMenu.TooltipReaderText, 1000)
					end
					SkuMenu.TTS:PreviousLine(2, true)
				end
			end
			return
		end

		if a ~= "SHIFT-RIGHT" and a ~= "SHIFT-LEFT" and a ~= "SHIFT-ENTER" and a ~= "SHIFT-BACKSPACE" and a ~= "SHIFT-UP" and a ~= "SHIFT-DOWN" and a ~= "SHIFT-PAGEDOWN" and a ~= "CTRL-SHIFT-UP" and a ~= "CTRL-SHIFT-DOWN" then
			if SkuMenu.TTS:IsAutoRead() == true then
				SkuMenu.TTS:ToggleAutoRead()
				SkuMenu.Voice:StopOutputEmptyQueue(true, nil)
			end
			if SkuMenu.TTS:IsVisible() then
				--SkuMenu.TTS:Output("", -1)
				SkuMenu.TTS:Hide()
			end
		end
		if a == "SHIFT-UP" then
			SkuMenu.currentMenuPosition = SkuMenu.currentMenuPosition or {}
			SkuMenu.currentMenuPosition.textFull = SkuMenu:UpdateOverviewText(tCurrentOverviewPage)
			if SkuMenu.currentMenuPosition.textFull ~= "" then
				if not SkuMenu.TTS:IsVisible() then
					SkuMenu.TTS:Output(SkuMenu.currentMenuPosition.textFull, 1000)
				end
				SkuMenu.currentMenuPosition.links = {}
				SkuMenu.currentMenuPosition.linksSelected = 0
				if SkuMenu.TTS:IsAutoRead() == true then
					SkuMenu.TTS:ToggleAutoRead()
					SkuMenu.TTS.AutoReadEventFlag = nil
				end					
				SkuMenu.TTS:PreviousLine(SkuMenu.currentMenuPosition.ttsEngine)
			end
		end
		if a == "SHIFT-DOWN" then
			SkuMenu.currentMenuPosition = SkuMenu.currentMenuPosition or {}
			SkuMenu.currentMenuPosition.textFull = SkuMenu:UpdateOverviewText(tCurrentOverviewPage)
			if SkuMenu.currentMenuPosition.textFull ~= "" then
				if not SkuMenu.TTS:IsVisible() then
					SkuMenu.TTS:Output(SkuMenu.currentMenuPosition.textFull, 1000)
				end
				SkuMenu.currentMenuPosition.links = {}
				SkuMenu.currentMenuPosition.linksSelected = 0
				if SkuMenu.TTS:IsAutoRead() == true then
					SkuMenu.TTS:ToggleAutoRead()
					SkuMenu.TTS.AutoReadEventFlag = nil
				end					
				SkuMenu.TTS:NextLine(SkuMenu.currentMenuPosition.ttsEngine)
			end
		end
		if a == "CTRL-SHIFT-UP" then
			SkuMenu.currentMenuPosition = SkuMenu.currentMenuPosition or {}
			SkuMenu.currentMenuPosition.textFull = SkuMenu:UpdateOverviewText(tCurrentOverviewPage)
			if SkuMenu.currentMenuPosition.textFull ~= "" then
				local tTextFull = SkuMenu:AddExtraTooltipData(SkuMenu.currentMenuPosition.textFull, SkuMenu.currentMenuPosition.itemId)
				if not SkuMenu.TTS:IsVisible() then
					SkuMenu.TTS:Output(tTextFull, 1000)
				end
				SkuMenu.currentMenuPosition.links = {}
				SkuMenu.currentMenuPosition.linksSelected = 0
				if SkuMenu.TTS:IsAutoRead() == true then
					SkuMenu.TTS:ToggleAutoRead()
					SkuMenu.TTS.AutoReadEventFlag = nil
				end					
				SkuMenu.TTS:PreviousSection(SkuMenu.currentMenuPosition.ttsEngine)
			end
		end
		if a == "CTRL-SHIFT-DOWN" then
			SkuMenu.currentMenuPosition = SkuMenu.currentMenuPosition or {}
			SkuMenu.currentMenuPosition.textFull = SkuMenu:UpdateOverviewText(tCurrentOverviewPage)
			if SkuMenu.currentMenuPosition.textFull ~= "" then
				local tTextFull = SkuMenu:AddExtraTooltipData(SkuMenu.currentMenuPosition.textFull, SkuMenu.currentMenuPosition.itemId)
				if not SkuMenu.TTS:IsVisible() then
					SkuMenu.TTS:Output(tTextFull, 1000)
				end
				SkuMenu.currentMenuPosition.links = {}
				SkuMenu.currentMenuPosition.linksSelected = 0
				if SkuMenu.TTS:IsAutoRead() == true then
					SkuMenu.TTS:ToggleAutoRead()
					SkuMenu.TTS.AutoReadEventFlag = nil
				end					
				SkuMenu.TTS:NextSection(SkuMenu.currentMenuPosition.ttsEngine)
			end
		end
		if a == "SHIFT-PAGEDOWN" then
			SkuMenu.currentMenuPosition = SkuMenu.currentMenuPosition or {}
			SkuMenu.currentMenuPosition.textFull = SkuMenu:UpdateOverviewText(tCurrentOverviewPage)
			if SkuMenu.currentMenuPosition.textFull ~= "" then
				local tTextFull = SkuMenu:AddExtraTooltipData(SkuMenu.currentMenuPosition.textFull, SkuMenu.currentMenuPosition.itemId)
				if not SkuMenu.TTS:IsVisible() then
					SkuMenu.TTS:Output(tTextFull, 1000)
				end
				SkuMenu.currentMenuPosition.links = {}
				SkuMenu.currentMenuPosition.linksSelected = 0

				SkuMenu.TTS:ToggleAutoRead(SkuMenu.currentMenuPosition.ttsEngine)
				
			end
		end
		if a == "SHIFT-RIGHT" then
			SkuMenu.currentMenuPosition = SkuMenu.currentMenuPosition or {}
			SkuMenu.currentMenuPosition.textFull = SkuMenu:UpdateOverviewText(tCurrentOverviewPage)
			if SkuMenu.currentMenuPosition.textFull ~= "" then
				if SkuMenu.currentMenuPosition.links then
					if #SkuMenu.currentMenuPosition.links > 0 then
						SkuMenu.currentMenuPosition.linksSelected = SkuMenu.currentMenuPosition.linksSelected + 1
						if SkuMenu.currentMenuPosition.linksSelected > #SkuMenu.currentMenuPosition.links then
							SkuMenu.currentMenuPosition.linksSelected = #SkuMenu.currentMenuPosition.links
						end
						if SkuMenu.TTS:IsAutoRead() == true then
							SkuMenu.TTS:ToggleAutoRead()
							SkuMenu.TTS.AutoReadEventFlag = nil

						end					
						SkuMenu.TTS:NextLink(SkuMenu.currentMenuPosition.ttsEngine)
					end
				end
			end
		end
		if a == "SHIFT-LEFT" then
			SkuMenu.currentMenuPosition = SkuMenu.currentMenuPosition or {}
			SkuMenu.currentMenuPosition.textFull = SkuMenu:UpdateOverviewText(tCurrentOverviewPage)
			if SkuMenu.currentMenuPosition.textFull ~= "" then
				if SkuMenu.currentMenuPosition.links then
					if #SkuMenu.currentMenuPosition.links > 0 then
						SkuMenu.currentMenuPosition.linksSelected = SkuMenu.currentMenuPosition.linksSelected - 1
						if SkuMenu.currentMenuPosition.linksSelected < 1 then
							SkuMenu.currentMenuPosition.linksSelected = 1
						end
						if SkuMenu.TTS:IsAutoRead() == true then
							SkuMenu.TTS:ToggleAutoRead()
							SkuMenu.TTS.AutoReadEventFlag = nil

						end					
						SkuMenu.TTS:PreviousLink(SkuMenu.currentMenuPosition.ttsEngine)
					end
				end
			end
		end
		if a == "SHIFT-ENTER" then
			SkuMenu.currentMenuPosition = SkuMenu.currentMenuPosition or {}
			SkuMenu.currentMenuPosition.textFull = SkuMenu:UpdateOverviewText(tCurrentOverviewPage)
			if SkuMenu.currentMenuPosition.textFull ~= "" then
				if not SkuMenu.currentMenuPosition.textFullInitial then
					SkuMenu.currentMenuPosition.textFullInitial = SkuMenu.currentMenuPosition.textFull
				end
				if SkuMenu.currentMenuPosition.links then
					if #SkuMenu.currentMenuPosition.links > 0 then
						if SkuMenu.currentMenuPosition.linksSelected > 0 then
							if SkuMenu.TTS:IsAutoRead() == true then
								SkuMenu.TTS:ToggleAutoRead()
								SkuMenu.TTS.AutoReadEventFlag = nil

							end					
							SkuMenu:LoadLinkDataToTooltip(slower(SkuMenu.currentMenuPosition.links[SkuMenu.currentMenuPosition.linksSelected]))
						end
					end
				end
			end
		end
		if a == "SHIFT-BACKSPACE" then
			local tHasHistory = false
			SkuMenu.currentMenuPosition = SkuMenu.currentMenuPosition or {}
			SkuMenu.currentMenuPosition.textFull = SkuMenu:UpdateOverviewText(tCurrentOverviewPage)
			if SkuMenu.currentMenuPosition.linksHistory then
				if #SkuMenu.currentMenuPosition.linksHistory > 1 then
					table.remove(SkuMenu.currentMenuPosition.linksHistory, 1)
					if SkuMenu.currentMenuPosition.linksHistory[1] then
						tHasHistory = true
						SkuMenu:LoadLinkDataToTooltip(slower(SkuMenu.currentMenuPosition.linksHistory[1]), true)
					end
				end
			end
			if tHasHistory == false then
				if SkuMenu.currentMenuPosition.textFullInitial then
					SkuMenu.currentMenuPosition.textFull = SkuMenu.currentMenuPosition.textFullInitial
				end
				SkuMenu.currentMenuPosition.links = {}
				SkuMenu.currentMenuPosition.linksSelected = 0
				SkuMenu.currentMenuPosition.currentLinkName = nil
				SkuMenu.currentMenuPosition.linksHistory = nil
			end
			if SkuMenu.currentMenuPosition.textFull then
				if SkuMenu.currentMenuPosition.textFull ~= "" then
					if not SkuMenu.TTS:IsVisible() then
						SkuMenu.TTS:Output(SkuMenu:AddExtraTooltipData(SkuMenu.currentMenuPosition.textFull, SkuMenu.currentMenuPosition.itemId), 1000)
					end
					SkuMenu.TTS:Output(SkuMenu.currentMenuPosition.textFull, 1000)

					SkuMenu.currentMenuPosition.links = {}
					SkuMenu.currentMenuPosition.linksSelected = 0
					SkuMenu.TTS:PreviousLine(SkuMenu.currentMenuPosition.ttsEngine)
				end
			end			
			if SkuMenu.TTS:IsAutoRead() == true then
				SkuMenu.TTS:ToggleAutoRead()
				SkuMenu.TTS.AutoReadEventFlag = nil

			end					
		end

		if SkuMenu.inCombat == true then
			--SkuMenu.openMenuAfterCombat = true
			return
		end
		if SkuMenu.isMoving == true then
			--dprint("SkuMenu.isMoving", SkuMenu.isMoving)
			SkuMenu.openMenuAfterMoving = true
			return
		end
		SkuMenu.openMenuAfterCombat = false
		SkuMenu.openMenuAfterMoving = false

		if a == SkuMenu.db.profile["SkuMenu"].SkuKeyBinds["SKU_KEY_OPENMENU"].key or a == nil then
			if #SkuMenu.Menu == 0 then

				for i, v in pairs(SkuMenu.RegisteredPlugIns) do
					local tNewMenuEntry = SkuMenu:InjectMenuItems(SkuMenu.Menu, {i}, SkuGenericMenuItem)
					tNewMenuEntry.dynamic = true
					tNewMenuEntry.BuildChildren = v.menuBuilder
				end

				local tNewMenuEntry = SkuMenu:InjectMenuItems(SkuMenu.Menu, {L["Menu Options"]}, SkuGenericMenuItem)
				tNewMenuEntry.dynamic = true
				tNewMenuEntry.BuildChildren = function(self)
					SkuMenu:MenuBuilder(tNewMenuEntry)
				end
			end

			--set menu to entry first
			SkuMenu.currentMenuPosition = SkuMenu.Menu[1]
			SkuMenu.currentMenuPosition:OnFirst()

			if self:IsVisible() then
				self:Hide()

				SkuMenu.Voice:OutputStringBTtts(L["Menu;closed"], false, true, 0.3, true, nil, nil, 2)
				SkuMenu.Debug("", L["Menu;closed"], true)

			else
				self:Show()
				SkuMenu.currentMenuPosition = SkuMenu.Menu[1]
				PlaySound(811)
				SkuMenu.Voice:OutputStringBTtts(L["Menu;open"], true, true, 0.3, true, nil, nil, 2)
				SkuMenu.Voice:OutputStringBTtts(SkuMenu.Menu[1].name, false, true, 0.3, nil, nil, nil, 2)
				SkuMenu.Debug("", SkuMenu.currentMenuPosition.name, true)
			end
		end

	end)
	tFrame:Hide()
	tFrame:SetScript("OnHide", function(self, a, b)
		--dprint("OnSkuMenuMain OnHide")
		--ClearOverrideBindings(self)
		
	end)

	local tKbds = SkuMenu.db.profile["SkuMenu"].SkuKeyBinds
	SetOverrideBindingClick(tFrame, true, tKbds["SKU_KEY_ENABLEPARTYRAIDHEALTHMONITOR"].key, tFrame:GetName(), tKbds["SKU_KEY_ENABLEPARTYRAIDHEALTHMONITOR"].key)
	SetOverrideBindingClick(tFrame, true, tKbds["SKU_KEY_COMBATMONSETFOLLOWTARGET"].key, tFrame:GetName(), tKbds["SKU_KEY_COMBATMONSETFOLLOWTARGET"].key)
	SetOverrideBindingClick(tFrame, true, tKbds["SKU_KEY_COMBATMONOUTPUTNUMBERINCOMBAT"].key, tFrame:GetName(), tKbds["SKU_KEY_COMBATMONOUTPUTNUMBERINCOMBAT"].key)
	
	SetOverrideBindingClick(tFrame, true, "SHIFT-UP", tFrame:GetName(), "SHIFT-UP")
	SetOverrideBindingClick(tFrame, true, "SHIFT-DOWN", tFrame:GetName(), "SHIFT-DOWN")
	SetOverrideBindingClick(tFrame, true, "CTRL-SHIFT-UP", tFrame:GetName(), "CTRL-SHIFT-UP")
	SetOverrideBindingClick(tFrame, true, "CTRL-SHIFT-DOWN", tFrame:GetName(), "CTRL-SHIFT-DOWN")
	SetOverrideBindingClick(tFrame, true, "SHIFT-PAGEDOWN", "OnSkuMenuMainOption1", "SHIFT-PAGEDOWN")
	SetOverrideBindingClick(tFrame, true, "SHIFT-RIGHT", "OnSkuMenuMainOption1", "SHIFT-RIGHT")
	SetOverrideBindingClick(tFrame, true, "SHIFT-LEFT", "OnSkuMenuMainOption1", "SHIFT-LEFT")
	SetOverrideBindingClick(tFrame, true, "SHIFT-ENTER", "OnSkuMenuMainOption1", "SHIFT-ENTER")
	SetOverrideBindingClick(tFrame, true, "SHIFT-BACKSPACE", "OnSkuMenuMainOption1", "SHIFT-BACKSPACE")

	SetOverrideBindingClick(tFrame, true, tKbds["SKU_KEY_OPENMENU"].key, tFrame:GetName(), tKbds["SKU_KEY_OPENMENU"].key)

	SetOverrideBindingClick(tFrame, true, tKbds["SKU_KEY_STOPTTSOUTPUT"].key, tFrame:GetName(), tKbds["SKU_KEY_STOPTTSOUTPUT"].key)

end

---------------------------------------------------------------------------------------------------------------------------------------
function SkuMenu:AddExtraTooltipData(aUnmodifiedTextFull, aItemId)
	--print("AddExtraTooltipData", aUnmodifiedTextFull, aItemId)
	if not aUnmodifiedTextFull then
		return ""
	end

	if type(aUnmodifiedTextFull) == "string" then
		return aUnmodifiedTextFull
	end

	if type(aUnmodifiedTextFull) == "function" then
		aUnmodifiedTextFull = aUnmodifiedTextFull()
	end

	local tDNA
	local tRatingIndex = #aUnmodifiedTextFull
	for i, v in pairs(aUnmodifiedTextFull) do
		if string.find(v, L["Wertung:"]) then
			tDNA = true
			tRatingIndex = i
		end
	end

	local tNewTextFull = aUnmodifiedTextFull

	if not tDNA then
		local tFirstLine = aUnmodifiedTextFull[1] or aUnmodifiedTextFull
		if type(tFirstLine) == "table" then
			tFirstLine = ""
		end

		local tFirstWord
		if string.find(tFirstLine, " ") then
			tFirstWord = string.sub(tFirstLine, 1, string.find(tFirstLine, " ") - 1)
			if string.len(tFirstWord) < 5 then
				tFirstWord = nil
			end
		end
		
		if string.find(tFirstLine, "\r") then
			local tItemName = string.sub(tFirstLine, 1, string.find(tFirstLine, "\r") - 1)

			local tItemId
			local tItemIdWord

			for i, v in pairs(SkuDB.itemLookup) do
				if tItemName == v[SkuMenu.Loc] then
					tItemId = i
					break
				end
				if tFirstWord then
					if tFirstWord == v[SkuMenu.Loc] then
						tItemIdWord = i
					end
				end
			end

		end
	end

	return tNewTextFull
end

---------------------------------------------------------------------------------------------------------------------------------------
function SkuMenu:CreateMenuFrame()
	local OnSkuMenuMainOption1LastInputTime = GetTime()
	local OnSkuMenuMainOption1LastInputTimeout = 0.5

	tFrame = _G["OnSkuMenuMainOption1"] or CreateFrame("Button", "OnSkuMenuMainOption1", _G["OnSkuMenuMain"], "UIPanelButtonTemplate")
	tFrame:SetSize(80, 22)
	tFrame:SetText("OnSkuMenuMainOption1")
	tFrame:SetPoint("TOP", _G["OnSkuMenuMain"], "BOTTOM", 0, 0)

	local OnSkuMenuMainOnKeyPressTimer = GetTimePreciseSec()

	tFrame:SetScript("OnChar", function(self, aKey, aB)
		--dprint("OnSkuMenuMainOption1 OnChar", aKey)
		OnSkuMenuMainOption1:GetScript("OnClick")(self, aKey)
	end)
	tFrame:SetScript("OnClick", function(self, aKey, aB)

      if aKey == "CTRL-RIGHT" then
			if SkuMenu.currentMenuPosition then
				if SkuMenu.currentMenuPosition.name ~= "" then
					SkuMenu.Voice:OutputStringBTtts(SkuMenu.currentMenuPosition.name, false, true, 0, false, nil, nil, 2, true) -- for strings with lookup in string index
				end
			end
			return
		end

		local tIsDoubleDown = false
		local tSecondTime = GetTimePreciseSec() - OnSkuMenuMainOnKeyPressTimer
		if tSecondTime < 0.25 then
			tIsDoubleDown = true
		end
		OnSkuMenuMainOnKeyPressTimer = GetTimePreciseSec()

		if SkuMenu.MenuAccessKeysChars[aKey] then
			aKey = slower(aKey)
		end

		if aKey == "SPACE" then
			aKey = " "
		end

		if SkuMenu.inCombat == true then
			SkuMenu.openMenuAfterCombat = true
			return
		end
		if SkuMenu.isMoving == true then
			SkuMenu.openMenuAfterMoving = true
			return
		end
		SkuMenu.openMenuAfterCombat = false
		SkuMenu.openMenuAfterMoving = false

		if SkuMenu.currentMenuPosition then
			if SkuMenu.currentMenuPosition.parent then
				if SkuMenu.currentMenuPosition.parent.filterable == true then
					if  SkuMenu.MenuAccessKeysChars[aKey] or SkuMenu.MenuAccessKeysNumbers[aKey] then
						if aKey == "shift-," then aKey = ";" end
						if SkuMenu.Filterstring == "" then
							--SkuMenu:Debug("empty = rep")
							SkuMenu.Filterstring = aKey
						elseif string.len(SkuMenu.Filterstring) == 1 and ((GetTime() - OnSkuMenuMainOption1LastInputTime) < OnSkuMenuMainOption1LastInputTimeout) then
							--SkuMenu:Debug("1 and in time = add")
							SkuMenu.Filterstring = SkuMenu.Filterstring..aKey
							aKey = ""
						elseif  string.len(SkuMenu.Filterstring) > 1  then
							--SkuMenu:Debug("> 1 = add")
							SkuMenu.Filterstring = SkuMenu.Filterstring..aKey
							aKey = ""
						else
							--SkuMenu:Debug("1 and out of time = rep")
							SkuMenu.Filterstring = aKey
						end
						OnSkuMenuMainOption1LastInputTime = GetTime()

						if string.len(SkuMenu.Filterstring) > 1  then
							SkuMenu:ApplyFilter(SkuMenu.Filterstring)
							--SkuMenu:Debug("filter by: ", SkuMenu.Filterstring)
							aKey = ""
						end
					end
					if  string.len(SkuMenu.Filterstring) > 1  then
						if aKey == "BACKSPACE" then
							SkuMenu.Filterstring = ""
							SkuMenu:ApplyFilter(SkuMenu.Filterstring)
							aKey = ""
						end
						if aKey == "LEFT" then
							SkuMenu.Filterstring = ""
							SkuMenu:ApplyFilter(SkuMenu.Filterstring)
						end
					end
				end
			end
		end
		local tVocalizeReset = true

		if aKey == "UP" then
			if tIsDoubleDown ~= true then
				SkuMenu.currentMenuPosition:OnPrev()
			else
				local tOut = false
				local tOldMenuName = ""
				while tOut == false do
					SkuMenu.currentMenuPosition:OnPrev()
					if not string.find(SkuMenu.currentMenuPosition.name, L["Empty"]) then
						tOut = true
					end
					if SkuMenu.currentMenuPosition.name == tOldMenuName then
						tOut = true
					end
					tOldMenuName = SkuMenu.currentMenuPosition.name
				end
			end
		end
		if aKey == "DOWN" then
			if tIsDoubleDown ~= true then
				SkuMenu.currentMenuPosition:OnNext()
			else
				local tOut = false
				local tOldMenuName = ""
				while tOut == false do
					SkuMenu.currentMenuPosition:OnNext()
					if not string.find(SkuMenu.currentMenuPosition.name, L["Empty"]) then
						tOut = true
					end
					if SkuMenu.currentMenuPosition.name == tOldMenuName then
						tOut = true
					end
					tOldMenuName = SkuMenu.currentMenuPosition.name
				end
			end
		end
		if aKey == "RIGHT" then
			if #SkuMenu.currentMenuPosition.children > 0 or SkuMenu.currentMenuPosition.dynamic == true then
				SkuMenu.currentMenuPosition:OnSelect()
				SkuMenu:ClearFilter()
			end
		end
		if aKey == "LEFT" then
			if SkuMenu.currentMenuPosition then
				SkuMenu.currentMenuPosition:OnBack()
			end
			SkuMenu:ClearFilter()
		end
		if aKey == "HOME" then
			SkuMenu.currentMenuPosition:OnFirst()
		end
		if aKey == "END" then
			SkuMenu.currentMenuPosition:OnLast()
		end		
		if aKey == "ENTER" or aKey == "SHIFT-ENTER" then
			tVocalizeReset = false
			if SkuMenu.currentMenuPosition then
				SkuMenu.currentMenuPosition:OnSelect(true)
				SkuMenu:ClearFilter()
			end
		end
		if aKey == "BACKSPACE" then
			SkuMenu.currentMenuPosition:OnBack()
			SkuMenu:ClearFilter()
		end
		if aKey == "ESCAPE" then
			SkuMenu:CloseMenu()
			SkuMenu:ClearFilter()
		end
		if SkuMenu.MenuAccessKeysChars[aKey] or (SkuMenu.MenuAccessKeysNumbers[aKey]) then
			SkuMenu.currentMenuPosition:OnKey(aKey)
		end
		PlaySound(811)

		if aKey ~= "SHIFT-RIGHT" and aKey ~= "SHIFT-LEFT" and aKey ~= "SHIFT-ENTER" and aKey ~= "SHIFT-BACKSPACE" and aKey ~= "SHIFT-UP" and aKey ~= "SHIFT-DOWN" and aKey ~= "SHIFT-PAGEDOWN" and aKey ~= "CTRL-SHIFT-UP" and aKey ~= "CTRL-SHIFT-DOWN" then
			if SkuMenu.TTS:IsAutoRead() == true then
				SkuMenu.TTS:ToggleAutoRead()
				SkuMenu.Voice:StopOutputEmptyQueue(true, nil)
			end
			if SkuMenu.TTS:IsVisible() then
				--SkuMenu.TTS:Output("", -1)
				SkuMenu.TTS:Hide()
			end
		end

		if aKey ~= "ESCAPE" and _G["OnSkuMenuMainOption1"]:IsVisible() and aKey ~= "SHIFT-DOWN" and SkuMenu.TTS.MainFrame:IsVisible() ~= true then
			SkuMenu:VocalizeCurrentMenuName(tVocalizeReset)
			if string.len(SkuMenu.Filterstring) > 1  then
				--SkuMenu.Voice:OutputStringBTtts("Filter", false, true, 0.3, nil, nil, nil, 2)
			end
		end

		if SkuMenu.currentMenuPosition then
			if aKey == "SHIFT-UP" then 
				if SkuMenu.currentMenuPosition.textFull then
					if SkuMenu.currentMenuPosition.textFull ~= "" then
						local tTextFull = SkuMenu:AddExtraTooltipData(SkuMenu.currentMenuPosition.textFull, SkuMenu.currentMenuPosition.itemId)
						if not SkuMenu.TTS:IsVisible() then
							SkuMenu.TTS:Output(tTextFull, 1000)
						end
						SkuMenu.currentMenuPosition.links = {}
						SkuMenu.currentMenuPosition.linksSelected = 0
						if SkuMenu.TTS:IsAutoRead() == true then
							SkuMenu.TTS:ToggleAutoRead()
							SkuMenu.TTS.AutoReadEventFlag = nil
						end					
						SkuMenu.TTS:PreviousLine(SkuMenu.currentMenuPosition.ttsEngine)
					end
				end
			end
			if aKey == "SHIFT-DOWN" then
				if SkuMenu.currentMenuPosition.textFull then
					if SkuMenu.currentMenuPosition.textFull ~= "" then
						local tTextFull = SkuMenu:AddExtraTooltipData(SkuMenu.currentMenuPosition.textFull, SkuMenu.currentMenuPosition.itemId)
						if not SkuMenu.TTS:IsVisible() then
							SkuMenu.TTS:Output(tTextFull, 1000)
						end
						SkuMenu.currentMenuPosition.links = {}
						SkuMenu.currentMenuPosition.linksSelected = 0
						if SkuMenu.TTS:IsAutoRead() == true then
							SkuMenu.TTS:ToggleAutoRead()
							SkuMenu.TTS.AutoReadEventFlag = nil
						end					
						SkuMenu.TTS:NextLine(SkuMenu.currentMenuPosition.ttsEngine)
					end
				end
			end
			if aKey == "SHIFT-PAGEDOWN" then
				if SkuMenu.currentMenuPosition.textFull then
					if SkuMenu.currentMenuPosition.textFull ~= "" then
						local tTextFull = SkuMenu:AddExtraTooltipData(SkuMenu.currentMenuPosition.textFull, SkuMenu.currentMenuPosition.itemId)
						if not SkuMenu.TTS:IsVisible() then
							SkuMenu.TTS:Output(tTextFull, 1000)
						end
						SkuMenu.currentMenuPosition.links = {}
						SkuMenu.currentMenuPosition.linksSelected = 0

						SkuMenu.TTS:ToggleAutoRead(SkuMenu.currentMenuPosition.ttsEngine)
						
					end
				end
			end
			if aKey == "CTRL-SHIFT-UP" then
				if SkuMenu.currentMenuPosition.textFull then
					if SkuMenu.currentMenuPosition.textFull ~= "" then
						local tTextFull = SkuMenu:AddExtraTooltipData(SkuMenu.currentMenuPosition.textFull, SkuMenu.currentMenuPosition.itemId)
						if not SkuMenu.TTS:IsVisible() then
							SkuMenu.TTS:Output(tTextFull, 1000)
						end
						SkuMenu.currentMenuPosition.links = {}
						SkuMenu.currentMenuPosition.linksSelected = 0
						if SkuMenu.TTS:IsAutoRead() == true then
							SkuMenu.TTS:ToggleAutoRead()
							SkuMenu.TTS.AutoReadEventFlag = nil
						end					
						SkuMenu.TTS:PreviousSection(SkuMenu.currentMenuPosition.ttsEngine)
					end
				end
			end
			if aKey == "CTRL-SHIFT-DOWN" then
				if SkuMenu.currentMenuPosition.textFull then
					if SkuMenu.currentMenuPosition.textFull ~= "" then
						local tTextFull = SkuMenu:AddExtraTooltipData(SkuMenu.currentMenuPosition.textFull, SkuMenu.currentMenuPosition.itemId)
						if not SkuMenu.TTS:IsVisible() then
							SkuMenu.TTS:Output(tTextFull, 1000)
						end
						SkuMenu.currentMenuPosition.links = {}
						SkuMenu.currentMenuPosition.linksSelected = 0
						if SkuMenu.TTS:IsAutoRead() == true then
							SkuMenu.TTS:ToggleAutoRead()
							SkuMenu.TTS.AutoReadEventFlag = nil
						end					
						SkuMenu.TTS:NextSection(SkuMenu.currentMenuPosition.ttsEngine)
					end
				end
			end
			if aKey == "SHIFT-RIGHT" then
				if SkuMenu.currentMenuPosition.textFull then
					if SkuMenu.currentMenuPosition.textFull ~= "" then
						if SkuMenu.currentMenuPosition.links then
							if #SkuMenu.currentMenuPosition.links > 0 then
								SkuMenu.currentMenuPosition.linksSelected = SkuMenu.currentMenuPosition.linksSelected + 1
								if SkuMenu.currentMenuPosition.linksSelected > #SkuMenu.currentMenuPosition.links then
									SkuMenu.currentMenuPosition.linksSelected = #SkuMenu.currentMenuPosition.links
								end
								if SkuMenu.TTS:IsAutoRead() == true then
									SkuMenu.TTS:ToggleAutoRead()
									SkuMenu.TTS.AutoReadEventFlag = nil

								end					
								SkuMenu.TTS:NextLink(SkuMenu.currentMenuPosition.ttsEngine)
							end
						end
					end
				end
			end
			if aKey == "SHIFT-LEFT" then
				if SkuMenu.currentMenuPosition.textFull then
					if SkuMenu.currentMenuPosition.textFull ~= "" then
						if SkuMenu.currentMenuPosition.links then
							if #SkuMenu.currentMenuPosition.links > 0 then
								SkuMenu.currentMenuPosition.linksSelected = SkuMenu.currentMenuPosition.linksSelected - 1
								if SkuMenu.currentMenuPosition.linksSelected < 1 then
									SkuMenu.currentMenuPosition.linksSelected = 1
								end
								if SkuMenu.TTS:IsAutoRead() == true then
									SkuMenu.TTS:ToggleAutoRead()
									SkuMenu.TTS.AutoReadEventFlag = nil

								end					
								SkuMenu.TTS:PreviousLink(SkuMenu.currentMenuPosition.ttsEngine)
							end
						end
					end
				end
			end
			if aKey == "SHIFT-ENTER" then
				if SkuMenu.currentMenuPosition.textFull then
					if SkuMenu.currentMenuPosition.textFull ~= "" then
						if not SkuMenu.currentMenuPosition.textFullInitial then
							SkuMenu.currentMenuPosition.textFullInitial = SkuMenu.currentMenuPosition.textFull
						end
						if SkuMenu.currentMenuPosition.links then
							if #SkuMenu.currentMenuPosition.links > 0 then
								if SkuMenu.currentMenuPosition.linksSelected > 0 then
									if SkuMenu.TTS:IsAutoRead() == true then
										SkuMenu.TTS:ToggleAutoRead()
										SkuMenu.TTS.AutoReadEventFlag = nil

									end					
									SkuMenu:LoadLinkDataToTooltip(slower(SkuMenu.currentMenuPosition.links[SkuMenu.currentMenuPosition.linksSelected]))
								end
							end
						end
					end
				end
			end
			if aKey == "SHIFT-BACKSPACE" then
				local tHasHistory = false
				if SkuMenu.currentMenuPosition.linksHistory then
					if #SkuMenu.currentMenuPosition.linksHistory > 1 then
						table.remove(SkuMenu.currentMenuPosition.linksHistory, 1)
						if SkuMenu.currentMenuPosition.linksHistory[1] then
							tHasHistory = true
							SkuMenu:LoadLinkDataToTooltip(slower(SkuMenu.currentMenuPosition.linksHistory[1]), true)
						end
					end
				end
				if tHasHistory == false then
					if SkuMenu.currentMenuPosition.textFullInitial then
						SkuMenu.currentMenuPosition.textFull = SkuMenu.currentMenuPosition.textFullInitial
					end
					SkuMenu.currentMenuPosition.links = {}
					SkuMenu.currentMenuPosition.linksSelected = 0
					SkuMenu.currentMenuPosition.currentLinkName = nil
					SkuMenu.currentMenuPosition.linksHistory = nil
				end
				if SkuMenu.currentMenuPosition.textFull then
					if SkuMenu.currentMenuPosition.textFull ~= "" then
						if not SkuMenu.TTS:IsVisible() then
							SkuMenu.TTS:Output(SkuMenu:AddExtraTooltipData(SkuMenu.currentMenuPosition.textFull, SkuMenu.currentMenuPosition.itemId), 1000)
						end
						SkuMenu.TTS:Output(SkuMenu.currentMenuPosition.textFull, 1000)

						SkuMenu.currentMenuPosition.links = {}
						SkuMenu.currentMenuPosition.linksSelected = 0
						SkuMenu.TTS:PreviousLine(SkuMenu.currentMenuPosition.ttsEngine)
					end
				end			
				if SkuMenu.TTS:IsAutoRead() == true then
					SkuMenu.TTS:ToggleAutoRead()
					SkuMenu.TTS.AutoReadEventFlag = nil

				end					
			end
		end

		if aKey ~= "ESCAPE" and SkuMenu.currentMenuPosition then
			--[[
			SkuMenu:ShowVisualMenu()
			local tTable = SkuMenu.currentMenuPosition
			local tBread = SkuMenu.currentMenuPosition.name
			local tResult = {}
			if tTable.parent then
				while tTable.parent.name do
					tTable = tTable.parent
					tBread = tTable.name.." > "..tBread
					table.insert(tResult, 1, tTable.name)
				end
				table.insert(tResult, SkuMenu.currentMenuPosition.name)
				SkuMenu:ShowVisualMenuSelectByPath(unpack(tResult))
			end
			]]
		end
	end)

	tFrame:SetScript("OnShow", function(self)
		--dprint("OnSkuMenuMainOption1 OnShow")
		
		if SkuMenu.inCombat == true then
			SkuMenu.openMenuAfterCombat = true
			return
		end
		if SkuMenu.isMoving == true then
			SkuMenu.openMenuAfterMoving = true
			return
		end

		SkuMenu.openMenuAfterCombat = false
		SkuMenu.openMenuAfterMoving = false	
		
		PlaySound(88)
		SetOverrideBindingClick(self, true, "PAGEUP", "OnSkuMenuMainOption1", "PAGEUP")
		SetOverrideBindingClick(self, true, "PAGEDOWN", "OnSkuMenuMainOption1", "PAGEDOWN")
		SetOverrideBindingClick(self, true, "CTRL-SHIFT-UP", "OnSkuMenuMainOption1", "CTRL-SHIFT-UP")
		SetOverrideBindingClick(self, true, "CTRL-SHIFT-DOWN", "OnSkuMenuMainOption1", "CTRL-SHIFT-DOWN")
		SetOverrideBindingClick(self, true, "SHIFT-UP", "OnSkuMenuMainOption1", "SHIFT-UP")
		SetOverrideBindingClick(self, true, "SHIFT-DOWN", "OnSkuMenuMainOption1", "SHIFT-DOWN")
		SetOverrideBindingClick(self, true, "SHIFT-PAGEDOWN", "OnSkuMenuMainOption1", "SHIFT-PAGEDOWN")

		SetOverrideBindingClick(self, true, "SHIFT-RIGHT", "OnSkuMenuMainOption1", "SHIFT-RIGHT")
		SetOverrideBindingClick(self, true, "SHIFT-LEFT", "OnSkuMenuMainOption1", "SHIFT-LEFT")
		SetOverrideBindingClick(self, true, "SHIFT-ENTER", "OnSkuMenuMainOption1", "SHIFT-ENTER")
		SetOverrideBindingClick(self, true, "SHIFT-BACKSPACE", "OnSkuMenuMainOption1", "SHIFT-BACKSPACE")

		SetOverrideBindingClick(self, true, "CTRL-RIGHT", "OnSkuMenuMainOption1", "CTRL-RIGHT")
		SetOverrideBindingClick(self, true, "HOME", "OnSkuMenuMainOption1", "HOME")
		SetOverrideBindingClick(self, true, "END", "OnSkuMenuMainOption1", "END")
		SetOverrideBindingClick(self, true, "UP", "OnSkuMenuMainOption1", "UP")
		SetOverrideBindingClick(self, true, "DOWN", "OnSkuMenuMainOption1", "DOWN")
		SetOverrideBindingClick(self, true, "LEFT", "OnSkuMenuMainOption1", "LEFT")
		SetOverrideBindingClick(self, true, "RIGHT", "OnSkuMenuMainOption1", "RIGHT")
		SetOverrideBindingClick(self, true, "BACKSPACE", "OnSkuMenuMainOption1", "BACKSPACE")
		SetOverrideBindingClick(self, true, "ESCAPE", "OnSkuMenuMainOption1", "ESCAPE")
		for x = 1, #SkuMenu.MenuAccessKeysChars do
			--SetOverrideBindingClick(self, true, SkuMenu.MenuAccessKeysChars[x], "OnSkuMenuMainOption1", SkuMenu.MenuAccessKeysChars[x])
			SetOverrideBindingClick(UIParent, true, SkuMenu.MenuAccessKeysChars[x], "UIParent", SkuMenu.MenuAccessKeysChars[x])
			SkuMenu.MenuAccessKeysChars[SkuMenu.MenuAccessKeysChars[x]] = SkuMenu.MenuAccessKeysChars[x]
		end
		--SetOverrideBindingClick(self, true, "SPACE", "OnSkuMenuMainOption1", "SPACE")
		SetOverrideBindingClick(UIParent, true, "SPACE", "UIParent", "SPACE")
		for x = 1, #SkuMenu.MenuAccessKeysNumbers do
			--SetOverrideBindingClick(self, true, SkuMenu.MenuAccessKeysNumbers[x], "OnSkuMenuMainOption1", SkuMenu.MenuAccessKeysNumbers[x])
			SetOverrideBindingClick(UIParent, true, SkuMenu.MenuAccessKeysNumbers[x], "UIParent", SkuMenu.MenuAccessKeysNumbers[x])
			SkuMenu.MenuAccessKeysNumbers[SkuMenu.MenuAccessKeysNumbers[x]] = SkuMenu.MenuAccessKeysNumbers[x]
		end
	end)

	tFrame:SetScript("OnHide", function(self)
		--dprint("OnSkuMenuMainOption1 OnHide")
		
		if SkuMenu.inCombat == true then
			return
		end
		

		ClearOverrideBindings(self)
		ClearOverrideBindings(UIParent)
		PlaySound(89)


		SkuMenu.TTS:Output("", -1)
	end)

	tFrame:Show()

	tFrame = CreateFrame("Button", "SecureOnSkuMenuMainOption1", _G["OnSkuMenuMain"], "SecureActionButtonTemplate")
	tFrame:SetText("SecureOnSkuMenuMainOption1")
	tFrame:SetPoint("TOP", _G["OnSkuMenuMain"], "BOTTOM", 0, 0)
	tFrame:SetScript("OnShow", function(self)
		SetOverrideBindingClick(self, true, "ENTER", "SecureOnSkuMenuMainOption1", "ENTER")
	end)
	tFrame:SetScript("OnHide", function(self)
		ClearOverrideBindings(self)
	end)
	tFrame:HookScript("OnClick", _G["OnSkuMenuMainOption1"]:GetScript("OnClick"))
	tFrame:Show()
end

---------------------------------------------------------------------------------------------------------------------------------------
function SkuMenu:GetLinkFinalRedirectTarget(aLinkName)
	--check redirect until there is actual content or nil
	if not SkuDB.Wiki[SkuMenu.Loc].data[aLinkName] then
		return
	end
	if not SkuDB.Wiki[SkuMenu.Loc].data[aLinkName].redirect then
		return aLinkName
	end
	
	local visited = {}
	local tNextRedToCheck = SkuDB.Wiki[SkuMenu.Loc].data[aLinkName].redirect
	while true do
		if not SkuDB.Wiki[SkuMenu.Loc].data[tNextRedToCheck] then
			return
		end
		if visited[tNextRedToCheck] then
			return
		end
		if not SkuDB.Wiki[SkuMenu.Loc].data[tNextRedToCheck].redirect then
			return tNextRedToCheck
		end
		visited[tNextRedToCheck] = true
		tNextRedToCheck = SkuDB.Wiki[SkuMenu.Loc].data[tNextRedToCheck].redirect
	end

	return
end

---------------------------------------------------------------------------------------------------------------------------------------
local tStar1ValueText = {}
local tStar2ValueText = {}
local tStar3ValueText = {}

for x = 0, 500 do
	tStar1ValueText[x] = x
	tStar2ValueText[x] = x
	tStar3ValueText[x] = x
end

function SkuMenu:FormatAndBuildSectionTable(aPlainText, aLinkName, aRedirectedFromLinkName)
	SkuMenu.db.profile.testtext = aPlainText
	aPlainText = string.gsub(aPlainText, "\r\n", "\n")
	
	--format and build the section table for SkuTTS
	local tFormattedWikiFull, tFinalLinkName = aPlainText, aLinkName
	--bold, italic
	tFormattedWikiFull = string.gsub(tFormattedWikiFull, "''''''", "")
	tFormattedWikiFull = string.gsub(tFormattedWikiFull, "'''''", "")
	--tFormattedWikiFull = string.gsub(tFormattedWikiFull, "''''", "") --this should be never used in wiki articles
	tFormattedWikiFull = string.gsub(tFormattedWikiFull, "'''", "")

	--bullets, numbers
	if SkuMenu.db.profile["SkuAdventureGuide"].formatEnumsInArticles ~= true then
		tFormattedWikiFull = string.gsub(tFormattedWikiFull, "^%*", "")
		tFormattedWikiFull = string.gsub(tFormattedWikiFull, "^%*%*", "")
		tFormattedWikiFull = string.gsub(tFormattedWikiFull, "^%*%*%*", "")
		tFormattedWikiFull = string.gsub(tFormattedWikiFull, "^#", "")
		tFormattedWikiFull = string.gsub(tFormattedWikiFull, "^##", "")
		tFormattedWikiFull = string.gsub(tFormattedWikiFull, "^###", "")
	else
		local tStar1Value = 0
		local tStar2Value = 0
		local tStar3Value = 0

		local tCurrentStart = 0
		local tNextLb = string.find(tFormattedWikiFull, "\n")
		
		local tFinalFormatted = ""
		if tNextLb then
			repeat
				local tSubString = string.sub(tFormattedWikiFull, tCurrentStart, tNextLb)
				local tFound = false
				if string.sub(tSubString, 0, 3) == "***" then
					tSubString = (tStar1ValueText[tStar1Value] or "").."."..(tStar2ValueText[tStar2Value] or "").."."..tStar3ValueText[tStar3Value + 1]..", "..string.sub(tSubString, 4) 
					tStar3Value = tStar3Value + 1
					tFound = true
				else
					tStar3Value = 0
				end

				if string.sub(tSubString, 0, 2) == "**" then
					tSubString = (tStar1ValueText[tStar1Value] or "").."."..tStar2ValueText[tStar2Value + 1]..". "..string.sub(tSubString, 3) 
					tStar2Value = tStar2Value + 1
					tStar3Value = 0
					tFound = true
				else
					tStar2Value = 0
				end

				if string.sub(tSubString, 0, 1) == "*" then
					tSubString = tStar1ValueText[tStar1Value + 1]..". "..string.sub(tSubString, 2) 
					tStar1Value = tStar1Value + 1
					tStar2Value = 0
					tStar3Value = 0
					tFound = true
				end

				if tFound == false then
					tStar1Value = 0
					tStar2Value = 0
					tStar3Value = 0
				end
				
				tCurrentStart = tNextLb + 1
				tNextLb = string.find(tFormattedWikiFull, "\n", tCurrentStart)

				tFinalFormatted = tFinalFormatted..tSubString
			until(not tNextLb)

			local tSubString = string.sub(tFormattedWikiFull, tCurrentStart)
			tFinalFormatted = tFinalFormatted..tSubString
		end

		if tFinalFormatted ~= "" then
			tFormattedWikiFull = tFinalFormatted
		end
	end

	tFormattedWikiFull = string.gsub(tFormattedWikiFull, "―", " - ")
	tFormattedWikiFull = string.gsub(tFormattedWikiFull, "{{PAGENAME}}", tFinalLinkName)

	if aRedirectedFromLinkName then
		aRedirectedFromLinkName = L[" (Redirected from "]..aRedirectedFromLinkName..")"
	else
		aRedirectedFromLinkName = ""
	end

	local tFormattedWikiSections = {}
	local tSections = {}
	if not string.find(tFormattedWikiFull, "\n") then
		local tSection = aLinkName..aRedirectedFromLinkName.."\n"..tFormattedWikiFull
		table.insert(tFormattedWikiSections, tSection)
	else
		local tSection = aLinkName..aRedirectedFromLinkName
		local tLastString = ""
		for str in string.gmatch(tFormattedWikiFull, "[^\n]+") do
			if string.sub(str, 1, 1) ~= "=" then
				tSection = tSection.."\r\n"..str
			else
				table.insert(tFormattedWikiSections, tSection)
				local tVClear = string.gsub(str, " =", "")
				tVClear = string.gsub(tVClear, "= ", "")
				tVClear = string.gsub(tVClear, "=", "")
				tSection = tVClear
			end
			tLastString = str
		end

		table.insert(tFormattedWikiSections, tSection)
	end

	return tFormattedWikiSections
end

---------------------------------------------------------------------------------------------------------------------------------------
function SkuMenu:LoadLinkDataToTooltip(aLinkName, aDontAddToHistory)
	local tStringLower = slower(aLinkName)
	local tDataLink = SkuDB.Wiki[SkuMenu.Loc].lookup[tStringLower]
	if tDataLink then
		local tFinalLink = SkuMenu:GetLinkFinalRedirectTarget(tDataLink)
		if tFinalLink then
			if not aDontAddToHistory then
				SkuMenu.currentMenuPosition.linksHistory = SkuMenu.currentMenuPosition.linksHistory or {}
				table.insert(SkuMenu.currentMenuPosition.linksHistory, 1, tFinalLink)
			end

			--format wiki content and build sections
			local tFormattedWikiFull = SkuDB.Wiki[SkuMenu.Loc].data[tFinalLink].content
			local tFormattedWikiSections
			if tDataLink ~= tFinalLink then
				tFormattedWikiSections = SkuMenu:FormatAndBuildSectionTable(SkuDB.Wiki[SkuMenu.Loc].data[tFinalLink].content, tFinalLink, tDataLink)
			else
				tFormattedWikiSections = SkuMenu:FormatAndBuildSectionTable(SkuDB.Wiki[SkuMenu.Loc].data[tFinalLink].content, tFinalLink)
			end

			SkuMenu.currentMenuPosition.currentLinkName = tFinalLinkName
			SkuMenu.currentMenuPosition.textFull = tFormattedWikiSections--tFormattedWikiFull
			SkuMenu.TTS:Output(tFormattedWikiSections, 1000)
			SkuMenu.currentMenuPosition.links = {}
			SkuMenu.currentMenuPosition.linksSelected = 0
			SkuMenu.TTS:PreviousLine(SkuMenu.currentMenuPosition.ttsEngine)
		end
	end
end

---------------------------------------------------------------------------------------------------------------------------------------
function SkuMenu:OnInitialize()
	print("SkuMenu OnInitialize")
	if SkuMenu then
		options.args["SkuMenu"] = SkuMenu.options
		defaults.profile["SkuMenu"] = SkuMenu.defaults
	end

	SkuMenu.AceConfig = LibStub("AceConfig-3.0")
	SkuMenu.AceConfig:RegisterOptionsTable("SkuMenu", options, {"taop"})
	SkuMenu.db = LibStub("AceDB-3.0"):New("SkuMenuDB", defaults, true)
	options.args.profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(SkuMenu.db)

	SkuMenu:SkuKeyBindsUpdate(true)

	SkuMenu.db.RegisterCallback(self, "OnProfileChanged", "OnProfileChanged")
	SkuMenu.db.RegisterCallback(self, "OnProfileCopied", "OnProfileCopied")
	SkuMenu.db.RegisterCallback(self, "OnProfileReset", "OnProfileReset")

	SkuMenu:RegisterEvent("PLAYER_ENTERING_WORLD")
	SkuMenu:RegisterEvent("PLAYER_LOGIN")
	SkuMenu:RegisterEvent("PLAYER_REGEN_DISABLED")
	SkuMenu:RegisterEvent("PLAYER_REGEN_ENABLED")





	--This is because the audio menu overrides most movement keys. 
	--If the player is turning/moving when the audio menu opens it would turn/move until the menu is closed.
	hooksecurefunc("StartAutoRun", function() SkuMenuMovement.Flags.IsTurningOrAutorunningOrStrafing = true end)
	hooksecurefunc("StrafeLeftStart", function() SkuMenuMovement.Flags.IsTurningOrAutorunningOrStrafing = true end)
	hooksecurefunc("StrafeRightStart", function() SkuMenuMovement.Flags.IsTurningOrAutorunningOrStrafing = true end)
	hooksecurefunc("TurnLeftStart", function() SkuMenuMovement.Flags.IsTurningOrAutorunningOrStrafing = true end)
	hooksecurefunc("TurnRightStart", function() SkuMenuMovement.Flags.IsTurningOrAutorunningOrStrafing = true end)
	hooksecurefunc("StopAutoRun", function() SkuMenuMovement.Flags.IsTurningOrAutorunningOrStrafing = false end)
	hooksecurefunc("StrafeLeftStop", function() SkuMenuMovement.Flags.IsTurningOrAutorunningOrStrafing = false end)
	hooksecurefunc("StrafeRightStop", function() SkuMenuMovement.Flags.IsTurningOrAutorunningOrStrafing = false end)
	hooksecurefunc("TurnLeftStop", function() SkuMenuMovement.Flags.IsTurningOrAutorunningOrStrafing = false end)
	hooksecurefunc("TurnRightStop", function() SkuMenuMovement.Flags.IsTurningOrAutorunningOrStrafing = false end)
	hooksecurefunc("AscendStop", function() SkuMenuMovement.Flags.Ascend = false end)
	hooksecurefunc("SitStandOrDescendStart", function() SkuMenuMovement.Flags.Descend = true end)
	hooksecurefunc("DescendStop", function() SkuMenuMovement.Flags.Descend = false end)
	hooksecurefunc("FollowUnit", function() SkuMenuMovement.Flags.FollowUnit = true end)
	hooksecurefunc("MoveForwardStart", function() SkuMenuMovement.Flags.MoveForward = true end)
	hooksecurefunc("MoveForwardStop", function() SkuMenuMovement.Flags.MoveForward = false end)
	hooksecurefunc("MoveBackwardStart", function() SkuMenuMovement.Flags.MoveBackward = true end)
	hooksecurefunc("MoveBackwardStop", function() SkuMenuMovement.Flags.MoveBackward = false end)
	hooksecurefunc("StrafeLeftStart", function() SkuMenuMovement.Flags.StrafeLeft = true end)
	hooksecurefunc("StrafeLeftStop", function() SkuMenuMovement.Flags.StrafeLeft = false end)
	hooksecurefunc("StrafeRightStart", function() SkuMenuMovement.Flags.StrafeRight = true end)
	hooksecurefunc("StrafeRightStop", function() SkuMenuMovement.Flags.StrafeRight = false end)
	hooksecurefunc("JumpOrAscendStart", function() SkuMenuMovement.Flags.Ascend = true end)
	hooksecurefunc("AscendStop", function() SkuMenuMovement.Flags.Ascend = false end)
	hooksecurefunc("SitStandOrDescendStart", function() SkuMenuMovement.Flags.Descend = true end)
	hooksecurefunc("DescendStop", function() SkuMenuMovement.Flags.Descend = false end)
	hooksecurefunc("PitchDownStart", function() SkuMenuMovement.Flags.PitchDown = true end)
	hooksecurefunc("PitchDownStop", function() SkuMenuMovement.Flags.PitchDown = false end)
	hooksecurefunc("PitchUpStart", function() SkuMenuMovement.Flags.PitchUp = true end)
	hooksecurefunc("PitchUpStop", function() SkuMenuMovement.Flags.PitchUp = false end)


	SkuMenu:CreateControlFrame()
	SkuMenu:CreateMainFrame()
	SkuMenu.Filterstring = ""
	SkuMenu:CreateMenuFrame()
end

---------------------------------------------------------------------------------------------------------------------------------------
function SkuMenu:IsPlayerMoving()
	local rValue = false
	if SkuMenuMovement.Flags.IsTurningOrAutorunningOrStrafing == true or
	SkuMenuMovement.Flags.MoveForward == true or
		SkuMenuMovement.Flags.MoveBackward == true or
		SkuMenuMovement.Flags.StrafeLeft == true or
		SkuMenuMovement.Flags.StrafeRight == true or
		SkuMenuMovement.Flags.Ascend == true or
		SkuMenuMovement.Flags.Descend == true
	then
		rValue = true
	end
    return rValue
end

---------------------------------------------------------------------------------------------------------------------------------------
function SkuMenu:PLAYER_REGEN_DISABLED(...)
	SkuMenu:CloseMenu()
	SkuMenu.inCombat = true
	--SkuMenu.Voice:OutputString(L["Combat start"], true, true, 0.2)
end

---------------------------------------------------------------------------------------------------------------------------------------
function SkuMenu:PLAYER_REGEN_ENABLED(...)
	SkuMenu.inCombat = false
	--SkuMenu.Voice:OutputString(L["Combat end"], true, true, 0.2)
end

---------------------------------------------------------------------------------------------------------------------------------------
local tOldChildren = false
function SkuMenu:ClearFilter()
	if tOldChildren ~= false then
		tOldChildren = false
		--SkuMenu:Debug("ClearFilter: filter cleared, no menu update")
	else
		--SkuMenu:Debug("ClearFilter: error: no old child data", tOldChildren)
	end
	SkuMenu.Filterstring = ""
end
---------------------------------------------------------------------------------------------------------------------------------------
function SkuMenu:ApplyFilter(aFilterstring)
	--dprint("aFilterstring", aFilterstring, SkuMenu.currentMenuPosition.parent.filterable)

	aFilterstring = slower(aFilterstring)

	if SkuMenu.currentMenuPosition.parent.filterable ~= true then
		--SkuMenu:Debug("ApplyFilter: not filterable")
		return
	end

	if aFilterstring ~= "" then
		if tOldChildren ~= false then
			--SkuMenu:Debug("ApplyFilter: is already filtered; will unfilter first", tOldChildren)
			SkuMenu:ApplyFilter("")
		end

		tOldChildren = SkuMenu.currentMenuPosition.parent.children

		local tChildrenFiltered = {}
		local tFilterEntry = SkuMenu:TableCopy(tOldChildren[1])
		tFilterEntry.name = L["Filter"]..";"..aFilterstring
		table.insert(tChildrenFiltered, tFilterEntry)
		for x = 1, #tOldChildren do
			local tHayStack = slower(tOldChildren[x].name)
			tHayStack = string.gsub(tHayStack, L["OBJECT"]..";%d+;", L["OBJECT"]..";")
			tHayStack = string.gsub(tHayStack, ";", " ")
			tHayStack = string.gsub(tHayStack, "#", " ")

			local tTempHayStack = tHayStack
			for i, v in pairs({strsplit(tHayStack, " ")}) do
				local tNumberTest = tonumber(v)
				if tNumberTest then
					local tFloat = math.floor(tNumberTest)
					if (tNumberTest > 20000) or (tNumberTest - tFloat > 0) then
						tTempHayStack = string.gsub(tTempHayStack, v)
					end
				end
			end
			tHayStack = tTempHayStack

			if string.find(slower(tHayStack), slower(aFilterstring))  then
					table.insert(tChildrenFiltered, tOldChildren[x])
			end
		end

		if #tChildrenFiltered == 0 then
			table.insert(tChildrenFiltered, tOldChildren[1])
			--SkuMenu:Debug("ApplyFilter: keine Ergebnisse f�r filter, element 1 wird angezeigt")
			SkuMenu.Voice:OutputStringBTtts(L["No results"], true, true, 0.2, nil, nil, nil, 2)
		end

		for x = 1, #tChildrenFiltered do
			if tChildrenFiltered[x+1] then
				tChildrenFiltered[x].next = tChildrenFiltered[x+1]
			else
				tChildrenFiltered[x].next = nil
			end
			if tChildrenFiltered[x-1] then
				tChildrenFiltered[x].prev = tChildrenFiltered[x-1]
			else
				tChildrenFiltered[x].prev = nil
			end
		end

		SkuMenu.currentMenuPosition.parent.children = tChildrenFiltered--tOldChildren)
		SkuMenu.currentMenuPosition:OnFirst()

		SkuMenu.Voice:OutputStringBTtts(L["Filter applied"], true, true, 0.3, nil, nil, nil, 2)
		--SkuMenu:Debug("ApplyFilter: filter applied, menu updated")
	end
	if aFilterstring == "" then
		if tOldChildren ~= false then
			SkuMenu.currentMenuPosition.parent.children = tOldChildren--tOldChildren)
			for x = 1, #SkuMenu.currentMenuPosition.parent.children do
				if SkuMenu.currentMenuPosition.parent.children[x+1] then
					SkuMenu.currentMenuPosition.parent.children[x].next = SkuMenu.currentMenuPosition.parent.children[x+1]
				else
					SkuMenu.currentMenuPosition.parent.children[x].next = nil
				end
				if SkuMenu.currentMenuPosition.parent.children[x-1] then
					SkuMenu.currentMenuPosition.parent.children[x].prev = SkuMenu.currentMenuPosition.parent.children[x-1]
				else
					SkuMenu.currentMenuPosition.parent.children[x].prev = nil
				end
			end
			SkuMenu.currentMenuPosition:OnFirst()
			tOldChildren = false

			SkuMenu.Voice:OutputStringBTtts(L["Filter removed"], true, true, 0.3, nil, nil, nil, 2)
			--SkuMenu:Debug("ApplyFilter: filter cleared, menu updated")
		else
			--SkuMenu:Debug("ApplyFilter: error: no old child data. this should not happen!")
		end
	end
end

---------------------------------------------------------------------------------------------------------------------------------------
function SkuMenu:OnEnable()
	print("SkuMenu OnEnable")
   
	if SkuMenu.inCombat == true then
		return
	end
   


end

---------------------------------------------------------------------------------------------------------------------------------------
function SkuMenu:OnDisable()
	print("SkuMenu OnDisable")
end

---------------------------------------------------------------------------------------------------------------------------------------
function SkuMenu:PLAYER_LOGIN(...)

end

---------------------------------------------------------------------------------------------------------------------------------------
function SkuMenu:PLAYER_ENTERING_WORLD(...)
	print("PLAYER_ENTERING_WORLD", ...)
	local event, isInitialLogin, isReloadingUi = ...

	--remove aws polly dev voices on my system
	SkuMenu.WowTtsVoices = {}
	for i, v in pairs(C_VoiceChat.GetTtsVoices()) do
		if not string.find(v.name, "Polly") then
			SkuMenu.WowTtsVoices[i] = v.name
		end
	end
	SkuMenu.options.args.WowTtsVoice.values = SkuMenu.WowTtsVoices

	if isInitialLogin == true or isReloadingUi == true then
		SkuMenu.db.global["SkuMenu"] = SkuMenu.db.global["SkuMenu"] or {}
	end
end


---------------------------------------------------------------------------------------------------------------------------------------
function SkuMenu:VocalizeMultipartString(aStr, aReset, aWait, aDuration, aDoNotOverride, engine, aVocalizeAsIs)
	SkuMenu.Voice:OutputStringBTtts(aStr, aReset, aWait, 0.2, aDoNotOverride, false, nil, true, 2, aVocalizeAsIs)
end

---------------------------------------------------------------------------------------------------------------------------------------
---@param aReset bool reset queue
function SkuMenu:VocalizeCurrentMenuName(aReset, aReturnAsString)
	--print("--VocalizeCurrentMenuName", aReset, debugstack())
	
	if aReset == nil then aReset = true end

	local tTable = SkuMenu.currentMenuPosition

	--get menu pos
	local tMenuNumber = nil
	if tTable.parent then
		if tTable.parent.children then
			if tTable.parent.children ~= {} then
				for x = 1, #tTable.parent.children do
					if tTable.parent.children[x].name == SkuMenu.currentMenuPosition.name then
						tMenuNumber = x
					end
				end
			end
		else
			for x = 1, #SkuMenu.Menu do
				if SkuMenu.Menu[x].name == SkuMenu.currentMenuPosition.name then
					tMenuNumber = x
				end
			end
		end
	end
	SkuMenu.currentMenuPosition:BuildChildren(SkuMenu.currentMenuPosition)

	--handle filter placeholder
	local tUncleanValue = SkuMenu.currentMenuPosition.name
	--handle unicode chars
	local tString = ""
	if string.find(tUncleanValue, L["Filter"]..";") then
		tUncleanValue = slower(tUncleanValue:sub(string.len(L["Filter"]..";") + 1))
		for tChr in tUncleanValue:gmatch("[\33-\127\192-\255]?[\128-\191]*") do
			tString = tString..tChr..";"
		end
		while string.find(tString, ";;") do
			tString = string.gsub(tString, ";;", ";")
		end
		tUncleanValue = tString
	end

	if string.sub(tUncleanValue, 1, string.len(L["Filter"]..";")) == L["Filter"]..";" then
		local tSecondSegment = string.sub(tUncleanValue, string.len(L["Filter"]..";") + 1)
		tUncleanValue = L["Filter"]..";"
		for q = 1, string.len(tSecondSegment) do
			tUncleanValue = tUncleanValue..string.sub(tSecondSegment, q, q)..";"
		end
	end

	local tCleanValue = tUncleanValue--SkuMenu.currentMenuPosition.name
	local tPrefix
	local tPos = string.find(tUncleanValue, "#")
	if tPos ~= nil then
		tPrefix = string.sub(tUncleanValue, 1, tPos - 1)
		tCleanValue = string.sub(tUncleanValue,  tPos + 1)
	end

	local tFinalString = ""

	tMenuNumber = tMenuNumber or ""

	if SkuMenu.db.profile[MODULE_NAME].vocalizeMenuNumbers == true and  SkuMenu.currentMenuPosition.noMenuNumbers ~= true then
		tFinalString = tFinalString..tMenuNumber..";"
	end
	if tPrefix then
		tFinalString = tFinalString..tPrefix..";"
	end
	tFinalString = tFinalString..tCleanValue
	if SkuMenu.db.profile[MODULE_NAME].vocalizeSubmenus == true then
		if #SkuMenu.currentMenuPosition.children > 0 then
			tFinalString = tFinalString..";"..L["plus"]
		end
	end

	--print("SkuMenu:VocalizeMultipartString", tFinalString, aReset, true, nil, nil, SkuMenu.currentMenuPosition.ttsEngine, SkuMenu.currentMenuPosition.vocalizeAsIs)

	if aReturnAsString then
		return tFinalString
	else
		SkuMenu:VocalizeMultipartString(tFinalString, aReset, true, nil, nil, 2, SkuMenu.currentMenuPosition.vocalizeAsIs)
	end

	--debug as text
	local tBread = SkuMenu.currentMenuPosition.name
	while tTable.parent.name do
		tTable = tTable.parent
		tBread = tTable.name.." > "..tBread
	end
	SkuMenu:Debug(tBread, true)
end

---------------------------------------------------------------------------------------------------------------------------------------
function SkuMenu:InjectMenuItems(aParentMenu, aNewItems, aItemTemplate)
	local rValue = nil

	if aItemTemplate then
		local tParentMenu = aParentMenu.children or aParentMenu
		for x = 1, #aNewItems do
			tParentMenu = tParentMenu + aItemTemplate
			tParentMenu[#tParentMenu].name = aNewItems[x]
			tParentMenu[#tParentMenu].index = #tParentMenu
			tParentMenu[#tParentMenu].parent = aParentMenu
			if tParentMenu[#tParentMenu - 1] then
				tParentMenu[#tParentMenu].prev = tParentMenu[#tParentMenu - 1]
				tParentMenu[#tParentMenu - 1].next = tParentMenu[#tParentMenu]
			end
			rValue = tParentMenu[#tParentMenu]
		end
	else
		aParentMenu.children = aNewItems
		for x = 1, #aNewItems do
			aNewItems[x].parent = aParentMenu
		end
	end

	return rValue
end


---------------------------------------------------------------------------------------------------------------------------------------
function SkuMenu:TableCopy(t, deep, seen)
	seen = seen or {}
	if t == nil then return nil end
	if seen[t] then return seen[t] end
	local nt = {}
	for k, v in pairs(t) do
		if type(v) ~= "userdata" and k ~= "frame" and k ~= 0  then
			if deep and type(v) == 'table' then
				nt[k] = SkuMenu:TableCopy(v, deep, seen)
			else
				nt[k] = v
			end
		end
	end
	--setmetatable(nt, getmetatable(t), deep, seen))
	seen[t] = nt
	return nt
end


---------------------------------------------------------------------------------------------------------------------------------------
function SkuMenu:IterateOptionsArgs(aArgTable, aParentMenu, tProfileParentPath)
	for i, v in SkuSpairs(aArgTable, function(t, a, b) if t[b].order and t[a].order then return t[b].order > t[a].order end end) do
		if v.args and v.forAudioMenu ~= false then
			local tParentMenu =  SkuMenu:InjectMenuItems(aParentMenu, {v.name}, SkuGenericMenuItem)
			--tParentMenu.dynamic = true
			tParentMenu.filterable = true
			SkuMenu:IterateOptionsArgs(v.args, tParentMenu, tProfileParentPath[i])
		else
			if v.type == "toggle" then
				local tNewMenuEntry = SkuMenu:InjectMenuItems(aParentMenu, {v.name}, SkuGenericMenuItem)
				tNewMenuEntry.optionsPath = aArgTable
				tNewMenuEntry.profilePath = tProfileParentPath
				tNewMenuEntry.profileIndex = i
				tNewMenuEntry.dynamic = true
				tNewMenuEntry.isSelect = true
				tNewMenuEntry.OnAction = function(self, aValue, aName)
					if aName == L["On"] then
						self.profilePath[self.profileIndex] = true
					elseif aName == L["Off"] then
						self.profilePath[self.profileIndex] = false
					end
					
					if self.optionsPath[self.profileIndex].OnAction then
						self.optionsPath[self.profileIndex]:OnAction(nil, self.profilePath[self.profileIndex])
					end
					--PlaySound(835)
				end
				tNewMenuEntry.BuildChildren = function(self)
					tNewMenuEntry = SkuMenu:InjectMenuItems(self, {L["On"]}, SkuGenericMenuItem)
					tNewMenuEntry = SkuMenu:InjectMenuItems(self, {L["Off"]}, SkuGenericMenuItem)
				end
				tNewMenuEntry.GetCurrentValue = function(self, aValue, aName)
					local tValue = L["On"]
					--if self.profilePath[self.profileIndex] == true then
					if self.optionsPath[self.profileIndex]:get() == true then
						tValue = L["On"]
					else
						tValue = L["Off"]
					end
					return tValue
				end

			elseif v.type == "select" then
				local tNewMenuEntry =SkuMenu:InjectMenuItems(aParentMenu, {v.name}, SkuGenericMenuItem)
				tNewMenuEntry.optionsPath = aArgTable
				tNewMenuEntry.profilePath = tProfileParentPath
				tNewMenuEntry.profileIndex = i
				tNewMenuEntry.dynamic = true
				tNewMenuEntry.isSelect = true
				tNewMenuEntry.OnAction = function(self, aValue, aName)
					for ia, va in pairs(v.values) do
						if va == aName or va == L["sound"].."#"..aName or va == L["aura;sound"].."#"..aName then
							self.profilePath[self.profileIndex] = ia
						end
					end

					local tFlag
					if self.optionsPath[self.profileIndex].OnAction then
						self.optionsPath[self.profileIndex]:OnAction(aValue, aName)
					end
				end
				tNewMenuEntry.BuildChildren = function(self)
					local tFinalMenuEntries = {}
					local tCounter = 0

					--unfortunately we have value tables with number keys and holes and need to handle that
					for key, value in pairs(v.values) do
						tFinalMenuEntries[#tFinalMenuEntries + 1] = value
						tCounter = tCounter + 1
					end

					--if number index and no holes, use it to sort
					if #v.values > 0 and #v.values == tCounter then
						tFinalMenuEntries = {}
						for key, value in ipairs(v.values) do
							tFinalMenuEntries[#tFinalMenuEntries + 1] = value
						end
					end

					for key, value in ipairs(tFinalMenuEntries) do
						SkuMenu:InjectMenuItems(self, {value}, SkuGenericMenuItem)
					end
				end
				tNewMenuEntry.GetCurrentValue = function(self, aValue, aName)
					local tValue = ""
					for ia, va in pairs(v.values) do
						--if ia == self.profilePath[self.profileIndex] then
						if ia == self.optionsPath[self.profileIndex]:get() then
							tValue = va
						end
					end
					return tValue
				end
			elseif v.type == "range" then
				local tNewMenuEntry = SkuMenu:InjectMenuItems(aParentMenu, {v.name}, SkuGenericMenuItem)
				tNewMenuEntry.optionsPath = aArgTable
				tNewMenuEntry.profilePath = tProfileParentPath
				tNewMenuEntry.profileIndex = i
				tNewMenuEntry.dynamic = true
				tNewMenuEntry.isSelect = true
				tNewMenuEntry.filterable = true
				tNewMenuEntry.rangeMin = v.min or 0
				tNewMenuEntry.rangeMax = v.max or 100
				tNewMenuEntry.OnAction = function(self, aValue, aName)
					--self.profilePath[self.profileIndex] = tonumber(aName)
					self.optionsPath[self.profileIndex]:set(tonumber(aName))
					--PlaySound(835)
					if self.optionsPath[self.profileIndex].OnAction then
						self.optionsPath[self.profileIndex]:OnAction(aValue, aName)
					end

				end
				tNewMenuEntry.BuildChildren = function(self)
					local tList = {}
					for q = self.rangeMax, self.rangeMin, -1 do
						--table.insert(tList, q)
						local tNewSMenuEntry =SkuMenu:InjectMenuItems(self, {q}, SkuGenericMenuItem)
						tNewSMenuEntry.noMenuNumbers = true
					end
					--SkuMenu:InjectMenuItems(self, tList, SkuGenericMenuItem)
				end
				tNewMenuEntry.GetCurrentValue = function(self, aValue, aName)
					return self.optionsPath[self.profileIndex]:get()
					--return self.profilePath[self.profileIndex]
				end

			elseif v.type == "execute" then
				local tNewMenuEntry = SkuMenu:InjectMenuItems(aParentMenu, {v.name}, SkuGenericMenuItem)
				tNewMenuEntry.optionsPath = aArgTable
				tNewMenuEntry.profilePath = tProfileParentPath
				tNewMenuEntry.profileIndex = i
				--tNewMenuEntry.dynamic = true
				--tNewMenuEntry.isSelect = true
				--tNewMenuEntry.filterable = true
				tNewMenuEntry.OnAction = function(self, aValue, aName)
					--self.profilePath[self.profileIndex] = tonumber(aName)
					self.optionsPath[self.profileIndex]:func()
					--PlaySound(835)
				end
			end
		end
	end
end

---------------------------------------------------------------------------------------------------------------------------------------
function SkuMenu:Debug(text, clear)
	clear = true

	if skudebuglevel == 0 then
		return
	end

	if not text then
		return
	end
	if not _G["SkuDebug"] then
		local f = _G["SkuDebug"] or CreateFrame("Frame", "SkuDebug", UIParent, BackdropTemplateMixin and "BackdropTemplate")
		local ttime = 0
		--f:SetMovable(true)
		--f:EnableMouse(true)
		f:SetClampedToScreen(true)
		--f:RegisterForDrag("LeftButton")
		f:SetFrameStrata("DIALOG")
		f:SetFrameLevel(129)
		f:SetSize(1000, 40)
		f:SetPoint("TOP", UIParent, "TOP")
		f:SetPoint("LEFT", UIParent, "LEFT")
		f:SetPoint("RIGHT", UIParent, "RIGHT", -300, 0)
		f:SetBackdrop({bgFile = [[Interface\ChatFrame\ChatFrameBackground]], edgeFile = "", tile = false, tileSize = 0, edgeSize = 32, insets = {left = 0, right = 0, top = 0, bottom = 0}})
		f:SetBackdropColor(0, 0, 0, 1)
		f:SetScript("OnDragStart", function(self) self:StartMoving() end)
		f:SetScript("OnDragStop", function(self) self:StopMovingOrSizing() end)
		f:Show()
		local fs = f:CreateFontString("SkuDebugFS")
		fs:SetFontObject(SystemFont_Large)
		fs:SetTextColor(1, 1, 1, 1)
		fs:SetJustifyH("LEFT")
		fs:SetJustifyV("TOP")
		fs:SetAllPoints()
		fs:SetText("\r\n")
	end

	_G["SkuDebug"]:Show()

	if string.len(_G["SkuDebugFS"]:GetText()) > 500 then
		_G["SkuDebugFS"]:SetText("")
	end

	if not clear then
		_G["SkuDebugFS"]:SetText(text.."\r\n".._G["SkuDebugFS"]:GetText())
	else
		_G["SkuDebugFS"]:SetText(text)
	end

	tStartDebugTimestamp = GetTime()
end







-------------------------------------------------------------------------------------------------
function SkuMenu:CheckBound(aKey)
	local aBindingSet = GetCurrentBindingSet()
	local tNumKeyBindings = GetNumBindings()
	for x = 1, tNumKeyBindings do
		local tCommand, _, tKey1, tKey2, tKey3, tKey4 = GetBinding(x, aBindingSet)
		if aKey == tKey1 then
			return tCommand
		end
	end
end

-------------------------------------------------------------------------------------------------
function SkuMenu:SaveBindings()
	local aBindingSet = GetCurrentBindingSet()
	SaveBindings(aBindingSet) 
end

-------------------------------------------------------------------------------------------------
function SkuMenu:GetBinding(aIndex)
	local aBindingSet = GetCurrentBindingSet()
	local tCommand, tCategory, tKey1, tKey2 = GetBinding(aIndex, aBindingSet)

	return tCommand, tCategory, tKey1, tKey2
end

-------------------------------------------------------------------------------------------------
function SkuMenu:DeleteBinding(aCommand)
	local aBindingSet = GetCurrentBindingSet()

	local tNumKeyBindings = GetNumBindings()
	for x = 1, tNumKeyBindings do
		local tCommand, _, tKey1, tKey2, tKey3, tKey4 = GetBinding(x, aBindingSet)
		if tCommand == aCommand then
			if tKey4 then
				SetBinding(tKey4)
			end
			if tKey3 then
				SetBinding(tKey3)
			end
			if tKey2 then
				SetBinding(tKey2)
			end
			if tKey1 then
				SetBinding(tKey1)
			end
		end
	end

	SkuMenu:SaveBindings()
end

-------------------------------------------------------------------------------------------------
function SkuMenu:SetBinding(aKey, aCommand)
	local aBindingSet = GetCurrentBindingSet()
	local tCommand, _, tKey1, tKey2, tKey3, tKey4

	local tNumKeyBindings = GetNumBindings()
	for x = 1, tNumKeyBindings do
		tCommand, _, tKey1, tKey2, tKey3, tKey4 = GetBinding(x, aBindingSet)
		if tCommand == aCommand then
			break
		end
	end
	
	SkuMenu:DeleteBinding(aCommand)

	local tOk = SetBinding(aKey, aCommand, 1)
	if tKey2 then
		local tOk = SetBinding(tKey2, aCommand, 1)
	end

	SkuMenu:SaveBindings()
end

-------------------------------------------------------------------------------------------------
function SkuMenu:LoadBindings()
	local aBindingSet = GetCurrentBindingSet()
	LoadBindings(aBindingSet) 
end

---------------------------------------------------------------------------------------------------------------------------------------
local function SkuMenuEditBoxOkScript(...)
	
end
---------------------------------------------------------------------------------------------------------------------------------------
---@param aText string
---@param aOkScript function
function SkuMenu:EditBoxShow(aText, aOkScript, aMultilineFlag)
	if not SkuMenuEditBox then
		local f = CreateFrame("Frame", "SkuMenuEditBox", UIParent, "DialogBoxFrame")
		f:SetPoint("CENTER")
		f:SetSize(600, 500)

		f:SetBackdrop({
			bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
			edgeFile = "Interface\\PVPFrame\\UI-Character-PVP-Highlight", -- this one is neat
			edgeSize = 16,
			insets = { left = 8, right = 6, top = 8, bottom = 8 },
		})
		f:SetBackdropBorderColor(0, .44, .87, 0.5) -- darkblue

		-- Movable
		f:SetMovable(true)
		f:SetClampedToScreen(true)
		f:SetScript("OnMouseDown", function(self, button)
			if button == "LeftButton" then
				self:StartMoving()
			end
		end)
		f:SetScript("OnMouseUp", f.StopMovingOrSizing)

		-- ScrollFrame
		local sf = CreateFrame("ScrollFrame", "SkuMenuEditBoxScrollFrame", SkuMenuEditBox, "UIPanelScrollFrameTemplate")
		sf:SetPoint("LEFT", 16, 0)
		sf:SetPoint("RIGHT", -32, 0)
		sf:SetPoint("TOP", 0, -16)
		sf:SetPoint("BOTTOM", SkuMenuEditBoxButton, "TOP", 0, 0)

		-- EditBox
		local eb = CreateFrame("EditBox", "SkuMenuEditBoxEditBox", SkuMenuEditBoxScrollFrame)
		eb:SetSize(sf:GetSize())

		eb:SetAutoFocus(false) -- dont automatically focus
		eb:SetFontObject("ChatFontNormal")
		eb:SetScript("OnEscapePressed", function() 
			PlaySound(89)
			f:Hide()
		end)
		eb:SetScript("OnTextSet", function(self)
			self:HighlightText()
		end)

		sf:SetScrollChild(eb)

		local rb = CreateFrame("Button", "SkuMenuEditBoxResizeButton", SkuMenuEditBox)
		rb:SetPoint("BOTTOMRIGHT", -6, 7)
		rb:SetSize(16, 16)

		rb:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
		rb:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
		rb:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")

		rb:SetScript("OnMouseDown", function(self, button)
			if button == "LeftButton" then
				f:StartSizing("BOTTOMRIGHT")
				self:GetHighlightTexture():Hide() -- more noticeable
			end
		end)
		rb:SetScript("OnMouseUp", function(self, button)
			f:StopMovingOrSizing()
			self:GetHighlightTexture():Show()
			eb:SetWidth(sf:GetWidth())
		end)

		SkuMenuEditBoxEditBox:HookScript("OnEnterPressed", function(...) SkuMenuEditBoxOkScript(...) SkuMenuEditBox:Hide() end)
		SkuMenuEditBoxButton:HookScript("OnClick", SkuMenuEditBoxOkScript)

		f:Show()
	end

	if aMultilineFlag == true then
		SkuMenuEditBoxEditBox:SetMultiLine(true)
	else
		SkuMenuEditBoxEditBox:SetMultiLine(false)
	end
	
	SkuMenuEditBoxEditBox:Hide()
	SkuMenuEditBoxEditBox:SetText("")
	if aText then
		SkuMenuEditBoxEditBox:SetText(aText)
		SkuMenuEditBoxEditBox:HighlightText()
	end
	SkuMenuEditBoxEditBox:Show()
	if aOkScript then
		SkuMenuEditBoxOkScript = aOkScript
	end

	SkuMenuEditBox:Show()

	SkuMenuEditBoxEditBox:SetFocus()
end
