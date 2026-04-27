# 🔑 GitHub Personal Access Token - Complete Guide

## Step-by-Step Instructions

### Step 1: GitHub Login
1. Open browser and go to: **https://github.com**
2. Login with your **LaksTyagi** account

---

### Step 2: Go to Settings
1. Click on your **profile picture** (top right corner)
2. Click **"Settings"** from dropdown menu

---

### Step 3: Developer Settings
1. Scroll down in left sidebar
2. Click **"Developer settings"** (last option)

---

### Step 4: Personal Access Tokens
1. In left sidebar, click **"Personal access tokens"**
2. Click **"Tokens (classic)"**
3. Click **"Generate new token"** button
4. Select **"Generate new token (classic)"**

---

### Step 5: Configure Token
Fill in these details:

**Note (Token name):**
```
Anuvadini-voice-ai-push
```

**Expiration:**
```
90 days (or "No expiration" if you want)
```

**Select scopes (permissions):**
- ✅ **repo** (check this - it will auto-check all sub-options)
  - ✅ repo:status
  - ✅ repo_deployment
  - ✅ public_repo
  - ✅ repo:invite
  - ✅ security_events

**Optional (but recommended):**
- ✅ **workflow** (if you use GitHub Actions)

---

### Step 6: Generate Token
1. Scroll to bottom
2. Click **"Generate token"** (green button)
3. **IMPORTANT:** Copy the token immediately!
   - It looks like: `ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx`
   - You will see it **ONLY ONCE**
   - Save it somewhere safe (Notepad, password manager)

---

### Step 7: Use Token to Push Code

Open your terminal and run:

```bash
# Clear old credentials
git credential-manager delete https://github.com

# Push code
git push -u origin main
```

**When prompted:**
- **Username:** `LaksTyagi`
- **Password:** `ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx` (paste your token)

---

## 🎯 Quick Links

**Direct link to create token:**
```
https://github.com/settings/tokens/new
```

**Your repository:**
```
https://github.com/LaksTyagi/Anuvadini-voice-ai
```

---

## ⚠️ Important Notes

1. **Never share your token** - treat it like a password
2. **Token is shown only once** - copy it immediately
3. **Use token as password** - not your GitHub password
4. **Token expires** - you'll need to generate new one after expiration
5. **Save token securely** - in password manager or secure note

---

## 🔄 Alternative: Save Token in Git (Optional)

After first successful push, Git will remember your credentials:

```bash
git config --global credential.helper store
```

Next time you push, it won't ask for username/password again.

---

## 🆘 Troubleshooting

### If push still fails:
```bash
# Check current remote
git remote -v

# Should show HTTPS URL
# If not, run:
git remote set-url origin https://github.com/LaksTyagi/Anuvadini-voice-ai.git

# Try push again
git push -u origin main
```

### If "Permission denied" error:
- Make sure you're using **LaksTyagi** username
- Make sure you're pasting the **token** (not password)
- Make sure token has **repo** permission checked

---

## ✅ Success Check

After successful push, you should see:
```
Enumerating objects: X, done.
Counting objects: 100% (X/X), done.
Writing objects: 100% (X/X), done.
Total X (delta X), reused X (delta X)
To https://github.com/LaksTyagi/Anuvadini-voice-ai.git
 * [new branch]      main -> main
Branch 'main' set up to track remote branch 'main' from 'origin'.
```

Then check your repository: https://github.com/LaksTyagi/Anuvadini-voice-ai

---

## 📱 Need Help?

If you get stuck at any step, let me know which step number and what error you're seeing!
