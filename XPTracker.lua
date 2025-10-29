-- XPTracker Main File
local _, XPT = ...
local L = XPT.L

-- Font mapping
local fontPaths = {
    FRIZQT = "Fonts\\FRIZQT__.TTF",
    ARIALN = "Fonts\\ARIALN.TTF",
    SKURRI = "Fonts\\SKURRI.TTF",
    MORPHEUS = "Fonts\\MORPHEUS.TTF"
}

-- Default settings
local defaultSettings = {
    textAlign = "LEFT",  -- LEFT, CENTER, RIGHT
    scale = 1.0,         -- Interface scale (0.5 to 2.0)
    fontSize = 14,       -- Font size for main text (10 to 24)
    bgOpacity = 0.4,     -- Background opacity (0 to 1)
    font = "FRIZQT",     -- Font choice
}

-- Initialize saved variables
XPTrackerSettings = XPTrackerSettings or CopyTable(defaultSettings)

-- Expose default settings for config panel
XPT.defaultSettings = defaultSettings
XPT.fontPaths = fontPaths

-- Main frame
local frame = CreateFrame("Frame", "XPTrackerFrame", UIParent)
frame:SetSize(250, 80)
frame:SetPoint("TOP", UIParent, "TOP", 0, -50)
frame:SetMovable(true)
frame:EnableMouse(true)
frame:RegisterForDrag("LeftButton")
frame:SetScript("OnDragStart", frame.StartMoving)
frame:SetScript("OnDragStop", frame.StopMovingOrSizing)

-- Show/hide buttons on hover
frame:SetScript("OnEnter", function(self)
    toggleButton:Show()
    resetButton:Show()
    configButton:Show()
end)
frame:SetScript("OnLeave", function(self)
    toggleButton:Hide()
    resetButton:Hide()
    configButton:Hide()
end)

-- Background (transparent)
local bg = frame:CreateTexture(nil, "BACKGROUND")
bg:SetAllPoints(true)
bg:SetColorTexture(0, 0, 0, 0.4)

-- Main text (XP/h)
local text = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
text:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -10)
text:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -10, -10)
text:SetText(string.format(L.xpPerHour, L.calculating))

-- Secondary text (time to next level)
local timeText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
timeText:SetPoint("TOPLEFT", text, "BOTTOMLEFT", 0, -5)
timeText:SetPoint("TOPRIGHT", text, "BOTTOMRIGHT", 0, -5)
timeText:SetText("")

-- Session time text
local sessionTimeText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
sessionTimeText:SetPoint("TOPLEFT", timeText, "BOTTOMLEFT", 0, -5)
sessionTimeText:SetPoint("TOPRIGHT", timeText, "BOTTOMRIGHT", 0, -5)
sessionTimeText:SetText(string.format(L.time, "0s", ""))

-- Buttons container
local buttonsY = -5
local buttonSize = 20

-- Pause/Start button with icon
local toggleButton = CreateFrame("Button", nil, frame)
toggleButton:SetSize(buttonSize, buttonSize)
toggleButton:SetPoint("TOP", sessionTimeText, "BOTTOM", -buttonSize, buttonsY)

-- Button background
local toggleBg = toggleButton:CreateTexture(nil, "BACKGROUND")
toggleBg:SetAllPoints(true)
toggleBg:SetColorTexture(0.2, 0.2, 0.2, 0.8)

-- Pause icon
local pauseIcon = toggleButton:CreateTexture(nil, "ARTWORK")
pauseIcon:SetTexture("Interface\\AddOns\\XPTrackerClassicMoP\\assets\\pause")
pauseIcon:SetAllPoints(true)
pauseIcon:SetVertexColor(1, 1, 1) -- White color

-- Play icon
local playIcon = toggleButton:CreateTexture(nil, "ARTWORK")
playIcon:SetTexture("Interface\\AddOns\\XPTrackerClassicMoP\\assets\\play")
playIcon:SetAllPoints(true)
playIcon:SetVertexColor(1, 1, 1) -- White color
playIcon:Hide()

-- Hover effect
toggleButton:SetScript("OnEnter", function(self)
    toggleBg:SetColorTexture(0.3, 0.3, 0.3, 0.8)
    GameTooltip:SetOwner(self, "ANCHOR_TOP")
    GameTooltip:SetText(isTracking and "Pause" or "Start")
    GameTooltip:Show()
end)
toggleButton:SetScript("OnLeave", function(self)
    toggleBg:SetColorTexture(0.2, 0.2, 0.2, 0.8)
    GameTooltip:Hide()
end)

-- Reset button with icon
local resetButton = CreateFrame("Button", nil, frame)
resetButton:SetSize(buttonSize, buttonSize)
resetButton:SetPoint("LEFT", toggleButton, "RIGHT", 0, 0) -- No space between buttons

-- Button background
local resetBg = resetButton:CreateTexture(nil, "BACKGROUND")
resetBg:SetAllPoints(true)
resetBg:SetColorTexture(0.2, 0.2, 0.2, 0.8)

-- Reset icon
local resetIcon = resetButton:CreateTexture(nil, "ARTWORK")
resetIcon:SetTexture("Interface\\AddOns\\XPTrackerClassicMoP\\assets\\reset")
resetIcon:SetAllPoints(true)
resetIcon:SetVertexColor(1, 1, 1) -- White color

-- Hover effect
resetButton:SetScript("OnEnter", function(self)
    resetBg:SetColorTexture(0.3, 0.3, 0.3, 0.8)
    GameTooltip:SetOwner(self, "ANCHOR_TOP")
    GameTooltip:SetText("Reset")
    GameTooltip:Show()
end)
resetButton:SetScript("OnLeave", function(self)
    resetBg:SetColorTexture(0.2, 0.2, 0.2, 0.8)
    GameTooltip:Hide()
end)

-- Config button (using text since no config icon)
local configButton = CreateFrame("Button", nil, frame)
configButton:SetSize(buttonSize, buttonSize)
configButton:SetPoint("LEFT", resetButton, "RIGHT", 0, 0) -- No space between buttons

-- Button background
local configBg = configButton:CreateTexture(nil, "BACKGROUND")
configBg:SetAllPoints(true)
configBg:SetColorTexture(0.2, 0.2, 0.2, 0.8)

-- Config text/icon
local configText = configButton:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
configText:SetPoint("CENTER", 0, 0)
configText:SetText("⚙")
configText:SetTextColor(1, 1, 1) -- White color

-- Hover effect
configButton:SetScript("OnEnter", function(self)
    configBg:SetColorTexture(0.3, 0.3, 0.3, 0.8)
    GameTooltip:SetOwner(self, "ANCHOR_TOP")
    GameTooltip:SetText("Config")
    GameTooltip:Show()
end)
configButton:SetScript("OnLeave", function(self)
    configBg:SetColorTexture(0.2, 0.2, 0.2, 0.8)
    GameTooltip:Hide()
end)


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

-- Function to apply scale
local function ApplyScale()
    local scale = XPTrackerSettings.scale or 1.0
    frame:SetScale(scale)
end

-- Function to apply font size
local function ApplyFontSize()
    local size = XPTrackerSettings.fontSize or 14
    local fontChoice = XPTrackerSettings.font or "FRIZQT"
    local fontPath = fontPaths[fontChoice] or fontPaths["FRIZQT"]
    local _, _, flags = text:GetFont()
    text:SetFont(fontPath, size, flags or "OUTLINE")
    timeText:SetFont(fontPath, size - 2, flags or "OUTLINE")
    sessionTimeText:SetFont(fontPath, size - 2, flags or "OUTLINE")
end

-- Function to apply background opacity
local function ApplyBackgroundOpacity()
    local opacity = XPTrackerSettings.bgOpacity or 0.4
    bg:SetColorTexture(0, 0, 0, opacity)
end

-- Expose functions for config panel
XPT.ApplyTextAlignment = ApplyTextAlignment
XPT.ApplyScale = ApplyScale
XPT.ApplyFontSize = ApplyFontSize
XPT.ApplyBackgroundOpacity = ApplyBackgroundOpacity

-- Update display function
local function UpdateDisplay()
    if not text then return end
    -- Check if player has reached max level (works for all WoW versions)
    local currentLevel = UnitLevel("player")
    local maxLevel = GetMaxPlayerLevel and GetMaxPlayerLevel() or 60

    if currentLevel >= maxLevel then
        text:SetText(L.maxLevel)
        timeText:SetText("")
        sessionTimeText:SetText("")
        toggleButton:Hide()
        resetButton:Hide()
        configButton:Hide()
        return
    else
        toggleButton:Show()
        resetButton:Show()
        configButton:Show()
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

    -- Display XP/h with green color for value
    local xpValue = xpPerHour > 0 and FormatNumber(xpPerHour) or L.calculating
    local xpFormatted = L.xpPerHour:gsub("%%s", "|cff00ff00%%s|r")
    text:SetText(string.format(xpFormatted, xpValue))

    -- Display session time with yellow color for value
    local timeValue = FormatTime(math.floor(elapsedTime)) .. (isTracking and "" or " " .. L.paused)
    local timeFormatted = L.time:gsub("%%s", "|cffffff00%%s|r")
    sessionTimeText:SetText(string.format(timeFormatted, timeValue, ""))

    -- Calculate time remaining with white level and yellow time
    if xpPerHour > 0 then
        local xpNeeded = maxXP - currentXP
        local timeNeeded = (xpNeeded / xpPerHour) * 3600
        local nextLevel = UnitLevel("player") + 1
        -- Replace %d with white and time %s with yellow
        local levelFormatted = L.nextLevel:gsub("%%d", "|cffffffff%%d|r")
        levelFormatted = levelFormatted:gsub("%%s", "|cffffff00%%s|r")
        timeText:SetText(string.format(levelFormatted, nextLevel, FormatTime(math.floor(timeNeeded))))
    else
        local nextLevel = UnitLevel("player") + 1
        local levelFormatted = L.nextLevel:gsub("%%d", "|cffffffff%%d|r")
        levelFormatted = levelFormatted:gsub("%%s", "|cffffff00%%s|r")
        timeText:SetText(string.format(levelFormatted, nextLevel, L.calculatingTime))
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
    pauseIcon:Show()
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
        pauseIcon:Hide()
        playIcon:Show()
        print(L.sessionPaused)
    else
        -- Resume - show pause icon
        isTracking = true
        pausedTime = pausedTime + (time() - pauseStartTime)
        pauseIcon:Show()
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

        -- Ensure new settings exist
        XPTrackerSettings.scale = XPTrackerSettings.scale or 1.0
        XPTrackerSettings.fontSize = XPTrackerSettings.fontSize or 14
        XPTrackerSettings.bgOpacity = XPTrackerSettings.bgOpacity or 0.4
        XPTrackerSettings.font = XPTrackerSettings.font or "FRIZQT"

        startTime = time()
        startXP = UnitXP("player")
        sessionXP = 0
        pausedTime = 0
        pauseStartTime = 0
        isTracking = true
        pendingReset = false
        pauseIcon:Show()
        playIcon:Hide()
        -- Hide buttons by default
        toggleButton:Hide()
        resetButton:Hide()
        configButton:Hide()
        local inInstance = IsInInstance()
        wasInInstance = inInstance
        ApplyTextAlignment()
        ApplyScale()
        ApplyFontSize()
        ApplyBackgroundOpacity()
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
