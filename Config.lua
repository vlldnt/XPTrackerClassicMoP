-- XPTracker Configuration Panel
local _, XPT = ...

-- Wait for addon to be fully loaded
local initFrame = CreateFrame("Frame")
initFrame:RegisterEvent("ADDON_LOADED")
initFrame:SetScript("OnEvent", function(self, event, addonName)
    if addonName ~= "XPTracker" then return end
    self:UnregisterEvent("ADDON_LOADED")

    local L = XPT.L
    if not L then
        print("|cffff0000XP Tracker Error:|r Locales not loaded")
        return
    end

    -- Create the main config frame
    local configFrame = CreateFrame("Frame", "XPTrackerConfigFrame", UIParent)
    configFrame:SetSize(500, 600)
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
    content:SetPoint("TOPLEFT", 20, -70)
    content:SetPoint("BOTTOMRIGHT", -20, 60)

    -- ===========================
    -- SECTION: Text Alignment
    -- ===========================
    local alignSection = content:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    alignSection:SetPoint("TOPLEFT", content, "TOPLEFT", 10, -10)
    alignSection:SetText("|cffffd700" .. L.alignmentSection .. "|r")

    local alignDesc = content:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    alignDesc:SetPoint("TOPLEFT", alignSection, "BOTTOMLEFT", 0, -5)
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
    -- SECTION: Colors
    -- ===========================
    local colorSection = content:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    colorSection:SetPoint("TOPLEFT", alignDesc, "BOTTOMLEFT", 0, -60)
    colorSection:SetText("|cffffd700" .. L.colorsSection .. "|r")

    local colorDesc = content:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
    colorDesc:SetPoint("TOPLEFT", colorSection, "BOTTOMLEFT", 0, -5)
    colorDesc:SetText(L.colorsDesc)
    colorDesc:SetTextColor(0.8, 0.8, 0.8)

    local colorOptions = {
        {key = "xpRateLabel", label = L.colorXpLabel, example = "XP/h:"},
        {key = "xpRateValue", label = L.colorXpValue, example = "12.5k"},
        {key = "levelLabel", label = L.colorLevelLabel, example = "Level 60:"},
        {key = "levelValue", label = L.colorLevelValue, example = "2h 15m"},
        {key = "timeLabel", label = L.colorTimeLabel, example = "Time:"},
        {key = "timeValue", label = L.colorTimeValue, example = "1h 30m"},
        {key = "maxLevel", label = L.colorMaxLevel, example = L.maxLevel},
    }

    local colorButtons = {}
    local yOffset = -10

    for i, opt in ipairs(colorOptions) do
        -- Container
        local container = CreateFrame("Frame", nil, content)
        container:SetPoint("TOPLEFT", colorDesc, "BOTTOMLEFT", 0, yOffset)
        container:SetSize(450, 35)

        -- Background
        local itemBg = container:CreateTexture(nil, "BACKGROUND")
        itemBg:SetAllPoints(true)
        if i % 2 == 0 then
            itemBg:SetColorTexture(0.1, 0.1, 0.1, 0.3)
        else
            itemBg:SetColorTexture(0.15, 0.15, 0.15, 0.3)
        end

        -- Label
        local label = container:CreateFontString(nil, "ARTWORK", "GameFontNormal")
        label:SetPoint("LEFT", 10, 0)
        label:SetText(opt.label)
        label:SetWidth(120)
        label:SetJustifyH("LEFT")

        -- Example text
        local exampleText = container:CreateFontString(nil, "ARTWORK", "GameFontNormal")
        exampleText:SetPoint("LEFT", label, "RIGHT", 10, 0)
        exampleText:SetText(opt.example)
        exampleText:SetWidth(150)
        exampleText:SetJustifyH("LEFT")

        -- Color swatch button
        local colorBtn = CreateFrame("Button", nil, container)
        colorBtn:SetSize(30, 30)
        colorBtn:SetPoint("RIGHT", -10, 0)

        local colorTexture = colorBtn:CreateTexture(nil, "ARTWORK")
        colorTexture:SetAllPoints(true)

        local colorBorder = colorBtn:CreateTexture(nil, "OVERLAY")
        colorBorder:SetTexture("Interface\\ChatFrame\\ChatFrameBackground")
        colorBorder:SetPoint("TOPLEFT", -1, 1)
        colorBorder:SetPoint("BOTTOMRIGHT", 1, -1)
        colorBorder:SetColorTexture(0, 0, 0)

        colorBtn:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
            GameTooltip:SetText(L.colorTooltip)
            GameTooltip:Show()
        end)

        colorBtn:SetScript("OnLeave", function(self)
            GameTooltip:Hide()
        end)

        colorBtn:SetScript("OnClick", function(self)
            local c = XPTrackerSettings.colors[opt.key]

            local function UpdateColor()
                local r, g, b = ColorPickerFrame:GetColorRGB()
                XPTrackerSettings.colors[opt.key] = {r = r, g = g, b = b}
                colorTexture:SetColorTexture(r, g, b)
                exampleText:SetTextColor(r, g, b)
                if XPT.UpdateDisplay then XPT.UpdateDisplay() end
            end

            ColorPickerFrame.func = UpdateColor
            ColorPickerFrame.opacityFunc = UpdateColor
            ColorPickerFrame.cancelFunc = function(prev)
                XPTrackerSettings.colors[opt.key] = {r = prev.r, g = prev.g, b = prev.b}
                colorTexture:SetColorTexture(prev.r, prev.g, prev.b)
                exampleText:SetTextColor(prev.r, prev.g, prev.b)
                if XPT.UpdateDisplay then XPT.UpdateDisplay() end
            end

            ColorPickerFrame.previousValues = {r = c.r, g = c.g, b = c.b}
            ColorPickerFrame:SetColorRGB(c.r, c.g, c.b)
            ColorPickerFrame.hasOpacity = false
            ColorPickerFrame:Show()
        end)

        -- Store references
        colorBtn.texture = colorTexture
        colorBtn.example = exampleText
        colorBtn.colorKey = opt.key

        table.insert(colorButtons, colorBtn)

        yOffset = yOffset - 40
    end

    -- ===========================
    -- RESET BUTTON
    -- ===========================
    local resetBtn = CreateFrame("Button", nil, configFrame, "UIPanelButtonTemplate")
    resetBtn:SetPoint("BOTTOM", 0, 20)
    resetBtn:SetSize(200, 35)
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
                if XPT.UpdateDisplay then XPT.UpdateDisplay() end

                UpdateAlignmentButtons()
                UpdateColorDisplay()

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
    local function UpdateColorDisplay()
        for i, btn in ipairs(colorButtons) do
            if btn and btn.colorKey and XPTrackerSettings.colors[btn.colorKey] then
                local c = XPTrackerSettings.colors[btn.colorKey]
                if btn.texture then
                    btn.texture:SetColorTexture(c.r, c.g, c.b)
                end
                if btn.example then
                    btn.example:SetTextColor(c.r, c.g, c.b)
                    btn.example:SetText(colorOptions[i].example)
                end
            end
        end
    end

    configFrame:SetScript("OnShow", function(self)
        UpdateAlignmentButtons()
        UpdateColorDisplay()
    end)

    -- ===========================
    -- EXPOSE FUNCTIONS
    -- ===========================
    function XPT.ShowConfig()
        configFrame:Show()
    end

    XPT.configFrame = configFrame

    print("|cff00ff00XP Tracker:|r " .. L.configLoaded)
end)
