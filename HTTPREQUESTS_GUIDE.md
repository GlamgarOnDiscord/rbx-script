# 🌐 Guide HttpRequests - Solutions par Exécuteur

## 🚨 Problème : Webhook ne marche pas

**Erreur typique :** `"HttpRequests DÉSACTIVÉ"` ou `"attempt to call a nil value"`

**Cause :** Les requêtes HTTP sont désactivées dans ton exécuteur Roblox.

## 🔧 Solutions par Exécuteur

### 🔥 Synapse X
1. **Ouvre Synapse X**
2. **Clique sur "Options"** (en haut)
3. **Coche "Allow HTTP Requests"** ✅
4. **Redémarre Synapse X**

### 🌊 Krnl
1. **Lance Krnl**
2. **Va dans "Settings"**
3. **Active "Enable HTTP Requests"** ✅
4. **Injecte à nouveau**

### ⚡ Script-Ware
1. **Ouvre Script-Ware**
2. **Settings** → **HTTP Requests**
3. **Met sur "ON"** ✅
4. **Restart Script-Ware**

### 🌟 Fluxus
1. **Lance Fluxus**
2. **Settings** → **HTTP**
3. **Active "Enable"** ✅
4. **Réinjecte**

### 🔺 Delta
1. **Ouvre Delta**
2. **Options** → **HTTP Requests**
3. **Active "Enable"** ✅
4. **Redémarre Delta**

### 💨 Oxygen U
1. **Lance Oxygen U**
2. **Settings** → **Allow HTTP**
3. **Coche la case** ✅
4. **Reinject**

### 🎯 Autres Exécuteurs
- **Cherche "HTTP"** dans les paramètres
- **Active/Enable** toutes les options HTTP
- **Redémarre** l'exécuteur après activation

## 🧪 Comment Tester

### Méthode 1: Script MVP
1. **Lance le script** Steal Brainrot MVP
2. **Onglet 👁️ ESP** → **🌐 Test HttpRequests**
3. **Regarde F9** pour le résultat

### Méthode 2: Test Simple
```lua
-- Copie ce code dans ton exécuteur:
local HttpService = game:GetService("HttpService")
local success, result = pcall(function()
    return HttpService:GetAsync("https://httpbin.org/get")
end)

if success then
    print("✅ HttpRequests ACTIVÉ !")
else
    print("❌ HttpRequests DÉSACTIVÉ: " .. tostring(result))
end
```

## 📊 Vérifications Étape par Étape

### ✅ Checklist
- [ ] **Exécuteur ouvert** avec permissions admin
- [ ] **HttpRequests activé** dans les paramètres  
- [ ] **Exécuteur redémarré** après activation
- [ ] **Injecté dans Roblox** correctement
- [ ] **Test HttpRequests** réussi

### 🔍 Debug HttpRequests
1. **Lance le script** MVP
2. **F9** pour ouvrir console
3. **ESP** → **🌐 Test HttpRequests**
4. **Lis le résultat** dans F9

## 🚨 Erreurs Courantes

### ❌ "HttpService is not allowed to access this API"
**Solution :** Active HttpRequests dans ton exécuteur

### ❌ "HTTP 403 Forbidden"  
**Solution :** Ton URL webhook Discord est incorrecte

### ❌ "Connection failed"
**Solution :** Problème de connexion internet

### ❌ "attempt to call a nil value"
**Solution :** HttpService pas accessible, réactive HttpRequests

## 💡 Tips Supplémentaires

### 🔄 Si ça marche toujours pas
1. **Ferme complètement** l'exécuteur
2. **Redémarre en tant qu'admin**
3. **Vérifie les paramètres** HTTP
4. **Teste avec un webhook différent**

### 🎯 Test Final Webhook
```lua
-- Test webhook direct (remplace URL):
local HttpService = game:GetService("HttpService")
local data = {content = "Test de " .. game.Players.LocalPlayer.Name}
local request = {
    Url = "TON_URL_WEBHOOK_ICI",
    Method = "POST", 
    Headers = {["Content-Type"] = "application/json"},
    Body = HttpService:JSONEncode(data)
}
local response = HttpService:RequestAsync(request)
print(response.Success and "✅ Webhook OK" or "❌ Webhook KO")
```

## 📱 Executeurs Mobile

### 🍎 iOS (Scriptable/autres)
- **Généralement** HttpRequests activé par défaut
- **Si problème :** Cherche dans Advanced Settings

### 🤖 Android (Delta/Arceus/autres)  
- **Delta :** Settings → HTTP → Enable
- **Arceus :** Options → Allow HTTP
- **Hydrogen :** Settings → Network → HTTP

---

**💡 Astuce :** La plupart des problèmes webhook viennent d'HttpRequests désactivé. Active-le dans ton exécuteur et redémarre !**

**🎯 Une fois HttpRequests activé, tous les webhooks Discord fonctionneront parfaitement.**
