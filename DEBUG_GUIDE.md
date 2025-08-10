# 🔍 Guide Debug - Steal Brainrot GUI

## 🎯 Comment utiliser le système de debug

### 1. 📂 Ouvrir la Console Roblox

**Méthode 1 :** Appuie sur **F9** pendant le jeu
**Méthode 2 :** Tape **/console** dans le chat du jeu

La console affichera tous les logs de debug en temps réel.

### 2. 🔍 Onglet Debug dans la GUI

La GUI contient un onglet **🔍 Debug** avec ces outils :

#### ⚙️ Contrôles Debug
- **🔍 Mode Debug** - Active/désactive tous les logs
- **🌐 Explorer Workspace** - Scan complet des objets du jeu
- **📡 Explorer RemoteEvents** - Liste tous les events serveur
- **👥 Analyser Joueurs** - Info sur tous les joueurs connectés  
- **📍 Objets Proches** - Liste les objets à 50 studs de toi

#### 🔄 Mode Temps Réel
- **🔄 Explorateur Temps Réel** - Scan automatique toutes les 5 secondes

#### 🧪 Tests Spécifiques
- **🧪 Test Téléportation** - Test de déplacement 
- **🧪 Test ProximityPrompts** - Trouve tous les objets achetables

## 📊 Types de Logs

### 💰 Auto Collect
```
🪐 DEBUG: 💰 ITEM TROUVÉ: Cash | Type: Part | Parent: Workspace
🪐 DEBUG:   📍 Distance: 25 studs
🪐 DEBUG:   ✅ TÉLÉPORTATION vers: 100, 5, 200
🪐 DEBUG: 📊 BILAN COLLECT: 3 trouvés, 2 collectés (Total: 15)
```

### 🎯 Auto Steal
```
🪐 DEBUG: 👤 JOUEUR: PlayerName | Distance: 15 studs
🪐 DEBUG:   🎯 CIBLE VALIDE: PlayerName (Distance: 15)
🪐 DEBUG:     📡 EVENT TROUVÉ: StealMoney
🪐 DEBUG:     🔥 TENTATIVE DE VOL via: StealMoney
```

### 🛒 Auto Buy
```
🪐 DEBUG: 🏪 SHOP TROUVÉ: GunShop | Type: Part | Parent: Workspace
🪐 DEBUG: 🛒 PROMPT TROUVÉ: ProximityPrompt | Parent: GunShop | ActionText: Buy Gun
🪐 DEBUG:   📍 Distance: 8 studs | Enabled: true
🪐 DEBUG:   🔥 TENTATIVE D'ACHAT: GunShop
```

## 🔧 Que Regarder dans les Logs

### ✅ Pour Auto Collect
1. **Items trouvés** - Vérifie quels objets sont détectés
2. **Distances** - Assure-toi qu'ils sont à portée (<50 studs)
3. **Téléportations** - Vérifie que le script te déplace bien

### ✅ Pour Auto Steal  
1. **Joueurs détectés** - Liste des cibles potentielles
2. **RemoteEvents** - Cherche les events avec "Steal", "Rob", "Take"
3. **Distances** - Cibles à moins de 20 studs

### ✅ Pour Auto Buy
1. **ProximityPrompts** - Objets avec prompt d'achat
2. **ActionText** - Texte affiché (Buy, Purchase, etc.)
3. **Enabled status** - Prompt activé ou pas

## 🎯 Identifier les Problèmes

### ❌ Auto Collect ne marche pas
```
🪐 DEBUG: 📊 BILAN COLLECT: 0 trouvés, 0 collectés
```
**Solution :** Les noms d'objets sont différents. Regarde la section "Explorer Workspace" pour voir les vrais noms.

### ❌ Auto Steal ne marche pas  
```
⚠️ WARN: Aucun RemoteEvent de vol trouvé
```
**Solution :** Les RemoteEvents ont des noms différents. Regarde "Explorer RemoteEvents" pour trouver les bons.

### ❌ Auto Buy ne marche pas
```
🪐 DEBUG: 📊 BILAN BUY: 2 shops, 0 prompts, 0 achats tentés
```
**Solution :** Pas de ProximityPrompts trouvés. Vérifie avec "Test ProximityPrompts".

## 🔍 Méthode de Debug Complète

### Étape 1 : Scan Initial
1. Lance le script
2. Va dans l'onglet Debug  
3. Clique "Explorer Workspace"
4. Clique "Explorer RemoteEvents"
5. Clique "Analyser Joueurs"

### Étape 2 : Test des Fonctions
1. Active une fonction auto (collect/steal/buy)
2. Regarde les logs en temps réel dans F9
3. Note les noms d'objets/events trouvés

### Étape 3 : Ajustements
Si quelque chose ne marche pas :
1. Regarde les noms d'objets dans les logs
2. Modifie le script pour utiliser ces noms
3. Teste à nouveau

## 📝 Exemples de Modifications

### Changer les noms d'objets à collecter
Dans `AutoCollectItems()`, ligne ~191 :
```lua
-- Au lieu de :
if item.Name:find("Coin") or item.Name:find("Cash") then

-- Utilise les vrais noms du jeu :
if item.Name:find("Money") or item.Name:find("Dollar") or item.Name:find("BrainrotCoin") then
```

### Changer les RemoteEvents pour steal
Dans `AutoStealFunction()`, ligne ~249 :
```lua
-- Au lieu de :
if remote.Name:find("Steal") or remote.Name:find("Rob") then

-- Utilise le vrai nom :
if remote.Name == "TakeMoney" or remote.Name == "StealFromPlayer" then
```

## 🚀 Tips de Debug Avancés

### 1. Logs Personnalisés
Ajoute tes propres logs :
```lua
DebugLog("Mon message de debug")
DebugLog("Attention problème", "warn") 
DebugLog("Erreur critique", "error")
```

### 2. Inspecteur d'Objets
Pour examiner un objet spécifique :
```lua
local obj = workspace.MonObjet
DebugLog("Nom: " .. obj.Name)
DebugLog("Type: " .. obj.ClassName)
DebugLog("Parent: " .. obj.Parent.Name)
```

### 3. Mode Temps Réel
Active "Explorateur Temps Réel" pour voir les changements en direct.

---

**💡 Conseil :** Garde toujours la console F9 ouverte pendant tes tests !

**🔧 Support :** Si tu ne comprends pas un log, copie-le et demande de l'aide.
