-- 🪐 Steal Brainrot GUI - Chargement depuis Github
-- Créé avec Rayfield UI Library
-- Compatible tous executeurs Roblox

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "🪐 Steal Brainrot GUI",
   LoadingTitle = "Chargement Steal Brainrot",
   LoadingSubtitle = "par GlamgarOnDiscord",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "StealBrainrotConfig",
      FileName = "config"
   },
   Discord = {
      Enabled = false,
      Invite = "noinvitelink",
      RememberJoins = true
   },
   KeySystem = false
})

-- Variables de contrôle
local AutoBuy = false
local AutoSteal = false
local AutoCollect = false
local AutoFarm = false
local WalkSpeed = 16
local JumpPower = 50
local DebugMode = true
local ObjectExplorer = false

-- Services Roblox
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

-- 🔍 FONCTIONS DE DEBUG
local function DebugLog(message, level)
    if not DebugMode then return end
    local prefix = "🪐 DEBUG"
    if level == "warn" then
        prefix = "⚠️ WARN"
        warn(prefix .. ": " .. tostring(message))
    elseif level == "error" then
        prefix = "❌ ERROR"
        error(prefix .. ": " .. tostring(message))
    else
        print(prefix .. ": " .. tostring(message))
    end
end

-- Explorer tous les objets du workspace
local function ExploreWorkspace()
    DebugLog("=== EXPLORATION DU WORKSPACE ===")
    local objectCount = 0
    local interactiveObjects = {}
    
    for _, obj in pairs(workspace:GetDescendants()) do
        objectCount = objectCount + 1
        
        -- Objets avec ProximityPrompt (achetables/interactifs)
        if obj:FindFirstChild("ProximityPrompt") then
            table.insert(interactiveObjects, obj)
            DebugLog("🛒 OBJET INTERACTIF: " .. obj.Name .. " | Parent: " .. obj.Parent.Name .. " | Position: " .. tostring(obj.Position))
        end
        
        -- Objets monnaie/collectibles
        if obj.Name:find("Coin") or obj.Name:find("Cash") or obj.Name:find("Money") or obj.Name:find("Brainrot") or obj.Name:find("Dollar") then
            DebugLog("💰 COLLECTIBLE: " .. obj.Name .. " | Type: " .. obj.ClassName .. " | Parent: " .. obj.Parent.Name)
        end
        
        -- Shops/Magasins
        if obj.Name:find("Shop") or obj.Name:find("Buy") or obj.Name:find("Store") or obj.Name:find("Magasin") then
            DebugLog("🏪 SHOP: " .. obj.Name .. " | Type: " .. obj.ClassName .. " | Position: " .. tostring(obj.Position or "Pas de position"))
        end
    end
    
    DebugLog("Total objets scannés: " .. objectCount)
    DebugLog("Objets interactifs trouvés: " .. #interactiveObjects)
    return interactiveObjects
end

-- Explorer les RemoteEvents et RemoteFunctions
local function ExploreRemotes()
    DebugLog("=== EXPLORATION DES REMOTES ===")
    
    for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
        if remote:IsA("RemoteEvent") then
            DebugLog("📡 REMOTE EVENT: " .. remote.Name .. " | Parent: " .. remote.Parent.Name)
        elseif remote:IsA("RemoteFunction") then
            DebugLog("📞 REMOTE FUNCTION: " .. remote.Name .. " | Parent: " .. remote.Parent.Name)
        end
    end
end

-- Explorer les joueurs et leurs personnages
local function ExplorePlayers()
    DebugLog("=== EXPLORATION DES JOUEURS ===")
    
    for _, otherPlayer in pairs(Players:GetPlayers()) do
        if otherPlayer ~= player then
            DebugLog("👤 JOUEUR: " .. otherPlayer.Name .. " | DisplayName: " .. otherPlayer.DisplayName)
            
            if otherPlayer.Character then
                local character = otherPlayer.Character
                local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
                
                if humanoidRootPart then
                    local distance = (rootPart.Position - humanoidRootPart.Position).Magnitude
                    DebugLog("  📍 Position: " .. tostring(humanoidRootPart.Position) .. " | Distance: " .. math.floor(distance))
                else
                    DebugLog("  ❌ Pas de HumanoidRootPart")
                end
                
                -- Chercher des objets importants sur le joueur
                for _, item in pairs(character:GetDescendants()) do
                    if item.Name:find("Cash") or item.Name:find("Money") or item.Name:find("Brainrot") then
                        DebugLog("  💰 ITEM SUR JOUEUR: " .. item.Name)
                    end
                end
            else
                DebugLog("  ❌ Pas de personnage")
            end
        end
    end
end

-- Analyser les objets autour du joueur
local function AnalyzeNearbyObjects(radius)
    radius = radius or 50
    DebugLog("=== ANALYSE OBJETS PROCHES (Rayon: " .. radius .. ") ===")
    
    local nearbyObjects = {}
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Part") or obj:IsA("MeshPart") then
            local distance = (rootPart.Position - obj.Position).Magnitude
            if distance <= radius then
                table.insert(nearbyObjects, {object = obj, distance = distance})
            end
        end
    end
    
    -- Trier par distance
    table.sort(nearbyObjects, function(a, b) return a.distance < b.distance end)
    
    for i, data in ipairs(nearbyObjects) do
        if i <= 10 then -- Afficher seulement les 10 plus proches
            local obj = data.object
            DebugLog("📍 OBJET PROCHE: " .. obj.Name .. " | Distance: " .. math.floor(data.distance) .. " | Type: " .. obj.ClassName)
        end
    end
end

-- Fonction de téléportation sécurisée
local function SafeTeleport(position)
    if character and rootPart then
        rootPart.CFrame = CFrame.new(position)
    end
end

-- Fonction pour trouver les objets par nom
local function FindItemByName(name, searchIn)
    searchIn = searchIn or workspace
    for _, item in pairs(searchIn:GetDescendants()) do
        if item.Name:lower():find(name:lower()) then
            return item
        end
    end
    return nil
end

-- Fonction pour auto-collect items
local function AutoCollectItems()
    DebugLog("🚜 AUTO COLLECT DÉMARRÉ")
    local collectCount = 0
    
    while AutoCollect do
        local itemsFound = 0
        local itemsCollected = 0
        
        for _, item in pairs(workspace:GetDescendants()) do
            if item.Name:find("Coin") or item.Name:find("Cash") or item.Name:find("Money") or item.Name:find("Brainrot") or item.Name:find("Dollar") then
                itemsFound = itemsFound + 1
                DebugLog("💰 ITEM TROUVÉ: " .. item.Name .. " | Type: " .. item.ClassName .. " | Parent: " .. item.Parent.Name)
                
                local part = item:FindFirstChild("Handle") or item:FindFirstChild("Part") or item
                if part and part:IsA("BasePart") then
                    local distance = (rootPart.Position - part.Position).Magnitude
                    DebugLog("  📍 Distance: " .. math.floor(distance) .. " studs")
                    
                    if distance < 50 then
                        DebugLog("  ✅ TÉLÉPORTATION vers: " .. tostring(part.Position))
                        SafeTeleport(part.Position)
                        itemsCollected = itemsCollected + 1
                        collectCount = collectCount + 1
                        wait(0.1)
                    else
                        DebugLog("  ❌ Trop loin (" .. math.floor(distance) .. " > 50)")
                    end
                else
                    DebugLog("  ❌ Pas de partie collectible trouvée", "warn")
                end
            end
        end
        
        DebugLog("📊 BILAN COLLECT: " .. itemsFound .. " trouvés, " .. itemsCollected .. " collectés (Total: " .. collectCount .. ")")
        wait(0.5)
    end
    
    DebugLog("🛑 AUTO COLLECT ARRÊTÉ")
end

-- Fonction pour auto-steal
local function AutoStealFunction()
    DebugLog("💰 AUTO STEAL DÉMARRÉ")
    local stealAttempts = 0
    
    while AutoSteal do
        local playersFound = 0
        local stealTargets = 0
        
        DebugLog("🔍 Recherche de cibles à voler...")
        
        for _, otherPlayer in pairs(Players:GetPlayers()) do
            if otherPlayer ~= player and otherPlayer.Character then
                playersFound = playersFound + 1
                local otherRoot = otherPlayer.Character:FindFirstChild("HumanoidRootPart")
                
                if otherRoot then
                    local distance = (rootPart.Position - otherRoot.Position).Magnitude
                    DebugLog("👤 JOUEUR: " .. otherPlayer.Name .. " | Distance: " .. math.floor(distance) .. " studs")
                    
                    if distance < 20 then
                        stealTargets = stealTargets + 1
                        DebugLog("  🎯 CIBLE VALIDE: " .. otherPlayer.Name .. " (Distance: " .. math.floor(distance) .. ")")
                        
                        -- Chercher les RemoteEvents de vol
                        local stealEvents = {}
                        for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
                            if remote:IsA("RemoteEvent") and (remote.Name:find("Steal") or remote.Name:find("Rob") or remote.Name:find("Take")) then
                                table.insert(stealEvents, remote)
                                DebugLog("    📡 EVENT TROUVÉ: " .. remote.Name)
                            end
                        end
                        
                        if #stealEvents > 0 then
                            for _, stealEvent in pairs(stealEvents) do
                                DebugLog("    🔥 TENTATIVE DE VOL via: " .. stealEvent.Name)
                                stealEvent:FireServer(otherPlayer)
                                stealAttempts = stealAttempts + 1
                            end
                        else
                            DebugLog("    ❌ Aucun RemoteEvent de vol trouvé", "warn")
                        end
                    else
                        DebugLog("  ❌ Trop loin: " .. otherPlayer.Name .. " (" .. math.floor(distance) .. " > 20)")
                    end
                else
                    DebugLog("  ❌ Pas de HumanoidRootPart: " .. otherPlayer.Name, "warn")
                end
            end
        end
        
        DebugLog("📊 BILAN STEAL: " .. playersFound .. " joueurs, " .. stealTargets .. " cibles, " .. stealAttempts .. " tentatives totales")
        wait(1)
    end
    
    DebugLog("🛑 AUTO STEAL ARRÊTÉ")
end

-- Fonction pour auto-buy
local function AutoBuyFunction()
    DebugLog("🛒 AUTO BUY DÉMARRÉ")
    local buyAttempts = 0
    
    while AutoBuy do
        local shopsFound = 0
        local buyableItems = 0
        
        DebugLog("🔍 Recherche de magasins et objets achetables...")
        
        for _, obj in pairs(workspace:GetDescendants()) do
            -- Chercher par nom de shop
            if obj.Name:find("Shop") or obj.Name:find("Buy") or obj.Name:find("Store") or obj.Name:find("Magasin") then
                shopsFound = shopsFound + 1
                DebugLog("🏪 SHOP TROUVÉ: " .. obj.Name .. " | Type: " .. obj.ClassName .. " | Parent: " .. obj.Parent.Name)
                
                if obj:IsA("BasePart") and obj.Position then
                    local distance = (rootPart.Position - obj.Position).Magnitude
                    DebugLog("  📍 Distance: " .. math.floor(distance) .. " studs")
                end
            end
            
            -- Chercher les ProximityPrompts (objets achetables)
            if obj:IsA("ProximityPrompt") then
                buyableItems = buyableItems + 1
                local parent = obj.Parent
                DebugLog("🛒 PROMPT TROUVÉ: " .. obj.Name .. " | Parent: " .. parent.Name .. " | ActionText: " .. (obj.ActionText or "N/A"))
                
                if parent:IsA("BasePart") and parent.Position then
                    local distance = (rootPart.Position - parent.Position).Magnitude
                    DebugLog("  📍 Distance: " .. math.floor(distance) .. " studs | Enabled: " .. tostring(obj.Enabled))
                    
                    if distance < 10 and obj.Enabled then
                        DebugLog("  🔥 TENTATIVE D'ACHAT: " .. parent.Name)
                        fireproximityprompt(obj)
                        buyAttempts = buyAttempts + 1
                        wait(0.5)
                    elseif distance >= 10 then
                        DebugLog("  ❌ Trop loin (" .. math.floor(distance) .. " > 10)")
                    elseif not obj.Enabled then
                        DebugLog("  ❌ Prompt désactivé")
                    end
                else
                    DebugLog("  ❌ Parent n'est pas une BasePart ou pas de position", "warn")
                end
            end
        end
        
        DebugLog("📊 BILAN BUY: " .. shopsFound .. " shops, " .. buyableItems .. " prompts, " .. buyAttempts .. " achats tentés")
        wait(2)
    end
    
    DebugLog("🛑 AUTO BUY ARRÊTÉ")
end

-- Onglet Principal
local MainTab = Window:CreateTab("🏠 Principal", 4483362458)

-- Section Auto Farm
local AutoSection = MainTab:CreateSection("🤖 Automatisation")

local AutoFarmToggle = MainTab:CreateToggle({
   Name = "🚜 Auto Farm",
   CurrentValue = false,
   Flag = "AutoFarm",
   Callback = function(Value)
      AutoFarm = Value
      if Value then
         spawn(function()
            while AutoFarm do
               AutoCollectItems()
               wait(1)
            end
         end)
      end
   end,
})

local AutoStealToggle = MainTab:CreateToggle({
   Name = "💰 Auto Steal",
   CurrentValue = false,
   Flag = "AutoSteal",
   Callback = function(Value)
      AutoSteal = Value
      if Value then
         spawn(AutoStealFunction)
      end
   end,
})

local AutoBuyToggle = MainTab:CreateToggle({
   Name = "🛒 Auto Buy",
   CurrentValue = false,
   Flag = "AutoBuy",
   Callback = function(Value)
      AutoBuy = Value
      if Value then
         spawn(AutoBuyFunction)
      end
   end,
})

local AutoCollectToggle = MainTab:CreateToggle({
   Name = "💎 Auto Collect",
   CurrentValue = false,
   Flag = "AutoCollect",
   Callback = function(Value)
      AutoCollect = Value
      if Value then
         spawn(AutoCollectItems)
      end
   end,
})

-- Section Player
local PlayerSection = MainTab:CreateSection("👤 Joueur")

local WalkSpeedSlider = MainTab:CreateSlider({
   Name = "🏃 Vitesse de marche",
   Range = {16, 200},
   Increment = 1,
   Suffix = " Speed",
   CurrentValue = 16,
   Flag = "WalkSpeed",
   Callback = function(Value)
      WalkSpeed = Value
      if character and humanoid then
         humanoid.WalkSpeed = Value
      end
   end,
})

local JumpPowerSlider = MainTab:CreateSlider({
   Name = "🦘 Puissance de saut",
   Range = {50, 200},
   Increment = 1,
   Suffix = " Power",
   CurrentValue = 50,
   Flag = "JumpPower",
   Callback = function(Value)
      JumpPower = Value
      if character and humanoid then
         humanoid.JumpPower = Value
      end
   end,
})

-- Onglet Téléportation
local TeleportTab = Window:CreateTab("🌐 Téléportation", 4483362458)

local TeleportSection = TeleportTab:CreateSection("📍 Lieux importants")

local SpawnButton = TeleportTab:CreateButton({
   Name = "🏠 Spawn",
   Callback = function()
      SafeTeleport(Vector3.new(0, 10, 0))
   end,
})

local ShopButton = TeleportTab:CreateButton({
   Name = "🛒 Shop",
   Callback = function()
      local shop = FindItemByName("shop")
      if shop then
         SafeTeleport(shop.Position + Vector3.new(0, 5, 0))
      end
   end,
})

-- Onglet Utilitaires
local UtilsTab = Window:CreateTab("🔧 Utilitaires", 4483362458)

local UtilsSection = UtilsTab:CreateSection("⚙️ Outils")

local NoClipToggle = UtilsTab:CreateToggle({
   Name = "👻 NoClip",
   CurrentValue = false,
   Flag = "NoClip",
   Callback = function(Value)
      for _, part in pairs(character:GetDescendants()) do
         if part:IsA("BasePart") then
            part.CanCollide = not Value
         end
      end
   end,
})

local InfiniteJumpToggle = UtilsTab:CreateToggle({
   Name = "🚀 Saut infini",
   CurrentValue = false,
   Flag = "InfiniteJump",
   Callback = function(Value)
      if Value then
         UserInputService.JumpRequest:Connect(function()
            if character and humanoid then
               humanoid:ChangeState("Jumping")
            end
         end)
      end
   end,
})

-- Section Credits
local CreditsSection = UtilsTab:CreateSection("📝 Crédits")

local CreditsLabel = UtilsTab:CreateLabel("Créé avec Rayfield UI")
local VersionLabel = UtilsTab:CreateLabel("Version 1.0 - Github")
local AuthorLabel = UtilsTab:CreateLabel("by GlamgarOnDiscord")

-- 🔍 ONGLET DEBUG
local DebugTab = Window:CreateTab("🔍 Debug", 4483362458)

local DebugControlSection = DebugTab:CreateSection("⚙️ Contrôles Debug")

local DebugModeToggle = DebugTab:CreateToggle({
   Name = "🔍 Mode Debug",
   CurrentValue = true,
   Flag = "DebugMode",
   Callback = function(Value)
      DebugMode = Value
      if Value then
         DebugLog("✅ Mode Debug ACTIVÉ")
      else
         print("🔍 Mode Debug DÉSACTIVÉ")
      end
   end,
})

local ExploreButton = DebugTab:CreateButton({
   Name = "🌐 Explorer Workspace",
   Callback = function()
      ExploreWorkspace()
   end,
})

local RemotesButton = DebugTab:CreateButton({
   Name = "📡 Explorer RemoteEvents",
   Callback = function()
      ExploreRemotes()
   end,
})

local PlayersButton = DebugTab:CreateButton({
   Name = "👥 Analyser Joueurs",
   Callback = function()
      ExplorePlayers()
   end,
})

local NearbyButton = DebugTab:CreateButton({
   Name = "📍 Objets Proches (50 studs)",
   Callback = function()
      AnalyzeNearbyObjects(50)
   end,
})

local DebugInfoSection = DebugTab:CreateSection("📊 Informations Debug")

local InfoLabel = DebugTab:CreateLabel("Ouvre F9 ou tape /console pour voir les logs")

local ObjectExplorerToggle = DebugTab:CreateToggle({
   Name = "🔄 Explorateur Temps Réel",
   CurrentValue = false,
   Flag = "ObjectExplorer",
   Callback = function(Value)
      ObjectExplorer = Value
      if Value then
         DebugLog("🔄 Explorateur temps réel ACTIVÉ")
         spawn(function()
            while ObjectExplorer do
               DebugLog("=== SCAN TEMPS RÉEL ===")
               ExplorePlayers()
               AnalyzeNearbyObjects(30)
               wait(5)
            end
         end)
      else
         DebugLog("🔄 Explorateur temps réel DÉSACTIVÉ")
      end
   end,
})

-- Tests spécifiques
local TestSection = DebugTab:CreateSection("🧪 Tests Spécifiques")

local TestTeleportButton = DebugTab:CreateButton({
   Name = "🧪 Test Téléportation",
   Callback = function()
      local testPos = rootPart.Position + Vector3.new(10, 0, 10)
      DebugLog("🧪 TEST: Téléportation vers " .. tostring(testPos))
      SafeTeleport(testPos)
   end,
})

local TestProximityButton = DebugTab:CreateButton({
   Name = "🧪 Test ProximityPrompts",
   Callback = function()
      DebugLog("🧪 TEST: Recherche de tous les ProximityPrompts")
      local promptCount = 0
      for _, obj in pairs(workspace:GetDescendants()) do
         if obj:IsA("ProximityPrompt") then
            promptCount = promptCount + 1
            local parent = obj.Parent
            DebugLog("  🛒 PROMPT #" .. promptCount .. ": " .. obj.Name .. " | Parent: " .. parent.Name .. " | ActionText: " .. (obj.ActionText or "N/A"))
         end
      end
      DebugLog("📊 Total ProximityPrompts trouvés: " .. promptCount)
   end,
})

-- Reconnexion automatique du character
player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoid = character:WaitForChild("Humanoid")
    rootPart = character:WaitForChild("HumanoidRootPart")
    
    if WalkSpeed ~= 16 then
        humanoid.WalkSpeed = WalkSpeed
    end
    if JumpPower ~= 50 then
        humanoid.JumpPower = JumpPower
    end
end)

-- 🔍 DEBUG INITIAL
DebugLog("=== INITIALISATION GUI STEAL BRAINROT ===")
DebugLog("👤 Joueur: " .. player.Name .. " | DisplayName: " .. player.DisplayName)
DebugLog("📍 Position spawn: " .. tostring(rootPart.Position))
DebugLog("🏃 Vitesse marche: " .. humanoid.WalkSpeed)
DebugLog("🦘 Puissance saut: " .. humanoid.JumpPower)

-- Scan initial automatique
spawn(function()
    wait(2)
    DebugLog("🔍 SCAN INITIAL AUTOMATIQUE")
    ExploreWorkspace()
    ExploreRemotes()
    ExplorePlayers()
end)

-- Notifications
Rayfield:Notify({
   Title = "🪐 Steal Brainrot GUI",
   Content = "GUI chargée depuis Github !",
   Duration = 3,
   Image = 4483362458,
})

DebugLog("✅ GUI CHARGÉE AVEC SUCCÈS !")
DebugLog("📖 Instructions: Ouvre F9 ou tape /console pour voir tous les logs")
DebugLog("🔍 Va dans l'onglet Debug pour explorer le jeu")
print("✅ Steal Brainrot GUI chargée avec succès depuis Github !")
