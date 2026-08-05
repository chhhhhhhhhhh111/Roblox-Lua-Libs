-- ================================================================================
-- DARK PREMIUM UI LIBRARY (Luau)
-- Theme: Dark (#141414) with Purple Accent (#6E50FF)
-- ================================================================================

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

-- Инициализация объекта библиотеки
local Library = {
    ActiveTab = nil,
    ActiveTabName = "Visuals",
    ActiveSubTabName = "ESP",
    IsOpen = true,
    ToggledKey = Enum.KeyCode.Insert
}
Library.__index = Library

-- Цветовая палитра (Dark Premium)
local Theme = {
    MainBg = Color3.fromRGB(20, 20, 20),
    CardBg = Color3.fromRGB(25, 25, 25),
    ElementBg = Color3.fromRGB(32, 32, 32),
    Accent = Color3.fromRGB(110, 80, 255),
    AccentInactive = Color3.fromRGB(45, 45, 45),
    TextMain = Color3.fromRGB(255, 255, 255),
    TextMuted = Color3.fromRGB(150, 150, 150),
    Stroke = Color3.fromRGB(40, 40, 40),
    StrokeHover = Color3.fromRGB(80, 80, 80)
}

-- ================================================================================
-- ВСПОМОГАТЕЛЬНЫЕ ФУНКЦИИ
-- ================================================================================

local function Tween(object, time, properties, style, direction)
    local tweenInfo = TweenInfo.new(time or 0.25, style or Enum.EasingStyle.Quart, direction or Enum.EasingDirection.Out)
    local tween = TweenService:Create(object, tweenInfo, properties)
    tween:Play()
    return tween
end

-- Функция безопасного загрузчика иконок Icons8 (загрузка через request/getcustomasset или fallback)
local function GetIconAsset(iconName)
    if not iconName or iconName == "" then return "" end
    if iconName:sub(1, 13) == "rbxassetid://" then return iconName end
    
    local fileName = "icon8_" .. iconName .. ".png"
    
    -- Проверка на наличие функций эксплойта для работы с ФС и сетью
    local requestFunc = (syn and syn.request) or (http and http.request) or http_request or request
    local getAssetFunc = getcustomasset or getassethandle
    
    if isfile and isfile(fileName) and getAssetFunc then
        return getAssetFunc(fileName)
    end
    
    if requestFunc and writefile and getAssetFunc then
        local url = string.format("https://img.icons8.com/ios-glyphs/30/ffffff/%s.png", iconName)
        local success, result = pcall(function()
            return requestFunc({Url = url, Method = "GET"})
        end)
        
        if success and result and result.StatusCode == 200 then
            writefile(fileName, result.Body)
            return getAssetFunc(fileName)
        end
    end
    
    -- Дефолтный фоллбэк (стандартный ID в Roblox, если внешняя загрузка недоступна)
    return "rbxassetid://6031763426"
end

-- Функция перетаскивания (Drag & Drop)
local function MakeDraggable(frame, handle)
    local dragging = false
    local dragInput, dragStart, startPos
    
    handle = handle or frame
    
    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    handle.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            Tween(frame, 0.1, {Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)})
        end
    end)
end

-- ================================================================================
-- СОЗДАНИЕ ОКНА (CreateWindow)
-- ================================================================================

function Library:CreateWindow(windowTitle)
    local Window = {
        Tabs = {},
        CurrentTab = nil
    }
    
    -- Родительский ScreenGui с защитой
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "DarkPremiumUI_" .. math.random(1000, 9999)
    ScreenGui.ResetOnSpawn = false
    
    if gethui then
        ScreenGui.Parent = gethui()
    elseif syn and syn.protect_gui then
        syn.protect_gui(ScreenGui)
        ScreenGui.Parent = CoreGui
    else
        ScreenGui.Parent = CoreGui or LocalPlayer:WaitForChild("PlayerGui")
    end

    -- ----------------------------------------------------------------------------
    -- А. НИЖНИЙ ТАСКБАР (Windows 11 Style)
    -- ----------------------------------------------------------------------------
    local Taskbar = Instance.new("Frame")
    Taskbar.Name = "Taskbar"
    Taskbar.Size = UDim2.new(0, 680, 0, 50)
    Taskbar.Position = UDim2.new(0.5, 0, 1, -65)
    Taskbar.AnchorPoint = Vector2.new(0.5, 1)
    Taskbar.BackgroundColor3 = Theme.MainBg
    Taskbar.Parent = ScreenGui
    
    local TaskbarCorner = Instance.new("UICorner", Taskbar)
    TaskbarCorner.CornerRadius = UDim.new(0, 10)
    
    local TaskbarStroke = Instance.new("UIStroke", Taskbar)
    TaskbarStroke.Color = Theme.Stroke
    TaskbarStroke.Thickness = 1
    
    -- 1. Левая часть: Путь / Название (Например, "Visuals > ESP")
    local PathLabel = Instance.new("TextLabel")
    PathLabel.Name = "PathLabel"
    PathLabel.Size = UDim2.new(0, 180, 1, 0)
    PathLabel.Position = UDim2.new(0, 15, 0, 0)
    PathLabel.BackgroundTransparency = 1
    PathLabel.Font = Enum.Font.GothamBold
    PathLabel.Text = windowTitle or "Visuals"
    PathLabel.TextColor3 = Theme.TextMain
    PathLabel.TextSize = 14
    PathLabel.TextXAlignment = Enum.TextXAlignment.Left
    PathLabel.Parent = Taskbar
    
    -- 2. Центральная часть: Иконки вкладок
    local TabIconsContainer = Instance.new("Frame")
    TabIconsContainer.Name = "TabIconsContainer"
    TabIconsContainer.Size = UDim2.new(0, 300, 1, 0)
    TabIconsContainer.Position = UDim2.new(0.5, 0, 0, 0)
    TabIconsContainer.AnchorPoint = Vector2.new(0.5, 0)
    TabIconsContainer.BackgroundTransparency = 1
    TabIconsContainer.Parent = Taskbar
    
    local TabListLayout = Instance.new("UIListLayout", TabIconsContainer)
    TabListLayout.FillDirection = Enum.FillDirection.Horizontal
    TabListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    TabListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    TabListLayout.Padding = UDim.new(0, 8)

    -- 3. Правая часть: Профиль пользователя Roblox
    local ProfileFrame = Instance.new("Frame")
    ProfileFrame.Name = "ProfileFrame"
    ProfileFrame.Size = UDim2.new(0, 160, 1, 0)
    ProfileFrame.Position = UDim2.new(1, -15, 0, 0)
    ProfileFrame.AnchorPoint = Vector2.new(1, 0)
    ProfileFrame.BackgroundTransparency = 1
    ProfileFrame.Parent = Taskbar
    
    local AvatarImage = Instance.new("ImageLabel")
    AvatarImage.Name = "Avatar"
    AvatarImage.Size = UDim2.new(0, 32, 0, 32)
    AvatarImage.Position = UDim2.new(0, 0, 0.5, 0)
    AvatarImage.AnchorPoint = Vector2.new(0, 0.5)
    AvatarImage.BackgroundColor3 = Theme.CardBg
    AvatarImage.Parent = ProfileFrame
    
    local AvatarCorner = Instance.new("UICorner", AvatarImage)
    AvatarCorner.CornerRadius = UDim.new(1, 0)
    
    -- Загрузка аватара
    task.spawn(function()
        local content, isReady = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size100x100)
        if isReady then
            AvatarImage.Image = content
        end
    end)
    
    local UsernameLabel = Instance.new("TextLabel")
    UsernameLabel.Size = UDim2.new(1, -40, 0, 16)
    UsernameLabel.Position = UDim2.new(0, 40, 0, 9)
    UsernameLabel.BackgroundTransparency = 1
    UsernameLabel.Font = Enum.Font.GothamMedium
    UsernameLabel.Text = LocalPlayer.DisplayName
    UsernameLabel.TextColor3 = Theme.TextMain
    UsernameLabel.TextSize = 12
    UsernameLabel.TextXAlignment = Enum.TextXAlignment.Left
    UsernameLabel.TextTruncate = Enum.TextTruncate.AtEnd
    UsernameLabel.Parent = ProfileFrame
    
    local RoleLabel = Instance.new("TextLabel")
    RoleLabel.Size = UDim2.new(1, -40, 0, 14)
    RoleLabel.Position = UDim2.new(0, 40, 0, 25)
    RoleLabel.BackgroundTransparency = 1
    RoleLabel.Font = Enum.Font.Gotham
    RoleLabel.Text = "Owner"
    RoleLabel.TextColor3 = Theme.TextMuted
    RoleLabel.TextSize = 10
    RoleLabel.TextXAlignment = Enum.TextXAlignment.Left
    RoleLabel.Parent = ProfileFrame

    -- ----------------------------------------------------------------------------
    -- Б. ГЛАВНОЕ МЕНЮ (Основной Контейнер)
    -- ----------------------------------------------------------------------------
    local MainContainer = Instance.new("CanvasGroup")
    MainContainer.Name = "MainContainer"
    MainContainer.Size = UDim2.new(0, 600, 0, 420)
    MainContainer.Position = UDim2.new(0.5, 0, 0.5, -30)
    MainContainer.AnchorPoint = Vector2.new(0.5, 0.5)
    MainContainer.BackgroundColor3 = Theme.MainBg
    
    -- Корректное свойство прозрачности для CanvasGroup
    pcall(function()
        MainContainer.GroupTransparency = 0
    end)
    
    MainContainer.Parent = ScreenGui
    
    local MainCorner = Instance.new("UICorner", MainContainer)
    MainCorner.CornerRadius = UDim.new(0, 8)
    
    local MainStroke = Instance.new("UIStroke", MainContainer)
    MainStroke.Color = Theme.Stroke
    MainStroke.Thickness = 1
    
    MakeDraggable(MainContainer)

    -- Подшапка со списками под-вкладок (ESP / Radar / Builder)
    local SubNavFrame = Instance.new("Frame")
    SubNavFrame.Name = "SubNavFrame"
    SubNavFrame.Size = UDim2.new(1, 0, 0, 45)
    SubNavFrame.BackgroundTransparency = 1
    SubNavFrame.Parent = MainContainer
    
    local SubNavLayout = Instance.new("UIListLayout", SubNavFrame)
    SubNavLayout.FillDirection = Enum.FillDirection.Horizontal
    SubNavLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    SubNavLayout.VerticalAlignment = Enum.VerticalAlignment.Center
    SubNavLayout.Padding = UDim.new(0, 40)
    
    -- Контейнер для содержимого страниц
    local PagesContainer = Instance.new("Frame")
    PagesContainer.Name = "PagesContainer"
    PagesContainer.Size = UDim2.new(1, -30, 1, -60)
    PagesContainer.Position = UDim2.new(0, 15, 0, 50)
    PagesContainer.BackgroundTransparency = 1
    PagesContainer.Parent = MainContainer

    -- Обработка переключения видимости по клавише Insert
    UserInputService.InputBegan:Connect(function(input, gpe)
        if not gpe and input.KeyCode == Library.ToggledKey then
            Library.IsOpen = not Library.IsOpen
            if Library.IsOpen then
                MainContainer.Visible = true
                pcall(function() Tween(MainContainer, 0.3, {GroupTransparency = 0}) end)
                Tween(MainContainer, 0.3, {Size = UDim2.new(0, 600, 0, 420)})
            else
                pcall(function() Tween(MainContainer, 0.25, {GroupTransparency = 1}) end)
                local tw = Tween(MainContainer, 0.25, {Size = UDim2.new(0, 580, 0, 400)})
                tw.Completed:Connect(function()
                    if not Library.IsOpen then MainContainer.Visible = false end
                end)
            end
        end
    end)

    -- Обновление пути в таскбаре
    local function UpdatePath()
        PathLabel.Text = Library.ActiveTabName .. " > <font color=\"#6E50FF\">" .. Library.ActiveSubTabName .. "</font>"
        PathLabel.RichText = true
    end

    -- ----------------------------------------------------------------------------
    -- ВЛАДКИ И СЕКЦИИ
    -- ----------------------------------------------------------------------------
    function Window:CreateTab(tabName, iconName)
        local Tab = {
            SubTabs = {},
            Button = nil
        }
        
        -- Кнопка-иконка в Таскбар
        local TabIconButton = Instance.new("ImageButton")
        TabIconButton.Name = tabName .. "_Icon"
        TabIconButton.Size = UDim2.new(0, 36, 0, 36)
        TabIconButton.BackgroundColor3 = Theme.CardBg
        TabIconButton.BackgroundTransparency = 0.5
        TabIconButton.Image = GetIconAsset(iconName or "eye")
        TabIconButton.ImageColor3 = Theme.TextMuted
        TabIconButton.Parent = TabIconsContainer
        
        local TabIconCorner = Instance.new("UICorner", TabIconButton)
        TabIconCorner.CornerRadius = UDim.new(0, 8)
        
        local TabIconStroke = Instance.new("UIStroke", TabIconButton)
        TabIconStroke.Color = Theme.Stroke
        TabIconStroke.Thickness = 1
        
        -- Подстраница под эту вкладку
        local TabPage = Instance.new("Frame")
        TabPage.Name = tabName .. "_Page"
        TabPage.Size = UDim2.new(1, 0, 1, 0)
        TabPage.BackgroundTransparency = 1
        TabPage.Visible = false
        TabPage.Parent = PagesContainer

        local SubNavButtons = {}

        local function SwitchTab()
            for _, t in pairs(Window.Tabs) do
                t.Page.Visible = false
                Tween(t.IconButton, 0.2, {BackgroundTransparency = 0.5, ImageColor3 = Theme.TextMuted})
                Tween(t.IconStroke, 0.2, {Color = Theme.Stroke})
            end
            TabPage.Visible = true
            Tween(TabIconButton, 0.2, {BackgroundTransparency = 0, ImageColor3 = Theme.Accent})
            Tween(TabIconStroke, 0.2, {Color = Theme.Accent})
            
            Library.ActiveTabName = tabName
            UpdatePath()
        end

        TabIconButton.MouseButton1Click:Connect(SwitchTab)
        
        Tab.Page = TabPage
        Tab.IconButton = TabIconButton
        Tab.IconStroke = TabIconStroke

        -- Метод создания под-вкладок (ESP / Radar / Builder)
        function Tab:CreateSubTab(subTabName)
            local SubTab = {}
            
            -- Кнопка под-навигации в верхней части
            local SubNavBtn = Instance.new("TextButton")
            SubNavBtn.Name = subTabName .. "_SubBtn"
            SubNavBtn.Size = UDim2.new(0, 70, 1, 0)
            SubNavBtn.BackgroundTransparency = 1
            SubNavBtn.Font = Enum.Font.GothamMedium
            SubNavBtn.Text = subTabName
            SubNavBtn.TextColor3 = Theme.TextMuted
            SubNavBtn.TextSize = 13
            SubNavBtn.Parent = SubNavFrame
            
            -- Индикатор активной вкладки (фиолетовая полоска)
            local Indicator = Instance.new("Frame")
            Indicator.Size = UDim2.new(0, 0, 0, 2)
            Indicator.Position = UDim2.new(0.5, 0, 1, -2)
            Indicator.AnchorPoint = Vector2.new(0.5, 0)
            Indicator.BackgroundColor3 = Theme.Accent
            Indicator.BorderSizePixel = 0
            Indicator.Parent = SubNavBtn

            -- Сетка карточек (2х2)
            local GridPage = Instance.new("Frame")
            GridPage.Name = subTabName .. "_Grid"
            GridPage.Size = UDim2.new(1, 0, 1, 0)
            GridPage.BackgroundTransparency = 1
            GridPage.Visible = false
            GridPage.Parent = TabPage

            local GridLayout = Instance.new("UIGridLayout", GridPage)
            GridLayout.CellSize = UDim2.new(0.5, -6, 0.5, -6)
            GridLayout.CellPadding = UDim2.new(0, 12, 0, 12)

            local function ActivateSubTab()
                for _, btnData in pairs(SubNavButtons) do
                    Tween(btnData.Btn, 0.2, {TextColor3 = Theme.TextMuted})
                    Tween(btnData.Indicator, 0.2, {Size = UDim2.new(0, 0, 0, 2)})
                    btnData.Grid.Visible = false
                end
                Tween(SubNavBtn, 0.2, {TextColor3 = Theme.TextMain})
                Tween(Indicator, 0.2, {Size = UDim2.new(0.8, 0, 0, 2)})
                GridPage.Visible = true
                
                Library.ActiveSubTabName = subTabName
                UpdatePath()
            end

            SubNavBtn.MouseButton1Click:Connect(ActivateSubTab)
            table.insert(SubNavButtons, {Btn = SubNavBtn, Indicator = Indicator, Grid = GridPage})

            if #SubNavButtons == 1 then
                ActivateSubTab()
            end

            -- Метод создания секций (Карточек)
            function SubTab:CreateSection(sectionTitle)
                local Section = {}
                
                local Card = Instance.new("Frame")
                Card.Name = sectionTitle .. "_Card"
                Card.BackgroundColor3 = Theme.CardBg
                Card.Parent = GridPage
                
                local CardCorner = Instance.new("UICorner", Card)
                CardCorner.CornerRadius = UDim.new(0, 6)
                
                local CardStroke = Instance.new("UIStroke", Card)
                CardStroke.Color = Theme.Stroke
                CardStroke.Thickness = 1

                -- Заголовок секции
                local TitleLabel = Instance.new("TextLabel")
                TitleLabel.Size = UDim2.new(1, -20, 0, 25)
                TitleLabel.Position = UDim2.new(0, 10, 0, 5)
                TitleLabel.BackgroundTransparency = 1
                TitleLabel.Font = Enum.Font.GothamBold
                TitleLabel.Text = sectionTitle
                TitleLabel.TextColor3 = Theme.TextMain
                TitleLabel.TextSize = 11
                TitleLabel.TextXAlignment = Enum.TextXAlignment.Center
                TitleLabel.Parent = Card
                
                local TitleLine = Instance.new("Frame")
                TitleLine.Size = UDim2.new(0, 20, 0, 1)
                TitleLine.Position = UDim2.new(0.5, -10, 0, 26)
                TitleLine.BackgroundColor3 = Theme.Accent
                TitleLine.BorderSizePixel = 0
                TitleLine.Parent = Card

                -- Контейнер элементов управления
                local Container = Instance.new("ScrollingFrame")
                Container.Size = UDim2.new(1, -12, 1, -38)
                Container.Position = UDim2.new(0, 6, 0, 32)
                Container.BackgroundTransparency = 1
                Container.BorderSizePixel = 0
                Container.ScrollBarThickness = 2
                Container.ScrollBarImageColor3 = Theme.Accent
                Container.Parent = Card
                
                local ContainerLayout = Instance.new("UIListLayout", Container)
                ContainerLayout.SortOrder = Enum.SortOrder.LayoutOrder
                ContainerLayout.Padding = UDim.new(0, 6)

                -- ====================================================================
                -- API ЭЛЕМЕНТОВ УПРАВЛЕНИЯ (Controls)
                -- ====================================================================

                -- 1. Toggle (Чекбокс)
                function Section:AddToggle(text, default, callback)
                    local state = default or false
                    callback = callback or function() end
                    
                    local ToggleBtn = Instance.new("TextButton")
                    ToggleBtn.Size = UDim2.new(1, 0, 0, 24)
                    ToggleBtn.BackgroundTransparency = 1
                    ToggleBtn.Text = ""
                    ToggleBtn.Parent = Container
                    
                    local Label = Instance.new("TextLabel")
                    Label.Size = UDim2.new(1, -30, 1, 0)
                    Label.Position = UDim2.new(0, 6, 0, 0)
                    Label.BackgroundTransparency = 1
                    Label.Font = Enum.Font.Gotham
                    Label.Text = text
                    Label.TextColor3 = state and Theme.TextMain or Theme.TextMuted
                    Label.TextSize = 11
                    Label.TextXAlignment = Enum.TextXAlignment.Left
                    Label.Parent = ToggleBtn
                    
                    local Box = Instance.new("Frame")
                    Box.Size = UDim2.new(0, 12, 0, 12)
                    Box.Position = UDim2.new(1, -16, 0.5, -6)
                    Box.BackgroundColor3 = state and Theme.Accent or Theme.ElementBg
                    Box.Parent = ToggleBtn
                    
                    local BoxCorner = Instance.new("UICorner", Box)
                    BoxCorner.CornerRadius = UDim.new(0, 2)
                    
                    local BoxStroke = Instance.new("UIStroke", Box)
                    BoxStroke.Color = state and Theme.Accent or Theme.Stroke
                    BoxStroke.Thickness = 1

                    local function ToggleState()
                        state = not state
                        Tween(Label, 0.2, {TextColor3 = state and Theme.TextMain or Theme.TextMuted})
                        Tween(Box, 0.2, {BackgroundColor3 = state and Theme.Accent or Theme.ElementBg})
                        Tween(BoxStroke, 0.2, {Color = state and Theme.Accent or Theme.Stroke})
                        callback(state)
                    end

                    ToggleBtn.MouseButton1Click:Connect(ToggleState)
                end

                -- 2. Slider (Ползунок)
                function Section:AddSlider(text, min, max, default, suffix, callback)
                    local value = default or min
                    suffix = suffix or ""
                    callback = callback or function() end
                    
                    local SliderFrame = Instance.new("Frame")
                    SliderFrame.Size = UDim2.new(1, 0, 0, 32)
                    SliderFrame.BackgroundTransparency = 1
                    SliderFrame.Parent = Container
                    
                    local Label = Instance.new("TextLabel")
                    Label.Size = UDim2.new(0.6, 0, 0, 14)
                    Label.Position = UDim2.new(0, 6, 0, 0)
                    Label.BackgroundTransparency = 1
                    Label.Font = Enum.Font.Gotham
                    Label.Text = text
                    Label.TextColor3 = Theme.TextMuted
                    Label.TextSize = 11
                    Label.TextXAlignment = Enum.TextXAlignment.Left
                    Label.Parent = SliderFrame
                    
                    local ValueLabel = Instance.new("TextLabel")
                    ValueLabel.Size = UDim2.new(0.4, -10, 0, 14)
                    ValueLabel.Position = UDim2.new(0.6, 0, 0, 0)
                    ValueLabel.BackgroundTransparency = 1
                    ValueLabel.Font = Enum.Font.Gotham
                    ValueLabel.Text = tostring(value) .. " " .. suffix
                    ValueLabel.TextColor3 = Theme.TextMuted
                    ValueLabel.TextSize = 10
                    ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
                    ValueLabel.Parent = SliderFrame
                    
                    local BarBg = Instance.new("Frame")
                    BarBg.Size = UDim2.new(1, -12, 0, 4)
                    BarBg.Position = UDim2.new(0, 6, 0, 20)
                    BarBg.BackgroundColor3 = Theme.ElementBg
                    BarBg.Parent = SliderFrame
                    
                    local BarCorner = Instance.new("UICorner", BarBg)
                    BarCorner.CornerRadius = UDim.new(0, 2)
                    
                    local Fill = Instance.new("Frame")
                    Fill.Size = UDim2.new((value - min) / (max - min), 0, 1, 0)
                    Fill.BackgroundColor3 = Theme.Accent
                    Fill.Parent = BarBg
                    
                    local FillCorner = Instance.new("UICorner", Fill)
                    FillCorner.CornerRadius = UDim.new(0, 2)

                    local dragging = false
                    local function UpdateSlider(input)
                        local pos = math.clamp((input.Position.X - BarBg.AbsolutePosition.X) / BarBg.AbsoluteSize.X, 0, 1)
                        value = math.floor(min + ((max - min) * pos))
                        ValueLabel.Text = tostring(value) .. " " .. suffix
                        Tween(Fill, 0.05, {Size = UDim2.new(pos, 0, 1, 0)})
                        callback(value)
                    end

                    BarBg.InputBegan:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            dragging = true
                            UpdateSlider(input)
                        end
                    end)

                    UserInputService.InputEnded:Connect(function(input)
                        if input.UserInputType == Enum.UserInputType.MouseButton1 then
                            dragging = false
                        end
                    end)

                    UserInputService.InputChanged:Connect(function(input)
                        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                            UpdateSlider(input)
                        end
                    end)
                end

                -- 3. Dropdown (Выпадающий список)
                function Section:AddDropdown(text, options, default, callback)
                    options = options or {}
                    callback = callback or function() end
                    local selected = default or options[1] or ""
                    local open = false

                    local DropFrame = Instance.new("Frame")
                    DropFrame.Size = UDim2.new(1, -12, 0, 26)
                    DropFrame.Position = UDim2.new(0, 6, 0, 0)
                    DropFrame.BackgroundColor3 = Theme.ElementBg
                    DropFrame.ClipsDescendants = true
                    DropFrame.Parent = Container

                    local DropCorner = Instance.new("UICorner", DropFrame)
                    DropCorner.CornerRadius = UDim.new(0, 4)

                    local Btn = Instance.new("TextButton")
                    Btn.Size = UDim2.new(1, 0, 0, 26)
                    Btn.BackgroundTransparency = 1
                    Btn.Font = Enum.Font.Gotham
                    Btn.Text = "  " .. text .. ": " .. selected
                    Btn.TextColor3 = Theme.TextMain
                    Btn.TextSize = 10
                    Btn.TextXAlignment = Enum.TextXAlignment.Left
                    Btn.Parent = DropFrame

                    local ListLayout = Instance.new("UIListLayout", DropFrame)
                    ListLayout.SortOrder = Enum.SortOrder.LayoutOrder

                    Btn.MouseButton1Click:Connect(function()
                        open = not open
                        local targetSize = open and (26 + (#options * 20)) or 26
                        Tween(DropFrame, 0.2, {Size = UDim2.new(1, -12, 0, targetSize)})
                    end)

                    for _, opt in ipairs(options) do
                        local OptBtn = Instance.new("TextButton")
                        OptBtn.Size = UDim2.new(1, 0, 0, 20)
                        OptBtn.BackgroundColor3 = Theme.CardBg
                        OptBtn.BackgroundTransparency = 0.5
                        OptBtn.Font = Enum.Font.Gotham
                        OptBtn.Text = opt
                        OptBtn.TextColor3 = Theme.TextMuted
                        OptBtn.TextSize = 10
                        OptBtn.Parent = DropFrame

                        OptBtn.MouseButton1Click:Connect(function()
                            selected = opt
                            Btn.Text = "  " .. text .. ": " .. selected
                            open = false
                            Tween(DropFrame, 0.2, {Size = UDim2.new(1, -12, 0, 26)})
                            callback(selected)
                        end)
                    end
                end

                -- 4. TextBox (Поле ввода)
                function Section:AddTextBox(text, placeholder, callback)
                    callback = callback or function() end
                    
                    local BoxFrame = Instance.new("Frame")
                    BoxFrame.Size = UDim2.new(1, -12, 0, 26)
                    BoxFrame.BackgroundColor3 = Theme.ElementBg
                    BoxFrame.Parent = Container

                    local BoxCorner = Instance.new("UICorner", BoxFrame)
                    BoxCorner.CornerRadius = UDim.new(0, 4)

                    local Input = Instance.new("TextBox")
                    Input.Size = UDim2.new(1, -10, 1, 0)
                    Input.Position = UDim2.new(0, 5, 0, 0)
                    Input.BackgroundTransparency = 1
                    Input.Font = Enum.Font.Gotham
                    Input.PlaceholderText = placeholder or text
                    Input.PlaceholderColor3 = Theme.TextMuted
                    Input.Text = ""
                    Input.TextColor3 = Theme.TextMain
                    Input.TextSize = 10
                    Input.TextXAlignment = Enum.TextXAlignment.Left
                    Input.Parent = BoxFrame

                    Input.FocusLost:Connect(function(enterPressed)
                        callback(Input.Text, enterPressed)
                    end)
                end

                -- 5. Color Picker (Выбор цвета)
                function Section:AddColorPicker(text, defaultColor, callback)
                    local color = defaultColor or Color3.fromRGB(255, 255, 255)
                    callback = callback or function() end

                    local PickerFrame = Instance.new("Frame")
                    PickerFrame.Size = UDim2.new(1, 0, 0, 24)
                    PickerFrame.BackgroundTransparency = 1
                    PickerFrame.Parent = Container

                    local Label = Instance.new("TextLabel")
                    Label.Size = UDim2.new(1, -30, 1, 0)
                    Label.Position = UDim2.new(0, 6, 0, 0)
                    Label.BackgroundTransparency = 1
                    Label.Font = Enum.Font.Gotham
                    Label.Text = text
                    Label.TextColor3 = Theme.TextMain
                    Label.TextSize = 11
                    Label.TextXAlignment = Enum.TextXAlignment.Left
                    Label.Parent = PickerFrame

                    local Preview = Instance.new("TextButton")
                    Preview.Size = UDim2.new(0, 16, 0, 16)
                    Preview.Position = UDim2.new(1, -20, 0.5, -8)
                    Preview.BackgroundColor3 = color
                    Preview.Text = ""
                    Preview.Parent = PickerFrame

                    local PreviewCorner = Instance.new("UICorner", Preview)
                    PreviewCorner.CornerRadius = UDim.new(0, 4)

                    Preview.MouseButton1Click:Connect(function()
                        local palette = {
                            Color3.fromRGB(110, 80, 255),
                            Color3.fromRGB(255, 50, 50),
                            Color3.fromRGB(50, 255, 50),
                            Color3.fromRGB(50, 150, 255),
                            Color3.fromRGB(255, 255, 255)
                        }
                        local nextColor = palette[math.random(1, #palette)]
                        color = nextColor
                        Tween(Preview, 0.2, {BackgroundColor3 = color})
                        callback(color)
                    end)
                end

                return Section
            end

            return SubTab
        end

        if #Window.Tabs == 0 then
            SwitchTab()
        end

        table.insert(Window.Tabs, Tab)
        return Tab
    end

    return Window
end

return Library
