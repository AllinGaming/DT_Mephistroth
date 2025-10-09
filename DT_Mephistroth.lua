------------------------------------------------------------
--  DT_Mephistroth Shackles Helper (Turtle WoW 1.12)
--  Disables WASD/Arrow keys while Shackles is active
--  Shows a big red warning immediately on cast
------------------------------------------------------------
--  Version info
------------------------------------------------------------
local ADDON_PREFIX = "DTMEPH"
local ADDON_VERSION = "1.6.1"
local versionReplies = {}
local versionActive  = false
local versionStart   = 0

DT_MephistrothDB = DT_MephistrothDB or {}
if DT_MephistrothDB.includeQE == nil then DT_MephistrothDB.includeQE = true end

------------------------------------------------------------
--  Localization
------------------------------------------------------------
local locale = GetLocale()
local L = {}
if locale == "zhCN" then
  L.BOSS_CAST        = "Mephistroth begins to cast Shackles of the Legion"
  L.BOSS_CAST_CN     = "孟菲斯托斯开始施放军团镣铐"
  L.SHACKLES_NAME    = "Shackles of the Legion"
  L.SHACKLES_NAME_CN = "军团镣铐"
  L.BIGMSG           = "【DT_Mephistroth】警告!!! 请松开WASD/方向键！"
elseif locale == "zhTW" then
  L.BOSS_CAST        = "Mephistroth begins to cast Shackles of the Legion"
  L.BOSS_CAST_CN     = "梅菲斯托斯開始施放軍團鐐銬"
  L.SHACKLES_NAME    = "Shackles of the Legion"
  L.SHACKLES_NAME_CN = "軍團鐐銬"
  L.BIGMSG           = "【DT_Mephistroth】警告!!! 請鬆開WASD/方向鍵！"
else
  L.BOSS_CAST        = "Mephistroth begins to cast Shackles of the Legion"
  L.BOSS_CAST_CN     = nil
  L.SHACKLES_NAME    = "Shackles of the Legion"
  L.SHACKLES_NAME_CN = "军团镣铐"
  L.BIGMSG           = "[DT_Mephistroth] WARNING: Release WASD/Arrow keys!"
end

------------------------------------------------------------
--  Utility
------------------------------------------------------------
local function GetWASDKeys()
  local t = { "W","A","S","D","UP","DOWN","LEFT","RIGHT","SPACE" }
  if DT_MephistrothDB.includeQE then tinsert(t,"Q"); tinsert(t,"E") end
  return t
end

------------------------------------------------------------
--  Big on-screen message
------------------------------------------------------------
local function ShowBigMessage(msg)
  if not DT_Mephistroth_BigMsg then
    local f = CreateFrame("Frame", "DT_Mephistroth_BigMsg", UIParent)
    f:SetFrameStrata("FULLSCREEN_DIALOG")
    f:SetWidth(1000); f:SetHeight(800)
    f:SetPoint("CENTER", 0, 0)
    local bg = f:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints(); bg:SetTexture(0,0,0,0.6); f.bg = bg
    local text = f:CreateFontString(nil,"OVERLAY")
    text:SetFont("Fonts\\FRIZQT__.TTF", 120, "OUTLINE")
    text:SetAllPoints(); text:SetJustifyH("CENTER"); text:SetJustifyV("MIDDLE")
    text:SetTextColor(1,0,0); f.text = text; f:Hide()
  end
  DT_Mephistroth_BigMsg.text:SetText(msg)
  DT_Mephistroth_BigMsg.text:SetTextColor(1,0,0)
  DT_Mephistroth_BigMsg:Show()
  DT_Timer.After(3, function() DT_Mephistroth_BigMsg:Hide() end)
end

------------------------------------------------------------
--  Debuff detection (1.12-safe)
------------------------------------------------------------
local tip = CreateFrame("GameTooltip","DT_MephTooltip",UIParent,"GameTooltipTemplate")
tip:SetOwner(UIParent,"ANCHOR_NONE")

local function AuraHasName(unit, enName, zhName)
  for i=1,32 do
    local tex = UnitDebuff(unit, i)
    if not tex then break end
    tip:ClearLines()
    tip:SetUnitDebuff(unit, i)
    local line = getglobal("DT_MephTooltipTextLeft1")
    local nm = line and line:GetText() or nil
    if nm and (nm == enName or (zhName and nm == zhName)) then
      return true
    end
  end
  return false
end

local function HasShackles()
  return AuraHasName("player", L.SHACKLES_NAME, L.SHACKLES_NAME_CN)
end

local function HasConeOfCold()
  return AuraHasName("player", "Cone of Cold", "Cone of Cold")
end
------------------------------------------------------------
--  Movement detection (position delta)
------------------------------------------------------------
local playerMoveState = {}
local function PlayerIsMoving()
  local x, y = GetPlayerMapPosition("player")
  if (not x) or (x == 0 and y == 0) then
    if SetMapToCurrentZone then SetMapToCurrentZone() end
    x, y = GetPlayerMapPosition("player")
  end
  local now = GetTime()
  if not playerMoveState.lastX then
    playerMoveState.lastX, playerMoveState.lastY, playerMoveState.lastTime = x, y, now
    return false
  end
  if (now - (playerMoveState.lastTime or 0)) < 0.20 then
    return false
  end
  local moved = (x ~= playerMoveState.lastX or y ~= playerMoveState.lastY)
  playerMoveState.lastX, playerMoveState.lastY, playerMoveState.lastTime = x, y, now
  return moved
end

------------------------------------------------------------
--  Binding control
------------------------------------------------------------
local originalBindings, isDisabled = {}, false

local function RestoreBindings()
  for key, action in pairs(originalBindings) do
    if action and action ~= "" then SetBinding(key, action) else SetBinding(key) end
  end
  SaveBindings(GetCurrentBindingSet())
  for k in pairs(originalBindings) do originalBindings[k] = nil end
  isDisabled = false
end

local function DisableBindings()
  if isDisabled then return end
  local keys = GetWASDKeys()
  for i=1,table.getn(keys) do
    local key = keys[i]
    originalBindings[key] = GetBindingAction(key)
    SetBinding(key)
  end
  SaveBindings(GetCurrentBindingSet())
  isDisabled = true
  -- ShowBigMessage(L.BIGMSG)
end

------------------------------------------------------------
--  Debuff watcher (restores when Shackles fades)
------------------------------------------------------------
local function WatchAura()
  if not isDisabled then return end
  if not HasShackles() then
    RestoreBindings()
    return
  end
  DT_Timer.After(0.2, WatchAura)
end
------------------------------------------------------------
--  Debuff watcher (restores when Shackles fades)
------------------------------------------------------------
local function WatchAuraCoC()
  if not isDisabled then return end
  if not HasConeOfCold() then
    RestoreBindings()
    return
  end
  DT_Timer.After(0.2, WatchAuraCoC)
end
------------------------------------------------------------
--  Wait until still & debuffed (timer-based)
------------------------------------------------------------
local function DisableWhenStillAndDebuffedCoc(timeoutSec)
  local startTime, stillFor = GetTime(), 0
    DT_Timer.After(2.9, DisableBindings)
    DT_Timer.After(3.1, WatchAuraCoC)
  local function poll()
    if timeoutSec and (GetTime() - startTime > timeoutSec) then return end

    -- -- Wait for debuff
    -- if not HasShackles() then
    --   stillFor = 0
    --   DT_Timer.After(0.2, poll)
    --   return
    -- end

    -- Wait for stop moving
    if PlayerIsMoving() then
      stillFor = 0
      DT_Timer.After(0.2, poll)
      return
    end

    stillFor = stillFor + 0.2
    if stillFor >= 0.3 then
      DT_Timer.After(8.5, function() if isDisabled then RestoreBindings() end end)
    else
      DT_Timer.After(0.2, poll)
    end
  end

  poll()
end

------------------------------------------------------------
--  Wait until still & debuffed (timer-based)
------------------------------------------------------------
local function DisableWhenStillAndDebuffed(timeoutSec)
  local startTime, stillFor = GetTime(), 0
    DT_Timer.After(2.9, DisableBindings)
    DT_Timer.After(3.1, WatchAura)
  local function poll()
    if timeoutSec and (GetTime() - startTime > timeoutSec) then return end

    -- -- Wait for debuff
    -- if not HasShackles() then
    --   stillFor = 0
    --   DT_Timer.After(0.2, poll)
    --   return
    -- end

    -- Wait for stop moving
    if PlayerIsMoving() then
      stillFor = 0
      DT_Timer.After(0.2, poll)
      return
    end

    stillFor = stillFor + 0.2
    if stillFor >= 0.3 then
      DT_Timer.After(8.5, function() if isDisabled then RestoreBindings() end end)
    else
      DT_Timer.After(0.2, poll)
    end
  end

  poll()
end

------------------------------------------------------------
--  Wait until still & debuffed test version (timer-based)
------------------------------------------------------------
local function DisableWhenStillAndDebuffedTest(timeoutSec)
  local startTime, stillFor = GetTime(), 0
    DT_Timer.After(2.9, DisableBindings)
    -- DT_Timer.After(3.1, WatchAura)
    DT_Timer.After(8.5, function() if isDisabled then RestoreBindings() end end)
  -- local function poll2()
  --   if timeoutSec and (GetTime() - startTime > timeoutSec) then return end

  --   -- -- Wait for debuff
  --   -- if not HasShackles() then
  --   --   stillFor = 0
  --   --   DT_Timer.After(0.2, poll)
  --   --   return
  --   -- end

  --   -- Wait for stop moving
  --   if PlayerIsMoving() then
  --     stillFor = 0
  --     DT_Timer.After(0.2, poll2)
  --     return
  --   end

  --   stillFor = stillFor + 0.2
  --   if stillFor >= 0.3 then
  --     DT_Timer.After(8.5, function() if isDisabled then RestoreBindings() end end)
  --   else
  --     DT_Timer.After(0.2, poll2)
  --   end
  -- end

  -- poll2()
end

------------------------------------------------------------
--  Trigger flow
------------------------------------------------------------
local function OnShacklesCast()
  ShowBigMessage(L.BIGMSG)
  DisableWhenStillAndDebuffed(8.5)
end
------------------------------------------------------------
--  Trigger flow
------------------------------------------------------------
local function OnShacklesCastCoc()
  ShowBigMessage(L.BIGMSG)
  DisableWhenStillAndDebuffedCoc(8.5)
end

local function OnShacklesCastTest()
  ShowBigMessage(L.BIGMSG)
  DisableWhenStillAndDebuffedTest(8.5)
end
------------------------------------------------------------
--  Event hook
------------------------------------------------------------
local frame = CreateFrame("Frame")
frame:RegisterEvent("CHAT_MSG_RAID_BOSS_EMOTE")
frame:RegisterEvent("CHAT_MSG_RAID_LEADER")
-- Register for addon messages
frame:RegisterEvent("CHAT_MSG_ADDON")
if RegisterAddonMessagePrefix then
  RegisterAddonMessagePrefix(ADDON_PREFIX)
end

frame:SetScript("OnEvent", function()
  local msg = arg1
  if not msg then return end
  if string.find(msg, L.BOSS_CAST) or (L.BOSS_CAST_CN and string.find(msg, L.BOSS_CAST_CN)) then
    OnShacklesCast()
  end
end)
-- Keep reference to old handler so we don't lose boss logic
local oldHandler = frame:GetScript("OnEvent")
frame:SetScript("OnEvent", function()
  local event = event or arg1
  -- --- Version message handling ---
  if event == "CHAT_MSG_ADDON" then
    local prefix, message, channel, sender = arg1, arg2, arg3, arg4
    if prefix ~= ADDON_PREFIX then return end

    if string.find(message, "^VER:") then
      local ver = string.sub(message, 5)
      versionReplies[sender] = ver
    elseif message == "PING" then
      -- someone else is checking → reply with our version
      SendAddonMessage(ADDON_PREFIX, "VER:"..ADDON_VERSION, "RAID")
    end
    return
  end

  -- --- Keep your original boss-emote logic ---
  if oldHandler then
    oldHandler()
  end
end)

------------------------------------------------------------
--  Slash commands
------------------------------------------------------------
SLASH_DTSCREENTEST1 = "/dtscreentest"
SlashCmdList["DTSCREENTEST"] = function(_) OnShacklesCast() end

------------------------------------------------------------
--  Slash commands
------------------------------------------------------------
SLASH_COCTEST1 = "/coctest"
SlashCmdList["COCTEST"] = function(_) OnShacklesCastCoc() end

------------------------------------------------------------
--  Slash commands
------------------------------------------------------------
SLASH_DTMOVETEST1 = "/dtmovetest"
SlashCmdList["DTMOVETEST"] = function(_) OnShacklesCastTest() end

SLASH_DTMVER1 = "/dtver"
SlashCmdList["DTMVER"] = function()
  if versionActive then
    DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00[DT_Mephistroth]|r Version check already running.")
    return
  end

  versionActive = true
  versionReplies = {}
  versionStart = GetTime()

  DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00[DT_Mephistroth]|r Checking raid addon versions...")
  SendAddonMessage(ADDON_PREFIX, "PING", "RAID")

  -- after 3 seconds, show summary
  DT_Timer.After(3, function()
    versionActive = false
    local raidSize = GetNumRaidMembers and GetNumRaidMembers() or 0
    local known, missing = {}, {}

    if raidSize > 0 then
      for i = 1, raidSize do
        local name = UnitName("raid"..i)
        if name then
          if versionReplies[name] then
            table.insert(known, name .. " (".. versionReplies[name] ..")")
          else
            table.insert(missing, name)
          end
        end
      end
    else
      -- fallback: party or self test
      local name = UnitName("player")
      table.insert(known, name .. " (".. ADDON_VERSION ..")")
    end

    DEFAULT_CHAT_FRAME:AddMessage("|cffffff00=== DT_Mephistroth Version Report ===|r")

    if table.getn(known) > 0 then
      DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00✅ Addon detected:|r " .. table.concat(known, ", "))
    else
      DEFAULT_CHAT_FRAME:AddMessage("|cffff0000No raid members responded.|r")
    end

    if table.getn(missing) > 0 then
      DEFAULT_CHAT_FRAME:AddMessage("|cffff0000❌ No response (likely missing addon):|r " .. table.concat(missing, ", "))
    else
      DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00All raid members responded.|r")
    end

    DEFAULT_CHAT_FRAME:AddMessage("|cffffff00====================================|r")
  end)
end


SLASH_DTMQETOGGLE1 = "/dtqe"
SlashCmdList["DTMQETOGGLE"] = function(msg)
  msg = string.lower(msg or "")
  if msg == "on" or msg == "1" or msg == "enable" then
    DT_MephistrothDB.includeQE = true
  elseif msg == "off" or msg == "0" or msg == "disable" then
    DT_MephistrothDB.includeQE = false
  elseif msg == "status" or msg == "?" then
    DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00[DT_Mephistroth]|r Q/E disabling is "
      .. (DT_MephistrothDB.includeQE and "|cffffff00ON|r" or "|cffff0000OFF|r"))
    return
  else
    DT_MephistrothDB.includeQE = not DT_MephistrothDB.includeQE
  end
  DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00[DT_Mephistroth]|r Q/E disabling: "
    .. (DT_MephistrothDB.includeQE and "|cffffff00ON|r" or "|cffff0000OFF|r"))
end
