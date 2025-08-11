# 📡 Guide Webhook Discord - Steal Brainrot MVP

## 🎯 Qu'est-ce que les Webhooks Discord ?

Les webhooks permettent de recevoir des notifications **en temps réel** sur Discord quand :
- 🎭 Un brainrot **God ou Secret** spawn sur le tapis rouge
- 🛒 L'auto buy **achète ou échoue** à acheter un brainrot
- 🚨 Une **erreur** se produit dans le script
- 👤 Un **nouveau joueur** rejoint le serveur (optionnel)

## 🚀 Configuration Rapide (5 étapes)

### 1. 📱 Créer un Webhook Discord

1. **Ouvre Discord** et va sur ton serveur
2. **Clic droit** sur le salon où tu veux les notifications
3. **Paramètres du salon** → **Intégrations** → **Webhooks**
4. **Créer un webhook** → Nomme-le "Steal Brainrot"
5. **Copie l'URL du webhook** (ressemble à : `https://discord.com/api/webhooks/123456789/abcdef...`)

### 2. 🔧 Configurer dans le Script

1. Lance le script Steal Brainrot MVP
2. Va dans l'onglet **📡 Discord**
3. **Colle l'URL** du webhook dans le champ
4. **Active "📡 Activer Webhook"**
5. **Clique "🧪 Tester Webhook"** pour vérifier

### 3. ⚙️ Choisir les Notifications

**Notifications Recommandées :**
- ✅ **🎭 Spawn Brainrots God/Secret** - Pour savoir quand acheter
- ✅ **🛒 Résultats Auto Buy** - Confirmer les achats
- ✅ **🚨 Notifications d'Erreurs** - Débogage

**Optionnel :**
- ❌ **👤 Joueurs qui rejoignent** - Peut spammer si beaucoup de joueurs

### 4. 🧪 Tester la Configuration

1. **Clique "🧪 Tester Webhook"** dans l'onglet Discord
2. **Vérifie Discord** - tu devrais voir un message de test
3. **Active l'auto buy** et attends qu'un brainrot spawn pour tester en réel

### 5. ✅ Utilisation

Une fois configuré, tu recevras automatiquement :

**🎭 Spawn Brainrot :**
```
🎭 Nouveau Brainrot God
Un brainrot God vient d'apparaître !

Nom: Galactic La Vacca
Rareté: God  
Prix: $1T
Joueur: TonNom
Argent disponible: $2.5T
Peut acheter: ✅ Oui
```

**🛒 Achat Réussi :**
```
✅ Achat Réussi
Brainrot acheté avec succès !

Brainrot: Galactic La Vacca
Rareté: God
Prix: $1T
Joueur: TonNom
Serveur: abc123...
Timestamp: 14:35:21
```

**🚨 Erreur :**
```
🚨 Erreur Détectée
Une erreur s'est produite dans le script

Erreur: Impossible de détecter le tapis rouge
Contexte: AutoBuy Function
Joueur: TonNom (123456789)
Serveur: abc123...
```

## 📱 Exemple d'URL Webhook

**Format :** `https://discord.com/api/webhooks/[ID]/[TOKEN]`

**Exemple réel :**
```
https://discord.com/api/webhooks/1234567890123456789/abcdefghijklmnopqrstuvwxyz-ABCDEFGHIJKLMNOPQRSTUVWXYZ123456789
```

## 🔒 Sécurité

### ✅ Bonnes Pratiques
- **Ne partage jamais** ton URL de webhook
- **Utilise un salon privé** pour les notifications
- **Révoque le webhook** si compromis
- **Teste sur un serveur de test** d'abord

### ⚠️ Attention
- L'URL webhook = accès à écrire sur ton Discord
- Si quelqu'un a ton URL, il peut envoyer des messages
- Garde l'URL **privée** !

## 🛠️ Résolution de Problèmes

### ❌ "Erreur webhook: HTTP 404"
**Cause :** URL webhook incorrecte ou supprimée
**Solution :** Vérifier l'URL ou créer un nouveau webhook

### ❌ "Erreur webhook: HTTP 401"  
**Cause :** Token webhook invalide
**Solution :** Recréer le webhook et copier la nouvelle URL

### ❌ "Pas de test reçu sur Discord"
**Cause :** Script pas activé ou URL mal copiée
**Solutions :**
1. Vérifier que "📡 Activer Webhook" est coché
2. Re-copier l'URL webhook
3. Vérifier les permissions du salon Discord

### ❌ "Webhook spam trop de messages"
**Solution :** Le script a un anti-spam intégré :
- Erreurs identiques : 1 par 30 secondes
- Brainrots identiques : 1 par 10 secondes

## 🎮 Intégration avec Auto Buy

Le webhook est **parfaitement intégré** avec l'auto buy :

1. **Brainrot spawn** → Notification Discord
2. **Script se déplace** → Logs F9 
3. **Achat tenté** → Notification Discord (succès/échec)
4. **Erreur éventuelle** → Notification Discord

Tu peux donc **suivre tout en temps réel** sur Discord sans rester devant Roblox !

## 📊 Types de Couleurs

- 🟢 **Vert** - Succès (achats réussis, tests, démarrage)
- 🔴 **Rouge** - Erreurs (échecs d'achat, erreurs script)
- 🟡 **Or** - Brainrots God
- ⚪ **Blanc** - Brainrots Secret  
- 🔵 **Bleu** - Informations (joueurs, serveur)

---

**💡 Conseil :** Configure le webhook **avant** d'activer l'auto buy pour ne rien rater !

**🎯 Une fois configuré, tu peux fermer Roblox et suivre tout sur Discord !**
