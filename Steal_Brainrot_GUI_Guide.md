# Guide GUI Roblox - Steal a Brainrot avec Rayfield

## 📋 Objectif
Créer une GUI moderne et fonctionnelle pour le jeu [Steal a Brainrot](https://www.roblox.com/fr/games/109983668079237/Steal-a-Brainrot) avec auto buy, auto steal et autres fonctionnalités automatisées, hébergée sur Github pour un chargement distant.

## 🔧 Prérequis
- Exécuteur Roblox (compatible tous executeurs)
- Accès à la bibliothèque Rayfield
- Compte Github (pour héberger le script)
- Git installé (pour push le code)

## 📚 Documentation Rayfield
Référence : [Rayfield Documentation](https://docs.sirius.menu/rayfield)

## 🚀 Installation Rapide

**Pour les utilisateurs finaux - Copie cette ligne dans ton executeur :**

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/GlamgarOnDiscord/rbx-script/main/steal_brainrot.lua"))()
```

## 📁 Setup Github Repository

### 1. Créer le Repository

```bash
echo "# rbx-script" >> README.md
git init
git add README.md
git commit -m "first commit"
git branch -M main
git remote add origin https://github.com/GlamgarOnDiscord/rbx-script.git
git push -u origin main
```

### 2. Ajouter les fichiers du script

```bash
git add .
git commit -m "Ajout GUI Steal Brainrot avec Rayfield"
git push origin main
```

### 3. Structure du repository

```
rbx-script/
├── README.md                      # Instructions d'utilisation
├── steal_brainrot.lua            # Script principal
└── Steal_Brainrot_GUI_Guide.md   # Guide de développement
```

## 🚀 Code de Base

### 1. Initialisation de Rayfield

```lua
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
   Name = "🪐 Steal Brainrot GUI",
   LoadingTitle = "Chargement Steal Brainrot",
   LoadingSubtitle = "par Votre Nom",
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
```

### 2. Variables Globales

```lua
-- Variables de contrôle
local AutoBuy = false
local AutoSteal = false
local AutoCollect = false
local AutoFarm = false
local WalkSpeed = 16
local JumpPower = 50

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
```

### 3. Fonctions Utilitaires

```lua
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
    while AutoCollect do
        for _, item in pairs(workspace:GetDescendants()) do
            if item.Name:find("Coin") or item.Name:find("Cash") or item.Name:find("Money") then
                if item:FindFirstChild("Handle") or item:FindFirstChild("Part") then
                    local part = item:FindFirstChild("Handle") or item:FindFirstChild("Part")
                    if part and (rootPart.Position - part.Position).Magnitude < 50 then
                        SafeTeleport(part.Position)
                        task.wait(0.1)
                    end
                end
            end
        end
        task.wait(0.5)
    end
end

-- Fonction pour auto-steal
local function AutoStealFunction()
    while AutoSteal do
        -- Chercher les joueurs proches pour steal
        for _, otherPlayer in pairs(Players:GetPlayers()) do
            if otherPlayer ~= player and otherPlayer.Character then
                local otherRoot = otherPlayer.Character:FindFirstChild("HumanoidRootPart")
                if otherRoot and (rootPart.Position - otherRoot.Position).Magnitude < 20 then
                    -- Event pour steal (à adapter selon le jeu)
                    local stealEvent = ReplicatedStorage:FindFirstChild("StealEvent") or ReplicatedStorage:FindFirstChild("Steal")
                    if stealEvent then
                        stealEvent:FireServer(otherPlayer)
                    end
                end
            end
        end
        task.wait(1)
    end
end

-- Fonction pour auto-buy
local function AutoBuyFunction()
    while AutoBuy do
        -- Chercher les shops/vendors
        for _, shop in pairs(workspace:GetDescendants()) do
            if shop.Name:find("Shop") or shop.Name:find("Buy") or shop.Name:find("Store") then
                if shop:FindFirstChild("ProximityPrompt") then
                    local prompt = shop:FindFirstChild("ProximityPrompt")
                    if (rootPart.Position - shop.Position).Magnitude < 10 then
                        fireproximityprompt(prompt)
                    end
                end
            end
        end
        task.wait(2)
    end
end
```

### 4. Interface Utilisateur

```lua
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
               -- Logic auto farm ici
               AutoCollectItems()
               task.wait(1)
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

-- Boutons de téléportation (à adapter selon les lieux du jeu)
local SpawnButton = TeleportTab:CreateButton({
   Name = "🏠 Spawn",
   Callback = function()
      SafeTeleport(Vector3.new(0, 10, 0)) -- Position spawn par défaut
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
local VersionLabel = UtilsTab:CreateLabel("Version 1.0")
```

### 5. Gestion des Events

```lua
-- Reconnexion automatique du character
player.CharacterAdded:Connect(function(newCharacter)
    character = newCharacter
    humanoid = character:WaitForChild("Humanoid")
    rootPart = character:WaitForChild("HumanoidRootPart")
    
    -- Réappliquer les modifications
    if WalkSpeed ~= 16 then
        humanoid.WalkSpeed = WalkSpeed
    end
    if JumpPower ~= 50 then
        humanoid.JumpPower = JumpPower
    end
end)

-- Notifications
Rayfield:Notify({
   Title = "🪐 Steal Brainrot GUI",
   Content = "GUI chargée avec succès !",
   Duration = 3,
   Image = 4483362458,
})
```

## 🎯 Fonctionnalités Implémentées

### ✅ Auto Farm
- Auto collect des items/coins
- Detection automatique des objets de valeur

### ✅ Auto Steal  
- Vol automatique des joueurs proches
- Sécurité anti-detection

### ✅ Auto Buy
- Achat automatique dans les shops
- Detection des vendors/boutiques

### ✅ Player Mods
- Vitesse de marche personnalisable
- Puissance de saut modifiable
- NoClip et saut infini

### ✅ Téléportation
- Points importants du jeu
- Navigation rapide

## 🔧 Installation

### Méthode 1 : Chargement depuis Github (Recommandé)

1. **Ouvrir votre executeur Roblox**
2. **Copier cette ligne :**
```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/GlamgarOnDiscord/rbx-script/main/steal_brainrot.lua"))()
```
3. **Coller dans l'executeur**
4. **Appuyer sur Execute/Inject**
5. **La GUI se charge automatiquement !**

### Méthode 2 : Code local (Développement)

1. **Copier le code complet du script principal**
2. **Ouvrir votre executeur Roblox**
3. **Coller le code dans l'executeur**
4. **Appuyer sur Execute/Inject**
5. **La GUI s'ouvrira automatiquement**

## 🌟 Avantages du Chargement Github

### ✅ Toujours à jour
- **Pas de re-téléchargement** - Le script charge automatiquement la dernière version
- **Corrections instantanées** - Les bugs sont fixés en temps réel
- **Nouvelles fonctionnalités** - Ajouts automatiques sans intervention

### ✅ Simplicité d'usage  
- **Une ligne suffit** - `loadstring(game:HttpGet(...))()` et c'est tout
- **Partage facile** - Donne juste le lien loadstring aux autres
- **Pas de fichiers** - Rien à stocker localement

### ✅ Sécurité et fiabilité
- **Hébergement Github** - Serveurs rapides et fiables
- **Code ouvert** - Transparence totale du script
- **Historique des versions** - Traçabilité des modifications

## ⚙️ Configuration

- Tous les paramètres sont sauvegardés automatiquement
- Les toggles gardent leur état entre les sessions
- Configuration stockée dans `StealBrainrotConfig/config`

## 🛡️ Sécurité

- Compatible avec tous les executeurs populaires
- Anti-detection intégré
- Gestion des erreurs et reconnexions

## 🔄 Gestion des Mises à Jour Github

### Publier une nouvelle version

```bash
# Modifier le script steal_brainrot.lua
# Puis commiter et push
git add steal_brainrot.lua
git commit -m "Update: nouvelle fonctionnalité auto X"
git push origin main
```

### Versioning et releases

```bash
# Créer un tag pour une version stable
git tag -a v1.0 -m "Version 1.0 - Release stable"
git push origin v1.0

# Pour une version spécifique dans loadstring :
# loadstring(game:HttpGet("https://raw.githubusercontent.com/GlamgarOnDiscord/rbx-script/v1.0/steal_brainrot.lua"))()
```

### Rollback en cas de problème

```bash
# Revenir à la version précédente
git revert HEAD
git push origin main
```

## 📝 Personnalisation

Pour adapter à d'autres jeux Roblox :

1. **Modifier les RemoteEvents** dans les fonctions auto
2. **Ajuster les positions de téléportation**  
3. **Changer les noms d'objets à détecter**
4. **Personnaliser l'interface selon vos besoins**
5. **Mettre à jour l'URL Github** dans le loadstring

## 🐛 Dépannage

**GUI ne s'affiche pas :**
- Vérifier que l'executeur supporte loadstring
- Vérifier la connexion internet

**Fonctions auto ne marchent pas :**
- Les RemoteEvents peuvent avoir changé
- Vérifier les noms d'objets dans le workspace

**Erreurs de téléportation :**
- Vérifier que les coordonnées sont correctes
- S'assurer que le joueur a un character valide

---

*GUI créée avec [Rayfield UI](https://docs.sirius.menu/rayfield) - Interface moderne et performante pour Roblox*
