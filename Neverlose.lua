local Neverlose = {}
Neverlose.__index = Neverlose

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")

-- Определение родительского контейнера UI
local function GetContainer()
    local success, result = pcall(function()
        return CoreGui
    end)
    if success and result then return result end
    return Players.LocalPlayer:WaitForChild("PlayerGui")
end

-- Вспомогательная функция анимаций
local function Tween(object, time, properties)
    local info = TweenInfo.new(time, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
    local tween = TweenService:Create(object, info, properties)
    tween:Play()
    return tween
end

-- Реализация перетаскивания окна
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
            Tween(gui, 0.1, {
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
    local userName = config.User or "User"
    local userDays = config.DaysLeft or "Unlimited"

    -- Удаление предыдущего интерфейса при перезапуске
    local parent = GetContainer()
    if parent:FindFirstChild("NeverloseUI") then
        parent.NeverloseUI:Destroy()
    end

    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "NeverloseUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.Parent = parent

    -- Главный Frame
    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 750, 0, 520)
    MainFrame.Position = UDim2.new(0.5, -375, 0.5, -260)
    MainFrame.BackgroundColor3 = Color3.fromRGB(11, 13, 19)
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = ScreenGui

    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 10)
    MainCorner.Parent = MainFrame

    -- Левая панель (Sidebar)
    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Size = UDim2.new(0, 180, 1, 0)
    Sidebar.BackgroundColor3 = Color3.fromRGB(8, 10, 15)
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = MainFrame

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
    TitleLabel.Size = UDim2.new(0, 100, 0, 18)
    TitleLabel.Position = UDim2.new(0, 55, 0, 14)
    TitleLabel.Text = windowTitle
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.TextSize = 14
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Parent = LogoFrame

    local SubtitleLabel = Instance.new("TextLabel")
    SubtitleLabel.Size = UDim2.new(0, 100, 0, 14)
    SubtitleLabel.Position = UDim2.new(0, 55, 0, 32)
    SubtitleLabel.Text = windowSubtitle
    SubtitleLabel.TextColor3 = Color3.fromRGB(100, 110, 130)
    SubtitleLabel.TextSize = 10
    SubtitleLabel.Font = Enum.Font.Gotham
    SubtitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    SubtitleLabel.BackgroundTransparency = 1
    SubtitleLabel.Parent = LogoFrame

    -- Контейнер для вкладок
    local TabButtonContainer = Instance.new("ScrollingFrame")
    TabButtonContainer.Size = UDim2.new(1, 0, 1, -120)
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

    -- Профиль пользователя (внизу слева)
    local ProfileFrame = Instance.new("Frame")
    ProfileFrame.Size = UDim2.new(1, -20, 0, 45)
    ProfileFrame.Position = UDim2.new(0, 10, 1, -55)
    ProfileFrame.BackgroundColor3 = Color3.fromRGB(14, 17, 25)
    ProfileFrame.Parent = Sidebar

    local ProfileCorner = Instance.new("UICorner")
    ProfileCorner.CornerRadius = UDim.new(0, 6)
    ProfileCorner.Parent = ProfileFrame

    local UserLabel = Instance.new("TextLabel")
    UserLabel.Size = UDim2.new(1, -10, 0, 16)
    UserLabel.Position = UDim2.new(0, 10, 0, 7)
    UserLabel.Text = userName
    UserLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    UserLabel.Font = Enum.Font.GothamBold
    UserLabel.TextSize = 12
    UserLabel.TextXAlignment = Enum.TextXAlignment.Left
    UserLabel.BackgroundTransparency = 1
    UserLabel.Parent = ProfileFrame

    local DaysLabel = Instance.new("TextLabel")
    DaysLabel.Size = UDim2.new(1, -10, 0, 14)
    DaysLabel.Position = UDim2.new(0, 10, 0, 23)
    DaysLabel.Text = userDays
    DaysLabel.TextColor3 = Color3.fromRGB(0, 150, 255)
    DaysLabel.Font = Enum.Font.Gotham
    DaysLabel.TextSize = 10
    DaysLabel.TextXAlignment = Enum.TextXAlignment.Left
    DaysLabel.BackgroundTransparency = 1
    DaysLabel.Parent = ProfileFrame

    -- Шапка и область контента
    local Header = Instance.new("Frame")
    Header.Size = UDim2.new(1, -180, 0, 50)
    Header.Position = UDim2.new(0, 180, 0, 0)
    Header.BackgroundTransparency = 1
    Header.Parent = MainFrame

    MakeDraggable(MainFrame, Header)

    local ContentArea = Instance.new("Frame")
    ContentArea.Size = UDim2.new(1, -180, 1, -50)
    ContentArea.Position = UDim2.new(0, 180, 0, 50)
    ContentArea.BackgroundTransparency = 1
    ContentArea.Parent = MainFrame

    local WindowObj = {
        Screen = ScreenGui,
        Main = MainFrame,
        Tabs = {},
        ActiveTab = nil,
        ContentArea = ContentArea,
        TabButtonContainer = TabButtonContainer
    }

    function WindowObj:CreateTab(name, iconId)
        local TabButton = Instance.new("TextButton")
        TabButton.Size = UDim2.new(1, 0, 0, 36)
        TabButton.BackgroundColor3 = Color3.fromRGB(14, 17, 25)
        TabButton.BackgroundTransparency = 1
        TabButton.Text = "      " .. name
        TabButton.TextColor3 = Color3.fromRGB(120, 130, 150)
        TabButton.Font = Enum.Font.GothamMedium
        TabButton.TextSize = 13
        TabButton.TextXAlignment = Enum.TextXAlignment.Left
        TabButton.Parent = TabButtonContainer

        local TabBtnCorner = Instance.new("UICorner")
        TabBtnCorner.CornerRadius = UDim.new(0, 6)
        TabBtnCorner.Parent = TabButton

        -- Страница содержимого для вкладки
        local TabPage = Instance.new("Frame")
        TabPage.Size = UDim2.new(1, 0, 1, 0)
        TabPage.BackgroundTransparency = 1
        TabPage.Visible = false
        TabPage.Parent = ContentArea

        local LeftColumn = Instance.new("ScrollingFrame")
        LeftColumn.Size = UDim2.new(0.5, -15, 1, -10)
        LeftColumn.Position = UDim2.new(0, 10, 0, 0)
        LeftColumn.BackgroundTransparency = 1
        LeftColumn.ScrollBarThickness = 2
        LeftColumn.ScrollBarImageColor3 = Color3.fromRGB(30, 35, 50)
        LeftColumn.Parent = TabPage

        local RightColumn = Instance.new("ScrollingFrame")
        RightColumn.Size = UDim2.new(0.5, -15, 1, -10)
        RightColumn.Position = UDim2.new(0.5, 5, 0, 0)
        RightColumn.BackgroundTransparency = 1
        RightColumn.ScrollBarThickness = 2
        RightColumn.ScrollBarImageColor3 = Color3.fromRGB(30, 35, 50)
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
                Tween(t.Button, 0.2, {BackgroundTransparency = 1, TextColor3 = Color3.fromRGB(120, 130, 150)})
                t.Page.Visible = false
            end
            Tween(TabButton, 0.2, {BackgroundTransparency = 0, TextColor3 = Color3.fromRGB(255, 255, 255)})
            TabPage.Visible = true
        end)

        -- Авто-активация первой добавленной вкладки
        if #WindowObj.Tabs == 0 then
            TabButton.BackgroundTransparency = 0
            TabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            TabPage.Visible = true
        end

        table.insert(WindowObj.Tabs, TabObj)

        function TabObj:CreateSection(sectionTitle, side)
            local parentCol = (side and side:lower() == "right") and RightColumn or LeftColumn

            local SectionFrame = Instance.new("Frame")
            SectionFrame.Size = UDim2.new(1, -5, 0, 30)
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

            local function AutoResize()
                local contentHeight = ItemLayout.AbsoluteContentSize.Y
                SectionFrame.Size = UDim2.new(1, -5, 0, contentHeight + 40)
            end

            ItemLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(AutoResize)

            local SectionObj = {}

            -- Переключатель (Toggle)
            function SectionObj:CreateToggle(opts)
                opts = opts or {}
                local name = opts.Name or "Toggle"
                local state = opts.Default or false
                local callback = opts.Callback or function() end

                local ToggleFrame = Instance.new("Frame")
                ToggleFrame.Size = UDim2.new(1, 0, 0, 24)
                ToggleFrame.BackgroundTransparency = 1
                ToggleFrame.Parent = ItemHolder

                local Label = Instance.new("TextLabel")
                Label.Size = UDim2.new(1, -45, 1, 0)
                Label.Text = name
                Label.TextColor3 = Color3.fromRGB(220, 225, 235)
                Label.Font = Enum.Font.GothamMedium
                Label.TextSize = 12
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.BackgroundTransparency = 1
                Label.Parent = ToggleFrame

                local SwitchBg = Instance.new("TextButton")
                SwitchBg.Size = UDim2.new(0, 36, 0, 18)
                SwitchBg.Position = UDim2.new(1, -36, 0.5, -9)
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

                SwitchBg.MouseButton1Click:Connect(function()
                    state = not state
                    Tween(SwitchBg, 0.15, {BackgroundColor3 = state and Color3.fromRGB(0, 140, 255) or Color3.fromRGB(25, 30, 42)})
                    Tween(Circle, 0.15, {Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)})
                    callback(state)
                end)
            end

            -- Ползунок (Slider)
            function SectionObj:CreateSlider(opts)
                opts = opts or {}
                local name = opts.Name or "Slider"
                local min = opts.Min or 0
                local max = opts.Max or 100
                local val = opts.Default or min
                local suffix = opts.Suffix or ""
                local callback = opts.Callback or function() end

                local SliderFrame = Instance.new("Frame")
                SliderFrame.Size = UDim2.new(1, 0, 0, 38)
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
                Track.Size = UDim2.new(1, 0, 0, 6)
                Track.Position = UDim2.new(0, 0, 0, 24)
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

            -- Выпадающий список (Dropdown)
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
                Box.Text = "  " .. selected
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
                        Box.Text = "  " .. selected
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

            -- Кнопка (Button)
            function SectionObj:CreateButton(opts)
                opts = opts or {}
                local name = opts.Name or "Button"
                local callback = opts.Callback or function() end

                local Btn = Instance.new("TextButton")
                Btn.Size = UDim2.new(1, 0, 0, 26)
                Btn.BackgroundColor3 = Color3.fromRGB(22, 26, 38)
                Btn.Text = name
                Btn.TextColor3 = Color3.fromRGB(220, 225, 235)
                Btn.Font = Enum.Font.GothamMedium
                Btn.TextSize = 12
                Btn.Parent = ItemHolder

                local BtnCorner = Instance.new("UICorner")
                BtnCorner.CornerRadius = UDim.new(0, 5)
                BtnCorner.Parent = Btn

                Btn.MouseButton1Click:Connect(function()
                    Tween(Btn, 0.08, {BackgroundColor3 = Color3.fromRGB(0, 140, 255)})
                    task.wait(0.08)
                    Tween(Btn, 0.15, {BackgroundColor3 = Color3.fromRGB(22, 26, 38)})
                    callback()
                end)
            end

            return SectionObj
        end

        return TabObj
    end

    return WindowObj
end

return Neverlose
