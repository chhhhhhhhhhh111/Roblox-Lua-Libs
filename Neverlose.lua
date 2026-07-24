local Neverlose = {}
Neverlose.__index = Neverlose

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

-- Получение контейнера GUI
local function GetContainer()
    local success, result = pcall(function() return CoreGui end)
    if success and result then return result end
    return LocalPlayer:WaitForChild("PlayerGui")
end

-- Вспомогательная функция плавных анимаций
local function Tween(obj, time, props, style, dir)
    style = style or Enum.EasingStyle.Quad
    dir = dir or Enum.EasingDirection.Out
    local info = TweenInfo.new(time, style, dir)
    local t = TweenService:Create(obj, info, props)
    t:Play()
    return t
end

-- Функция перемещения окна
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
            Tween(gui, 0.08, {
                Position = UDim2.new(
                    startPos.X.Scale, startPos.X.Offset + delta.X,
                    startPos.Y.Scale, startPos.Y.Offset + delta.Y
                )
            })
        end
    end)
end

function Neverlose:CreateWindow(config)
    config = config or {}
    local windowTitle = config.Title or "Neverlose"
    local windowSubtitle = config.Subtitle or "Counter-Strike 2"
    local configName = config.ConfigName or "Default Config"
    local regionName = config.Region or "Global"
    local enableESPPreview = config.EnableESPPreview ~= false

    local parent = GetContainer()
    if parent:FindFirstChild("NeverloseUI") then
        parent.NeverloseUI:Destroy()
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "NeverloseUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = parent

    -- Главный фрейм
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 760, 0, 530)
    MainFrame.Position = UDim2.new(0.5, -380, 0.5, -265)
    MainFrame.BackgroundColor3 = Color3.fromRGB(11, 13, 19)
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = false
    MainFrame.Parent = ScreenGui

    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 10)
    MainCorner.Parent = MainFrame

    -- Левая панель (Sidebar)
    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Size = UDim2.new(0, 185, 1, 0)
    Sidebar.BackgroundColor3 = Color3.fromRGB(8, 10, 15)
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = MainFrame

    local SideCorner = Instance.new("UICorner")
    SideCorner.CornerRadius = UDim.new(0, 10)
    SideCorner.Parent = Sidebar

    -- Логотип
    local LogoFrame = Instance.new("Frame")
    LogoFrame.Size = UDim2.new(1, 0, 0, 60)
    LogoFrame.BackgroundTransparency = 1
    LogoFrame.Parent = Sidebar

    local LogoBadge = Instance.new("TextLabel")
    LogoBadge.Size = UDim2.new(0, 32, 0, 32)
    LogoBadge.Position = UDim2.new(0, 15, 0, 14)
    LogoBadge.BackgroundColor3 = Color3.fromRGB(0, 130, 255)
    LogoBadge.Text = "NL"
    LogoBadge.TextColor3 = Color3.fromRGB(255, 255, 255)
    LogoBadge.TextSize = 14
    LogoBadge.Font = Enum.Font.GothamBold
    LogoBadge.Parent = LogoFrame

    local LogoCorner = Instance.new("UICorner")
    LogoCorner.CornerRadius = UDim.new(0, 6)
    LogoCorner.Parent = LogoBadge

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(0, 110, 0, 18)
    TitleLabel.Position = UDim2.new(0, 55, 0, 14)
    TitleLabel.Text = windowTitle
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.TextSize = 14
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Parent = LogoFrame

    local SubtitleLabel = Instance.new("TextLabel")
    SubtitleLabel.Size = UDim2.new(0, 110, 0, 14)
    SubtitleLabel.Position = UDim2.new(0, 55, 0, 32)
    SubtitleLabel.Text = windowSubtitle
    SubtitleLabel.TextColor3 = Color3.fromRGB(100, 110, 130)
    SubtitleLabel.TextSize = 10
    SubtitleLabel.Font = Enum.Font.Gotham
    SubtitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    SubtitleLabel.BackgroundTransparency = 1
    SubtitleLabel.Parent = LogoFrame

    -- Контейнер для категорий и вкладок
    local TabButtonContainer = Instance.new("ScrollingFrame")
    TabButtonContainer.Size = UDim2.new(1, 0, 1, -125)
    TabButtonContainer.Position = UDim2.new(0, 0, 0, 60)
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

    -- РЕАЛЬНЫЙ ПРОФИЛЬ ИГРОКА (Внизу слева)
    local ProfileFrame = Instance.new("Frame")
    ProfileFrame.Size = UDim2.new(1, -20, 0, 50)
    ProfileFrame.Position = UDim2.new(0, 10, 1, -60)
    ProfileFrame.BackgroundColor3 = Color3.fromRGB(14, 17, 25)
    ProfileFrame.Parent = Sidebar

    local ProfileCorner = Instance.new("UICorner")
    ProfileCorner.CornerRadius = UDim.new(0, 8)
    ProfileCorner.Parent = ProfileFrame

    local AvatarImage = Instance.new("ImageLabel")
    AvatarImage.Size = UDim2.new(0, 36, 0, 36)
    AvatarImage.Position = UDim2.new(0, 7, 0.5, -18)
    AvatarImage.BackgroundColor3 = Color3.fromRGB(20, 24, 35)
    AvatarImage.BackgroundTransparency = 0
    AvatarImage.Parent = ProfileFrame

    local AvatarCorner = Instance.new("UICorner")
    AvatarCorner.CornerRadius = UDim.new(1, 0)
    AvatarCorner.Parent = AvatarImage

    -- Загрузка реального аватарка
    task.spawn(function()
        if LocalPlayer then
            local content, isReady = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
            if isReady then
                AvatarImage.Image = content
            end
        end
    end)

    local DisplayNameLabel = Instance.new("TextLabel")
    DisplayNameLabel.Size = UDim2.new(1, -55, 0, 16)
    DisplayNameLabel.Position = UDim2.new(0, 48, 0, 8)
    DisplayNameLabel.Text = LocalPlayer and LocalPlayer.DisplayName or "User"
    DisplayNameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    DisplayNameLabel.Font = Enum.Font.GothamBold
    DisplayNameLabel.TextSize = 11
    DisplayNameLabel.TextXAlignment = Enum.TextXAlignment.Left
    DisplayNameLabel.TextTruncate = Enum.TextTruncate.AtEnd
    DisplayNameLabel.BackgroundTransparency = 1
    DisplayNameLabel.Parent = ProfileFrame

    local UsernameLabel = Instance.new("TextLabel")
    UsernameLabel.Size = UDim2.new(1, -55, 0, 14)
    UsernameLabel.Position = UDim2.new(0, 48, 0, 24)
    UsernameLabel.Text = "@" .. (LocalPlayer and LocalPlayer.Name or "username")
    UsernameLabel.TextColor3 = Color3.fromRGB(0, 150, 255)
    UsernameLabel.Font = Enum.Font.Gotham
    UsernameLabel.TextSize = 10
    UsernameLabel.TextXAlignment = Enum.TextXAlignment.Left
    UsernameLabel.TextTruncate = Enum.TextTruncate.AtEnd
    UsernameLabel.BackgroundTransparency = 1
    UsernameLabel.Parent = ProfileFrame

    -- Верхняя панель (Header)
    local Header = Instance.new("Frame")
    Header.Size = UDim2.new(1, -185, 0, 50)
    Header.Position = UDim2.new(0, 185, 0, 0)
    Header.BackgroundTransparency = 1
    Header.Parent = MainFrame

    MakeDraggable(MainFrame, Header)

    -- Элементы шапки (Замок, Выбор Конфига, Сервер, Поиск)
    local ConfigSelector = Instance.new("TextButton")
    ConfigSelector.Size = UDim2.new(0, 150, 0, 28)
    ConfigSelector.Position = UDim2.new(0, 15, 0.5, -14)
    ConfigSelector.BackgroundColor3 = Color3.fromRGB(15, 18, 27)
    ConfigSelector.Text = "  🔒 " .. configName .. "  ⌄"
    ConfigSelector.TextColor3 = Color3.fromRGB(200, 210, 230)
    ConfigSelector.Font = Enum.Font.GothamMedium
    ConfigSelector.TextSize = 11
    ConfigSelector.TextXAlignment = Enum.TextXAlignment.Left
    ConfigSelector.Parent = Header

    local ConfigCorner = Instance.new("UICorner")
    ConfigCorner.CornerRadius = UDim.new(0, 6)
    ConfigCorner.Parent = ConfigSelector

    local RegionSelector = Instance.new("TextButton")
    RegionSelector.Size = UDim2.new(0, 90, 0, 28)
    RegionSelector.Position = UDim2.new(0, 175, 0.5, -14)
    RegionSelector.BackgroundColor3 = Color3.fromRGB(15, 18, 27)
    RegionSelector.Text = "  " .. regionName .. "  ⌄"
    RegionSelector.TextColor3 = Color3.fromRGB(160, 170, 190)
    RegionSelector.Font = Enum.Font.GothamMedium
    RegionSelector.TextSize = 11
    RegionSelector.TextXAlignment = Enum.TextXAlignment.Left
    RegionSelector.Parent = Header

    local RegionCorner = Instance.new("UICorner")
    RegionCorner.CornerRadius = UDim.new(0, 6)
    RegionCorner.Parent = RegionSelector

    local ContentArea = Instance.new("Frame")
    ContentArea.Size = UDim2.new(1, -185, 1, -50)
    ContentArea.Position = UDim2.new(0, 185, 0, 50)
    ContentArea.BackgroundTransparency = 1
    ContentArea.Parent = MainFrame

    -- ESP PREVIEW ПАНЕЛЬ (СПРАВА)
    local ESPPreviewFrame, ViewportCamera, PreviewModel, ESPBoxOutline
    local espBoxColor = Color3.fromRGB(0, 150, 255)

    if enableESPPreview then
        ESPPreviewFrame = Instance.new("Frame")
        ESPPreviewFrame.Name = "ESPPreview"
        ESPPreviewFrame.Size = UDim2.new(0, 220, 1, 0)
        ESPPreviewFrame.Position = UDim2.new(1, 12, 0, 0)
        ESPPreviewFrame.BackgroundColor3 = Color3.fromRGB(11, 13, 19)
        ESPPreviewFrame.Parent = MainFrame

        local ESPCorner = Instance.new("UICorner")
        ESPCorner.CornerRadius = UDim.new(0, 10)
        ESPCorner.Parent = ESPPreviewFrame

        local ESPTitle = Instance.new("TextLabel")
        ESPTitle.Size = UDim2.new(1, -20, 0, 30)
        ESPTitle.Position = UDim2.new(0, 10, 0, 10)
        ESPTitle.Text = "ESP PREVIEW"
        ESPTitle.TextColor3 = Color3.fromRGB(140, 150, 175)
        ESPTitle.Font = Enum.Font.GothamBold
        ESPTitle.TextSize = 11
        ESPTitle.TextXAlignment = Enum.TextXAlignment.Left
        ESPTitle.BackgroundTransparency = 1
        ESPTitle.Parent = ESPPreviewFrame

        local Viewport = Instance.new("ViewportFrame")
        Viewport.Size = UDim2.new(1, -20, 1, -50)
        Viewport.Position = UDim2.new(0, 10, 0, 40)
        Viewport.BackgroundTransparency = 1
        Viewport.Parent = ESPPreviewFrame

        ViewportCamera = Instance.new("Camera")
        ViewportCamera.CFrame = CFrame.new(Vector3.new(0, 2.5, 6.5), Vector3.new(0, 2.5, 0))
        Viewport.CurrentCamera = ViewportCamera

        -- Загрузка аватара персонажа в Viewport
        task.spawn(function()
            if LocalPlayer and LocalPlayer.Character then
                LocalPlayer.Character.Archivable = true
                PreviewModel = LocalPlayer.Character:Clone()
                PreviewModel:SetPrimaryPartCFrame(CFrame.new(0, 0, 0))
                PreviewModel.Parent = Viewport

                -- ESP 2D Box Overlay
                ESPBoxOutline = Instance.new("Frame")
                ESPBoxOutline.Size = UDim2.new(0, 110, 0, 180)
                ESPBoxOutline.Position = UDim2.new(0.5, -55, 0.5, -90)
                ESPBoxOutline.BackgroundTransparency = 1
                ESPBoxOutline.BorderColor3 = espBoxColor
                ESPBoxOutline.BorderSizePixel = 2
                ESPBoxOutline.Parent = Viewport
            end
        end)

        -- Вращение 3D модели мышкой
        local isRotating = false
        local lastMousePos = Vector3.new()
        local currentRotation = 0

        Viewport.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                isRotating = true
                lastMousePos = input.Position
            end
        end)

        UserInputService.InputEnded:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                isRotating = false
            end
        end)

        UserInputService.InputChanged:Connect(function(input)
            if isRotating and input.UserInputType == Enum.UserInputType.MouseMovement then
                local delta = input.Position.X - lastMousePos.X
                lastMousePos = input.Position
                currentRotation = currentRotation + (delta * 0.01)
                if PreviewModel and PreviewModel.PrimaryPart then
                    PreviewModel:SetPrimaryPartCFrame(CFrame.new(0, 0, 0) * CFrame.Angles(0, currentRotation, 0))
                end
            end
        end)
    end

    local WindowObj = {
        Screen = ScreenGui,
        Main = MainFrame,
        Tabs = {},
        Categories = {},
        ContentArea = ContentArea,
        TabButtonContainer = TabButtonContainer
    }

    function WindowObj:UpdateESPColor(color)
        espBoxColor = color
        if ESPBoxOutline then
            ESPBoxOutline.BorderColor3 = color
        end
    end

    function WindowObj:CreateTab(opts)
        opts = opts or {}
        local name = opts.Name or "Tab"
        local category = opts.Category or "GENERAL"
        local icon = opts.Icon or ""

        -- Создание заголовка категории, если ее нет
        if not WindowObj.Categories[category] then
            local CatLabel = Instance.new("TextLabel")
            CatLabel.Size = UDim2.new(1, 0, 0, 22)
            CatLabel.Text = string.upper(category)
            CatLabel.TextColor3 = Color3.fromRGB(80, 90, 110)
            CatLabel.Font = Enum.Font.GothamBold
            CatLabel.TextSize = 9
            CatLabel.TextXAlignment = Enum.TextXAlignment.Left
            CatLabel.BackgroundTransparency = 1
            CatLabel.Parent = TabButtonContainer

            WindowObj.Categories[category] = true
        end

        local TabButton = Instance.new("TextButton")
        TabButton.Size = UDim2.new(1, 0, 0, 32)
        TabButton.BackgroundColor3 = Color3.fromRGB(14, 17, 25)
        TabButton.BackgroundTransparency = 1
        TabButton.Text = "      " .. name
        TabButton.TextColor3 = Color3.fromRGB(120, 130, 150)
        TabButton.Font = Enum.Font.GothamMedium
        TabButton.TextSize = 12
        TabButton.TextXAlignment = Enum.TextXAlignment.Left
        TabButton.Parent = TabButtonContainer

        local TabBtnCorner = Instance.new("UICorner")
        TabBtnCorner.CornerRadius = UDim.new(0, 6)
        TabBtnCorner.Parent = TabButton

        if icon ~= "" then
            local IconImg = Instance.new("ImageLabel")
            IconImg.Size = UDim2.new(0, 16, 0, 16)
            IconImg.Position = UDim2.new(0, 8, 0.5, -8)
            IconImg.BackgroundTransparency = 1
            IconImg.Image = icon
            IconImg.Parent = TabButton
        end

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
        LeftColumn.Parent = TabPage

        local RightColumn = Instance.new("ScrollingFrame")
        RightColumn.Size = UDim2.new(0.5, -12, 1, -10)
        RightColumn.Position = UDim2.new(0.5, 4, 0, 0)
        RightColumn.BackgroundTransparency = 1
        RightColumn.ScrollBarThickness = 0
        RightColumn.Parent = TabPage

        local LeftLayout = Instance.new("UIListLayout")
        LeftLayout.SortOrder = Enum.SortOrder.LayoutOrder
        LeftLayout.Padding = UDim.new(0, 10)
        LeftLayout.Parent = LeftColumn

        local RightLayout = Instance.new("UIListLayout")
        RightLayout.SortOrder = Enum.SortOrder.LayoutOrder
        RightLayout.Padding = UDim.new(0, 10)
        RightLayout.Parent = RightColumn

        local TabObj = {
            Button = TabButton,
            Page = TabPage,
            Left = LeftColumn,
            Right = RightColumn
        }

        TabButton.MouseButton1Click:Connect(function()
            for _, t in pairs(WindowObj.Tabs) do
                Tween(t.Button, 0.15, {BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(120, 130, 150)})
                t.Page.Visible = false
            end
            Tween(TabButton, 0.15, {BackgroundTransparency = 0, TextColor3 = Color3.fromRGB(255, 255, 255)})
            TabPage.Visible = true
        end)

        if #WindowObj.Tabs == 0 then
            TabButton.BackgroundTransparency = 0
            TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            TabPage.Visible = true
        end

        table.insert(WindowObj.Tabs, TabObj)

        function TabObj:CreateSection(sectionTitle, side)
            local parentCol = (side and side:lower() == "right") and RightColumn or LeftColumn

            local SectionFrame = Instance.new("Frame")
            SectionFrame.Size = UDim2.new(1, 0, 0, 30)
            SectionFrame.BackgroundColor3 = Color3.fromRGB(15, 18, 27)
            SectionFrame.Parent = parentCol

            local SecCorner = Instance.new("UICorner")
            SecCorner.CornerRadius = UDim.new(0, 8)
            SecCorner.Parent = SectionFrame

            local Title = Instance.new("TextLabel")
            Title.Size = UDim2.new(1, -20, 0, 25)
            Title.Position = UDim2.new(0, 10, 0, 5)
            Title.Text = string.upper(sectionTitle)
            Title.TextColor3 = Color3.fromRGB(140, 150, 175)
            Title.Font = Enum.Font.GothamBold
            Title.TextSize = 10
            Title.TextXAlignment = Enum.TextXAlignment.Left
            Title.BackgroundTransparency = 1
            Title.Parent = SectionFrame

            local ItemHolder = Instance.new("Frame")
            ItemHolder.Size = UDim2.new(1, -20, 1, -35)
            ItemHolder.Position = UDim2.new(0, 10, 0, 30)
            ItemHolder.BackgroundTransparency = 1
            ItemHolder.Parent = SectionFrame

            local ItemLayout = Instance.new("UIListLayout")
            ItemLayout.SortOrder = Enum.SortOrder.LayoutOrder
            ItemLayout.Padding = UDim.new(0, 8)
            ItemLayout.Parent = ItemHolder

            ItemLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                SectionFrame.Size = UDim2.new(1, 0, 0, ItemLayout.AbsoluteContentSize.Y + 40)
            end)

            local SectionObj = {}

            -- TOGGLE (ПЕРЕКЛЮЧАТЕЛЬ) С ПОДДЕРЖКОЙ ПКМ КИСЛИ (KEYBIND)
            function SectionObj:CreateToggle(opts)
                opts = opts or {}
                local name = opts.Name or "Toggle"
                local state = opts.Default or false
                local callback = opts.Callback or function() end
                local keybind = opts.Keybind or nil
                local bindMode = "Toggle" -- Hold или Toggle

                local ToggleFrame = Instance.new("Frame")
                ToggleFrame.Size = UDim2.new(1, 0, 0, 24)
                ToggleFrame.BackgroundTransparency = 1
                ToggleFrame.Parent = ItemHolder

                local Label = Instance.new("TextButton")
                Label.Size = UDim2.new(1, -45, 1, 0)
                Label.Text = name
                Label.TextColor3 = Color3.fromRGB(220, 225, 235)
                Label.Font = Enum.Font.GothamMedium
                Label.TextSize = 12
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.BackgroundTransparency = 1
                Label.Parent = ToggleFrame

                local SwitchBg = Instance.new("TextButton")
                SwitchBg.Size = UDim2.new(0, 34, 0, 18)
                SwitchBg.Position = UDim2.new(1, -34, 0.5, -9)
                SwitchBg.BackgroundColor3 = state and Color3.fromRGB(0, 140, 255) or Color3.fromRGB(25, 30, 42)
                SwitchBg.Text = ""
                SwitchBg.Parent = ToggleFrame

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

                local function ToggleState(newVal)
                    state = newVal ~= nil and newVal or not state
                    Tween(SwitchBg, 0.15, {BackgroundColor3 = state and Color3.fromRGB(0, 140, 255) or Color3.fromRGB(25, 30, 42)})
                    Tween(Circle, 0.15, {Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)})
                    callback(state)
                end

                SwitchBg.MouseButton1Click:Connect(function() ToggleState() end)
                Label.MouseButton1Click:Connect(function() ToggleState() end)

                -- КОНТЕКСТНОЕ МЕНЮ БИНДОВ (ПКМ по Настройке)
                Label.MouseButton2Click:Connect(function()
                    local ContextMenu = Instance.new("Frame")
                    ContextMenu.Size = UDim2.new(0, 120, 0, 60)
                    ContextMenu.Position = UDim2.new(0, UserInputService:GetMouseLocation().X - MainFrame.AbsolutePosition.X, 0, UserInputService:GetMouseLocation().Y - MainFrame.AbsolutePosition.Y)
                    ContextMenu.BackgroundColor3 = Color3.fromRGB(20, 24, 35)
                    ContextMenu.ZIndex = 100
                    ContextMenu.Parent = MainFrame

                    local ContextCorner = Instance.new("UICorner")
                    ContextCorner.CornerRadius = UDim.new(0, 6)
                    ContextCorner.Parent = ContextMenu

                    local BindModeBtn = Instance.new("TextButton")
                    BindModeBtn.Size = UDim2.new(1, 0, 0, 28)
                    BindModeBtn.Text = "Mode: " .. bindMode
                    BindModeBtn.TextColor3 = Color3.fromRGB(200, 210, 230)
                    BindModeBtn.Font = Enum.Font.Gotham
                    BindModeBtn.TextSize = 11
                    BindModeBtn.ZIndex = 101
                    BindModeBtn.BackgroundTransparency = 1
                    BindModeBtn.Parent = ContextMenu

                    BindModeBtn.MouseButton1Click:Connect(function()
                        bindMode = (bindMode == "Toggle") and "Hold" or "Toggle"
                        BindModeBtn.Text = "Mode: " .. bindMode
                    end)

                    local CloseBtn = Instance.new("TextButton")
                    CloseBtn.Size = UDim2.new(1, 0, 0, 28)
                    CloseBtn.Position = UDim2.new(0, 0, 0, 28)
                    CloseBtn.Text = "Close"
                    CloseBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
                    CloseBtn.Font = Enum.Font.Gotham
                    CloseBtn.TextSize = 11
                    CloseBtn.ZIndex = 101
                    CloseBtn.BackgroundTransparency = 1
                    CloseBtn.Parent = ContextMenu

                    CloseBtn.MouseButton1Click:Connect(function()
                        ContextMenu:Destroy()
                    end)
                end)
            end

            -- СЛАЙДЕР (SLIDER)
            function SectionObj:CreateSlider(opts)
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
                SliderFrame.Parent = ItemHolder

                local Label = Instance.new("TextLabel")
                Label.Size = UDim2.new(0.6, 0, 0, 16)
                Label.Text = name
                Label.TextColor3 = Color3.fromRGB(220, 225, 235)
                Label.Font = Enum.Font.GothamMedium
                Label.TextSize = 12
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.BackgroundTransparency = 1
                Label.Parent = SliderFrame

                local ValLabel = Instance.new("TextLabel")
                ValLabel.Size = UDim2.new(0.4, 0, 0, 16)
                ValLabel.Position = UDim2.new(0.6, 0, 0, 0)
                ValLabel.Text = tostring(val) .. suffix
                ValLabel.TextColor3 = Color3.fromRGB(120, 130, 150)
                ValLabel.Font = Enum.Font.Gotham
                ValLabel.TextSize = 11
                ValLabel.TextXAlignment = Enum.TextXAlignment.Right
                ValLabel.BackgroundTransparency = 1
                ValLabel.Parent = SliderFrame

                local Track = Instance.new("TextButton")
                Track.Size = UDim2.new(1, 0, 0, 5)
                Track.Position = UDim2.new(0, 0, 0, 23)
                Track.BackgroundColor3 = Color3.fromRGB(25, 30, 42)
                Track.Text = ""
                Track.Parent = SliderFrame

                local TrackCorner = Instance.new("UICorner")
                TrackCorner.CornerRadius = UDim.new(1, 0)
                TrackCorner.Parent = Track

                local Fill = Instance.new("Frame")
                Fill.Size = UDim2.new((val - min) / (max - min), 0, 1, 0)
                Fill.BackgroundColor3 = Color3.fromRGB(0, 140, 255)
                Fill.Parent = Track

                local FillCorner = Instance.new("UICorner")
                FillCorner.CornerRadius = UDim.new(1, 0)
                FillCorner.Parent = Fill

                local dragging = false
                local function Update(input)
                    local percent = math.clamp((input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
                    val = math.floor(min + (max - min) * percent)
                    ValLabel.Text = tostring(val) .. suffix
                    Tween(Fill, 0.05, {Size = UDim2.new(percent, 0, 1, 0)})
                    callback(val)
                end

                Track.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = true
                        Update(input)
                    end
                end)

                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        dragging = false
                    end
                end)

                UserInputService.InputChanged:Connect(function(input)
                    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                        Update(input)
                    end
                end)
            end

            -- COLOR PICKER (ВЫБОР ЦВЕТА)
            function SectionObj:CreateColorPicker(opts)
                opts = opts or {}
                local name = opts.Name or "Color"
                local color = opts.Default or Color3.fromRGB(0, 150, 255)
                local callback = opts.Callback or function() end

                local ColorFrame = Instance.new("Frame")
                ColorFrame.Size = UDim2.new(1, 0, 0, 24)
                ColorFrame.BackgroundTransparency = 1
                ColorFrame.Parent = ItemHolder

                local Label = Instance.new("TextLabel")
                Label.Size = UDim2.new(1, -30, 1, 0)
                Label.Text = name
                Label.TextColor3 = Color3.fromRGB(220, 225, 235)
                Label.Font = Enum.Font.GothamMedium
                Label.TextSize = 12
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.BackgroundTransparency = 1
                Label.Parent = ColorFrame

                local ColorBox = Instance.new("TextButton")
                ColorBox.Size = UDim2.new(0, 20, 0, 14)
                ColorBox.Position = UDim2.new(1, -20, 0.5, -7)
                ColorBox.BackgroundColor3 = color
                ColorBox.Text = ""
                ColorBox.Parent = ColorFrame

                local BoxCorner = Instance.new("UICorner")
                BoxCorner.CornerRadius = UDim.new(0, 4)
                BoxCorner.Parent = ColorBox

                ColorBox.MouseButton1Click:Connect(function()
                    -- Переключение цвета по клику (базовый функционал)
                    if color == Color3.fromRGB(0, 150, 255) then
                        color = Color3.fromRGB(255, 50, 50)
                    elseif color == Color3.fromRGB(255, 50, 50) then
                        color = Color3.fromRGB(50, 255, 50)
                    else
                        color = Color3.fromRGB(0, 150, 255)
                    end
                    ColorBox.BackgroundColor3 = color
                    callback(color)
                end)
            end

            -- DROPDOWN (ВЫПАДАЮЩИЙ СПИСОК)
            function SectionObj:CreateDropdown(opts)
                opts = opts or {}
                local name = opts.Name or "Dropdown"
                local options = opts.Options or {}
                local selected = opts.Default or options[1] or "None"
                local callback = opts.Callback or function() end

                local DropFrame = Instance.new("Frame")
                DropFrame.Size = UDim2.new(1, 0, 0, 44)
                DropFrame.BackgroundTransparency = 1
                DropFrame.Parent = ItemHolder

                local Label = Instance.new("TextLabel")
                Label.Size = UDim2.new(1, 0, 0, 16)
                Label.Text = name
                Label.TextColor3 = Color3.fromRGB(220, 225, 235)
                Label.Font = Enum.Font.GothamMedium
                Label.TextSize = 12
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.BackgroundTransparency = 1
                Label.Parent = DropFrame

                local Box = Instance.new("TextButton")
                Box.Size = UDim2.new(1, 0, 0, 24)
                Box.Position = UDim2.new(0, 0, 0, 20)
                Box.BackgroundColor3 = Color3.fromRGB(22, 26, 38)
                Box.Text = "  " .. selected .. "  ⌄"
                Box.TextColor3 = Color3.fromRGB(180, 190, 210)
                Box.Font = Enum.Font.Gotham
                Box.TextSize = 11
                Box.TextXAlignment = Enum.TextXAlignment.Left
                Box.Parent = DropFrame

                local BoxCorner = Instance.new("UICorner")
                BoxCorner.CornerRadius = UDim.new(0, 5)
                BoxCorner.Parent = Box

                local open = false
                local Container = Instance.new("Frame")
                Container.Size = UDim2.new(1, 0, 0, #options * 22)
                Container.Position = UDim2.new(0, 0, 1, 4)
                Container.BackgroundColor3 = Color3.fromRGB(22, 26, 38)
                Container.Visible = false
                Container.ZIndex = 10
                Container.Parent = Box

                local CCorner = Instance.new("UICorner")
                CCorner.CornerRadius = UDim.new(0, 5)
                CCorner.Parent = Container

                local CLayout = Instance.new("UIListLayout")
                CLayout.SortOrder = Enum.SortOrder.LayoutOrder
                CLayout.Parent = Container

                for _, opt in ipairs(options) do
                    local OptBtn = Instance.new("TextButton")
                    OptBtn.Size = UDim2.new(1, 0, 0, 22)
                    OptBtn.BackgroundTransparency = 1
                    OptBtn.Text = "  " .. opt
                    OptBtn.TextColor3 = Color3.fromRGB(160, 170, 190)
                    OptBtn.Font = Enum.Font.Gotham
                    OptBtn.TextSize = 11
                    OptBtn.TextXAlignment = Enum.TextXAlignment.Left
                    OptBtn.ZIndex = 11
                    OptBtn.Parent = Container

                    OptBtn.MouseButton1Click:Connect(function()
                        selected = opt
                        Box.Text = "  " .. selected .. "  ⌄"
                        Container.Visible = false
                        DropFrame.Size = UDim2.new(1, 0, 0, 44)
                        open = false
                        callback(selected)
                    end)
                end

                Box.MouseButton1Click:Connect(function()
                    open = not open
                    Container.Visible = open
                    DropFrame.Size = open and UDim2.new(1, 0, 0, 48 + #options * 22) or UDim2.new(1, 0, 0, 44)
                end)
            end

            return SectionObj
        end

        return TabObj
    end

    return WindowObj
end

return Neverlose
