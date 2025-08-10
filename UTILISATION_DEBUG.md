# 🚀 Debug Mode - Utilisation Rapide

## ⚡ TL;DR - 3 Étapes Essentielles

### 1. 📂 Ouvre la Console
- Appuie sur **F9** dans Roblox
- Ou tape **/console** dans le chat

### 2. 🔍 Va dans l'onglet Debug
- Ouvre la GUI  
- Clique sur l'onglet **🔍 Debug**
- Clique **🌐 Explorer Workspace**

### 3. 👀 Regarde les Logs
Dans la console F9, tu verras :
- 🛒 **OBJETS INTERACTIFS** = Trucs achetables
- 💰 **COLLECTIBLES** = Trucs à ramasser  
- 📡 **REMOTE EVENTS** = Events pour steal
- 👤 **JOUEURS** = Cibles pour steal

## 🎯 Actions Immédiates

### Si Auto Collect ne marche pas :
1. Regarde les logs **"💰 COLLECTIBLE"**
2. Note les vrais noms d'objets (ex: "BrainrotCoin")
3. Adapte le script avec ces noms

### Si Auto Steal ne marche pas :
1. Regarde les logs **"📡 REMOTE EVENT"**  
2. Cherche des events comme "TakeMoney", "StealCash"
3. Utilise ces noms dans le script

### Si Auto Buy ne marche pas :
1. Clique **🧪 Test ProximityPrompts**
2. Note les **ActionText** (Buy, Purchase, etc.)
3. Vérifie que les prompts sont **Enabled: true**

## 📊 Logs les Plus Importants

```
🪐 DEBUG: 💰 COLLECTIBLE: BrainrotCoin | Type: Part
🪐 DEBUG: 🛒 PROMPT TROUVÉ: ProximityPrompt | ActionText: Buy Gun  
🪐 DEBUG: 📡 REMOTE EVENT: StealMoney | Parent: ReplicatedStorage
🪐 DEBUG: 👤 JOUEUR: PlayerName | Distance: 15 studs
```

## ⚙️ Boutons Debug Utiles

- **🌐 Explorer Workspace** = Scan complet du jeu
- **📡 Explorer RemoteEvents** = Trouve les events de steal  
- **👥 Analyser Joueurs** = Liste tous les joueurs
- **🧪 Test ProximityPrompts** = Trouve tous les achats
- **🔄 Explorateur Temps Réel** = Scan automatique

---

**💡 Conseil Rapide :** Lance le script → F9 → Onglet Debug → Explorer Workspace → Note les noms d'objets → Profit !
