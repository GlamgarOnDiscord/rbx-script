# 🎮 MVP Steal Brainrot - Guide d'Utilisation

## 🚀 Installation

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/GlamgarOnDiscord/rbx-script/main/steal_brainrot.lua"))()
```

## ⚡ Démarrage Rapide (3 étapes)

### 1. 📂 Ouvre la Console
- Appuie sur **F9** dans Roblox
- Ou tape **/console** dans le chat

### 2. 🎯 Active l'Auto Buy  
- Va dans l'onglet **🏠 Principal**
- Active **🛒 Auto Buy God/Secret**
- Le script détecte automatiquement le tapis rouge et ton argent

### 3. 👁️ Active l'ESP (optionnel)
- Va dans l'onglet **👁️ ESP**  
- Active **🎭 ESP Brainrots God/Secret**
- Active **👥 ESP Joueurs**

## 🎛️ Contrôles Principaux

### 🏠 Onglet Principal
- **🛒 Auto Buy God/Secret** - Achète automatiquement les brainrots God/Secret sur le tapis rouge
- **🏃 Vitesse de marche** - Réglé sur 30 par défaut (sûr anti-détection)
- **🦘 Puissance de saut** - Améliore la mobilité

### 👁️ Onglet ESP
- **🎭 ESP Brainrots** - Affiche les brainrots God (doré) et Secret (blanc)
- **👥 ESP Joueurs** - Affiche nom + distance des autres joueurs
- **🔍 Scanner Maintenant** - Force un scan manuel
- **📍 Détecter Positions** - Trouve le tapis rouge + ta base
- **💰 Vérifier Argent** - Affiche ton argent actuel

### 🔍 Onglet Debug
- **🌐 Explorer Workspace** - Scan complet du jeu
- **📡 Explorer RemoteEvents** - Liste tous les events
- **👥 Analyser Joueurs** - Info détaillée sur les joueurs
- **🔄 Explorateur Temps Réel** - Scan automatique toutes les 5s

## 🎯 Comment ça Marche

### Auto Buy Process
1. **Détection** - Scanne le tapis rouge pour brainrots God/Secret
2. **Vérification** - Vérifie que tu as assez d'argent  
3. **Déplacement** - Se dirige vers le brainrot (vitesse sûre)
4. **Achat** - Appuie sur E automatiquement
5. **Attente** - Délai entre les achats pour éviter la détection

### ESP Visuel
- **Brainrots God** : Texte **doré** avec nom + prix
- **Brainrots Secret** : Texte **blanc** avec nom + prix
- **Joueurs** : Texte **cyan** avec nom + distance

## 📊 Logs de Debug

Dans la console F9, tu verras :

```
🪐 DEBUG: 🔴 TAPIS ROUGE DÉTECTÉ: 100, 5, 200
🪐 DEBUG: 💰 Argent joueur: $1570000000000
🪐 DEBUG: 🎭 BRAINROT God TROUVÉ: Galactic La Vacca | Prix: 1T
🪐 DEBUG: 🎯 CIBLE: God Galactic La Vacca | Prix: $1T
🪐 DEBUG: 🏃 DÉPLACEMENT vers: 100, 5, 200 | Distance: 45
🪐 DEBUG: ✅ Arrivé près du brainrot, tentative d'achat...
🪐 DEBUG: 🔥 ACHAT TENTÉ #1: Galactic La Vacca
```

## ⚠️ Sécurité Anti-Détection

### ✅ Protections Intégrées
- **Vitesse limitée** - Max 30 par défaut (50+ détectable)
- **Délais entre achats** - Pas de spam
- **Déplacement naturel** - Pas de téléportation si proche
- **Logs discrets** - Seulement dans F9, pas visible aux autres

### 🚨 À Éviter
- **Vitesse > 50** - Détection possible
- **Utiliser avec d'autres cheats** - Cumul de risques
- **AFK trop longtemps** - Surveillance possible

## 🔧 Résolution de Problèmes

### ❌ Auto Buy ne marche pas
**Symptôme** : Pas d'achat automatique
**Solutions** :
1. Vérifie que le tapis rouge est détecté (`📍 Détecter Positions`)
2. Assure-toi d'avoir assez d'argent (`💰 Vérifier Argent`)
3. Regarde les logs F9 pour voir les erreurs

### ❌ ESP ne s'affiche pas  
**Symptôme** : Pas de texte au-dessus des brainrots
**Solutions** :
1. Va dans l'onglet ESP et active les toggles
2. Clique `🔍 Scanner Maintenant`
3. Vérifie qu'il y a des brainrots God/Secret sur la map

### ❌ Détection du tapis rouge
**Symptôme** : Message "Tapis rouge non trouvé"
**Solutions** :
1. Va près du centre de la map
2. Clique `📍 Détecter Positions`
3. Regarde dans Debug les objets rouges détectés

## 🎮 Tips d'Utilisation

### 🎯 Stratégie Optimale
1. **Démarre près du tapis rouge** pour une détection rapide
2. **Active ESP** pour voir les spawns en temps réel
3. **Surveille F9** pour les logs d'achat
4. **Reste près du tapis** pour réduire les délais de déplacement

### 💰 Gestion d'Argent
- Le script détecte automatiquement ton argent
- Il n'achète que si tu peux te le permettre
- Priorité aux brainrots les moins chers disponibles

### 🕒 Timing
- Les brainrots God/Secret ont des spawns programmés
- Laisse le script tourner en continu
- Il achètera dès qu'un brainrot spawn

---

**🚀 MVP PRÊT - Lance le script et active Auto Buy pour commencer !**

**💡 Astuce** : Garde toujours F9 ouvert pour voir ce qui se passe en temps réel.
