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
        DebugLog("❌ Webhook non configuré", "warn")
        return
    end
    
    local success, result = pcall(function()
        local HttpService = game:GetService("HttpService")
        
        local data = {
            embeds = {{
                title = title,
                description = description,
                color = color or 3447003,
                fields = fields or {},
                footer = {
                    text = "Steal Brainrot MVP • " .. player.Name,
                    icon_url = "https://www.roblox.com/headshot-thumbnail/image?userId=" .. player.UserId .. "&width=150&height=150&format=png"
                },
                timestamp = os.date("!%Y-%m-%dT%H:%M:%S")
            }}
        }
        
        local jsonData = HttpService:JSONEncode(data)
        DebugLog("📡 Tentative envoi webhook: " .. title)
        
        local request = {
            Url = WebhookConfig.url,
            Method = "POST",
            Headers = {
                ["Content-Type"] = "application/json"
            },
            Body = jsonData
        }
        
        local response = HttpService:RequestAsync(request)
        
        if response.Success then
            DebugLog("✅ Webhook envoyé avec succès: " .. title)
            return true
        else
            DebugLog("❌ Échec webhook - Code: " .. response.StatusCode .. " | Message: " .. response.StatusMessage, "warn")
            return false
        end
    end)
    
    if not success then
        DebugLog("❌ Erreur critique webhook: " .. tostring(result), "error")
    end
    
    return success
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

-- 🔍 FONCTION DEBUG (définie en premier)
local function DebugLog(message, level)
    if not DebugMode then return end
    local prefix = "🪐 DEBUG"
    if level == "warn" then
        prefix = "⚠️ WARN"
        warn(prefix .. ": " .. tostring(message))
    elseif level == "error" then
        prefix = "❌ ERROR"
        -- CORRECTION: print au lieu d'error pour éviter crash callback
        print(prefix .. ": " .. tostring(message))
    else
        print(prefix .. ": " .. tostring(message))
    end
end

-- 📡 FONCTIONS WEBHOOK (définies tôt pour éviter les erreurs nil)

-- Notification d'erreur simple (sans webhook pour éviter boucle)
local function SimpleNotifyError(errorMsg, context)
    DebugLog("🚨 ERREUR: " .. errorMsg .. " | Contexte: " .. (context or "Inconnu"), "error")
end

-- Convertir prix texte en nombre (fonction utilitaire)
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

-- 🎮 FONCTIONS SPÉCIFIQUES STEAL BRAINROT

-- Détecter l'argent du joueur depuis l'interface
local function DetectPlayerMoney()
    DebugLog("🔍 Recherche argent joueur...")
    
    -- Méthode 1: Chercher dans Leaderstats (priorité)
    if player:FindFirstChild("leaderstats") then
        local leaderstats = player.leaderstats
        DebugLog("📊 Leaderstats trouvé, scan...")
        for _, stat in pairs(leaderstats:GetChildren()) do
            local statName = stat.Name:lower()
            DebugLog("  📝 Stat: " .. stat.Name .. " = " .. tostring(stat.Value))
            if statName:find("cash") or statName:find("money") or statName:find("coin") or statName:find("dollar") then
                PlayerMoney = tonumber(stat.Value) or 0
                DebugLog("✅ Argent détecté via leaderstats: $" .. PlayerMoney .. " (source: " .. stat.Name .. ")")
                return PlayerMoney
            end
        end
        DebugLog("⚠️ Leaderstats présent mais pas d'argent reconnu")
    else
        DebugLog("❌ Aucun leaderstats trouvé")
    end
    
    -- Méthode 2: Chercher dans PlayerGui (fallback)
    DebugLog("🔍 Scan PlayerGui pour argent...")
    local guiMoney = {}
    for _, gui in pairs(player.PlayerGui:GetDescendants()) do
        pcall(function()
            if gui:IsA("TextLabel") and gui.Text then
                local text = gui.Text
                -- CORRECTION: Patterns plus larges pour détecter argent
                if text:find("%$") or text:lower():find("cash") or text:lower():find("money") then
                    DebugLog("💳 GUI text trouvé: '" .. text .. "' | Path: " .. gui:GetFullName())
                    
                    -- Format $123 ou $123K/M/B/T
                    if text:find("%$%d") then
                        local numberStr = text:match("%$([%d%.]+[KMBT]?)")
                        if numberStr then
                            local cleanText = numberStr:gsub("[^%d%.]", "")
                            local number = tonumber(cleanText) or 0
                            
                            if numberStr:find("K") then number = number * 1000
                            elseif numberStr:find("M") then number = number * 1000000
                            elseif numberStr:find("B") then number = number * 1000000000
                            elseif numberStr:find("T") then number = number * 1000000000000
                            end
                            
                            table.insert(guiMoney, {amount = number, text = text, path = gui:GetFullName()})
                        end
                    else
                        -- Format simple nombre
                        local numberInText = text:match("%d+")
                        if numberInText then
                            local amount = tonumber(numberInText) or 0
                            table.insert(guiMoney, {amount = amount, text = text, path = gui:GetFullName()})
                        end
                    end
                end
            end
        end)
    end
    
    -- Prendre le plus grand montant trouvé dans GUI
    if #guiMoney > 0 then
        table.sort(guiMoney, function(a, b) return a.amount > b.amount end)
        PlayerMoney = guiMoney[1].amount
        DebugLog("✅ Argent détecté via GUI: $" .. PlayerMoney .. " (source: '" .. guiMoney[1].text .. "')")
        DebugLog("📊 Autres montants trouvés: " .. #guiMoney)
        for i = 1, math.min(3, #guiMoney) do
            DebugLog("  " .. i .. ". $" .. guiMoney[i].amount .. " - '" .. guiMoney[i].text .. "'")
        end
        return PlayerMoney
    end
    
    DebugLog("❌ Impossible de détecter l'argent du joueur", "error")
    PlayerMoney = 0
    return 0
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
        if child:IsA("TextLabel") and child.Text then
            local text = child.Text
            -- CORRECTION: Plus spécifique pour éviter faux positifs
            if text:find("Brainrot God") then
                DebugLog("✅ Brainrot God détecté: '" .. text .. "' sur " .. brainrot.Name)
                return true, "God"
            elseif text:find("Secret") and not text:find("Codes") and not text:find("Main") and brainrot.Name ~= "Codes" and brainrot.Name ~= "Main" then
                DebugLog("✅ Brainrot Secret détecté: '" .. text .. "' sur " .. brainrot.Name)
                return true, "Secret"
            end
        elseif child:IsA("SurfaceGui") then
            -- Chercher dans les TextLabel des SurfaceGui
            for _, subChild in pairs(child:GetDescendants()) do
                if subChild:IsA("TextLabel") and subChild.Text then
                    local text = subChild.Text
                    if text:find("Brainrot God") then
                        DebugLog("✅ Brainrot God détecté: '" .. text .. "' sur " .. brainrot.Name)
                        return true, "God"
                    elseif text:find("Secret") and not text:find("Codes") and not text:find("Main") and brainrot.Name ~= "Codes" and brainrot.Name ~= "Main" then
                        DebugLog("✅ Brainrot Secret détecté: '" .. text .. "' sur " .. brainrot.Name)
                        return true, "Secret"
                    end
                end
            end
        end
    end
    return false, nil
end

-- Détecter le tapis rouge (position centrale)
local function DetectRedCarpet()
    DebugLog("🔍 Recherche du tapis rouge...")
    
    for _, part in pairs(workspace:GetDescendants()) do
        pcall(function()
            if part:IsA("BasePart") then
                local isRed = false
                local isLarge = false
                
                -- Vérifier la couleur
                if part.BrickColor and (part.BrickColor == BrickColor.new("Bright red") or part.BrickColor == BrickColor.new("Really red")) then
                    isRed = true
                elseif part.Material == Enum.Material.Carpet then
                    isRed = true
                elseif part.Name:lower():find("carpet") or part.Name:lower():find("tapis") then
                    isRed = true
                end
                
                -- Vérifier la taille
                if part.Size and (part.Size.X > 15 or part.Size.Z > 15) then
                    isLarge = true
                end
                
                if isRed and isLarge then
                    RedCarpetPosition = part.Position
                    DebugLog("🔴 TAPIS ROUGE DÉTECTÉ: " .. part.Name .. " | Position: " .. tostring(RedCarpetPosition))
                    return RedCarpetPosition
                end
            end
        end)
    end
    
    DebugLog("❌ Tapis rouge non trouvé", "warn")
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
    
    pcall(function()
        for _, obj in pairs(workspace:GetDescendants()) do
            pcall(function()
                if obj:IsA("Model") or obj:IsA("Part") then
                    local isGodSecret, rarity = IsBrainrotGodOrSecret(obj)
                    if isGodSecret then
                        -- CORRECTION: Meilleure détection position pour Models
                        local position = nil
                        if obj:IsA("BasePart") then
                            position = obj.Position
                        elseif obj:IsA("Model") then
                            if obj.PrimaryPart then
                                position = obj.PrimaryPart.Position
                            else
                                -- Essayer GetPivot() pour les nouveaux Models
                                local success, pivotResult = pcall(function()
                                    return obj:GetPivot().Position
                                end)
                                if success then
                                    position = pivotResult
                                else
                                    -- Fallback: centre approximatif via BoundingBox  
                                    local cfSuccess, cframe, size = pcall(function()
                                        return obj:GetBoundingBox()
                                    end)
                                    if cfSuccess then
                                        position = cframe.Position
                                    end
                                end
                            end
                        end

                        local info = {
                            object = obj,
                            rarity = rarity,
                            position = position,
                            name = obj.Name
                        }
                        
                        -- Détecter le prix si c'est sur le tapis
                        for _, child in pairs(obj:GetDescendants()) do
                            pcall(function()
                                if child:IsA("TextLabel") and child.Text and child.Text:find("%$") then
                                    local priceText = child.Text:match("%$([%d%.]+[KMBT]?)")
                                    if priceText then
                                        info.price = priceText
                                        info.priceNumber = ConvertPriceToNumber(priceText)
                                    end
                                end
                            end)
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
            end)
        end
    end)
    
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

-- 🔍 FONCTIONS DE DEBUG (DebugLog déjà défini plus haut)

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
      DebugLog("🧪 DÉBUT TEST WEBHOOK")
      
      if WebhookConfig.url == "" then
         DebugLog("❌ Configure d'abord l'URL du webhook !", "warn")
         return
      end
      
      if not WebhookConfig.enabled then
         DebugLog("❌ Active d'abord le webhook !", "warn")
         return
      end
      
      DebugLog("📡 Envoi test webhook...")
      
      -- Vérifier HttpRequests d'abord
      local HttpService = game:GetService("HttpService")
      local httpEnabled = pcall(function()
         return HttpService.HttpEnabled
      end)
      
      if not httpEnabled then
         DebugLog("❌ ERREUR: HttpRequests DÉSACTIVÉ dans ton executeur !", "error")
         DebugLog("📖 SOLUTION:")
         DebugLog("  • Synapse X: Options → Allow HTTP Requests")
         DebugLog("  • Krnl: Paramètres → Enable HTTP Requests")
         DebugLog("  • Script-Ware: Settings → HTTP Requests → ON")
         DebugLog("  • Fluxus: Settings → HTTP → Enable")
         return
      end
      
      DebugLog("✅ HttpRequests activé, test en cours...")
      
      -- Test webhook simple
      local success, result = pcall(function()
         local data = {
            content = "🧪 Test Webhook MVP - " .. player.Name .. " - " .. os.date("%H:%M:%S")
         }
         
         local request = {
            Url = WebhookConfig.url,
            Method = "POST",
            Headers = {
               ["Content-Type"] = "application/json"
            },
            Body = HttpService:JSONEncode(data)
         }
         
         local response = HttpService:RequestAsync(request)
         
         if response.Success then
            DebugLog("✅ TEST WEBHOOK RÉUSSI!")
            return true
         else
            DebugLog("❌ Test webhook échoué: " .. response.StatusCode .. " - " .. response.StatusMessage, "warn")
            return false
         end
      end)
      
      if not success then
         DebugLog("❌ Erreur test webhook - Vérifie HttpRequests dans ton executeur", "error")
      end
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
      DebugLog("🛒 AUTO BUY TOGGLE: " .. (Value and "ON" or "OFF"))
      
      AutoBuy = Value
      if Value then
         DebugLog("🚀 AUTO BUY ACTIVÉ - Recherche de brainrots God/Secret")
         
         -- Détecter le tapis rouge au démarrage
         pcall(function()
            if not RedCarpetPosition then
               DetectRedCarpet()
            end
         end)
         
         -- Lancer l'auto buy de façon sécurisée
         pcall(function()
            spawn(function()
               -- Auto buy simplifié pour éviter les erreurs
               while AutoBuy do
                  DebugLog("🔍 Recherche brainrots...")
                  wait(5) -- Attendre 5 secondes entre les scans
               end
            end)
         end)
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

local FullDebugButton = DebugTab:CreateButton({
   Name = "🔍 FULL DEBUG PRÉCIS",
   Callback = function()
      DebugLog("=== 🎯 FULL DEBUG ANALYSIS START ===")
      
      -- 1. BRAINROTS DETECTION PRÉCISE
      DebugLog("--- 🎭 BRAINROTS PRÉCIS ---")
      local brainrotTargets = {}
      
      for _, obj in pairs(workspace:GetDescendants()) do
         pcall(function()
            if obj:IsA("Model") or obj:IsA("Part") or obj:IsA("MeshPart") then
               for _, child in pairs(obj:GetDescendants()) do
                  pcall(function()
                     if child:IsA("TextLabel") and child.Text then
                        local text = child.Text
                        if text:find("Brainrot") or text:find("God") or text:find("Secret") or text:find("\\$") then
                           local target = {
                              parentName = "N/A",
                              parentClass = "N/A",
                              parentPath = "N/A",
                              childName = "N/A",
                              childClass = "N/A",
                              childPath = "N/A",
                              text = text,
                              position = "N/A"
                           }
                           
                           -- Accès sécurisé aux propriétés
                           pcall(function() target.parentName = obj.Name end)
                           pcall(function() target.parentClass = obj.ClassName end)
                           pcall(function() target.parentPath = obj:GetFullName() end)
                           pcall(function() target.childName = child.Name end)
                           pcall(function() target.childClass = child.ClassName end)
                           pcall(function() target.childPath = child:GetFullName() end)
                           
                           if obj:IsA("BasePart") then
                              pcall(function() target.position = tostring(obj.Position) end)
                           end
                           
                           table.insert(brainrotTargets, target)
                           
                           DebugLog("🎯 BRAINROT TARGET:")
                           DebugLog("  📦 Parent: " .. target.parentName .. " (" .. target.parentClass .. ")")
                           DebugLog("  📍 Path: " .. target.parentPath)
                           DebugLog("  📝 Child: " .. target.childName .. " (" .. target.childClass .. ")")
                           DebugLog("  🔗 ChildPath: " .. target.childPath)
                           DebugLog("  💬 Text: '" .. target.text .. "'")
                           DebugLog("  📍 Position: " .. target.position)
                           DebugLog("---")
                        end
                     end
                  end)
               end
            end
         end)
      end
      
      -- 2. LEADERSTATS ANALYSIS
      DebugLog("--- 💰 LEADERSTATS PRÉCIS ---")
      if player:FindFirstChild("leaderstats") then
         local leaderstats = player.leaderstats
         DebugLog("📊 Leaderstats trouvé: " .. leaderstats:GetFullName())
         for _, stat in pairs(leaderstats:GetChildren()) do
            DebugLog("  💎 STAT: " .. stat.Name .. " (" .. stat.ClassName .. ")")
            DebugLog("    🔗 Path: " .. stat:GetFullName())
            DebugLog("    💰 Value: " .. tostring(stat.Value))
            DebugLog("    🏷️ ValueType: " .. typeof(stat.Value))
         end
      else
         DebugLog("❌ Aucun leaderstats trouvé")
      end
      
      -- 3. GUI MONEY DETECTION
      DebugLog("--- 💳 GUI MONEY PRÉCIS ---")
      local moneyGUIs = {}
      for _, gui in pairs(player.PlayerGui:GetDescendants()) do
         pcall(function()
            if gui:IsA("TextLabel") and gui.Text and gui.Text:find("\\$") then
               local moneyTarget = {
                  name = "N/A",
                  class = "N/A",
                  path = "N/A",
                  text = "N/A",
                  parent = "N/A",
                  parentPath = "N/A"
               }
               
               -- Accès sécurisé aux propriétés
               pcall(function() moneyTarget.name = gui.Name end)
               pcall(function() moneyTarget.class = gui.ClassName end)
               pcall(function() moneyTarget.path = gui:GetFullName() end)
               pcall(function() moneyTarget.text = gui.Text end)
               pcall(function() moneyTarget.parent = gui.Parent.Name end)
               pcall(function() moneyTarget.parentPath = gui.Parent:GetFullName() end)
               
               table.insert(moneyGUIs, moneyTarget)
               
               DebugLog("💳 MONEY GUI:")
               DebugLog("  📝 Name: " .. moneyTarget.name)
               DebugLog("  🔗 Path: " .. moneyTarget.path)
               DebugLog("  💬 Text: '" .. moneyTarget.text .. "'")
               DebugLog("  📦 Parent: " .. moneyTarget.parent)
               DebugLog("---")
            end
         end)
      end
      
      -- 4. REMOTE EVENTS PRÉCIS
      DebugLog("--- 📡 REMOTE EVENTS PRÉCIS ---")
      local remoteTargets = {}
      for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
         pcall(function()
            if remote:IsA("RemoteEvent") or remote:IsA("RemoteFunction") then
               local remoteTarget = {
                  name = "N/A",
                  class = "N/A",
                  path = "N/A",
                  parent = "N/A",
                  parentPath = "N/A"
               }
               
               -- Accès sécurisé aux propriétés
               pcall(function() remoteTarget.name = remote.Name end)
               pcall(function() remoteTarget.class = remote.ClassName end)
               pcall(function() remoteTarget.path = remote:GetFullName() end)
               pcall(function() remoteTarget.parent = remote.Parent.Name end)
               pcall(function() remoteTarget.parentPath = remote.Parent:GetFullName() end)
               
               table.insert(remoteTargets, remoteTarget)
               
               DebugLog("📡 REMOTE:")
               DebugLog("  📝 Name: " .. remoteTarget.name)
               DebugLog("  🏷️ Type: " .. remoteTarget.class)
               DebugLog("  🔗 Path: " .. remoteTarget.path)
               DebugLog("  📦 Parent: " .. remoteTarget.parent)
               DebugLog("---")
            end
         end)
      end
      
      -- 5. PROXIMITY PROMPTS PRÉCIS
      DebugLog("--- 🛒 PROXIMITY PROMPTS PRÉCIS ---")
      local promptTargets = {}
      for _, prompt in pairs(workspace:GetDescendants()) do
         pcall(function()
            if prompt:IsA("ProximityPrompt") then
               local promptTarget = {
                  name = "N/A",
                  path = "N/A", 
                  parent = "N/A",
                  parentPath = "N/A",
                  actionText = "N/A",
                  keycode = "N/A",
                  enabled = "N/A",
                  position = "N/A"
               }
               
               -- Accès sécurisé aux propriétés
               pcall(function() promptTarget.name = prompt.Name end)
               pcall(function() promptTarget.path = prompt:GetFullName() end)
               pcall(function() promptTarget.parent = prompt.Parent.Name end)
               pcall(function() promptTarget.parentPath = prompt.Parent:GetFullName() end)
               pcall(function() promptTarget.actionText = prompt.ActionText end)
               pcall(function() promptTarget.keycode = tostring(prompt.KeyboardKeyCode) end)
               pcall(function() promptTarget.enabled = tostring(prompt.Enabled) end)
               
               if prompt.Parent and prompt.Parent:IsA("BasePart") then
                  pcall(function() promptTarget.position = tostring(prompt.Parent.Position) end)
               end
               
               table.insert(promptTargets, promptTarget)
               
               DebugLog("🛒 PROMPT:")
               DebugLog("  📝 Name: " .. promptTarget.name)
               DebugLog("  🔗 Path: " .. promptTarget.path)
               DebugLog("  📦 Parent: " .. promptTarget.parent)
               DebugLog("  💬 ActionText: '" .. promptTarget.actionText .. "'")
               DebugLog("  ⌨️ KeyCode: " .. promptTarget.keycode)
               DebugLog("  ✅ Enabled: " .. promptTarget.enabled)
               DebugLog("  📍 Position: " .. promptTarget.position)
               DebugLog("---")
            end
         end)
      end
      
      -- 6. MAP STRUCTURE ANALYSIS
      DebugLog("--- 🗺️ MAP STRUCTURE PRÉCISE ---")
      local mapObjects = {}
      for _, obj in pairs(workspace:GetChildren()) do
         pcall(function()
            if obj.Name ~= "Camera" and obj.Name ~= "Terrain" and not obj:IsA("Player") then
               local mapTarget = {
                  name = "N/A",
                  class = "N/A", 
                  path = "N/A",
                  position = "N/A",
                  size = "N/A",
                  material = "N/A",
                  color = "N/A"
               }
               
               -- Accès sécurisé aux propriétés
               pcall(function() mapTarget.name = obj.Name end)
               pcall(function() mapTarget.class = obj.ClassName end)
               pcall(function() mapTarget.path = obj:GetFullName() end)
               
               if obj:IsA("BasePart") then
                  pcall(function() mapTarget.position = tostring(obj.Position) end)
                  pcall(function() mapTarget.size = tostring(obj.Size) end)
                  pcall(function() mapTarget.material = tostring(obj.Material) end)
                  pcall(function() mapTarget.color = tostring(obj.BrickColor) end)
               elseif obj:IsA("Model") then
                  -- CORRECTION: Position pour Models
                  pcall(function() 
                     if obj.PrimaryPart then
                        mapTarget.position = tostring(obj.PrimaryPart.Position)
                     else
                        local pivot = obj:GetPivot()
                        if pivot then
                           mapTarget.position = tostring(pivot.Position)
                        end
                     end
                  end)
               end
               
               table.insert(mapObjects, mapTarget)
               
               DebugLog("🗺️ MAP OBJECT:")
               DebugLog("  📝 Name: " .. mapTarget.name)
               DebugLog("  🏷️ Class: " .. mapTarget.class)
               DebugLog("  🔗 Path: " .. mapTarget.path)
               DebugLog("  📍 Position: " .. mapTarget.position)
               DebugLog("  📏 Size: " .. mapTarget.size)
               DebugLog("  🎨 Material: " .. mapTarget.material)
               DebugLog("  🌈 Color: " .. mapTarget.color)
               DebugLog("---")
            end
         end)
      end
      
      -- 7. RÉSUMÉ TARGETS
      DebugLog("=== 📊 RÉSUMÉ TARGETS PRÉCIS ===")
      DebugLog("🎭 Brainrots trouvés: " .. #brainrotTargets)
      DebugLog("💳 Money GUIs trouvés: " .. #moneyGUIs)
      DebugLog("📡 Remote Events trouvés: " .. #remoteTargets)
      DebugLog("🛒 Proximity Prompts trouvés: " .. #promptTargets)
      DebugLog("🗺️ Map Objects trouvés: " .. #mapObjects)
      DebugLog("=== 🎯 FULL DEBUG ANALYSIS END ===")
   end,
})

local FalsePositivesButton = DebugTab:CreateButton({
   Name = "🚨 Debug Faux Positifs",
   Callback = function()
      DebugLog("🚨 ANALYSE FAUX POSITIFS BRAINROTS:")
      
      local suspects = {}
      for _, obj in pairs(workspace:GetDescendants()) do
         pcall(function()
            if obj:IsA("Model") or obj:IsA("Part") then
               -- Chercher les objets suspects
               for _, child in pairs(obj:GetDescendants()) do
                  pcall(function()
                     if child:IsA("TextLabel") and child.Text then
                        local text = child.Text
                        if text:find("Secret") or text:find("God") or text:find("Codes") or text:find("Main") then
                           table.insert(suspects, {
                              objectName = obj.Name,
                              objectClass = obj.ClassName,
                              objectPath = obj:GetFullName(),
                              labelText = text,
                              labelPath = child:GetFullName()
                           })
                        end
                     end
                  end)
               end
            end
         end)
      end
      
      DebugLog("🔍 OBJETS SUSPECTS TROUVÉS: " .. #suspects)
      for i, suspect in pairs(suspects) do
         DebugLog("🚨 SUSPECT " .. i .. ":")
         DebugLog("  📦 Objet: " .. suspect.objectName .. " (" .. suspect.objectClass .. ")")
         DebugLog("  🔗 Path: " .. suspect.objectPath)
         DebugLog("  💬 Texte: '" .. suspect.labelText .. "'")
         DebugLog("  📍 Label: " .. suspect.labelPath)
         
         -- Analyser si c'est un vrai brainrot ou un faux positif
         local isReal = suspect.labelText:find("Brainrot God") or 
                       (suspect.labelText:find("Secret") and not suspect.labelText:find("Codes") and suspect.objectName ~= "Codes")
         DebugLog("  ✅ Verdict: " .. (isReal and "VRAI BRAINROT" or "❌ FAUX POSITIF"))
         DebugLog("---")
      end
   end,
})

local QuickTargetsButton = DebugTab:CreateButton({
   Name = "⚡ TARGETS RAPIDES",
   Callback = function()
      DebugLog("=== ⚡ QUICK TARGETS ===")
      
      -- TARGETS RAPIDES POUR EXPLOIT
      DebugLog("🎯 COPY-PASTE TARGETS:")
      
      -- Leaderstats target
      if player:FindFirstChild("leaderstats") then
         for _, stat in pairs(player.leaderstats:GetChildren()) do
            if stat.Name:lower():find("cash") or stat.Name:lower():find("money") then
               DebugLog("💰 MONEY TARGET: game.Players.LocalPlayer.leaderstats." .. stat.Name .. ".Value")
            end
         end
      end
      
      -- Remote events targets
      for _, remote in pairs(ReplicatedStorage:GetDescendants()) do
         if remote:IsA("RemoteEvent") then
            if remote.Name:find("Buy") or remote.Name:find("Purchase") or remote.Name:find("Steal") then
               DebugLog("📡 REMOTE TARGET: game.ReplicatedStorage:FindFirstChild(\"" .. remote.Name .. "\")")
            end
         end
      end
      
      -- Workspace targets
      for _, obj in pairs(workspace:GetDescendants()) do
         if obj:IsA("ProximityPrompt") then
            DebugLog("🛒 PROMPT TARGET: " .. obj:GetFullName())
         end
      end
      
      DebugLog("=== ⚡ END QUICK TARGETS ===")
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
      DebugLog("📍 DÉBUT DÉTECTION POSITIONS")
      
      pcall(function()
         DetectRedCarpet()
      end)
      
      pcall(function()
         DetectPlayerBase()
      end)
      
      DebugLog("📍 DÉTECTION POSITIONS TERMINÉE")
      DebugLog("🔴 Tapis rouge: " .. (RedCarpetPosition and tostring(RedCarpetPosition) or "Non trouvé"))
      DebugLog("🏠 Base joueur: " .. (PlayerBasePosition and tostring(PlayerBasePosition) or "Non trouvé"))
   end,
})

local MoneyCheckButton = ESPTab:CreateButton({
   Name = "💰 Vérifier Argent Joueur",
   Callback = function()
      DetectPlayerMoney()
      DebugLog("💰 ARGENT DÉTECTÉ: $" .. tostring(PlayerMoney))
      
      -- Debug supplémentaire pour l'argent
      if player:FindFirstChild("leaderstats") then
         DebugLog("📊 Leaderstats trouvé:")
         for _, stat in pairs(player.leaderstats:GetChildren()) do
            DebugLog("  - " .. stat.Name .. ": " .. tostring(stat.Value))
         end
      else
         DebugLog("❌ Aucun leaderstats trouvé")
      end
   end,
})

local DebugWebhookButton = ESPTab:CreateButton({
   Name = "🔧 Debug Webhook Détaillé",
   Callback = function()
      DebugLog("🔍 DEBUG WEBHOOK:")
      DebugLog("  URL configuré: " .. (WebhookConfig.url ~= "" and "✅ Oui" or "❌ Non"))
      DebugLog("  Webhook activé: " .. (WebhookConfig.enabled and "✅ Oui" or "❌ Non"))
      DebugLog("  HttpService disponible: " .. (game:GetService("HttpService") and "✅ Oui" or "❌ Non"))
      
      if WebhookConfig.url ~= "" and WebhookConfig.enabled then
         DebugLog("🧪 Test webhook forcé...")
         local success = SendDiscordWebhook("🔧 Debug Test", "Test depuis bouton debug", 16776960)
         DebugLog("Résultat: " .. (success and "✅ Succès" or "❌ Échec"))
      end
   end,
})

local HttpRequestsTestButton = ESPTab:CreateButton({
   Name = "🌐 Test HttpRequests",
   Callback = function()
      DebugLog("🌐 TEST HTTPREQUESTS:")
      
      local HttpService = game:GetService("HttpService")
      local success, result = pcall(function()
         return HttpService:GetAsync("https://httpbin.org/get")
      end)
      
      if success then
         DebugLog("✅ HttpRequests ACTIVÉ - Fonctionne parfaitement !")
         DebugLog("📡 Response reçue: " .. tostring(result):sub(1, 100) .. "...")
      else
         DebugLog("❌ HttpRequests DÉSACTIVÉ !", "error")
         DebugLog("🔧 SOLUTIONS PAR EXECUTEUR:")
         DebugLog("  • SYNAPSE X: Options → Allow HTTP Requests → ✅")
         DebugLog("  • KRNL: Settings → Enable HTTP Requests → ✅")
         DebugLog("  • SCRIPT-WARE: Settings → HTTP Requests → ON")
         DebugLog("  • FLUXUS: Settings → HTTP → Enable")
         DebugLog("  • DELTA: Options → HTTP Requests → Enable") 
         DebugLog("  • OXYGEN U: Settings → Allow HTTP → ✅")
         DebugLog("📖 Erreur: " .. tostring(result))
      end
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
