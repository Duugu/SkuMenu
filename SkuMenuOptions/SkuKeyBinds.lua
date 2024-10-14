---------------------------------------------------------------------------------------------------------------------------------------
local MODULE_NAME, MODULE_PART = "SkuMenu", "SkuKeyBinds"  
local L = SkuMenu.L

SkuMenu = SkuMenu or LibStub("AceAddon-3.0"):NewAddon("SkuMenu", "AceConsole-3.0", "AceEvent-3.0")

SkuMenu.skuDefaultKeyBindings = {
   
   ["SKU_KEY_OPENMENU"] = {key = "SHIFT-F1", object = "SkuMenu", func = "CreateMainFrame",},
   ["SKU_KEY_STOPTTSOUTPUT"] = {key = "CTRL-V", object = "SkuMenu", func = "CreateMainFrame",},
   ["SKU_KEY_DOMONITORPARTYHEALTH2CONTI"] = {key = "", object = "SkuCoreControlOption1", func = "OnHide",},
   ["SKU_KEY_ENABLEPARTYRAIDHEALTHMONITOR"] = {key = "", object = "SkuMenu", func = "CreateMainFrame",},
   ["SKU_KEY_GROUPMEMBERSRANGECHECK"] = {key = "", object = "SkuMenu", func = "CreateMainFrame",},
   ["SKU_KEY_COMBATMONSETFOLLOWTARGET"] = {key = "", object = "SkuMenu", func = "CreateMainFrame",},
   ["SKU_KEY_COMBATMONOUTPUTNUMBERINCOMBAT"] = {key = "", object = "SkuMenu", func = "CreateMainFrame",},

}


---------------------------------------------------------------------------------------------------------------------------------------
function SkuMenu:SkuKeyBindsResetBindings()
   SkuMenu.db.profile["SkuMenu"].SkuKeyBinds = {}
   SkuMenu:SkuKeyBindsUpdate()
end

---------------------------------------------------------------------------------------------------------------------------------------
function SkuMenu:SkuKeyBindsGetBinding(aBindingConst)
   return SkuMenu.db.profile[MODULE_NAME].SkuKeyBinds[aBindingConst].key
end

---------------------------------------------------------------------------------------------------------------------------------------
function SkuMenu:SkuKeyBindsSetBinding(aBindingConst, aNewKey)
   if not SkuMenu.db.profile["SkuMenu"].SkuKeyBinds[aBindingConst] then
      return
   end
   SkuMenu.db.profile["SkuMenu"].SkuKeyBinds[aBindingConst].key = aNewKey
   SkuMenu:SkuKeyBindsUpdate()
   return true
end

---------------------------------------------------------------------------------------------------------------------------------------
function SkuMenu:SkuKeyBindsDeleteBinding(aBindingConst)
   dprint("SkuKeyBindsDeleteBinding", aBindingConst)
   if not SkuMenu.db.profile["SkuMenu"].SkuKeyBinds[aBindingConst] then
      return
   end
   SkuMenu.db.profile["SkuMenu"].SkuKeyBinds[aBindingConst].key = ""
   SkuMenu:SkuKeyBindsUpdate()
   return true
end

---------------------------------------------------------------------------------------------------------------------------------------
function SkuMenu:SkuKeyBindsCheckBound(aKey)
   for i, v in pairs(SkuMenu.skuDefaultKeyBindings) do
      if SkuMenu.db.profile["SkuMenu"].SkuKeyBinds[i] then
         if SkuMenu.db.profile["SkuMenu"].SkuKeyBinds[i].key == aKey then
            return i
         end
      end
   end
end

---------------------------------------------------------------------------------------------------------------------------------------
function SkuMenu:SkuKeyBindsUpdate(aInitializeFlag)
   SkuMenu.db.profile["SkuMenu"] = SkuMenu.db.profile["SkuMenu"] or {}

   --default settings if no data
   if not SkuMenu.db.profile["SkuMenu"].SkuKeyBinds then
      SkuMenu.db.profile["SkuMenu"].SkuKeyBinds = {}
   end
   for i, v in pairs(SkuMenu.skuDefaultKeyBindings) do
      if not SkuMenu.db.profile["SkuMenu"].SkuKeyBinds[i] then
         SkuMenu.db.profile["SkuMenu"].SkuKeyBinds[i] = {key = v.key or ""}
         dprint("set default", i, v)
      end
   end

   --update all override bindings
   if not aInitializeFlag then
      local tDone = {}   
      for i, v in pairs(SkuMenu.skuDefaultKeyBindings) do
         if not tDone[i..v.object..(v.func or v.script)] then
            tDone[i..v.object..(v.func or v.script)] = true
            if _G[v.object] then
               if v.func then
                  if _G[v.object][v.func] then
                     dprint("calling ", v.object, v.func, _G[v.object][v.func])
                     _G[v.object][v.func](_G[v.object])
                  else
                     dprint("nil func", v.func)
                  end
               elseif v.script then
                  if _G[v.object]:GetScript(v.script) then
                     dprint("calling ", v.object, v.script, _G[v.object]:GetScript(v.script))
                     _G[v.object]:GetScript(v.script)(_G[v.object])
                  else
                     dprint("nil func", v.func)
                  end
               end
            else
               dprint("  ", "nil object", v.object)
            end
         end
      end
   end
end