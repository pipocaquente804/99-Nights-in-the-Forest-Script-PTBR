--// Script 99 Noites na Floresta com Rayfield GUI //--

-- Carregar biblioteca Rayfield UI
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Serviços
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local camera = workspace.CurrentCamera

-- Configuração da janela
local Window = Rayfield:CreateWindow({
    Name = "99 Noites",
    LoadingTitle = "Script 99 Noites",
    LoadingSubtitle = "por Raygull",
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
local speed = 60

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
        bodyVelocity.Velocity = moveVec.Magnitude > 0 and moveVec.Unit * speed or Vector3.zero
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
