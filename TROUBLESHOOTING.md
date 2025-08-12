# 🔧 Guide de Dépannage - Steal Brainrot MVP

## 🚨 Problèmes Courants et Solutions

### ❌ Test Webhook ne marche pas

**Symptôme :** Le bouton "🧪 Tester Webhook" ne sent rien sur Discord

**Solutions :**
1. **Vérifier l'URL webhook** - Assure-toi qu'elle commence par `https://discord.com/api/webhooks/`
2. **Activer le webhook** - Toggle "📡 Activer Webhook" doit être coché
3. **HttpRequests activé** - Dans ton executeur, assure-toi que les requêtes HTTP sont autorisées

**Test de diagnostic :**
- Va dans l'onglet **👁️ ESP**
- Clique **🔧 Debug Webhook Détaillé**
- Regarde les logs F9 pour voir le problème exact

---

### ❌ Auto Buy ne marche pas

**Symptôme :** "Text is not a valid member of SurfaceGui"

**Cause :** Le script cherche du texte dans des objets qui n'en ont pas

**Solutions :**
1. **Test de détection** - Onglet **🔍 Debug** → **🎭 Debug Détection Brainrots**
2. **Vérifier les logs** - Ouvre F9 et regarde les messages d'erreur
3. **Position tapis rouge** - Assure-toi que le tapis rouge est détecté

**Debug étapes :**
```
1. Onglet ESP → 📍 Détecter Tapis Rouge + Base
2. Onglet Debug → 🎭 Debug Détection Brainrots  
3. Regarde F9 pour voir ce qui est trouvé
```

---

### ❌ ESP Brainrots ne s'affiche pas

**Symptôme :** Pas de texte au-dessus des brainrots

**Solutions :**
1. **Active l'ESP** - Onglet **👁️ ESP** → **🎭 ESP Brainrots God/Secret**
2. **Debug brainrots** - Onglet **🔍 Debug** → **🎭 Debug Détection Brainrots**
3. **Vérifier qu'il y a des brainrots** sur la map

---

### ❌ Détection Argent Incorrecte

**Symptôme :** Script dit 5000$ alors que tu as 80$

**Solutions :**
1. **Test argent** - Onglet **👁️ ESP** → **💰 Vérifier Argent Joueur**
2. **Regarder leaderstats** - F9 va afficher tous les stats trouvés
3. **Le script priorise leaderstats** puis interface

**Debug :**
- Le script va dire s'il trouve leaderstats ou GUI
- Regarde F9 pour voir quelle méthode est utilisée

---

### ❌ Détection Tapis Rouge Échoue

**Symptôme :** "attempt to call a nil value"

**Solutions :**
1. **Va près du centre** de la map
2. **Test détection** - Onglet **👁️ ESP** → **📍 Détecter Tapis Rouge + Base**
3. **Regarder F9** pour voir les objets rouges détectés

---

## 🧪 Tests de Diagnostic Complets

### 1. Test Webhook
```
Onglet Discord → URL webhook → Activer → 🧪 Tester Webhook
Regarde F9 pour voir les logs détaillés
```

### 2. Test Détection Brainrots
```
Onglet Debug → 🎭 Debug Détection Brainrots
Regarde combien de TextLabels et brainrots sont trouvés
```

### 3. Test Détection Argent
```
Onglet ESP → 💰 Vérifier Argent Joueur
Regarde si leaderstats ou GUI est utilisé
```

### 4. Test Positions
```
Onglet ESP → 📍 Détecter Tapis Rouge + Base
Vérifier que les positions sont trouvées
```

---

## 📊 Logs F9 Importants

### ✅ Logs Normaux
```
🪐 DEBUG: 🔴 TAPIS ROUGE DÉTECTÉ: Part | Position: 100, 5, 200
🪐 DEBUG: 💰 Argent détecté via leaderstats: $80
🪐 DEBUG: 🎭 BRAINROT God TROUVÉ: BrainrotName | Prix: 1M
✅ Webhook envoyé avec succès: Test Webhook
```

### ❌ Logs d'Erreur
```
❌ Webhook non configuré
❌ Tapis rouge non trouvé
❌ Impossible de détecter l'argent
❌ Erreur critique webhook: HttpService error
```

---

## 🔧 Solutions Avancées

### Si Webhook ne marche toujours pas
1. **Teste ton URL** directement dans ton navigateur
2. **Vérifie les permissions** du salon Discord
3. **Recrée le webhook** si nécessaire

### Si Auto Buy ne trouve rien
1. **Va sur le tapis rouge** manuellement
2. **Regarde s'il y a des brainrots** qui spawnent
3. **Teste avec un brainrot visible** à l'écran

### Si ESP ne marche pas
1. **Désactive puis réactive** l'ESP
2. **Va dans différentes zones** de la map
3. **Teste sur des joueurs** d'abord (ESP Players)

---

## 📞 Support Debug

**Si rien ne marche :**

1. **Lance le script**
2. **Ouvre F9** (console)
3. **Va dans l'onglet Debug**
4. **Clique tous les boutons de test**
5. **Copie tous les logs F9**
6. **Partage les logs** pour diagnostic

**Informations utiles à fournir :**
- Executeur utilisé (Synapse, Krnl, etc.)
- Messages d'erreur exacts de F9
- Résultats des tests de debug
- Ce qui marche / ne marche pas

---

**💡 Conseil :** La plupart des problèmes viennent de la structure du jeu qui change. Les boutons de debug permettent de voir exactement ce qui est détecté.
