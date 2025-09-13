# 🎯 Guide Full Debug Précis - Steal Brainrot MVP

## 🔍 Système de Debug Ultra-Détaillé

Ce guide explique comment utiliser le système de debug avancé pour obtenir **toutes les informations précises** nécessaires pour cibler parfaitement les objets du jeu.

## ⚡ Utilisation Rapide

### 1. 🔍 FULL DEBUG PRÉCIS
**Localisation :** Onglet **🔍 Debug** → **🔍 FULL DEBUG PRÉCIS**

**Ce que ça fait :**
- Scanne **TOUT** le jeu avec précision maximale
- Donne les **chemins exacts** de chaque objet
- Propriétés complètes de tous les éléments
- IDs et paths pour cibler précisément

### 2. ⚡ TARGETS RAPIDES  
**Localisation :** Onglet **🔍 Debug** → **⚡ TARGETS RAPIDES**

**Ce que ça fait :**
- Donne les **targets copy-paste** prêts à utiliser
- Code Lua direct pour accéder aux objets
- Optimisé pour l'exploitation

## 📊 Types d'Analyses Détaillées

### 🎭 1. BRAINROTS PRÉCIS
**Informations collectées :**
```
🎯 BRAINROT TARGET:
  📦 Parent: BrainrotModel (Model)
  📍 Path: Workspace.Map.Brainrots.BrainrotModel
  📝 Child: NameLabel (TextLabel)
  🔗 ChildPath: Workspace.Map.Brainrots.BrainrotModel.GUI.NameLabel
  💬 Text: 'Brainrot God - Galactic La Vacca - $1T'
  📍 Position: 100.5, 5.2, 200.8
```

**Utilisation exploit :**
```lua
local brainrot = workspace.Map.Brainrots.BrainrotModel
local nameLabel = brainrot.GUI.NameLabel
print(nameLabel.Text) -- Voir le nom et prix
```

### 💰 2. LEADERSTATS PRÉCIS
**Informations collectées :**
```
💎 STAT: Cash (IntValue)
  🔗 Path: Players.TonNom.leaderstats.Cash
  💰 Value: 1500000
  🏷️ ValueType: number
```

**Utilisation exploit :**
```lua
local money = game.Players.LocalPlayer.leaderstats.Cash.Value
print("Argent: $" .. money)
```

### 💳 3. GUI MONEY PRÉCIS
**Informations collectées :**
```
💳 MONEY GUI:
  📝 Name: MoneyDisplay
  🔗 Path: Players.TonNom.PlayerGui.MainGui.MoneyFrame.MoneyDisplay
  💬 Text: '$1.5M'
  📦 Parent: MoneyFrame
```

**Utilisation exploit :**
```lua
local moneyGUI = game.Players.LocalPlayer.PlayerGui.MainGui.MoneyFrame.MoneyDisplay
print("GUI Money: " .. moneyGUI.Text)
```

### 📡 4. REMOTE EVENTS PRÉCIS
**Informations collectées :**
```
📡 REMOTE:
  📝 Name: BuyBrainrot
  🏷️ Type: RemoteEvent
  🔗 Path: ReplicatedStorage.Events.BuyBrainrot
  📦 Parent: Events
```

**Utilisation exploit :**
```lua
local buyRemote = game.ReplicatedStorage.Events.BuyBrainrot
buyRemote:FireServer(brainrotData)
```

### 🛒 5. PROXIMITY PROMPTS PRÉCIS
**Informations collectées :**
```
🛒 PROMPT:
  📝 Name: BuyPrompt
  🔗 Path: Workspace.Shops.GunShop.BuyPrompt
  📦 Parent: GunShop
  💬 ActionText: 'Buy Gun ($500)'
  ⌨️ KeyCode: Enum.KeyCode.E
  ✅ Enabled: true
  📍 Position: 50, 10, 150
```

**Utilisation exploit :**
```lua
local prompt = workspace.Shops.GunShop.BuyPrompt
fireproximityprompt(prompt)
```

### 🗺️ 6. MAP STRUCTURE PRÉCISE
**Informations collectées :**
```
🗺️ MAP OBJECT:
  📝 Name: RedCarpet
  🏷️ Class: Part
  🔗 Path: Workspace.Map.RedCarpet
  📍 Position: 100, 5, 200
  📏 Size: 50, 1, 50
  🎨 Material: Enum.Material.Carpet
  🌈 Color: Bright red
```

**Utilisation exploit :**
```lua
local redCarpet = workspace.Map.RedCarpet
local center = redCarpet.Position
```

## 🎯 Targets Copy-Paste Prêts

Le bouton **⚡ TARGETS RAPIDES** génère du code direct :

### 💰 Money Targets
```lua
-- Target trouvé automatiquement:
game.Players.LocalPlayer.leaderstats.Cash.Value
```

### 📡 Remote Targets  
```lua
-- Targets trouvés automatiquement:
game.ReplicatedStorage:FindFirstChild("BuyBrainrot")
game.ReplicatedStorage:FindFirstChild("StealMoney")
```

### 🛒 Prompt Targets
```lua
-- Targets trouvés automatiquement:
workspace.Shops.GunShop.ProximityPrompt
workspace.Map.BrainrotSpawner.BuyPrompt
```

## 🔧 Procédure Debug Complète

### Étape 1: Lancement
1. Lance le script MVP
2. Va dans **🔍 Debug**
3. Clique **🔍 FULL DEBUG PRÉCIS**
4. **Attends** le scan complet (1-2 minutes)

### Étape 2: Analyse F9
1. Ouvre **F9** (console)
2. **Copie tous les logs** de debug
3. **Sauvegarde** dans un fichier texte
4. **Analyse** les paths et propriétés

### Étape 3: Targets Exploit
1. Clique **⚡ TARGETS RAPIDES**
2. **Copie les codes** générés depuis F9
3. **Utilise directement** dans ton exploit

### Étape 4: Test Précis
1. **Teste chaque target** individuellement
2. **Vérifie les paths** dans F9
3. **Confirme les propriétés**

## 📋 Template Exploit avec Targets

```lua
-- TEMPLATE EXPLOIT AVEC TARGETS PRÉCIS

-- Money Detection
local function getMoney()
    -- Utilise le path exact trouvé
    if game.Players.LocalPlayer:FindFirstChild("leaderstats") then
        return game.Players.LocalPlayer.leaderstats.Cash.Value
    end
    return 0
end

-- Brainrot Detection
local function findGodBrainrots()
    local targets = {}
    -- Utilise les paths exacts trouvés
    for _, obj in pairs(workspace.Map.Brainrots:GetChildren()) do
        local nameLabel = obj:FindFirstChild("GUI") and obj.GUI:FindFirstChild("NameLabel")
        if nameLabel and nameLabel.Text:find("God") then
            table.insert(targets, {
                object = obj,
                text = nameLabel.Text,
                position = obj.Position
            })
        end
    end
    return targets
end

-- Buy Function
local function buyBrainrot(brainrotObj)
    -- Utilise le remote exact trouvé
    local buyRemote = game.ReplicatedStorage:FindFirstChild("BuyBrainrot")
    if buyRemote then
        buyRemote:FireServer(brainrotObj)
    end
end

-- Main Exploit Loop
while true do
    local money = getMoney()
    local brainrots = findGodBrainrots()
    
    for _, brainrot in pairs(brainrots) do
        if money >= 1000000 then -- 1M minimum
            buyBrainrot(brainrot.object)
            break
        end
    end
    
    task.wait(1)
end
```

## 💡 Tips d'Utilisation

### ✅ Bonnes Pratiques
- **Lance le debug** au début de chaque session
- **Sauvegarde les paths** dans un fichier
- **Teste les targets** avant exploitation
- **Vérifie les updates** de structure du jeu

### ⚠️ Attention
- **Paths peuvent changer** avec les updates du jeu
- **Teste toujours** avant exploitation massive
- **Sauvegarde** les résultats de debug
- **Compare** avec les versions précédentes

### 🚀 Optimisation
- **Utilise les Quick Targets** pour du code rapide
- **Full Debug** pour l'analyse complète
- **F9 logs** pour les détails exacts
- **Copy-paste** les paths corrects

---

**🎯 Avec ce système, tu auras 100% des informations précises pour créer des exploits parfaitement ciblés !**

**💡 Les paths et IDs exacts permettent un ciblage précis sans erreur ni approximation.**
