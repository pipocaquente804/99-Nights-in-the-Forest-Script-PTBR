--// Script 99 Noites na Floresta com Rayfield GUI //--

-- Carregar biblioteca Rayfield UI
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Serviços
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local LocalPlayer = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- Configuração da janela
local Window = Rayfield:CreateWindow({
    Name = "shiftz99nights",
    LoadingTitle = "99 Noites na Floresta",
    LoadingSubtitle = "shiftz99nights",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = nil,
        FileName = "99NightsSettings"
    },
    Discord = {
        Enabled = false,
        Invite = "",
        RememberJoins = true
    },
    KeySystem = false,
})

-- Variáveis
local teleportTargets = {
"Alpha Wolf", "Alpha Wolf Pelt", "Anvil Base", "Apple", "Bandage", "Bear", "Berry", 
"Bolt", "Broken Fan", "Broken Microwave", "Bunny", "Bunny Foot", "Cake", "Carrot", "Chair Set", "Chest", "Chilli",
"Coal", "Coin Stack", "Crossbow Cultist", "Cultist", "Cultist Gem", "Deer", "Fuel Canister", "Good Sack", "Good Axe", "Iron Body",
"Item Chest", "Item Chest2", "Item Chest3", "Item Chest4", "Item Chest6", "Leather Body", "Log", "Lost Child",
"Lost Child2", "Lost Child3", "Lost Child4", "Medkit", "Meat? Sandwich", "Morsel", "Old Car Engine", "Old Flashlight", "Old Radio", "Oil Barrel",
"Revolver", "Revolver Ammo", "Rifle", "Rifle Ammo", "Riot Shield", "Sapling", "Seed Box", "Sheet Metal", "Spear",
"Steak", "Stronghold Diamond Chest", "Tyre", "Washing Machine", "Wolf", "Wolf Corpse", "Wolf Pelt"
}
local AimbotTargets = {"Alpha Wolf", "Wolf", "Crossbow Cultist", "Cultist", "Bunny", "Bear", "Polar Bear"}
local espEnabled = false
local npcESPEnabled = false
local ignoreDistanceFrom = Vector3.new(0, 0, 0)
local minDistance = 50
local AutoTreeFarmEnabled = false
local InfiniteHealthEnabled = false
local AutoKillMobsEnabled = false
local AutoKillMobsRadius = 50

local IndetectavelEnabled = false
local NoFallDamageEnabled = false
local FullbrightEnabled = false
local NoClipEnabled = false
local AutoCollectEnabled = false
local FOVValue = 70
local AntiAFKEnabled = false
local InfiniteJumpEnabled = false
local WalkOnWaterEnabled = false
local NightVisionEnabled = false
local ItemMagnetEnabled = false
local InfiniteDurabilityEnabled = false
local flySpeed = 60
local JumpPowerValue = 50
local GravityValue = 196.2
local ShowCoordinatesEnabled = false
local ShowFPSEnabled = false
local FreecamEnabled = false
local FreecamPos = Vector3.new(0, 0, 0)
local InvisibleEnabled = false
local NoRecoilEnabled = false
local AutoSprintEnabled = false
local InfiniteOxygenEnabled = false
local SafeModeEnabled = false
local MobNotifyEnabled = false
local MobNotifyCooldown = {}
local NoScreenEffectsEnabled = false
local defaultAmbientB, defaultBrightnessB, defaultGravityB = Lighting.Ambient, Lighting.Brightness, workspace.Gravity
local coordsTextB, fpsTextB
local panicEnabled = false

-- Simulação de clique
local VirtualInputManager = game:GetService("VirtualInputManager")
function mouse1click()
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, true, game, 0)
    VirtualInputManager:SendMouseButtonEvent(0, 0, 0, false, game, 0)
end

-- Círculo FOV do Aimbot
local AimbotEnabled = false
local FOVRadius = 100
local FOVCircle = Drawing.new("Circle")
FOVCircle.Color = Color3.fromRGB(128, 255, 0)
FOVCircle.Thickness = 1
FOVCircle.Radius = FOVRadius
FOVCircle.Transparency = 0.5
FOVCircle.Filled = false
FOVCircle.Visible = false

RunService.RenderStepped:Connect(function()
    if AimbotEnabled then
        local mousePos = UserInputService:GetMouseLocation()
        FOVCircle.Position = Vector2.new(mousePos.X, mousePos.Y)
        FOVCircle.Visible = true
    else
        FOVCircle.Visible = false
    end
end)

-- Função ESP
local function createESP(item)
    local adorneePart
    if item:IsA("Model") then
        if item:FindFirstChildWhichIsA("Humanoid") then return end
        adorneePart = item:FindFirstChildWhichIsA("BasePart")
    elseif item:IsA("BasePart") then
        adorneePart = item
    else
        return
    end

    if not adorneePart then return end

    local distance = (adorneePart.Position - ignoreDistanceFrom).Magnitude
    if distance < minDistance then return end

    if not item:FindFirstChild("ESP_Billboard") then
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "ESP_Billboard"
        billboard.Adornee = adorneePart
        billboard.Size = UDim2.new(0, 50, 0, 20)
        billboard.AlwaysOnTop = true
        billboard.StudsOffset = Vector3.new(0, 2, 0)

        local label = Instance.new("TextLabel", billboard)
        label.Size = UDim2.new(1, 0, 1, 0)
        label.Text = item.Name
        label.BackgroundTransparency = 1
        label.TextColor3 = Color3.fromRGB(255, 255, 255)
        label.TextStrokeTransparency = 0
        label.TextScaled = true
        billboard.Parent = item
    end

    if not item:FindFirstChild("ESP_Highlight") then
        local highlight = Instance.new("Highlight")
        highlight.Name = "ESP_Highlight"
        highlight.FillColor = Color3.fromRGB(255, 255, 255)
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.FillTransparency = 0.25
        highlight.OutlineTransparency = 0
        highlight.Adornee = item:IsA("Model") and item or adorneePart
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.Parent = item
    end
end


local function toggleESP(state)
    espEnabled = state
    for _, item in pairs(workspace:GetDescendants()) do
        if table.find(teleportTargets, item.Name) then
            if espEnabled then
                createESP(item)
            else
                if item:FindFirstChild("ESP_Billboard") then item.ESP_Billboard:Destroy() end
                if item:FindFirstChild("ESP_Highlight") then item.ESP_Highlight:Destroy() end
            end
        end
    end
end

workspace.DescendantAdded:Connect(function(desc)
    if espEnabled and table.find(teleportTargets, desc.Name) then
        task.wait(0.1)
        createESP(desc)
    end
end)

-- ESP para NPCs
local npcBoxes = {}

local function createNPCESP(npc)
    if not npc:IsA("Model") or npc:FindFirstChild("HumanoidRootPart") == nil then return end

    local root = npc:FindFirstChild("HumanoidRootPart")
    if npcBoxes[npc] then return end

    local box = Drawing.new("Square")
    box.Thickness = 2
    box.Transparency = 1
    box.Color = Color3.fromRGB(255, 85, 0)
    box.Filled = false
    box.Visible = true

    local nameText = Drawing.new("Text")
    nameText.Text = npc.Name
    nameText.Color = Color3.fromRGB(255, 255, 255)
    nameText.Size = 16
    nameText.Center = true
    nameText.Outline = true
    nameText.Visible = true

    npcBoxes[npc] = {box = box, name = nameText}

    -- Limpar ao remover
    npc.AncestryChanged:Connect(function(_, parent)
        if not parent and npcBoxes[npc] then
            npcBoxes[npc].box:Remove()
            npcBoxes[npc].name:Remove()
            npcBoxes[npc] = nil
        end
    end)
end

local function toggleNPCESP(state)
    npcESPEnabled = state
    if not state then
        for npc, visuals in pairs(npcBoxes) do
            if visuals.box then visuals.box:Remove() end
            if visuals.name then visuals.name:Remove() end
        end
        npcBoxes = {}
    else
        -- Mostrar ESP de NPCs já existentes
        for _, obj in ipairs(workspace:GetDescendants()) do
            if table.find(AimbotTargets, obj.Name) and obj:IsA("Model") then
                createNPCESP(obj)
            end
        end
    end
end

workspace.DescendantAdded:Connect(function(desc)
    if table.find(AimbotTargets, desc.Name) and desc:IsA("Model") then
        task.wait(0.1)
        if npcESPEnabled then
            createNPCESP(desc)
        end
    end
end)

-- Lógica do farm automático de árvores (com tempo limite)
local badTrees = {}

task.spawn(function()
    while true do
        if AutoTreeFarmEnabled then
            local trees = {}
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj.Name == "Trunk" and obj.Parent and obj.Parent.Name == "Small Tree" then
                    local distance = (obj.Position - ignoreDistanceFrom).Magnitude
                    if distance > minDistance and not badTrees[obj:GetFullName()] then
                        table.insert(trees, obj)
                    end
                end
            end

            table.sort(trees, function(a, b)
                return (a.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude <
                       (b.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
            end)

            for _, trunk in ipairs(trees) do
                if not AutoTreeFarmEnabled then break end
                LocalPlayer.Character:PivotTo(trunk.CFrame + Vector3.new(0, 3, 0))
                task.wait(0.2)
                local startTime = tick()
                while AutoTreeFarmEnabled and trunk and trunk.Parent and trunk.Parent.Name == "Small Tree" do
                    mouse1click()
                    task.wait(0.2)
                    if tick() - startTime > 12 then
                        badTrees[trunk:GetFullName()] = true
                        break
                    end
                end
                task.wait(0.3)
            end
        end
        task.wait(1.5)
    end
end)

local AutoLogFarmEnabled = false
local LogDropType = "Campfire" -- or "Grinder"

local function teleportToClosestLog()
    local closest, shortest = nil, math.huge
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj.Name == "Log" and obj:IsA("Model") then
            local cf = nil
            if pcall(function() cf = obj:GetPivot() end) then
                -- success
            else
                local part = obj:FindFirstChildWhichIsA("BasePart")
                if part then cf = part.CFrame end
            end
            if cf then
                local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local dist = (cf.Position - hrp.Position).Magnitude
                    if dist < shortest then
                        closest = obj
                        shortest = dist
                    end
                end
            end
        end
    end
    if closest then
        local cf = nil
        if pcall(function() cf = closest:GetPivot() end) then
            -- success
        else
            local part = closest:FindFirstChildWhichIsA("BasePart")
            if part then cf = part.CFrame end
        end
        if cf then
            LocalPlayer.Character:PivotTo(cf + Vector3.new(0, 5, 0)) -- Teleport 5 studs above log
            return closest
        end
    end
    return nil
end


local function getBagPickupCount()
    if LogBagType == "Old Sack" then
        return 5
    elseif LogBagType == "Good Sack" then
        return 15
    elseif LogBagType == "Auto" then
        local bag = getBagType()
        if bag == "Good Sack" then return 15 end
        if bag == "Old Sack" then return 5 end
    end
    return 0
end

task.spawn(function()
    while true do
        if AutoLogFarmEnabled then
            local pickupCount = getBagPickupCount()
            if pickupCount == 0 then
                Rayfield:Notify({Title="Farm de troncos", Content="Nenhum tipo de saco selecionado ou encontrado!", Duration=3})
                AutoLogFarmEnabled = false
                continue
            end

            -- Find the nearest log
            local log = getClosestLog()
            if log then
                -- Teleport above log
                local pos = log.Position or (log.PrimaryPart and log.PrimaryPart.Position)
                if pos then
                    LocalPlayer.Character:PivotTo(CFrame.new(pos + Vector3.new(0, 2, 0)))
                    task.wait(0.5)
                    -- Move mouse to feet
                    local footPos = LocalPlayer.Character.HumanoidRootPart.Position - Vector3.new(0, 3, 0)
                    local screen = camera:WorldToScreenPoint(footPos)
                    VirtualInputManager:SendMouseMoveEvent(screen.X, screen.Y, game)
                    task.wait(0.25)
                    -- Pickup logs (F then E, x times)
                    for i=1, pickupCount do
                        pressKey("F")
                        pressKey("E")
                        task.wait(0.13)
                    end

                    -- Teleport to drop location
                    if LogDropType == "Campfire" then
                        LocalPlayer.Character:PivotTo(CFrame.new(0, 10, 0))
                    else
                        LocalPlayer.Character:PivotTo(CFrame.new(16.1,4,-4.6))
                    end
                    task.wait(2)
                end
            else
                Rayfield:Notify({Title="Farm de troncos", Content="Nenhum tronco encontrado!", Duration=3})
                task.wait(3)
            end
        end
        task.wait(1)
    end
end)




local function getClosestLog()
    local minDist = math.huge
    local closest = nil
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj.Name == "Log" then
            local pos = nil
            if obj:IsA("BasePart") then
                pos = obj.Position
            elseif obj:IsA("Model") then
                -- Try PrimaryPart
                if obj.PrimaryPart then
                    pos = obj.PrimaryPart.Position
                else
                    -- Fallback: Find any BasePart inside the Model
                    for _, part in ipairs(obj:GetChildren()) do
                        if part:IsA("BasePart") then
                            pos = part.Position
                            break
                        end
                    end
                end
            end
            if pos then
                local hrp = game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if hrp then
                    local dist = (hrp.Position - pos).Magnitude
                    if dist < minDist then
                        minDist = dist
                        closest = obj
                    end
                end
            end
        end
    end
    return closest
end



local function pressKey(key)
    key = typeof(key) == "EnumItem" and key or Enum.KeyCode[key]
    VirtualInputManager:SendKeyEvent(true, key, false, game)
    task.wait(0.07)
    VirtualInputManager:SendKeyEvent(false, key, false, game)
end



-- Variáveis do aimbot otimizado
local lastAimbotCheck = 0
local aimbotCheckInterval = 0.02 -- Intervalo de atualização (em segundos)
local smoothness = 0.2 -- Suavidade da câmera em direção ao alvo

RunService.RenderStepped:Connect(function()
    -- Só executa se aimbot estiver ativo e botão direito estiver pressionado
    if not AimbotEnabled or not UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton2) then
        FOVCircle.Visible = false
        return
    end

    local currentTime = tick()
    if currentTime - lastAimbotCheck < aimbotCheckInterval then
        -- Aguardar próximo intervalo de atualização
        return
    end
    lastAimbotCheck = currentTime

    local mousePos = UserInputService:GetMouseLocation()
    local closestTarget = nil
    local shortestDistance = math.huge

    -- Buscar alvo mais próximo dentro do raio FOV
    for _, obj in ipairs(workspace:GetDescendants()) do
        if table.find(AimbotTargets, obj.Name) and obj:IsA("Model") then
            local head = obj:FindFirstChild("Head")
            if head then
                local screenPos, onScreen = camera:WorldToViewportPoint(head.Position)
                if onScreen then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - mousePos).Magnitude
                    if dist < shortestDistance and dist <= FOVRadius then
                        shortestDistance = dist
                        closestTarget = head
                    end
                end
            end
        end
    end

    if closestTarget then
        -- Girar câmera suavemente em direção à cabeça do alvo
        local currentCF = camera.CFrame
        local targetCF = CFrame.new(currentCF.Position, closestTarget.Position)
        camera.CFrame = currentCF:Lerp(targetCF, smoothness)

        -- Manter círculo FOV visível na posição do mouse
        FOVCircle.Position = Vector2.new(mousePos.X, mousePos.Y)
        FOVCircle.Visible = true
    else
        FOVCircle.Visible = false
    end
end)



-- Lógica de voar
local flying, flyConnection = false, nil

local function startFlying()
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    local bodyGyro = Instance.new("BodyGyro", hrp)
    local bodyVelocity = Instance.new("BodyVelocity", hrp)
    bodyGyro.P = 9e4
    bodyGyro.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    bodyGyro.CFrame = hrp.CFrame
    bodyVelocity.MaxForce = Vector3.new(9e9, 9e9, 9e9)

    flyConnection = RunService.RenderStepped:Connect(function()
        local moveVec = Vector3.zero
        local camCF = camera.CFrame
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveVec += camCF.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveVec -= camCF.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveVec -= camCF.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveVec += camCF.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then moveVec += camCF.UpVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then moveVec -= camCF.UpVector end
        bodyVelocity.Velocity = moveVec.Magnitude > 0 and moveVec.Unit * flySpeed or Vector3.zero
        bodyGyro.CFrame = camCF
    end)
end

local function stopFlying()
    if flyConnection then flyConnection:Disconnect() end
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        for _, v in pairs(hrp:GetChildren()) do
            if v:IsA("BodyGyro") or v:IsA("BodyVelocity") then v:Destroy() end
        end
    end
end

local function toggleFly(state)
    flying = state
    if flying then startFlying() else stopFlying() end
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    if input.KeyCode == Enum.KeyCode.Q then
        toggleFly(not flying)
    end
end)

RunService.RenderStepped:Connect(function()
    for npc, visuals in pairs(npcBoxes) do
        local box = visuals.box
        local name = visuals.name

        if npc and npc:FindFirstChild("HumanoidRootPart") then
            local hrp = npc.HumanoidRootPart
            local size = Vector2.new(60, 80)
            local screenPos, onScreen = camera:WorldToViewportPoint(hrp.Position)

            if onScreen then
                box.Position = Vector2.new(screenPos.X - size.X / 2, screenPos.Y - size.Y / 2)
                box.Size = size
                box.Visible = true

                name.Position = Vector2.new(screenPos.X, screenPos.Y - size.Y / 2 - 15)
                name.Visible = true
            else
                box.Visible = false
                name.Visible = false
            end
        else
            box:Remove()
            name:Remove()
            npcBoxes[npc] = nil
        end
    end
end)

-- Variável de velocidade de caminhada
local currentSpeed = 16

-- Aplicar velocidade ao personagem
local function setWalkSpeed(speed)
    currentSpeed = speed
    local character = LocalPlayer.Character
    if character and character:FindFirstChildOfClass("Humanoid") then
        character:FindFirstChildOfClass("Humanoid").WalkSpeed = speed
    end
end

-- Atualizar velocidade quando o personagem renascer
LocalPlayer.CharacterAdded:Connect(function(char)
    task.spawn(function()
        local humanoid = char:WaitForChild("Humanoid", 5)
        if humanoid then
            humanoid.WalkSpeed = currentSpeed
        end
    end)
end)

-- Vida infinita + sem dano queda + NoClip + Fullbright + etc.
local function setupInfiniteHealth(character)
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    if not humanoid then return end
    humanoid.Health = humanoid.MaxHealth
    humanoid.HealthChanged:Connect(function()
        if (InfiniteHealthEnabled or NoFallDamageEnabled) and humanoid.Health < humanoid.MaxHealth then
            humanoid.Health = humanoid.MaxHealth
        end
    end)
end
LocalPlayer.CharacterAdded:Connect(setupInfiniteHealth)
if LocalPlayer.Character then setupInfiniteHealth(LocalPlayer.Character) end
RunService.Heartbeat:Connect(function()
    if LocalPlayer.Character then
        local h = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if h then
            if (InfiniteHealthEnabled or NoFallDamageEnabled) and h.Health < h.MaxHealth then h.Health = h.MaxHealth end
            if InfiniteJumpEnabled then h.JumpPower = JumpPowerValue; h.UseJumpPower = true end
            if InfiniteOxygenEnabled and h:GetAttribute and h:GetAttribute("Oxygen") ~= nil then h:SetAttribute("Oxygen", 100) end
            if h.Parent and h.Parent:FindFirstChild("HumanoidRootPart") then
                local hrp = h.Parent.HumanoidRootPart
                if NoClipEnabled then hrp.CanCollide = false else hrp.CanCollide = true end
            end
        end
    end
    if FullbrightEnabled then Lighting.Ambient = Color3.new(1,1,1); Lighting.Brightness = 2; Lighting.ClockTime = 14 end
    if NightVisionEnabled then Lighting.Ambient = Color3.fromRGB(80,100,80); Lighting.Brightness = 1.5 end
    if not FullbrightEnabled and not NightVisionEnabled and defaultAmbientB then Lighting.Ambient = defaultAmbientB; Lighting.Brightness = defaultBrightnessB or 1 end
    if workspace.Gravity ~= defaultGravityB and GravityValue == defaultGravityB then workspace.Gravity = defaultGravityB end
    if GravityValue ~= defaultGravityB then workspace.Gravity = GravityValue end
    if AutoSprintEnabled and LocalPlayer.Character then local h = LocalPlayer.Character:FindFirstChildOfClass("Humanoid"); if h then h.WalkSpeed = 32 end end
    if InvisibleEnabled and LocalPlayer.Character then for _, p in pairs(LocalPlayer.Character:GetDescendants()) do if p:IsA("BasePart") then p.Transparency = 1 end end
    elseif LocalPlayer.Character then for _, p in pairs(LocalPlayer.Character:GetDescendants()) do if p:IsA("BasePart") and p.Name ~= "HumanoidRootPart" then p.Transparency = 0 end end end
    if InfiniteDurabilityEnabled and LocalPlayer.Character then for _, t in pairs(LocalPlayer.Character:GetChildren()) do if t:IsA("Tool") then local d = t:FindFirstChild("Durability") or t:FindFirstChild("Uses"); if d and d:IsA("NumberValue") then d.Value = 999 end end end end
    if NoScreenEffectsEnabled then for _, e in pairs(Lighting:GetChildren()) do if e:IsA("BlurEffect") or e:IsA("DepthOfFieldEffect") then e.Enabled = false end end end
    if WalkOnWaterEnabled and LocalPlayer.Character then local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart"); if hrp then local ray = workspace:Raycast(hrp.Position, Vector3.new(0,-50,0)); if ray and ray.Instance and (ray.Instance.Name:lower():find("water") or (ray.Instance:GetAttribute and ray.Instance:GetAttribute("Water"))) then hrp.CFrame = hrp.CFrame + Vector3.new(0,0.3,0) end end end
end)
LocalPlayer.CharacterAdded:Connect(function() if NoClipEnabled and LocalPlayer.Character then task.defer(function() local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart"); if hrp then hrp.CanCollide = false end end) end end)

-- Auto kill mobs (com indetectável)
task.spawn(function()
    while true do
        if AutoKillMobsEnabled and not panicEnabled then
            local char = LocalPlayer.Character
            local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp then
                local myPos = hrp.Position
                local closestMob, closestDist = nil, math.huge
                for _, obj in ipairs(workspace:GetDescendants()) do
                    if table.find(AimbotTargets, obj.Name) and obj:IsA("Model") then
                        local mobHrp = obj:FindFirstChild("HumanoidRootPart")
                        local head = obj:FindFirstChild("Head")
                        if mobHrp and head then
                            local dist = (mobHrp.Position - myPos).Magnitude
                            if dist <= AutoKillMobsRadius and dist < closestDist then
                                closestDist = dist
                                closestMob = obj
                            end
                        end
                    end
                end
                if closestMob then
                    local head = closestMob:FindFirstChild("Head")
                    if head then
                        camera.CFrame = CFrame.new(camera.CFrame.Position, head.Position)
                        mouse1click()
                    end
                end
            end
        end
        local delay = 0.25
        if IndetectavelEnabled or SafeModeEnabled then delay = 0.25 + math.random() * 0.5 end
        task.wait(delay)
    end
end)

-- FOV
RunService.RenderStepped:Connect(function() camera.FieldOfView = FOVValue end)

-- Anti-AFK
task.spawn(function()
    while true do
        if AntiAFKEnabled and not panicEnabled then VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.W, false, game); task.wait(0.05); VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.W, false, game) end
        task.wait(IndetectavelEnabled and 25 + math.random(10) or 30)
    end
end)

-- Auto coletar
task.spawn(function()
    while true do
        if AutoCollectEnabled and LocalPlayer.Character and not panicEnabled then
            local hrp = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                for _, obj in pairs(workspace:GetDescendants()) do
                    if table.find(teleportTargets, obj.Name) and obj:IsA("Model") then
                        local part = obj:FindFirstChildWhichIsA("BasePart")
                        if part and (part.Position - hrp.Position).Magnitude < 12 then VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game); task.wait(0.1); VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game); break end
                    end
                end
            end
        end
        task.wait(0.5)
    end
end)

UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.Space and InfiniteJumpEnabled and LocalPlayer.Character then
        local h = LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if h and (h:GetState() == Enum.HumanoidStateType.Freefall or h:GetState() == Enum.HumanoidStateType.Landed) then h.Jump = true end
    end
end)

-- Freecam
RunService.RenderStepped:Connect(function()
    if FreecamEnabled and LocalPlayer.Character then
        if camera.CameraSubject then FreecamPos = camera.CFrame.Position; camera.CameraSubject = nil end
        local move = Vector3.zero
        local cam = camera.CFrame
        if UserInputService:IsKeyDown(Enum.KeyCode.W) then move += cam.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.S) then move -= cam.LookVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.A) then move -= cam.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.D) then move += cam.RightVector end
        if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.new(0,1,0) end
        if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then move -= Vector3.new(0,1,0) end
        FreecamPos = FreecamPos + move * 1.2
        camera.CFrame = CFrame.new(FreecamPos, FreecamPos + cam.LookVector)
    elseif camera.CameraSubject == nil then camera.CameraSubject = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") end
end
end)

-- Coordenadas e FPS
coordsTextB = Drawing.new("Text"); coordsTextB.Size = 16; coordsTextB.Center = true; coordsTextB.Outline = true; coordsTextB.Color = Color3.new(1,1,1); coordsTextB.Visible = false
fpsTextB = Drawing.new("Text"); fpsTextB.Size = 16; fpsTextB.Center = true; fpsTextB.Outline = true; fpsTextB.Color = Color3.new(0,1,0); fpsTextB.Position = Vector2.new(100,50); fpsTextB.Visible = false
local lastTimeB, framesB = tick(), 0
RunService.RenderStepped:Connect(function()
    if coordsTextB and ShowCoordinatesEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then local p = LocalPlayer.Character.HumanoidRootPart.Position; coordsTextB.Text = string.format("X: %.0f Y: %.0f Z: %.0f", p.X, p.Y, p.Z); coordsTextB.Position = Vector2.new(camera.ViewportSize.X/2, camera.ViewportSize.Y-40); coordsTextB.Visible = true else if coordsTextB then coordsTextB.Visible = false end end
    if fpsTextB then framesB = framesB + 1; if tick() - lastTimeB >= 1 then fpsTextB.Text = "FPS: " .. framesB; framesB = 0; lastTimeB = tick() end; fpsTextB.Visible = ShowFPSEnabled end
end)

-- Tecla de pânico (End)
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == Enum.KeyCode.End then
        panicEnabled = true
        IndetectavelEnabled = false; NoFallDamageEnabled = false; FullbrightEnabled = false; NoClipEnabled = false; AutoCollectEnabled = false; AntiAFKEnabled = false; InfiniteJumpEnabled = false; NightVisionEnabled = false; ItemMagnetEnabled = false; InfiniteDurabilityEnabled = false; FreecamEnabled = false; InvisibleEnabled = false; NoRecoilEnabled = false; AutoSprintEnabled = false; InfiniteOxygenEnabled = false; SafeModeEnabled = false; MobNotifyEnabled = false; NoScreenEffectsEnabled = false; AutoKillMobsEnabled = false; AimbotEnabled = false
        if flying then toggleFly(false) end
        camera.CameraSubject = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid")
        Rayfield:Notify({ Title = "Pânico", Content = "Todas as opções desativadas.", Duration = 3, Image = 4483362458 })
        task.delay(2, function() panicEnabled = false end)
    end
end)

-- Abas da interface
local HomeTab = Window:CreateTab("🏠Início🏠", 4483362458)

HomeTab:CreateButton({
    Name = "Teletransportar para Fogueira",
    Callback = function()
        LocalPlayer.Character:PivotTo(CFrame.new(0, 10, 0))
    end
})

HomeTab:CreateButton({
    Name = "Teletransportar para Moedor",
    Callback = function()
        LocalPlayer.Character:PivotTo(CFrame.new(16.1,4,-4.6))
    end
})

-- Controle de velocidade
HomeTab:CreateSlider({
    Name = "Velocidade (Speedhack)",
    Range = {16, 100},
    Increment = 1,
    Suffix = "Velocidade",
    CurrentValue = 16,
    Callback = setWalkSpeed
})

HomeTab:CreateToggle({
    Name = "ESP de Itens",
    CurrentValue = false,
    Callback = toggleESP
})

HomeTab:CreateToggle({
    Name = "ESP de NPCs",
    CurrentValue = false,
    Callback = function(value)
        toggleNPCESP(value)
        Rayfield:Notify({
            Title = "ESP de NPCs",
            Content = value and "ESP de NPCs ativado." or "ESP de NPCs desativado.",
            Duration = 4,
            Image = 4483362458,
        })
    end
})

HomeTab:CreateToggle({
    Name = "Farm automático de árvores (árvore pequena)",
    CurrentValue = false,
    Callback = function(value)
        AutoTreeFarmEnabled = value
    end
})

HomeTab:CreateToggle({
    Name = "Farm automático de troncos",
    CurrentValue = false,
    Callback = function(value)
        AutoLogFarmEnabled = value
        Rayfield:Notify({Title="Farm de troncos", Content=value and "Ativado" or "Desativado", Duration=3})
    end
})


HomeTab:CreateToggle({
    Name = "Aimbot (clique direito)",
    CurrentValue = false,
    Callback = function(value)
        AimbotEnabled = value
        Rayfield:Notify({
            Title = "Aimbot",
            Content = value and "Ativado - segure o botão direito para mirar." or "Desativado.",
            Duration = 4,
            Image = 4483362458,
        })
    end
})

HomeTab:CreateToggle({
    Name = "Voar (WASD + Espaço + Shift)",
    CurrentValue = false,
    Callback = function(value)
        toggleFly(value)
        Rayfield:Notify({
            Title = "Voar",
            Content = value and "Voar ativado." or "Voar desativado.",
            Duration = 4,
            Image = 4483362458,
        })
    end
})

HomeTab:CreateToggle({
    Name = "Vida infinita",
    CurrentValue = false,
    Callback = function(value)
        InfiniteHealthEnabled = value
        Rayfield:Notify({
            Title = "Vida infinita",
            Content = value and "Ativado - sua vida não diminui." or "Desativado.",
            Duration = 4,
            Image = 4483362458,
        })
    end
})

HomeTab:CreateToggle({
    Name = "Auto kill mobs (ao redor)",
    CurrentValue = false,
    Callback = function(value)
        AutoKillMobsEnabled = value
        Rayfield:Notify({
            Title = "Auto kill mobs",
            Content = value and "Ativado - equipa uma arma e mata inimigos ao redor." or "Desativado.",
            Duration = 4,
            Image = 4483362458,
        })
    end
})

HomeTab:CreateSlider({ Name = "Raio do auto kill (studs)", Range = {15, 150}, Increment = 5, Suffix = "studs", CurrentValue = 50, Callback = function(v) AutoKillMobsRadius = v end })

-- Aba Proteção (Antiban)
local ProtecTabB = Window:CreateTab("🛡️Proteção (Antiban)🛡️", 4483362458)
ProtecTabB:CreateToggle({ Name = "Indetectável / Antiban", CurrentValue = false, Callback = function(v) IndetectavelEnabled = v; Rayfield:Notify({ Title = "Antiban", Content = v and "Ativado - delays aleatórios." or "Desativado.", Duration = 3, Image = 4483362458 }) end })
ProtecTabB:CreateToggle({ Name = "Modo seguro (menos ações)", CurrentValue = false, Callback = function(v) SafeModeEnabled = v end })
ProtecTabB:CreateButton({ Name = "Tecla de pânico: END", Callback = function() Rayfield:Notify({ Title = "Tecla de pânico", Content = "Pressione END para desativar tudo.", Duration = 5, Image = 4483362458 }) end })

-- Aba Movimento
local MovTabB = Window:CreateTab("🏃Movimento🏃", 4483362458)
MovTabB:CreateToggle({ Name = "Sem dano de queda", CurrentValue = false, Callback = function(v) NoFallDamageEnabled = v end })
MovTabB:CreateToggle({ Name = "No clip (atravessar paredes)", CurrentValue = false, Callback = function(v) NoClipEnabled = v end })
MovTabB:CreateToggle({ Name = "Pulo infinito", CurrentValue = false, Callback = function(v) InfiniteJumpEnabled = v end })
MovTabB:CreateToggle({ Name = "Sprint sempre", CurrentValue = false, Callback = function(v) AutoSprintEnabled = v end })
MovTabB:CreateSlider({ Name = "Velocidade do voar", Range = {20, 200}, Increment = 5, Suffix = "", CurrentValue = 60, Callback = function(v) flySpeed = v end })
MovTabB:CreateSlider({ Name = "Força do pulo", Range = {30, 100}, Increment = 5, Suffix = "", CurrentValue = 50, Callback = function(v) JumpPowerValue = v end })
MovTabB:CreateSlider({ Name = "Gravidade", Range = {0, 300}, Increment = 10, Suffix = "", CurrentValue = 196, Callback = function(v) GravityValue = v end })

-- Aba Visão
local VisaoTabB = Window:CreateTab("👁️Visão👁️", 4483362458)
VisaoTabB:CreateToggle({ Name = "Fullbright (luz máxima)", CurrentValue = false, Callback = function(v) FullbrightEnabled = v end })
VisaoTabB:CreateToggle({ Name = "Visão noturna", CurrentValue = false, Callback = function(v) NightVisionEnabled = v end })
VisaoTabB:CreateSlider({ Name = "FOV (campo de visão)", Range = {60, 120}, Increment = 5, Suffix = "", CurrentValue = 70, Callback = function(v) FOVValue = v end })
VisaoTabB:CreateToggle({ Name = "Sem efeitos de tela (blur)", CurrentValue = false, Callback = function(v) NoScreenEffectsEnabled = v end })
VisaoTabB:CreateToggle({ Name = "Câmera livre (freecam)", CurrentValue = false, Callback = function(v) FreecamEnabled = v; if v then FreecamPos = camera.CFrame.Position end end })

-- Aba Extras
local ExtrasTabB = Window:CreateTab("✨Extras✨", 4483362458)
ExtrasTabB:CreateToggle({ Name = "Auto coletar (perto de itens)", CurrentValue = false, Callback = function(v) AutoCollectEnabled = v end })
ExtrasTabB:CreateToggle({ Name = "Anti-AFK (não ser kickado)", CurrentValue = false, Callback = function(v) AntiAFKEnabled = v end })
ExtrasTabB:CreateToggle({ Name = "Durabilidade infinita (ferramentas)", CurrentValue = false, Callback = function(v) InfiniteDurabilityEnabled = v end })
ExtrasTabB:CreateToggle({ Name = "Oxigênio infinito (debaixo d'água)", CurrentValue = false, Callback = function(v) InfiniteOxygenEnabled = v end })
ExtrasTabB:CreateToggle({ Name = "Personagem invisível", CurrentValue = false, Callback = function(v) InvisibleEnabled = v end })
ExtrasTabB:CreateToggle({ Name = "Mostrar coordenadas", CurrentValue = false, Callback = function(v) ShowCoordinatesEnabled = v end })
ExtrasTabB:CreateToggle({ Name = "Mostrar FPS", CurrentValue = false, Callback = function(v) ShowFPSEnabled = v end })
ExtrasTabB:CreateToggle({ Name = "Notificação quando mob perto", CurrentValue = false, Callback = function(v) MobNotifyEnabled = v end })
ExtrasTabB:CreateToggle({ Name = "Ímã de itens (client)", CurrentValue = false, Callback = function(v) ItemMagnetEnabled = v end })
ExtrasTabB:CreateToggle({ Name = "Andar na água (experimental)", CurrentValue = false, Callback = function(v) WalkOnWaterEnabled = v end })
ExtrasTabB:CreateToggle({ Name = "Sem recuo (armas)", CurrentValue = false, Callback = function(v) NoRecoilEnabled = v end })

-- Notificação mob perto (Beta)
task.spawn(function()
    while true do
        if MobNotifyEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local myPos = LocalPlayer.Character.HumanoidRootPart.Position
            for _, obj in ipairs(workspace:GetDescendants()) do
                if table.find(AimbotTargets, obj.Name) and obj:IsA("Model") then
                    local hrp = obj:FindFirstChild("HumanoidRootPart")
                    if hrp then local dist = (hrp.Position - myPos).Magnitude; if dist < 25 and (not MobNotifyCooldown[obj] or tick() - MobNotifyCooldown[obj] > 10) then MobNotifyCooldown[obj] = tick(); Rayfield:Notify({ Title = "Mob perto!", Content = obj.Name .. " a " .. math.floor(dist) .. " studs", Duration = 2, Image = 4483362458 }) end end
                end
            end
        end
        task.wait(1)
    end
end)

-- Variáveis do teletransporte anti-morte
local AntiDeathEnabled = false
local AntiDeathRadius = 50
local AntiDeathTargets = {
    Alien = true,
    ["Alpha Wolf"] = true,
    Wolf = true,
    ["Crossbow Cultist"] = true,
    Cultist = true,
    Bear = true,
}

-- Círculo visual do raio de detecção
local detectionCircle = Instance.new("Part")
detectionCircle.Name = "AntiDeathCircle"
detectionCircle.Anchored = true
detectionCircle.CanCollide = false
detectionCircle.Transparency = 0.7
detectionCircle.Material = Enum.Material.Neon
detectionCircle.Color = Color3.fromRGB(255, 0, 0)
detectionCircle.Parent = workspace

local mesh = Instance.new("SpecialMesh", detectionCircle)
mesh.MeshType = Enum.MeshType.Cylinder
mesh.Scale = Vector3.new(AntiDeathRadius * 2, 0.2, AntiDeathRadius * 2)

-- Atualizar posição e tamanho do círculo de detecção
local function updateDetectionCircle()
    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        detectionCircle.Position = Vector3.new(hrp.Position.X, hrp.Position.Y - 3, hrp.Position.Z)
        mesh.Scale = Vector3.new(AntiDeathRadius * 2, 0.2, AntiDeathRadius * 2)
        detectionCircle.Transparency = AntiDeathEnabled and 0.5 or 1
    else
        detectionCircle.Transparency = 1
    end
end

RunService.RenderStepped:Connect(function()
    updateDetectionCircle()
end)

-- Lógica do teletransporte anti-morte
task.spawn(function()
    while true do
        if AntiDeathEnabled then
            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then
                local pos = hrp.Position
                for _, npc in ipairs(workspace:GetDescendants()) do
                    if npc:IsA("Model") and npc:FindFirstChild("HumanoidRootPart") and AntiDeathTargets[npc.Name] then
                        local npcPos = npc.HumanoidRootPart.Position
                        if (npcPos - pos).Magnitude <= AntiDeathRadius then
                            -- Teletransportar imediatamente para lugar seguro
                            LocalPlayer.Character:PivotTo(CFrame.new(0, 10, 0))
                            break
                        end
                    end
                end
            end
        end
        task.wait(0.2)
    end
end)


-- Alternar anti-morte na aba Início
HomeTab:CreateToggle({
    Name = "Anti-morte (teletransporte)",
    CurrentValue = false,
    Callback = function(value)
        AntiDeathEnabled = value
        Rayfield:Notify({
            Title = "Anti-morte",
            Content = value and "Ativado" or "Desativado",
            Duration = 4,
            Image = 4483362458,
        })
    end
})

-- Aba Teletransporte
local TeleTab = Window:CreateTab("🧲Teletransporte🧲", 4483362458)
for _, itemName in ipairs(teleportTargets) do
    TeleTab:CreateButton({
        Name = "Ir para " .. itemName,
        Callback = function()
            local closest, shortest = nil, math.huge
            for _, obj in pairs(workspace:GetDescendants()) do
                if obj.Name == itemName and obj:IsA("Model") then
                    local cf = nil
                    if pcall(function() cf = obj:GetPivot() end) then
                        -- success
                    else
                        local part = obj:FindFirstChildWhichIsA("BasePart")
                        if part then cf = part.CFrame end
                    end
                    if cf then
                        local dist = (cf.Position - ignoreDistanceFrom).Magnitude
                        if dist >= minDistance and dist < shortest then
                            closest = obj
                            shortest = dist
                        end
                    end
                end
            end
            if closest then
                local cf = nil
                if pcall(function() cf = closest:GetPivot() end) then
                    -- success
                else
                    local part = closest:FindFirstChildWhichIsA("BasePart")
                    if part then cf = part.CFrame end
                end
                if cf then
                    LocalPlayer.Character:PivotTo(cf + Vector3.new(0, 5, 0))
                else
                    Rayfield:Notify({
                        Title = "Teletransporte falhou",
                        Content = "Não foi possível encontrar uma posição válida.",
                        Duration = 5,
                        Image = 4483362458,
                    })
                end
            else
                Rayfield:Notify({
                    Title = "Item não encontrado",
                    Content = itemName .. " não encontrado ou muito perto da origem.",
                    Duration = 5,
                    Image = 4483362458,
                })
            end
        end
    })
end


local LogTab = Window:CreateTab("🌳Farm de Troncos🌳", 4483362458)
local LogBagType = "Old Sack" -- "Old Sack", "Good Sack", ou "Auto"
local OldSackToggle = nil
local GoodSackToggle = nil

OldSackToggle = LogTab:CreateToggle({
    Name = "Usar saco velho (5 troncos)",
    CurrentValue = false,
    Callback = function(value)
        if value then
            LogBagType = "Old Sack"
            if GoodSackToggle then GoodSackToggle.Set(false) end
        else
            if LogBagType == "Old Sack" then LogBagType = "Auto" end
        end
    end
})

GoodSackToggle = LogTab:CreateToggle({
    Name = "Usar saco bom (15 troncos)",
    CurrentValue = false,
    Callback = function(value)
        if value then
            LogBagType = "Good Sack"
            if OldSackToggle then OldSackToggle.Set(false) end
        else
            if LogBagType == "Good Sack" then LogBagType = "Auto" end
        end
    end
})



-- Aba Anti-morte
local AntiDeathTab = Window:CreateTab("🛡️Anti-morte🛡️", 4483362458)

-- Controle do raio
AntiDeathTab:CreateSlider({
    Name = "Raio de detecção",
    Range = {10, 150},
    Increment = 1,
    Suffix = "Studs",
    CurrentValue = AntiDeathRadius,
    Callback = function(value)
        AntiDeathRadius = value
        updateDetectionCircle()
    end
})

-- Alternar NPCs a evitar
for npcName, _ in pairs(AntiDeathTargets) do
    AntiDeathTab:CreateToggle({
        Name = "Evitar " .. npcName,
        CurrentValue = true,
        Callback = function(value)
            AntiDeathTargets[npcName] = value
        end
    })
end

-- Guardar valores padrão da neblina para restaurar depois
local defaultFogStart = game.Lighting.FogStart
local defaultFogEnd = game.Lighting.FogEnd

local fogEnabled = false

HomeTab:CreateToggle({
    Name = "Sem neblina (céu limpo)",
    CurrentValue = false,
    Callback = function(value)
        fogEnabled = value
        if fogEnabled then
            game.Lighting.FogStart = 999999
            game.Lighting.FogEnd = 1000000
        else
            game.Lighting.FogStart = defaultFogStart
            game.Lighting.FogEnd = defaultFogEnd
        end
        Rayfield:Notify({
            Title = "Neblina",
            Content = fogEnabled and "Neblina desativada." or "Neblina restaurada.",
            Duration = 3,
            Image = 4483362458,
        })
    end
})
