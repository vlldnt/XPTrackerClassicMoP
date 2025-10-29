-- XPTracker Configuration Panel
local _, XPT = ...

-- Wait for addon to be fully loaded
local initFrame = CreateFrame("Frame")
initFrame:RegisterEvent("ADDON_LOADED")
initFrame:RegisterEvent("PLAYER_LOGIN")

local configInitialized = false

local function InitializeConfig()
    if configInitialized then return end

    local L = XPT.L
    if not L then
        print("|cffff0000XP Tracker Error:|r Locales not loaded")
        return
    end

    configInitialized = true

    -- Create the main config frame
    local configFrame = CreateFrame("Frame", "XPTrackerConfigFrame", UIParent)
    configFrame:SetSize(420, 480)
    configFrame:SetPoint("CENTER")
    configFrame:Hide()
    configFrame:EnableMouse(true)
    configFrame:SetMovable(true)
    configFrame:RegisterForDrag("LeftButton")
    configFrame:SetScript("OnDragStart", configFrame.StartMoving)
    configFrame:SetScript("OnDragStop", configFrame.StopMovingOrSizing)

    -- Background
    local bg = configFrame:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints(true)
    bg:SetColorTexture(0.05, 0.05, 0.05, 0.9)

    -- Border
    local border = CreateFrame("Frame", nil, configFrame, "DialogBorderTemplate")

    -- Title
    local title = configFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalHuge")
    title:SetPoint("TOP", 0, -20)
    title:SetText("|cff00ff00XP Tracker|r " .. L.configTitle)

    -- Subtitle
    local subtitle = configFrame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    subtitle:SetPoint("TOP", title, "BOTTOM", 0, -8)
    subtitle:SetText(L.configSubtitle)
    subtitle:SetTextColor(0.7, 0.7, 0.7)

    -- Close button
    local closeBtn = CreateFrame("Button", nil, configFrame, "UIPanelCloseButton")
    closeBtn:SetPoint("TOPRIGHT", -5, -5)

    -- Content frame
    local content = CreateFrame("Frame", nil, configFrame)
    content:SetPoint("TOPLEFT", 15, -60)
    content:SetPoint("BOTTOMRIGHT", -15, 50)

    -- ===========================
    -- SECTION: Text Alignment
    -- ===========================
    local alignSection = content:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    alignSection:SetPoint("TOPLEFT", content, "TOPLEFT", 5, -5)
    alignSection:SetText("|cffffd700" .. L.alignmentSection .. "|r")

    local alignDesc = content:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    alignDesc:SetPoint("TOPLEFT", alignSection, "BOTTOMLEFT", 0, -3)
    alignDesc:SetText(L.alignmentDesc)
    alignDesc:SetTextColor(0.8, 0.8, 0.8)

    local alignButtons = {}
    local alignOptions = {
        {value = "LEFT", label = L.alignLeft, x = 10},
        {value = "CENTER", label = L.alignCenter, x = 130},
        {value = "RIGHT", label = L.alignRight, x = 250}
    }

    local function UpdateAlignmentButtons()
        for _, btn in ipairs(alignButtons) do
            if btn.value == XPTrackerSettings.textAlign then
                btn:LockHighlight()
                btn:SetAlpha(1)
            else
                btn:UnlockHighlight()
                btn:SetAlpha(0.7)
            end
        end
    end

    for _, opt in ipairs(alignOptions) do
        local btn = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
        btn:SetPoint("TOPLEFT", alignDesc, "BOTTOMLEFT", opt.x, -10)
        btn:SetSize(100, 30)
        btn:SetText(opt.label)
        btn.value = opt.value

        btn:SetScript("OnClick", function(self)
            XPTrackerSettings.textAlign = self.value
            if XPT.ApplyTextAlignment then XPT.ApplyTextAlignment() end
            if XPT.UpdateDisplay then XPT.UpdateDisplay() end
            UpdateAlignmentButtons()
        end)

        table.insert(alignButtons, btn)
    end

    -- ===========================
    -- SECTION: Scale & Font Size
    -- ===========================
    local scaleSection = content:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    scaleSection:SetPoint("TOPLEFT", alignDesc, "BOTTOMLEFT", 0, -50)
    scaleSection:SetText("|cffffd700" .. (L.scaleSection or "Scale & Font") .. "|r")

    -- Scale Slider
    local scaleLabel = content:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    scaleLabel:SetPoint("TOPLEFT", scaleSection, "BOTTOMLEFT", 5, -8)
    scaleLabel:SetText((L.scaleLabel or "Interface Scale") .. ": " .. string.format("%.0f%%", (XPTrackerSettings.scale or 1.0) * 100))

    local scaleSlider = CreateFrame("Slider", "XPTConfigScaleSlider", content, "OptionsSliderTemplate")
    scaleSlider:SetPoint("TOPLEFT", scaleLabel, "BOTTOMLEFT", 0, -8)
    scaleSlider:SetMinMaxValues(50, 200)
    scaleSlider:SetValue((XPTrackerSettings.scale or 1.0) * 100)
    scaleSlider:SetValueStep(5)
    scaleSlider:SetObeyStepOnDrag(true)
    scaleSlider:SetWidth(200)
    _G[scaleSlider:GetName() .. 'Low']:SetText('50%')
    _G[scaleSlider:GetName() .. 'High']:SetText('200%')
    _G[scaleSlider:GetName() .. 'Text']:SetText('')
    scaleSlider:SetScript("OnValueChanged", function(self, value)
        XPTrackerSettings.scale = value / 100
        scaleLabel:SetText((L.scaleLabel or "Interface Scale") .. ": " .. string.format("%.0f%%", value))
        if XPT.ApplyScale then XPT.ApplyScale() end
    end)

    -- Font Size Slider
    local fontLabel = content:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    fontLabel:SetPoint("TOPLEFT", scaleSlider, "BOTTOMLEFT", 0, -15)
    fontLabel:SetText((L.fontSizeLabel or "Font Size") .. ": " .. (XPTrackerSettings.fontSize or 14))

    local fontSlider = CreateFrame("Slider", "XPTConfigFontSlider", content, "OptionsSliderTemplate")
    fontSlider:SetPoint("TOPLEFT", fontLabel, "BOTTOMLEFT", 0, -8)
    fontSlider:SetMinMaxValues(10, 24)
    fontSlider:SetValue(XPTrackerSettings.fontSize or 14)
    fontSlider:SetValueStep(1)
    fontSlider:SetObeyStepOnDrag(true)
    fontSlider:SetWidth(200)
    _G[fontSlider:GetName() .. 'Low']:SetText('10')
    _G[fontSlider:GetName() .. 'High']:SetText('24')
    _G[fontSlider:GetName() .. 'Text']:SetText('')
    fontSlider:SetScript("OnValueChanged", function(self, value)
        XPTrackerSettings.fontSize = value
        fontLabel:SetText((L.fontSizeLabel or "Font Size") .. ": " .. value)
        if XPT.ApplyFontSize then XPT.ApplyFontSize() end
        if XPT.UpdateDisplay then XPT.UpdateDisplay() end
    end)

    -- Background Opacity Slider
    local opacityLabel = content:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    opacityLabel:SetPoint("TOPLEFT", fontSlider, "BOTTOMLEFT", 0, -15)
    opacityLabel:SetText((L.opacityLabel or "Background Opacity") .. ": " .. string.format("%.0f%%", (XPTrackerSettings.bgOpacity or 0.4) * 100))

    local opacitySlider = CreateFrame("Slider", "XPTConfigOpacitySlider", content, "OptionsSliderTemplate")
    opacitySlider:SetPoint("TOPLEFT", opacityLabel, "BOTTOMLEFT", 0, -8)
    opacitySlider:SetMinMaxValues(0, 100)
    opacitySlider:SetValue((XPTrackerSettings.bgOpacity or 0.4) * 100)
    opacitySlider:SetValueStep(5)
    opacitySlider:SetObeyStepOnDrag(true)
    opacitySlider:SetWidth(200)
    _G[opacitySlider:GetName() .. 'Low']:SetText('0%')
    _G[opacitySlider:GetName() .. 'High']:SetText('100%')
    _G[opacitySlider:GetName() .. 'Text']:SetText('')
    opacitySlider:SetScript("OnValueChanged", function(self, value)
        XPTrackerSettings.bgOpacity = value / 100
        opacityLabel:SetText((L.opacityLabel or "Background Opacity") .. ": " .. string.format("%.0f%%", value))
        if XPT.ApplyBackgroundOpacity then XPT.ApplyBackgroundOpacity() end
    end)

    -- ===========================
    -- SECTION: Font Selection
    -- ===========================
    local fontSection = content:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    fontSection:SetPoint("TOPLEFT", opacitySlider, "BOTTOMLEFT", 0, -25)
    fontSection:SetText("|cffffd700" .. (L.fontSection or "Font") .. "|r")

    local fontDesc = content:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    fontDesc:SetPoint("TOPLEFT", fontSection, "BOTTOMLEFT", 0, -3)
    fontDesc:SetText(L.fontDesc or "Choose text font")
    fontDesc:SetTextColor(0.8, 0.8, 0.8)

    local fontButtons = {}
    local fontOptions = {
        {value = "FRIZQT", label = "Friz Quadrata", x = 0},
        {value = "ARIALN", label = "Arial Narrow", x = 110},
        {value = "SKURRI", label = "Skurri", x = 220},
        {value = "MORPHEUS", label = "Morpheus", x = 55, y = -40},
        {value = "PARIS2024", label = "Paris 2024", x = 165, y = -40}
    }

    local function UpdateFontButtons()
        for _, btn in ipairs(fontButtons) do
            if btn.value == XPTrackerSettings.font then
                btn:LockHighlight()
                btn:SetAlpha(1)
            else
                btn:UnlockHighlight()
                btn:SetAlpha(0.7)
            end
        end
    end

    for _, opt in ipairs(fontOptions) do
        local btn = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
        btn:SetPoint("TOPLEFT", fontDesc, "BOTTOMLEFT", opt.x, opt.y or -10)
        btn:SetSize(100, 30)
        btn:SetText(opt.label)
        btn.value = opt.value

        btn:SetScript("OnClick", function(self)
            XPTrackerSettings.font = self.value
            if XPT.ApplyFontSize then XPT.ApplyFontSize() end
            if XPT.UpdateDisplay then XPT.UpdateDisplay() end
            UpdateFontButtons()
        end)

        table.insert(fontButtons, btn)
    end

    -- ===========================
    -- RESET BUTTON
    -- ===========================
    local resetBtn = CreateFrame("Button", nil, configFrame, "UIPanelButtonTemplate")
    resetBtn:SetPoint("BOTTOM", 0, 15)
    resetBtn:SetSize(180, 30)
    resetBtn:SetText(L.resetDefault)

    resetBtn:SetScript("OnClick", function(self)
        StaticPopupDialogs["XPTRACKER_RESET_CONFIG"] = {
            text = L.resetConfigConfirm,
            button1 = L.yes,
            button2 = L.no,
            OnAccept = function()
                for k, v in pairs(XPT.defaultSettings) do
                    if type(v) == "table" then
                        XPTrackerSettings[k] = {}
                        for k2, v2 in pairs(v) do
                            if type(v2) == "table" then
                                XPTrackerSettings[k][k2] = {}
                                for k3, v3 in pairs(v2) do
                                    XPTrackerSettings[k][k2][k3] = v3
                                end
                            else
                                XPTrackerSettings[k][k2] = v2
                            end
                        end
                    else
                        XPTrackerSettings[k] = v
                    end
                end

                if XPT.ApplyTextAlignment then XPT.ApplyTextAlignment() end
                if XPT.ApplyScale then XPT.ApplyScale() end
                if XPT.ApplyFontSize then XPT.ApplyFontSize() end
                if XPT.ApplyBackgroundOpacity then XPT.ApplyBackgroundOpacity() end
                if XPT.UpdateDisplay then XPT.UpdateDisplay() end

                UpdateAlignmentButtons()
                UpdateFontButtons()

                -- Update sliders
                scaleSlider:SetValue((XPTrackerSettings.scale or 1.0) * 100)
                scaleLabel:SetText((L.scaleLabel or "Interface Scale") .. ": " .. string.format("%.0f%%", (XPTrackerSettings.scale or 1.0) * 100))
                fontSlider:SetValue(XPTrackerSettings.fontSize or 14)
                fontLabel:SetText((L.fontSizeLabel or "Font Size") .. ": " .. (XPTrackerSettings.fontSize or 14))
                opacitySlider:SetValue((XPTrackerSettings.bgOpacity or 0.4) * 100)
                opacityLabel:SetText((L.opacityLabel or "Background Opacity") .. ": " .. string.format("%.0f%%", (XPTrackerSettings.bgOpacity or 0.4) * 100))

                print("|cff00ff00XP Tracker:|r " .. L.configReset)
            end,
            timeout = 0,
            whileDead = true,
            hideOnEscape = true,
            preferredIndex = 3,
        }
        StaticPopup_Show("XPTRACKER_RESET_CONFIG")
    end)

    -- ===========================
    -- UPDATE FUNCTIONS
    -- ===========================
    configFrame:SetScript("OnShow", function(self)
        UpdateAlignmentButtons()
        UpdateFontButtons()
    end)

    -- ===========================
    -- EXPOSE FUNCTIONS
    -- ===========================
    function XPT.ShowConfig()
        configFrame:Show()
    end

    XPT.configFrame = configFrame

    print("|cff00ff00XP Tracker:|r " .. L.configLoaded)
end

-- Event handler
initFrame:SetScript("OnEvent", function(self, event, addonName)
    if event == "ADDON_LOADED" and addonName == "XPTrackerClassicMoP" then
        -- Try to initialize immediately
        InitializeConfig()
    elseif event == "PLAYER_LOGIN" then
        -- Initialize on login as fallback
        InitializeConfig()
        self:UnregisterAllEvents()
    end
end)
