local Neverlose = {}
Neverlose.__index = Neverlose

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")

local LocalPlayer = Players.LocalPlayer

Neverlose.Icons = {
    Checkmark = "https://img.icons8.com/ios-glyphs/30/checkmark--v1.png",
    Color = "https://img.icons8.com/ios-glyphs/30/paint-palette--v1.png",
    Move = "https://img.icons8.com/ios-glyphs/60/move.png",
    Search = "https://img.icons8.com/ios-glyphs/30/search.png",
    ChevronDown = "https://img.icons8.com/ios-glyphs/30/chevron-down.png"
}

Neverlose.Themes = {
    Dark = {
        MainBg = Color3.fromRGB(10, 12, 18),
        MainTransparency = 0.25,
        SidebarBg = Color3.fromRGB(6, 7, 12),
        SidebarTransparency = 0.35,
        CardBg = Color3.fromRGB(15, 18, 26),
        CardTransparency = 0.4,
        ElementBg = Color3.fromRGB(22, 26, 38),
        ElementTransparency = 0.3,
        TextColor = Color3.fromRGB(235, 240, 250),
        SubTextColor = Color3.fromRGB(120, 130, 150),
        BorderColor = Color3.fromRGB(255, 255, 255),
        BorderTransparency = 0.93
    },
    Light = {
        MainBg = Color3.fromRGB(240, 242, 248),
        MainTransparency = 0.2,
        SidebarBg = Color3.fromRGB(225, 228, 238),
        SidebarTransparency = 0.25,
        CardBg = Color3.fromRGB(255, 255, 255),
        CardTransparency = 0.45,
        ElementBg = Color3.fromRGB(230, 235, 245),
        ElementTransparency = 0.35,
        TextColor = Color3.fromRGB(20, 25, 35),
        SubTextColor = Color3.fromRGB(100, 110, 125),
        BorderColor = Color3.fromRGB(0, 0, 0),
        BorderTransparency = 0.9
    }
}

Neverlose.CurrentTheme = "Dark"
Neverlose.AccentColor = Color3.fromRGB(0, 180, 255)
Neverlose.AccentRegistry = {}
Neverlose.ThemeRegistry = {}

local function GetAsset(url, filename, fallback)
    if getcustomasset and writefile and isfile then
        filename = "nl_glass_" .. filename
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

function Neverlose:RegisterTheme(obj, property, themeKey, transparencyKey)
    table.insert(Neverlose.ThemeRegistry, { Object = obj, Property = property, Key = themeKey, TransKey = transparencyKey })
    local theme = Neverlose.Themes[Neverlose.CurrentTheme]
    if theme and theme[themeKey] then
        obj[property] = theme[themeKey]
        if transparencyKey and theme[transparencyKey] then
            if property == "BackgroundColor3" then
                obj.BackgroundTransparency = theme[transparencyKey]
            elseif property == "Color" and obj:IsA("UIStroke") then
                obj.Transparency = theme[transparencyKey]
            end
        end
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
            if item.TransKey and theme[item.TransKey] then
                if item.Property == "BackgroundColor3" then
                    Tween(item.Object, 0.25, { BackgroundTransparency = theme[item.TransKey] })
                elseif item.Property == "Color" and item.Object:IsA("UIStroke") then
                    Tween(item.Object, 0.25, { Transparency = theme[item.TransKey] })
                end
            end
        end
    end
end

function Neverlose:CreateWindow(config)
    config = config or {}
    local windowTitle = config.Title or "Neverlose"
    local windowSubtitle = config.Subtitle or "Counter-Strike 2"
    local toggleKey = config.ToggleKey or Enum.KeyCode.Insert

    local parent = GetContainer()
    if parent:FindFirstChild("NeverloseUI") then
        parent.NeverloseUI:Destroy()
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "NeverloseUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = parent

    -- Кнопка открытия на мобильных
    local MobileToggleButton = Instance.new("TextButton")
    MobileToggleButton.Name = "MobileToggleButton"
    MobileToggleButton.Size = UDim2.new(0, 44, 0, 44)
    MobileToggleButton.Position = UDim2.new(0, 15, 0.5, -22)
    MobileToggleButton.Text = "NL"
    MobileToggleButton.Font = Enum.Font.GothamBold
    MobileToggleButton.TextSize = 16
    MobileToggleButton.ZIndex = 999
    MobileToggleButton.Parent = ScreenGui

    Neverlose:RegisterTheme(MobileToggleButton, "BackgroundColor3", "MainBg", "MainTransparency")
    Neverlose:RegisterAccent(MobileToggleButton, "TextColor3")

    local MobileBtnCorner = Instance.new("UICorner")
    MobileBtnCorner.CornerRadius = UDim.new(1, 0)
    MobileBtnCorner.Parent = MobileToggleButton

    local MobileBtnStroke = Instance.new("UIStroke")
    MobileBtnStroke.Thickness = 1.5
    MobileBtnStroke.Parent = MobileToggleButton
    Neverlose:RegisterAccent(MobileBtnStroke, "Color")

    MakeDraggable(MobileToggleButton, MobileToggleButton)

    -- Главное окно
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 760, 0, 530)
    MainFrame.Position = UDim2.new(0.5, -380, 0.5, -265)
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = false
    MainFrame.Parent = ScreenGui

    Neverlose:RegisterTheme(MainFrame, "BackgroundColor3", "MainBg", "MainTransparency")

    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 12)
    MainCorner.Parent = MainFrame

    local MainStroke = Instance.new("UIStroke")
    MainStroke.Thickness = 1
    MainStroke.Parent = MainFrame
    Neverlose:RegisterTheme(MainStroke, "Color", "BorderColor", "BorderTransparency")

    local function ToggleMenuVisibility()
        MainFrame.Visible = not MainFrame.Visible
    end

    MobileToggleButton.MouseButton1Click:Connect(ToggleMenuVisibility)

    UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == toggleKey then
            ToggleMenuVisibility()
        end
    end)

    -- Sidebar
    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Size = UDim2.new(0, 190, 1, 0)
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = MainFrame
    Neverlose:RegisterTheme(Sidebar, "BackgroundColor3", "SidebarBg", "SidebarTransparency")

    local SideCorner = Instance.new("UICorner")
    SideCorner.CornerRadius = UDim.new(0, 12)
    SideCorner.Parent = Sidebar

    local LogoFrame = Instance.new("Frame")
    LogoFrame.Size = UDim2.new(1, 0, 0, 65)
    LogoFrame.BackgroundTransparency = 1
    LogoFrame.Parent = Sidebar

    local LogoBadge = Instance.new("Frame")
    LogoBadge.Size = UDim2.new(0, 40, 0, 40)
    LogoBadge.Position = UDim2.new(0, 14, 0, 12)
    LogoBadge.Parent = LogoFrame
    Neverlose:RegisterTheme(LogoBadge, "BackgroundColor3", "ElementBg", "ElementTransparency")

    local LogoCorner = Instance.new("UICorner")
    LogoCorner.CornerRadius = UDim.new(0, 8)
    LogoCorner.Parent = LogoBadge

    local LogoText = Instance.new("TextLabel")
    LogoText.Size = UDim2.new(1, 0, 1, 0)
    LogoText.Text = "NL"
    LogoText.TextSize = 20
    LogoText.Font = Enum.Font.GothamBlack
    LogoText.BackgroundTransparency = 1
    LogoText.Parent = LogoBadge
    Neverlose:RegisterAccent(LogoText, "TextColor3")

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(0, 110, 0, 18)
    TitleLabel.Position = UDim2.new(0, 62, 0, 15)
    TitleLabel.Text = windowTitle
    TitleLabel.TextSize = 14
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Parent = LogoFrame
    Neverlose:RegisterTheme(TitleLabel, "TextColor3", "TextColor")

    local SubtitleLabel = Instance.new("TextLabel")
    SubtitleLabel.Size = UDim2.new(0, 110, 0, 14)
    SubtitleLabel.Position = UDim2.new(0, 62, 0, 33)
    SubtitleLabel.Text = windowSubtitle
    SubtitleLabel.TextSize = 10
    SubtitleLabel.Font = Enum.Font.Gotham
    SubtitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    SubtitleLabel.BackgroundTransparency = 1
    SubtitleLabel.Parent = LogoFrame
    Neverlose:RegisterTheme(SubtitleLabel, "TextColor3", "SubTextColor")

    local TabButtonContainer = Instance.new("ScrollingFrame")
    TabButtonContainer.Size = UDim2.new(1, 0, 1, -130)
    TabButtonContainer.Position = UDim2.new(0, 0, 0, 65)
    TabButtonContainer.BackgroundTransparency = 1
    TabButtonContainer.ScrollBarThickness = 0
    TabButtonContainer.Parent = Sidebar

    local TabListLayout = Instance.new("UIListLayout")
    TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabListLayout.Padding = UDim.new(0, 4)
    TabListLayout.Parent = TabButtonContainer

    local TabPadding = Instance.new("UIPadding")
    TabPadding.PaddingLeft = UDim.new(0, 10)
    TabPadding.PaddingRight = UDim.new(0, 10)
    TabPadding.Parent = TabButtonContainer

    -- Profile Frame
    local ProfileFrame = Instance.new("Frame")
    ProfileFrame.Size = UDim2.new(1, -20, 0, 50)
    ProfileFrame.Position = UDim2.new(0, 10, 1, -60)
    ProfileFrame.Parent = Sidebar
    Neverlose:RegisterTheme(ProfileFrame, "BackgroundColor3", "ElementBg", "ElementTransparency")

    local ProfileCorner = Instance.new("UICorner")
    ProfileCorner.CornerRadius = UDim.new(0, 8)
    ProfileCorner.Parent = ProfileFrame

    local AvatarImage = Instance.new("ImageLabel")
    AvatarImage.Size = UDim2.new(0, 34, 0, 34)
    AvatarImage.Position = UDim2.new(0, 8, 0.5, -17)
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
    DisplayNameLabel.Size = UDim2.new(1, -52, 0, 16)
    DisplayNameLabel.Position = UDim2.new(0, 48, 0, 8)
    DisplayNameLabel.Text = LocalPlayer and LocalPlayer.DisplayName or "User"
    DisplayNameLabel.Font = Enum.Font.GothamBold
    DisplayNameLabel.TextSize = 11
    DisplayNameLabel.TextXAlignment = Enum.TextXAlignment.Left
    DisplayNameLabel.TextTruncate = Enum.TextTruncate.AtEnd
    DisplayNameLabel.BackgroundTransparency = 1
    DisplayNameLabel.Parent = ProfileFrame
    Neverlose:RegisterTheme(DisplayNameLabel, "TextColor3", "TextColor")

    local UsernameLabel = Instance.new("TextLabel")
    UsernameLabel.Size = UDim2.new(1, -52, 0, 14)
    UsernameLabel.Position = UDim2.new(0, 48, 0, 24)
    UsernameLabel.Text = "@" .. (LocalPlayer and LocalPlayer.Name or "username")
    UsernameLabel.Font = Enum.Font.Gotham
    UsernameLabel.TextSize = 10
    UsernameLabel.TextXAlignment = Enum.TextXAlignment.Left
    UsernameLabel.TextTruncate = Enum.TextTruncate.AtEnd
    UsernameLabel.BackgroundTransparency = 1
    UsernameLabel.Parent = ProfileFrame
    Neverlose:RegisterAccent(UsernameLabel, "TextColor3")

    -- Header Search
    local Header = Instance.new("Frame")
    Header.Size = UDim2.new(1, -190, 0, 45)
    Header.Position = UDim2.new(0, 190, 0, 0)
    Header.BackgroundTransparency = 1
    Header.Parent = MainFrame

    MakeDraggable(MainFrame, Header)

    local SearchBox = Instance.new("TextBox")
    SearchBox.Size = UDim2.new(0, 210, 0, 26)
    SearchBox.Position = UDim2.new(1, -225, 0.5, -13)
    SearchBox.PlaceholderText = "Search functions..."
    SearchBox.Text = ""
    SearchBox.Font = Enum.Font.GothamMedium
    SearchBox.TextSize = 11
    SearchBox.Parent = Header

    Neverlose:RegisterTheme(SearchBox, "BackgroundColor3", "ElementBg", "ElementTransparency")
    Neverlose:RegisterTheme(SearchBox, "TextColor3", "TextColor")
    Neverlose:RegisterTheme(SearchBox, "PlaceholderColor3", "SubTextColor")

    local SearchCorner = Instance.new("UICorner")
    SearchCorner.CornerRadius = UDim.new(0, 6)
    SearchCorner.Parent = SearchBox

    local ContentArea = Instance.new("Frame")
    ContentArea.Size = UDim2.new(1, -190, 1, -45)
    ContentArea.Position = UDim2.new(0, 190, 0, 45)
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

    SearchBox:GetPropertyChangedSignal("Text"):Connect(function()
        local query = string.lower(SearchBox.Text)
        for _, elem in ipairs(WindowObj.AllElements) do
            if query == "" then
                elem.Frame.Visible = true
            else
                elem.Frame.Visible = string.find(string.lower(elem.Name), query) ~= nil
            end
        end
    end)

    -- Вспомогательная функция построения элементов управления для секций и дочерних окон
    local function AttachItemCreators(targetHolder, elementTracker)
        local Creators = {}

        -- 1. TOGGLE (с поддержкой 3 точек "..." и отдельного перетаскиваемого окна)
        function Creators:CreateToggle(opts)
            opts = opts or {}
            local name = opts.Name or "Toggle"
            local state = opts.Default or false
            local callback = opts.Callback or function() end
            local hasColor = opts.HasColor or false
            local colorDefault = opts.ColorDefault or Neverlose.AccentColor
            local colorCallback = opts.ColorCallback or function() end
            local subWindowBuilder = opts.SubWindow

            local ToggleFrame = Instance.new("Frame")
            ToggleFrame.Size = UDim2.new(1, 0, 0, 24)
            ToggleFrame.BackgroundTransparency = 1
            ToggleFrame.Parent = targetHolder

            if elementTracker then
                table.insert(elementTracker, { Name = name, Frame = ToggleFrame })
            end

            local offsetRight = -40
            if subWindowBuilder then offsetRight = offsetRight - 28 end
            if hasColor then offsetRight = offsetRight - 24 end

            local Label = Instance.new("TextButton")
            Label.Size = UDim2.new(1, offsetRight, 1, 0)
            Label.Text = name
            Label.Font = Enum.Font.GothamMedium
            Label.TextSize = 12
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.BackgroundTransparency = 1
            Label.Parent = ToggleFrame
            Neverlose:RegisterTheme(Label, "TextColor3", "TextColor")

            local SwitchBg = Instance.new("TextButton")
            SwitchBg.Size = UDim2.new(0, 34, 0, 18)
            SwitchBg.Position = UDim2.new(1, -34, 0.5, -9)
            SwitchBg.Text = ""
            SwitchBg.Parent = ToggleFrame
            Neverlose:RegisterTheme(SwitchBg, "BackgroundColor3", "ElementBg", "ElementTransparency")

            local SwitchCorner = Instance.new("UICorner")
            SwitchCorner.CornerRadius = UDim.new(1, 0)
            SwitchCorner.Parent = SwitchBg

            local Circle = Instance.new("Frame")
            Circle.Size = UDim2.new(0, 14, 0, 14)
            Circle.Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)
            Circle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Circle.Parent = SwitchBg

            local CircleCorner = Instance.new("UICorner")
            CircleCorner.CornerRadius = UDim.new(1, 0)
            CircleCorner.Parent = Circle

            local function SetToggleState(newState)
                state = newState
                if state then
                    Tween(SwitchBg, 0.15, {BackgroundColor3 = Neverlose.AccentColor, BackgroundTransparency = 0})
                else
                    local theme = Neverlose.Themes[Neverlose.CurrentTheme]
                    Tween(SwitchBg, 0.15, {BackgroundColor3 = theme.ElementBg, BackgroundTransparency = theme.ElementTransparency})
                end
                Tween(Circle, 0.15, {Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)})
                callback(state)
            end

            if state then SetToggleState(true) end

            SwitchBg.MouseButton1Click:Connect(function() SetToggleState(not state) end)
            Label.MouseButton1Click:Connect(function() SetToggleState(not state) end)

            -- Встроенный ColorPicker в toggle
            if hasColor then
                local ColorBtn = Instance.new("TextButton")
                ColorBtn.Size = UDim2.new(0, 18, 0, 12)
                ColorBtn.Position = UDim2.new(1, subWindowBuilder and -84 or -58, 0.5, -6)
                ColorBtn.BackgroundColor3 = colorDefault
                ColorBtn.Text = ""
                ColorBtn.Parent = ToggleFrame

                local CBCorner = Instance.new("UICorner")
                CBCorner.CornerRadius = UDim.new(0, 4)
                CBCorner.Parent = ColorBtn
            end

            -- 3 точки "..." и создание независимого перетаскиваемого дочернего окна!
            if subWindowBuilder then
                local DotsBtn = Instance.new("TextButton")
                DotsBtn.Size = UDim2.new(0, 22, 0, 18)
                DotsBtn.Position = UDim2.new(1, -60, 0.5, -9)
                DotsBtn.Text = "•••"
                DotsBtn.Font = Enum.Font.GothamBold
                DotsBtn.TextSize = 10
                DotsBtn.Parent = ToggleFrame
                Neverlose:RegisterTheme(DotsBtn, "TextColor3", "SubTextColor")
                Neverlose:RegisterTheme(DotsBtn, "BackgroundColor3", "ElementBg", "ElementTransparency")

                local DotsCorner = Instance.new("UICorner")
                DotsCorner.CornerRadius = UDim.new(0, 4)
                DotsCorner.Parent = DotsBtn

                -- Создание плавающего дочернего окна (Sub-Window Card)
                local SubWinFrame = Instance.new("Frame")
                SubWinFrame.Name = "SubWindow_" .. name
                SubWinFrame.Size = UDim2.new(0, 220, 0, 0)
                SubWinFrame.Position = UDim2.new(0.5, 50, 0.3, 0)
                SubWinFrame.AutomaticSize = Enum.AutomaticSize.Y
                SubWinFrame.Visible = false
                SubWinFrame.ZIndex = 500
                SubWinFrame.Parent = ScreenGui

                Neverlose:RegisterTheme(SubWinFrame, "BackgroundColor3", "CardBg", "CardTransparency")

                local SubWinCorner = Instance.new("UICorner")
                SubWinCorner.CornerRadius = UDim.new(0, 10)
                SubWinCorner.Parent = SubWinFrame

                local SubWinStroke = Instance.new("UIStroke")
                SubWinStroke.Thickness = 1
                SubWinStroke.Parent = SubWinFrame
                Neverlose:RegisterTheme(SubWinStroke, "Color", "BorderColor", "BorderTransparency")

                -- Заголовок дочернего окна
                local SubWinHeader = Instance.new("Frame")
                SubWinHeader.Size = UDim2.new(1, 0, 0, 28)
                SubWinHeader.BackgroundTransparency = 1
                SubWinHeader.Parent = SubWinFrame

                local SubWinTitle = Instance.new("TextLabel")
                SubWinTitle.Size = UDim2.new(1, -30, 1, 0)
                SubWinTitle.Position = UDim2.new(0, 10, 0, 0)
                SubWinTitle.Text = string.upper(opts.SubWindowTitle or name)
                SubWinTitle.Font = Enum.Font.GothamBold
                SubWinTitle.TextSize = 10
                SubWinTitle.TextXAlignment = Enum.TextXAlignment.Left
                SubWinTitle.BackgroundTransparency = 1
                SubWinTitle.Parent = SubWinHeader
                Neverlose:RegisterTheme(SubWinTitle, "TextColor3", "SubTextColor")

                local CloseSubBtn = Instance.new("TextButton")
                CloseSubBtn.Size = UDim2.new(0, 20, 0, 20)
                CloseSubBtn.Position = UDim2.new(1, -24, 0.5, -10)
                CloseSubBtn.Text = "✕"
                CloseSubBtn.Font = Enum.Font.GothamBold
                CloseSubBtn.TextSize = 11
                CloseSubBtn.BackgroundTransparency = 1
                CloseSubBtn.Parent = SubWinHeader
                Neverlose:RegisterTheme(CloseSubBtn, "TextColor3", "SubTextColor")

                local SubItemHolder = Instance.new("Frame")
                SubItemHolder.Size = UDim2.new(1, -16, 0, 0)
                SubItemHolder.Position = UDim2.new(0, 8, 0, 30)
                SubItemHolder.AutomaticSize = Enum.AutomaticSize.Y
                SubItemHolder.BackgroundTransparency = 1
                SubItemHolder.Parent = SubWinFrame

                local SubLayout = Instance.new("UIListLayout")
                SubLayout.SortOrder = Enum.SortOrder.LayoutOrder
                SubLayout.Padding = UDim.new(0, 6)
                SubLayout.Parent = SubItemHolder

                local SubPadding = Instance.new("UIPadding")
                SubPadding.PaddingBottom = UDim.new(0, 10)
                SubPadding.Parent = SubItemHolder

                -- Делаем дочернее окно перетаскиваемым!
                MakeDraggable(SubWinFrame, SubWinHeader)

                CloseSubBtn.MouseButton1Click:Connect(function()
                    SubWinFrame.Visible = false
                end)

                DotsBtn.MouseButton1Click:Connect(function()
                    SubWinFrame.Visible = not SubWinFrame.Visible
                end)

                -- Заполняем элементы внутри дочернего окна
                local SubCreators = AttachItemCreators(SubItemHolder, elementTracker)
                subWindowBuilder(SubCreators)
            end
        end

        -- 2. SLIDER
        function Creators:CreateSlider(opts)
            opts = opts or {}
            local name = opts.Name or "Slider"
            local min = opts.Min or 0
            local max = opts.Max or 100
            local val = opts.Default or min
            local suffix = opts.Suffix or ""
            local callback = opts.Callback or function() end

            local SliderFrame = Instance.new("Frame")
            SliderFrame.Size = UDim2.new(1, 0, 0, 36)
            SliderFrame.BackgroundTransparency = 1
            SliderFrame.Parent = targetHolder

            if elementTracker then table.insert(elementTracker, { Name = name, Frame = SliderFrame }) end

            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(0.6, 0, 0, 16)
            Label.Text = name
            Label.Font = Enum.Font.GothamMedium
            Label.TextSize = 12
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.BackgroundTransparency = 1
            Label.Parent = SliderFrame
            Neverlose:RegisterTheme(Label, "TextColor3", "TextColor")

            local ValLabel = Instance.new("TextLabel")
            ValLabel.Size = UDim2.new(0.4, 0, 0, 16)
            ValLabel.Position = UDim2.new(0.6, 0, 0, 0)
            ValLabel.Text = tostring(val) .. suffix
            ValLabel.Font = Enum.Font.Gotham
            ValLabel.TextSize = 11
            ValLabel.TextXAlignment = Enum.TextXAlignment.Right
            ValLabel.BackgroundTransparency = 1
            ValLabel.Parent = SliderFrame
            Neverlose:RegisterTheme(ValLabel, "TextColor3", "SubTextColor")

            local Track = Instance.new("TextButton")
            Track.Size = UDim2.new(1, 0, 0, 5)
            Track.Position = UDim2.new(0, 0, 0, 23)
            Track.Text = ""
            Track.Parent = SliderFrame
            Neverlose:RegisterTheme(Track, "BackgroundColor3", "ElementBg", "ElementTransparency")

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
            Thumb.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            Thumb.Parent = Fill

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
        function Creators:CreateDropdown(opts)
            opts = opts or {}
            local name = opts.Name or "Dropdown"
            local options = opts.Options or {}
            local selected = opts.Default or options[1] or "None"
            local callback = opts.Callback or function() end

            local DropFrame = Instance.new("Frame")
            DropFrame.Size = UDim2.new(1, 0, 0, 44)
            DropFrame.BackgroundTransparency = 1
            DropFrame.ZIndex = 5
            DropFrame.Parent = targetHolder

            if elementTracker then table.insert(elementTracker, { Name = name, Frame = DropFrame }) end

            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, 0, 0, 16)
            Label.Text = name
            Label.Font = Enum.Font.GothamMedium
            Label.TextSize = 12
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.BackgroundTransparency = 1
            Label.Parent = DropFrame
            Neverlose:RegisterTheme(Label, "TextColor3", "TextColor")

            local Box = Instance.new("TextButton")
            Box.Size = UDim2.new(1, 0, 0, 24)
            Box.Position = UDim2.new(0, 0, 0, 20)
            Box.Text = "  " .. selected
            Box.Font = Enum.Font.Gotham
            Box.TextSize = 11
            Box.TextXAlignment = Enum.TextXAlignment.Left
            Box.ZIndex = 6
            Box.Parent = DropFrame
            Neverlose:RegisterTheme(Box, "BackgroundColor3", "ElementBg", "ElementTransparency")
            Neverlose:RegisterTheme(Box, "TextColor3", "TextColor")

            local BoxCorner = Instance.new("UICorner")
            BoxCorner.CornerRadius = UDim.new(0, 6)
            BoxCorner.Parent = Box

            local ArrowIcon = Instance.new("ImageLabel")
            ArrowIcon.Size = UDim2.new(0, 12, 0, 12)
            ArrowIcon.Position = UDim2.new(1, -20, 0.5, -6)
            ArrowIcon.BackgroundTransparency = 1
            ArrowIcon.Image = GetAsset(Neverlose.Icons.ChevronDown, "chevron.png")
            ArrowIcon.ZIndex = 7
            ArrowIcon.Parent = Box
            Neverlose:RegisterAccent(ArrowIcon, "ImageColor3")

            local Container = Instance.new("Frame")
            Container.Size = UDim2.new(1, 0, 0, #options * 24)
            Container.Position = UDim2.new(0, 0, 1, 4)
            Container.Visible = false
            Container.ZIndex = 30
            Container.Parent = Box
            Neverlose:RegisterTheme(Container, "BackgroundColor3", "CardBg")

            local CCorner = Instance.new("UICorner")
            CCorner.CornerRadius = UDim.new(0, 6)
            CCorner.Parent = Container

            local CStroke = Instance.new("UIStroke")
            CStroke.Thickness = 1
            CStroke.Parent = Container
            Neverlose:RegisterTheme(CStroke, "Color", "BorderColor", "BorderTransparency")

            local CLayout = Instance.new("UIListLayout")
            CLayout.SortOrder = Enum.SortOrder.LayoutOrder
            CLayout.Parent = Container

            local open = false
            for _, opt in ipairs(options) do
                local OptBtn = Instance.new("TextButton")
                OptBtn.Size = UDim2.new(1, 0, 0, 24)
                OptBtn.BackgroundTransparency = 1
                OptBtn.Text = "  " .. opt
                OptBtn.Font = Enum.Font.Gotham
                OptBtn.TextSize = 11
                OptBtn.TextXAlignment = Enum.TextXAlignment.Left
                OptBtn.ZIndex = 31
                OptBtn.Parent = Container
                Neverlose:RegisterTheme(OptBtn, "TextColor3", "SubTextColor")

                OptBtn.MouseButton1Click:Connect(function()
                    selected = opt
                    Box.Text = "  " .. selected
                    Container.Visible = false
                    open = false
                    Tween(ArrowIcon, 0.2, {Rotation = 0})
                    callback(selected)
                end)
            end

            Box.MouseButton1Click:Connect(function()
                open = not open
                Container.Visible = open
                Tween(ArrowIcon, 0.2, {Rotation = open and 180 or 0})
            end)
        end

        -- 4. MULTI-DROPDOWN
        function Creators:CreateMultiDropdown(opts)
            opts = opts or {}
            local name = opts.Name or "Multi Dropdown"
            local options = opts.Options or {}
            local selected = opts.Default or {}
            local callback = opts.Callback or function() end

            local DropFrame = Instance.new("Frame")
            DropFrame.Size = UDim2.new(1, 0, 0, 44)
            DropFrame.BackgroundTransparency = 1
            DropFrame.ZIndex = 5
            DropFrame.Parent = targetHolder

            if elementTracker then table.insert(elementTracker, { Name = name, Frame = DropFrame }) end

            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, 0, 0, 16)
            Label.Text = name
            Label.Font = Enum.Font.GothamMedium
            Label.TextSize = 12
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.BackgroundTransparency = 1
            Label.Parent = DropFrame
            Neverlose:RegisterTheme(Label, "TextColor3", "TextColor")

            local selectedSet = {}
            for _, item in ipairs(selected) do selectedSet[item] = true end

            local function GetFormattedText()
                local list = {}
                for opt, act in pairs(selectedSet) do
                    if act then table.insert(list, opt) end
                end
                if #list == 0 then return "None" end
                return table.concat(list, ", ")
            end

            local Box = Instance.new("TextButton")
            Box.Size = UDim2.new(1, 0, 0, 24)
            Box.Position = UDim2.new(0, 0, 0, 20)
            Box.Text = "  " .. GetFormattedText()
            Box.Font = Enum.Font.Gotham
            Box.TextSize = 11
            Box.TextXAlignment = Enum.TextXAlignment.Left
            Box.TextTruncate = Enum.TextTruncate.AtEnd
            Box.ZIndex = 6
            Box.Parent = DropFrame
            Neverlose:RegisterTheme(Box, "BackgroundColor3", "ElementBg", "ElementTransparency")
            Neverlose:RegisterTheme(Box, "TextColor3", "TextColor")

            local BoxCorner = Instance.new("UICorner")
            BoxCorner.CornerRadius = UDim.new(0, 6)
            BoxCorner.Parent = Box

            local ArrowIcon = Instance.new("ImageLabel")
            ArrowIcon.Size = UDim2.new(0, 12, 0, 12)
            ArrowIcon.Position = UDim2.new(1, -20, 0.5, -6)
            ArrowIcon.BackgroundTransparency = 1
            ArrowIcon.Image = GetAsset(Neverlose.Icons.ChevronDown, "chevron.png")
            ArrowIcon.ZIndex = 7
            ArrowIcon.Parent = Box
            Neverlose:RegisterAccent(ArrowIcon, "ImageColor3")

            local Container = Instance.new("Frame")
            Container.Size = UDim2.new(1, 0, 0, #options * 24)
            Container.Position = UDim2.new(0, 0, 1, 4)
            Container.Visible = false
            Container.ZIndex = 30
            Container.Parent = Box
            Neverlose:RegisterTheme(Container, "BackgroundColor3", "CardBg")

            local CCorner = Instance.new("UICorner")
            CCorner.CornerRadius = UDim.new(0, 6)
            CCorner.Parent = Container

            local CLayout = Instance.new("UIListLayout")
            CLayout.SortOrder = Enum.SortOrder.LayoutOrder
            CLayout.Parent = Container

            local open = false
            for _, opt in ipairs(options) do
                local OptBtn = Instance.new("TextButton")
                OptBtn.Size = UDim2.new(1, 0, 0, 24)
                OptBtn.BackgroundTransparency = 1
                OptBtn.Text = (selectedSet[opt] and "  ✓ " or "    ") .. opt
                OptBtn.Font = Enum.Font.Gotham
                OptBtn.TextSize = 11
                OptBtn.TextXAlignment = Enum.TextXAlignment.Left
                OptBtn.ZIndex = 31
                OptBtn.Parent = Container
                if selectedSet[opt] then
                    Neverlose:RegisterAccent(OptBtn, "TextColor3")
                else
                    Neverlose:RegisterTheme(OptBtn, "TextColor3", "SubTextColor")
                end

                OptBtn.MouseButton1Click:Connect(function()
                    selectedSet[opt] = not selectedSet[opt]
                    OptBtn.Text = (selectedSet[opt] and "  ✓ " or "    ") .. opt
                    if selectedSet[opt] then
                        OptBtn.TextColor3 = Neverlose.AccentColor
                    else
                        local theme = Neverlose.Themes[Neverlose.CurrentTheme]
                        OptBtn.TextColor3 = theme.SubTextColor
                    end
                    Box.Text = "  " .. GetFormattedText()
                    callback(selectedSet)
                end)
            end

            Box.MouseButton1Click:Connect(function()
                open = not open
                Container.Visible = open
                Tween(ArrowIcon, 0.2, {Rotation = open and 180 or 0})
            end)
        end

        -- 5. COLOR PICKER
        function Creators:CreateColorPicker(opts)
            opts = opts or {}
            local name = opts.Name or "Color"
            local currentColor = opts.Default or Neverlose.AccentColor
            local callback = opts.Callback or function() end

            local h, s, v = Color3.toHSV(currentColor)

            local ColorFrame = Instance.new("Frame")
            ColorFrame.Size = UDim2.new(1, 0, 0, 24)
            ColorFrame.BackgroundTransparency = 1
            ColorFrame.Parent = targetHolder

            if elementTracker then table.insert(elementTracker, { Name = name, Frame = ColorFrame }) end

            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, -30, 1, 0)
            Label.Text = name
            Label.Font = Enum.Font.GothamMedium
            Label.TextSize = 12
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.BackgroundTransparency = 1
            Label.Parent = ColorFrame
            Neverlose:RegisterTheme(Label, "TextColor3", "TextColor")

            local ColorBox = Instance.new("TextButton")
            ColorBox.Size = UDim2.new(0, 22, 0, 14)
            ColorBox.Position = UDim2.new(1, -22, 0.5, -7)
            ColorBox.BackgroundColor3 = currentColor
            ColorBox.Text = ""
            ColorBox.Parent = ColorFrame

            local BoxCorner = Instance.new("UICorner")
            BoxCorner.CornerRadius = UDim.new(0, 4)
            BoxCorner.Parent = ColorBox

            local PickerWindow = Instance.new("Frame")
            PickerWindow.Size = UDim2.new(0, 180, 0, 160)
            PickerWindow.ZIndex = 200
            PickerWindow.Visible = false
            PickerWindow.Parent = ScreenGui
            Neverlose:RegisterTheme(PickerWindow, "BackgroundColor3", "CardBg")

            local PCorner = Instance.new("UICorner")
            PCorner.CornerRadius = UDim.new(0, 8)
            PCorner.Parent = PickerWindow

            local PStroke = Instance.new("UIStroke")
            PStroke.Thickness = 1
            PStroke.Parent = PickerWindow
            Neverlose:RegisterTheme(PStroke, "Color", "BorderColor", "BorderTransparency")

            local SVBox = Instance.new("TextButton")
            SVBox.Size = UDim2.new(0, 130, 0, 130)
            SVBox.Position = UDim2.new(0, 10, 0, 15)
            SVBox.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
            SVBox.Text = ""
            SVBox.ZIndex = 201
            SVBox.Parent = PickerWindow

            local WhiteGrad = Instance.new("Frame")
            WhiteGrad.Size = UDim2.new(1, 0, 1, 0)
            WhiteGrad.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            WhiteGrad.ZIndex = 202
            WhiteGrad.Parent = SVBox

            local WGrad = Instance.new("UIGradient")
            WGrad.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1)})
            WGrad.Parent = WhiteGrad

            local BlackGrad = Instance.new("Frame")
            BlackGrad.Size = UDim2.new(1, 0, 1, 0)
            BlackGrad.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
            BlackGrad.ZIndex = 203
            BlackGrad.Parent = SVBox

            local BGrad = Instance.new("UIGradient")
            BGrad.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(1, 0)})
            BGrad.Rotation = 90
            BGrad.Parent = BlackGrad

            local SVCursor = Instance.new("Frame")
            SVCursor.Size = UDim2.new(0, 10, 0, 10)
            SVCursor.Position = UDim2.new(s, -5, 1 - v, -5)
            SVCursor.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            SVCursor.ZIndex = 205
            SVCursor.Parent = SVBox

            local SVCurserCorner = Instance.new("UICorner")
            SVCurserCorner.CornerRadius = UDim.new(1, 0)
            SVCurserCorner.Parent = SVCursor

            local HueSlider = Instance.new("TextButton")
            HueSlider.Size = UDim2.new(0, 18, 0, 130)
            HueSlider.Position = UDim2.new(0, 150, 0, 15)
            HueSlider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            HueSlider.Text = ""
            HueSlider.ZIndex = 201
            HueSlider.Parent = PickerWindow

            local HueGradient = Instance.new("UIGradient")
            HueGradient.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
                ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
                ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
                ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
                ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
                ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0))
            })
            HueGradient.Rotation = 90
            HueGradient.Parent = HueSlider

            local draggingSV, draggingHue = false, false

            local function UpdateColor()
                currentColor = Color3.fromHSV(h, s, v)
                SVBox.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
                ColorBox.BackgroundColor3 = currentColor
                callback(currentColor)
            end

            local function UpdateSV(input)
                s = math.clamp((input.Position.X - SVBox.AbsolutePosition.X) / SVBox.AbsoluteSize.X, 0, 1)
                v = 1 - math.clamp((input.Position.Y - SVBox.AbsolutePosition.Y) / SVBox.AbsoluteSize.Y, 0, 1)
                SVCursor.Position = UDim2.new(s, -5, 1 - v, -5)
                UpdateColor()
            end

            local function UpdateHue(input)
                h = math.clamp((input.Position.Y - HueSlider.AbsolutePosition.Y) / HueSlider.AbsoluteSize.Y, 0, 1)
                UpdateColor()
            end

            SVBox.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingSV = true UpdateSV(input) end
            end)
            HueSlider.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingHue = true UpdateHue(input) end
            end)

            UserInputService.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingSV = false draggingHue = false end
            end)

            UserInputService.InputChanged:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseMovement then
                    if draggingSV then UpdateSV(input) end
                    if draggingHue then UpdateHue(input) end
                end
            end)

            ColorBox.MouseButton1Click:Connect(function()
                PickerWindow.Visible = not PickerWindow.Visible
                if PickerWindow.Visible then
                    local mouse = UserInputService:GetMouseLocation()
                    PickerWindow.Position = UDim2.new(0, mouse.X - 90, 0, mouse.Y)
                end
            end)
        end

        -- 6. KEYBIND
        function Creators:CreateKeybind(opts)
            opts = opts or {}
            local name = opts.Name or "Keybind"
            local currentKey = opts.Default or Enum.KeyCode.E
            local callback = opts.Callback or function() end

            local BindFrame = Instance.new("Frame")
            BindFrame.Size = UDim2.new(1, 0, 0, 24)
            BindFrame.BackgroundTransparency = 1
            BindFrame.Parent = targetHolder

            if elementTracker then table.insert(elementTracker, { Name = name, Frame = BindFrame }) end

            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, -60, 1, 0)
            Label.Text = name
            Label.Font = Enum.Font.GothamMedium
            Label.TextSize = 12
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.BackgroundTransparency = 1
            Label.Parent = BindFrame
            Neverlose:RegisterTheme(Label, "TextColor3", "TextColor")

            local BindBtn = Instance.new("TextButton")
            BindBtn.Size = UDim2.new(0, 50, 0, 20)
            BindBtn.Position = UDim2.new(1, -50, 0.5, -10)
            BindBtn.Text = currentKey.Name
            BindBtn.Font = Enum.Font.Gotham
            BindBtn.TextSize = 10
            BindBtn.Parent = BindFrame
            Neverlose:RegisterTheme(BindBtn, "BackgroundColor3", "ElementBg", "ElementTransparency")
            Neverlose:RegisterTheme(BindBtn, "TextColor3", "SubTextColor")

            local BtnCorner = Instance.new("UICorner")
            BtnCorner.CornerRadius = UDim.new(0, 4)
            BtnCorner.Parent = BindBtn

            local listening = false
            BindBtn.MouseButton1Click:Connect(function()
                listening = true
                BindBtn.Text = "..."
                Neverlose:RegisterAccent(BindBtn, "TextColor3")
            end)

            UserInputService.InputBegan:Connect(function(input)
                if listening and input.UserInputType == Enum.UserInputType.Keyboard then
                    currentKey = input.KeyCode
                    BindBtn.Text = currentKey.Name
                    listening = false
                    local theme = Neverlose.Themes[Neverlose.CurrentTheme]
                    BindBtn.TextColor3 = theme.SubTextColor
                    callback(currentKey)
                end
            end)
        end

        -- 7. TEXTBOX
        function Creators:CreateTextbox(opts)
            opts = opts or {}
            local name = opts.Name or "Textbox"
            local defaultText = opts.Default or ""
            local placeholder = opts.Placeholder or "Type..."
            local callback = opts.Callback or function() end

            local TextFrame = Instance.new("Frame")
            TextFrame.Size = UDim2.new(1, 0, 0, 42)
            TextFrame.BackgroundTransparency = 1
            TextFrame.Parent = targetHolder

            if elementTracker then table.insert(elementTracker, { Name = name, Frame = TextFrame }) end

            local Label = Instance.new("TextLabel")
            Label.Size = UDim2.new(1, 0, 0, 16)
            Label.Text = name
            Label.Font = Enum.Font.GothamMedium
            Label.TextSize = 12
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.BackgroundTransparency = 1
            Label.Parent = TextFrame
            Neverlose:RegisterTheme(Label, "TextColor3", "TextColor")

            local Box = Instance.new("TextBox")
            Box.Size = UDim2.new(1, 0, 0, 22)
            Box.Position = UDim2.new(0, 0, 0, 20)
            Box.Text = defaultText
            Box.PlaceholderText = placeholder
            Box.Font = Enum.Font.Gotham
            Box.TextSize = 11
            Box.Parent = TextFrame

            Neverlose:RegisterTheme(Box, "BackgroundColor3", "ElementBg", "ElementTransparency")
            Neverlose:RegisterTheme(Box, "TextColor3", "TextColor")
            Neverlose:RegisterTheme(Box, "PlaceholderColor3", "SubTextColor")

            local BoxCorner = Instance.new("UICorner")
            BoxCorner.CornerRadius = UDim.new(0, 5)
            BoxCorner.Parent = Box

            Box:GetPropertyChangedSignal("Text"):Connect(function()
                callback(Box.Text)
            end)
        end

        -- 8. BUTTON
        function Creators:CreateButton(opts)
            opts = opts or {}
            local name = opts.Name or "Button"
            local callback = opts.Callback or function() end

            local BtnFrame = Instance.new("Frame")
            BtnFrame.Size = UDim2.new(1, 0, 0, 28)
            BtnFrame.BackgroundTransparency = 1
            BtnFrame.Parent = targetHolder

            if elementTracker then table.insert(elementTracker, { Name = name, Frame = BtnFrame }) end

            local Btn = Instance.new("TextButton")
            Btn.Size = UDim2.new(1, 0, 1, 0)
            Btn.Text = name
            Btn.Font = Enum.Font.GothamMedium
            Btn.TextSize = 12
            Btn.Parent = BtnFrame
            Neverlose:RegisterTheme(Btn, "BackgroundColor3", "ElementBg", "ElementTransparency")
            Neverlose:RegisterTheme(Btn, "TextColor3", "TextColor")

            local BtnCorner = Instance.new("UICorner")
            BtnCorner.CornerRadius = UDim.new(0, 5)
            BtnCorner.Parent = Btn

            Btn.MouseButton1Click:Connect(function()
                Tween(Btn, 0.08, {BackgroundColor3 = Neverlose.AccentColor, BackgroundTransparency = 0})
                task.wait(0.08)
                local theme = Neverlose.Themes[Neverlose.CurrentTheme]
                Tween(Btn, 0.15, {BackgroundColor3 = theme.ElementBg, BackgroundTransparency = theme.ElementTransparency})
                callback()
            end)
        end

        return Creators
    end

    function WindowObj:CreateTab(opts)
        opts = opts or {}
        local name = opts.Name or "Tab"
        local category = opts.Category or "GENERAL"
        local icon = opts.Icon or Neverlose.Icons.Checkmark

        if not WindowObj.Categories[category] then
            local CatLabel = Instance.new("TextLabel")
            CatLabel.Size = UDim2.new(1, 0, 0, 22)
            CatLabel.Text = string.upper(category)
            CatLabel.Font = Enum.Font.GothamBold
            CatLabel.TextSize = 9
            CatLabel.TextXAlignment = Enum.TextXAlignment.Left
            CatLabel.BackgroundTransparency = 1
            CatLabel.Parent = TabButtonContainer
            Neverlose:RegisterTheme(CatLabel, "TextColor3", "SubTextColor")

            WindowObj.Categories[category] = true
        end

        local TabButton = Instance.new("Frame")
        TabButton.Size = UDim2.new(1, 0, 0, 32)
        TabButton.BackgroundTransparency = 1
        TabButton.Parent = TabButtonContainer
        Neverlose:RegisterTheme(TabButton, "BackgroundColor3", "ElementBg", "ElementTransparency")

        local TabBtnCorner = Instance.new("UICorner")
        TabBtnCorner.CornerRadius = UDim.new(0, 6)
        TabBtnCorner.Parent = TabButton

        local TabClickBtn = Instance.new("TextButton")
        TabClickBtn.Size = UDim2.new(1, 0, 1, 0)
        TabClickBtn.BackgroundTransparency = 1
        TabClickBtn.Text = ""
        TabClickBtn.Parent = TabButton

        local IconImg = Instance.new("ImageLabel")
        IconImg.Size = UDim2.new(0, 16, 0, 16)
        IconImg.Position = UDim2.new(0, 10, 0.5, -8)
        IconImg.BackgroundTransparency = 1
        IconImg.Image = GetAsset(icon, "tab_icon.png")
        IconImg.Parent = TabButton
        Neverlose:RegisterAccent(IconImg, "ImageColor3")

        local TabTitleLabel = Instance.new("TextLabel")
        TabTitleLabel.Size = UDim2.new(1, -36, 1, 0)
        TabTitleLabel.Position = UDim2.new(0, 34, 0, 0)
        TabTitleLabel.Text = name
        TabTitleLabel.Font = Enum.Font.GothamMedium
        TabTitleLabel.TextSize = 12
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
            SectionFrame.Parent = parentCol
            Neverlose:RegisterTheme(SectionFrame, "BackgroundColor3", "CardBg", "CardTransparency")

            local SecCorner = Instance.new("UICorner")
            SecCorner.CornerRadius = UDim.new(0, 10)
            SecCorner.Parent = SectionFrame

            local SecStroke = Instance.new("UIStroke")
            SecStroke.Thickness = 1
            SecStroke.Parent = SectionFrame
            Neverlose:RegisterTheme(SecStroke, "Color", "BorderColor", "BorderTransparency")

            local Title = Instance.new("TextLabel")
            Title.Size = UDim2.new(1, -20, 0, 25)
            Title.Position = UDim2.new(0, 10, 0, 5)
            Title.Text = string.upper(sectionTitle)
            Title.Font = Enum.Font.GothamBold
            Title.TextSize = 10
            Title.TextXAlignment = Enum.TextXAlignment.Left
            Title.BackgroundTransparency = 1
            Title.Parent = SectionFrame
            Neverlose:RegisterTheme(Title, "TextColor3", "SubTextColor")

            local ItemHolder = Instance.new("Frame")
            ItemHolder.Size = UDim2.new(1, -20, 0, 0)
            ItemHolder.Position = UDim2.new(0, 10, 0, 30)
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

            return AttachItemCreators(ItemHolder, WindowObj.AllElements)
        end

        return TabObj
    end

    return WindowObj
end

return Neverlose
