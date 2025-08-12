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
