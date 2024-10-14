local MODULE_NAME = "SkuMenu"
local L = SkuMenu.L


local tBlockedKeysParts = {
	"TAB",
	"BACKSPACE",
	"ENTER",
	--"ESCAPE",
	"BUTTON1",
	"BUTTON2",
	"BUTTON3",
	"BUTTON4",
	"BUTTON5",
	"DOWN",
	"UP",
	"LEFT",
	"RIGHT",
	"PAGEDOWN",
	"PAGEDUP",
}
local tBlockedKeysBinds = {
	--"I",
}

local tModifierKeys = {
	"",
	"CTRL-",
	"SHIFT-",
	"ALT-",
	"CTRL-SHIFT-",
	"CTRL-ALT-",
	"SHIFT-ALT-",
	"SHIFT-SHIFT-ALT-",
}

local tStandardChars = {"a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z", "ä", "ü", "ö", "ß", "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "Ä", "Ö", "Ü", ",", ".", "-", "#", "+", "ß", "´", "<"}
local tStandardNumbers = {"1", "2", "3", "4", "5", "6", "7", "8", "9", "0", "F1", "F2", "F3", "F4", "F5", "F6", "F7", "F8", "F9", "F10", "F11", "F12",}


--------------------------------------------------------------------------------------------------------------------------------------
SkuMenu.options = {
	name = MODULE_NAME,
	handler = SkuMenu,
	type = "group",
	args = {
		WowTtsVoice = {
			order = 3,
			name = L["TTS voice"],
			desc = "",
			type = "select",
			values = SkuMenu.WowTtsVoices,
			set = function(info,val)
				SkuMenu.db.profile[MODULE_NAME].WowTtsVoice = val
			end,
			get = function(info)
				return SkuMenu.db.profile[MODULE_NAME].WowTtsVoice
			end,
		},
		WowTtsSpeed = {
			order = 4,
			name = L["TTS speed"],
			desc = "",
			type = "range",
			set = function(info,val)
				SkuMenu.db.profile[MODULE_NAME].WowTtsSpeed = val
			end,
			get = function(info)
				return SkuMenu.db.profile[MODULE_NAME].WowTtsSpeed
			end,
		},
		WowTtsVolume = {
			order = 5,
			name = L["TTS volume"],
			desc = "",
			type = "range",
			set = function(info,val)
				SkuMenu.db.profile[MODULE_NAME].WowTtsVolume = val
			end,
			get = function(info)
				return SkuMenu.db.profile[MODULE_NAME].WowTtsVolume
			end,
		},
		vocalizeMenuNumbers = {
			order = 1,
			name = L["Menünummern ansagen"],
			desc = "",
			type = "toggle",
			set = function(info,val)
				SkuMenu.db.profile[MODULE_NAME].vocalizeMenuNumbers = val
			end,
			get = function(info)
				return SkuMenu.db.profile[MODULE_NAME].vocalizeMenuNumbers
			end
		},
		vocalizeSubmenus = {
			order = 2,
			name = L["Untermenüs ansagen"] ,
			desc = "",
			type = "toggle",
			set = function(info,val)
				SkuMenu.db.profile[MODULE_NAME].vocalizeSubmenus = val
			end,
			get = function(info)
				return SkuMenu.db.profile[MODULE_NAME].vocalizeSubmenus
			end
		},
	},
}
---------------------------------------------------------------------------------------------------------------------------------------
SkuMenu.defaults = {
	WowTtsVoice = 1,
	WowTtsSpeed = 3,
	WowTtsVolume = 50,
	vocalizeMenuNumbers = true,
	vocalizeSubmenus = true,
	}

---------------------------------------------------------------------------------------------------------------------------------------
local function KeyBindingKeyMenuEntryHelper(self, aValue, aName)
	--dprint("cat OnAction 2", aValue, aName, self.name)
	if aName == L["Neu belegen"] then
		SkuMenu.bindingMode = true

		C_Timer.After(0.001, function()
			SkuMenu.Voice:OutputStringBTtts(L["Press new key or Escape to cancel"], true, true, 0.2, true, nil, nil, 2)

			local f = _G["SkuMenuBindControlFrame"] or CreateFrame("Button", "SkuMenuBindControlFrame", UIParent, "UIPanelButtonTemplate")
			f.menuTarget = self
			f.command = self.command
			f.category = self.category
			f.index = self.index
			f.prevKey = nil

			f:SetSize(80, 22)
			f:SetText("SkuMenuBindControlFrame")
			f:SetPoint("LEFT", UIParent, "RIGHT", 1500, 0)
			f:SetPoint("CENTER")
			f:SetScript("OnClick", function(self, aKey, aB)
				--dprint(aKey, aB)
				if aKey ~= "ESCAPE" then
					if not self.command or not self.category or not self.menuTarget or not self.index then return end
					for z = 1, #tBlockedKeysParts do
						if string.find(aKey, tBlockedKeysParts[z]) or string.find(string.lower(aKey), string.lower(tBlockedKeysParts[z])) then 
							SkuMenu.Voice:OutputStringBTtts(L["Ungültig. Andere Taste drücken."], true, true, 0.2, true, nil, nil, 2)
							self.prevKey = nil
							return 
						end
					end

					for z = 1, #tBlockedKeysBinds do
						if aKey == tBlockedKeysBinds[z] or string.lower(aKey) == string.lower(tBlockedKeysBinds[z]) then 
							SkuMenu.Voice:OutputStringBTtts(L["Ungültig. Andere Taste drücken."], true, true, 0.2, true, nil, nil, 2)
							return
						end
					end

					local tCommand = SkuMenu:CheckBound(aKey)
					local bindingConst = SkuMenu:SkuKeyBindsCheckBound(aKey)
					if tCommand or bindingConst then
						if not self.prevKey or self.prevKey ~= aKey then
							self.prevKey = aKey
							if bindingConst then
								SkuMenu.Voice:OutputStringBTtts(L["Warning! That key is already bound to"].." "..L[bindingConst]..L[". Press the key again to confirm new binding. The current bound action will be unbound!"], true, true, 0.2, true, nil, nil, 2)
							elseif tCommand then
								SkuMenu.Voice:OutputStringBTtts(L["Warning! That key is already bound to"].." ".._G["BINDING_NAME_"..tCommand]..L[". Press the key again to confirm new binding. The current bound action will be unbound!"], true, true, 0.2, true, nil, nil, 2)
							end
							return 
						end
					end

					if tCommand or bindingConst and self.prevKey == aKey then
						if bindingConst then
							SkuMenu:SkuKeyBindsDeleteBinding(bindingConst)
						elseif tCommand then
							SkuMenu:DeleteBinding(tCommand)
						end
					end
					
					SkuMenu:SetBinding(aKey, self.command)
					
					local tCommand, tCategory, tKey1, tKey2 = GetBinding(self.index, GetCurrentBindingSet())
					local aFriendlyKey1, tFriendlyKey2 = tKey1 or L["nichts"], tKey2 or L["nichts"]
					for kLocKey, vLocKey in pairs(SkuMenu.Keys.LocNames) do
						aFriendlyKey1 = gsub(aFriendlyKey1, kLocKey, vLocKey)
						tFriendlyKey2 = gsub(tFriendlyKey2, kLocKey, vLocKey)
					end				
					if tCommand or bindingConst then
						_G["OnSkuMenuMainOption1"]:GetScript("OnClick")(_G["OnSkuMenuMainOption1"], "LEFT")
					else
						self.menuTarget.name = _G["BINDING_NAME_" .. tCommand]..L[" Taste 1: "]..(aFriendlyKey1)..L[" Taste 2: "]..(tFriendlyKey2)
						_G["OnSkuMenuMainOption1"]:GetScript("OnClick")(_G["OnSkuMenuMainOption1"], "RIGHT")
						_G["OnSkuMenuMainOption1"]:GetScript("OnClick")(_G["OnSkuMenuMainOption1"], "LEFT")
					end
					SkuMenu.Voice:OutputStringBTtts(L["New key"]..";"..aFriendlyKey1, true, true, 0.2, true, nil, nil, 2)
				elseif aKey == "ESCAPE" then
					SkuMenu.Voice:OutputStringBTtts(L["Binding canceled"], true, true, 0.2, true, nil, nil, 2)
				end
				ClearOverrideBindings(self)
				SkuMenu.bindingMode = nil
			end)
			SetOverrideBindingClick(f, true, "ESCAPE", "SkuMenuBindControlFrame", "ESCAPE")

			for i, v in pairs(_G) do 
				if string.find(i, "KEY_") == 1 then 
					if not string.find(i, "ESC") then
						for x = 1, #tModifierKeys do
							SetOverrideBindingClick(f, true, tModifierKeys[x]..string.sub(i, 5), "SkuMenuBindControlFrame", tModifierKeys[x]..string.sub(i, 5))
						end
					end
				end 
			end

			for x = 1, #tStandardChars do
				for y = 1, #tModifierKeys do
					SetOverrideBindingClick(f, true, tModifierKeys[y]..tStandardChars[x], "SkuMenuBindControlFrame", tModifierKeys[y]..tStandardChars[x])
				end
			end
			for x = 1, #tStandardNumbers do
				for y = 1, #tModifierKeys do
					SetOverrideBindingClick(f, true, tModifierKeys[y]..tStandardNumbers[x], "SkuMenuBindControlFrame", tModifierKeys[y]..tStandardNumbers[x])
				end
			end
		end)											
	elseif aName == L["Belegung löschen"] then
		if not self.command or not self.category or not self.index then return end
		SkuMenu:DeleteBinding(self.command)
		local tCommand, tCategory, tKey1, tKey2 = GetBinding(self.index, GetCurrentBindingSet())
		local aFriendlyKey1, tFriendlyKey2
		self.name = _G["BINDING_NAME_" .. tCommand]..L[" Taste 1: "]..(aFriendlyKey1 or L["nichts"])..L[" Taste 2: "]..(tFriendlyKey2 or L["nichts"])
		_G["OnSkuMenuMainOption1"]:GetScript("OnClick")(_G["OnSkuMenuMainOption1"], "RIGHT")
		_G["OnSkuMenuMainOption1"]:GetScript("OnClick")(_G["OnSkuMenuMainOption1"], "LEFT")
		SkuMenu.Voice:OutputStringBTtts(L["Belegung gelöscht"], true, true, 0.2)						
	end					
end

---------------------------------------------------------------------------------------------------------------------------------------
local function BindingHelper(aCurrentMenuEntry, aType, aButtonId, aParentEntry, aActionBarName, aBooktypeOrObjId)
	SkuMenu.Voice:OutputStringBTtts(L["Press new key or Escape to cancel"], true, true, 0.2)						
	local f = _G["SkuMenuBindControlFrame"] or CreateFrame("Button", "SkuMenuBindControlFrame", UIParent, "UIPanelButtonTemplate")
	f.menuTarget = aCurrentMenuEntry
	f:SetSize(80, 22)
	f:SetText("SkuMenuBindControlFrame")
	f:SetPoint("LEFT", UIParent, "RIGHT", 1500, 0)
	f:SetPoint("CENTER")
	f:SetScript("OnClick", function(self, aKey, aB)
		--dprint(aKey, aB)
		SkuMenu.bindingMode = nil

		for z = 1, #tBlockedKeysParts do
			if string.find(aKey, tBlockedKeysParts[z]) or string.find(string.lower(aKey), string.lower(tBlockedKeysParts[z])) then 
				SkuMenu.Voice:OutputStringBTtts(L["Ungültig. Andere Taste drücken."], true, true, 0.2, true, nil, nil, 2)
				return
			end
		end

		for z = 1, #tBlockedKeysBinds do
			if aKey == tBlockedKeysBinds[z] or string.lower(aKey) == string.lower(tBlockedKeysBinds[z]) then 
				SkuMenu.Voice:OutputStringBTtts(L["Ungültig. Andere Taste drücken."], true, true, 0.2, true, nil, nil, 2)
				return
			end
		end

		if aKey ~= "ESCAPE" then
			SetBinding(aKey)
			local key1, key2 = GetBindingKey(tActionBarData[aActionBarName].command..aButtonId)
			if key1 then SetBinding(key1) end
			if key2 then SetBinding(key2) end
			local ok = SetBinding(aKey , tActionBarData[aActionBarName].command..aButtonId)
			SaveBindings(GetCurrentBindingSet())

			if aType == "player" then
				local actionType, id, subType = GetActionInfo(self.menuTarget.buttonObj.action)
				self.menuTarget.name = L["Button"].." "..aButtonId..";"..ButtonContentNameHelper(actionType, id, subType, aActionBarName, aButtonId)
			elseif aType == "pet" then
				self.menuTarget.name = L["Button"].." "..aButtonId..";"..ButtonContentNameHelper("pet", aBooktypeOrObjId, subType, aActionBarName, aBooktypeOrObjId)
			end

			_G["OnSkuMenuMainOption1"]:GetScript("OnClick")(_G["OnSkuMenuMainOption1"], "RIGHT")
			_G["OnSkuMenuMainOption1"]:GetScript("OnClick")(_G["OnSkuMenuMainOption1"], "LEFT")
			SkuMenu.Voice:OutputStringBTtts(L["New key"]..";"..aKey, true, true, 0.2)						
		else
			SkuMenu.Voice:OutputStringBTtts(L["Binding canceled"], true, true, 0.2)						
		end
		ClearOverrideBindings(self)
	end)
	SetOverrideBindingClick(f, true, "ESCAPE", "SkuMenuBindControlFrame", "ESCAPE")

	for i, v in pairs(_G) do 
		if string.find(i, "KEY_") == 1 then 
			if not string.find(i, "ESC") then
				--dprint(i, v, string.find(i, "KEY_"), string.sub(i, 5))
				for x = 1, #tModifierKeys do
					SetOverrideBindingClick(f, true, tModifierKeys[x]..string.sub(i, 5), "SkuMenuBindControlFrame", tModifierKeys[x]..string.sub(i, 5))
				end
			end
		end 
	end

	for x = 1, #tStandardChars do
		for y = 1, #tModifierKeys do
			SetOverrideBindingClick(f, true, tModifierKeys[y]..tStandardChars[x], "SkuMenuBindControlFrame", tModifierKeys[y]..tStandardChars[x])
		end
	end
	for x = 1, #tStandardNumbers do
		for y = 1, #tModifierKeys do
			SetOverrideBindingClick(f, true, tModifierKeys[y]..tStandardNumbers[x], "SkuMenuBindControlFrame", tModifierKeys[y]..tStandardNumbers[x])
		end
	end
end


--------------------------------------------------------------------------------------------------------------------------------------
function SkuMenu:MenuBuilder(aParentEntry)
	--local tNewMenuEntry =  SkuMenu:InjectMenuItems(aParentEntry, {"Menu Options"}, SkuGenericMenuItem)
	--tNewMenuEntry.filterable = true


	SkuMenu:IterateOptionsArgs(SkuMenu.options.args, aParentEntry, SkuMenu.db.profile[MODULE_NAME])





	local tNewMenuParentEntry =  SkuMenu:InjectMenuItems(aParentEntry, {L["Key Binds"]}, SkuGenericMenuItem)
	tNewMenuParentEntry.dynamic = true
	tNewMenuParentEntry.BuildChildren = function(self)
		local tNewMenuEntry = SkuMenu:InjectMenuItems(self, {L["Taste zuweisen"]}, SkuGenericMenuItem)
		tNewMenuEntry.dynamic = true
		tNewMenuEntry.filterable = true
		tNewMenuEntry.BuildChildren = function(self)
			--remove outdated and delete key bindings
			for i, v in pairs(SkuMenu.db.profile["SkuMenu"].SkuKeyBinds) do
				if not SkuMenu.skuDefaultKeyBindings[i] then
					SkuMenu.db.profile["SkuMenu"].SkuKeyBinds[i] = nil
				end
			end

			--sort
			local tSortedList = {}
			for k, v in SkuSpairs(SkuMenu.db.profile["SkuMenu"].SkuKeyBinds, function(t,a,b) 
				return L[b] > L[a] end) do
				tSortedList[#tSortedList+1] = k
			end

			--build list
			for _, tBindingConst in pairs(tSortedList) do
				local v = SkuMenu.db.profile["SkuMenu"].SkuKeyBinds[tBindingConst]
				local tFriendlyKey1
				if v.key == "" then
					tFriendlyKey1 = L["nichts"]
				else
					tFriendlyKey1 = v.key or L["nichts"]
				end
				for kLocKey, vLocKey in pairs(SkuMenu.Keys.LocNames) do
					tFriendlyKey1 = gsub(tFriendlyKey1, kLocKey, vLocKey)
				end
				if tFriendlyKey1 == "-" then
					tFriendlyKey1 = L["Minus"]
				else
					tFriendlyKey1 = gsub(tFriendlyKey1, "%-%-", "-"..L["Minus"])
				end

				local tNewMenuEntryKey = SkuMenu:InjectMenuItems(self, {L[tBindingConst].." "..L["Taste"]..":"..(tFriendlyKey1 or L["nichts"])}, SkuGenericMenuItem)
				tNewMenuEntryKey.isSelect = true
				tNewMenuEntryKey.dynamic = true
				tNewMenuEntryKey.OnAction = function(self, aValue, aName)
					dprint("Taste zuweisen OnAction", aValue, aName, self.name)
					if aName == L["fixed"] then
						return
					end
					if aName == L["Neu belegen"] then
						SkuMenu.bindingMode = true

						C_Timer.After(0.001, function()
							SkuMenu.Voice:OutputStringBTtts(L["Press new key or Escape to cancel"], true, true, 0.2, true, nil, nil, 2)

							local f = _G["SkuMenuBindControlFrame"] or CreateFrame("Button", "SkuMenuBindControlFrame", UIParent, "UIPanelButtonTemplate")
							f.menuTarget = self
							f.bindingConst = self.bindingConst
							f.prevKey = nil
		
							f:SetSize(80, 22)
							f:SetText("SkuMenuBindControlFrame")
							f:SetPoint("LEFT", UIParent, "RIGHT", 1500, 0)
							f:SetPoint("CENTER")
							f:SetScript("OnClick", function(self, aKey, aB)
								dprint("SkuMenuBindControlFrame OnClick", aKey, aB)
								if aKey ~= "ESCAPE" then
									if not self.bindingConst or not self.menuTarget then return end
									for z = 1, #tBlockedKeysParts do
										if string.find(aKey, tBlockedKeysParts[z]) or string.find(string.lower(aKey), string.lower(tBlockedKeysParts[z])) then 
											SkuMenu.Voice:OutputStringBTtts(L["Ungültig. Andere Taste drücken."], true, true, 0.2, true, nil, nil, 2)
											self.prevKey = nil
											return 
										end
									end
									for z = 1, #tBlockedKeysBinds do
										if aKey == tBlockedKeysBinds[z] or string.lower(aKey) == string.lower(tBlockedKeysBinds[z]) then 
											SkuMenu.Voice:OutputStringBTtts(L["Ungültig. Andere Taste drücken."], true, true, 0.2, true, nil, nil, 2)
											return
										end
									end

									dprint(self.bindingConst, self.menuTarget, self.menuTarget.name, self.prevKey)

									local tCommand = SkuMenu:CheckBound(aKey)
									local bindingConst = SkuMenu:SkuKeyBindsCheckBound(aKey)
									if tCommand or bindingConst then
										if not self.prevKey or self.prevKey ~= aKey then
											self.prevKey = aKey
											if bindingConst then
												SkuMenu.Voice:OutputStringBTtts(L["Warning! That key is already bound to"].." "..L[bindingConst]..L[". Press the key again to confirm new binding. The current bound action will be unbound!"], true, true, 0.2, true, nil, nil, 2)
											elseif tCommand then
												SkuMenu.Voice:OutputStringBTtts(L["Warning! That key is already bound to"].." ".._G["BINDING_NAME_"..tCommand]..L[". Press the key again to confirm new binding. The current bound action will be unbound!"], true, true, 0.2, true, nil, nil, 2)
											end
											return 
										end
									end

									if tCommand or bindingConst and self.prevKey == aKey then
										if bindingConst then
											SkuMenu:SkuKeyBindsDeleteBinding(bindingConst)
										elseif tCommand then
											SkuMenu:DeleteBinding(tCommand)
										end
									end

									SkuMenu:SkuKeyBindsSetBinding(self.bindingConst, aKey)
									
									local tKey1 = SkuMenu:SkuKeyBindsGetBinding(self.bindingConst)
									local tFriendlyKey1 = tKey1 or L["nichts"]
									for kLocKey, vLocKey in pairs(SkuMenu.Keys.LocNames) do
										tFriendlyKey1 = gsub(tFriendlyKey1, kLocKey, vLocKey)
									end							
									if tCommand or bindingConst then
										_G["OnSkuMenuMainOption1"]:GetScript("OnClick")(_G["OnSkuMenuMainOption1"], "LEFT")
									else
										self.menuTarget.name = L[self.bindingConst].." "..L["Taste"]..":"..(tFriendlyKey1 or L["nichts"]) --_G["BINDING_NAME_" .. tCommand]..L[" Taste 1: "]..(tFriendlyKey1)..L[" Taste 2: "]..(tFriendlyKey2)
										_G["OnSkuMenuMainOption1"]:GetScript("OnClick")(_G["OnSkuMenuMainOption1"], "RIGHT")
										_G["OnSkuMenuMainOption1"]:GetScript("OnClick")(_G["OnSkuMenuMainOption1"], "LEFT")
									end
									SkuMenu.Voice:OutputStringBTtts(L["New key"]..";"..tFriendlyKey1, true, true, 0.2, true, nil, nil, 2)
								elseif aKey == "ESCAPE" then
									self.prevKey = nil
									SkuMenu.Voice:OutputStringBTtts(L["Binding canceled"], true, true, 0.2, true, nil, nil, 2)
								end
								ClearOverrideBindings(self)
								SkuMenu.bindingMode = nil
							end)
							SetOverrideBindingClick(f, true, "ESCAPE", "SkuMenuBindControlFrame", "ESCAPE")
		
							for i, v in pairs(_G) do 
								if string.find(i, "KEY_") == 1 then 
									if not string.find(i, "ESC") then
										for x = 1, #tModifierKeys do
											SetOverrideBindingClick(f, true, tModifierKeys[x]..string.sub(i, 5), "SkuMenuBindControlFrame", tModifierKeys[x]..string.sub(i, 5))
										end
									end
								end 
							end
		
							for x = 1, #tStandardChars do
								for y = 1, #tModifierKeys do
									SetOverrideBindingClick(f, true, tModifierKeys[y]..tStandardChars[x], "SkuMenuBindControlFrame", tModifierKeys[y]..tStandardChars[x])
								end
							end
							for x = 1, #tStandardNumbers do
								for y = 1, #tModifierKeys do
									SetOverrideBindingClick(f, true, tModifierKeys[y]..tStandardNumbers[x], "SkuMenuBindControlFrame", tModifierKeys[y]..tStandardNumbers[x])
								end
							end
						end)											
					elseif aName == L["Belegung löschen"] then
						if not self.bindingConst then return end
						SkuMenu:SkuKeyBindsDeleteBinding(self.bindingConst)
						local tKey1 = SkuMenu:SkuKeyBindsGetBinding(self.bindingConst)
						local tFriendlyKey1
						self.name = L[self.bindingConst].." "..L["Taste"]..":"..(tFriendlyKey1 or L["nichts"]) 
						_G["OnSkuMenuMainOption1"]:GetScript("OnClick")(_G["OnSkuMenuMainOption1"], "RIGHT")
						_G["OnSkuMenuMainOption1"]:GetScript("OnClick")(_G["OnSkuMenuMainOption1"], "LEFT")
						SkuMenu.Voice:OutputStringBTtts(L["Belegung gelöscht"], true, true, 0.2)						
					end					
				end
				tNewMenuEntryKey.bindingConst = tBindingConst
				--tNewMenuEntryKey.category = categoryConst2
				--tNewMenuEntryKey.index = v1.index
				
				tNewMenuEntryKey.BuildChildren = function(self)
					local tNewMenuEntryKeyAction = SkuMenu:InjectMenuItems(self, {L["Neu belegen"]}, SkuGenericMenuItem)
					local tNewMenuEntryKeyAction = SkuMenu:InjectMenuItems(self, {L["Belegung löschen"]}, SkuGenericMenuItem)
				end
			end
		end
	end






	local tNewMenuParentEntry =  SkuMenu:InjectMenuItems(aParentEntry, {L["Profil"]}, SkuGenericMenuItem)
	local tNewMenuSubEntry =SkuMenu:InjectMenuItems(tNewMenuParentEntry, {L["Auswählen"]}, SkuGenericMenuItem)
	tNewMenuSubEntry.dynamic = true
	tNewMenuSubEntry.isSelect = true
	tNewMenuSubEntry.OnAction = function(self, aValue, aName)
		SkuMenu.db:SetProfile(aName)
		
	end
	tNewMenuSubEntry.BuildChildren = function(self)
		local tList = SkuMenu.db:GetProfiles()
		local tNewMenuEntry = SkuMenu:InjectMenuItems(self, tList, SkuGenericMenuItem)
	end
	tNewMenuSubEntry.GetCurrentValue = function(self, aValue, aName)
		return SkuMenu.db:GetCurrentProfile()
	end

	local tNewMenuSubEntry =SkuMenu:InjectMenuItems(tNewMenuParentEntry, {L["New"]}, SkuGenericMenuItem)
	tNewMenuSubEntry.dynamic = false
	tNewMenuSubEntry.isSelect = true
	tNewMenuSubEntry.OnAction = function(self, aValue, aName)
		SkuMenu:EditBoxShow(
			"",
			function(self)
				local tText = SkuMenuEditBoxEditBox:GetText()
				if tText and tText ~= "" then
					for i, v in pairs(SkuMenu.db:GetProfiles()) do
						if v == tText then
							C_Timer.After(0.1, function()
								SkuMenu.Voice:OutputStringBTtts(L["name already taken"], true, true, 1, true)
							end)
							return
						end
					end
					SkuMenu.db:SetProfile(tText)
				end
			end,
			nil
		)
		C_Timer.After(0.1, function()
			SkuMenu.Voice:OutputStringBTtts(L["enter profile name now"], true, true, 1, true)
		end)
	end

	local tNewMenuSubEntry =SkuMenu:InjectMenuItems(tNewMenuParentEntry, {L["Kopieren von"]}, SkuGenericMenuItem)
	tNewMenuSubEntry.dynamic = true
	tNewMenuSubEntry.isSelect = true
	tNewMenuSubEntry.OnAction = function(self, aValue, aName)
		SkuMenu.db:CopyProfile(aName, true)
	end
	tNewMenuSubEntry.BuildChildren = function(self)
		local tList = SkuMenu.db:GetProfiles()
		local tNewMenuEntry = SkuMenu:InjectMenuItems(self, tList, SkuGenericMenuItem)
	end
	tNewMenuSubEntry.GetCurrentValue = function(self, aValue, aName)
		return SkuMenu.db:GetCurrentProfile()
	end

	local tNewMenuSubEntry =SkuMenu:InjectMenuItems(tNewMenuParentEntry, {"Löschen"}, SkuGenericMenuItem)
	tNewMenuSubEntry.dynamic = true
	tNewMenuSubEntry.isSelect = true
	tNewMenuSubEntry.OnAction = function(self, aValue, aName)
		SkuMenu.db:DeleteProfile(aName, silent)
	end
	tNewMenuSubEntry.BuildChildren = function(self)
		local tList = SkuMenu.db:GetProfiles()
		local tClean = {}
		for i, v in pairs(tList) do
			if v ~= SkuMenu.db:GetCurrentProfile() then
				table.insert(tClean, v)
			end
		end
		local tNewMenuEntry = SkuMenu:InjectMenuItems(self, tClean, SkuGenericMenuItem)
	end
	
	local tNewMenuSubEntry =SkuMenu:InjectMenuItems(tNewMenuParentEntry, {L["Zurücksetzen"]}, SkuGenericMenuItem)
	tNewMenuSubEntry.dynamic = true
	tNewMenuSubEntry.OnAction = function(self, aValue, aName)
		SkuMenu.db:ResetProfile()
		SkuMenu:OnProfileReset()
	end


end
