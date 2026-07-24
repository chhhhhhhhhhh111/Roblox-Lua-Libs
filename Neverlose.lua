local Neverlose = {}
Neverlose.__index = Neverlose

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local ScriptStartTime = tick()

local URL_MOVE_ICON = "https://img.icons8.com/ios-glyphs/60/move.png"

local function GetAsset(url, filename, fallback)
    if getcustomasset and writefile and isfile then
        filename = "nl_cache_" .. filename
        if not isfile(filename) then
            pcall(function()
                writefile(filename, game:HttpGet(url))
            end)
        end
        if isfile(filename) then
            return getcustomasset(filename)
        end
    end
    return fallback
end

local AssetMove = GetAsset(URL_MOVE_ICON, "move.png", "rbxassetid://6031094678")

local ActiveContextMenu = nil
local function CloseContextMenu()
    if ActiveContextMenu then
        ActiveContextMenu:Destroy()
        ActiveContextMenu = nil
    end
end

UserInputService.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        CloseContextMenu()
    end
end)

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

    -- Плавающая кнопка для мобильных
    local MobileToggleButton = Instance.new("TextButton")
    MobileToggleButton.Name = "MobileToggleButton"
    MobileToggleButton.Size = UDim2.new(0, 44, 0, 44)
    MobileToggleButton.Position = UDim2.new(0, 15, 0.5, -22)
    MobileToggleButton.BackgroundColor3 = Color3.fromRGB(12, 14, 20)
    MobileToggleButton.Text = "NL"
    MobileToggleButton.TextColor3 = Color3.fromRGB(0, 180, 255)
    MobileToggleButton.Font = Enum.Font.GothamBold
    MobileToggleButton.TextSize = 16
    MobileToggleButton.ZIndex = 999
    MobileToggleButton.Parent = ScreenGui

    local MobileBtnCorner = Instance.new("UICorner")
    MobileBtnCorner.CornerRadius = UDim.new(1, 0)
    MobileBtnCorner.Parent = MobileToggleButton

    local MobileBtnStroke = Instance.new("UIStroke")
    MobileBtnStroke.Color = Color3.fromRGB(0, 180, 255)
    MobileBtnStroke.Thickness = 1.5
    MobileBtnStroke.Parent = MobileToggleButton

    MakeDraggable(MobileToggleButton, MobileToggleButton)

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 750, 0, 520)
    MainFrame.Position = UDim2.new(0.5, -375, 0.5, -260)
    MainFrame.BackgroundColor3 = Color3.fromRGB(12, 14, 20)
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = false
    MainFrame.Parent = ScreenGui

    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 10)
    MainCorner.Parent = MainFrame

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
    Sidebar.Size = UDim2.new(0, 185, 1, 0)
    Sidebar.BackgroundColor3 = Color3.fromRGB(8, 9, 14)
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = MainFrame

    local SideCorner = Instance.new("UICorner")
    SideCorner.CornerRadius = UDim.new(0, 10)
    SideCorner.Parent = Sidebar

    local LogoFrame = Instance.new("Frame")
    LogoFrame.Size = UDim2.new(1, 0, 0, 65)
    LogoFrame.BackgroundTransparency = 1
    LogoFrame.Parent = Sidebar

    local LogoBadge = Instance.new("Frame")
    LogoBadge.Size = UDim2.new(0, 40, 0, 40)
    LogoBadge.Position = UDim2.new(0, 12, 0, 12)
    LogoBadge.BackgroundColor3 = Color3.fromRGB(12, 16, 24)
    LogoBadge.Parent = LogoFrame

    local LogoCorner = Instance.new("UICorner")
    LogoCorner.CornerRadius = UDim.new(0, 8)
    LogoCorner.Parent = LogoBadge

    local LogoShadow = Instance.new("TextLabel")
    LogoShadow.Size = UDim2.new(1, 0, 1, 0)
    LogoShadow.Position = UDim2.new(0, 2, 0, 2)
    LogoShadow.Text = "NL"
    LogoShadow.TextColor3 = Color3.fromRGB(0, 160, 255)
    LogoShadow.TextSize = 20
    LogoShadow.Font = Enum.Font.GothamBlack
    LogoShadow.BackgroundTransparency = 1
    LogoShadow.Parent = LogoBadge

    local LogoText = Instance.new("TextLabel")
    LogoText.Size = UDim2.new(1, 0, 1, 0)
    LogoText.Text = "NL"
    LogoText.TextColor3 = Color3.fromRGB(255, 255, 255)
    LogoText.TextSize = 20
    LogoText.Font = Enum.Font.GothamBlack
    LogoText.BackgroundTransparency = 1
    LogoText.Parent = LogoBadge

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Size = UDim2.new(0, 110, 0, 18)
    TitleLabel.Position = UDim2.new(0, 60, 0, 15)
    TitleLabel.Text = windowTitle
    TitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TitleLabel.TextSize = 14
    TitleLabel.Font = Enum.Font.GothamBold
    TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Parent = LogoFrame

    local SubtitleLabel = Instance.new("TextLabel")
    SubtitleLabel.Size = UDim2.new(0, 110, 0, 14)
    SubtitleLabel.Position = UDim2.new(0, 60, 0, 33)
    SubtitleLabel.Text = windowSubtitle
    SubtitleLabel.TextColor3 = Color3.fromRGB(110, 120, 140)
    SubtitleLabel.TextSize = 10
    SubtitleLabel.Font = Enum.Font.Gotham
    SubtitleLabel.TextXAlignment = Enum.TextXAlignment.Left
    SubtitleLabel.BackgroundTransparency = 1
    SubtitleLabel.Parent = LogoFrame

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

    -- Мини-профиль
    local ProfileFrame = Instance.new("TextButton")
    ProfileFrame.Size = UDim2.new(1, -20, 0, 50)
    ProfileFrame.Position = UDim2.new(0, 10, 1, -60)
    ProfileFrame.BackgroundColor3 = Color3.fromRGB(14, 16, 24)
    ProfileFrame.Text = ""
    ProfileFrame.Parent = Sidebar

    local ProfileCorner = Instance.new("UICorner")
    ProfileCorner.CornerRadius = UDim.new(0, 8)
    ProfileCorner.Parent = ProfileFrame

    local AvatarImage = Instance.new("ImageLabel")
    AvatarImage.Size = UDim2.new(0, 34, 0, 34)
    AvatarImage.Position = UDim2.new(0, 8, 0.5, -17)
    AvatarImage.BackgroundColor3 = Color3.fromRGB(20, 24, 35)
    AvatarImage.BackgroundTransparency = 0
    AvatarImage.Parent = ProfileFrame

    local AvatarCorner = Instance.new("UICorner")
    AvatarCorner.CornerRadius = UDim.new(1, 0)
    AvatarCorner.Parent = AvatarImage

    task.spawn(function()
        if LocalPlayer then
            local content, isReady = Players:GetUserThumbnailAsync(LocalPlayer.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size150x150)
            if isReady then
                AvatarImage.Image = content
            end
        end
    end)

    local DisplayNameLabel = Instance.new("TextLabel")
    DisplayNameLabel.Size = UDim2.new(1, -52, 0, 16)
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
    UsernameLabel.Size = UDim2.new(1, -52, 0, 14)
    UsernameLabel.Position = UDim2.new(0, 48, 0, 24)
    UsernameLabel.Text = "@" .. (LocalPlayer and LocalPlayer.Name or "username")
    UsernameLabel.TextColor3 = Color3.fromRGB(0, 180, 255)
    UsernameLabel.Font = Enum.Font.Gotham
    UsernameLabel.TextSize = 10
    UsernameLabel.TextXAlignment = Enum.TextXAlignment.Left
    UsernameLabel.TextTruncate = Enum.TextTruncate.AtEnd
    UsernameLabel.BackgroundTransparency = 1
    UsernameLabel.Parent = ProfileFrame

    -- Окно Информации об Аккаунте
    local SessionModal = Instance.new("Frame")
    SessionModal.Size = UDim2.new(0, 280, 0, 220)
    SessionModal.Position = UDim2.new(0.5, -140, 0.5, -110)
    SessionModal.BackgroundColor3 = Color3.fromRGB(14, 16, 24)
    SessionModal.ZIndex = 500
    SessionModal.Visible = false
    SessionModal.Parent = MainFrame

    local ModalCorner = Instance.new("UICorner")
    ModalCorner.CornerRadius = UDim.new(0, 10)
    ModalCorner.Parent = SessionModal

    local ModalStroke = Instance.new("UIStroke")
    ModalStroke.Color = Color3.fromRGB(0, 180, 255)
    ModalStroke.Thickness = 1
    ModalStroke.Parent = SessionModal

    local ModalTitle = Instance.new("TextLabel")
    ModalTitle.Size = UDim2.new(1, -20, 0, 30)
    ModalTitle.Position = UDim2.new(0, 15, 0, 10)
    ModalTitle.Text = "ACCOUNT & SESSION INFO"
    ModalTitle.TextColor3 = Color3.fromRGB(0, 180, 255)
    ModalTitle.Font = Enum.Font.GothamBold
    ModalTitle.TextSize = 12
    ModalTitle.TextXAlignment = Enum.TextXAlignment.Left
    ModalTitle.ZIndex = 501
    ModalTitle.BackgroundTransparency = 1
    ModalTitle.Parent = SessionModal

    local ModalInfoText = Instance.new("TextLabel")
    ModalInfoText.Size = UDim2.new(1, -30, 1, -50)
    ModalInfoText.Position = UDim2.new(0, 15, 0, 40)
    ModalInfoText.TextColor3 = Color3.fromRGB(220, 225, 235)
    ModalInfoText.Font = Enum.Font.GothamMedium
    ModalInfoText.TextSize = 11
    ModalInfoText.TextXAlignment = Enum.TextXAlignment.Left
    ModalInfoText.TextYAlignment = Enum.TextYAlignment.Top
    ModalInfoText.ZIndex = 501
    ModalInfoText.BackgroundTransparency = 1
    ModalInfoText.Parent = SessionModal

    local CloseModalBtn = Instance.new("TextButton")
    CloseModalBtn.Size = UDim2.new(0, 24, 0, 24)
    CloseModalBtn.Position = UDim2.new(1, -30, 0, 10)
    CloseModalBtn.Text = "X"
    CloseModalBtn.TextColor3 = Color3.fromRGB(255, 80, 80)
    CloseModalBtn.Font = Enum.Font.GothamBold
    CloseModalBtn.TextSize = 12
    CloseModalBtn.ZIndex = 502
    CloseModalBtn.BackgroundTransparency = 1
    CloseModalBtn.Parent = SessionModal

    CloseModalBtn.MouseButton1Click:Connect(function()
        SessionModal.Visible = false
    end)

    RunService.RenderStepped:Connect(function()
        if SessionModal.Visible and LocalPlayer then
            local sessionTime = math.floor(tick() - ScriptStartTime)
            local mins = math.floor(sessionTime / 60)
            local secs = sessionTime % 60
            local fps = math.floor(workspace:GetRealPhysicsFPS())

            ModalInfoText.Text = string.format(
                "Display Name: %s\n" ..
                "Username: @%s\n" ..
                "User ID: %d\n" ..
                "Account Age: %d days\n\n" ..
                "Place ID: %d\n" ..
                "Session Time: %02dm %02ds\n" ..
                "Performance: %d FPS",
                LocalPlayer.DisplayName,
                LocalPlayer.Name,
                LocalPlayer.UserId,
                LocalPlayer.AccountAge,
                game.PlaceId,
                mins, secs,
                fps
            )
        end
    end)

    ProfileFrame.MouseButton1Click:Connect(function()
        SessionModal.Visible = not SessionModal.Visible
    end)

    -- Header
    local Header = Instance.new("Frame")
    Header.Size = UDim2.new(1, -185, 0, 45)
    Header.Position = UDim2.new(0, 185, 0, 0)
    Header.BackgroundTransparency = 1
    Header.Parent = MainFrame

    MakeDraggable(MainFrame, Header)

    local MoveDragIcon = Instance.new("ImageButton")
    MoveDragIcon.Size = UDim2.new(0, 22, 0, 22)
    MoveDragIcon.Position = UDim2.new(0, 10, 0.5, -11)
    MoveDragIcon.BackgroundTransparency = 1
    MoveDragIcon.Image = AssetMove
    MoveDragIcon.ImageColor3 = Color3.fromRGB(0, 180, 255)
    MoveDragIcon.Parent = Header

    MakeDraggable(MainFrame, MoveDragIcon)

    local SearchBox = Instance.new("TextBox")
    SearchBox.Size = UDim2.new(0, 200, 0, 26)
    SearchBox.Position = UDim2.new(1, -215, 0.5, -13)
    SearchBox.BackgroundColor3 = Color3.fromRGB(16, 19, 28)
    SearchBox.PlaceholderText = "Search functions..."
    SearchBox.PlaceholderColor3 = Color3.fromRGB(100, 110, 130)
    SearchBox.Text = ""
    SearchBox.TextColor3 = Color3.fromRGB(220, 225, 235)
    SearchBox.Font = Enum.Font.GothamMedium
    SearchBox.TextSize = 11
    SearchBox.Parent = Header

    local SearchCorner = Instance.new("UICorner")
    SearchCorner.CornerRadius = UDim.new(0, 6)
    SearchCorner.Parent = SearchBox

    local ContentArea = Instance.new("Frame")
    ContentArea.Size = UDim2.new(1, -185, 1, -45)
    ContentArea.Position = UDim2.new(0, 185, 0, 45)
    ContentArea.BackgroundTransparency = 1
    ContentArea.Parent = MainFrame

    -- ESP PREVIEW ЖИВОЙ АНИМИРОВАННЫЙ ПЕРСОНАЖ
    local ESPPreviewFrame, ViewportCamera, PreviewModel, ESPBoxOutline, WorldModel
    local espBoxColor = Color3.fromRGB(0, 180, 255)

    ESPPreviewFrame = Instance.new("Frame")
    ESPPreviewFrame.Name = "ESPPreview"
    ESPPreviewFrame.Size = UDim2.new(0, 210, 1, 0)
    ESPPreviewFrame.Position = UDim2.new(1, 12, 0, 0)
    ESPPreviewFrame.BackgroundColor3 = Color3.fromRGB(12, 14, 20)
    ESPPreviewFrame.Visible = false
    ESPPreviewFrame.Parent = MainFrame

    local ESPCorner = Instance.new("UICorner")
    ESPCorner.CornerRadius = UDim.new(0, 10)
    ESPCorner.Parent = ESPPreviewFrame

    local ESPTitle = Instance.new("TextLabel")
    ESPTitle.Size = UDim2.new(1, -20, 0, 30)
    ESPTitle.Position = UDim2.new(0, 15, 0, 10)
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
    ViewportCamera.CFrame = CFrame.new(Vector3.new(0, 0, 5.5), Vector3.new(0, 0, 0))
    Viewport.CurrentCamera = ViewportCamera

    WorldModel = Instance.new("WorldModel")
    WorldModel.Parent = Viewport

    local isRotating = false
    local lastMousePos = Vector3.new()
    local currentRotation = 0

    -- ИНИЦИАЛИЗАЦИЯ И СИНХРОНИЗАЦИЯ ДВИЖЕНИЙ В РЕАЛЬНОМ ВРЕМЕНИ
    local partMap = {}

    local function SetupLivePreview()
        local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
        if not char then return end

        char.Archivable = true
        if PreviewModel then PreviewModel:Destroy() end
        partMap = {}

        PreviewModel = char:Clone()

        for _, item in ipairs(PreviewModel:GetDescendants()) do
            if item:IsA("Script") or item:IsA("LocalScript") or item:IsA("Animator") or item:IsA("Humanoid") then
                item:Destroy()
            end
            if item:IsA("BasePart") then
                item.Anchored = true
                item.CanCollide = false
                if item.Name ~= "HumanoidRootPart" then
                    item.Transparency = 0
                    item.LocalTransparencyModifier = 0
                else
                    item.Transparency = 1
                end

                local origPart = char:FindFirstChild(item.Name, true)
                if origPart then
                    partMap[item] = origPart
                end
            end
        end

        PreviewModel.Parent = WorldModel

        if not ESPBoxOutline then
            ESPBoxOutline = Instance.new("Frame")
            ESPBoxOutline.Size = UDim2.new(0, 110, 0, 175)
            ESPBoxOutline.Position = UDim2.new(0.5, -55, 0.5, -87)
            ESPBoxOutline.BackgroundTransparency = 1
            ESPBoxOutline.BorderColor3 = espBoxColor
            ESPBoxOutline.BorderSizePixel = 2
            ESPBoxOutline.Parent = Viewport
        end
    end

    task.spawn(SetupLivePreview)

    LocalPlayer.CharacterAdded:Connect(function()
        task.wait(1)
        SetupLivePreview()
    end)

    -- ПОКАДРОВАЯ СИНХРОНИЗАЦИЯ АНИМАЦИЙ ЖИВОГО ИГРОКА
    RunService.RenderStepped:Connect(function()
        if ESPPreviewFrame.Visible and MainFrame.Visible and LocalPlayer.Character then
            local realRoot = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if realRoot then
                local rootCF = realRoot.CFrame
                local rotCF = CFrame.Angles(0, currentRotation, 0)

                for clonePart, realPart in pairs(partMap) do
                    if clonePart and realPart and clonePart.Parent and realPart.Parent then
                        local relCF = rootCF:ToObjectSpace(realPart.CFrame)
                        clonePart.CFrame = rotCF * relCF
                    end
                end
            end
        end
    end)

    Viewport.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isRotating = true
            lastMousePos = input.Position
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            isRotating = false
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if isRotating and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position.X - lastMousePos.X
            lastMousePos = input.Position
            currentRotation = currentRotation + (delta * 0.01)
        end
    end)

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
        local icon = opts.Icon or "rbxassetid://6031280882"
        local showPreview = opts.ShowPreview or false

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

        local TabButton = Instance.new("Frame")
        TabButton.Size = UDim2.new(1, 0, 0, 32)
        TabButton.BackgroundColor3 = Color3.fromRGB(16, 19, 28)
        TabButton.BackgroundTransparency = 1
        TabButton.Parent = TabButtonContainer

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
        IconImg.Image = icon
        IconImg.ImageColor3 = Color3.fromRGB(0, 180, 255)
        IconImg.Parent = TabButton

        local TabTitleLabel = Instance.new("TextLabel")
        TabTitleLabel.Size = UDim2.new(1, -36, 1, 0)
        TabTitleLabel.Position = UDim2.new(0, 34, 0, 0)
        TabTitleLabel.Text = name
        TabTitleLabel.TextColor3 = Color3.fromRGB(120, 130, 150)
        TabTitleLabel.Font = Enum.Font.GothamMedium
        TabTitleLabel.TextSize = 12
        TabTitleLabel.TextXAlignment = Enum.TextXAlignment.Left
        TabTitleLabel.BackgroundTransparency = 1
        TabTitleLabel.Parent = TabButton

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

        local TabObj = {
            Button = TabButton,
            Page = TabPage,
            ShowPreview = showPreview
        }

        TabClickBtn.MouseButton1Click:Connect(function()
            for _, t in pairs(WindowObj.Tabs) do
                Tween(t.Button, 0.15, {BackgroundTransparency = 1})
                t.Page.Visible = false
            end
            Tween(TabButton, 0.15, {BackgroundTransparency = 0})
            Tween(TabTitleLabel, 0.15, {TextColor3 = Color3.fromRGB(255, 255, 255)})
            TabPage.Visible = true
            ESPPreviewFrame.Visible = showPreview
        end)

        if #WindowObj.Tabs == 0 then
            TabButton.BackgroundTransparency = 0
            TabTitleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
            TabPage.Visible = true
            ESPPreviewFrame.Visible = showPreview
        end

        table.insert(WindowObj.Tabs, TabObj)

        function TabObj:CreateSection(sectionTitle, side)
            local parentCol = (side and side:lower() == "right") and RightColumn or LeftColumn

            local SectionFrame = Instance.new("Frame")
            SectionFrame.Size = UDim2.new(1, 0, 0, 0)
            SectionFrame.AutomaticSize = Enum.AutomaticSize.Y
            SectionFrame.BackgroundColor3 = Color3.fromRGB(16, 19, 28)
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

            local SectionObj = {}

            -- TOGGLE
            function SectionObj:CreateToggle(opts)
                opts = opts or {}
                local name = opts.Name or "Toggle"
                local state = opts.Default or false
                local callback = opts.Callback or function() end

                local bindKey = nil
                local bindMode = "Toggle"

                local ToggleFrame = Instance.new("Frame")
                ToggleFrame.Size = UDim2.new(1, 0, 0, 24)
                ToggleFrame.BackgroundTransparency = 1
                ToggleFrame.Parent = ItemHolder

                table.insert(WindowObj.AllElements, { Name = name, Frame = ToggleFrame })

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
                SwitchBg.BackgroundColor3 = state and Color3.fromRGB(0, 180, 255) or Color3.fromRGB(25, 30, 42)
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

                local function SetToggleState(newState)
                    state = newState
                    Tween(SwitchBg, 0.15, {BackgroundColor3 = state and Color3.fromRGB(0, 180, 255) or Color3.fromRGB(25, 30, 42)})
                    Tween(Circle, 0.15, {Position = state and UDim2.new(1, -16, 0.5, -7) or UDim2.new(0, 2, 0.5, -7)})
                    callback(state)
                end

                SwitchBg.MouseButton1Click:Connect(function() SetToggleState(not state) end)
                Label.MouseButton1Click:Connect(function() SetToggleState(not state) end)

                local function OpenBindMenu()
                    CloseContextMenu()

                    local mouse = UserInputService:GetMouseLocation()
                    local ContextMenu = Instance.new("Frame")
                    ContextMenu.Name = "BindContextMenu"
                    ContextMenu.Size = UDim2.new(0, 130, 0, 65)
                    ContextMenu.Position = UDim2.new(0, mouse.X - MainFrame.AbsolutePosition.X, 0, mouse.Y - MainFrame.AbsolutePosition.Y)
                    ContextMenu.BackgroundColor3 = Color3.fromRGB(20, 24, 35)
                    ContextMenu.ZIndex = 150
                    ContextMenu.Parent = MainFrame

                    ActiveContextMenu = ContextMenu

                    local ContextCorner = Instance.new("UICorner")
                    ContextCorner.CornerRadius = UDim.new(0, 6)
                    ContextCorner.Parent = ContextMenu

                    local ModeBtn = Instance.new("TextButton")
                    ModeBtn.Size = UDim2.new(1, 0, 0, 32)
                    ModeBtn.Text = "Mode: " .. bindMode
                    ModeBtn.TextColor3 = Color3.fromRGB(220, 225, 235)
                    ModeBtn.Font = Enum.Font.GothamMedium
                    ModeBtn.TextSize = 11
                    ModeBtn.ZIndex = 151
                    ModeBtn.BackgroundTransparency = 1
                    ModeBtn.Parent = ContextMenu

                    ModeBtn.MouseButton1Click:Connect(function()
                        bindMode = (bindMode == "Toggle") and "Hold" or "Toggle"
                        ModeBtn.Text = "Mode: " .. bindMode
                    end)

                    local BindBtn = Instance.new("TextButton")
                    BindBtn.Size = UDim2.new(1, 0, 0, 32)
                    BindBtn.Position = UDim2.new(0, 0, 0, 32)
                    BindBtn.Text = "Key: " .. (bindKey and bindKey.Name or "None")
                    BindBtn.TextColor3 = Color3.fromRGB(0, 180, 255)
                    BindBtn.Font = Enum.Font.GothamMedium
                    BindBtn.TextSize = 11
                    BindBtn.ZIndex = 151
                    BindBtn.BackgroundTransparency = 1
                    BindBtn.Parent = ContextMenu

                    local listening = false
                    BindBtn.MouseButton1Click:Connect(function()
                        listening = true
                        BindBtn.Text = "Key: [...]"
                    end)

                    local bindConn
                    bindConn = UserInputService.InputBegan:Connect(function(input)
                        if listening and input.UserInputType == Enum.UserInputType.Keyboard then
                            bindKey = input.KeyCode
                            BindBtn.Text = "Key: " .. bindKey.Name
                            listening = false
                            bindConn:Disconnect()
                            task.wait(0.2)
                            CloseContextMenu()
                        end
                    end)
                end

                Label.MouseButton2Click:Connect(OpenBindMenu)
                SwitchBg.MouseButton2Click:Connect(OpenBindMenu)

                UserInputService.InputBegan:Connect(function(input)
                    if bindKey and input.KeyCode == bindKey then
                        if bindMode == "Toggle" then
                            SetToggleState(not state)
                        elseif bindMode == "Hold" then
                            SetToggleState(true)
                        end
                    end
                end)

                UserInputService.InputEnded:Connect(function(input)
                    if bindKey and input.KeyCode == bindKey and bindMode == "Hold" then
                        SetToggleState(false)
                    end
                end)
            end

            -- SLIDER
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

                table.insert(WindowObj.AllElements, { Name = name, Frame = SliderFrame })

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
                Fill.BackgroundColor3 = Color3.fromRGB(0, 180, 255)
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
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        dragging = true
                        Update(input)
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

            -- COLOR PICKER
            function SectionObj:CreateColorPicker(opts)
                opts = opts or {}
                local name = opts.Name or "Color"
                local currentColor = opts.Default or Color3.fromRGB(0, 180, 255)
                local callback = opts.Callback or function() end

                local h, s, v = Color3.toHSV(currentColor)

                local ColorFrame = Instance.new("Frame")
                ColorFrame.Size = UDim2.new(1, 0, 0, 24)
                ColorFrame.BackgroundTransparency = 1
                ColorFrame.Parent = ItemHolder

                table.insert(WindowObj.AllElements, { Name = name, Frame = ColorFrame })

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
                PickerWindow.BackgroundColor3 = Color3.fromRGB(20, 24, 35)
                PickerWindow.ZIndex = 200
                PickerWindow.Visible = false
                PickerWindow.Parent = MainFrame

                local PCorner = Instance.new("UICorner")
                PCorner.CornerRadius = UDim.new(0, 8)
                PCorner.Parent = PickerWindow

                local SVBox = Instance.new("TextButton")
                SVBox.Size = UDim2.new(0, 130, 0, 130)
                SVBox.Position = UDim2.new(0, 10, 0, 15)
                SVBox.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
                SVBox.Text = ""
                SVBox.ZIndex = 201
                SVBox.Parent = PickerWindow

                local SVCorner = Instance.new("UICorner")
                SVCorner.CornerRadius = UDim.new(0, 6)
                SVCorner.Parent = SVBox

                local WhiteGrad = Instance.new("Frame")
                WhiteGrad.Size = UDim2.new(1, 0, 1, 0)
                WhiteGrad.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                WhiteGrad.ZIndex = 202
                WhiteGrad.Parent = SVBox

                local WGrad = Instance.new("UIGradient")
                WGrad.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1)})
                WGrad.Rotation = 0
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
                SVCursor.Size = UDim2.new(0, 12, 0, 12)
                SVCursor.Position = UDim2.new(s, -6, 1 - v, -6)
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

                local HueCorner = Instance.new("UICorner")
                HueCorner.CornerRadius = UDim.new(1, 0)
                HueCorner.Parent = HueSlider

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

                local HueCursor = Instance.new("Frame")
                HueCursor.Size = UDim2.new(0, 14, 0, 14)
                HueCursor.Position = UDim2.new(0.5, -7, h, -7)
                HueCursor.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                HueCursor.ZIndex = 205
                HueCursor.Parent = HueSlider

                local HueCursorCorner = Instance.new("UICorner")
                HueCursorCorner.CornerRadius = UDim.new(1, 0)
                HueCursorCorner.Parent = HueCursor

                local draggingSV = false
                local draggingHue = false

                local function UpdateColor()
                    currentColor = Color3.fromHSV(h, s, v)
                    SVBox.BackgroundColor3 = Color3.fromHSV(h, 1, 1)
                    ColorBox.BackgroundColor3 = currentColor
                    callback(currentColor)
                end

                local function UpdateSV(input)
                    s = math.clamp((input.Position.X - SVBox.AbsolutePosition.X) / SVBox.AbsoluteSize.X, 0, 1)
                    v = 1 - math.clamp((input.Position.Y - SVBox.AbsolutePosition.Y) / SVBox.AbsoluteSize.Y, 0, 1)
                    SVCursor.Position = UDim2.new(s, -6, 1 - v, -6)
                    UpdateColor()
                end

                local function UpdateHue(input)
                    h = math.clamp((input.Position.Y - HueSlider.AbsolutePosition.Y) / HueSlider.AbsoluteSize.Y, 0, 1)
                    HueCursor.Position = UDim2.new(0.5, -7, h, -7)
                    UpdateColor()
                end

                SVBox.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        draggingSV = true
                        UpdateSV(input)
                    end
                end)

                HueSlider.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        draggingHue = true
                        UpdateHue(input)
                    end
                end)

                UserInputService.InputEnded:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                        draggingSV = false
                        draggingHue = false
                    end
                end)

                UserInputService.InputChanged:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                        if draggingSV then UpdateSV(input) end
                        if draggingHue then UpdateHue(input) end
                    end
                end)

                ColorBox.MouseButton1Click:Connect(function()
                    if not PickerWindow.Visible then
                        CloseContextMenu()
                        local mouse = UserInputService:GetMouseLocation()
                        PickerWindow.Position = UDim2.new(0, mouse.X - MainFrame.AbsolutePosition.X - 180, 0, mouse.Y - MainFrame.AbsolutePosition.Y)
                        PickerWindow.Visible = true
                    else
                        PickerWindow.Visible = false
                    end
                end)
            end

            -- DROPDOWN
            function SectionObj:CreateDropdown(opts)
                opts = opts or {}
                local name = opts.Name or "Dropdown"
                local options = opts.Options or {}
                local selected = opts.Default or options[1] or "None"
                local callback = opts.Callback or function() end

                local DropFrame = Instance.new("Frame")
                DropFrame.Size = UDim2.new(1, 0, 0, 44)
                DropFrame.BackgroundTransparency = 1
                DropFrame.ZIndex = 5
                DropFrame.Parent = ItemHolder

                table.insert(WindowObj.AllElements, { Name = name, Frame = DropFrame })

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
                Box.ZIndex = 6
                Box.Parent = DropFrame

                local BoxCorner = Instance.new("UICorner")
                BoxCorner.CornerRadius = UDim.new(0, 5)
                BoxCorner.Parent = Box

                local ArrowIcon = Instance.new("ImageLabel")
                ArrowIcon.Size = UDim2.new(0, 14, 0, 14)
                ArrowIcon.Position = UDim2.new(1, -20, 0.5, -7)
                ArrowIcon.BackgroundTransparency = 1
                ArrowIcon.Image = "rbxassetid://6031091004"
                ArrowIcon.ImageColor3 = Color3.fromRGB(0, 180, 255)
                ArrowIcon.ZIndex = 7
                ArrowIcon.Parent = Box

                local open = false
                local Container = Instance.new("Frame")
                Container.Size = UDim2.new(1, 0, 0, #options * 22)
                Container.Position = UDim2.new(0, 0, 1, 4)
                Container.BackgroundColor3 = Color3.fromRGB(22, 26, 38)
                Container.Visible = false
                Container.ZIndex = 20
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
                    OptBtn.ZIndex = 21
                    OptBtn.Parent = Container

                    OptBtn.MouseButton1Click:Connect(function()
                        selected = opt
                        Box.Text = "  " .. selected
                        Container.Visible = false
                        DropFrame.ZIndex = 5
                        open = false
                        Tween(ArrowIcon, 0.2, {Rotation = 0})
                        callback(selected)
                    end)
                end

                Box.MouseButton1Click:Connect(function()
                    open = not open
                    Container.Visible = open
                    DropFrame.ZIndex = open and 50 or 5
                    Tween(ArrowIcon, 0.2, {Rotation = open and 180 or 0})
                end)
            end

            -- KEYBIND BUTTON
            function SectionObj:CreateKeybind(opts)
                opts = opts or {}
                local name = opts.Name or "Keybind"
                local currentKey = opts.Default or Enum.KeyCode.E
                local callback = opts.Callback or function() end

                local BindFrame = Instance.new("Frame")
                BindFrame.Size = UDim2.new(1, 0, 0, 24)
                BindFrame.BackgroundTransparency = 1
                BindFrame.Parent = ItemHolder

                table.insert(WindowObj.AllElements, { Name = name, Frame = BindFrame })

                local Label = Instance.new("TextLabel")
                Label.Size = UDim2.new(1, -65, 1, 0)
                Label.Text = name
                Label.TextColor3 = Color3.fromRGB(220, 225, 235)
                Label.Font = Enum.Font.GothamMedium
                Label.TextSize = 12
                Label.TextXAlignment = Enum.TextXAlignment.Left
                Label.BackgroundTransparency = 1
                Label.Parent = BindFrame

                local BindBtn = Instance.new("TextButton")
                BindBtn.Size = UDim2.new(0, 55, 0, 20)
                BindBtn.Position = UDim2.new(1, -55, 0.5, -10)
                BindBtn.BackgroundColor3 = Color3.fromRGB(22, 26, 38)
                BindBtn.Text = currentKey.Name
                BindBtn.TextColor3 = Color3.fromRGB(180, 190, 210)
                BindBtn.Font = Enum.Font.Gotham
                BindBtn.TextSize = 11
                BindBtn.Parent = BindFrame

                local BtnCorner = Instance.new("UICorner")
                BtnCorner.CornerRadius = UDim.new(0, 4)
                BtnCorner.Parent = BindBtn

                local listening = false
                BindBtn.MouseButton1Click:Connect(function()
                    listening = true
                    BindBtn.Text = "[...]"
                    BindBtn.TextColor3 = Color3.fromRGB(0, 180, 255)
                end)

                UserInputService.InputBegan:Connect(function(input)
                    if listening and input.UserInputType == Enum.UserInputType.Keyboard then
                        currentKey = input.KeyCode
                        BindBtn.Text = currentKey.Name
                        BindBtn.TextColor3 = Color3.fromRGB(180, 190, 210)
                        listening = false
                        callback(currentKey)
                    end
                end)
            end

            -- BUTTON
            function SectionObj:CreateButton(opts)
                opts = opts or {}
                local name = opts.Name or "Button"
                local callback = opts.Callback or function() end

                local BtnFrame = Instance.new("Frame")
                BtnFrame.Size = UDim2.new(1, 0, 0, 28)
                BtnFrame.BackgroundTransparency = 1
                BtnFrame.Parent = ItemHolder

                table.insert(WindowObj.AllElements, { Name = name, Frame = BtnFrame })

                local Btn = Instance.new("TextButton")
                Btn.Size = UDim2.new(1, 0, 1, 0)
                Btn.BackgroundColor3 = Color3.fromRGB(22, 26, 38)
                Btn.Text = name
                Btn.TextColor3 = Color3.fromRGB(220, 225, 235)
                Btn.Font = Enum.Font.GothamMedium
                Btn.TextSize = 12
                Btn.Parent = BtnFrame

                local BtnCorner = Instance.new("UICorner")
                BtnCorner.CornerRadius = UDim.new(0, 5)
                BtnCorner.Parent = Btn

                Btn.MouseButton1Click:Connect(function()
                    Tween(Btn, 0.08, {BackgroundColor3 = Color3.fromRGB(0, 180, 255)})
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
