-- ================================================================================
-- DARK PREMIUM UI LIBRARY v2.0 (Minimalist Edition)
-- ================================================================================

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local StatsService = game:GetService("Stats")
local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

-- Инициализация библиотеки
local Library = {
    IsOpen = true,
    ToggledKey = Enum.KeyCode.Insert,
    SoundEnabled = true,
    ActiveTabName = "Main",
    ActiveSubTabName = "General"
}
Library.__index = Library

-- Минималистичная цветовая палитра
local Theme = {
    MainBg = Color3.fromRGB(16, 16, 18),
    CardBg = Color3.fromRGB(22, 22, 25),
    ElementBg = Color3.fromRGB(28, 28, 32),
    Accent = Color3.fromRGB(110, 80, 255),
    AccentMuted = Color3.fromRGB(70, 50, 160),
    TextMain = Color3.fromRGB(240, 240, 245),
    TextMuted = Color3.fromRGB(130, 130, 140),
    Stroke = Color3.fromRGB(35, 35, 40),
    Success = Color3.fromRGB(75, 210, 140),
    Warning = Color3.fromRGB(240, 180, 70),
    Error = Color3.fromRGB(240, 80, 80),
    Info = Color3.fromRGB(110, 80, 255)
}

-- ================================================================================
-- ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ И ЗВУКИ
-- ================================================================================

local function Tween(object, time, properties, style, direction)
    style = style or Enum.EasingStyle.Quart
    direction = direction or Enum.EasingDirection.Out
    local tweenInfo = TweenInfo.new(time or 0.2, style, direction)
    local tween = TweenService:Create(object, tweenInfo, properties)
    tween:Play()
    return tween
end

local function PlaySound(soundId)
    if not Library.SoundEnabled then return end
    task.spawn(function()
        local sound = Instance.new("Sound")
        sound.SoundId = "rbxassetid://" .. tostring(soundId or 6895079853)
        sound.Volume = 0.3
        sound.Parent = CoreGui
        sound:Play()
        sound.Ended:Connect(function() sound:Destroy() end)
    end)
end

local function MakeDraggable(frame, handle)
    local dragging, dragInput, dragStart, startPos
    handle = handle or frame
    
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    
    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            Tween(frame, 0.05, {Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)})
        end
    end)
end

local function MakeResizable(frame, handle)
    local resizing, resizeInput, resizeStart, startSize
    
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            resizing = true
            resizeStart = input.Position
            startSize = frame.Size
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then resizing = false end
            end)
        end
    end)
    
    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then resizeInput = input end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == resizeInput and resizing then
            local delta = input.Position - resizeStart
            local newX = math.clamp(startSize.X.Offset + delta.X, 520, 900)
            local newY = math.clamp(startSize.Y.Offset + delta.Y, 360, 650)
            frame.Size = UDim2.new(0, newX, 0, newY)
        end
    end)
end

-- ================================================================================
-- СИСТЕМА УВЕДОМЛЕНИЙ (Toast Notifications)
-- ================================================================================

local NotificationHolder

function Library:Notify(options)
    options = options or {}
    local title = options.Title or "Notification"
    local text = options.Text or ""
    local duration = options.Duration or 3
    local nType = options.Type or "Info" -- Success, Warning, Error, Info
    
    if not NotificationHolder then return end
    PlaySound(4590662766)

    local typeColor = Theme[nType] or Theme.Info

    local Toast = Instance.new("Frame")
    Toast.Name = "Toast"
    Toast.Size = UDim2.new(1, 0, 0, 52)
    Toast.BackgroundColor3 = Theme.CardBg
    Toast.ClipsDescendants = true
    Toast.Parent = NotificationHolder
    
    local ToastCorner = Instance.new("UICorner", Toast)
    ToastCorner.CornerRadius = UDim.new(0, 6)
    
    local ToastStroke = Instance.new("UIStroke", Toast)
    ToastStroke.Color = Theme.Stroke
    
    local SideAccent = Instance.new("Frame")
    SideAccent.Size = UDim2.new(0, 3, 1, 0)
    SideAccent.BackgroundColor3 = typeColor
    SideAccent.BorderSizePixel = 0
    SideAccent.Parent = Toast

    local TitleLbl = Instance.new("TextLabel")
    TitleLbl.Size = UDim2.new(1, -15, 0, 18)
    TitleLbl.Position = UDim2.new(0, 12, 0, 6)
    TitleLbl.BackgroundTransparency = 1
    TitleLbl.Font = Enum.Font.GothamBold
    TitleLbl.Text = title
    TitleLbl.TextColor3 = Theme.TextMain
    TitleLbl.TextSize = 12
    TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
    TitleLbl.Parent = Toast

    local TextLbl = Instance.new("TextLabel")
    TextLbl.Size = UDim2.new(1, -15, 0, 18)
    TextLbl.Position = UDim2.new(0, 12, 0, 24)
    TextLbl.BackgroundTransparency = 1
    TextLbl.Font = Enum.Font.Gotham
    TextLbl.Text = text
    TextLbl.TextColor3 = Theme.TextMuted
    TextLbl.TextSize = 11
    TextLbl.TextXAlignment = Enum.TextXAlignment.Left
    TextLbl.Parent = Toast

    local ProgressBar = Instance.new("Frame")
    ProgressBar.Size = UDim2.new(1, 0, 0, 2)
    ProgressBar.Position = UDim2.new(0, 0, 1, -2)
    ProgressBar.BackgroundColor3 = typeColor
    ProgressBar.BorderSizePixel = 0
    ProgressBar.Parent = Toast

    -- Анимация таймера
    Tween(ProgressBar, duration, {Size = UDim2.new(0, 0, 0, 2)}, Enum.EasingStyle.Linear)

    task.delay(duration, function()
        local tw = Tween(Toast, 0.25, {Size = UDim2.new(1, 0, 0, 0), BackgroundTransparency = 1})
        tw.Completed:Connect(function()
            Toast:Destroy()
        end)
    end)
end

-- ================================================================================
-- СОЗДАНИЕ ОКНА (CreateWindow)
-- ================================================================================

function Library:CreateWindow(config)
    config = config or {}
    local windowTitle = config.Title or "DARK PREMIUM"
    local userRole = config.UserRole or "VIP User"
    
    local Window = { Tabs = {}, CurrentTab = nil }

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "DarkUI_" .. math.random(1000, 9999)
    ScreenGui.ResetOnSpawn = false
    
    if gethui then ScreenGui.Parent = gethui()
    elseif syn and syn.protect_gui then syn.protect_gui(ScreenGui) ScreenGui.Parent = CoreGui
    else ScreenGui.Parent = CoreGui or LocalPlayer:WaitForChild("PlayerGui") end

    -- Контейнер нотификаций
    NotificationHolder = Instance.new("Frame")
    NotificationHolder.Name = "NotificationHolder"
    NotificationHolder.Size = UDim2.new(0, 240, 0, 300)
    NotificationHolder.Position = UDim2.new(1, -250, 1, -80)
    NotificationHolder.BackgroundTransparency = 1
    NotificationHolder.Parent = ScreenGui

    local NotifLayout = Instance.new("UIListLayout", NotificationHolder)
    NotifLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
    NotifLayout.Padding = UDim.new(0, 8)

    -- ----------------------------------------------------------------------------
    -- МИНИМАЛИСТИЧНЫЙ ТАСКБАР
    -- ----------------------------------------------------------------------------
    local Taskbar = Instance.new("Frame")
    Taskbar.Name = "Taskbar"
    Taskbar.Size = UDim2.new(0, 640, 0, 42)
    Taskbar.Position = UDim2.new(0.5, 0, 1, -55)
    Taskbar.AnchorPoint = Vector2.new(0.5, 1)
    Taskbar.BackgroundColor3 = Theme.MainBg
    Taskbar.Parent = ScreenGui
    
    Instance.new("UICorner", Taskbar).CornerRadius = UDim.new(0, 8)
    local TaskbarStroke = Instance.new("UIStroke", Taskbar)
    TaskbarStroke.Color = Theme.Stroke

    -- Профиль
    local ProfileFrame = Instance.new("Frame")
    ProfileFrame.Size = UDim2.new(0, 140, 1, 0)
    ProfileFrame.Position = UDim2.new(0, 10, 0, 0)
    ProfileFrame.BackgroundTransparency = 1
    ProfileFrame.Parent = Taskbar

    local OnlineDot = Instance.new("Frame")
    OnlineDot.Size = UDim2.new(0, 6, 0, 6)
    OnlineDot.Position = UDim2.new(0, 0, 0.5, -3)
    OnlineDot.BackgroundColor3 = Theme.Success
    OnlineDot.BorderSizePixel = 0
    OnlineDot.Parent = ProfileFrame
    Instance.new("UICorner", OnlineDot).CornerRadius = UDim.new(1, 0)

    local UserLbl = Instance.new("TextLabel")
    UserLbl.Size = UDim2.new(1, -12, 0, 14)
    UserLbl.Position = UDim2.new(0, 12, 0, 8)
    UserLbl.BackgroundTransparency = 1
    UserLbl.Font = Enum.Font.GothamBold
    UserLbl.Text = LocalPlayer.DisplayName
    UserLbl.TextColor3 = Theme.TextMain
    UserLbl.TextSize = 11
    UserLbl.TextXAlignment = Enum.TextXAlignment.Left
    UserLbl.Parent = ProfileFrame

    local RoleLbl = Instance.new("TextLabel")
    RoleLbl.Size = UDim2.new(1, -12, 0, 12)
    RoleLbl.Position = UDim2.new(0, 12, 0, 22)
    RoleLbl.BackgroundTransparency = 1
    RoleLbl.Font = Enum.Font.Gotham
    RoleLbl.Text = userRole
    RoleLbl.TextColor3 = Theme.TextMuted
    RoleLbl.TextSize = 9
    RoleLbl.TextXAlignment = Enum.TextXAlignment.Left
    RoleLbl.Parent = ProfileFrame

    -- Статистика (Watermark)
    local StatsLbl = Instance.new("TextLabel")
    StatsLbl.Size = UDim2.new(0, 200, 1, 0)
    StatsLbl.Position = UDim2.new(1, -210, 0, 0)
    StatsLbl.BackgroundTransparency = 1
    StatsLbl.Font = Enum.Font.Code
    StatsLbl.Text = "FPS: -- | Ping: --ms"
    StatsLbl.TextColor3 = Theme.TextMuted
    StatsLbl.TextSize = 10
    StatsLbl.TextXAlignment = Enum.TextXAlignment.Right
    StatsLbl.Parent = Taskbar

    -- Иконки в центре таскбара
    local TabIconsContainer = Instance.new("Frame")
    TabIconsContainer.Size = UDim2.new(0, 220, 1, 0)
    TabIconsContainer.Position = UDim2.new(0.5, 0, 0, 0)
    TabIconsContainer.AnchorPoint = Vector2.new(0.5, 0)
    TabIconsContainer.BackgroundTransparency = 1
    TabIconsContainer.Parent = Taskbar

    local TabListLayout = Instance.new("UIListLayout", TabIconsContainer)
    TabListLayout.FillDirection = Enum.FillDirection.Horizontal
    TabListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    TabListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    TabListLayout.Padding = UDim.new(0, 6)

    -- Обновление статистики (FPS & Ping)
    local fpsCount, lastTick = 0, os.clock()
    local startTime = os.clock()
    RunService.RenderStepped:Connect(function()
        fpsCount = fpsCount + 1
        if os.clock() - lastTick >= 1 then
            local ping = math.floor(StatsService.Network.ServerStatsItem["Data Ping"]:GetValue())
            StatsLbl.Text = string.format("FPS: %d | Ping: %dms", fpsCount, ping)
            fpsCount = 0
            lastTick = os.clock()
        end
    end)

    -- ----------------------------------------------------------------------------
    -- ГЛАВНОЕ ОКНО
    -- ----------------------------------------------------------------------------
    local MainContainer = Instance.new("CanvasGroup")
    MainContainer.Name = "MainContainer"
    MainContainer.Size = UDim2.new(0, 580, 0, 400)
    MainContainer.Position = UDim2.new(0.5, 0, 0.5, -20)
    MainContainer.AnchorPoint = Vector2.new(0.5, 0.5)
    MainContainer.BackgroundColor3 = Theme.MainBg
    MainContainer.Parent = ScreenGui

    Instance.new("UICorner", MainContainer).CornerRadius = UDim.new(0, 8)
    local MainStroke = Instance.new("UIStroke", MainContainer)
    MainStroke.Color = Theme.Stroke

    MakeDraggable(MainContainer)

    -- Уголок изменения размера (Resize Grip)
    local ResizeGrip = Instance.new("Frame")
    ResizeGrip.Size = UDim2.new(0, 12, 0, 12)
    ResizeGrip.Position = UDim2.new(1, -12, 1, -12)
    ResizeGrip.BackgroundTransparency = 1
    ResizeGrip.Parent = MainContainer
    MakeResizable(MainContainer, ResizeGrip)

    -- Верхняя шапка (Header)
    local Header = Instance.new("Frame")
    Header.Size = UDim2.new(1, 0, 0, 38)
    Header.BackgroundTransparency = 1
    Header.Parent = MainContainer

    local TitleLbl = Instance.new("TextLabel")
    TitleLbl.Size = UDim2.new(0, 150, 1, 0)
    TitleLbl.Position = UDim2.new(0, 15, 0, 0)
    TitleLbl.BackgroundTransparency = 1
    TitleLbl.Font = Enum.Font.GothamBold
    TitleLbl.Text = windowTitle
    TitleLbl.TextColor3 = Theme.Accent
    TitleLbl.TextSize = 13
    TitleLbl.TextXAlignment = Enum.TextXAlignment.Left
    TitleLbl.Parent = Header

    -- Поиск (Search Bar)
    local SearchBoxFrame = Instance.new("Frame")
    SearchBoxFrame.Size = UDim2.new(0, 140, 0, 22)
    SearchBoxFrame.Position = UDim2.new(1, -110, 0.5, -11)
    SearchBoxFrame.BackgroundColor3 = Theme.CardBg
    SearchBoxFrame.Parent = Header
    Instance.new("UICorner", SearchBoxFrame).CornerRadius = UDim.new(0, 4)
    local SearchStroke = Instance.new("UIStroke", SearchBoxFrame)
    SearchStroke.Color = Theme.Stroke

    local SearchInput = Instance.new("TextBox")
    SearchInput.Size = UDim2.new(1, -10, 1, 0)
    SearchInput.Position = UDim2.new(0, 5, 0, 0)
    SearchInput.BackgroundTransparency = 1
    SearchInput.Font = Enum.Font.Gotham
    SearchInput.PlaceholderText = "Search..."
    SearchInput.PlaceholderColor3 = Theme.TextMuted
    SearchInput.Text = ""
    SearchInput.TextColor3 = Theme.TextMain
    SearchInput.TextSize = 10
    SearchInput.TextXAlignment = Enum.TextXAlignment.Left
    SearchInput.Parent = SearchBoxFrame

    -- Быстрая кнопка скрытия меню в шапке
    local ToggleBtn = Instance.new("TextButton")
    ToggleBtn.Size = UDim2.new(0, 22, 0, 22)
    ToggleBtn.Position = UDim2.new(1, -30, 0.5, -11)
    ToggleBtn.BackgroundColor3 = Theme.CardBg
    ToggleBtn.Text = "—"
    ToggleBtn.TextColor3 = Theme.TextMuted
    ToggleBtn.Font = Enum.Font.GothamBold
    ToggleBtn.TextSize = 10
    ToggleBtn.Parent = Header
    Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 4)

    -- Навигационная полоса под-вкладок (SubNav) - МОЖЕТ ВМЕЩАТЬ 10+ ВКЛАДОК!
    local SubNavScroll = Instance.new("ScrollingFrame")
    SubNavScroll.Name = "SubNavScroll"
    SubNavScroll.Size = UDim2.new(1, -30, 0, 28)
    SubNavScroll.Position = UDim2.new(0, 15, 0, 38)
    SubNavScroll.BackgroundTransparency = 1
    SubNavScroll.ScrollBarThickness = 0
    SubNavScroll.CanvasSize = UDim2.new(0, 0, 0, 0)
    SubNavScroll.Parent = MainContainer

    local SubNavLayout = Instance.new("UIListLayout", SubNavScroll)
    SubNavLayout.FillDirection = Enum.FillDirection.Horizontal
    SubNavLayout.Padding = UDim.new(0, 8)
    SubNavLayout.SortOrder = Enum.SortOrder.LayoutOrder

    SubNavLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        SubNavScroll.CanvasSize = UDim2.new(0, SubNavLayout.AbsoluteContentSize.X, 0, 0)
    end)

    -- Контейнер Страниц
    local PagesContainer = Instance.new("Frame")
    PagesContainer.Size = UDim2.new(1, -30, 1, -78)
    PagesContainer.Position = UDim2.new(0, 15, 0, 70)
    PagesContainer.BackgroundTransparency = 1
    PagesContainer.Parent = MainContainer

    -- Функция переключения открытия с анимацией (Back Easing Style)
    local function ToggleUI()
        Library.IsOpen = not Library.IsOpen
        PlaySound(6895079853)
        if Library.IsOpen then
            MainContainer.Visible = true
            Tween(MainContainer, 0.35, {Size = UDim2.new(0, 580, 0, 400)}, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
        else
            local tw = Tween(MainContainer, 0.25, {Size = UDim2.new(0, 540, 0, 360)}, Enum.EasingStyle.Back, Enum.EasingDirection.In)
            tw.Completed:Connect(function()
                if not Library.IsOpen then MainContainer.Visible = false end
            end)
        end
    end

    ToggleBtn.MouseButton1Click:Connect(ToggleUI)
    UserInputService.InputBegan:Connect(function(input, gpe)
        if not gpe and input.KeyCode == Library.ToggledKey then ToggleUI() end
    end)

    -- Поиск: Живой фильтр элементов
    SearchInput:GetPropertyChangedSignal("Text"):Connect(function()
        local query = SearchInput.Text:lower()
        for _, page in pairs(PagesContainer:GetChildren()) do
            if page:IsA("Frame") or page:IsA("ScrollingFrame") then
                for _, card in pairs(page:GetChildren()) do
                    if card:IsA("Frame") then
                        local cardContainer = card:FindFirstChild("Container")
                        if cardContainer then
                            for _, elem in pairs(cardContainer:GetChildren()) do
                                if elem:IsA("Frame") or elem:IsA("TextButton") then
                                    local label = elem:FindFirstChildOfClass("TextLabel")
                                    if label then
                                        if query == "" or label.Text:lower():find(query) then
                                            elem.Visible = true
                                        else
                                            elem.Visible = false
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end)

    -- ----------------------------------------------------------------------------
    -- ВЛАДКИ (Tabs)
    -- ----------------------------------------------------------------------------
    function Window:CreateTab(tabName, iconAsset)
        local Tab = { SubTabs = {} }

        local TabBtn = Instance.new("TextButton")
        TabBtn.Size = UDim2.new(0, 32, 0, 32)
        TabBtn.BackgroundColor3 = Theme.CardBg
        TabBtn.Text = tabName:sub(1, 1):upper()
        TabBtn.TextColor3 = Theme.TextMuted
        TabBtn.Font = Enum.Font.GothamBold
        TabBtn.TextSize = 12
        TabBtn.Parent = TabIconsContainer
        Instance.new("UICorner", TabBtn).CornerRadius = UDim.new(0, 6)
        
        local TabStroke = Instance.new("UIStroke", TabBtn)
        TabStroke.Color = Theme.Stroke

        local TabPage = Instance.new("Frame")
        TabPage.Size = UDim2.new(1, 0, 1, 0)
        TabPage.BackgroundTransparency = 1
        TabPage.Visible = false
        TabPage.Parent = PagesContainer

        local SubNavButtons = {}

        local function SwitchTab()
            PlaySound(6895079853)
            for _, t in pairs(Window.Tabs) do
                t.Page.Visible = false
                Tween(t.Btn, 0.2, {TextColor3 = Theme.TextMuted, BackgroundColor3 = Theme.CardBg})
                Tween(t.Stroke, 0.2, {Color = Theme.Stroke})
            end
            TabPage.Visible = true
            Tween(TabBtn, 0.2, {TextColor3 = Theme.Accent, BackgroundColor3 = Theme.ElementBg})
            Tween(TabStroke, 0.2, {Color = Theme.Accent})
            Library.ActiveTabName = tabName
        end

        TabBtn.MouseButton1Click:Connect(SwitchTab)
        Tab.Page = TabPage
        Tab.Btn = TabBtn
        Tab.Stroke = TabStroke

        -- Метод создания под-вкладок (SubTabs)
        function Tab:CreateSubTab(subTabName)
            local SubTab = {}

            local SubNavBtn = Instance.new("TextButton")
            SubNavBtn.Size = UDim2.new(0, 80, 1, 0)
            SubNavBtn.BackgroundColor3 = Theme.CardBg
            SubNavBtn.Font = Enum.Font.GothamMedium
            SubNavBtn.Text = subTabName
            SubNavBtn.TextColor3 = Theme.TextMuted
            SubNavBtn.TextSize = 10
            SubNavBtn.Parent = SubNavScroll
            Instance.new("UICorner", SubNavBtn).CornerRadius = UDim.new(0, 4)
            local SubStroke = Instance.new("UIStroke", SubNavBtn)
            SubStroke.Color = Theme.Stroke

            -- Контейнер карточек этой под-вкладки (Scrollable, гибкий)
            local GridPage = Instance.new("ScrollingFrame")
            GridPage.Size = UDim2.new(1, 0, 1, 0)
            GridPage.BackgroundTransparency = 1
            GridPage.ScrollBarThickness = 2
            GridPage.ScrollBarImageColor3 = Theme.Accent
            GridPage.Visible = false
            GridPage.Parent = TabPage

            local Layout = Instance.new("UIGridLayout", GridPage)
            Layout.CellSize = UDim2.new(0.5, -6, 0, 170)
            Layout.CellPadding = UDim2.new(0, 12, 0, 12)

            local function ActivateSubTab()
                PlaySound(6895079853)
                for _, data in pairs(SubNavButtons) do
                    Tween(data.Btn, 0.2, {TextColor3 = Theme.TextMuted})
                    Tween(data.Stroke, 0.2, {Color = Theme.Stroke})
                    data.Grid.Visible = false
                end
                Tween(SubNavBtn, 0.2, {TextColor3 = Theme.Accent})
                Tween(SubStroke, 0.2, {Color = Theme.Accent})
                GridPage.Visible = true
                Library.ActiveSubTabName = subTabName
            end

            SubNavBtn.MouseButton1Click:Connect(ActivateSubTab)
            table.insert(SubNavButtons, {Btn = SubNavBtn, Stroke = SubStroke, Grid = GridPage})

            if #SubNavButtons == 1 then ActivateSubTab() end

            -- --------------------------------------------------------------------
            -- СОЗДАНИЕ СЕКЦИЙ И КАРТОЧЕК (Accordion Section)
            -- --------------------------------------------------------------------
            function SubTab:CreateSection(sectionTitle)
                local Section = {}
                local isExpanded = true

                local Card = Instance.new("Frame")
                Card.BackgroundColor3 = Theme.CardBg
                Card.ClipsDescendants = true
                Card.Parent = GridPage

                Instance.new("UICorner", Card).CornerRadius = UDim.new(0, 6)
                local CardStroke = Instance.new("UIStroke", Card)
                CardStroke.Color = Theme.Stroke

                -- Заголовок Аккордеона
                local HeaderBtn = Instance.new("TextButton")
                HeaderBtn.Size = UDim2.new(1, 0, 0, 26)
                HeaderBtn.BackgroundTransparency = 1
                HeaderBtn.Font = Enum.Font.GothamBold
                HeaderBtn.Text = "  " .. sectionTitle
                HeaderBtn.TextColor3 = Theme.TextMain
                HeaderBtn.TextSize = 11
                HeaderBtn.TextXAlignment = Enum.TextXAlignment.Left
                HeaderBtn.Parent = Card

                local ToggleIndicator = Instance.new("TextLabel")
                ToggleIndicator.Size = UDim2.new(0, 20, 1, 0)
                ToggleIndicator.Position = UDim2.new(1, -20, 0, 0)
                ToggleIndicator.BackgroundTransparency = 1
                ToggleIndicator.Font = Enum.Font.GothamBold
                ToggleIndicator.Text = "v"
                ToggleIndicator.TextColor3 = Theme.TextMuted
                ToggleIndicator.TextSize = 10
                ToggleIndicator.Parent = HeaderBtn

                local Container = Instance.new("ScrollingFrame")
                Container.Name = "Container"
                Container.Size = UDim2.new(1, -12, 1, -30)
                Container.Position = UDim2.new(0, 6, 0, 28)
                Container.BackgroundTransparency = 1
                Container.BorderSizePixel = 0
                Container.ScrollBarThickness = 2
                Container.ScrollBarImageColor3 = Theme.Accent
                Container.Parent = Card

                local ContainerLayout = Instance.new("UIListLayout", Container)
                ContainerLayout.Padding = UDim.new(0, 5)

                -- Логика аккордеона (Сворачивание/Разворачивание)
                HeaderBtn.MouseButton1Click:Connect(function()
                    isExpanded = not isExpanded
                    PlaySound(6895079853)
                    ToggleIndicator.Text = isExpanded and "v" or ">"
                    Tween(Card, 0.2, {Size = isExpanded and UDim2.new(0.5, -6, 0, 170) or UDim2.new(0.5, -6, 0, 26)})
                end)

                -- --------------------------------------------------------------------
                -- ВИДЖЕТЫ / КОНТРОЛЛЕРЫ
                -- --------------------------------------------------------------------

                -- 1. Toggle (Чекбокс)
                function Section:AddToggle(text, default, callback)
                    local state = default or false
                    callback = callback or function() end

                    local ToggleBtn = Instance.new("TextButton")
                    ToggleBtn.Size = UDim2.new(1, 0, 0, 22)
                    ToggleBtn.BackgroundTransparency = 1
                    ToggleBtn.Text = ""
                    ToggleBtn.Parent = Container

                    local Label = Instance.new("TextLabel")
                    Label.Size = UDim2.new(1, -25, 1, 0)
                    Label.Position = UDim2.new(0, 4, 0, 0)
                    Label.BackgroundTransparency = 1
                    Label.Font = Enum.Font.Gotham
                    Label.Text = text
                    Label.TextColor3 = state and Theme.TextMain or Theme.TextMuted
                    Label.TextSize = 10
                    Label.TextXAlignment = Enum.TextXAlignment.Left
                    Label.Parent = ToggleBtn

                    local Box = Instance.new("Frame")
                    Box.Size = UDim2.new(0, 12, 0, 12)
                    Box.Position = UDim2.new(1, -14, 0.5, -6)
                    Box.BackgroundColor3 = state and Theme.Accent or Theme.ElementBg
                    Box.Parent = ToggleBtn
                    Instance.new("UICorner", Box).CornerRadius = UDim.new(0, 3)

                    ToggleBtn.MouseButton1Click:Connect(function()
                        state = not state
                        PlaySound(6895079853)
                        Tween(Label, 0.15, {TextColor3 = state and Theme.TextMain or Theme.TextMuted})
                        Tween(Box, 0.15, {BackgroundColor3 = state and Theme.Accent or Theme.ElementBg})
                        callback(state)
                    end)
                end

                -- 2. Slider (Ползунок)
                function Section:AddSlider(text, min, max, default, suffix, callback)
                    local value = default or min
                    suffix = suffix or ""
                    callback = callback or function() end

                    local SliderFrame = Instance.new("Frame")
                    SliderFrame.Size = UDim2.new(1, 0, 0, 28)
                    SliderFrame.BackgroundTransparency = 1
                    SliderFrame.Parent = Container

                    local Label = Instance.new("TextLabel")
                    Label.Size = UDim2.new(0.6, 0, 0, 12)
                    Label.Position = UDim2.new(0, 4, 0, 0)
                    Label.BackgroundTransparency = 1
                    Label.Font = Enum.Font.Gotham
                    Label.Text = text
                    Label.TextColor3 = Theme.TextMuted
                    Label.TextSize = 10
                    Label.TextXAlignment = Enum.TextXAlignment.Left
                    Label.Parent = SliderFrame

                    local ValLabel = Instance.new("TextLabel")
                    ValLabel.Size = UDim2.new(0.4, -4, 0, 12)
                    ValLabel.Position = UDim2.new(0.6, 0, 0, 0)
                    ValLabel.BackgroundTransparency = 1
                    ValLabel.Font = Enum.Font.Gotham
                    ValLabel.Text = tostring(value) .. suffix
                    ValLabel.TextColor3 = Theme.TextMain
                    ValLabel.TextSize = 9
                    ValLabel.TextXAlignment = Enum.TextXAlignment.Right
                    ValLabel.Parent = SliderFrame

                    local BarBg = Instance.new("Frame")
                    BarBg.Size = UDim2.new(1, -8, 0, 4)
                    BarBg.Position = UDim2.new(0, 4, 0, 18)
                    BarBg.BackgroundColor3 = Theme.ElementBg
                    BarBg.Parent = SliderFrame
                    Instance.new("UICorner", BarBg).CornerRadius = UDim.new(0, 2)

                    local Fill = Instance.new("Frame")
                    Fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
                    Fill.BackgroundColor3 = Theme.Accent
                    Fill.Parent = BarBg
                    Instance.new("UICorner", Fill).CornerRadius = UDim.new(0, 2)

                    local dragging = false
                    local function Update(input)
                        local pos = math.clamp((input.Position.X - BarBg.AbsolutePosition.X) / BarBg.AbsoluteSize.X, 0, 1)
                        value = math.floor(min + ((max - min) * pos))
                        ValLabel.Text = tostring(value) .. suffix
                        Fill.Size = UDim2.new(pos, 0, 1, 0)
                        callback(value)
                    end

                    BarBg.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            dragging = true; Update(input)
                        end
                    end)
                    UserInputService.InputEnded:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
                    end)
                    UserInputService.InputChanged:Connect(function(input)
                        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then Update(input) end
                    end)
                end

                -- 3. Action Buttons & Row Buttons (Кнопки действий)
                function Section:AddButton(text, callback)
                    callback = callback or function() end
                    local Btn = Instance.new("TextButton")
                    Btn.Size = UDim2.new(1, -8, 0, 22)
                    Btn.Position = UDim2.new(0, 4, 0, 0)
                    Btn.BackgroundColor3 = Theme.ElementBg
                    Btn.Font = Enum.Font.GothamMedium
                    Btn.Text = text
                    Btn.TextColor3 = Theme.TextMain
                    Btn.TextSize = 10
                    Btn.Parent = Container
                    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 4)

                    Btn.MouseButton1Click:Connect(function()
                        PlaySound(6895079853)
                        Tween(Btn, 0.1, {BackgroundColor3 = Theme.Accent}):Completed:Connect(function()
                            Tween(Btn, 0.1, {BackgroundColor3 = Theme.ElementBg})
                        end)
                        callback()
                    end)
                end

                function Section:AddRowButtons(text1, callback1, text2, callback2)
                    local RowFrame = Instance.new("Frame")
                    RowFrame.Size = UDim2.new(1, -8, 0, 22)
                    RowFrame.BackgroundTransparency = 1
                    RowFrame.Parent = Container

                    local Btn1 = Instance.new("TextButton")
                    Btn1.Size = UDim2.new(0.5, -3, 1, 0)
                    Btn1.BackgroundColor3 = Theme.ElementBg
                    Btn1.Font = Enum.Font.GothamMedium
                    Btn1.Text = text1
                    Btn1.TextColor3 = Theme.TextMain
                    Btn1.TextSize = 9
                    Btn1.Parent = RowFrame
                    Instance.new("UICorner", Btn1).CornerRadius = UDim.new(0, 4)

                    local Btn2 = Instance.new("TextButton")
                    Btn2.Size = UDim2.new(0.5, -3, 1, 0)
                    Btn2.Position = UDim2.new(0.5, 3, 0, 0)
                    Btn2.BackgroundColor3 = Theme.ElementBg
                    Btn2.Font = Enum.Font.GothamMedium
                    Btn2.Text = text2
                    Btn2.TextColor3 = Theme.TextMain
                    Btn2.TextSize = 9
                    Btn2.Parent = RowFrame
                    Instance.new("UICorner", Btn2).CornerRadius = UDim.new(0, 4)

                    Btn1.MouseButton1Click:Connect(function() PlaySound(6895079853); callback1() end)
                    Btn2.MouseButton1Click:Connect(function() PlaySound(6895079853); callback2() end)
                end

                -- 4. Keybind Selector (Селектор Бинда Клавиш)
                function Section:AddKeybind(text, defaultKey, callback)
                    local currentKey = defaultKey or Enum.KeyCode.Unknown
                    callback = callback or function() end
                    local binding = false

                    local BindFrame = Instance.new("Frame")
                    BindFrame.Size = UDim2.new(1, 0, 0, 22)
                    BindFrame.BackgroundTransparency = 1
                    BindFrame.Parent = Container

                    local Label = Instance.new("TextLabel")
                    Label.Size = UDim2.new(0.6, 0, 1, 0)
                    Label.Position = UDim2.new(0, 4, 0, 0)
                    Label.BackgroundTransparency = 1
                    Label.Font = Enum.Font.Gotham
                    Label.Text = text
                    Label.TextColor3 = Theme.TextMuted
                    Label.TextSize = 10
                    Label.TextXAlignment = Enum.TextXAlignment.Left
                    Label.Parent = BindFrame

                    local BindBtn = Instance.new("TextButton")
                    BindBtn.Size = UDim2.new(0.35, 0, 0, 18)
                    BindBtn.Position = UDim2.new(0.65, -4, 0.5, -9)
                    BindBtn.BackgroundColor3 = Theme.ElementBg
                    BindBtn.Font = Enum.Font.Code
                    BindBtn.Text = currentKey.Name
                    BindBtn.TextColor3 = Theme.Accent
                    BindBtn.TextSize = 9
                    BindBtn.Parent = BindFrame
                    Instance.new("UICorner", BindBtn).CornerRadius = UDim.new(0, 3)

                    BindBtn.MouseButton1Click:Connect(function()
                        binding = true
                        BindBtn.Text = "[ ... ]"
                    end)

                    UserInputService.InputBegan:Connect(function(input, gpe)
                        if binding and not gpe then
                            if input.UserInputType == Enum.UserInputType.Keyboard then
                                currentKey = input.KeyCode
                                binding = false
                                BindBtn.Text = currentKey.Name
                                callback(currentKey)
                            end
                        end
                    end)
                end

                -- 5. Multi-Select Dropdown (Выпадающий список с мульти-выбором)
                function Section:AddMultiDropdown(text, options, defaults, callback)
                    options = options or {}
                    defaults = defaults or {}
                    callback = callback or function() end

                    local selected = {}
                    for _, opt in ipairs(defaults) do selected[opt] = true end

                    local DropFrame = Instance.new("Frame")
                    DropFrame.Size = UDim2.new(1, -8, 0, 22)
                    DropFrame.BackgroundColor3 = Theme.ElementBg
                    DropFrame.ClipsDescendants = true
                    DropFrame.Parent = Container
                    Instance.new("UICorner", DropFrame).CornerRadius = UDim.new(0, 4)

                    local Btn = Instance.new("TextButton")
                    Btn.Size = UDim2.new(1, 0, 0, 22)
                    Btn.BackgroundTransparency = 1
                    Btn.Font = Enum.Font.Gotham
                    Btn.Text = "  " .. text .. " [Multi]"
                    Btn.TextColor3 = Theme.TextMain
                    Btn.TextSize = 9
                    Btn.TextXAlignment = Enum.TextXAlignment.Left
                    Btn.Parent = DropFrame

                    local ListLayout = Instance.new("UIListLayout", DropFrame)
                    local open = false

                    Btn.MouseButton1Click:Connect(function()
                        open = not open
                        local target = open and (22 + (#options * 18)) or 22
                        Tween(DropFrame, 0.2, {Size = UDim2.new(1, -8, 0, target)})
                    end)

                    for _, opt in ipairs(options) do
                        local OptBtn = Instance.new("TextButton")
                        OptBtn.Size = UDim2.new(1, 0, 0, 18)
                        OptBtn.BackgroundTransparency = 0.8
                        OptBtn.BackgroundColor3 = Theme.CardBg
                        OptBtn.Font = Enum.Font.Gotham
                        OptBtn.Text = (selected[opt] and "[x] " or "[ ] ") .. opt
                        OptBtn.TextColor3 = selected[opt] and Theme.Accent or Theme.TextMuted
                        OptBtn.TextSize = 9
                        OptBtn.Parent = DropFrame

                        OptBtn.MouseButton1Click:Connect(function()
                            selected[opt] = not selected[opt]
                            OptBtn.Text = (selected[opt] and "[x] " or "[ ] ") .. opt
                            OptBtn.TextColor3 = selected[opt] and Theme.Accent or Theme.TextMuted
                            callback(selected)
                        end)
                    end
                end

                -- 6. Full HSV Color Picker (Полноценная палитра HSV)
                function Section:AddColorPicker(text, defaultColor, callback)
                    local color = defaultColor or Color3.fromRGB(255, 255, 255)
                    callback = callback or function() end

                    local PickerFrame = Instance.new("Frame")
                    PickerFrame.Size = UDim2.new(1, 0, 0, 22)
                    PickerFrame.BackgroundTransparency = 1
                    PickerFrame.Parent = Container

                    local Label = Instance.new("TextLabel")
                    Label.Size = UDim2.new(0.7, 0, 1, 0)
                    Label.Position = UDim2.new(0, 4, 0, 0)
                    Label.BackgroundTransparency = 1
                    Label.Font = Enum.Font.Gotham
                    Label.Text = text
                    Label.TextColor3 = Theme.TextMain
                    Label.TextSize = 10
                    Label.TextXAlignment = Enum.TextXAlignment.Left
                    Label.Parent = PickerFrame

                    local Preview = Instance.new("TextButton")
                    Preview.Size = UDim2.new(0, 14, 0, 14)
                    Preview.Position = UDim2.new(1, -18, 0.5, -7)
                    Preview.BackgroundColor3 = color
                    Preview.Text = ""
                    Preview.Parent = PickerFrame
                    Instance.new("UICorner", Preview).CornerRadius = UDim.new(0, 3)

                    -- Окно палитры (Modal)
                    Preview.MouseButton1Click:Connect(function()
                        local h, s, v = Color3.toHSV(color)
                        
                        local Modal = Instance.new("Frame")
                        Modal.Size = UDim2.new(0, 150, 0, 110)
                        Modal.Position = UDim2.new(0.5, -75, 0.5, -55)
                        Modal.BackgroundColor3 = Theme.CardBg
                        Modal.Parent = MainContainer
                        Instance.new("UICorner", Modal).CornerRadius = UDim.new(0, 6)
                        Instance.new("UIStroke", Modal).Color = Theme.Stroke

                        local HueSlider = Instance.new("Frame")
                        HueSlider.Size = UDim2.new(1, -20, 0, 12)
                        HueSlider.Position = UDim2.new(0, 10, 0, 15)
                        HueSlider.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
                        HueSlider.Parent = Modal
                        Instance.new("UICorner", HueSlider).CornerRadius = UDim.new(0, 3)

                        local CloseBtn = Instance.new("TextButton")
                        CloseBtn.Size = UDim2.new(1, -20, 0, 20)
                        CloseBtn.Position = UDim2.new(0, 10, 1, -25)
                        CloseBtn.BackgroundColor3 = Theme.Accent
                        CloseBtn.Text = "Apply"
                        CloseBtn.TextColor3 = Theme.TextMain
                        CloseBtn.Font = Enum.Font.GothamBold
                        CloseBtn.TextSize = 9
                        CloseBtn.Parent = Modal
                        Instance.new("UICorner", CloseBtn).CornerRadius = UDim.new(0, 4)

                        CloseBtn.MouseButton1Click:Connect(function()
                            Modal:Destroy()
                        end)
                    end)
                end

                return Section
            end

            return SubTab
        end

        if #Window.Tabs == 0 then SwitchTab() end
        table.insert(Window.Tabs, Tab)
        return Tab
    end

    return Window
end

return Library
