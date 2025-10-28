-- XPTracker Main File
local _, XPT = ...
local L = XPT.L

-- Default settings
local defaultSettings = {
    textAlign = "LEFT",  -- LEFT, CENTER, RIGHT
    colors = {
        xpRateLabel = {r = 1, g = 1, b = 1},      -- "XP/h:" label
        xpRateValue = {r = 0, g = 1, b = 0},      -- XP rate value (green)
        levelLabel = {r = 1, g = 1, b = 1},       -- "Level X:" label
        levelValue = {r = 1, g = 1, b = 1},       -- Time value
        timeLabel = {r = 1, g = 1, b = 1},        -- "Time:" label
        timeValue = {r = 1, g = 1, b = 1},        -- Time value
        maxLevel = {r = 1, g = 0.843, b = 0},     -- Max level text (gold)
    }
}

-- Initialize saved variables
XPTrackerSettings = XPTrackerSettings or CopyTable(defaultSettings)

-- Expose default settings for config panel
XPT.defaultSettings = defaultSettings

-- Main frame
local frame = CreateFrame("Frame", "XPTrackerFrame", UIParent)
frame:SetSize(300, 100)
frame:SetPoint("TOP", UIParent, "TOP", 0, -50)
frame:SetMovable(true)
frame:EnableMouse(true)
frame:RegisterForDrag("LeftButton")
frame:SetScript("OnDragStart", frame.StartMoving)
frame:SetScript("OnDragStop", frame.StopMovingOrSizing)

-- Background (transparent)
local bg = frame:CreateTexture(nil, "BACKGROUND")
bg:SetAllPoints(true)
bg:SetColorTexture(0, 0, 0, 0)

-- Main text (XP/h)
local text = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
text:SetPoint("TOP", frame, "TOP", 0, -10)
text:SetWidth(280)
text:SetText(string.format(L.xpPerHour, L.calculating))

-- Secondary text (time to next level)
local timeText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
timeText:SetPoint("TOP", text, "BOTTOM", 0, -5)
timeText:SetWidth(280)
timeText:SetText("")

-- Session time text
local sessionTimeText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
sessionTimeText:SetPoint("TOP", timeText, "BOTTOM", 0, -5)
sessionTimeText:SetWidth(280)
sessionTimeText:SetText(string.format(L.time, "0s", ""))

-- Buttons container
local buttonsY = -5

-- Pause/Start button with icon
local toggleButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
toggleButton:SetSize(28, 28)
toggleButton:SetPoint("TOP", sessionTimeText, "BOTTOM", -45, buttonsY)

-- Pause icon (two bars)
local pauseIcon1 = toggleButton:CreateTexture(nil, "OVERLAY")
pauseIcon1:SetSize(4, 12)
pauseIcon1:SetPoint("CENTER", -3, 0)
pauseIcon1:SetColorTexture(1, 1, 1)

local pauseIcon2 = toggleButton:CreateTexture(nil, "OVERLAY")
pauseIcon2:SetSize(4, 12)
pauseIcon2:SetPoint("CENTER", 3, 0)
pauseIcon2:SetColorTexture(1, 1, 1)

-- Play icon (triangle)
local playIcon = toggleButton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
playIcon:SetPoint("CENTER", 2, 0)
playIcon:SetText("▶")
playIcon:SetFont("Fonts\\FRIZQT__.TTF", 14, "OUTLINE")
playIcon:Hide()

-- Reset button with icon
local resetButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
resetButton:SetSize(28, 28)
resetButton:SetPoint("TOP", sessionTimeText, "BOTTOM", 0, buttonsY)

-- Stop icon (square)
local stopIcon = resetButton:CreateTexture(nil, "OVERLAY")
stopIcon:SetSize(12, 12)
stopIcon:SetPoint("CENTER", 0, 0)
stopIcon:SetColorTexture(1, 1, 1)

-- Config button with icon
local configButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
configButton:SetSize(28, 28)
configButton:SetPoint("TOP", sessionTimeText, "BOTTOM", 45, buttonsY)

-- Config icon (gear)
local configIcon = configButton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
configIcon:SetPoint("CENTER", 0, 0)
configIcon:SetText("⚙")
configIcon:SetFont("Fonts\\FRIZQT__.TTF", 16, "OUTLINE")

-- Tooltips
toggleButton:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_TOP")
    GameTooltip:SetText(isTracking and L.pauseButton or L.startButton)
    GameTooltip:Show()
end)
toggleButton:SetScript("OnLeave", function() GameTooltip:Hide() end)

resetButton:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_TOP")
    GameTooltip:SetText(L.resetButton)
    GameTooltip:Show()
end)
resetButton:SetScript("OnLeave", function() GameTooltip:Hide() end)

configButton:SetScript("OnEnter", function(self)
    GameTooltip:SetOwner(self, "ANCHOR_TOP")
    GameTooltip:SetText(L.configButton)
    GameTooltip:Show()
end)
configButton:SetScript("OnLeave", function() GameTooltip:Hide() end)

-- Variables
local startTime = time()
local startXP = UnitXP("player")
local sessionXP = 0
local sessionTime = 0
local isTracking = true
local pausedTime = 0
local pauseStartTime = 0
local pendingReset = false
local wasInInstance = false

-- Function to format numbers with K and M
local function FormatNumber(value)
    if value < 1000 then
        return tostring(value)
    elseif value < 1000000 then
        return string.format("%.1fk", value / 1000)
    else
        return string.format("%.1fM", value / 1000000)
    end
end

-- Function to format time
local function FormatTime(seconds)
    if seconds < 60 then
        return string.format("%ds", seconds)
    elseif seconds < 3600 then
        return string.format("%dm %ds", math.floor(seconds / 60), seconds % 60)
    else
        return string.format("%dh %dm", math.floor(seconds / 3600), math.floor((seconds % 3600) / 60))
    end
end

-- Function to apply text alignment
local function ApplyTextAlignment()
    local align = XPTrackerSettings.textAlign
    text:SetJustifyH(align)
    timeText:SetJustifyH(align)
    sessionTimeText:SetJustifyH(align)
end

-- Expose functions for config panel
XPT.ApplyTextAlignment = ApplyTextAlignment

-- Function to create colored text
local function ColorText(text, color)
    return string.format("|cff%02x%02x%02x%s|r",
        color.r * 255, color.g * 255, color.b * 255, text)
end

-- Update display function
local function UpdateDisplay()
    if not text then return end
    -- Check if player has reached max level (works for all WoW versions)
    local currentLevel = UnitLevel("player")
    local maxLevel = GetMaxPlayerLevel and GetMaxPlayerLevel() or 60

    if currentLevel >= maxLevel then
        local c = XPTrackerSettings.colors.maxLevel
        text:SetTextColor(c.r, c.g, c.b)
        text:SetText(L.maxLevel)
        timeText:SetText("")
        sessionTimeText:SetText("")
        toggleButton:Hide()
        resetButton:Hide()
        return
    else
        toggleButton:Show()
        resetButton:Show()
    end

    local currentXP = UnitXP("player")
    local maxXP = UnitXPMax("player")

    -- Calculate elapsed time (accounting for pauses)
    local elapsedTime
    if isTracking then
        elapsedTime = (time() - startTime) - pausedTime
    else
        elapsedTime = (pauseStartTime - startTime) - pausedTime
    end

    -- Calculate XP gained
    sessionXP = currentXP - startXP

    -- Adjust for level change
    if sessionXP < 0 then
        sessionXP = sessionXP + maxXP
    end

    -- Calculate XP/h
    local xpPerHour = 0
    if elapsedTime > 0 then
        xpPerHour = math.floor((sessionXP / elapsedTime) * 3600)
    end

    -- Display XP/h with colors
    local xpValue = xpPerHour > 0 and FormatNumber(xpPerHour) or L.calculating
    local xpText = ColorText(L.xpPerHour:match("^(.-):%s*%%s") or "XP/h", XPTrackerSettings.colors.xpRateLabel) ..
                   ": " .. ColorText(xpValue, XPTrackerSettings.colors.xpRateValue)
    text:SetText(xpText)

    -- Display session time with colors
    local timeValue = FormatTime(math.floor(elapsedTime)) .. (isTracking and "" or " " .. L.paused)
    local timeStr = ColorText(L.time:match("^(.-):%s*%%s") or "Time", XPTrackerSettings.colors.timeLabel) ..
                    ": " .. ColorText(timeValue, XPTrackerSettings.colors.timeValue)
    sessionTimeText:SetText(timeStr)

    -- Calculate time remaining with colors
    if xpPerHour > 0 then
        local xpNeeded = maxXP - currentXP
        local timeNeeded = (xpNeeded / xpPerHour) * 3600
        local nextLevel = UnitLevel("player") + 1
        local levelLabel = L.nextLevel:match("^(.-)%d") or "Level"
        local levelStr = ColorText(levelLabel:gsub("%%d", tostring(nextLevel)), XPTrackerSettings.colors.levelLabel) ..
                        ": " .. ColorText(FormatTime(math.floor(timeNeeded)), XPTrackerSettings.colors.levelValue)
        timeText:SetText(levelStr)
    else
        local nextLevel = UnitLevel("player") + 1
        local levelLabel = L.nextLevel:match("^(.-)%d") or "Level"
        local levelStr = ColorText(levelLabel:gsub("%%d", tostring(nextLevel)), XPTrackerSettings.colors.levelLabel) ..
                        ": " .. ColorText(L.calculatingTime, XPTrackerSettings.colors.levelValue)
        timeText:SetText(levelStr)
    end
end

-- Expose UpdateDisplay for config panel
XPT.UpdateDisplay = UpdateDisplay

-- Function to reset stats
local function ResetStats()
    startTime = time()
    startXP = UnitXP("player")
    sessionXP = 0
    pausedTime = 0
    pauseStartTime = 0
    isTracking = true
    pauseIcon1:Show()
    pauseIcon2:Show()
    playIcon:Hide()
    pendingReset = false
    print(L.statsReset)
    UpdateDisplay()
end

-- Function to ask for reset confirmation
local function AskReset()
    StaticPopupDialogs["XPTRACKER_RESET_CONFIRM"] = {
        text = L.resetConfirm,
        button1 = L.yes,
        button2 = L.no,
        OnAccept = function()
            ResetStats()
        end,
        OnCancel = function()
            pendingReset = false
            print(L.resetCancelled)
        end,
        timeout = 0,
        whileDead = true,
        hideOnEscape = true,
        preferredIndex = 3,
    }
    StaticPopup_Show("XPTRACKER_RESET_CONFIRM")
end

-- Toggle button (Start/Pause) click handler
toggleButton:SetScript("OnClick", function(self)
    if isTracking then
        -- Pause - show play icon
        isTracking = false
        pauseStartTime = time()
        pauseIcon1:Hide()
        pauseIcon2:Hide()
        playIcon:Show()
        print(L.sessionPaused)
    else
        -- Resume - show pause icon
        isTracking = true
        pausedTime = pausedTime + (time() - pauseStartTime)
        pauseIcon1:Show()
        pauseIcon2:Show()
        playIcon:Hide()
        print(L.sessionResumed)
    end
    UpdateDisplay()
end)

-- Reset button click handler
resetButton:SetScript("OnClick", function(self)
    AskReset()
end)

-- Config button click handler
configButton:SetScript("OnClick", function(self)
    if XPT.ShowConfig then
        XPT.ShowConfig()
    else
        print("|cffff0000Error:|r Config panel not loaded yet")
    end
end)

-- Update timer
local updateTimer = 0
frame:SetScript("OnUpdate", function(self, elapsed)
    updateTimer = updateTimer + elapsed
    if updateTimer >= 1 then
        UpdateDisplay()
        updateTimer = 0
    end
end)

-- Events registration
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("PLAYER_XP_UPDATE")
frame:RegisterEvent("PLAYER_LEVEL_UP")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")

frame:SetScript("OnEvent", function(self, event, ...)
    if event == "PLAYER_LOGIN" then
        -- Load saved settings
        if not XPTrackerSettings then
            XPTrackerSettings = CopyTable(defaultSettings)
        end

        startTime = time()
        startXP = UnitXP("player")
        sessionXP = 0
        pausedTime = 0
        pauseStartTime = 0
        isTracking = true
        pendingReset = false
        pauseIcon1:Show()
        pauseIcon2:Show()
        playIcon:Hide()
        local inInstance = IsInInstance()
        wasInInstance = inInstance
        ApplyTextAlignment()
        UpdateDisplay()
    elseif event == "PLAYER_XP_UPDATE" then
        UpdateDisplay()
    elseif event == "PLAYER_LEVEL_UP" then
        -- Auto reset on level up
        ResetStats()
    elseif event == "PLAYER_ENTERING_WORLD" then
        local inInstance = IsInInstance()
        
        -- Detect dungeon/instance entrance/exit
        if inInstance ~= wasInInstance then
            if inInstance or wasInInstance then
                -- Entering or exiting instance - ask for confirmation
                AskReset()
            end
            wasInInstance = inInstance
        else
            -- Simple zone change, no reset
            UpdateDisplay()
        end
    end
end)

-- Slash commands
SLASH_XPTRACKER1 = "/xpt"
SLASH_XPTRACKER2 = "/xptracker"
SlashCmdList["XPTRACKER"] = function(msg)
    if msg == "reset" then
        ResetStats()
    elseif msg == "config" or msg == "settings" then
        if XPT.ShowConfig then
            XPT.ShowConfig()
        else
            print("|cffff0000Error:|r Config panel not loaded yet")
            print("|cffffff00Tip:|r Try /reload and wait a few seconds")
        end
    elseif msg == "pause" then
        if isTracking then
            isTracking = false
            pauseStartTime = time()
            pauseIcon1:Hide()
            pauseIcon2:Hide()
            playIcon:Show()
            print(L.sessionPaused)
        else
            print(L.alreadyPaused)
        end
        UpdateDisplay()
    elseif msg == "start" then
        if not isTracking then
            isTracking = true
            pausedTime = pausedTime + (time() - pauseStartTime)
            pauseIcon1:Show()
            pauseIcon2:Show()
            playIcon:Hide()
            print(L.sessionResumed)
        else
            print(L.alreadyActive)
        end
        UpdateDisplay()
    elseif msg == "hide" then
        frame:Hide()
    elseif msg == "show" then
        frame:Show()
    elseif msg == "debug" then
        print("|cff00ff00XP Tracker Debug:|r")
        print("Text Align:", XPTrackerSettings.textAlign)
        print("Settings saved in:", "|cffff00ffXPTrackerSettings|r")
        print("Logout properly to save changes!")
    else
        print(L.commands)
        print(L.cmdReset)
        print(L.cmdPause)
        print(L.cmdStart)
        print(L.cmdHide)
        print(L.cmdShow)
        print(L.cmdConfig)
    end
end

print(L.loaded)
