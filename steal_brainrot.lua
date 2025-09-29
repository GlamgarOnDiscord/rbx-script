-- 🪐 Steal Brainrot - VERSION COMPLÈTE AMÉLIORÉE
-- Version ultra-avancée avec toutes les fonctionnalités

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Services
local player = game.Players.LocalPlayer
local workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

-- Variables globales
local DebugMode = true
local WebhookUrl = ""
local WalkSpeed = 16
local AutoStealEnabled = false
local AutoFarmMoney = false
local PlayerStatsEnabled = false

-- Statistiques
local Stats = {
    BrainrotsDetected = 0,
    BrainrotsBought = 0,
    MoneyEarned = 0,
    PlayersStolen = 0,
    SessionStart = tick()
}

-- Fonction de debug avec webhook
local function DebugLog(message, level, sendWebhook)
    if not DebugMode then return end
    local prefix = "🪐 DEBUG"
    if level == "warn" then
        prefix = "⚠️ WARN"
        warn(prefix .. ": " .. tostring(message))
    elseif level == "error" then
        prefix = "❌ ERROR"
        print(prefix .. ": " .. tostring(message))
    elseif level == "success" then
        prefix = "✅ SUCCESS"
        print(prefix .. ": " .. tostring(message))
    else
        print(prefix .. ": " .. tostring(message))
    end
    
    -- Envoyer au webhook Discord si activé
    if sendWebhook and WebhookUrl ~= "" then
        SendDiscordWebhook("📊 " .. prefix, tostring(message))
    end
end

-- Fonction webhook Discord
local function SendDiscordWebhook(title, description, color)
    if WebhookUrl == "" then return end
    
    local data = {
        embeds = {{
            title = title,
            description = description,
            color = color or 3447003,
            timestamp = os.date("!%Y-%m-%dT%H:%M:%S.000Z"),
            footer = {
                text = "Steal Brainrot Premium - " .. player.Name
            }
        }}
    }
    
    pcall(function()
        local jsonData = HttpService:JSONEncode(data)
        local request = http_request or request or HttpPost or syn.request
        request({
            Url = WebhookUrl,
            Method = "POST",
            Headers = {["Content-Type"] = "application/json"},
            Body = jsonData
        })
    end)
end

-- Fonction de détection automatique de nouveaux patterns
local function LearnNewPatterns(text)
    local textLower = text:lower()
    
    -- Détecter si c'est une mutation inconnue (contient des mots-clés typiques)
    local mutationKeywords = {"shiny", "glow", "sparkle", "bright", "dark", "light", "metal", "gem"}
    for _, keyword in pairs(mutationKeywords) do
        if textLower:find(keyword) then
            local found = false
            for _, known in pairs(MUTATION_PATTERNS) do
                if textLower:find(known) then found = true break end
            end
            if not found and not DetectedPatterns.mutations[text] then
                DetectedPatterns.mutations[text] = true
                DebugLog("🔍 NOUVELLE MUTATION DÉTECTÉE: " .. text, "success", true)
                table.insert(MUTATION_PATTERNS, textLower)
            end
        end
    end
    
    -- Détecter si c'est une rareté inconnue (format typique de rareté)
    if textLower:match("^%a+$") and #text > 3 and #text < 15 then
        local found = false
        for _, known in pairs(RARITY_PATTERNS) do
            if textLower:find(known) then found = true break end
        end
        if not found and not DetectedPatterns.rarities[text] then
            DetectedPatterns.rarities[text] = true
            DebugLog("🔍 NOUVELLE RARETÉ DÉTECTÉE: " .. text, "success", true)
            table.insert(RARITY_PATTERNS, textLower)
        end
    end
end

-- Interface améliorée
local Window = Rayfield:CreateWindow({
   Name = "🪐 Steal Brainrot PREMIUM",
   LoadingTitle = "Steal Brainrot Premium",
   LoadingSubtitle = "by GlamgarOnDiscord - v2.0",
   ConfigurationSaving = {
      Enabled = true,
      FolderName = "StealBrainrotConfig",
      FileName = "StealBrainrot"
   },
   Discord = {
      Enabled = false,
   },
   KeySystem = false,
})

-- Onglets
local MainTab = Window:CreateTab("🏠 Principal", nil)
local ESPTab = Window:CreateTab("👁️ ESP", nil)
local AutoBuyTab = Window:CreateTab("🛒 Auto Buy", nil)
local AutoStealTab = Window:CreateTab("💰 Auto Steal", nil)
local FarmTab = Window:CreateTab("⚡ Auto Farm", nil)
local StatsTab = Window:CreateTab("📊 Statistiques", nil)
local SettingsTab = Window:CreateTab("⚙️ Paramètres", nil)
local DebugTab = Window:CreateTab("🔍 Debug", nil)

-- Variables globales
local ESPEnabled = false
local AutoBuyEnabled = false
local SelectedRarities = {}
local espBoxes = {}
local detectedBrainrots = {}

-- Cache des modèles potentiels pour éviter de parcourir tout le workspace à chaque fois
local cachedModels = {}

local function TrackModel(obj)
    if obj:IsA("Model") and obj.Name ~= "Carpet" then
        cachedModels[obj] = true
    end
end

local function UntrackModel(obj)
    if cachedModels[obj] then
        cachedModels[obj] = nil
    end
end

-- Remplir le cache initialement
for _, obj in ipairs(workspace:GetDescendants()) do
    TrackModel(obj)
end

-- Mettre à jour le cache dynamiquement
workspace.DescendantAdded:Connect(TrackModel)
workspace.DescendantRemoving:Connect(UntrackModel)

-- Tables de correspondance DYNAMIQUES pour détecter nouvelles raretés/mutations
local MUTATION_PATTERNS = {
    -- Mutations existantes
    "gold", "diamond", "rainbow", "lava", "celestial", "bloodrot", "silver",
    -- Nouvelles mutations potentielles
    "crystal", "plasma", "void", "shadow", "neon", "electric", "fire", "ice",
    "cosmic", "galaxy", "starlight", "aurora", "prismatic", "holographic",
    "obsidian", "titanium", "platinum", "emerald", "ruby", "sapphire",
    "quantum", "nuclear", "radioactive", "magnetic", "corrupted", "blessed"
}

local RARITY_PATTERNS = {
    -- Raretés existantes
    "common", "rare", "epic", "legendary", "mythic", "god", "secret",
    -- Nouvelles raretés potentielles
    "ultimate", "divine", "celestial", "transcendent", "omnipotent", "infinite",
    "eternal", "immortal", "supreme", "absolute", "perfect", "flawless",
    "prime", "apex", "zenith", "pinnacle", "master", "grandmaster"
}

-- Détection automatique de nouveaux patterns
local DetectedPatterns = {
    mutations = {},
    rarities = {}
}

local PRICE_MULTIPLIERS = {
    K = 1000,
    M = 1000000,
    B = 1000000000,
    T = 1000000000000
}

-- Conversion dédiée d'un prix texte en nombre
local function ConvertPrice(priceText)
    local numberStr = priceText:match("(%d+)")
    if not numberStr then return 0 end
    local num = tonumber(numberStr) or 0
    for suffix, multiplier in pairs(PRICE_MULTIPLIERS) do
        if priceText:find(suffix) then
            return num * multiplier
        end
    end
    return num
end



-- Fonction pour créer ESP Box
local function CreateESPBox(obj, text, color)
    -- Supprimer ancien ESP s'il existe
    RemoveESPBox(obj)

    local gui
    local success, err = pcall(function()
        gui = Instance.new("BillboardGui")
    end)
    if not success then
        DebugLog("Erreur création BillboardGui: " .. tostring(err), "error")
        return
    end

    gui.Name = "ESP_" .. obj.Name
    gui.Adornee = obj
    gui.Size = UDim2.new(0, 200, 0, 100)
    gui.StudsOffset = Vector3.new(0, 2, 0)
    gui.AlwaysOnTop = true
    gui.LightInfluence = 0

    -- Cadre principal
    local frame
    success, err = pcall(function()
        frame = Instance.new("Frame")
    end)
    if not success then
        DebugLog("Erreur création Frame: " .. tostring(err), "error")
        return
    end

    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.BackgroundTransparency = 0.7
    frame.BackgroundColor3 = color
    frame.BorderSizePixel = 2
    frame.BorderColor3 = color
    frame.Parent = gui

    -- Texte
    local label
    success, err = pcall(function()
        label = Instance.new("TextLabel")
    end)
    if not success then
        DebugLog("Erreur création TextLabel: " .. tostring(err), "error")
        return
    end

    label.Size = UDim2.new(1, 0, 1, 0)
    label.BackgroundTransparency = 1
    label.Text = text
    label.TextColor3 = Color3.new(1, 1, 1)
    label.TextScaled = true
    label.TextStrokeTransparency = 0
    label.TextStrokeColor3 = Color3.new(0, 0, 0)
    label.Font = Enum.Font.GothamBold
    label.Parent = frame

    local parentSuccess, parentErr = pcall(function()
        gui.Parent = game.CoreGui
    end)
    if not parentSuccess then
        DebugLog("Erreur assignation parent GUI: " .. tostring(parentErr), "error")
        return
    end

    espBoxes[obj] = gui
end

-- Fonction pour supprimer ESP Box
local function RemoveESPBox(obj)
    if espBoxes[obj] then
        local success, err = pcall(function()
            espBoxes[obj]:Destroy()
        end)
        if not success then
            DebugLog("Erreur destruction ESPBox: " .. tostring(err), "error")
        end
        espBoxes[obj] = nil
    end
end

-- L'ordre de priorité des tests est important :
-- mutation > rareté > revenu > prix > stolen > nom
local function ParseBrainrotTexts(texts)
    local brainrot = {
        mutation = "None",
        rarity = "Unknown",
        revenue = "N/A",
        price = "N/A",
        priceNumber = 0,
        stolen = false,
        name = "Unknown"
    }

    DebugLog("📝 Parsing textes: " .. table.concat(texts, ", "))

    for _, text in pairs(texts) do
        local textLower = text:lower()
        local processed = false
        
        -- Apprendre de nouveaux patterns
        LearnNewPatterns(text)

        -- 1. Mutations (détection améliorée)
        for _, pattern in ipairs(MUTATION_PATTERNS) do
            if textLower:find(pattern) then
                brainrot.mutation = text
                DebugLog("✨ Mutation trouvée: " .. text)
                processed = true
                break
            end
        end

        -- 2. Rareté (détection améliorée)
        if not processed then
            for _, pattern in ipairs(RARITY_PATTERNS) do
                if textLower:find(pattern) then
                    brainrot.rarity = text
                    DebugLog("🎨 Rareté trouvée: " .. text)
                    processed = true
                    break
                end
            end
        end

        -- 3. Génération d'argent ($/s)
        if not processed and (text:find("$/s") or text:find("%$%d+/s")) then
            brainrot.revenue = text
            DebugLog("💸 Revenu trouvé: " .. text)
            processed = true
        end

        -- 4. Prix d'achat ($1K, $500, etc.)
        if not processed and text:find("%$") and not text:find("/s") then
            brainrot.price = text
            brainrot.priceNumber = ConvertPrice(text)
            DebugLog("💰 Prix trouvé: " .. text)
            processed = true
        end

        -- 5. STOLEN
        if not processed and textLower:find("stolen") then
            brainrot.stolen = true
            DebugLog("🚨 STOLEN détecté")
            processed = true
        end

        -- 6. NOM - Tout ce qui reste et qui semble être un nom
        if not processed and text ~= "" and not text:find("%$") and not text:find("/s") then
            brainrot.name = text
            DebugLog("📝 Nom trouvé: " .. text)
        end
    end

    DebugLog("📊 Résultat parsing: " .. brainrot.name .. " | " .. brainrot.rarity .. " | " .. brainrot.price .. " | " .. brainrot.mutation)
    
    -- Mettre à jour les statistiques
    Stats.BrainrotsDetected = Stats.BrainrotsDetected + 1
    
    return brainrot
end

-- Fonction Auto Steal Players
local function AutoStealPlayers()
    if not AutoStealEnabled then return end
    
    for _, otherPlayer in pairs(game.Players:GetPlayers()) do
        if otherPlayer ~= player and otherPlayer.Character then
            local humanoidRootPart = otherPlayer.Character:FindFirstChild("HumanoidRootPart")
            local myRootPart = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
            
            if humanoidRootPart and myRootPart then
                local distance = (humanoidRootPart.Position - myRootPart.Position).Magnitude
                
                if distance < 50 then -- Proche du joueur
                    DebugLog("🎯 Tentative de vol: " .. otherPlayer.Name .. " (Distance: " .. math.floor(distance) .. ")")
                    
                    -- Chercher RemoteEvents de vol
                    for _, obj in pairs(game.ReplicatedStorage:GetDescendants()) do
                        if obj:IsA("RemoteEvent") then
                            local name = obj.Name:lower()
                            if name:find("steal") or name:find("rob") or name:find("take") then
                                pcall(function()
                                    obj:FireServer(otherPlayer)
                                    Stats.PlayersStolen = Stats.PlayersStolen + 1
                                    DebugLog("💰 Vol réussi sur: " .. otherPlayer.Name, "success", true)
                                end)
                                task.wait(1)
                            end
                        end
                    end
                end
            end
        end
    end
end

-- Fonction Auto Farm Money
local function AutoFarmMoney()
    if not AutoFarmMoney then return end
    
    local moneyItems = {}
    
    -- Chercher objets d'argent
    for _, obj in pairs(workspace:GetDescendants()) do
        if obj:IsA("BasePart") then
            local name = obj.Name:lower()
            if name:find("cash") or name:find("money") or name:find("coin") or name:find("dollar") then
                table.insert(moneyItems, obj)
            end
        end
    end
    
    -- Téléporter vers les objets d'argent
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        for _, item in pairs(moneyItems) do
            if AutoFarmMoney and item.Parent then
                player.Character.HumanoidRootPart.CFrame = item.CFrame
                task.wait(0.5)
                Stats.MoneyEarned = Stats.MoneyEarned + 1
                DebugLog("💰 Argent collecté: " .. item.Name)
            end
        end
    end
end

-- Fonction de mise à jour des statistiques
local function UpdatePlayerStats()
    if not PlayerStatsEnabled then return end
    
    local sessionTime = math.floor(tick() - Stats.SessionStart)
    local hours = math.floor(sessionTime / 3600)
    local minutes = math.floor((sessionTime % 3600) / 60)
    local seconds = sessionTime % 60
    
    local timeString = string.format("%02d:%02d:%02d", hours, minutes, seconds)
    
    DebugLog("📊 STATS - Temps: " .. timeString .. " | Brainrots: " .. Stats.BrainrotsDetected .. 
             " | Achats: " .. Stats.BrainrotsBought .. " | Vols: " .. Stats.PlayersStolen)
end

-- Fonction pour détecter tous les brainrots
local function DetectAllBrainrots()
    detectedBrainrots = {}
    
    -- Chercher le tapis
    local carpet = nil
    local map = workspace:FindFirstChild("Map")
    if map then carpet = map:FindFirstChild("Carpet") end
    
    if not carpet then
        DebugLog("❌ Tapis non trouvé pour ESP", "warn")
        return {}
    end
    
    local carpetPos = carpet.Position
    
    -- Scanner uniquement les modèles en cache
    for obj, _ in pairs(cachedModels) do
        pcall(function()
            if obj and obj.Parent and obj ~= carpet then
                local modelPos = nil
                if obj.PrimaryPart then
                    modelPos = obj.PrimaryPart.Position
                else
                    pcall(function()
                        local pivot = obj:GetPivot()
                        if pivot then modelPos = pivot.Position end
                    end)
                end

                if modelPos and (modelPos - carpetPos).Magnitude < 100 then
                    -- Collecter tous les textes
                    local texts = {}
                    for _, child in pairs(obj:GetDescendants()) do
                        if child:IsA("TextLabel") and child.Text ~= "" then
                            table.insert(texts, child.Text)
                        end
                    end

                    -- Si 6 textes trouvés, c'est probablement un brainrot
                    if #texts >= 5 then -- Au moins 5 textes pour être sûr
                        local brainrotData = ParseBrainrotTexts(texts)
                        brainrotData.object = obj
                        brainrotData.position = modelPos
                        brainrotData.allTexts = texts

                        table.insert(detectedBrainrots, brainrotData)

                        DebugLog("🎯 Brainrot détecté: " .. brainrotData.name .. " | " .. brainrotData.rarity .. " | " .. brainrotData.price)
                    end
                end
            else
                -- Retirer les objets éloignés du cache
                cachedModels[obj] = nil
            end
        end)
    end
    
    DebugLog("📊 Total brainrots détectés: " .. #detectedBrainrots)
    return detectedBrainrots
end

-- Fonction pour mettre à jour l'ESP
local function UpdateESP()
    if not ESPEnabled then return end
    
    -- Nettoyer ancien ESP
    for obj, gui in pairs(espBoxes) do
        RemoveESPBox(obj)
    end
    
    -- Détecter brainrots
    local brainrots = DetectAllBrainrots()
    
    -- Créer ESP pour chaque brainrot
    for _, brainrot in pairs(brainrots) do
        local espText = brainrot.rarity .. " - " .. brainrot.name
        if brainrot.price ~= "N/A" then
            espText = espText .. "\n💰 " .. brainrot.price
        end
        if brainrot.mutation ~= "None" then
            espText = espText .. "\n✨ " .. brainrot.mutation
        end
        if brainrot.stolen then
            espText = espText .. "\n🚨 STOLEN"
        end
        
        -- Couleur selon rareté
        local color = Color3.fromRGB(200, 200, 200) -- Gris par défaut
        if brainrot.rarity:find("God") then
            color = Color3.fromRGB(255, 215, 0) -- Or
        elseif brainrot.rarity:find("Secret") then
            color = Color3.fromRGB(255, 255, 255) -- Blanc
        elseif brainrot.rarity == "Legendary" then
            color = Color3.fromRGB(255, 140, 0) -- Orange
        elseif brainrot.rarity == "Mythic" then
            color = Color3.fromRGB(255, 0, 0) -- Rouge
        elseif brainrot.rarity == "Epic" then
            color = Color3.fromRGB(128, 0, 255) -- Violet
        elseif brainrot.rarity == "Rare" then
            color = Color3.fromRGB(0, 100, 255) -- Bleu
        elseif brainrot.rarity == "Common" then
            color = Color3.fromRGB(255, 255, 255) -- Blanc
        end
        
        CreateESPBox(brainrot.object, espText, color)
    end
    
    DebugLog("✅ ESP mis à jour: " .. #brainrots .. " brainrots affichés")
end

-- Fonction pour trouver la base du joueur
local function FindPlayerBase()
    -- Chercher base avec "structure base home"
    for _, obj in pairs(workspace:GetDescendants()) do
        pcall(function()
            if obj:IsA("Model") or obj:IsA("BasePart") then
                local objName = obj.Name:lower()
                if objName:find("structure") and objName:find("base") and objName:find("home") then
                    local position = nil
                    if obj:IsA("BasePart") then
                        position = obj.Position
                    elseif obj:IsA("Model") and obj.PrimaryPart then
                        position = obj.PrimaryPart.Position
                    end
                    
                    if position then
                        DebugLog("🏠 Base trouvée: " .. obj:GetFullName() .. " à " .. tostring(position))
                        return position
                    end
                end
            end
        end)
    end
    
    -- Fallback: position actuelle
    if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
        return player.Character.HumanoidRootPart.Position
    end
    
    return nil
end

-- Fonction Auto Buy avec suivi amélioré
local function AutoBuyBrainrots()
    if not AutoBuyEnabled then return end
    
    local brainrots = DetectAllBrainrots()
    local targetBrainrots = {}
    
    -- Filtrer selon les raretés sélectionnées
    for _, brainrot in pairs(brainrots) do
        for rarity, selected in pairs(SelectedRarities) do
            if selected and brainrot.rarity:find(rarity) then
                table.insert(targetBrainrots, brainrot)
                break
            end
        end
    end
    
    -- Trier par priorité (God > Secret > Legendary > Mythic > Epic > Rare > Common)
    local rarityPriority = {
        ["God"] = 7,
        ["Secret"] = 6,
        ["Legendary"] = 5,
        ["Mythic"] = 4,
        ["Epic"] = 3,
        ["Rare"] = 2,
        ["Common"] = 1
    }
    
    table.sort(targetBrainrots, function(a, b)
        local priorityA = 0
        local priorityB = 0
        
        for rarity, priority in pairs(rarityPriority) do
            if a.rarity:find(rarity) then priorityA = priority end
            if b.rarity:find(rarity) then priorityB = priority end
        end
        
        return priorityA > priorityB
    end)
    
    -- Acheter et suivre le premier brainrot disponible
    for _, brainrot in pairs(targetBrainrots) do
        if not AutoBuyEnabled then
            DebugLog("⛔ Auto Buy interrompu (désactivé)")
            return
        end

        if not brainrot.stolen then
            DebugLog("🛒 Processus d'achat: " .. brainrot.name .. " (" .. brainrot.rarity .. ") - " .. brainrot.price)
            
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                local character = player.Character
                local humanoidRootPart = character.HumanoidRootPart
                
                -- Étape 1: Aller à côté du brainrot
                DebugLog("📍 Étape 1: Se téléporter à côté du brainrot")
                local nearPosition = brainrot.position + Vector3.new(3, 2, 3)
                humanoidRootPart.CFrame = CFrame.new(nearPosition)
                task.wait(1)
                
                -- Étape 2: Essayer d'acheter avec E
                DebugLog("💰 Étape 2: Tentative d'achat avec E")
                local VirtualInputManager = game:GetService("VirtualInputManager")
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                task.wait(0.1)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                task.wait(1)
                
                -- Étape 3: Suivre le brainrot vers la base
                DebugLog("🏃 Étape 3: Suivi du brainrot vers la base")
                local basePosition = FindPlayerBase()
                
                if basePosition then
                    for i = 1, 20 do
                        if not AutoBuyEnabled then
                            DebugLog("⛔ Suivi interrompu (Auto Buy désactivé)")
                            return
                        end
                        
                        pcall(function()
                            if brainrot.object and brainrot.object.Parent then
                                local currentBrainrotPos = nil
                                
                                if brainrot.object.PrimaryPart then
                                    currentBrainrotPos = brainrot.object.PrimaryPart.Position
                                else
                                    local pivot = brainrot.object:GetPivot()
                                    if pivot then currentBrainrotPos = pivot.Position end
                                end

                                if currentBrainrotPos then
                                    local followPos = currentBrainrotPos + Vector3.new(2, 1, 2)
                                    humanoidRootPart.CFrame = CFrame.new(followPos)
                                    
                                    local distanceToBase = (currentBrainrotPos - basePosition).Magnitude
                                    if distanceToBase < 20 then
                                        DebugLog("🏠 Brainrot arrivé à la base !")
                                        Stats.BrainrotsBought = Stats.BrainrotsBought + 1
                                        SendDiscordWebhook("🛒 Achat Réussi", 
                                            "Brainrot acheté: " .. brainrot.name .. " (" .. brainrot.rarity .. ")", 65280)
                                        return
                                    end
                                end
                            end
                        end)
                        
                        task.wait(1)
                    end
                end
                
                break
            end
        end
    end
end

-- === ONGLETS ===

-- Onglet Principal
local WelcomeSection = MainTab:CreateSection("🏠 Bienvenue")

MainTab:CreateLabel("🪐 Steal Brainrot Premium v2.0")
MainTab:CreateLabel("💫 Créé par GlamgarOnDiscord")
MainTab:CreateLabel("🚀 Version complète avec toutes les fonctionnalités premium")

local StatusSection = MainTab:CreateSection("📊 Status Actuel")

local StatusLabel = MainTab:CreateLabel("🔴 Systèmes: Arrêtés")

-- Fonction pour mettre à jour le status
local function UpdateStatus()
    local activeFeatures = {}
    if ESPEnabled then table.insert(activeFeatures, "ESP") end
    if AutoBuyEnabled then table.insert(activeFeatures, "Auto Buy") end
    if AutoStealEnabled then table.insert(activeFeatures, "Auto Steal") end
    if AutoFarmMoney then table.insert(activeFeatures, "Auto Farm") end
    
    if #activeFeatures > 0 then
        StatusLabel.Text = "🟢 Actifs: " .. table.concat(activeFeatures, ", ")
    else
        StatusLabel.Text = "🔴 Systèmes: Arrêtés"
    end
end

local QuickStartSection = MainTab:CreateSection("⚡ Démarrage Rapide")

local QuickESPButton = MainTab:CreateButton({
   Name = "👁️ Activer ESP Rapide",
   Callback = function()
      ESPEnabled = true
      DebugLog("👁️ ESP ACTIVÉ via démarrage rapide")
      spawn(function()
         while ESPEnabled do
            UpdateESP()
            task.wait(3)
         end
      end)
   end,
})

local QuickBuyButton = MainTab:CreateButton({
   Name = "🛒 Auto Buy God+Secret",
   Callback = function()
      SelectedRarities["God"] = true
      SelectedRarities["Secret"] = true
      AutoBuyEnabled = true
      DebugLog("🛒 AUTO BUY ACTIVÉ (God + Secret)")
      spawn(function()
         while AutoBuyEnabled do
            AutoBuyBrainrots()
            task.wait(10)
         end
      end)
   end,
})

-- ESP Tab
local ESPConfigSection = ESPTab:CreateSection("⚙️ Configuration ESP")

local ESPToggle = ESPTab:CreateToggle({
   Name = "👁️ ESP Brainrots",
   CurrentValue = false,
   Callback = function(Value)
      ESPEnabled = Value
      UpdateStatus()
      if Value then
         DebugLog("👁️ ESP ACTIVÉ")
         spawn(function()
            while ESPEnabled do
               UpdateESP()
               task.wait(3)
            end
         end)
      else
         DebugLog("👁️ ESP DÉSACTIVÉ")
         for obj, gui in pairs(espBoxes) do
            RemoveESPBox(obj)
         end
      end
   end,
})

local ESPDistanceSlider = ESPTab:CreateSlider({
   Name = "📏 Distance ESP (studs)",
   Range = {50, 500},
   Increment = 10,
   Suffix = " studs",
   CurrentValue = 100,
   Callback = function(Value)
      DebugLog("📏 Distance ESP: " .. Value .. " studs")
   end,
})

-- Auto Steal Tab
local AutoStealSection = AutoStealTab:CreateSection("🎯 Configuration Auto Steal")

local AutoStealToggle = AutoStealTab:CreateToggle({
   Name = "💰 Auto Steal Players",
   CurrentValue = false,
   Callback = function(Value)
      AutoStealEnabled = Value
      UpdateStatus()
      if Value then
         DebugLog("💰 AUTO STEAL ACTIVÉ")
         spawn(function()
            while AutoStealEnabled do
               AutoStealPlayers()
               task.wait(5)
            end
         end)
      else
         DebugLog("💰 AUTO STEAL DÉSACTIVÉ")
      end
   end,
})

local StealDistanceSlider = AutoStealTab:CreateSlider({
   Name = "📏 Distance Vol (studs)",
   Range = {10, 100},
   Increment = 5,
   Suffix = " studs",
   CurrentValue = 50,
   Callback = function(Value)
      DebugLog("📏 Distance vol: " .. Value .. " studs")
   end,
})

-- Farm Tab
local FarmSection = FarmTab:CreateSection("⚡ Configuration Farm")

local AutoFarmToggle = FarmTab:CreateToggle({
   Name = "💰 Auto Farm Money",
   CurrentValue = false,
   Callback = function(Value)
      AutoFarmMoney = Value
      UpdateStatus()
      if Value then
         DebugLog("💰 AUTO FARM ACTIVÉ")
         spawn(function()
            while AutoFarmMoney do
               AutoFarmMoney()
               task.wait(3)
            end
         end)
      else
         DebugLog("💰 AUTO FARM DÉSACTIVÉ")
      end
   end,
})

local WalkSpeedSlider = FarmTab:CreateSlider({
   Name = "🏃 Vitesse de Marche",
   Range = {16, 100},
   Increment = 1,
   Suffix = " studs/s",
   CurrentValue = 16,
   Callback = function(Value)
      WalkSpeed = Value
      if player.Character and player.Character:FindFirstChild("Humanoid") then
         player.Character.Humanoid.WalkSpeed = Value
      end
      DebugLog("🏃 Vitesse: " .. Value .. " studs/s")
   end,
})

-- Stats Tab
local StatsSection = StatsTab:CreateSection("📊 Statistiques en Temps Réel")

local StatsToggle = StatsTab:CreateToggle({
   Name = "📊 Afficher Statistiques",
   CurrentValue = false,
   Callback = function(Value)
      PlayerStatsEnabled = Value
      if Value then
         spawn(function()
            while PlayerStatsEnabled do
               UpdatePlayerStats()
               task.wait(10)
            end
         end)
      end
   end,
})

StatsTab:CreateLabel("🎯 Brainrots Détectés: " .. Stats.BrainrotsDetected)
StatsTab:CreateLabel("🛒 Brainrots Achetés: " .. Stats.BrainrotsBought)
StatsTab:CreateLabel("💰 Argent Collecté: " .. Stats.MoneyEarned)
StatsTab:CreateLabel("👥 Joueurs Volés: " .. Stats.PlayersStolen)

-- Settings Tab
local WebhookSection = SettingsTab:CreateSection("🔗 Webhook Discord")

local WebhookInput = SettingsTab:CreateInput({
   Name = "🔗 URL Webhook Discord",
   PlaceholderText = "https://discord.com/api/webhooks/...",
   RemoveTextAfterFocusLost = false,
   Callback = function(Text)
      WebhookUrl = Text
      DebugLog("🔗 Webhook configuré")
   end,
})

local TestWebhookButton = SettingsTab:CreateButton({
   Name = "🧪 Tester Webhook",
   Callback = function()
      SendDiscordWebhook("🧪 Test Webhook", "Webhook fonctionnel ! ✅", 65280)
      DebugLog("🧪 Test webhook envoyé")
   end,
})

local GeneralSection = SettingsTab:CreateSection("⚙️ Paramètres Généraux")

local DebugToggle = SettingsTab:CreateToggle({
   Name = "🔍 Mode Debug",
   CurrentValue = true,
   Callback = function(Value)
      DebugMode = Value
      DebugLog("🔍 Debug: " .. (Value and "ACTIVÉ" or "DÉSACTIVÉ"))
   end,
})

-- Auto Buy Tab
local RaritySection = AutoBuyTab:CreateSection("🎯 Sélection des Raretés")

AutoBuyTab:CreateLabel("Sélectionnez les raretés à acheter automatiquement:")

-- Toggles pour chaque rareté avec émojis
local rarities = {
    {name = "God", emoji = "👑", color = "Or"},
    {name = "Secret", emoji = "🔮", color = "Blanc"},
    {name = "Legendary", emoji = "🧡", color = "Orange"},
    {name = "Mythic", emoji = "❤️", color = "Rouge"},
    {name = "Epic", emoji = "💜", color = "Violet"},
    {name = "Rare", emoji = "💙", color = "Bleu"},
    {name = "Common", emoji = "🤍", color = "Blanc"}
}

for _, rarity in pairs(rarities) do
    local toggle = AutoBuyTab:CreateToggle({
        Name = rarity.emoji .. " " .. rarity.name .. " (" .. rarity.color .. ")",
        CurrentValue = false,
        Callback = function(Value)
            SelectedRarities[rarity.name] = Value
            DebugLog("🎯 " .. rarity.name .. ": " .. (Value and "ACTIVÉ" or "DÉSACTIVÉ"))
        end,
    })
end

local AutoBuyConfigSection = AutoBuyTab:CreateSection("⚙️ Configuration Auto Buy")

local AutoBuyDelaySlider = AutoBuyTab:CreateSlider({
   Name = "⏱️ Délai entre achats (secondes)",
   Range = {5, 60},
   Increment = 5,
   Suffix = "s",
   CurrentValue = 10,
   Callback = function(Value)
      DebugLog("⏱️ Délai Auto Buy: " .. Value .. "s")
   end,
})

local AutoBuyToggle = AutoBuyTab:CreateToggle({
   Name = "🛒 Activer Auto Buy",
   CurrentValue = false,
   Callback = function(Value)
      AutoBuyEnabled = Value
      UpdateStatus()
      if Value then
         DebugLog("🛒 AUTO BUY ACTIVÉ")
         spawn(function()
            while AutoBuyEnabled do
               AutoBuyBrainrots()
               task.wait(10) -- Vérifier toutes les 10 secondes pour éviter spam
            end
         end)
      else
         DebugLog("🛒 AUTO BUY DÉSACTIVÉ")
      end
   end,
})

-- === BOUTONS DEBUG ===

-- 1. Debug tous les Parts et Carpet
local AllPartsButton = DebugTab:CreateButton({
   Name = "🧩 Debug Tous Parts + Carpet",
   Callback = function()
      DebugLog("=== 🧩 DEBUG TOUS PARTS + CARPET ===")
      
      local partCount = 0
      local carpetFound = false
      
      for _, obj in pairs(workspace:GetDescendants()) do
         pcall(function()
            if obj:IsA("BasePart") then
               partCount = partCount + 1
               
               -- Chercher spécifiquement "Carpet"
               if obj.Name:lower():find("carpet") then
                  carpetFound = true
                  DebugLog("🔴 CARPET TROUVÉ: " .. obj:GetFullName())
                  DebugLog("  📍 Position: " .. tostring(obj.Position))
                  DebugLog("  📏 Taille: " .. tostring(obj.Size))
                  DebugLog("  🎨 Couleur: " .. tostring(obj.BrickColor))
                  DebugLog("  🧱 Matériau: " .. tostring(obj.Material))
               end
               
               -- Limiter l'affichage pour pas spam
               if partCount <= 50 then
                  DebugLog("🧩 Part: " .. obj.Name .. " | " .. obj:GetFullName())
               end
            end
         end)
      end
      
      DebugLog("📊 Total Parts trouvés: " .. partCount)
      DebugLog("🔴 Carpet trouvé: " .. (carpetFound and "✅ OUI" or "❌ NON"))
      DebugLog("=== FIN DEBUG PARTS ===")
   end,
})

-- 2. Debug Models avec textes spécifiques
local SpecificTextsButton = DebugTab:CreateButton({
   Name = "📝 Models avec Textes Spécifiques",
   Callback = function()
      DebugLog("=== 📝 MODELS AVEC TEXTES SPÉCIFIQUES ===")
      
      local targetTexts = {
         "Mythic", "Legendary", "Common", "Epic", "Rare", "Brainrot God", "Secret"
      }
      
      local foundModels = {}
      
      -- Scanner tous les Models
      for _, obj in pairs(workspace:GetDescendants()) do
         pcall(function()
            if obj:IsA("Model") then
               local modelTexts = {}
               local hasTargetText = false
               
               -- Chercher TextLabels dans ce Model
               for _, child in pairs(obj:GetDescendants()) do
                  pcall(function()
                     if child:IsA("TextLabel") and child.Text and child.Text ~= "" then
                        table.insert(modelTexts, child.Text)
                        
                        -- Vérifier si c'est un texte cible
                        for _, target in pairs(targetTexts) do
                           if child.Text:find(target) then
                              hasTargetText = true
                           end
                        end
                     end
                  end)
               end
               
               -- Si le Model a un texte cible, l'afficher
               if hasTargetText then
                  table.insert(foundModels, {
                     model = obj,
                     texts = modelTexts
                  })
                  
                  DebugLog("🎯 MODEL TROUVÉ: " .. obj.Name)
                  DebugLog("  🔗 Path: " .. obj:GetFullName())
                  DebugLog("  📝 Textes (" .. #modelTexts .. "):")
                  for i, text in pairs(modelTexts) do
                     -- Marquer les textes cibles
                     local isTarget = false
                     for _, target in pairs(targetTexts) do
                        if text:find(target) then
                           isTarget = true
                           break
                        end
                     end
                     DebugLog("    " .. i .. ". '" .. text .. "'" .. (isTarget and " ⭐ TARGET" or ""))
                  end
                  DebugLog("  📍 Position: " .. (obj.PrimaryPart and tostring(obj.PrimaryPart.Position) or "N/A"))
               end
            end
         end)
      end
      
      DebugLog("📊 Models avec textes cibles: " .. #foundModels)
      DebugLog("🎯 Textes recherchés: " .. table.concat(targetTexts, ", "))
      DebugLog("=== FIN DEBUG TEXTES ===")
   end,
})

-- 3. Debug spécifique Workspace.Map.Carpet
local CarpetPathButton = DebugTab:CreateButton({
   Name = "🔴 Test Workspace.Map.Carpet",
   Callback = function()
      DebugLog("=== 🔴 TEST WORKSPACE.MAP.CARPET ===")
      
      -- Test path exact
      local map = workspace:FindFirstChild("Map")
      if map then
         DebugLog("✅ Map trouvé: " .. map:GetFullName())
         
         local carpet = map:FindFirstChild("Carpet")
         if carpet then
            DebugLog("✅ Carpet trouvé: " .. carpet:GetFullName())
            DebugLog("  📍 Position: " .. tostring(carpet.Position))
            DebugLog("  📏 Taille: " .. tostring(carpet.Size))
            DebugLog("  🎨 Couleur: " .. tostring(carpet.BrickColor))
            DebugLog("  🧱 Matériau: " .. tostring(carpet.Material))
            DebugLog("  📦 Type: " .. carpet.ClassName)
         else
            DebugLog("❌ Carpet pas trouvé dans Map")
            DebugLog("📁 Contenu de Map:")
            for _, child in pairs(map:GetChildren()) do
               DebugLog("  - " .. child.Name .. " (" .. child.ClassName .. ")")
            end
         end
      else
         DebugLog("❌ Map pas trouvé dans Workspace")
         DebugLog("📁 Contenu de Workspace (50 premiers):")
         local count = 0
         for _, child in pairs(workspace:GetChildren()) do
            count = count + 1
            if count <= 50 then
               DebugLog("  - " .. child.Name .. " (" .. child.ClassName .. ")")
            end
         end
      end
      
      DebugLog("=== FIN TEST CARPET ===")
   end,
})

-- 4. Debug spécifique Workspace.movingAnimals
local MovingAnimalsButton = DebugTab:CreateButton({
   Name = "🐾 Test Workspace.movingAnimals",
   Callback = function()
      DebugLog("=== 🐾 TEST WORKSPACE.MOVINGANIMALS ===")
      
      local movingAnimals = workspace:FindFirstChild("movingAnimals")
      if movingAnimals then
         DebugLog("✅ movingAnimals trouvé: " .. movingAnimals:GetFullName())
         DebugLog("📦 Nombre d'enfants: " .. #movingAnimals:GetChildren())
         
         for _, child in pairs(movingAnimals:GetChildren()) do
            pcall(function()
               if child:IsA("Model") then
                  DebugLog("📦 Model: " .. child.Name)
                  
                  -- Chercher HumanoidRootPart
                  local humanoidRootPart = child:FindFirstChild("HumanoidRootPart")
                  if humanoidRootPart then
                     DebugLog("  ✅ HumanoidRootPart: " .. humanoidRootPart:GetFullName())
                  else
                     DebugLog("  ❌ Pas de HumanoidRootPart")
                  end
                  
                  -- Compter et lister TextLabels
                  local textLabels = {}
                  for _, desc in pairs(child:GetDescendants()) do
                     if desc:IsA("TextLabel") and desc.Text ~= "" then
                        table.insert(textLabels, desc.Text)
                     end
                  end
                  
                  DebugLog("  📝 TextLabels (" .. #textLabels .. "):")
                  for i, text in pairs(textLabels) do
                     DebugLog("    " .. i .. ". '" .. text .. "'")
                  end
               end
            end)
         end
      else
         DebugLog("❌ movingAnimals pas trouvé dans Workspace")
      end
      
      DebugLog("=== FIN TEST MOVINGANIMALS ===")
   end,
})

-- 5. Debug Models sur le Tapis
local ModelsOnCarpetButton = DebugTab:CreateButton({
   Name = "🎯 Models sur le Tapis",
   Callback = function()
      DebugLog("=== 🎯 MODELS SUR LE TAPIS ===")
      
      -- Trouver le tapis d'abord
      local carpet = nil
      local map = workspace:FindFirstChild("Map")
      if map then
         carpet = map:FindFirstChild("Carpet")
      end
      
      if not carpet then
         DebugLog("❌ Tapis non trouvé - impossible de détecter les models dessus")
         return
      end
      
      DebugLog("✅ Tapis trouvé: " .. carpet:GetFullName())
      DebugLog("📍 Position tapis: " .. tostring(carpet.Position))
      
      local carpetPos = carpet.Position
      local modelsOnCarpet = {}
      
      -- Chercher models proches du tapis
      for _, obj in pairs(workspace:GetDescendants()) do
         pcall(function()
            if obj:IsA("Model") and obj ~= carpet and obj.Name ~= "Camera" and obj.Name ~= "Terrain" then
               local modelPos = nil
               
               if obj.PrimaryPart then
                  modelPos = obj.PrimaryPart.Position
               else
                  pcall(function()
                     local pivot = obj:GetPivot()
                     if pivot then
                        modelPos = pivot.Position
                     end
                  end)
               end
               
               if modelPos then
                  local distance = (modelPos - carpetPos).Magnitude
                  if distance < 100 then -- Proche du tapis
                     -- Chercher textes cibles
                     local targetTexts = {
                        "Mythic", "Legendary", "Common", "Epic", "Rare", "Brainrot God", "Secret"
                     }
                     local modelTexts = {}
                     local hasTargetText = false
                     
                     for _, child in pairs(obj:GetDescendants()) do
                        pcall(function()
                           if child:IsA("TextLabel") and child.Text and child.Text ~= "" then
                              table.insert(modelTexts, child.Text)
                              for _, target in pairs(targetTexts) do
                                 if child.Text:find(target) then
                                    hasTargetText = true
                                 end
                              end
                           end
                        end)
                     end
                     
                     if hasTargetText then
                        table.insert(modelsOnCarpet, {
                           model = obj,
                           distance = distance,
                           texts = modelTexts
                        })
                        
                        DebugLog("🎯 MODEL SUR TAPIS: " .. obj.Name)
                        DebugLog("  📏 Distance: " .. math.floor(distance) .. " unités")
                        DebugLog("  📍 Position: " .. tostring(modelPos))
                        DebugLog("  📝 Textes:")
                        for i, text in pairs(modelTexts) do
                           local isTarget = false
                           for _, target in pairs(targetTexts) do
                              if text:find(target) then isTarget = true break end
                           end
                           DebugLog("    " .. i .. ". '" .. text .. "'" .. (isTarget and " ⭐" or ""))
                        end
                     end
                  end
               end
            end
         end)
      end
      
      DebugLog("📊 Models avec textes cibles sur tapis: " .. #modelsOnCarpet)
      DebugLog("=== FIN MODELS SUR TAPIS ===")
   end,
})

-- 6. Test Parsing des Noms
local TestParsingButton = DebugTab:CreateButton({
   Name = "📝 Test Parsing Noms",
   Callback = function()
      DebugLog("=== 📝 TEST PARSING NOMS ===")
      
      local brainrots = DetectAllBrainrots()
      
      DebugLog("📊 Brainrots trouvés: " .. #brainrots)
      
      for i, brainrot in pairs(brainrots) do
         DebugLog("--- BRAINROT " .. i .. " ---")
         DebugLog("  📝 Nom: '" .. brainrot.name .. "'")
         DebugLog("  🎨 Rareté: '" .. brainrot.rarity .. "'")
         DebugLog("  💰 Prix: '" .. brainrot.price .. "'")
         DebugLog("  💸 Revenu: '" .. brainrot.revenue .. "'")
         DebugLog("  ✨ Mutation: '" .. brainrot.mutation .. "'")
         DebugLog("  🚨 STOLEN: " .. tostring(brainrot.stolen))
         DebugLog("  📄 Tous textes: " .. table.concat(brainrot.allTexts, " | "))
      end
      
      DebugLog("=== FIN TEST PARSING ===")
   end,
})

-- 7. Scan complet Workspace
local FullWorkspaceScanButton = DebugTab:CreateButton({
   Name = "🌍 Scan Complet Workspace",
   Callback = function()
      DebugLog("=== 🌍 SCAN COMPLET WORKSPACE ===")
      
      local stats = {
         models = 0,
         parts = 0,
         textLabels = 0,
         targetModels = 0
      }
      
      local targetTexts = {
         "Mythic", "Legendary", "Common", "Epic", "Rare", "Brainrot God", "Secret"
      }
      
      for _, obj in pairs(workspace:GetDescendants()) do
         pcall(function()
            if obj:IsA("Model") then
               stats.models = stats.models + 1
               
               -- Chercher textes cibles dans ce model
               local hasTarget = false
               for _, child in pairs(obj:GetDescendants()) do
                  if child:IsA("TextLabel") and child.Text then
                     stats.textLabels = stats.textLabels + 1
                     for _, target in pairs(targetTexts) do
                        if child.Text:find(target) then
                           hasTarget = true
                           break
                        end
                     end
                  end
               end
               
               if hasTarget then
                  stats.targetModels = stats.targetModels + 1
               end
               
            elseif obj:IsA("BasePart") then
               stats.parts = stats.parts + 1
            end
         end)
      end
      
      DebugLog("📊 STATISTIQUES WORKSPACE:")
      DebugLog("  📦 Models totaux: " .. stats.models)
      DebugLog("  🧩 Parts totaux: " .. stats.parts)
      DebugLog("  📝 TextLabels totaux: " .. stats.textLabels)
      DebugLog("  🎯 Models avec textes cibles: " .. stats.targetModels)
      DebugLog("  🔍 Textes recherchés: " .. table.concat(targetTexts, ", "))
      
      DebugLog("=== FIN SCAN COMPLET ===")
   end,
})

-- Message de bienvenue amélioré
Rayfield:Notify({
   Title = "🪐 Steal Brainrot PREMIUM v2.0",
   Content = "ESP Avancé + Auto Buy + Auto Steal + Stats + Webhooks - Premium Edition !",
   Duration = 6,
   Image = nil,
})

-- Démarrage automatique des systèmes
spawn(function()
    task.wait(2)
    DebugLog("🚀 STEAL BRAINROT PREMIUM v2.0 - Prêt à utiliser !")
    DebugLog("👁️ ESP avec box colorées et détection dynamique")
    DebugLog("🛒 Auto Buy avec suivi intelligent vers base")
    DebugLog("💰 Auto Steal players + Auto Farm money")
    DebugLog("📊 Statistiques en temps réel")
    DebugLog("🔗 Support Webhooks Discord")
    DebugLog("🔍 Détection automatique nouvelles raretés/mutations")
    DebugLog("⚙️ Configuration sauvegardée automatiquement")
    
    -- Notification webhook de démarrage
    if WebhookUrl ~= "" then
        SendDiscordWebhook("🚀 Script Démarré", 
            "Steal Brainrot Premium v2.0 lancé avec succès pour " .. player.Name, 3066993)
    end
end)

-- Mise à jour automatique de la vitesse de marche
spawn(function()
    while true do
        if player.Character and player.Character:FindFirstChild("Humanoid") then
            if player.Character.Humanoid.WalkSpeed ~= WalkSpeed then
                player.Character.Humanoid.WalkSpeed = WalkSpeed
            end
        end
        task.wait(1)
    end
end)

-- Système de sauvegarde automatique des statistiques
spawn(function()
    while true do
        task.wait(60) -- Sauvegarder toutes les minutes
        if PlayerStatsEnabled then
            local sessionTime = math.floor(tick() - Stats.SessionStart)
            if sessionTime > 0 and sessionTime % 300 == 0 then -- Toutes les 5 minutes
                SendDiscordWebhook("📊 Rapport Statistiques", 
                    string.format("Session: %d min | Brainrots: %d | Achats: %d | Vols: %d", 
                    math.floor(sessionTime/60), Stats.BrainrotsDetected, Stats.BrainrotsBought, Stats.PlayersStolen), 3447003)
            end
        end
    end
end)
