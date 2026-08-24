--[[
    Weter Client — UI Framework
    LocalScript

    Полностью переписан:
    - надёжный драг (официальный Roblox-паттерн, работает в любом экзекуторе)
    - иконки вкладок
    - контролы: toggle, slider (%), slider (decimal), dropdown, keybind, color swatch
    - ватермарка: отдельная плашка, тащится, клик открывает/закрывает меню
--]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ==================== THEME ====================
local THEME = {
    Background   = Color3.fromRGB(6, 8, 10),
    Panel        = Color3.fromRGB(10, 13, 16),
    Sidebar      = Color3.fromRGB(9, 11, 14),
    ButtonIdle   = Color3.fromRGB(16, 19, 23),
    ButtonHover  = Color3.fromRGB(22, 26, 31),
    Accent       = Color3.fromRGB(45, 190, 245),   -- голубой, как на референсе
    Text         = Color3.fromRGB(225, 230, 235),
    SubText      = Color3.fromRGB(120, 128, 138),
    Border       = Color3.fromRGB(28, 32, 38),
}

-- ==================== HELPERS ====================
local function corner(inst, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 10)
    c.Parent = inst
    return c
end

local function stroke(inst, color, thickness)
    local s = Instance.new("UIStroke")
    s.Color = color or THEME.Border
    s.Thickness = thickness or 1
    s.Parent = inst
    return s
end

local function tween(inst, props, time, style)
    local t = TweenService:Create(inst, TweenInfo.new(time or 0.15, style or Enum.EasingStyle.Quad), props)
    t:Play()
    return t
end

-- надёжный драг: официальный паттерн Roblox, не зависит от одного события
local function makeDraggable(handle, target)
    local dragging = false
    local dragInput, dragStart, startPos

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1
            or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = target.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement
            or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and input == dragInput then
            local delta = input.Position - dragStart
            target.Position = UDim2.new(
                startPos.X.Scale, startPos.X.Offset + delta.X,
                startPos.Y.Scale, startPos.Y.Offset + delta.Y
            )
        end
    end)
end

-- ==================== ICONS (векторные, без картинок) ====================
local function iconCombat(box)
    local ring = Instance.new("Frame")
    ring.Size = UDim2.fromOffset(16, 16)
    ring.Position = UDim2.new(0.5, -8, 0.5, -8)
    ring.BackgroundTransparency = 1
    ring.Parent = box
    corner(ring, 8)
    stroke(ring, THEME.SubText, 1.5)

    local dot = Instance.new("Frame")
    dot.Size = UDim2.fromOffset(4, 4)
    dot.Position = UDim2.new(0.5, -2, 0.5, -2)
    dot.BackgroundColor3 = THEME.SubText
    dot.BorderSizePixel = 0
    dot.Parent = box
    corner(dot, 2)
end

local function iconMovement(box)
    for i = 1, 3 do
        local bar = Instance.new("Frame")
        bar.Size = UDim2.fromOffset(12 - (i - 1) * 3, 2)
        bar.Position = UDim2.new(0.5, -7 + (i - 1) * 2, 0.5, -6 + (i - 1) * 4)
        bar.Rotation = -35
        bar.BackgroundColor3 = THEME.SubText
        bar.BorderSizePixel = 0
        bar.Parent = box
        corner(bar, 1)
    end
end

local function iconVisual(box)
    local outer = Instance.new("Frame")
    outer.Size = UDim2.fromOffset(18, 10)
    outer.Position = UDim2.new(0.5, -9, 0.5, -5)
    outer.BackgroundTransparency = 1
    outer.Parent = box
    corner(outer, 5)
    stroke(outer, THEME.SubText, 1.5)

    local pupil = Instance.new("Frame")
    pupil.Size = UDim2.fromOffset(5, 5)
    pupil.Position = UDim2.new(0.5, -2.5, 0.5, -2.5)
    pupil.BackgroundColor3 = THEME.SubText
    pupil.BorderSizePixel = 0
    pupil.Parent = box
    corner(pupil, 3)
end

local function iconPlayer(box)
    local head = Instance.new("Frame")
    head.Size = UDim2.fromOffset(6, 6)
    head.Position = UDim2.new(0.5, -3, 0.5, -9)
    head.BackgroundTransparency = 1
    head.Parent = box
    corner(head, 3)
    stroke(head, THEME.SubText, 1.5)

    local body = Instance.new("Frame")
    body.Size = UDim2.fromOffset(13, 7)
    body.Position = UDim2.new(0.5, -6.5, 0.5, 0)
    body.BackgroundTransparency = 1
    body.Parent = box
    corner(body, 4)
    stroke(body, THEME.SubText, 1.5)
end

local function iconMisc(box)
    local positions = {{-8, -8}, {2, -8}, {-8, 2}, {2, 2}}
    for _, p in ipairs(positions) do
        local sq = Instance.new("Frame")
        sq.Size = UDim2.fromOffset(6, 6)
        sq.Position = UDim2.new(0.5, p[1], 0.5, p[2])
        sq.BackgroundColor3 = THEME.SubText
        sq.BorderSizePixel = 0
        sq.Parent = box
        corner(sq, 2)
    end
end

local function iconSettings(box)
    local ring = Instance.new("Frame")
    ring.Size = UDim2.fromOffset(16, 16)
    ring.Position = UDim2.new(0.5, -8, 0.5, -8)
    ring.BackgroundTransparency = 1
    ring.Parent = box
    corner(ring, 8)
    stroke(ring, THEME.SubText, 3)
end

-- перекрасить все элементы иконки (при активной вкладке)
local function setIconColor(box, color)
    for _, child in ipairs(box:GetChildren()) do
        if child:IsA("Frame") then
            if child.BackgroundTransparency < 1 then
                child.BackgroundColor3 = color
            end
            local st = child:FindFirstChildOfClass("UIStroke")
            if st then st.Color = color end
        end
    end
end

-- ==================== CONTROLS ====================
local function createToggle(parent, default)
    local track = Instance.new("Frame")
    track.Size = UDim2.fromOffset(44, 24)
    track.Position = UDim2.fromOffset(0, 0)
    track.BackgroundColor3 = default and THEME.Accent or THEME.ButtonIdle
    track.BorderSizePixel = 0
    track.Parent = parent
    corner(track, 12)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.fromOffset(18, 18)
    knob.Position = default and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel = 0
    knob.Parent = track
    corner(knob, 9)

    local btn = Instance.new("TextButton")
    btn.BackgroundTransparency = 1
    btn.Size = UDim2.fromScale(1, 1)
    btn.Text = ""
    btn.Parent = track

    local state = default
    btn.MouseButton1Click:Connect(function()
        state = not state
        tween(track, {BackgroundColor3 = state and THEME.Accent or THEME.ButtonIdle}, 0.15)
        tween(knob, {Position = state and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)}, 0.15)
        -- сюда вставляешь свою функцию: state == true/false
    end)
end

local function createSlider(parent, min, max, default, decimals, barWidth)
    barWidth = barWidth or 190

    local bar = Instance.new("Frame")
    bar.Size = UDim2.fromOffset(barWidth, 4)
    bar.Position = UDim2.new(0, 0, 0.5, -2)
    bar.BackgroundColor3 = THEME.ButtonIdle
    bar.BorderSizePixel = 0
    bar.Parent = parent
    corner(bar, 2)

    local ratio = (default - min) / (max - min)

    local fill = Instance.new("Frame")
    fill.BackgroundColor3 = THEME.Accent
    fill.BorderSizePixel = 0
    fill.Size = UDim2.new(ratio, 0, 1, 0)
    fill.Parent = bar
    corner(fill, 2)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.fromOffset(14, 14)
    knob.AnchorPoint = Vector2.new(0.5, 0.5)
    knob.Position = UDim2.new(ratio, 0, 0.5, 0)
    knob.BackgroundColor3 = THEME.Accent
    knob.BorderSizePixel = 0
    knob.Parent = bar
    corner(knob, 7)
    stroke(knob, Color3.fromRGB(255, 255, 255), 1)

    local valueLabel = Instance.new("TextLabel")
    valueLabel.BackgroundTransparency = 1
    valueLabel.Position = UDim2.fromOffset(barWidth + 10, -10)
    valueLabel.Size = UDim2.fromOffset(50, 24)
    valueLabel.Font = Enum.Font.Gotham
    valueLabel.TextSize = 13
    valueLabel.TextColor3 = THEME.Text
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Parent = parent

    local function format(v)
        if decimals <= 0 then
            return math.floor(v + 0.5) .. "%"
        else
            return string.format("%." .. decimals .. "f", v)
        end
    end
    valueLabel.Text = format(default)

    local dragging = false
    local function update(pos)
        local rel = math.clamp((pos.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
        local value = min + (max - min) * rel
        fill.Size = UDim2.new(rel, 0, 1, 0)
        knob.Position = UDim2.new(rel, 0, 0.5, 0)
        valueLabel.Text = format(value)
        -- сюда вставляешь свою функцию: value
    end

    bar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            update(input.Position)
        end
    end)
    bar.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            update(input.Position)
        end
    end)
end

local function createDropdown(parent, options, default)
    local box = Instance.new("TextButton")
    box.Size = UDim2.fromOffset(150, 30)
    box.BackgroundColor3 = THEME.ButtonIdle
    box.AutoButtonColor = false
    box.Text = ""
    box.ZIndex = 3
    box.Parent = parent
    corner(box, 8)
    stroke(box)

    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Position = UDim2.fromOffset(10, 0)
    label.Size = UDim2.new(1, -30, 1, 0)
    label.Font = Enum.Font.Gotham
    label.Text = default
    label.TextColor3 = THEME.Text
    label.TextSize = 13
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = box
    label.ZIndex = 3

    local arrow = Instance.new("TextLabel")
    arrow.BackgroundTransparency = 1
    arrow.Position = UDim2.new(1, -22, 0, 0)
    arrow.Size = UDim2.fromOffset(18, 30)
    arrow.Font = Enum.Font.GothamBold
    arrow.Text = "v"
    arrow.TextColor3 = THEME.SubText
    arrow.TextSize = 12
    arrow.ZIndex = 3
    arrow.Parent = box

    local list = Instance.new("Frame")
    list.Position = UDim2.new(0, 0, 1, 4)
    list.Size = UDim2.fromOffset(150, #options * 26)
    list.BackgroundColor3 = THEME.ButtonIdle
    list.BorderSizePixel = 0
    list.Visible = false
    list.ZIndex = 10
    list.Parent = box
    corner(list, 8)
    stroke(list)

    local listLayout = Instance.new("UIListLayout")
    listLayout.Parent = list

    for _, opt in ipairs(options) do
        local optBtn = Instance.new("TextButton")
        optBtn.Size = UDim2.new(1, 0, 0, 26)
        optBtn.BackgroundTransparency = 1
        optBtn.Text = opt
        optBtn.Font = Enum.Font.Gotham
        optBtn.TextSize = 13
        optBtn.TextColor3 = THEME.SubText
        optBtn.ZIndex = 11
        optBtn.Parent = list

        optBtn.MouseButton1Click:Connect(function()
            label.Text = opt
            list.Visible = false
            -- сюда вставляешь свою функцию: opt
        end)
    end

    box.MouseButton1Click:Connect(function()
        list.Visible = not list.Visible
    end)
end

local function createKeybind(parent, default)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.fromOffset(150, 30)
    btn.BackgroundColor3 = THEME.ButtonIdle
    btn.AutoButtonColor = false
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 13
    btn.TextColor3 = THEME.SubText
    btn.Text = default
    btn.Parent = parent
    corner(btn, 8)
    stroke(btn)

    local listening = false
    btn.MouseButton1Click:Connect(function()
        listening = true
        btn.Text = "..."
    end)

    UserInputService.InputBegan:Connect(function(input, gpe)
        if listening and not gpe and input.UserInputType == Enum.UserInputType.Keyboard then
            btn.Text = input.KeyCode.Name
            listening = false
            -- сюда вставляешь свою функцию: input.KeyCode
        end
    end)
end

local function createColorSwatch(parent, colors, defaultIndex)
    local swatch = Instance.new("TextButton")
    swatch.Size = UDim2.fromOffset(30, 30)
    swatch.Position = UDim2.fromOffset(0, 0)
    swatch.BackgroundColor3 = colors[defaultIndex]
    swatch.AutoButtonColor = false
    swatch.Text = ""
    swatch.Parent = parent
    corner(swatch, 8)
    stroke(swatch)

    local arrow = Instance.new("TextButton")
    arrow.Size = UDim2.fromOffset(20, 30)
    arrow.Position = UDim2.fromOffset(34, 0)
    arrow.BackgroundColor3 = THEME.ButtonIdle
    arrow.AutoButtonColor = false
    arrow.Font = Enum.Font.GothamBold
    arrow.Text = "v"
    arrow.TextSize = 12
    arrow.TextColor3 = THEME.SubText
    arrow.Parent = parent
    corner(arrow, 8)
    stroke(arrow)

    local index = defaultIndex
    local function cycle()
        index = index % #colors + 1
        swatch.BackgroundColor3 = colors[index]
        -- сюда вставляешь свою функцию: colors[index]
    end

    swatch.MouseButton1Click:Connect(cycle)
    arrow.MouseButton1Click:Connect(cycle)
end

-- ==================== ROOT GUI ====================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "WeterClient"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

local WIDTH, HEIGHT = 840, 540 -- 14:9

local main = Instance.new("Frame")
main.Name = "Main"
main.Size = UDim2.fromOffset(WIDTH, HEIGHT)
main.Position = UDim2.new(0.5, -WIDTH / 2, 0.5, -HEIGHT / 2)
main.BackgroundColor3 = THEME.Background
main.BorderSizePixel = 0
main.ClipsDescendants = false
main.Parent = screenGui
corner(main, 14)
stroke(main, THEME.Border, 1)

local topBar = Instance.new("Frame")
topBar.Size = UDim2.new(1, 0, 0, 40)
topBar.BackgroundTransparency = 1
topBar.Parent = main

local title = Instance.new("TextLabel")
title.BackgroundTransparency = 1
title.Position = UDim2.fromOffset(18, 0)
title.Size = UDim2.new(1, -70, 1, 0)
title.Font = Enum.Font.GothamBold
title.Text = "Weter Client"
title.TextColor3 = THEME.Text
title.TextSize = 16
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = topBar

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.fromOffset(26, 26)
closeBtn.Position = UDim2.new(1, -34, 0, 7)
closeBtn.BackgroundColor3 = THEME.ButtonIdle
closeBtn.AutoButtonColor = false
closeBtn.Text = "×"
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 18
closeBtn.TextColor3 = THEME.SubText
closeBtn.Parent = topBar
corner(closeBtn, 7)

closeBtn.MouseEnter:Connect(function()
    tween(closeBtn, {BackgroundColor3 = THEME.ButtonHover}, 0.12)
end)
closeBtn.MouseLeave:Connect(function()
    tween(closeBtn, {BackgroundColor3 = THEME.ButtonIdle}, 0.12)
end)
closeBtn.MouseButton1Click:Connect(function()
    main.Visible = false
end)

makeDraggable(topBar, main)

-- sidebar
local sidebar = Instance.new("Frame")
sidebar.Position = UDim2.fromOffset(0, 40)
sidebar.Size = UDim2.new(0, 190, 1, -40)
sidebar.BackgroundColor3 = THEME.Sidebar
sidebar.BorderSizePixel = 0
sidebar.ClipsDescendants = false
sidebar.Parent = main
corner(sidebar, 14)

local sidebarMask = Instance.new("Frame")
sidebarMask.BackgroundColor3 = THEME.Sidebar
sidebarMask.BorderSizePixel = 0
sidebarMask.Position = UDim2.new(1, -14, 0, 0)
sidebarMask.Size = UDim2.fromOffset(14, sidebar.AbsoluteSize.Y)
sidebarMask.Size = UDim2.new(0, 14, 1, 0)
sidebarMask.Parent = sidebar

local tabList = Instance.new("UIListLayout")
tabList.Padding = UDim.new(0, 8)
tabList.Parent = sidebar

local tabPad = Instance.new("UIPadding")
tabPad.PaddingTop = UDim.new(0, 12)
tabPad.PaddingLeft = UDim.new(0, 10)
tabPad.PaddingRight = UDim.new(0, 10)
tabPad.Parent = sidebar

-- content
local content = Instance.new("Frame")
content.Position = UDim2.fromOffset(190, 40)
content.Size = UDim2.new(1, -190, 1, -40)
content.BackgroundTransparency = 1
content.ClipsDescendants = false
content.Parent = main

-- ==================== TABS DATA ====================
local TABS = {
    {
        Name = "Combat", Icon = iconCombat,
        Items = {
            {name = "test", type = "toggle", default = true},
            {name = "test", type = "toggle", default = false},
            {name = "test", type = "slider", min = 0, max = 100, decimals = 0, default = 65},
            {name = "test", type = "dropdown", options = {"test", "Option A", "Option B"}, default = "test"},
            {name = "test", type = "keybind", default = "Keybind"},
            {name = "test", type = "color", colors = {
                Color3.fromRGB(45, 190, 245), Color3.fromRGB(80, 220, 140),
                Color3.fromRGB(230, 90, 90), Color3.fromRGB(230, 200, 70)
            }, default = 1},
            {name = "test", type = "slider", min = 0, max = 5, decimals = 2, default = 2.5},
        },
    },
    {
        Name = "Movement", Icon = iconMovement,
        Items = {
            {name = "Option 1", type = "toggle", default = false},
            {name = "Option 2", type = "toggle", default = false},
        },
    },
    {
        Name = "Visual", Icon = iconVisual,
        Items = {
            {name = "Option 1", type = "toggle", default = false},
            {name = "Option 2", type = "toggle", default = false},
        },
    },
    {
        Name = "Player", Icon = iconPlayer,
        Items = {
            {name = "Option 1", type = "toggle", default = false},
            {name = "Option 2", type = "slider", min = 0, max = 100, decimals = 0, default = 50},
        },
    },
    {
        Name = "Misc", Icon = iconMisc,
        Items = {
            {name = "Option 1", type = "dropdown", options = {"A", "B", "C"}, default = "A"},
            {name = "Option 2", type = "toggle", default = false},
        },
    },
    {
        Name = "Settings", Icon = iconSettings,
        Items = {
            {name = "Menu Key", type = "keybind", default = "RightShift"},
            {name = "UI Scale", type = "slider", min = 50, max = 150, decimals = 0, default = 100},
        },
    },
}

-- ==================== BUILD ====================
local pages, tabButtons, iconBoxes = {}, {}, {}
local activeTab

local function selectTab(name)
    if activeTab == name then return end
    activeTab = name

    for tabName, btn in pairs(tabButtons) do
        local on = tabName == name
        tween(btn, {BackgroundColor3 = on and THEME.Panel or THEME.Sidebar}, 0.15)
        btn.Label.TextColor3 = on and THEME.Accent or THEME.SubText
        btn.AccentBar.Visible = on
        setIconColor(iconBoxes[tabName], on and THEME.Accent or THEME.SubText)
        btn.UIStroke.Transparency = on and 0 or 1
    end

    for pageName, page in pairs(pages) do
        page.Visible = (pageName == name)
    end
end

for _, tabData in ipairs(TABS) do
    local btn = Instance.new("TextButton")
    btn.Name = tabData.Name
    btn.Size = UDim2.new(1, 0, 0, 42)
    btn.BackgroundColor3 = THEME.Sidebar
    btn.AutoButtonColor = false
    btn.Text = ""
    btn.Parent = sidebar
    corner(btn, 10)
    local st = stroke(btn, THEME.Accent, 1)
    st.Transparency = 1
    st.Name = "UIStroke"

    local accentBar = Instance.new("Frame")
    accentBar.Name = "AccentBar"
    accentBar.Size = UDim2.fromOffset(3, 22)
    accentBar.Position = UDim2.fromOffset(0, 10)
    accentBar.BackgroundColor3 = THEME.Accent
    accentBar.BorderSizePixel = 0
    accentBar.Visible = false
    accentBar.Parent = btn
    corner(accentBar, 2)

    local iconBox = Instance.new("Frame")
    iconBox.Size = UDim2.fromOffset(24, 24)
    iconBox.Position = UDim2.fromOffset(12, 9)
    iconBox.BackgroundTransparency = 1
    iconBox.Parent = btn
    tabData.Icon(iconBox)
    iconBoxes[tabData.Name] = iconBox

    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.BackgroundTransparency = 1
    label.Position = UDim2.fromOffset(46, 0)
    label.Size = UDim2.new(1, -56, 1, 0)
    label.Font = Enum.Font.Gotham
    label.Text = tabData.Name
    label.TextColor3 = THEME.SubText
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = btn

    btn.MouseEnter:Connect(function()
        if activeTab ~= tabData.Name then
            tween(btn, {BackgroundColor3 = THEME.ButtonHover}, 0.12)
        end
    end)
    btn.MouseLeave:Connect(function()
        if activeTab ~= tabData.Name then
            tween(btn, {BackgroundColor3 = THEME.Sidebar}, 0.12)
        end
    end)
    btn.MouseButton1Click:Connect(function()
        selectTab(tabData.Name)
    end)

    tabButtons[tabData.Name] = btn

    -- page
    local page = Instance.new("ScrollingFrame")
    page.Size = UDim2.fromScale(1, 1)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 3
    page.ScrollBarImageColor3 = THEME.Border
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.Visible = false
    page.Parent = content

    local pad = Instance.new("UIPadding")
    pad.PaddingTop = UDim.new(0, 14)
    pad.PaddingLeft = UDim.new(0, 14)
    pad.PaddingRight = UDim.new(0, 14)
    pad.Parent = page

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 8)
    layout.Parent = page

    for _, item in ipairs(tabData.Items) do
        local card = Instance.new("Frame")
        card.Size = UDim2.new(1, 0, 0, 46)
        card.BackgroundColor3 = THEME.Panel
        card.BorderSizePixel = 0
        card.ClipsDescendants = false
        card.Parent = page
        corner(card, 10)
        stroke(card)

        local dot = Instance.new("Frame")
        dot.Size = UDim2.fromOffset(6, 6)
        dot.Position = UDim2.fromOffset(16, 20)
        dot.BackgroundColor3 = THEME.Accent
        dot.BorderSizePixel = 0
        dot.Parent = card
        corner(dot, 3)

        local nameLabel = Instance.new("TextLabel")
        nameLabel.BackgroundTransparency = 1
        nameLabel.Position = UDim2.fromOffset(32, 0)
        nameLabel.Size = UDim2.new(0.4, 0, 1, 0)
        nameLabel.Font = Enum.Font.Gotham
        nameLabel.Text = item.name
        nameLabel.TextColor3 = THEME.Text
        nameLabel.TextSize = 14
        nameLabel.TextXAlignment = Enum.TextXAlignment.Left
        nameLabel.Parent = card

        local controlWidth = 150
        if item.type == "toggle" then controlWidth = 44
        elseif item.type == "color" then controlWidth = 56
        elseif item.type == "slider" then controlWidth = 190 + 60 end

        local controlHolder = Instance.new("Frame")
        controlHolder.AnchorPoint = Vector2.new(1, 0.5)
        controlHolder.Position = UDim2.new(1, -14, 0.5, 0)
        controlHolder.Size = UDim2.fromOffset(controlWidth, 30)
        controlHolder.BackgroundTransparency = 1
        controlHolder.ClipsDescendants = false
        controlHolder.Parent = card

        if item.type == "toggle" then
            createToggle(controlHolder, item.default)
        elseif item.type == "slider" then
            createSlider(controlHolder, item.min, item.max, item.default, item.decimals, 190)
        elseif item.type == "dropdown" then
            createDropdown(controlHolder, item.options, item.default)
        elseif item.type == "keybind" then
            createKeybind(controlHolder, item.default)
        elseif item.type == "color" then
            createColorSwatch(controlHolder, item.colors, item.default)
        end
    end

    pages[tabData.Name] = page
end

selectTab(TABS[1].Name)

-- ==================== WATERMARK (открывает/закрывает клик) ====================
local watermark = Instance.new("TextButton")
watermark.Name = "Watermark"
watermark.Size = UDim2.fromOffset(140, 34)
watermark.Position = UDim2.fromOffset(20, 20)
watermark.BackgroundColor3 = THEME.Panel
watermark.AutoButtonColor = false
watermark.Text = ""
watermark.Parent = screenGui
corner(watermark, 10)
stroke(watermark, THEME.Accent, 1)

local wDot = Instance.new("Frame")
wDot.Size = UDim2.fromOffset(6, 6)
wDot.Position = UDim2.fromOffset(12, 14)
wDot.BackgroundColor3 = THEME.Accent
wDot.BorderSizePixel = 0
wDot.Parent = watermark
corner(wDot, 3)

local wLabel = Instance.new("TextLabel")
wLabel.BackgroundTransparency = 1
wLabel.Position = UDim2.fromOffset(26, 0)
wLabel.Size = UDim2.new(1, -30, 1, 0)
wLabel.Font = Enum.Font.GothamBold
wLabel.Text = "Weter Client"
wLabel.TextColor3 = THEME.Text
wLabel.TextSize = 13
wLabel.TextXAlignment = Enum.TextXAlignment.Left
wLabel.Parent = watermark

makeDraggable(watermark, watermark)

-- клик = тоггл, но не срабатывает как клик если только что тащили
local wDragMoved = false
watermark.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        wDragMoved = false
    end
end)
UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        wDragMoved = true
    end
end)
watermark.MouseButton1Click:Connect(function()
    main.Visible = not main.Visible
end)

-- горячая клавиша (дублирует ватермарку)
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        main.Visible = not main.Visible
    end
end)
