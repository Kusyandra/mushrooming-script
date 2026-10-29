-- ============================================================
-- Mushrooming: ESP + Speed + Auto-Cut + Menu (Potassium)
-- Бинды: F - меню, G - авто-разрезание
-- ============================================================
print("1. Скрипт начал работу")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")

local player = Players.LocalPlayer
pcall(function() workspace.StreamingEnabled = false end)

local highlightColor = Color3.fromRGB(0, 255, 0)
local normalSpeed = 16
local currentSpeed = 16
local speedEnabled = false
local autoCutEnabled = false
local usePerfectZone = true

local mushroomsByRarity = {
    Common = {"Birch Polypore", "Button Mushroom", "Chanterelle", "Honey Fungus", "Meadow Mushroom", "Puddle Puffball", "Raindrop Cap", "Mudfoot Bolete", "Turkey Tail", "Drizzle Bonnet", "Jelly Ear", "Oyster Mushroom", "Saffron Milkcap", "Slippery Jack", "Snowy Waxcap", "Pale Cavecap", "Duskbell", "Gravemoss", "Mistpuff", "Rainfolk", "Tallow Cap", "Willowfoot", "Cobweb Webcap", "Glimmergill", "Gourdcap"},
    Uncommon = {"Bird's Nest Fungus", "Fairy Ring Champignon", "Glowing Mycena", "Inkwell Cap", "Orange Birch Bolete", "Shaggy Ink Cap", "Beefsteak Fungus", "Fly Agaric", "Hedgehog Mushroom", "Wood Blewit", "Dew Jelly", "Moss Bell", "Scarlet Elf Cup", "Amethyst Deceiver", "Stormcap", "Violet Webcap", "Yellow Stagshorn", "Skybell", "Dripcap", "Rootlace", "Black Trumpet", "Ashen Shelf", "Barrowtongue", "Cloudcap", "Hushcap", "Lanternstalk", "Mourning Veil", "Silverreed Cap", "Slatecap", "Verdigris Cap", "Batwing Oyster", "Candy Corn Cap", "Moth Bonnet", "Witch's Hat"},
    Rare = {"Giant Puffball", "Morel", "Parasol Mushroom", "Rainbow Waxcap", "Umbrella Parasol", "Chicken of the Woods", "Foxfire", "Harefoot Inkcap", "Jack-o'-Lantern", "King Bolete", "Ghost Fungus", "Lion's Mane", "Cauliflower Fungus", "Earthstar", "Thunderhorn", "Indigo Milk Cap", "Cavern Lantern", "Death Cap", "Bellwort", "Fen Lantern", "Hearthash Cap", "Stillwater Cup", "Tearfringe", "Wreathcap", "Yew Bracket", "Cauldron Cap", "Ghostbell", "Hexcap", "Hollowgrin", "Skullcap"},
    Epic = {"Chaga", "Black Truffle", "Mistveil", "Porcelain Fungus", "Sky Blue Mushroom", "Tidepool Morel", "Deadly Webcap", "Frostcap", "Azure Glowcap", "Crystal Morel", "Bleeding Tooth", "Devil's Fingers", "Ambertear", "Founder's Lace", "Gloam Morel", "Silverbark Ear", "Twilight Parasol", "Weeping Cap", "Dawnbell", "Harvest Bolete", "Hearthcap", "Raven's Cowl", "Wispcap"},
    Legendary = {"Sun Crown", "Caesar's Mushroom", "Destroying Angel", "Matsutake", "Starlight Veil", "Umbral Cap", "Moonlit Morel", "Storm Crown", "Veiled Lady", "Barrowstar", "Canopy Crown", "Duskglass Cap", "Eightfold Crown", "Palesaddle", "Stormlily", "Veilfall Cap", "Grand Gourdcap", "Lamplight Parasol", "Mirrorcap", "Sentinel Morel", "Wellspring Cap"},
    Mythic = {"Rainbringer", "Starspore", "Prism Crown", "Echo Bell", "Elder Cap", "Candlecoral", "Firstroot", "Founder's Bonnet", "Harvest Moon Cap", "Starwhisper"},
    Secret = {"Glowfoot", "Heart of the Forest", "Skytear", "Bramblecrown", "Thousandleaf", "Wanderwick"},
    Celestial = {"Chimecap", "Fogweave", "Hallowroot", "Rainpearl", "Wisp's Chalice"},
    Ancestral = {"Firstlight"}
}

local nameOverrides = {["Oyster"] = "Oyster Mushroom", ["FairyRing"] = "Fairy Ring Champignon", ["Porcini"] = "King Bolete"}

local function normalizeName(name)
    local n = string.lower(name)
    return n:gsub("[%s'%-%._]", "")
end

print("2. Списки созданы")
local mushroomLookup = {}
local enabledMushrooms = {}
for _, list in pairs(mushroomsByRarity) do
    for _, name in ipairs(list) do
        mushroomLookup[normalizeName(name)] = name
        enabledMushrooms[name] = true
    end
end

local espObjects = {}

local function createESP(object, nameOverride)
    if espObjects[object] then return end
    local part = object
    if object:IsA("Model") then part = object.PrimaryPart or object:FindFirstChildWhichIsA("BasePart") end
    if not part then return end
    
    local highlight = Instance.new("Highlight")
    highlight.Name = "MushroomESP_Highlight"
    highlight.Adornee = object
    highlight.FillColor = highlightColor
    highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
    highlight.FillTransparency = 0.5
    highlight.OutlineTransparency = 0
    highlight.Parent = object

    local billboard = Instance.new("BillboardGui")
    billboard.Name = "MushroomESP_Label"
    billboard.Adornee = part
    billboard.Size = UDim2.new(0, 160, 0, 28)
    billboard.StudsOffset = Vector3.new(0, 2.5, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = part

    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.TextColor3 = Color3.fromRGB(255, 255, 255)
    label.TextStrokeTransparency = 0
    label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
    label.Font = Enum.Font.GothamBold
    label.TextScaled = true
    label.Text = nameOverride or object.Name
    label.Parent = billboard

    espObjects[object] = {highlight = highlight, billboard = billboard, label = label, part = part, originalName = nameOverride or object.Name}
end

local function removeESP(object)
    if espObjects[object] then
        if espObjects[object].highlight then espObjects[object].highlight:Destroy() end
        if espObjects[object].billboard then espObjects[object].billboard:Destroy() end
        espObjects[object] = nil
    end
end

local function getCanonicalName(modelName)
    if nameOverrides[modelName] then return nameOverrides[modelName] end
    local norm = normalizeName(modelName)
    if mushroomLookup[norm] then return mushroomLookup[norm] end
    for normKey, original in pairs(mushroomLookup) do
        if normKey:sub(1, #norm) == norm and #norm >= 4 then return original end
    end
    return nil
end

print("3. Функции ESP готовы")
local function scanMushroomsFolder()
    local folder = workspace:FindFirstChild("Mushrooms")
    if not folder then return end
    for _, obj in ipairs(folder:GetChildren()) do
        if obj:IsA("Model") then
            local canonical = getCanonicalName(obj.Name)
            if canonical then createESP(obj, canonical) end
        end
    end
end

local function watchMushroomsFolder()
    local folder = workspace:FindFirstChild("Mushrooms")
    if not folder then
        workspace.ChildAdded:Connect(function(child)
            if child.Name == "Mushrooms" then watchMushroomsFolder() end
        end)
        return
    end
    folder.ChildAdded:Connect(function(obj)
        task.wait(0.2)
        if obj:IsA("Model") then
            local canonical = getCanonicalName(obj.Name)
            if canonical then createESP(obj, canonical) end
        end
    end)
    folder.ChildRemoved:Connect(function(obj) removeESP(obj) end)
end

task.spawn(function()
    while true do
        task.wait(5)
        scanMushroomsFolder()
    end
end)

RunService.Heartbeat:Connect(function()
    local char = player.Character
    if not char then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    for obj, data in pairs(espObjects) do
        if not obj or not obj.Parent then
            removeESP(obj)
            continue
        end
        if data.label and data.part then
            local enabled = enabledMushrooms[data.originalName]
            data.highlight.Enabled = enabled == true
            data.billboard.Enabled = enabled == true
            if enabled then
                local dist = (root.Position - data.part.Position).Magnitude
                data.label.Text = data.originalName .. " [" .. math.floor(dist) .. "m]"
            end
        end
    end
end)

print("4. Ускорение готово")
local speedConnection = nil
local function applySpeed()
    local character = player.Character
    if not character then return end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    humanoid.WalkSpeed = speedEnabled and currentSpeed or normalSpeed
    if speedConnection then speedConnection:Disconnect() end
    speedConnection = humanoid:GetPropertyChangedSignal("WalkSpeed"):Connect(function()
        if humanoid.WalkSpeed ~= (speedEnabled and currentSpeed or normalSpeed) then
            humanoid.WalkSpeed = speedEnabled and currentSpeed or normalSpeed
        end
    end)
end

player.CharacterAdded:Connect(function()
    task.wait(1)
    applySpeed()
end)
if player.Character then applySpeed() end

local function pressCutKey()
    VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.Space, false, game)
    task.wait(0.05)
    VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.Space, false, game)
end

task.spawn(function()
    local playerGui = player:WaitForChild("PlayerGui")
    while true do
        task.wait(0.01)
        if autoCutEnabled then
            local carveGui = playerGui:FindFirstChild("Carve")
            if not carveGui then
                for _, gui in ipairs(playerGui:GetChildren()) do
                    if gui:FindFirstChild("Bar") and gui.Bar:FindFirstChild("Marker") and gui.Bar:FindFirstChild("Zone") then
                        carveGui = gui
                        break
                    end
                end
            end

            if carveGui then
                local bar = carveGui:FindFirstChild("Bar")
                if bar then
                    local zone = bar:FindFirstChild("Zone")
                    local perfect = bar:FindFirstChild("Perfect")
                    local marker = bar:FindFirstChild("Marker")
                    if zone and marker then
                        local target = usePerfectZone and perfect or zone
                        if target then
                            local markerX = marker.AbsolutePosition.X + (marker.AbsoluteSize.X / 2)
                            local zoneX = target.AbsolutePosition.X
                            local zoneWidth = target.AbsoluteSize.X
                            if markerX >= zoneX and markerX <= (zoneX + zoneWidth) then
                                pressCutKey()
                                task.wait(0.2)
                            end
                        end
                    end
                end
            end
        end
    end
end)

-- ================== МЕНЮ ==================
print("5. Начинаю создавать меню")
local gui = Instance.new("ScreenGui")
gui.Name = "MushroomESP_Menu"
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = player:WaitForChild("PlayerGui")

local mainFrame = Instance.new("Frame")
mainFrame.Name = "Main"
mainFrame.Size = UDim2.new(0, 420, 0, 540)
mainFrame.Position = UDim2.new(0.5, -210, 0.5, -270)
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
mainFrame.BorderSizePixel = 0
mainFrame.Visible = false
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Parent = gui

local corner = Instance.new("UICorner")
corner.CornerRadius = UDim.new(0, 10)
corner.Parent = mainFrame

local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(0, 200, 100)
stroke.Thickness = 2
stroke.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 40)
title.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
title.BorderSizePixel = 0
title.Text = "🍄 Mushrooming — Ultimate"
title.TextColor3 = Color3.fromRGB(255, 255, 255)
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.Parent = mainFrame
local titleCorner = Instance.new("UICorner")
titleCorner.CornerRadius = UDim.new(0, 10)
titleCorner.Parent = title

local closeBtn = Instance.new("TextButton")
closeBtn.Size = UDim2.new(0, 32, 0, 32)
closeBtn.Position = UDim2.new(1, -38, 0, 4)
closeBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
closeBtn.Text = "✕"
closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
closeBtn.Font = Enum.Font.GothamBold
closeBtn.TextSize = 16
closeBtn.Parent = mainFrame
local closeCorner = Instance.new("UICorner")
closeCorner.CornerRadius = UDim.new(0, 6)
closeCorner.Parent = closeBtn

closeBtn.MouseButton1Click:Connect(function() mainFrame.Visible = false end)

local tabFrame = Instance.new("Frame")
tabFrame.Size = UDim2.new(1, -20, 0, 35)
tabFrame.Position = UDim2.new(0, 10, 0, 48)
tabFrame.BackgroundTransparency = 1
tabFrame.Parent = mainFrame

local espTab = Instance.new("TextButton")
espTab.Size = UDim2.new(0.5, -5, 1, 0)
espTab.BackgroundColor3 = Color3.fromRGB(0, 150, 80)
espTab.Text = "ESP (Грибы)"
espTab.TextColor3 = Color3.fromRGB(255, 255, 255)
espTab.Font = Enum.Font.GothamBold
espTab.TextSize = 14
espTab.Parent = tabFrame
local espTabCorner = Instance.new("UICorner"); espTabCorner.CornerRadius = UDim.new(0, 6); espTabCorner.Parent = espTab

local settingsTab = Instance.new("TextButton")
settingsTab.Size = UDim2.new(0.5, -5, 1, 0)
settingsTab.Position = UDim2.new(0.5, 5, 0, 0)
settingsTab.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
settingsTab.Text = "Настройки"
settingsTab.TextColor3 = Color3.fromRGB(255, 255, 255)
settingsTab.Font = Enum.Font.GothamBold
settingsTab.TextSize = 14
settingsTab.Parent = tabFrame
local settingsTabCorner = Instance.new("UICorner"); settingsTabCorner.CornerRadius = UDim.new(0, 6); settingsTabCorner.Parent = settingsTab

local searchBox = Instance.new("TextBox")
searchBox.Size = UDim2.new(1, -20, 0, 30)
searchBox.Position = UDim2.new(0, 10, 0, 88)
searchBox.BackgroundColor3 = Color3.fromRGB(45, 45, 52)
searchBox.BorderSizePixel = 0
searchBox.Text = ""
searchBox.PlaceholderText = "🔍 Поиск гриба по названию..."
searchBox.PlaceholderColor3 = Color3.fromRGB(150, 150, 150)
searchBox.TextColor3 = Color3.fromRGB(255, 255, 255)
searchBox.Font = Enum.Font.Gotham
searchBox.TextSize = 13
searchBox.TextXAlignment = Enum.TextXAlignment.Left
searchBox.ClearTextOnFocus = false
searchBox.Parent = mainFrame
local searchCorner = Instance.new("UICorner"); searchCorner.CornerRadius = UDim.new(0, 6); searchCorner.Parent = searchBox
local searchPad = Instance.new("UIPadding"); searchPad.PaddingLeft = UDim.new(0, 8); searchPad.Parent = searchBox

local espContainer = Instance.new("ScrollingFrame")
espContainer.Size = UDim2.new(1, -20, 1, -185)
espContainer.Position = UDim2.new(0, 10, 0, 124)
espContainer.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
espContainer.BorderSizePixel = 0
espContainer.ScrollBarThickness = 6
espContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
espContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
espContainer.Parent = mainFrame
local espContainerCorner = Instance.new("UICorner"); espContainerCorner.CornerRadius = UDim.new(0, 6); espContainerCorner.Parent = espContainer

local espLayout = Instance.new("UIListLayout")
espLayout.Padding = UDim.new(0, 6)
espLayout.SortOrder = Enum.SortOrder.LayoutOrder
espLayout.Parent = espContainer

local allBtn = Instance.new("TextButton")
allBtn.Size = UDim2.new(0, 80, 0, 30)
allBtn.Position = UDim2.new(0, 10, 1, -45)
allBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 80)
allBtn.Text = "Все"
allBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
allBtn.Font = Enum.Font.GothamBold
allBtn.TextSize = 13
allBtn.Parent = mainFrame
local allCorner = Instance.new("UICorner"); allCorner.CornerRadius = UDim.new(0, 6); allCorner.Parent = allBtn

local noneBtn = Instance.new("TextButton")
noneBtn.Size = UDim2.new(0, 80, 0, 30)
noneBtn.Position = UDim2.new(0, 100, 1, -45)
noneBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
noneBtn.Text = "Ничего"
noneBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
noneBtn.Font = Enum.Font.GothamBold
noneBtn.TextSize = 13
noneBtn.Parent = mainFrame
local noneCorner = Instance.new("UICorner"); noneCorner.CornerRadius = UDim.new(0, 6); noneCorner.Parent = noneBtn

local settingsContainer = Instance.new("ScrollingFrame")
settingsContainer.Size = UDim2.new(1, -20, 1, -150)
settingsContainer.Position = UDim2.new(0, 10, 0, 90)
settingsContainer.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
settingsContainer.BorderSizePixel = 0
settingsContainer.ScrollBarThickness = 6
settingsContainer.CanvasSize = UDim2.new(0, 0, 0, 0)
settingsContainer.AutomaticCanvasSize = Enum.AutomaticSize.Y
settingsContainer.Visible = false
settingsContainer.Parent = mainFrame
local settingsCorner = Instance.new("UICorner"); settingsCorner.CornerRadius = UDim.new(0, 6); settingsCorner.Parent = settingsContainer

local settingsLayout = Instance.new("UIListLayout")
settingsLayout.Padding = UDim.new(0, 10)
settingsLayout.SortOrder = Enum.SortOrder.LayoutOrder
settingsLayout.Parent = settingsContainer

local bindsLabel = Instance.new("TextLabel")
bindsLabel.Size = UDim2.new(1, -20, 0, 50)
bindsLabel.Position = UDim2.new(0, 10, 0, 10)
bindsLabel.BackgroundTransparency = 1
bindsLabel.Text = "Бинды:\n[F] - Открыть/закрыть меню\n[G] - Вкл/выкл авто-разрезание"
bindsLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
bindsLabel.Font = Enum.Font.Gotham
bindsLabel.TextSize = 13
bindsLabel.TextXAlignment = Enum.TextXAlignment.Left
bindsLabel.TextYAlignment = Enum.TextYAlignment.Top
bindsLabel.LayoutOrder = 1
bindsLabel.Parent = settingsContainer

local speedFrame = Instance.new("Frame")
speedFrame.Size = UDim2.new(1, -20, 0, 180)
speedFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 42)
speedFrame.BorderSizePixel = 0
speedFrame.LayoutOrder = 2
speedFrame.Parent = settingsContainer
local speedFrameCorner = Instance.new("UICorner"); speedFrameCorner.CornerRadius = UDim.new(0, 6); speedFrameCorner.Parent = speedFrame

local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(1, -20, 0, 30)
speedLabel.Position = UDim2.new(0, 10, 0, 5)
speedLabel.BackgroundTransparency = 1
speedLabel.Text = "Скорость бега: 16"
speedLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
speedLabel.Font = Enum.Font.GothamBold
speedLabel.TextSize = 15
speedLabel.TextXAlignment = Enum.TextXAlignment.Left
speedLabel.Parent = speedFrame

local sliderBg = Instance.new("Frame")
sliderBg.Size = UDim2.new(1, -40, 0, 10)
sliderBg.Position = UDim2.new(0, 20, 0, 50)
sliderBg.BackgroundColor3 = Color3.fromRGB(60, 60, 70)
sliderBg.BorderSizePixel = 0
sliderBg.Parent = speedFrame
local sliderBgCorner = Instance.new("UICorner"); sliderBgCorner.CornerRadius = UDim.new(1, 0); sliderBgCorner.Parent = sliderBg

local sliderFill = Instance.new("Frame")
sliderFill.Size = UDim2.new(0, 0, 1, 0)
sliderFill.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
sliderFill.BorderSizePixel = 0
sliderFill.Parent = sliderBg
local sliderFillCorner = Instance.new("UICorner"); sliderFillCorner.CornerRadius = UDim.new(1, 0); sliderFillCorner.Parent = sliderFill

local sliderKnob = Instance.new("Frame")
sliderKnob.Size = UDim2.new(0, 20, 0, 20)
sliderKnob.Position = UDim2.new(0, -10, 0.5, -10)
sliderKnob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
sliderKnob.BorderSizePixel = 0
sliderKnob.Parent = sliderBg
local sliderKnobCorner = Instance.new("UICorner"); sliderKnobCorner.CornerRadius = UDim.new(1, 0); sliderKnobCorner.Parent = sliderKnob

local minSpeed, maxSpeed = 16, 200
local draggingSlider = false

local function updateSliderFromValue(value)
    local alpha = math.clamp((value - minSpeed) / (maxSpeed - minSpeed), 0, 1)
    sliderFill.Size = UDim2.new(alpha, 0, 1, 0)
    sliderKnob.Position = UDim2.new(alpha, -10, 0.5, -10)
    speedLabel.Text = "Скорость бега: " .. math.floor(value)
end

local function setSpeedFromX(x)
    local rel = (x - sliderBg.AbsolutePosition.X) / sliderBg.AbsoluteSize.X
    rel = math.clamp(rel, 0, 1)
    local value = math.floor(minSpeed + (maxSpeed - minSpeed) * rel)
    currentSpeed = value
    updateSliderFromValue(value)
    if speedEnabled then applySpeed() end
end

sliderBg.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingSlider = true
        mainFrame.Draggable = false
        setSpeedFromX(input.Position.X)
    end
end)

sliderKnob.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        draggingSlider = true
        mainFrame.Draggable = false
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if draggingSlider and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
        setSpeedFromX(input.Position.X)
    end
end)

UserInputService.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        if draggingSlider then
            draggingSlider = false
            mainFrame.Draggable = true
        end
    end
end)

local toggleSpeedBtn = Instance.new("TextButton")
toggleSpeedBtn.Size = UDim2.new(1, -40, 0, 40)
toggleSpeedBtn.Position = UDim2.new(0, 20, 0, 75)
toggleSpeedBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
toggleSpeedBtn.Text = "Ускорение: ВЫКЛ"
toggleSpeedBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
toggleSpeedBtn.Font = Enum.Font.GothamBold
toggleSpeedBtn.TextSize = 15
toggleSpeedBtn.Parent = speedFrame
local toggleCorner = Instance.new("UICorner"); toggleCorner.CornerRadius = UDim.new(0, 6); toggleCorner.Parent = toggleSpeedBtn

toggleSpeedBtn.MouseButton1Click:Connect(function()
    speedEnabled = not speedEnabled
    if speedEnabled then
        toggleSpeedBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 80)
        toggleSpeedBtn.Text = "Ускорение: ВКЛ"
    else
        toggleSpeedBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
        toggleSpeedBtn.Text = "Ускорение: ВЫКЛ"
    end
    applySpeed()
end)

local rarityColors = {
    Common = Color3.fromRGB(180, 180, 180),
    Uncommon = Color3.fromRGB(80, 200, 80),
    Rare = Color3.fromRGB(80, 140, 255),
    Epic = Color3.fromRGB(180, 80, 255),
    Legendary = Color3.fromRGB(255, 180, 50),
    Mythic = Color3.fromRGB(255, 80, 80),
    Secret = Color3.fromRGB(255, 50, 200),
    Celestial = Color3.fromRGB(100, 220, 255),
    Ancestral = Color3.fromRGB(255, 220, 100),
}

local listItems = {}
local layoutOrder = 0

for rarity, list in pairs(mushroomsByRarity) do
    layoutOrder = layoutOrder + 1
    local headerFrame = Instance.new("Frame")
    headerFrame.Size = UDim2.new(1, -10, 0, 24)
    headerFrame.BackgroundTransparency = 1
    headerFrame.LayoutOrder = layoutOrder
    headerFrame.Parent = espContainer

    local rarityLabel = Instance.new("TextLabel")
    rarityLabel.Size = UDim2.new(1, -70, 1, 0)
    rarityLabel.BackgroundTransparency = 1
    rarityLabel.Text = "— " .. rarity .. " —"
    rarityLabel.TextColor3 = rarityColors[rarity] or Color3.fromRGB(255, 255, 255)
    rarityLabel.Font = Enum.Font.GothamBold
    rarityLabel.TextSize = 14
    rarityLabel.TextXAlignment = Enum.TextXAlignment.Left
    rarityLabel.Parent = headerFrame

    local plusBtn = Instance.new("TextButton")
    plusBtn.Size = UDim2.new(0, 28, 0, 20)
    plusBtn.Position = UDim2.new(1, -60, 0.5, -10)
    plusBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 80)
    plusBtn.Text = "+"
    plusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    plusBtn.Font = Enum.Font.GothamBold
    plusBtn.TextSize = 14
    plusBtn.Parent = headerFrame
    local plusCorner = Instance.new("UICorner"); plusCorner.CornerRadius = UDim.new(0, 4); plusCorner.Parent = plusBtn

    local minusBtn = Instance.new("TextButton")
    minusBtn.Size = UDim2.new(0, 28, 0, 20)
    minusBtn.Position = UDim2.new(1, -28, 0.5, -10)
    minusBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
    minusBtn.Text = "—"
    minusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    minusBtn.Font = Enum.Font.GothamBold
    minusBtn.TextSize = 14
    minusBtn.Parent = headerFrame
    local minusCorner = Instance.new("UICorner"); minusCorner.CornerRadius = UDim.new(0, 4); minusCorner.Parent = minusBtn

    local rarityItems = {}
    for _, name in ipairs(list) do
        layoutOrder = layoutOrder + 1
        local item = Instance.new("TextButton")
        item.Size = UDim2.new(1, -10, 0, 26)
        item.BackgroundColor3 = Color3.fromRGB(40, 40, 48)
        item.Text = "  " .. name
        item.TextColor3 = Color3.fromRGB(255, 255, 255)
        item.Font = Enum.Font.Gotham
        item.TextSize = 13
        item.TextXAlignment = Enum.TextXAlignment.Left
        item.LayoutOrder = layoutOrder
        item.Parent = espContainer
        local itemCorner = Instance.new("UICorner"); itemCorner.CornerRadius = UDim.new(0, 4); itemCorner.Parent = item

        local indicator = Instance.new("Frame")
        indicator.Size = UDim2.new(0, 8, 0, 8)
        indicator.Position = UDim2.new(1, -16, 0.5, -4)
        indicator.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
        indicator.BorderSizePixel = 0
        indicator.Parent = item
        local indCorner = Instance.new("UICorner"); indCorner.CornerRadius = UDim.new(1, 0); indCorner.Parent = indicator

        item.MouseButton1Click:Connect(function()
            enabledMushrooms[name] = not enabledMushrooms[name]
            indicator.BackgroundColor3 = enabledMushrooms[name] and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(80, 80, 80)
        end)

        table.insert(rarityItems, {name = name, indicator = indicator})
        table.insert(listItems, {name = name, item = item, indicator = indicator, rarityLabel = headerFrame})
    end

    plusBtn.MouseButton1Click:Connect(function()
        for _, data in ipairs(rarityItems) do
            enabledMushrooms[data.name] = true
            data.indicator.BackgroundColor3 = Color3.fromRGB(0, 200, 100)
        end
    end)

    minusBtn.MouseButton1Click:Connect(function()
        for _, data in ipairs(rarityItems) do
            enabledMushrooms[data.name] = false
            data.indicator.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
        end
    end)
end

local function applySearchFilter()
    local query = string.lower(searchBox.Text)
    local visibleRarities = {}
    for _, entry in ipairs(listItems) do
        local matches = (query == "" or string.find(string.lower(entry.name), query, 1, true) ~= nil)
        entry.item.Visible = matches
        if matches then visibleRarities[entry.rarityLabel] = true end
    end
    for _, entry in ipairs(listItems) do
        if entry.rarityLabel then entry.rarityLabel.Visible = visibleRarities[entry.rarityLabel] == true end
    end
end

searchBox:GetPropertyChangedSignal("Text"):Connect(applySearchFilter)

allBtn.MouseButton1Click:Connect(function()
    for name, _ in pairs(enabledMushrooms) do enabledMushrooms[name] = true end
    for _, entry in ipairs(listItems) do entry.indicator.BackgroundColor3 = Color3.fromRGB(0, 200, 100) end
end)

noneBtn.MouseButton1Click:Connect(function()
    for name, _ in pairs(enabledMushrooms) do enabledMushrooms[name] = false end
    for _, entry in ipairs(listItems) do entry.indicator.BackgroundColor3 = Color3.fromRGB(80, 80, 80) end
end)

espTab.MouseButton1Click:Connect(function()
    espContainer.Visible = true
    speedContainer.Visible = false
    searchBox.Visible = true
    espTab.BackgroundColor3 = Color3.fromRGB(0, 150, 80)
    speedTab.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    allBtn.Visible = true
    noneBtn.Visible = true
end)

settingsTab.MouseButton1Click:Connect(function()
    espContainer.Visible = false
    settingsContainer.Visible = true
    searchBox.Visible = false
    espTab.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
    settingsTab.BackgroundColor3 = Color3.fromRGB(0, 150, 80)
    allBtn.Visible = false
    noneBtn.Visible = false
end)

local menuOpen = false
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.F then
        menuOpen = not menuOpen
        mainFrame.Visible = menuOpen
    elseif input.KeyCode == Enum.KeyCode.G then
        autoCutEnabled = not autoCutEnabled
        if autoCutLabel then
            autoCutLabel.Text = "Авто-разрезание: " .. (autoCutEnabled and "ВКЛ" or "ВЫКЛ") .. " [G]"
            autoCutLabel.TextColor3 = autoCutEnabled and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(200, 200, 200)
        end
    end
end)

updateSliderFromValue(currentSpeed)
applySearchFilter()
scanMushroomsFolder()
watchMushroomsFolder()
print("Mushrooming ESP + Speed + Auto-Cut + Menu загружен. Нажми F для меню.")
