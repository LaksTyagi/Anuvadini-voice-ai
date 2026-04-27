# Git Push Instructions

## Problem
Multiple GitHub accounts configured hai, permission denied aa raha hai.

## Solution - Personal Access Token Use Karo

### Step 1: GitHub Personal Access Token Banao
1. GitHub.com pe jao
2. Settings → Developer settings → Personal access tokens → Tokens (classic)
3. "Generate new token (classic)" click karo
4. Permissions select karo:
   - ✅ repo (full control)
   - ✅ workflow
5. Token copy karo (ek hi baar dikhega!)

### Step 2: Git Credentials Clear Karo
```bash
git credential-manager delete https://github.com
```

### Step 3: Push with Token
```bash
git push -u origin main
```

Jab username/password maange:
- **Username:** LaksTyagi
- **Password:** [Your Personal Access Token paste karo]

### Alternative: Direct URL with Token
```bash
git remote set-url origin https://YOUR_TOKEN@github.com/LaksTyagi/Anuvadini-voice-ai.git
git push -u origin main
```

Replace `YOUR_TOKEN` with your actual GitHub Personal Access Token.

---

## SSH Key Setup (Better Long-term Solution)

### Generate New SSH Key
```bash
ssh-keygen -t ed25519 -C "your_email@example.com"
```

### Add to SSH Agent
```bash
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
```

### Copy Public Key
```bash
cat ~/.ssh/id_ed25519.pub
```

### Add to GitHub
1. GitHub.com → Settings → SSH and GPG keys
2. "New SSH key" click karo
3. Public key paste karo
4. Save karo

### Change Remote Back to SSH
```bash
git remote set-url origin git@github.com:LaksTyagi/Anuvadini-voice-ai.git
git push -u origin main
```

---

## Current Status
- Repository: https://github.com/LaksTyagi/Anuvadini-voice-ai.git
- Branch: main
- Working tree: clean (no uncommitted changes)
- Issue: Permission denied (wrong GitHub account credentials)
