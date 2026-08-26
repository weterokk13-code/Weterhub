--[[
    Weter Hub — UI Framework (заготовка, без функций)
    LocalScript

    Стиль: как популярные хаб-меню (тёмная панель, сайдбар с иконками,
    группы переключателей, зелёные тумблеры, вкладки "Общее"/"Кнопки",
    поиск, отдельная кнопка-пилюля "Weter Hub" над гуи для открытия/закрытия).
--]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")

-- ==================== THEME ====================
local THEME = {
    Background  = Color3.fromRGB(15, 16, 19),
    Panel       = Color3.fromRGB(20, 22, 26),
    Sidebar     = Color3.fromRGB(12, 13, 16),
    RowIdle     = Color3.fromRGB(24, 26, 30),
    RowHover    = Color3.fromRGB(30, 33, 38),
    Active      = Color3.fromRGB(40, 43, 49),
    Accent      = Color3.fromRGB(60, 200, 120),  -- зелёный, как на референсе
    Text        = Color3.fromRGB(230, 232, 236),
    SubText     = Color3.fromRGB(135, 140, 148),
    Border      = Color3.fromRGB(32, 35, 40),
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

local function tween(inst, props, time)
    local t = TweenService:Create(inst, TweenInfo.new(time or 0.15, Enum.EasingStyle.Quad), props)
    t:Play()
    return t
end

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

-- ==================== ICONS ====================
local function iconHome(box)
    local roof = Instance.new("Frame")
    roof.Size = UDim2.fromOffset(9, 9)
    roof.Position = UDim2.new(0.5, -4.5, 0.5, -8)
    roof.Rotation = 45
    roof.BackgroundTransparency = 1
    roof.Parent = box
    stroke(roof, THEME.SubText, 1.5)

    local base = Instance.new("Frame")
    base.Size = UDim2.fromOffset(11, 8)
    base.Position = UDim2.new(0.5, -5.5, 0.5, -1)
    base.BackgroundTransparency = 1
    base.Parent = box
    corner(base, 2)
    stroke(base, THEME.SubText, 1.5)
end

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

local function smallGear(parent)
    local box = Instance.new("Frame")
    box.Size = UDim2.fromOffset(18, 18)
    box.BackgroundTransparency = 1
    box.Parent = parent
    local ring = Instance.new("Frame")
    ring.Size = UDim2.fromOffset(12, 12)
    ring.Position = UDim2.new(0.5, -6, 0.5, -6)
    ring.BackgroundTransparency = 1
    ring.Parent = box
    corner(ring, 6)
    stroke(ring, THEME.SubText, 2)
    return box
end

-- ==================== CONTROLS ====================
local function createToggle(parent, default)
    local track = Instance.new("Frame")
    track.Size = UDim2.fromOffset(42, 22)
    track.BackgroundColor3 = default and THEME.Accent or THEME.RowIdle
    track.BorderSizePixel = 0
    track.Parent = parent
    corner(track, 11)
    stroke(track, THEME.Border, 1)

    local knob = Instance.new("Frame")
    knob.Size = UDim2.fromOffset(16, 16)
    knob.Position = default and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)
    knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    knob.BorderSizePixel = 0
    knob.Parent = track
    corner(knob, 8)

    local btn = Instance.new("TextButton")
    btn.BackgroundTransparency = 1
    btn.Size = UDim2.fromScale(1, 1)
    btn.Text = ""
    btn.Parent = track

    local state = default
    btn.MouseButton1Click:Connect(function()
        state = not state
        tween(track, {BackgroundColor3 = state and THEME.Accent or THEME.RowIdle}, 0.15)
        tween(knob, {Position = state and UDim2.new(1, -19, 0.5, -8) or UDim2.new(0, 3, 0.5, -8)}, 0.15)
        -- сюда вставляешь свою функцию
    end)
end

local function createBindButton(parent, default)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.fromOffset(64, 26)
    btn.BackgroundColor3 = THEME.RowIdle
    btn.AutoButtonColor = false
    btn.Font = Enum.Font.Gotham
    btn.TextSize = 12
    btn.TextColor3 = THEME.SubText
    btn.Text = default
    btn.Parent = parent
    corner(btn, 7)
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
        end
    end)
    return btn
end

-- строка: [gear] Label ...... [Bind?] [toggle]
local function createRow(parent, item)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 36)
    row.BackgroundTransparency = 1
    row.Parent = parent

    local gearHolder = Instance.new("Frame")
    gearHolder.Size = UDim2.fromOffset(18, 18)
    gearHolder.Position = UDim2.new(0, 0, 0.5, -9)
    gearHolder.BackgroundTransparency = 1
    gearHolder.Parent = row
    smallGear(gearHolder)

    local label = Instance.new("TextLabel")
    label.BackgroundTransparency = 1
    label.Position = UDim2.fromOffset(28, 0)
    label.Size = UDim2.new(1, -160, 1, 0)
    label.Font = Enum.Font.Gotham
    label.Text = item.name
    label.TextColor3 = THEME.Text
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = row

    local toggleHolder = Instance.new("Frame")
    toggleHolder.AnchorPoint = Vector2.new(1, 0.5)
    toggleHolder.Position = UDim2.new(1, 0, 0.5, 0)
    toggleHolder.Size = UDim2.fromOffset(42, 22)
    toggleHolder.BackgroundTransparency = 1
    toggleHolder.Parent = row
    createToggle(toggleHolder, item.default)

    if item.bind then
        local bindHolder = Instance.new("Frame")
        bindHolder.AnchorPoint = Vector2.new(1, 0.5)
        bindHolder.Position = UDim2.new(1, -54, 0.5, 0)
        bindHolder.Size = UDim2.fromOffset(64, 26)
        bindHolder.BackgroundTransparency = 1
        bindHolder.Parent = row
        createBindButton(bindHolder, "Bind")
    end
end

local function createGroup(parent, title, items)
    local group = Instance.new("Frame")
    group.Size = UDim2.new(0.5, -6, 0, 40 + #items * 36 + 14)
    group.BackgroundColor3 = THEME.Panel
    group.BorderSizePixel = 0
    group.Parent = parent
    corner(group, 12)
    stroke(group)

    local pad = Instance.new("UIPadding")
    pad.PaddingTop = UDim.new(0, 14)
    pad.PaddingLeft = UDim.new(0, 14)
    pad.PaddingRight = UDim.new(0, 14)
    pad.Parent = group

    local titleLabel = Instance.new("TextLabel")
    titleLabel.BackgroundTransparency = 1
    titleLabel.Size = UDim2.new(1, 0, 0, 24)
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.Text = title
    titleLabel.TextColor3 = THEME.Text
    titleLabel.TextSize = 15
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = group

    local list = Instance.new("Frame")
    list.Position = UDim2.fromOffset(0, 30)
    list.Size = UDim2.new(1, 0, 1, -30)
    list.BackgroundTransparency = 1
    list.Parent = group

    local layout = Instance.new("UIListLayout")
    layout.Padding = UDim.new(0, 4)
    layout.Parent = list

    for _, item in ipairs(items) do
        createRow(list, item)
    end

    return group
end

-- ==================== ROOT GUI ====================
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "WeterHub"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = playerGui

local WIDTH, HEIGHT = 940, 580

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

-- ---------- collapse arrow (слева от панели) ----------
local collapseBtn = Instance.new("TextButton")
collapseBtn.Size = UDim2.fromOffset(26, 46)
collapseBtn.Position = UDim2.fromOffset(-34, HEIGHT / 2 - 23)
collapseBtn.BackgroundColor3 = THEME.Panel
collapseBtn.AutoButtonColor = false
collapseBtn.Font = Enum.Font.GothamBold
collapseBtn.Text = "‹"
collapseBtn.TextSize = 18
collapseBtn.TextColor3 = THEME.SubText
collapseBtn.Parent = main
corner(collapseBtn, 8)
stroke(collapseBtn)

collapseBtn.MouseButton1Click:Connect(function()
    main.Visible = false
end)

-- ---------- header ----------
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 56)
header.BackgroundTransparency = 1
header.Parent = main

local logo = Instance.new("Frame")
logo.Size = UDim2.fromOffset(36, 36)
logo.Position = UDim2.fromOffset(16, 10)
logo.BackgroundColor3 = THEME.Panel
logo.Parent = header
corner(logo, 10)
stroke(logo, THEME.Accent, 1.5)

local logoDot = Instance.new("Frame")
logoDot.Size = UDim2.fromOffset(10, 10)
logoDot.Position = UDim2.new(0.5, -5, 0.5, -5)
logoDot.BackgroundColor3 = THEME.Accent
logoDot.BorderSizePixel = 0
logoDot.Parent = logo
corner(logoDot, 5)

local titleLabel = Instance.new("TextLabel")
titleLabel.BackgroundTransparency = 1
titleLabel.Position = UDim2.fromOffset(62, 8)
titleLabel.Size = UDim2.fromOffset(160, 20)
titleLabel.Font = Enum.Font.GothamBold
titleLabel.Text = "Weter Hub"
titleLabel.TextColor3 = THEME.Text
titleLabel.TextSize = 16
titleLabel.TextXAlignment = Enum.TextXAlignment.Left
titleLabel.Parent = header

local subLabel = Instance.new("TextLabel")
subLabel.BackgroundTransparency = 1
subLabel.Position = UDim2.fromOffset(62, 28)
subLabel.Size = UDim2.fromOffset(160, 16)
subLabel.Font = Enum.Font.Gotham
subLabel.Text = "v0.1"
subLabel.TextColor3 = THEME.SubText
subLabel.TextSize = 12
subLabel.TextXAlignment = Enum.TextXAlignment.Left
subLabel.Parent = header

-- верхние вкладки Общее / Кнопки
local sectionTabs = {}
local activeSection = "general"

local generalTabBtn = Instance.new("TextButton")
generalTabBtn.Size = UDim2.fromOffset(110, 34)
generalTabBtn.Position = UDim2.new(0.5, -230, 0, 11)
generalTabBtn.BackgroundColor3 = THEME.Active
generalTabBtn.AutoButtonColor = false
generalTabBtn.Font = Enum.Font.GothamBold
generalTabBtn.Text = "Общее"
generalTabBtn.TextSize = 13
generalTabBtn.TextColor3 = THEME.Text
generalTabBtn.Parent = header
corner(generalTabBtn, 8)

local bindsTabBtn = Instance.new("TextButton")
bindsTabBtn.Size = UDim2.fromOffset(110, 34)
bindsTabBtn.Position = UDim2.new(0.5, -114, 0, 11)
bindsTabBtn.BackgroundColor3 = THEME.Panel
bindsTabBtn.AutoButtonColor = false
bindsTabBtn.Font = Enum.Font.GothamBold
bindsTabBtn.Text = "Кнопки"
bindsTabBtn.TextSize = 13
bindsTabBtn.TextColor3 = THEME.SubText
bindsTabBtn.Parent = header
corner(bindsTabBtn, 8)

-- поисковая строка
local searchBox = Instance.new("Frame")
searchBox.Size = UDim2.fromOffset(240, 34)
searchBox.Position = UDim2.new(1, -300, 0, 11)
searchBox.BackgroundColor3 = THEME.Panel
searchBox.Parent = header
corner(searchBox, 8)
stroke(searchBox)

local searchInput = Instance.new("TextBox")
searchInput.BackgroundTransparency = 1
searchInput.Position = UDim2.fromOffset(14, 0)
searchInput.Size = UDim2.new(1, -28, 1, 0)
searchInput.Font = Enum.Font.Gotham
searchInput.PlaceholderText = "Поиск..."
searchInput.Text = ""
searchInput.TextColor3 = THEME.Text
searchInput.PlaceholderColor3 = THEME.SubText
searchInput.TextSize = 13
searchInput.TextXAlignment = Enum.TextXAlignment.Left
searchInput.ClearTextOnFocus = false
searchInput.Parent = searchBox

-- закрыть (крестик)
local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.fromOffset(34, 34)
closeBtn.Position = UDim2.new(1, -50, 0, 11)
closeBtn.BackgroundColor3 = THEME.Panel
closeBtn.AutoButtonColor = false
closeBtn.Font = Enum.Font.GothamBold
closeBtn.Text = "×"
closeBtn.TextSize = 18
closeBtn.TextColor3 = THEME.SubText
closeBtn.Parent = header
corner(closeBtn, 8)
stroke(closeBtn)

closeBtn.MouseEnter:Connect(function() tween(closeBtn, {BackgroundColor3 = THEME.RowHover}, 0.12) end)
closeBtn.MouseLeave:Connect(function() tween(closeBtn, {BackgroundColor3 = THEME.Panel}, 0.12) end)
closeBtn.MouseButton1Click:Connect(function()
    main.Visible = false
end)

makeDraggable(header, main)

-- ---------- sidebar ----------
local sidebar = Instance.new("ScrollingFrame")
sidebar.Position = UDim2.fromOffset(0, 56)
sidebar.Size = UDim2.new(0, 220, 1, -56)
sidebar.BackgroundColor3 = THEME.Sidebar
sidebar.BorderSizePixel = 0
sidebar.ScrollBarThickness = 3
sidebar.ScrollBarImageColor3 = THEME.Border
sidebar.CanvasSize = UDim2.new(0, 0, 0, 0)
sidebar.AutomaticCanvasSize = Enum.AutomaticSize.Y
sidebar.Parent = main
corner(sidebar, 14)

local sidebarMask = Instance.new("Frame")
sidebarMask.BackgroundColor3 = THEME.Sidebar
sidebarMask.BorderSizePixel = 0
sidebarMask.Position = UDim2.new(1, -14, 0, 0)
sidebarMask.Size = UDim2.new(0, 14, 1, 0)
sidebarMask.Parent = sidebar

local sideList = Instance.new("UIListLayout")
sideList.Padding = UDim.new(0, 6)
sideList.Parent = sidebar

local sidePad = Instance.new("UIPadding")
sidePad.PaddingTop = UDim.new(0, 12)
sidePad.PaddingLeft = UDim.new(0, 10)
sidePad.PaddingRight = UDim.new(0, 10)
sidePad.Parent = sidebar

-- ---------- content ----------
local content = Instance.new("Frame")
content.Position = UDim2.fromOffset(220, 56)
content.Size = UDim2.new(1, -220, 1, -56)
content.BackgroundTransparency = 1
content.ClipsDescendants = false
content.Parent = main

-- ==================== DATA ====================
local SECTIONS = {
    {Name = "Главная", Icon = iconHome, Items = {
        {name = "Option 1", default = false}, {name = "Option 2", default = false},
    }},
    {Name = "Combat", Icon = iconCombat, Items = {
        {name = "Option 1", default = true}, {name = "Option 2", default = true},
        {name = "Option 3", default = false}, {name = "Option 4", default = false, bind = true},
        {name = "Option 5", default = false},
    }},
    {Name = "Movement", Icon = iconMovement, Items = {
        {name = "Option 1", default = false}, {name = "Option 2", default = false},
        {name = "Option 3", default = false},
    }},
    {Name = "Visual", Icon = iconVisual, Items = {
        {name = "Option 1", default = true}, {name = "Option 2", default = false},
    }},
    {Name = "Player", Icon = iconPlayer, Items = {
        {name = "Option 1", default = false}, {name = "Option 2", default = false},
    }},
    {Name = "Misc", Icon = iconMisc, Items = {
        {name = "Option 1", default = false}, {name = "Option 2", default = false, bind = true},
    }},
    {Name = "Settings", Icon = iconSettings, Items = {
        {name = "Menu Key", default = false, bind = true}, {name = "Option 2", default = false},
    }},
}

-- разбивает список пунктов на 2 колонки-группы
local function splitInTwo(items)
    local a, b = {}, {}
    for i, item in ipairs(items) do
        if i % 2 == 1 then table.insert(a, item) else table.insert(b, item) end
    end
    return a, b
end

-- ==================== BUILD ====================
local pages = {}
local sideButtons = {}
local activePage

local function selectSection(name)
    if activePage == name then return end
    activePage = name

    for secName, btn in pairs(sideButtons) do
        local on = secName == name
        tween(btn, {BackgroundColor3 = on and THEME.Active or THEME.Sidebar}, 0.15)
        btn.Label.TextColor3 = on and THEME.Text or THEME.SubText
        btn.Chevron.Rotation = on and 90 or 0
    end

    for pageName, page in pairs(pages) do
        page.general.Visible = (pageName == name) and (activeSection == "general")
        page.binds.Visible = (pageName == name) and (activeSection == "binds")
    end
end

local function setSection(sec)
    activeSection = sec
    tween(generalTabBtn, {BackgroundColor3 = sec == "general" and THEME.Active or THEME.Panel}, 0.12)
    generalTabBtn.TextColor3 = sec == "general" and THEME.Text or THEME.SubText
    tween(bindsTabBtn, {BackgroundColor3 = sec == "binds" and THEME.Active or THEME.Panel}, 0.12)
    bindsTabBtn.TextColor3 = sec == "binds" and THEME.Text or THEME.SubText

    for pageName, page in pairs(pages) do
        local isActive = pageName == activePage
        page.general.Visible = isActive and sec == "general"
        page.binds.Visible = isActive and sec == "binds"
    end
end

generalTabBtn.MouseButton1Click:Connect(function() setSection("general") end)
bindsTabBtn.MouseButton1Click:Connect(function() setSection("binds") end)

for _, sec in ipairs(SECTIONS) do
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 42)
    btn.BackgroundColor3 = THEME.Sidebar
    btn.AutoButtonColor = false
    btn.Text = ""
    btn.Parent = sidebar
    corner(btn, 10)

    local iconBox = Instance.new("Frame")
    iconBox.Size = UDim2.fromOffset(22, 22)
    iconBox.Position = UDim2.fromOffset(10, 10)
    iconBox.BackgroundTransparency = 1
    iconBox.Parent = btn
    sec.Icon(iconBox)

    local label = Instance.new("TextLabel")
    label.Name = "Label"
    label.BackgroundTransparency = 1
    label.Position = UDim2.fromOffset(42, 0)
    label.Size = UDim2.new(1, -66, 1, 0)
    label.Font = Enum.Font.Gotham
    label.Text = sec.Name
    label.TextColor3 = THEME.SubText
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = btn

    local chevron = Instance.new("TextLabel")
    chevron.Name = "Chevron"
    chevron.BackgroundTransparency = 1
    chevron.Position = UDim2.new(1, -26, 0, 0)
    chevron.Size = UDim2.fromOffset(20, 42)
    chevron.Font = Enum.Font.GothamBold
    chevron.Text = ">"
    chevron.TextSize = 12
    chevron.TextColor3 = THEME.SubText
    chevron.Parent = btn

    btn.MouseEnter:Connect(function()
        if activePage ~= sec.Name then tween(btn, {BackgroundColor3 = THEME.RowHover}, 0.12) end
    end)
    btn.MouseLeave:Connect(function()
        if activePage ~= sec.Name then tween(btn, {BackgroundColor3 = THEME.Sidebar}, 0.12) end
    end)
    btn.MouseButton1Click:Connect(function() selectSection(sec.Name) end)

    sideButtons[sec.Name] = btn

    -- страница "Общее": 2 колонки-группы
    local generalPage = Instance.new("Frame")
    generalPage.Size = UDim2.fromScale(1, 1)
    generalPage.BackgroundTransparency = 1
    generalPage.Visible = false
    generalPage.Parent = content

    local gPad = Instance.new("UIPadding")
    gPad.PaddingTop = UDim.new(0, 16)
    gPad.PaddingLeft = UDim.new(0, 16)
    gPad.PaddingRight = UDim.new(0, 16)
    gPad.Parent = generalPage

    local colHolder = Instance.new("Frame")
    colHolder.Size = UDim2.new(1, 0, 1, 0)
    colHolder.BackgroundTransparency = 1
    colHolder.Parent = generalPage

    local rowLayout = Instance.new("UIListLayout")
    rowLayout.FillDirection = Enum.FillDirection.Horizontal
    rowLayout.Padding = UDim.new(0, 12)
    rowLayout.Parent = colHolder

    local left, right = splitInTwo(sec.Items)
    createGroup(colHolder, "Group A", left)
    createGroup(colHolder, "Group B", right)

    -- страница "Кнопки": список бинд-строк
    local bindsPage = Instance.new("Frame")
    bindsPage.Size = UDim2.fromScale(1, 1)
    bindsPage.BackgroundTransparency = 1
    bindsPage.Visible = false
    bindsPage.Parent = content

    local bPad = Instance.new("UIPadding")
    bPad.PaddingTop = UDim.new(0, 16)
    bPad.PaddingLeft = UDim.new(0, 16)
    bPad.PaddingRight = UDim.new(0, 16)
    bPad.Parent = bindsPage

    local bindsGroup = Instance.new("Frame")
    bindsGroup.Size = UDim2.new(1, 0, 0, 40 + #sec.Items * 36 + 14)
    bindsGroup.BackgroundColor3 = THEME.Panel
    bindsGroup.BorderSizePixel = 0
    bindsGroup.Parent = bindsPage
    corner(bindsGroup, 12)
    stroke(bindsGroup)

    local bgPad = Instance.new("UIPadding")
    bgPad.PaddingTop = UDim.new(0, 14)
    bgPad.PaddingLeft = UDim.new(0, 14)
    bgPad.PaddingRight = UDim.new(0, 14)
    bgPad.Parent = bindsGroup

    local bgTitle = Instance.new("TextLabel")
    bgTitle.BackgroundTransparency = 1
    bgTitle.Size = UDim2.new(1, 0, 0, 24)
    bgTitle.Font = Enum.Font.GothamBold
    bgTitle.Text = "Клавиши"
    bgTitle.TextColor3 = THEME.Text
    bgTitle.TextSize = 15
    bgTitle.TextXAlignment = Enum.TextXAlignment.Left
    bgTitle.Parent = bindsGroup

    local bList = Instance.new("Frame")
    bList.Position = UDim2.fromOffset(0, 30)
    bList.Size = UDim2.new(1, 0, 1, -30)
    bList.BackgroundTransparency = 1
    bList.Parent = bindsGroup

    local bLayout = Instance.new("UIListLayout")
    bLayout.Padding = UDim.new(0, 4)
    bLayout.Parent = bList

    for _, item in ipairs(sec.Items) do
        createRow(bList, {name = item.name, default = false, bind = true})
    end

    pages[sec.Name] = {general = generalPage, binds = bindsPage}
end

selectSection(SECTIONS[1].Name)

-- ==================== WATERMARK / КНОПКА ОТКРЫТИЯ ====================
local pill = Instance.new("TextButton")
pill.Name = "WeterHubToggle"
pill.Size = UDim2.fromOffset(150, 36)
pill.Position = UDim2.fromOffset(20, 20)
pill.BackgroundColor3 = THEME.Panel
pill.AutoButtonColor = false
pill.Text = ""
pill.Parent = screenGui
corner(pill, 10)
stroke(pill, THEME.Accent, 1)

local pillDot = Instance.new("Frame")
pillDot.Size = UDim2.fromOffset(8, 8)
pillDot.Position = UDim2.fromOffset(14, 14)
pillDot.BackgroundColor3 = THEME.Accent
pillDot.BorderSizePixel = 0
pillDot.Parent = pill
corner(pillDot, 4)

local pillLabel = Instance.new("TextLabel")
pillLabel.BackgroundTransparency = 1
pillLabel.Position = UDim2.fromOffset(30, 0)
pillLabel.Size = UDim2.new(1, -36, 1, 0)
pillLabel.Font = Enum.Font.GothamBold
pillLabel.Text = "Weter Hub"
pillLabel.TextColor3 = THEME.Text
pillLabel.TextSize = 13
pillLabel.TextXAlignment = Enum.TextXAlignment.Left
pillLabel.Parent = pill

makeDraggable(pill, pill)

pill.MouseButton1Click:Connect(function()
    main.Visible = not main.Visible
end)

-- дублирующая горячая клавиша
UserInputService.InputBegan:Connect(function(input, gpe)
    if gpe then return end
    if input.KeyCode == Enum.KeyCode.RightShift then
        main.Visible = not main.Visible
    end
end)
