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

    if Settings.ShowNPCID and unitID ~= 0 then
      AddColoredDoubleLine(self, "ID", unitID)
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
  end
end