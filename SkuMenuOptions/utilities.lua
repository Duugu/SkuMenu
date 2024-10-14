local MODULE_NAME = "SkuMenu"
local L = SkuMenu.L
local _G = _G

---------------------------------------------------------------------------------------------------------------------------------------
function SkuTableToString(aTable, aCallback)
	local tStr = "{"
	local tPartString = ""
	local tcounterold = 1
	local tcounter = 1	
	local co = coroutine.create(function()	
		local tLocalCounter = 0
		local function tf(ttable, tTab)
			for k, v in pairs(ttable) do
				--print(tLocalCounter, k, v)
				if type(v) == 'table' then
					--print(tTab.."["..k.."] = {")
					tPartString = tPartString.."["..k.."] = {"
					tf(v, tTab.."  ")
					--print(tTab.."},")
					tPartString = tPartString.."},"
				elseif type(v) == "boolean" then
					--print(tTab.."["..k.."] = "..tostring(v)..",")
					tPartString = tPartString.."["..k.."] = "..tostring(v)..","
				elseif type(v) == "string" then
					--print(tTab.."["..k.."] = \""..tostring(v).."\",")
					tPartString = tPartString.."["..k.."] = \""..tostring(v).."\","
				else
					--print(tTab.."["..k.."] = "..v..",")
					tPartString = tPartString.."["..k.."] = "..v..","
				end
			end
			if tLocalCounter > 500 then
				tLocalCounter = 0
				tStr = tStr..tPartString
				tPartString = ""
				--print("part", tcounterold)
				tcounterold = tcounterold + 1
				coroutine.yield()
			end
			--print(tLocalCounter)
			tLocalCounter = tLocalCounter + 1
		end
		tf(aTable, "")
	end)

	local tCoCompleted = false
	local tSkuCoroutineControlFrameOnUpdateTimer = 0
	local tSkuCoroutineControlFrame = _G["SkuCoroutineControlFrame"] or CreateFrame("Frame", "SkuCoroutineControlFrame", UIParent)
	tSkuCoroutineControlFrame:SetPoint("CENTER")
	tSkuCoroutineControlFrame:SetSize(50, 50)
	tSkuCoroutineControlFrame:SetScript("OnUpdate", function(self, time)
		tSkuCoroutineControlFrameOnUpdateTimer = tSkuCoroutineControlFrameOnUpdateTimer + time
		if tSkuCoroutineControlFrameOnUpdateTimer < 0.001 then return end
		if coroutine.status(co) == "suspended" then
			coroutine.resume(co)
			--SkuMenu.Voice:OutputStringBTtts("sound-notification24", false, true)--24
		else
			if tCoCompleted == false then
				tCoCompleted = true
				--print("completed")
				tStr = tStr..tPartString
				aCallback("return "..tStr.."}")
			end
		end
	end)	
end

---------------------------------------------------------------------------------------------------------------------------------------
function SkuStringToTable(aString)
	return assert(loadstring(aString))()
end

---------------------------------------------------------------------------------------------------------------------------------------
function SkuSpairs(t, order)
	local keys = {}
	for k in pairs(t) do keys[#keys+1] = k end
	if order then
		table.sort(keys, function(a,b) return order(t, a, b) end)
	else
		table.sort(keys)
	end
	local i = 0
	return function()
		i = i + 1
		if keys[i] then
			return keys[i], t[keys[i]]
		end
	end
end

---------------------------------------------------------------------------------------------------------------------------------------
---@param tbl table
---@param indent string
local function tprint (tbl, indent)
	if not indent then indent = 0 end
	for k, v in pairs(tbl) do
		local formatting = string.rep("  ", indent)..k..": "
		if k == 'obj' then
			if v ~= nil then
				print(formatting.."<obj>")
			else
				print(formatting.."nil")
			end
		elseif k == 'func' then
			if v ~= nil then
				print(formatting.."<func>")
			else
				print(formatting.."nil")
			end
		elseif k == 'onActionFunc' then
			if v ~= nil then
				print(formatting.."<onActionFunc>")
			else
				print(formatting.."nil")
			end
		else
			if type(v) == "table" then
				print(formatting)
				tprint(v, indent+1)
			elseif type(v) == 'boolean' then
				print(formatting..tostring(v))      
			elseif type(v) == 'string' then
				print(formatting..string.gsub(v, "\r\n", " "))
			else
				print(formatting..v)
			end
		end
	end
end
