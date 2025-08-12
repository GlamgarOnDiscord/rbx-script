-- 🪐 Steal Brainrot - DEBUG SIMPLE VERSION
-- Version ultra-simplifiée pour debug uniquement

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

-- Services
local player = game.Players.LocalPlayer
local workspace = game:GetService("Workspace")

-- Variables globales
local DebugMode = true

-- Fonction de debug
local function DebugLog(message, level)
    if not DebugMode then return end
    local prefix = "🪐 DEBUG"
    if level == "warn" then
        prefix = "⚠️ WARN"
        warn(prefix .. ": " .. tostring(message))
    elseif level == "error" then
        prefix = "❌ ERROR"
        print(prefix .. ": " .. tostring(message))
    else
        print(prefix .. ": " .. tostring(message))
    end
end

-- Interface simplifiée
local Window = Rayfield:CreateWindow({
   Name = "🔍 DEBUG SIMPLE",
   LoadingTitle = "Debug Simple",
   LoadingSubtitle = "by GlamgarOnDiscord",
   ConfigurationSaving = {
      Enabled = false,
   },
   Discord = {
      Enabled = false,
   },
   KeySystem = false,
})

local DebugTab = Window:CreateTab("🔍 Debug", nil)
local ESPTab = Window:CreateTab("👁️ ESP", nil)
local AutoBuyTab = Window:CreateTab("🛒 Auto Buy", nil)

-- Variables globales
local ESPEnabled = false
local AutoBuyEnabled = false
local SelectedRarities = {}
local espBoxes = {}
local detectedBrainrots = {}

-- Fonction pour créer ESP Box
local function CreateESPBox(obj, text, color)
    pcall(function()
        -- Supprimer ancien ESP s'il existe
        RemoveESPBox(obj)
        
        local gui = Instance.new("BillboardGui")
        gui.Name = "ESP_" .. obj.Name
        gui.Adornee = obj
        gui.Size = UDim2.new(0, 200, 0, 100)
        gui.StudsOffset = Vector3.new(0, 2, 0)
        gui.AlwaysOnTop = true
        gui.LightInfluence = 0
        
        -- Cadre principal
        local frame = Instance.new("Frame")
        frame.Size = UDim2.new(1, 0, 1, 0)
        frame.BackgroundTransparency = 0.7
        frame.BackgroundColor3 = color
        frame.BorderSizePixel = 2
        frame.BorderColor3 = color
        frame.Parent = gui
        
        -- Texte
        local label = Instance.new("TextLabel")
        label.Size = UDim2.new(1, 0, 1, 0)
        label.BackgroundTransparency = 1
        label.Text = text
        label.TextColor3 = Color3.new(1, 1, 1)
        label.TextScaled = true
        label.TextStrokeTransparency = 0
        label.TextStrokeColor3 = Color3.new(0, 0, 0)
        label.Font = Enum.Font.GothamBold
        label.Parent = frame
        
        gui.Parent = game.CoreGui
        espBoxes[obj] = gui
    end)
end

-- Fonction pour supprimer ESP Box
local function RemoveESPBox(obj)
    pcall(function()
        if espBoxes[obj] then
            espBoxes[obj]:Destroy()
            espBoxes[obj] = nil
        end
    end)
end

-- Fonction pour analyser les 6 textes d'un brainrot
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
    
    for _, text in pairs(texts) do
        local textLower = text:lower()
        
        -- 1. Mutations (Gold, Diamond, Rainbow, etc.)
        if text:find("Gold") or text:find("Diamond") or text:find("Rainbow") or 
           text:find("Lava") or text:find("Celestial") or text:find("Bloodrot") then
            brainrot.mutation = text
            
        -- 2. Rareté
        elseif text == "Common" or text == "Rare" or text == "Epic" or 
               text == "Legendary" or text == "Mythic" or text:find("God") or text:find("Secret") then
            brainrot.rarity = text
            
        -- 3. Revenu généré ($/s)
        elseif text:find("$/s") or text:find("$%d+/s") then
            brainrot.revenue = text
            
        -- 4. Prix d'achat ($1K, $500, etc.)
        elseif text:find("$") and (text:find("K") or text:find("M") or text:find("B") or text:match("$%d+")) and not text:find("/s") then
            brainrot.price = text
            -- Convertir en nombre
            local numberStr = text:match("(%d+)")
            if numberStr then
                local num = tonumber(numberStr) or 0
                if text:find("K") then num = num * 1000
                elseif text:find("M") then num = num * 1000000
                elseif text:find("B") then num = num * 1000000000 end
                brainrot.priceNumber = num
            end
            
        -- 5. STOLEN
        elseif textLower:find("stolen") then
            brainrot.stolen = true
            
        -- 6. Nom (tout ce qui ne match pas les autres catégories)
        elseif text ~= "" and not text:find("$") and not text:find("/s") and 
               not (text == "Common" or text == "Rare" or text == "Epic" or text == "Legendary" or text == "Mythic") then
            brainrot.name = text
        end
    end
    
    return brainrot
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
    
    -- Scanner models sur le tapis
    for _, obj in pairs(workspace:GetDescendants()) do
        pcall(function()
            if obj:IsA("Model") and obj ~= carpet then
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

-- Fonction Auto Buy
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
    
    -- Acheter le premier brainrot disponible
    for _, brainrot in pairs(targetBrainrots) do
        if not brainrot.stolen then -- Ne pas acheter si déjà volé
            DebugLog("🛒 Tentative d'achat: " .. brainrot.name .. " (" .. brainrot.rarity .. ") - " .. brainrot.price)
            
            -- Se téléporter au brainrot
            if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                player.Character.HumanoidRootPart.CFrame = CFrame.new(brainrot.position + Vector3.new(0, 5, 0))
                wait(0.5)
                
                -- Simuler appui sur E
                local VirtualInputManager = game:GetService("VirtualInputManager")
                VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
                wait(0.1)
                VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
                
                DebugLog("✅ Achat tenté pour " .. brainrot.name)
                break -- Acheter seulement un à la fois
            end
        end
    end
end

-- === ONGLETS ===

-- ESP Tab
local ESPToggle = ESPTab:CreateToggle({
   Name = "👁️ ESP Brainrots",
   CurrentValue = false,
   Callback = function(Value)
      ESPEnabled = Value
      if Value then
         DebugLog("👁️ ESP ACTIVÉ")
         spawn(function()
            while ESPEnabled do
               UpdateESP()
               wait(3) -- Mise à jour toutes les 3 secondes
            end
         end)
      else
         DebugLog("👁️ ESP DÉSACTIVÉ")
         -- Nettoyer tous les ESP
         for obj, gui in pairs(espBoxes) do
            RemoveESPBox(obj)
         end
      end
   end,
})

-- Auto Buy Tab
local RaritySection = AutoBuyTab:CreateSection("🎯 Sélection des Raretés")

-- Toggles pour chaque rareté
local rarities = {"God", "Secret", "Legendary", "Mythic", "Epic", "Rare", "Common"}

for _, rarity in pairs(rarities) do
    local toggle = AutoBuyTab:CreateToggle({
        Name = rarity,
        CurrentValue = false,
        Callback = function(Value)
            SelectedRarities[rarity] = Value
            DebugLog("🎯 " .. rarity .. ": " .. (Value and "ACTIVÉ" or "DÉSACTIVÉ"))
        end,
    })
end

local AutoBuyToggle = AutoBuyTab:CreateToggle({
   Name = "🛒 Auto Buy",
   CurrentValue = false,
   Callback = function(Value)
      AutoBuyEnabled = Value
      if Value then
         DebugLog("🛒 AUTO BUY ACTIVÉ")
         spawn(function()
            while AutoBuyEnabled do
               AutoBuyBrainrots()
               wait(5) -- Vérifier toutes les 5 secondes
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

-- 6. Scan complet Workspace
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

-- Message de bienvenue
Rayfield:Notify({
   Title = "🔍 Debug Simple",
   Content = "Version ultra-simplifiée pour debug uniquement",
   Duration = 3,
   Image = nil,
})

DebugLog("🚀 DEBUG SIMPLE VERSION - Prêt à utiliser !")
DebugLog("🎯 6 boutons de debug disponibles")
