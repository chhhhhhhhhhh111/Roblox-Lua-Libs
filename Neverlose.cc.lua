local Neverlose = {}
Neverlose.__index = Neverlose

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

function Neverlose:GetIcons8Url(iconName, hexColor, size)
    size = size or 30
    hexColor = hexColor or "ffffff"
    return string.format("https://img.icons8.com/ios-glyphs/%d/%s/%s.png", size, hexColor, iconName)
end

Neverlose.Icons = {
    Rage = Neverlose:GetIcons8Url("target", "0099ff"),
    AntiAim = Neverlose:GetIcons8Url("rotate", "0099ff"),
    Legit = Neverlose:GetIcons8Url("mouse", "0099ff"),
    Players = Neverlose:GetIcons8Url("user", "0099ff"),
    Weapon = Neverlose:GetIcons8Url("rifle", "0099ff"),
    Grenades = Neverlose:GetIcons8Url("grenade", "0099ff"),
    World = Neverlose:GetIcons8Url("globe", "0099ff"),
    View = Neverlose:GetIcons8Url("binoculars", "0099ff"),
    Main = Neverlose:GetIcons8Url("wrench", "0099ff"),
    Inventory = Neverlose:GetIcons8Url("box", "0099ff"),
    Scripts = Neverlose:GetIcons8Url("code", "0099ff"),
    Configs = Neverlose:GetIcons8Url("settings", "0099ff"),
    ChevronDown = Neverlose:GetIcons8Url("chevron-down", "ffffff")
}

Neverlose.Themes = {
    Dark = {
        MainBg = Color3.fromRGB(12, 12, 15),
        SidebarBg = Color3.fromRGB(8, 8, 10),
        CardBg = Color3.fromRGB(16, 17, 20),
        ElementBg = Color3.fromRGB(24, 25, 30),
        TextColor = Color3.fromRGB(240, 240, 245),
        SubTextColor = Color3.fromRGB(110, 115, 130),
        BorderColor = Color3.fromRGB(35, 37, 45)
    },
    Light = {
        MainBg = Color3.fromRGB(240, 242, 245),
        SidebarBg = Color3.fromRGB(225, 228, 235),
        CardBg = Color3.fromRGB(255, 255, 255),
        ElementBg = Color3.fromRGB(230, 233, 240),
        TextColor = Color3.fromRGB(20, 22, 28),
        SubTextColor = Color3.fromRGB(100, 105, 120),
        BorderColor = Color3.fromRGB(210, 215, 225)
    }
}

Neverlose.CurrentTheme = "Dark"
Neverlose.AccentColor = Color3.fromRGB(0, 153, 255)
Neverlose.AccentRegistry = {}
Neverlose.ThemeRegistry = {}

local function GetAsset(url, filename, fallback)
    if getcustomasset and writefile and isfile then
        filename = "nl_" .. filename
        if not isfile(filename) then
            pcall(function() writefile(filename, game:HttpGet(url)) end)
        end
        if isfile(filename) then
            return getcustomasset(filename)
        end
    end
    return fallback or url
end

local function GetContainer()
    local success, result = pcall(function() return CoreGui end)
    if success and result then return result end
    return LocalPlayer:WaitForChild("PlayerGui")
end

local function Tween(obj, time, props)
    local info = TweenInfo.new(time, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local t = TweenService:Create(obj, info, props)
    t:Play()
    return t
end

local function MakeDraggable(gui, handle)
    local dragging, dragInput, dragStart, startPos
    handle = handle or gui

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = gui.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            Tween(gui, 0.05, {
                Position = UDim2.new(
                    startPos.X.Scale, startPos.X.Offset + delta.X,
                    startPos.Y.Scale, startPos.Y.Offset + delta.Y
                )
            })
        end
    end)
end

function Neverlose:RegisterAccent(obj, property)
    table.insert(Neverlose.AccentRegistry, { Object = obj, Property = property })
    obj[property] = Neverlose.AccentColor
end

function Neverlose:RegisterTheme(obj, property, themeKey)
    table.insert(Neverlose.ThemeRegistry, { Object = obj, Property = property, Key = themeKey })
    local theme = Neverlose.Themes[Neverlose.CurrentTheme]
    if theme and theme[themeKey] then
        obj[property] = theme[themeKey]
    end
end

function Neverlose:SetAccentColor(color)
    Neverlose.AccentColor = color
    for _, item in ipairs(Neverlose.AccentRegistry) do
        if item.Object and item.Object.Parent then
            Tween(item.Object, 0.2, { [item.Property] = color })
        end
    end
end

function Neverlose:SetTheme(themeName)
    if not Neverlose.Themes[themeName] then return end
    Neverlose.CurrentTheme = themeName
    local theme = Neverlose.Themes[themeName]
    for _, item in ipairs(Neverlose.ThemeRegistry) do
        if item.Object and item.Object.Parent and theme[item.Key] then
            Tween(item.Object, 0.25, { [item.Property] = theme[item.Key] })
        end
    end
end

function Neverlose:CreateWindow(config)
    config = config or {}
    local windowTitle = config.Title or "Neverlose"
    local toggleKey = config.ToggleKey or Enum.KeyCode.Insert

    local parent = GetContainer()
    if parent:FindFirstChild("NeverloseUI") then
        parent.NeverloseUI:Destroy()
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "NeverloseUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = parent

    -- Кнопка для мобильных
    local MobileToggleButton = Instance.new("TextButton")
    MobileToggleButton.Name = "MobileToggleButton"
    MobileToggleButton.Size = UDim2.new(0, 44, 0, 44)
    MobileToggleButton.Position = UDim2.new(0, 15, 0.5, -22)
    MobileToggleButton.Text = "NL"
    MobileToggleButton.Font = Enum.Font.GothamBold
    MobileToggleButton.TextSize = 16
    MobileToggleButton.ZIndex = 999
    MobileToggleButton.Parent = ScreenGui

    Neverlose:RegisterTheme(MobileToggleButton, "BackgroundColor3", "MainBg")
    Neverlose:RegisterAccent(MobileToggleButton, "TextColor3")

    local MobileBtnCorner = Instance.new("UICorner")
    MobileBtnCorner.CornerRadius = UDim.new(0, 8)
    MobileBtnCorner.Parent = MobileToggleButton

    MakeDraggable(MobileToggleButton, MobileToggleButton)

    -- Главный фрейм UI
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 780, 0, 520)
    MainFrame.Position = UDim2.new(0.5, -390, 0.5, -260)
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui

    Neverlose:RegisterTheme(MainFrame, "BackgroundColor3", "MainBg")

    local function ToggleMenuVisibility()
        MainFrame.Visible = not MainFrame.Visible
    end

    MobileToggleButton.MouseButton1Click:Connect(ToggleMenuVisibility)

    UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == toggleKey then
            ToggleMenuVisibility()
        end
    end)

    -- Сайдбар
    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Size = UDim2.new(0, 200, 1, 0)
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = MainFrame
    Neverlose:RegisterTheme(Sidebar, "BackgroundColor3", "SidebarBg")

    local LogoLabel = Instance.new("TextLabel")
    LogoLabel.Size = UDim2.new(1, -30, 0, 45)
    LogoLabel.Position = UDim2.new(0, 15, 0, 5)
    LogoLabel.Text = string.upper(windowTitle)
    LogoLabel.Font = Enum.Font.GothamBlack
    LogoLabel.TextSize = 20
    LogoLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    LogoLabel.TextXAlignment = Enum.TextXAlignment.Left
    LogoLabel.BackgroundTransparency = 1
    LogoLabel.Parent = Sidebar

    local TabButtonContainer = Instance.new("ScrollingFrame")
    TabButtonContainer.Size = UDim2.new(1, 0, 1, -115)
    TabButtonContainer.Position = UDim2.new(0, 0, 0, 55)
    TabButtonContainer.BackgroundTransparency = 1
    TabButtonContainer.ScrollBarThickness = 0
    TabButtonContainer.Parent = Sidebar

    local TabListLayout = Instance.new("UIListLayout")
    TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabListLayout.Padding = UDim.new(0, 2)
    TabListLayout.Parent = TabButtonContainer

    local TabPadding = Instance.new("UIPadding")
    TabPadding.PaddingLeft = UDim.new(0, 10)
    TabPadding.PaddingRight = UDim.new(0, 10)
    TabPadding.Parent = TabButtonContainer

    -- Профиль пользователя
    local ProfileFrame = Instance.new("Frame")
    ProfileFrame.Size = UDim2.new(1, -20, 0, 48)
    ProfileFrame.Position = UDim2.new(0, 10, 1, -55)
    ProfileFrame.BackgroundTransparency = 1
    ProfileFrame.Parent = Sidebar

    local AvatarImage = Instance.new("ImageLabel")
    AvatarImage.Size = UDim2.new(0, 32, 0, 32)
    AvatarImage.Position = UDim2.new(0, 4, 0.5, -16)
    AvatarImage.BackgroundTransparency = 1
    AvatarImage.Parent = ProfileFrame

    local AvatarCorner = Instance.new("UICorner")
    AvatarCorner.CornerRadius = UDim.new(1, 0)
    AvatarCorner.Parent = AvatarImage

    task.spawn(function()
        if LocalPlayer then
            local content, isReady = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
            if isReady then AvatarImage.Image = content end
        end
    end)

    local DisplayNameLabel = Instance.new("TextLabel")
    DisplayNameLabel.Size = UDim2.new(1, -45, 0, 16)
    DisplayNameLabel.Position = UDim2.new(0, 42, 0, 7)
    DisplayNameLabel.Text = LocalPlayer and LocalPlayer.DisplayName or "User"
    DisplayNameLabel.Font = Enum.Font.GothamBold
    DisplayNameLabel.TextSize = 11
    DisplayNameLabel.TextXAlignment = Enum.TextXAlignment.Left
    DisplayNameLabel.TextTruncate = Enum.TextTruncate.AtEnd
    DisplayNameLabel.BackgroundTransparency = 1
    DisplayNameLabel.Parent = ProfileFrame
    Neverlose:RegisterTheme(DisplayNameLabel, "TextColor3", "TextColor")

    local TillLabel = Instance.new("TextLabel")
    TillLabel.Size = UDim2.new(1, -45, 0, 14)
    TillLabel.Position = UDim2.new(0, 42, 0, 23)
    TillLabel.Text = "Till: LIFETIME"
    TillLabel.Font = Enum.Font.GothamBold
    TillLabel.TextSize = 10
    TillLabel.TextXAlignment = Enum.TextXAlignment.Left
    TillLabel.BackgroundTransparency = 1
    TillLabel.Parent = ProfileFrame
    Neverlose:RegisterAccent(TillLabel, "TextColor3")

    -- Шапка
    local Header = Instance.new("Frame")
    Header.Size = UDim2.new(1, -200, 0, 45)
    Header.Position = UDim2.new(0, 200, 0, 0)
    Header.BackgroundTransparency = 1
    Header.Parent = MainFrame

    MakeDraggable(MainFrame, Header)

    local SaveBtn = Instance.new("TextButton")
    SaveBtn.Size = UDim2.new(0, 55, 0, 22)
    SaveBtn.Position = UDim2.new(0, 15, 0.5, -11)
    SaveBtn.Text = "💾 Save"
    SaveBtn.Font = Enum.Font.GothamMedium
    SaveBtn.TextSize = 10
    SaveBtn.Parent = Header
    Neverlose:RegisterTheme(SaveBtn, "BackgroundColor3", "ElementBg")
    Neverlose:RegisterTheme(SaveBtn, "TextColor3", "TextColor")

    local SaveCorner = Instance.new("UICorner")
    SaveCorner.CornerRadius = UDim.new(0, 4)
    SaveCorner.Parent = SaveBtn

    local SettingsIcon = Instance.new("TextButton")
    SettingsIcon.Size = UDim2.new(0, 24, 0, 24)
    SettingsIcon.Position = UDim2.new(1, -65, 0.5, -12)
    SettingsIcon.Text = "⚙"
    SettingsIcon.Font = Enum.Font.GothamBold
    SettingsIcon.TextSize = 14
    SettingsIcon.BackgroundTransparency = 1
    SettingsIcon.Parent = Header
    Neverlose:RegisterTheme(SettingsIcon, "TextColor3", "SubTextColor")

    local SearchIcon = Instance.new("TextButton")
    SearchIcon.Size = UDim2.new(0, 24, 0, 24)
    SearchIcon.Position = UDim2.new(1, -35, 0.5, -12)
    SearchIcon.Text = "🔍"
    SearchIcon.Font = Enum.Font.GothamBold
    SearchIcon.TextSize = 12
    SearchIcon.BackgroundTransparency = 1
    SearchIcon.Parent = Header
    Neverlose:RegisterTheme(SearchIcon, "TextColor3", "SubTextColor")

    local ContentArea = Instance.new("Frame")
    ContentArea.Size = UDim2.new(1, -200, 1, -45)
    ContentArea.Position = UDim2.new(0, 200, 0, 45)
    ContentArea.BackgroundTransparency = 1
    ContentArea.Parent = MainFrame

    local WindowObj = {
        Screen = ScreenGui,
        Main = MainFrame,
        Tabs = {},
        Categories = {},
        AllElements = {},
        ContentArea = ContentArea
    }

    function WindowObj:CreateTab(opts)
        opts = opts or {}
        local name = opts.Name or "Tab"
        local category = opts.Category or "GENERAL"
        local icon = opts.Icon or Neverlose.Icons.Rage

        if not WindowObj.Categories[category] then
            local CatLabel = Instance.new("TextLabel")
            CatLabel.Size = UDim2.new(1, 0, 0, 22)
            CatLabel.Text = category
            CatLabel.Font = Enum.Font.GothamBold
            CatLabel.TextSize = 10
            CatLabel.TextXAlignment = Enum.TextXAlignment.Left
            CatLabel.BackgroundTransparency = 1
            CatLabel.Parent = TabButtonContainer
            Neverlose:RegisterTheme(CatLabel, "TextColor3", "SubTextColor")

            WindowObj.Categories[category] = true
        end

        local TabButton = Instance.new("Frame")
        TabButton.Size = UDim2.new(1, 0, 0, 30)
        TabButton.BackgroundTransparency = 1
        TabButton.Parent = TabButtonContainer
        Neverlose:RegisterTheme(TabButton, "BackgroundColor3", "ElementBg")

        local TabBtnCorner = Instance.new("UICorner")
        TabBtnCorner.CornerRadius = UDim.new(0, 6)
        TabBtnCorner.Parent = TabButton

        local TabClickBtn = Instance.new("TextButton")
        TabClickBtn.Size = UDim2.new(1, 0, 1, 0)
        TabClickBtn.BackgroundTransparency = 1
        TabClickBtn.Text = ""
        TabClickBtn.Parent = TabButton

        local IconImg = Instance.new("ImageLabel")
        IconImg.Size = UDim2.new(0, 14, 0, 14)
        IconImg.Position = UDim2.new(0, 10, 0.5, -7)
        IconImg.BackgroundTransparency = 1
        IconImg.Image = GetAsset(icon, "tab_icon.png")
        IconImg.Parent = TabButton
        Neverlose:RegisterAccent(IconImg, "ImageColor3")

        local TabTitleLabel = Instance.new("TextLabel")
        TabTitleLabel.Size = UDim2.new(1, -34, 1, 0)
        TabTitleLabel.Position = UDim2.new(0, 30, 0, 0)
        TabTitleLabel.Text = name
        TabTitleLabel.Font = Enum.Font.GothamMedium
        TabTitleLabel.TextSize = 11
        TabTitleLabel.TextXAlignment = Enum.TextXAlignment.Left
        TabTitleLabel.BackgroundTransparency = 1
        TabTitleLabel.Parent = TabButton
        Neverlose:RegisterTheme(TabTitleLabel, "TextColor3", "SubTextColor")

        local TabPage = Instance.new("Frame")
        TabPage.Size = UDim2.new(1, 0, 1, 0)
        TabPage.BackgroundTransparency = 1
        TabPage.Visible = false
        TabPage.Parent = ContentArea

        local LeftColumn = Instance.new("ScrollingFrame")
        LeftColumn.Size = UDim2.new(0.5, -12, 1, -10)
        LeftColumn.Position = UDim2.new(0, 8, 0, 0)
        LeftColumn.BackgroundTransparency = 1
        LeftColumn.ScrollBarThickness = 0
        LeftColumn.AutomaticCanvasSize = Enum.AutomaticSize.Y
        LeftColumn.CanvasSize = UDim2.new(0, 0, 0, 0)
        LeftColumn.Parent = TabPage

        local RightColumn = Instance.new("ScrollingFrame")
        RightColumn.Size = UDim2.new(0.5, -12, 1, -10)
        RightColumn.Position = UDim2.new(0.5, 4, 0, 0)
        RightColumn.BackgroundTransparency = 1
        RightColumn.ScrollBarThickness = 0
        RightColumn.AutomaticCanvasSize = Enum.AutomaticSize.Y
        RightColumn.CanvasSize = UDim2.new(0, 0, 0, 0)
        RightColumn.Parent = TabPage

        local LeftLayout = Instance.new("UIListLayout")
        LeftLayout.SortOrder = Enum.SortOrder.LayoutOrder
        LeftLayout.Padding = UDim.new(0, 10)
        LeftLayout.Parent = LeftColumn

        local RightLayout = Instance.new("UIListLayout")
        RightLayout.SortOrder = Enum.SortOrder.LayoutOrder
        RightLayout.Padding = UDim.new(0, 10)
        RightLayout.Parent = RightColumn

        local TabObj = { Button = TabButton, Page = TabPage }

        TabClickBtn.MouseButton1Click:Connect(function()
            for _, t in pairs(WindowObj.Tabs) do
                Tween(t.Button, 0.15, {BackgroundTransparency = 1})
                t.Page.Visible = false
            end
            Tween(TabButton, 0.15, {BackgroundTransparency = 0})
            TabPage.Visible = true
        end)

        if #WindowObj.Tabs == 0 then
            TabButton.BackgroundTransparency = 0
            TabPage.Visible = true
        end

        table.insert(WindowObj.Tabs, TabObj)

        function TabObj:CreateSection(sectionTitle, side)
            local parentCol = (side and side:lower() == "right") and RightColumn or LeftColumn

            local SectionFrame = Instance.new("Frame")
            SectionFrame.Size = UDim2.new(1, 0, 0, 0)
            SectionFrame.AutomaticSize = Enum.AutomaticSize.Y
            SectionFrame.BorderSizePixel = 0
            SectionFrame.Parent = parentCol
            Neverlose:RegisterTheme(SectionFrame, "BackgroundColor3", "CardBg")

            local SecCorner = Instance.new("UICorner")
            SecCorner.CornerRadius = UDim.new(0, 6)
            SecCorner.Parent = SectionFrame

            local Title = Instance.new("TextLabel")
            Title.Size = UDim2.new(1, -20, 0, 24)
            Title.Position = UDim2.new(0, 10, 0, 6)
            Title.Text = sectionTitle
            Title.Font = Enum.Font.GothamBold
            Title.TextSize = 13
            Title.TextXAlignment = Enum.TextXAlignment.Left
            Title.BackgroundTransparency = 1
            Title.Parent = SectionFrame
            Neverlose:RegisterTheme(Title, "TextColor3", "TextColor")

            local Line = Instance.new("Frame")
            Line.Size = UDim2.new(1, -20, 0, 1)
            Line.Position = UDim2.new(0, 10, 0, 32)
            Line.BorderSizePixel = 0
            Line.Parent = SectionFrame
            Neverlose:RegisterTheme(Line, "BackgroundColor3", "BorderColor")

            local ItemHolder = Instance.new("Frame")
            ItemHolder.Size = UDim2.new(1, -20, 0, 0)
            ItemHolder.Position = UDim2.new(0, 10, 0, 38)
            ItemHolder.AutomaticSize = Enum.AutomaticSize.Y
            ItemHolder.BackgroundTransparency = 1
            ItemHolder.Parent = SectionFrame

            local ItemLayout = Instance.new("UIListLayout")
            ItemLayout.SortOrder = Enum.SortOrder.LayoutOrder
            ItemLayout.Padding = UDim.new(0, 8)
            ItemLayout.Parent = ItemHolder

            local HolderPadding = Instance.new("UIPadding")
            HolderPadding.PaddingBottom = UDim.new(0, 10)
            HolderPadding.Parent = ItemHolder

            local SectionObj = {}

            -- 1. TOGGLE
            function SectionObj:CreateToggle(opts)
                opts = opts or {}
                local name = opts.Name or "Toggle"
                local state = opts.Default or false
                local callback = opts.Callback or function() end
                local hasColor = opts.HasColor or false
                local colorDefault = opts.ColorDefault or Neverlose.AccentColor

                local ToggleFrame = Instance.new("Frame")
                ToggleFrame.Size = UDim2.new(1, 0, 0, 24)
                ToggleFrame.BackgroundTransparency = 1
                ToggleFrame.Parent = ItemHolder

                table.insert(WindowObj.AllElements, { Name = name, Frame = ToggleFrame })

                local Label = Instance.new("TextButton")
                Label.Size = UDim2.new(1, hasColor and -65 or -40, 1, 0)
                Label.Text = name
                Label.Font = Enum.Font.GothamMedium
                Label.TextSize = 11
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.BackgroundTransparency = 1
                Label.Parent = ToggleFrame
                Neverlose:RegisterTheme(Label, "TextColor3", "TextColor")

                local SwitchBg = Instance.new("TextButton")
                SwitchBg.Size = UDim2.new(0, 32, 0, 16)
                SwitchBg.Position = UDim2.new(1, -32, 0.5, -8)
                SwitchBg.Text = ""
                SwitchBg.Parent = ToggleFrame
                Neverlose:RegisterTheme(SwitchBg, "BackgroundColor3", "ElementBg")

                local SwitchCorner = Instance.new("UICorner")
                SwitchCorner.CornerRadius = UDim.new(1, 0)
                SwitchCorner.Parent = SwitchBg

                local Circle = Instance.new("Frame")
                Circle.Size = UDim2.new(0, 12, 0, 12)
                Circle.Position = state and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6)
                Circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                Circle.Parent = SwitchBg

                local CircleCorner = Instance.new("UICorner")
                CircleCorner.CornerRadius = UDim.new(1, 0)
                CircleCorner.Parent = Circle

                local function SetToggleState(newState)
                    state = newState
                    if state then
                        Tween(SwitchBg, 0.15, {BackgroundColor3 = Neverlose.AccentColor})
                    else
                        local theme = Neverlose.Themes[Neverlose.CurrentTheme]
                        Tween(SwitchBg, 0.15, {BackgroundColor3 = theme.ElementBg})
                    end
                    Tween(Circle, 0.15, {Position = state and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6)})
                    callback(state)
                end

                if state then SetToggleState(true) end

                SwitchBg.MouseButton1Click:Connect(function() SetToggleState(not state) end)
                Label.MouseButton1Click:Connect(function() SetToggleState(not state) end)

                if hasColor then
                    local ColorBtn = Instance.new("TextButton")
                    ColorBtn.Size = UDim2.new(0, 16, 0, 12)
                    ColorBtn.Position = UDim2.new(1, -54, 0.5, -6)
                    ColorBtn.BackgroundColor3 = colorDefault
                    ColorBtn.Text = ""
                    ColorBtn.Parent = ToggleFrame

                    local CBCorner = Instance.new("UICorner")
                    CBCorner.CornerRadius = UDim.new(0, 3)
                    CBCorner.Parent = ColorBtn
                end
            end

            -- 2. SLIDER
            function SectionObj:CreateSlider(opts)
                opts = opts or {}
                local name = opts.Name or "Slider"
                local min = opts.Min or 0
                local max = opts.Max or 100
                local val = opts.Default or min
                local suffix = opts.Suffix or ""
                local callback = opts.Callback or function() end

                local SliderFrame = Instance.new("Frame")
                SliderFrame.Size = UDim2.new(1, 0, 0, 28)
                SliderFrame.BackgroundTransparency = 1
                SliderFrame.Parent = ItemHolder

                table.insert(WindowObj.AllElements, { Name = name, Frame = SliderFrame })

                local Label = Instance.new("TextLabel")
                Label.Size = UDim2.new(0.35, 0, 1, 0)
                Label.Text = name
                Label.Font = Enum.Font.GothamMedium
                Label.TextSize = 11
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.BackgroundTransparency = 1
                Label.Parent = SliderFrame
                Neverlose:RegisterTheme(Label, "TextColor3", "TextColor")

                local ValBox = Instance.new("Frame")
                ValBox.Size = UDim2.new(0, 36, 0, 18)
                ValBox.Position = UDim2.new(1, -36, 0.5, -9)
                ValBox.Parent = SliderFrame
                Neverlose:RegisterTheme(ValBox, "BackgroundColor3", "ElementBg")

                local ValBoxCorner = Instance.new("UICorner")
                ValBoxCorner.CornerRadius = UDim.new(0, 3)
                ValBoxCorner.Parent = ValBox

                local ValBoxStroke = Instance.new("UIStroke")
                ValBoxStroke.Thickness = 1
                ValBoxStroke.Parent = ValBox
                Neverlose:RegisterTheme(ValBoxStroke, "Color", "BorderColor")

                local ValLabel = Instance.new("TextLabel")
                ValLabel.Size = UDim2.new(1, 0, 1, 0)
                ValLabel.Text = tostring(val)
                ValLabel.Font = Enum.Font.GothamMedium
                ValLabel.TextSize = 10
                ValLabel.Parent = ValBox
                Neverlose:RegisterTheme(ValLabel, "TextColor3", "SubTextColor")

                local Track = Instance.new("TextButton")
                Track.Size = UDim2.new(0.65, -50, 0, 4)
                Track.Position = UDim2.new(0.35, 5, 0.5, -2)
                Track.Text = ""
                Track.Parent = SliderFrame
                Neverlose:RegisterTheme(Track, "BackgroundColor3", "ElementBg")

                local TrackCorner = Instance.new("UICorner")
                TrackCorner.CornerRadius = UDim.new(1, 0)
                TrackCorner.Parent = Track

                local Fill = Instance.new("Frame")
                Fill.Size = UDim2.new((val - min) / (max - min), 0, 1, 0)
                Fill.Parent = Track
                Neverlose:RegisterAccent(Fill, "BackgroundColor3")

                local FillCorner = Instance.new("UICorner")
                FillCorner.CornerRadius = UDim.new(1, 0)
                FillCorner.Parent = Fill

                local Thumb = Instance.new("Frame")
                Thumb.Size = UDim2.new(0, 10, 0, 10)
                Thumb.Position = UDim2.new(1, -5, 0.5, -5)
                Thumb.Parent = Fill
                Neverlose:RegisterAccent(Thumb, "BackgroundColor3")

                local ThumbCorner = Instance.new("UICorner")
                ThumbCorner.CornerRadius = UDim.new(1, 0)
                ThumbCorner.Parent = Thumb

                local dragging = false
                local function Update(input)
                    local percent = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
                    val = math.floor(min + (max - min) * percent)
                    ValLabel.Text = tostring(val) .. suffix
                    Tween(Fill, 0.05, {Size = UDim2.new(percent, 0, 1, 0)})
                    callback(val)
                end

                Track.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = true Update(input)
                    end
                end)

                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = false
                    end
                end)

                UserInputService.InputChanged:Connect(function(input)
                    if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                        Update(input)
                    end
                end)
            end

            -- 3. DROPDOWN
            function SectionObj:CreateDropdown(opts)
                opts = opts or {}
                local name = opts.Name or "Dropdown"
                local options = opts.Options or {}
                local selected = opts.Default or options[1] or "None"
                local callback = opts.Callback or function() end

                local DropFrame = Instance.new("Frame")
                DropFrame.Size = UDim2.new(1, 0, 0, 42)
                DropFrame.BackgroundTransparency = 1
                DropFrame.ZIndex = 5
                DropFrame.Parent = ItemHolder

                table.insert(WindowObj.AllElements, { Name = name, Frame = DropFrame })

                local Label = Instance.new("TextLabel")
                Label.Size = UDim2.new(1, 0, 0, 16)
                Label.Text = name
                Label.Font = Enum.Font.GothamMedium
                Label.TextSize = 11
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.BackgroundTransparency = 1
                Label.Parent = DropFrame
                Neverlose:RegisterTheme(Label, "TextColor3", "TextColor")

                local Box = Instance.new("TextButton")
                Box.Size = UDim2.new(1, 0, 0, 22)
                Box.Position = UDim2.new(0, 0, 0, 18)
                Box.Text = "  " .. selected
                Box.Font = Enum.Font.Gotham
                Box.TextSize = 10
                Box.TextXAlignment = Enum.TextXAlignment.Left
                Box.ZIndex = 6
                Box.Parent = DropFrame
                Neverlose:RegisterTheme(Box, "BackgroundColor3", "ElementBg")
                Neverlose:RegisterTheme(Box, "TextColor3", "TextColor")

                local BoxCorner = Instance.new("UICorner")
                BoxCorner.CornerRadius = UDim.new(0, 4)
                BoxCorner.Parent = Box

                local ArrowIcon = Instance.new("ImageLabel")
                ArrowIcon.Size = UDim2.new(0, 10, 0, 10)
                ArrowIcon.Position = UDim2.new(1, -18, 0.5, -5)
                ArrowIcon.BackgroundTransparency = 1
                ArrowIcon.Image = GetAsset(Neverlose.Icons.ChevronDown, "chevron.png")
                ArrowIcon.ZIndex = 7
                ArrowIcon.Parent = Box

                local Container = Instance.new("Frame")
                Container.Size = UDim2.new(1, 0, 0, #options * 22)
                Container.Position = UDim2.new(0, 0, 1, 4)
                Container.Visible = false
                Container.ZIndex = 30
                Container.Parent = Box
                Neverlose:RegisterTheme(Container, "BackgroundColor3", "CardBg")

                local CCorner = Instance.new("UICorner")
                CCorner.CornerRadius = UDim.new(0, 4)
                CCorner.Parent = Container

                local CLayout = Instance.new("UIListLayout")
                CLayout.SortOrder = Enum.SortOrder.LayoutOrder
                CLayout.Parent = Container

                local open = false
                for _, opt in ipairs(options) do
                    local OptBtn = Instance.new("TextButton")
                    OptBtn.Size = UDim2.new(1, 0, 0, 22)
                    OptBtn.BackgroundTransparency = 1
                    OptBtn.Text = "  " .. opt
                    OptBtn.Font = Enum.Font.Gotham
                    OptBtn.TextSize = 10
                    OptBtn.TextXAlignment = Enum.TextXAlignment.Left
                    OptBtn.ZIndex = 31
                    OptBtn.Parent = Container
                    Neverlose:RegisterTheme(OptBtn, "TextColor3", "SubTextColor")

                    OptBtn.MouseButton1Click:Connect(function()
                        selected = opt
                        Box.Text = "  " .. selected
                        Container.Visible = false
                        open = false
                        callback(selected)
                    end)
                end

                Box.MouseButton1Click:Connect(function()
                    open = not open
                    Container.Visible = open
                end)
            end

            -- 4. COLOR PICKER
            function SectionObj:CreateColorPicker(opts)
                opts = opts or {}
                local name = opts.Name or "Color"
                local currentColor = opts.Default or Neverlose.AccentColor
                local callback = opts.Callback or function() end

                local ColorFrame = Instance.new("Frame")
                ColorFrame.Size = UDim2.new(1, 0, 0, 24)
                ColorFrame.BackgroundTransparency = 1
                ColorFrame.Parent = ItemHolder

                table.insert(WindowObj.AllElements, { Name = name, Frame = ColorFrame })

                local Label = Instance.new("TextLabel")
                Label.Size = UDim2.new(1, -30, 1, 0)
                Label.Text = name
                Label.Font = Enum.Font.GothamMedium
                Label.TextSize = 11
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.BackgroundTransparency = 1
                Label.Parent = ColorFrame
                Neverlose:RegisterTheme(Label, "TextColor3", "TextColor")

                local ColorBox = Instance.new("TextButton")
                ColorBox.Size = UDim2.new(0, 20, 0, 12)
                ColorBox.Position = UDim2.new(1, -20, 0.5, -6)
                ColorBox.BackgroundColor3 = currentColor
                ColorBox.Text = ""
                ColorBox.Parent = ColorFrame

                local BoxCorner = Instance.new("UICorner")
                BoxCorner.CornerRadius = UDim.new(0, 3)
                BoxCorner.Parent = ColorBox

                ColorBox.MouseButton1Click:Connect(function()
                    callback(currentColor)
                end)
            end

            return SectionObj
        end

        return TabObj
    end

    return WindowObj
end

return Neverlose
