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

-- Variables de contrôle MVP
local AutoBuy = false
local WalkSpeed = 30
local JumpPower = 50
local DebugMode = true

-- Variables MVP Steal Brainrot
local ESPEnabled = false
local ESPBrainrots = false
local ESPPlayers = false
local SafeWalkSpeed = 30 -- Vitesse sûre anti-détection
local RedCarpetPosition = nil
local PlayerBasePosition = nil
local BuyingBrainrot = false
local PlayerMoney = 0

-- Configuration Webhook Discord
local WebhookConfig = {
    enabled = false,
    url = "", -- URL du webhook Discord
    sendErrors = true,
    sendBrainrotSpawn = true,
    sendAutoBuy = true,
    sendPlayerJoin = false
}

-- Cache pour éviter le spam de notifications
local NotificationCache = {
    lastBrainrotSpawn = {},
    lastError = "",
    lastErrorTime = 0
}

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

-- 📡 FONCTIONS WEBHOOK DISCORD

-- Envoyer un webhook Discord
local function SendDiscordWebhook(title, description, color, fields)
    if not WebhookConfig.enabled or WebhookConfig.url == "" then
        return
    end
    
    pcall(function()
        local data = {
            embeds = {{
                title = title,
                description = description,
                color = color or 3447003, -- Bleu par défaut
                fields = fields or {},
                footer = {
                    text = "Steal Brainrot MVP • " .. player.Name,
                    icon_url = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. player.UserId .. "&width=150&height=150&format=png"
                },
                timestamp = os.date("!%Y-%m-%dT%H:%M:%S")
            }}
        }
        
        local jsonData = game:GetService("HttpService"):JSONEncode(data)
        
        local request = {
            Url = WebhookConfig.url,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json"
            },
            Body = jsonData
        }
        
        local success, response = pcall(function()
            return game:GetService("HttpService"):RequestAsync(request)
        end)
        
        if success and response.Success then
            DebugLog("📡 Webhook envoyé: " .. title)
        else
            DebugLog("❌ Erreur webhook: " .. tostring(response), "warn")
        end
    end)
end

-- Notification d'erreur
local function NotifyError(errorMsg, context)
    if not WebhookConfig.sendErrors then return end
    
    -- Éviter le spam d'erreurs identiques
    local currentTime = tick()
    if NotificationCache.lastError == errorMsg and currentTime - NotificationCache.lastErrorTime < 30 then
        return
    end
    
    NotificationCache.lastError = errorMsg
    NotificationCache.lastErrorTime = currentTime
    
    SendDiscordWebhook(
        "🚨 Erreur Détectée",
        "Une erreur s'est produite dans le script",
        15158332, -- Rouge
        {
            {name = "Erreur", value = errorMsg, inline = false},
            {name = "Contexte", value = context or "Inconnu", inline = false},
            {name = "Joueur", value = player.Name .. " (" .. player.UserId .. ")", inline = true},
            {name = "Serveur", value = game.JobId, inline = true}
        }
    )
end

-- Notification spawn brainrot
local function NotifyBrainrotSpawn(brainrotInfo)
    if not WebhookConfig.sendBrainrotSpawn then return end
    
    -- Éviter le spam pour le même brainrot
    local cacheKey = brainrotInfo.name .. "_" .. brainrotInfo.rarity
    if NotificationCache.lastBrainrotSpawn[cacheKey] and 
       tick() - NotificationCache.lastBrainrotSpawn[cacheKey] < 10 then
        return
    end
    
    NotificationCache.lastBrainrotSpawn[cacheKey] = tick()
    
    local color = brainrotInfo.rarity == "God" and 16766720 or 16777215 -- Or ou Blanc
    
    SendDiscordWebhook(
        "🎭 Nouveau Brainrot " .. brainrotInfo.rarity,
        "Un brainrot " .. brainrotInfo.rarity .. " vient d'apparaître !",
        color,
        {
            {name = "Nom", value = brainrotInfo.name, inline = true},
            {name = "Rareté", value = brainrotInfo.rarity, inline = true},
            {name = "Prix", value = "$" .. (brainrotInfo.price or "N/A"), inline = true},
            {name = "Joueur", value = player.Name, inline = true},
            {name = "Argent disponible", value = "$" .. tostring(PlayerMoney), inline = true},
            {name = "Peut acheter", value = brainrotInfo.canAfford and "✅ Oui" or "❌ Non", inline = true}
        }
    )
end

-- Notification achat réussi
local function NotifyAutoBuy(brainrotInfo, success)
    if not WebhookConfig.sendAutoBuy then return end
    
    local color = success and 3066993 or 15158332 -- Vert ou Rouge
    local title = success and "✅ Achat Réussi" or "❌ Échec Achat"
    
    SendDiscordWebhook(
        title,
        success and "Brainrot acheté avec succès !" or "Échec de l'achat du brainrot",
        color,
        {
            {name = "Brainrot", value = brainrotInfo.name, inline = true},
            {name = "Rareté", value = brainrotInfo.rarity, inline = true},
            {name = "Prix", value = "$" .. (brainrotInfo.price or "N/A"), inline = true},
            {name = "Joueur", value = player.Name, inline = true},
            {name = "Serveur", value = game.JobId, inline = true},
            {name = "Timestamp", value = os.date("%H:%M:%S"), inline = true}
        }
    )
end

-- Notification joueur rejoint (optionnel)
local function NotifyPlayerJoin(playerName)
    if not WebhookConfig.sendPlayerJoin then return end
    
    SendDiscordWebhook(
        "👤 Joueur Rejoint",
        "Un nouveau joueur a rejoint le serveur",
        3447003, -- Bleu
        {
            {name = "Joueur", value = playerName, inline = true},
            {name = "Serveur", value = game.JobId, inline = true},
            {name = "Joueurs Total", value = #Players:GetPlayers(), inline = true}
        }
    )
end

-- 🎮 FONCTIONS SPÉCIFIQUES STEAL BRAINROT

-- Détecter l'argent du joueur depuis l'interface
local function DetectPlayerMoney()
    for _, gui in pairs(player.PlayerGui:GetDescendants()) do
        if gui:IsA("TextLabel") or gui:IsA("TextBox") then
            local text = gui.Text
            if text:find("%$") and (text:find("T") or text:find("B") or text:find("M") or text:find("K")) then
                local cleanText = text:gsub("[^%d%.]", "")
                if cleanText ~= "" then
                    local multiplier = 1
                    if text:find("K") then multiplier = 1000
                    elseif text:find("M") then multiplier = 1000000
                    elseif text:find("B") then multiplier = 1000000000
                    elseif text:find("T") then multiplier = 1000000000000
                    end
                    PlayerMoney = tonumber(cleanText) * multiplier
                    return PlayerMoney
                end
            end
        end
    end
    return PlayerMoney
end

-- Créer ESP pour un objet
local function CreateESP(object, text, color)
    if not object or not object.Parent then return end
    
    local billboard = Instance.new("BillboardGui")
    billboard.Size = UDim2.new(0, 200, 0, 50)
    billboard.StudsOffset = Vector3.new(0, 3, 0)
    billboard.Parent = object
    billboard.Name = "ESP_" .. object.Name
    
    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = text
    textLabel.TextColor3 = color
    textLabel.TextStrokeTransparency = 0
    textLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
    textLabel.TextScaled = true
    textLabel.Font = Enum.Font.SourceSansBold
    textLabel.Parent = billboard
    
    return billboard
end

-- Supprimer ESP existant
local function RemoveESP(object)
    for _, child in pairs(object:GetChildren()) do
        if child.Name:find("ESP_") then
            child:Destroy()
        end
    end
end

-- Détecter si un brainrot est God ou Secret
local function IsBrainrotGodOrSecret(brainrot)
    for _, child in pairs(brainrot:GetDescendants()) do
        if child:IsA("TextLabel") or child:IsA("SurfaceGui") then
            local text = child.Text or ""
            if text:find("Brainrot God") or text:find("Secret") then
                return true, text:find("Brainrot God") and "God" or "Secret"
            end
        end
    end
    return false, nil
end

-- Détecter le tapis rouge (position centrale)
local function DetectRedCarpet()
    for _, part in pairs(workspace:GetDescendants()) do
        if part:IsA("BasePart") and (part.BrickColor == BrickColor.new("Bright red") or part.Material == Enum.Material.Carpet) then
            if part.Size.X > 20 or part.Size.Z > 20 then -- Grand tapis
                RedCarpetPosition = part.Position
                DebugLog("🔴 TAPIS ROUGE DÉTECTÉ: " .. tostring(RedCarpetPosition))
                return RedCarpetPosition
            end
        end
    end
    return nil
end

-- Détecter la base du joueur
local function DetectPlayerBase()
    -- Chercher des objets avec le nom du joueur ou des bases
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj.Name:find(player.Name) or obj.Name:find("Base") then
            if obj:IsA("BasePart") then
                PlayerBasePosition = obj.Position
                DebugLog("🏠 BASE JOUEUR DÉTECTÉE: " .. tostring(PlayerBasePosition))
                return PlayerBasePosition
            end
        end
    end
    return nil
end

-- Scanner tous les brainrots God/Secret
local function ScanBrainrots(notifyWebhook)
    local brainrots = {}
    
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("Model") or obj:IsA("Part") then
            local isGodSecret, rarity = IsBrainrotGodOrSecret(obj)
            if isGodSecret then
                local info = {
                    object = obj,
                    rarity = rarity,
                    position = obj:IsA("BasePart") and obj.Position or obj.PrimaryPart and obj.PrimaryPart.Position,
                    name = obj.Name
                }
                
                -- Détecter le prix si c'est sur le tapis
                for _, child in pairs(obj:GetDescendants()) do
                    if child:IsA("TextLabel") and child.Text:find("%$") then
                        local priceText = child.Text:match("%$([%d%.]+[KMBT]?)")
                        if priceText then
                            info.price = priceText
                            info.priceNumber = ConvertPriceToNumber(priceText)
                        end
                    end
                end
                
                -- Vérifier si on peut se le permettre
                if info.priceNumber then
                    info.canAfford = PlayerMoney >= info.priceNumber
                end
                
                table.insert(brainrots, info)
                DebugLog("🎭 BRAINROT " .. rarity .. " TROUVÉ: " .. obj.Name .. " | Prix: " .. (info.price or "N/A"))
                
                -- Notifier le webhook pour les nouveaux spawns (seulement si sur le tapis rouge)
                if notifyWebhook and RedCarpetPosition and info.position then
                    local distanceFromCarpet = (info.position - RedCarpetPosition).Magnitude
                    if distanceFromCarpet < 50 then -- Sur le tapis = nouveau spawn
                        NotifyBrainrotSpawn(info)
                    end
                end
            end
        end
    end
    
    return brainrots
end

-- ESP pour brainrots
local function UpdateBrainrotESP()
    if not ESPBrainrots then return end
    
    local brainrots = ScanBrainrots()
    
    for _, info in pairs(brainrots) do
        local obj = info.object
        RemoveESP(obj)
        
        local espText = info.rarity .. " - " .. info.name
        if info.price then
            espText = espText .. "\n$" .. info.price
        end
        
        local color = info.rarity == "God" and Color3.fromRGB(255, 215, 0) or Color3.fromRGB(255, 255, 255)
        CreateESP(obj, espText, color)
    end
end

-- ESP pour joueurs
local function UpdatePlayerESP()
    if not ESPPlayers then return end
    
    for _, otherPlayer in pairs(Players:GetPlayers()) do
        if otherPlayer ~= player and otherPlayer.Character then
            local character = otherPlayer.Character
            local head = character:FindFirstChild("Head")
            
            if head then
                RemoveESP(head)
                
                local distance = rootPart and math.floor((rootPart.Position - head.Position).Magnitude) or 0
                local espText = otherPlayer.Name .. "\nDistance: " .. distance
                
                CreateESP(head, espText, Color3.fromRGB(0, 255, 255))
            end
        end
    end
end

-- 🔍 FONCTIONS DE DEBUG
local function DebugLog(message, level)
    if not DebugMode then return end
    local prefix = "🪐 DEBUG"
    if level == "warn" then
        prefix = "⚠️ WARN"
        warn(prefix .. ": " .. tostring(message))
    elseif level == "error" then
        prefix = "❌ ERROR"
        -- Envoyer l'erreur au webhook
        NotifyError(tostring(message), "DebugLog Error")
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

-- Fonctions MVP supprimées pour garder seulement l'essentiel

-- Convertir prix texte en nombre
local function ConvertPriceToNumber(priceText)
    if not priceText then return 0 end
    
    local cleanText = priceText:gsub("[^%d%.]", "")
    local number = tonumber(cleanText) or 0
    
    if priceText:find("K") then number = number * 1000
    elseif priceText:find("M") then number = number * 1000000
    elseif priceText:find("B") then number = number * 1000000000
    elseif priceText:find("T") then number = number * 1000000000000
    end
    
    return number
end

-- Téléportation sécurisée avec vitesse limitée
local function SafeMoveToPosition(targetPosition)
    if not targetPosition or not rootPart then return false end
    
    local distance = (rootPart.Position - targetPosition).Magnitude
    DebugLog("🏃 DÉPLACEMENT vers: " .. tostring(targetPosition) .. " | Distance: " .. math.floor(distance))
    
    -- Si trop loin, téléportation directe
    if distance > 100 then
        rootPart.CFrame = CFrame.new(targetPosition + Vector3.new(0, 5, 0))
        wait(0.5)
        return true
    end
    
    -- Sinon, déplacement avec vitesse sûre
    local originalSpeed = humanoid.WalkSpeed
    humanoid.WalkSpeed = SafeWalkSpeed
    
    -- Se diriger vers la position
    humanoid:MoveTo(targetPosition)
    
    -- Attendre d'arriver ou timeout
    local startTime = tick()
    while (rootPart.Position - targetPosition).Magnitude > 5 and tick() - startTime < 10 do
        wait(0.1)
    end
    
    humanoid.WalkSpeed = originalSpeed
    return (rootPart.Position - targetPosition).Magnitude <= 5
end

-- Fonction AUTO BUY pour Brainrots God/Secret
local function AutoBuyBrainrots()
    DebugLog("🛒 AUTO BUY BRAINROTS DÉMARRÉ")
    local buyAttempts = 0
    
    while AutoBuy do
        if BuyingBrainrot then
            DebugLog("⏳ Achat en cours, attente...")
            wait(2)
            continue
        end
        
        -- Mettre à jour l'argent du joueur
        DetectPlayerMoney()
        DebugLog("💰 Argent joueur: $" .. tostring(PlayerMoney))
        
        -- Scanner les brainrots disponibles (avec notifications webhook)
        local brainrots = ScanBrainrots(true)
        local targetBrainrot = nil
        
        -- Chercher le meilleur brainrot God/Secret qu'on peut se permettre
        for _, info in pairs(brainrots) do
            if info.rarity == "God" or info.rarity == "Secret" then
                local price = ConvertPriceToNumber(info.price)
                
                if price > 0 and PlayerMoney >= price then
                    -- Vérifier si c'est sur le tapis rouge (proche de RedCarpetPosition)
                    if RedCarpetPosition and info.position then
                        local distanceFromCarpet = (info.position - RedCarpetPosition).Magnitude
                        if distanceFromCarpet < 50 then -- Sur le tapis
                            targetBrainrot = info
                            DebugLog("🎯 CIBLE: " .. info.rarity .. " " .. info.name .. " | Prix: $" .. info.price)
                            break
                        end
                    end
                else
                    DebugLog("❌ Pas assez d'argent pour: " .. info.name .. " (Prix: $" .. (info.price or "0") .. ")")
                end
            end
        end
        
        if targetBrainrot then
            BuyingBrainrot = true
            DebugLog("🚀 DÉBUT ACHAT: " .. targetBrainrot.name)
            
            -- Se déplacer vers le brainrot
            local success = SafeMoveToPosition(targetBrainrot.position)
            
            if success then
                DebugLog("✅ Arrivé près du brainrot, tentative d'achat...")
                
                -- Appuyer sur E pour acheter
                local buySuccess = pcall(function()
                    game:GetService("VirtualInputManager"):SendKeyEvent(true, "E", false, game)
                    wait(0.1)
                    game:GetService("VirtualInputManager"):SendKeyEvent(false, "E", false, game)
                end)
                
                buyAttempts = buyAttempts + 1
                DebugLog("🔥 ACHAT TENTÉ #" .. buyAttempts .. ": " .. targetBrainrot.name)
                
                -- Notifier le webhook de la tentative d'achat
                NotifyAutoBuy(targetBrainrot, buySuccess)
                
                if buySuccess then
                    -- Attendre que le brainrot commence à se déplacer vers notre base
                    wait(2)
                    DebugLog("✅ ACHAT TERMINÉ pour: " .. targetBrainrot.name)
                else
                    DebugLog("❌ ERREUR lors de l'achat: " .. targetBrainrot.name, "error")
                end
            else
                DebugLog("❌ Échec déplacement vers: " .. targetBrainrot.name, "warn")
                NotifyAutoBuy(targetBrainrot, false)
            end
            
            BuyingBrainrot = false
            wait(1) -- Délai entre les achats
        else
            DebugLog("🔍 Aucun brainrot God/Secret disponible ou abordable")
            wait(3) -- Attendre plus longtemps si rien à acheter
        end
    end
    
    DebugLog("🛑 AUTO BUY BRAINROTS ARRÊTÉ")
end

-- 📡 ONGLET WEBHOOK DISCORD (2ème position pour visibilité)
local WebhookTab = Window:CreateTab("📡 Discord", 4483362458)

local WebhookConfigSection = WebhookTab:CreateSection("⚙️ Configuration Webhook")

local WebhookInput = WebhookTab:CreateInput({
   Name = "🔗 URL Webhook Discord",
   PlaceholderText = "https://discord.com/api/webhooks/...",
   RemoveTextAfterFocusLost = false,
   Flag = "WebhookURL",
   Callback = function(Text)
      WebhookConfig.url = Text
      if Text ~= "" then
         DebugLog("📡 Webhook URL configuré")
      end
   end,
})

local WebhookEnabledToggle = WebhookTab:CreateToggle({
   Name = "📡 Activer Webhook",
   CurrentValue = false,
   Flag = "WebhookEnabled",
   Callback = function(Value)
      WebhookConfig.enabled = Value
      if Value and WebhookConfig.url == "" then
         DebugLog("⚠️ URL Webhook non configuré !", "warn")
         WebhookConfig.enabled = false
      else
         DebugLog("📡 Webhook " .. (Value and "ACTIVÉ" or "DÉSACTIVÉ"))
      end
   end,
})

local WebhookNotificationSection = WebhookTab:CreateSection("🔔 Types de Notifications")

local ErrorNotifToggle = WebhookTab:CreateToggle({
   Name = "🚨 Notifications d'Erreurs",
   CurrentValue = true,
   Flag = "WebhookErrors",
   Callback = function(Value)
      WebhookConfig.sendErrors = Value
      DebugLog("🚨 Notifications erreurs: " .. (Value and "ON" or "OFF"))
   end,
})

local SpawnNotifToggle = WebhookTab:CreateToggle({
   Name = "🎭 Spawn Brainrots God/Secret",
   CurrentValue = true,
   Flag = "WebhookSpawn",
   Callback = function(Value)
      WebhookConfig.sendBrainrotSpawn = Value
      DebugLog("🎭 Notifications spawn: " .. (Value and "ON" or "OFF"))
   end,
})

local BuyNotifToggle = WebhookTab:CreateToggle({
   Name = "🛒 Résultats Auto Buy",
   CurrentValue = true,
   Flag = "WebhookBuy",
   Callback = function(Value)
      WebhookConfig.sendAutoBuy = Value
      DebugLog("🛒 Notifications achat: " .. (Value and "ON" or "OFF"))
   end,
})

local TestWebhookButton = WebhookTab:CreateButton({
   Name = "🧪 Tester Webhook",
   Callback = function()
      if WebhookConfig.url == "" then
         DebugLog("❌ Configure d'abord l'URL du webhook !", "warn")
         return
      end
      
      SendDiscordWebhook(
         "🧪 Test Webhook",
         "Test de connexion réussi !",
         3066993, -- Vert
         {
            {name = "Joueur", value = player.Name, inline = true},
            {name = "Status", value = "✅ Fonctionnel", inline = true}
         }
      )
      DebugLog("🧪 Test webhook envoyé")
   end,
})

local WebhookInfoSection = WebhookTab:CreateSection("📖 Instructions")
local InfoLabel1 = WebhookTab:CreateLabel("1. Discord → Serveur → Paramètres → Intégrations")
local InfoLabel2 = WebhookTab:CreateLabel("2. Webhooks → Nouveau → Copier URL")
local InfoLabel3 = WebhookTab:CreateLabel("3. Coller URL ci-dessus → Activer → Tester")

-- Onglet Principal
local MainTab = Window:CreateTab("🏠 Principal", 4483362458)

-- Section MVP Auto Buy
local AutoSection = MainTab:CreateSection("🛒 Auto Buy MVP")

local AutoBuyToggle = MainTab:CreateToggle({
   Name = "🛒 Auto Buy God/Secret",
   CurrentValue = false,
   Flag = "AutoBuy",
   Callback = function(Value)
      AutoBuy = Value
      if Value then
         DebugLog("🚀 AUTO BUY ACTIVÉ - Recherche de brainrots God/Secret")
         -- Détecter le tapis rouge au démarrage
         if not RedCarpetPosition then
            DetectRedCarpet()
         end
         spawn(AutoBuyBrainrots)
      else
         DebugLog("🛑 AUTO BUY DÉSACTIVÉ")
      end
   end,
})

-- Section Player
local PlayerSection = MainTab:CreateSection("👤 Joueur")

local WalkSpeedSlider = MainTab:CreateSlider({
   Name = "🏃 Vitesse de marche (Sûre: 30)",
   Range = {16, 100},
   Increment = 1,
   Suffix = " Speed",
   CurrentValue = 30,
   Flag = "WalkSpeed",
   Callback = function(Value)
      WalkSpeed = Value
      SafeWalkSpeed = Value
      if character and humanoid then
         humanoid.WalkSpeed = Value
      end
      if Value > 50 then
         DebugLog("⚠️ ATTENTION: Vitesse > 50 peut être détectée !", "warn")
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

-- Section Credits MVP
local CreditsSection = DebugTab:CreateSection("📝 Crédits MVP")
local CreditsLabel = DebugTab:CreateLabel("Steal Brainrot MVP v1.0 - Webhook Edition")
local AuthorLabel = DebugTab:CreateLabel("by GlamgarOnDiscord")
local GitHubLabel = DebugTab:CreateLabel("GitHub: rbx-script")

-- Doublon webhook supprimé

-- 👁️ ONGLET ESP
local ESPTab = Window:CreateTab("👁️ ESP", 4483362458)

local ESPControlSection = ESPTab:CreateSection("🎯 Contrôles ESP")

local ESPBrainrotsToggle = ESPTab:CreateToggle({
   Name = "🎭 ESP Brainrots God/Secret",
   CurrentValue = false,
   Flag = "ESPBrainrots",
   Callback = function(Value)
      ESPBrainrots = Value
      if Value then
         DebugLog("👁️ ESP BRAINROTS ACTIVÉ")
         spawn(function()
            while ESPBrainrots do
               UpdateBrainrotESP()
               wait(2)
            end
         end)
      else
         DebugLog("👁️ ESP BRAINROTS DÉSACTIVÉ")
         -- Supprimer tous les ESP brainrots
         for _, obj in pairs(workspace:GetDescendants()) do
            RemoveESP(obj)
         end
      end
   end,
})

local ESPPlayersToggle = ESPTab:CreateToggle({
   Name = "👥 ESP Joueurs",
   CurrentValue = false,
   Flag = "ESPPlayers",
   Callback = function(Value)
      ESPPlayers = Value
      if Value then
         DebugLog("👁️ ESP JOUEURS ACTIVÉ")
         spawn(function()
            while ESPPlayers do
               UpdatePlayerESP()
               wait(1)
            end
         end)
      else
         DebugLog("👁️ ESP JOUEURS DÉSACTIVÉ")
         -- Supprimer tous les ESP joueurs
         for _, otherPlayer in pairs(Players:GetPlayers()) do
            if otherPlayer.Character and otherPlayer.Character:FindFirstChild("Head") then
               RemoveESP(otherPlayer.Character.Head)
            end
         end
      end
   end,
})

local ESPInfoSection = ESPTab:CreateSection("📊 Informations ESP")

local ESPInfoLabel = ESPTab:CreateLabel("ESP God: Texte doré | ESP Secret: Texte blanc")
local ESPPlayerLabel = ESPTab:CreateLabel("ESP Joueurs: Nom + Distance")

local QuickESPSection = ESPTab:CreateSection("⚡ Actions Rapides")

local ScanBrainrotsButton = ESPTab:CreateButton({
   Name = "🔍 Scanner Brainrots Maintenant",
   Callback = function()
      local brainrots = ScanBrainrots()
      DebugLog("📊 SCAN MANUEL: " .. #brainrots .. " brainrots God/Secret trouvés")
   end,
})

local DetectPositionsButton = ESPTab:CreateButton({
   Name = "📍 Détecter Tapis Rouge + Base",
   Callback = function()
      DetectRedCarpet()
      DetectPlayerBase()
      DebugLog("📍 DÉTECTION POSITIONS TERMINÉE")
   end,
})

local MoneyCheckButton = ESPTab:CreateButton({
   Name = "💰 Vérifier Argent Joueur",
   Callback = function()
      DetectPlayerMoney()
      DebugLog("💰 ARGENT DÉTECTÉ: $" .. tostring(PlayerMoney))
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

-- Notifications joueurs qui rejoignent
Players.PlayerAdded:Connect(function(newPlayer)
    if newPlayer ~= player then
        DebugLog("👤 NOUVEAU JOUEUR: " .. newPlayer.Name)
        NotifyPlayerJoin(newPlayer.Name)
    end
end)

-- 🔍 DEBUG INITIAL
DebugLog("=== INITIALISATION GUI STEAL BRAINROT ===")
DebugLog("👤 Joueur: " .. player.Name .. " | DisplayName: " .. player.DisplayName)
DebugLog("📍 Position spawn: " .. tostring(rootPart.Position))
DebugLog("🏃 Vitesse marche: " .. humanoid.WalkSpeed)
DebugLog("🦘 Puissance saut: " .. humanoid.JumpPower)

-- Scan initial automatique MVP STEAL BRAINROT
spawn(function()
    wait(2)
    DebugLog("🔍 SCAN INITIAL STEAL BRAINROT MVP")
    
    -- Détections spécifiques au jeu
    DetectRedCarpet()
    DetectPlayerBase()
    DetectPlayerMoney()
    
    -- Scanner les brainrots disponibles
    local brainrots = ScanBrainrots()
    DebugLog("🎭 BRAINROTS TROUVÉS: " .. #brainrots .. " God/Secret")
    
    -- Scan général pour debug
    ExploreWorkspace()
    ExploreRemotes()
    ExplorePlayers()
    
    DebugLog("✅ SCAN INITIAL TERMINÉ - MVP PRÊT !")
end)

-- Notifications
Rayfield:Notify({
   Title = "🪐 Steal Brainrot MVP",
   Content = "🛒 Auto Buy + 📡 Discord + 👁️ ESP",
   Duration = 5,
   Image = 4483362458,
})

DebugLog("✅ MVP STEAL BRAINROT CHARGÉ - WEBHOOK EDITION !")
DebugLog("🎯 FONCTIONNALITÉS MVP: Auto Buy God/Secret, ESP, Webhook Discord")
DebugLog("📡 CONFIGURE WEBHOOK: Onglet Discord → Coller URL → Activer")
DebugLog("🛒 AUTO BUY: Onglet Principal → Activer Auto Buy")
DebugLog("⚡ PRÊT À UTILISER - MVP optimisé !")

-- Notification webhook de démarrage
spawn(function()
    wait(3) -- Laisser le temps à l'utilisateur de configurer le webhook
    if WebhookConfig.enabled and WebhookConfig.url ~= "" then
        SendDiscordWebhook(
            "🚀 Script Démarré",
            "MVP Steal Brainrot lancé avec succès !",
            3066993, -- Vert
            {
                {name = "Joueur", value = player.Name .. " (" .. player.DisplayName .. ")", inline = true},
                {name = "Serveur", value = game.JobId, inline = true},
                {name = "Joueurs présents", value = tostring(#Players:GetPlayers()), inline = true},
                {name = "Version", value = "MVP v1.0", inline = true},
                {name = "Fonctionnalités", value = "Auto Buy, ESP, Debug", inline = true},
                {name = "Status", value = "✅ Opérationnel", inline = true}
            }
        )
    end
end)

print("✅ MVP Steal Brainrot GUI chargée avec succès depuis Github !")
