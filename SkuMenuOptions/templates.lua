local _G = _G

SkuMenu = SkuMenu or LibStub("AceAddon-3.0"):NewAddon("SkuMenu", "AceConsole-3.0", "AceEvent-3.0")
local L = SkuMenu.L

local MENU_MENU = 1
local MENU_DROPDOWN = 2
local MENU_DROPDOWN_MULTI = 3

SkuMenu.MenuMT = {
	__add = function(thisTable, newTable)
		local function TableCopy(t, deep, seen)
			seen = seen or {}
			if t == nil then return nil end
			if seen[t] then return seen[t] end
			local nt = {}
			for k, v in pairs(t) do
				if type(v) ~= "userdata" and k ~= "frame" and k ~= 0  then
					if deep and type(v) == 'table' then
						nt[k] = TableCopy(v, deep, seen)
					else
						nt[k] = v
					end
				end
			end
			--setmetatable(nt, getmetatable(t), deep, seen))
			seen[t] = nt
			return nt
		end
		local seen = {}
		local tTable = TableCopy(newTable, true, seen)
		table.insert(thisTable, tTable)
		return thisTable
	end,
	__tostring = function(thisTable)
		local tStr = ""
		local function tf(ttable, tTab)
			for k, v in pairs(ttable) do
				if k ~= "parent" and v ~= "parent" and k ~= "prev" and v ~= "prev" and k ~= "next" and v ~= "next"  then
					if type(v) ~= "userdata" and k ~= "frame" and k ~= 0  then
						if type(v) == 'table' then
							print(tTab..k..": tab")
							tf(v, tTab.."  ")
						elseif type(v) == "function" then
							--dprint(tTab..k..": function")
						elseif type(v) == "boolean" then
							print(tTab..k..": "..tostring(v))
						else
							print(tTab..k..": "..v)
						end
					end
				end
			end
		end
		tf(thisTable, "")
	end,
	}

local tPrevErrorUtterance
local tCurrentErrorUtteranceTimerHandle
SkuGenericMenuItem = {
	name = "SkuGenericMenuItem name",
	type = MENU_MENU,
	parent = nil,
	children = {},
	prev = nil,
	next = nil,
	isSelect = false,
	isMultiselect = false,
	selectTarget = nil,
	dynamic = false,
	filterable = false,
	OnUpdate = function(self, aKey)
		C_Timer.After(0.01, function()
			dprint("++ OnUpdate generic")
			local tCurrentItemNumber
			local tCurrentItemName = self.name
			local tParent = self.parent

			if not self.parent then
				return
			end
			if not self.parent.children then
				return
			end

			local tMenuItems = self.parent.children
			for x = 1, #tMenuItems do
				if tMenuItems[x].name == tCurrentItemName then
					tCurrentItemNumber = x
				end
			end

			tCurrentItemNumber = tCurrentItemNumber or 1
			
			self.parent.children = {}
			
			tParent:BuildChildren(self.parent)

			tParent:OnSelect()
			if self.parent.children[tCurrentItemNumber] then
				SkuMenu.currentMenuPosition = self.parent.children[tCurrentItemNumber]
			elseif self.parent.children[tCurrentItemNumber - 1] then
				SkuMenu.currentMenuPosition = self.parent.children[tCurrentItemNumber - 1]
			else
				SkuMenu.currentMenuPosition = self.parent.children[1]
			end

			SkuMenu.currentMenuPosition:OnEnter()

			if SkuMenu.TTS.MainFrame:IsVisible() ~= true then
				SkuMenu:VocalizeCurrentMenuName()
			end
		end)
	end,
	OnKey = function(self, aKey)
		if SkuMenu.bindingMode == true then
			return
		end
		dprint("OnKey", aKey, SkuMenu.bindingMode)
		SkuMenu.currentMenuPosition:OnLeave(self, value, aValue)

		local tNewMenuItem = nil
		local tMenuItems = nil
		if self.parent.name then
			tMenuItems = self.parent.children
		else
			tMenuItems = self.parent
		end
		
		if SkuMenu.MenuAccessKeysChars[aKey] then
			for x= 1, #tMenuItems do
				if not tNewMenuItem then
					if string.lower(string.sub(tMenuItems[x].name, 1, 1)) == string.lower(aKey) then
						tNewMenuItem = tMenuItems[x]
					end
				end
			end
		elseif SkuMenu.MenuAccessKeysNumbers[aKey] then
			if not tNewMenuItem then
				aKey = tonumber(aKey)
				if tMenuItems[aKey] then
					tNewMenuItem = tMenuItems[aKey]
				end
			end
		end
		if tNewMenuItem then
			SkuMenu.currentMenuPosition = tNewMenuItem
		end
		SkuMenu.currentMenuPosition:OnEnter()
	end,
	BuildChildren = function(self)
		--dprint("BuildChildren generic", self.name)
	end,
	OnPrev = function(self)
		--dprint("OnPrev generic", self.name)
		SkuMenu.currentMenuPosition:OnLeave(self, value, aValue)

		if self.prev then
			SkuMenu.currentMenuPosition = self.prev
		else
			PlaySound(681)
		end
		SkuMenu.currentMenuPosition:OnEnter()

		C_Timer.After(0.01, function()
			local tIndexString, tBreadString = SkuMenu:GetMenuIndexAndBreadString(SkuMenu.currentMenuPosition)
			SkuDispatcher:TriggerSkuEvent("SKU_SLASH_MENU_ITEM_SELECTED", tIndexString, tBreadString)
		end)

	end,
	OnNext = function(self)
		--print("OnNext generic", self.name)
		SkuMenu.currentMenuPosition:OnLeave(self, value, aValue)

		if self.next then
			SkuMenu.currentMenuPosition = self.next
		else
			PlaySound(681)
		end
		SkuMenu.currentMenuPosition:OnEnter()

		C_Timer.After(0.01, function()
			local tIndexString, tBreadString = SkuMenu:GetMenuIndexAndBreadString(SkuMenu.currentMenuPosition)
			SkuDispatcher:TriggerSkuEvent("SKU_SLASH_MENU_ITEM_SELECTED", tIndexString, tBreadString)
		end)		
	end,
	OnFirst = function(self)
		--dprint("OnFirst generic", self.name)
		SkuMenu.currentMenuPosition:OnLeave(self, value, aValue)

		if self.parent then
			if self.parent.children then
				SkuMenu.currentMenuPosition = self.parent.children[1]
			else 
				SkuMenu.currentMenuPosition = self.parent[1]
			end
		end
		SkuMenu.currentMenuPosition:OnEnter()
	end,
	OnLast = function(self)
		--dprint("OnLast generic", self.name)
		SkuMenu.currentMenuPosition:OnLeave(self, value, aValue)

		if self.parent then
			if self.parent.children then
				SkuMenu.currentMenuPosition = self.parent.children[#self.parent.children]
			else 
				SkuMenu.currentMenuPosition = self.parent[1]
			end
		end
		SkuMenu.currentMenuPosition:OnEnter()
	end,
	OnBack = function(self)
		--dprint("OnBack generic", self.name, self.parent.name)
		SkuMenu.currentMenuPosition:OnLeave(self, value, aValue)

		if self.parent.name then
			SkuMenu.currentMenuPosition = self.parent
		else
			--dprint("main level > leave nav")
			_G["OnSkuMenuMain"]:GetScript("OnClick")(_G["OnSkuMenuMain"])
		end
		SkuMenu.currentMenuPosition:OnEnter()
	end,
	OnAction = function(self, value, aValue)
		--print("OnAction generic", self.name, value.name, value, aValue)
	end,
	OnLeave = function(self, value, aValue)
		--print("OnLeave generic", self.name, value, aValue)
		if tCurrentErrorUtteranceTimerHandle then
			tCurrentErrorUtteranceTimerHandle:Cancel()
		end
	end,
	OnEnter = function(self, value, aValue)
		--print("OnEnter generic", self.name, value, aValue)

		--if SkuCore.inCombat ~= true then
			if self.macrotext then
				--dprint("macrotext", self.macrotext)
				if _G["SecureOnSkuMenuMainOption1"] then
					_G["SecureOnSkuMenuMainOption1"]:SetAttribute("type","macro")
					_G["SecureOnSkuMenuMainOption1"]:SetAttribute("macrotext", self.macrotext)
				end
			else
				if _G["SecureOnSkuMenuMainOption1"] then
					_G["SecureOnSkuMenuMainOption1"]:SetAttribute("type","")
					_G["SecureOnSkuMenuMainOption1"]:SetAttribute("macrotext","")
				end
			end
		--end
	end,
	OnSelect = function(self, aEnterFlag)
		--print("OnSelect generic", self.name, aEnterFlag, self.isSelect, self.isMultiselect, self.dynamic)
		local spellID
		local itemID
		local macroID

		local tCollectValuesFrom

		if self.selectTarget then
			spellID = self.selectTarget.spellID
			itemID = self.selectTarget.itemID
			macroID = self.selectTarget.macroID

			tCollectValuesFrom = self.selectTarget.collectValuesFrom
		end

		SkuMenu.Filterstring = ""
		SkuMenu:ApplyFilter(SkuMenu.Filterstring)

		if tCollectValuesFrom then
			self.selectTarget.collectValuesFrom = tCollectValuesFrom
		end


		if self.selectTarget then
			--dprint("   ", self.selectTarget.name)
			self.selectTarget.spellID = spellID
			self.selectTarget.itemID = itemID
			self.selectTarget.macroID = macroID
	
		end

		if string.find(self.name, L["Filter"]..";") then
			return
		end

		if self.name == L["Empty;list"] then
			return
		end

		self:OnPostSelect(aEnterFlag)
	end,
	OnPostSelect = function(self, aEnterFlag)
		--print("++ OnPostSelect generic", self.name, self.actionOnEnter, aEnterFlag, self.isSelect, self.isMultiselect, self.dynamic)
		if self.dynamic == true then
			self.children = {}
			if self.isMultiselect == true then
				local tNewMenuEntry = SkuMenu:InjectMenuItems(self, {L["Nothing selected"]}, SkuGenericMenuItem)
				self.selectTarget = tNewMenuEntry
			end
			if self.isSelect == true then
				self.selectTarget = self
			end

			-- we need to free up the memory of the old children before we're re-building; otherwise we'll leak memory on next BuildChildren
			-- we can't do that for multi select menu items now, as we do need to collect the result from the selected sub items first
			if self.isMultiselect ~= true then
				self.children = {}
				--collectgarbage("collect")
			end

			self:BuildChildren(self)
			if self.selectTarget then
				for x = 1, #self.children do
					self.children[x].selectTarget = self.selectTarget
				end
			end		
		end
		if #self.children > 0 and (self.actionOnEnter ~= true or aEnterFlag ~= true) then
			SkuMenu.currentMenuPosition = self.children[1]
			if self.GetCurrentValue then
				local tGetCurrentValue = self:GetCurrentValue()
				for i, v in pairs(self.children) do
					if v.name == tGetCurrentValue then
						SkuMenu.currentMenuPosition = self.children[i]
					end
				end
			end			
		else
			if self.selectTarget and self.selectTarget ~= self then
				if self.selectTarget.parent.isMultiselect == true then
					if self.selectTarget.name == L["Nothing selected"] and (self.name ~= L["Small"] and self.name ~= L["Large"]) then
						self.selectTarget.name = L["Selected"]..";"..self.name
					else
						if self.name ~= L["Small"] and self.name ~= L["Large"] then
							self.selectTarget.name = self.selectTarget.name..";"..self.name
						end
					end
					SkuMenu.currentMenuPosition = self.selectTarget
				end
				if self.selectTarget.isSelect == true then
					if not string.find(self.name, L["Filter"]..";") then
						local rValue = self.name
						if string.sub(rValue, 1, string.len(L["Selected"]..";")) == L["Selected"]..";" then
							rValue = string.sub(rValue,  string.len(L["Selected"]..";") + 1)
						end

						local tUncleanValue = self.name
						local tCleanValue = self.name
						local tPos = string.find(tUncleanValue, "#")
						local tErrorSoundFound = string.find(tUncleanValue, L["error;sound"].."#")
						if tPos and not tErrorSoundFound then
							tCleanValue = string.sub(tUncleanValue,  tPos + 1)
						end

						self.selectTarget:OnAction(self, tCleanValue, self.parent.name)----------------
						-- we need to free up the memory of the old children before we're re-building on next acces of menu item
						-- now it's safe to do that, as multi select menu items are handled with the above OnAction
						self.children = {}
						--collectgarbage("collect")

						SkuMenu.currentMenuPosition = self.selectTarget
					else
						if SkuMenu.TTS.MainFrame:IsVisible() ~= true then
							SkuMenu:VocalizeCurrentMenuName()
						end
				
					end					
				end
			else
				local rValue = self.name
				local tUncleanValue = self.name
				local tCleanValue = self.name
				local tPos = string.find(tUncleanValue, "#")
				if tPos then
					tCleanValue = string.sub(tUncleanValue,  tPos + 1)
				end
				
				if string.sub(rValue, 1, string.len(L["Selected"]..";")) == L["Selected"]..";" then
					rValue = string.sub(rValue,  string.len(L["Selected"]..";") + 1)
				end
				if #self.children > 0 or self.selectTarget == self then
					self.parent:OnAction(self, tCleanValue, self.parent.name)
				else
					self:OnAction(self, tCleanValue, self.parent.name)------------
				end
				-- we need to free up the memory of the old children before we're re-building on next acces of menu item
				-- now it's safe to do that, as multi select menu items are handled with the above OnAction
				self.children = {}
				--collectgarbage("collect")
				SkuMenu.currentMenuPosition = self.parent
			end			
		end

		if SkuMenu.currentMenuPosition.OnEnter then
			SkuMenu.currentMenuPosition:OnEnter(aEnterFlag)
		end
		--if self.removeFilter then
			--SkuMenu.Filterstring = ""
			--SkuMenu:ApplyFilter(SkuMenu.Filterstring)
		--end
	end,
	}
setmetatable(SkuGenericMenuItem, SkuMenu.MenuMT)
