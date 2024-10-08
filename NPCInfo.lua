local addonName = ...
local NPCInfo = CreateFrame('frame')
local Settings = {}

-- Compat
local function AddColoredDoubleLine(tooltip, leftT, rightT, leftC, rightC, wrap)
  leftC = leftC or NORMAL_FONT_COLOR
  rightC = rightC or HIGHLIGHT_FONT_COLOR
  wrap = wrap or true
  tooltip:AddDoubleLine(leftT, rightT, leftC.r, leftC.g, leftC.b, rightC.r, rightC.g, rightC.b, wrap);
end

function NPCInfo:OnEvent(e,...)
  if e == "ADDON_LOADED" and ... == addonName then
    NPCInfoDB = NPCInfoDB or {}
    Settings = NPCInfoDB
  end
end

function NPCInfo:ShowInfo(self)
  if Settings.UsingMod and not IsModifierKeyDown() then return end
  local _, unit = self:GetUnit()
  local guid = UnitGUID(unit or "none")
  local unitID = tonumber(guid:sub(-12, -7), 16)
  local playerGUID = tonumber(guid:sub(3), 16)

    if Settings.ShowRawGUID then
      AddColoredDoubleLine(self, "Raw GUID", guid)
    end

    if Settings.ShowNPCID and unitID ~= 0 then
      AddColoredDoubleLine(self, "ID", unitID)
    end

    if Settings.ShowPlayerGUID and UnitIsPlayer(unit) then
      AddColoredDoubleLine(self, "GUID", playerGUID)
    end

    if Settings.ShowPlayerTarget and UnitIsPlayer(unit) then
      local unitTarget = unit .. "target"
      local targetName = UnitName(unitTarget)

      if UnitIsUnit(unitTarget, unit) then
        targetName = "Self"
      elseif UnitIsUnit(unitTarget, "player") then
        targetName = "You"
      end

      if targetName then
        AddColoredDoubleLine(self, "Target", targetName)
      end
    end
end

function NPCInfo:OnLoad()
  self:RegisterEvent("ADDON_LOADED")
  self:SetScript("OnEvent", self.OnEvent)

  GameTooltip:HookScript("OnTooltipSetUnit", function(...) self:ShowInfo(...) end)

  SLASH_NPCINFO1  = "/npcinfo"
  function SlashCmdList.NPCINFO(...)
    self:Help(...)
  end
end

NPCInfo:OnLoad()

local function AddMessage(...) _G.DEFAULT_CHAT_FRAME:AddMessage(strjoin(" ", tostringall(...))) end
function NPCInfo:Help(msg)
  local fName = "|cffEEE4AENPC Info:|r"
  local _, _, cmd, args = string.find(msg, "%s?(%w+)%s?(.*)")
  if not cmd or cmd == "" or cmd == "help" then
    AddMessage(fName.." |cff58C6FA/npcinfo|r")
    AddMessage("  |cff58C6FA/npcinfo id -|r  |cffEEE4AEToggles NPC ID|r")
    AddMessage("  |cff58C6FA/npcinfo playerguid -|r  |cffEEE4AEToggles player GUID|r")
    AddMessage("  |cff58C6FA/npcinfo rawguid -|r  |cffEEE4AEToggles raw GUID|r")
    AddMessage("  |cff58C6FA/npcinfo playertarget -|r  |cffEEE4AEToggles target of player|r")
    AddMessage("  |cff58C6FA/npcinfo mod  -|r  |cffEEE4AEToggle only show with CTRL/ALT/SHIFT|r")

  elseif cmd == "mod" then
    if Settings.UsingMod then
      AddMessage(fName, "Always show info")
    else
      AddMessage(fName, "Only show when using CTRL/ALT/SHIFT")
    end
    Settings.UsingMod = not Settings.UsingMod
  elseif cmd == "id" then
    if Settings.ShowNPCID then
      AddMessage(fName, "Hide NPC ID")
    else
      AddMessage(fName, "Show NPC ID")
    end
    Settings.ShowNPCID = not Settings.ShowNPCID
  elseif cmd == "playerguid" then
    if Settings.ShowPlayerGUID then
      AddMessage(fName, "Hide player GUID")
    else
      AddMessage(fName, "Show player GUID")
    end
    Settings.ShowPlayerGUID = not Settings.ShowPlayerGUID
  elseif cmd == "rawguid" then
    if Settings.ShowRawGUID then
      AddMessage(fName, "Hide raw GUID")
    else
      AddMessage(fName, "Show raw GUID")
    end
    Settings.ShowRawGUID = not Settings.ShowRawGUID
  elseif cmd == "playertarget" then
    if Settings.ShowPlayerTarget then
      AddMessage(fName, "Hide target of player")
    else
      AddMessage(fName, "Show target of player")
    end
    Settings.ShowPlayerTarget = not Settings.ShowPlayerTarget
  end
end