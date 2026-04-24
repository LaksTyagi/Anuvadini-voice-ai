# Fix Docker DNS Issue

## 🔴 The Problem

Docker can't resolve DNS names like `registry-1.docker.io`, showing this error:
```
dial tcp: lookup registry-1.docker.io: no such host
```

This is a common Docker Desktop on Windows issue with DNS resolution.

## ✅ Solutions (Try in Order)

### Solution 1: Restart Docker Desktop (Quickest)

1. Right-click Docker Desktop icon in system tray
2. Click "Quit Docker Desktop"
3. Wait 10 seconds
4. Start Docker Desktop again
5. Wait for it to fully initialize
6. Try running your compose command again

### Solution 2: Change Docker DNS Settings

1. Open Docker Desktop
2. Click the gear icon (Settings)
3. Go to "Docker Engine"
4. Find the JSON configuration
5. Add or modify the `dns` setting:

```json
{
  "builder": {
    "gc": {
      "defaultKeepStorage": "20GB",
      "enabled": true
    }
  },
  "experimental": false,
  "dns": ["8.8.8.8", "8.8.4.4"]
}
```

6. Click "Apply & Restart"
7. Wait for Docker to restart
8. Try again

### Solution 3: Use Google DNS or Cloudflare DNS

If Solution 2 doesn't work, try different DNS servers:

**Google DNS:**
```json
"dns": ["8.8.8.8", "8.8.4.4"]
```

**Cloudflare DNS:**
```json
"dns": ["1.1.1.1", "1.0.0.1"]
```

**Your Router DNS (if you know it):**
```json
"dns": ["192.168.1.1"]
```

### Solution 4: Check Windows Network Settings

1. Open "Network & Internet Settings"
2. Click "Change adapter options"
3. Right-click your active network adapter (Wi-Fi or Ethernet)
4. Click "Properties"
5. Select "Internet Protocol Version 4 (TCP/IPv4)"
6. Click "Properties"
7. Select "Use the following DNS server addresses"
8. Set:
   - Preferred DNS: `8.8.8.8`
   - Alternate DNS: `8.8.4.4`
9. Click OK
10. Restart Docker Desktop

### Solution 5: Disable VPN/Proxy

If you're using a VPN or proxy:

1. Temporarily disable it
2. Restart Docker Desktop
3. Try pulling images
4. Re-enable VPN/proxy after images are downloaded

### Solution 6: Reset Docker Desktop

**⚠️ Warning: This will remove all containers, images, and volumes**

1. Open Docker Desktop Settings
2. Go to "Troubleshoot"
3. Click "Clean / Purge data"
4. Click "Reset to factory defaults"
5. Restart Docker Desktop
6. Try again

### Solution 7: Use Docker Desktop's Built-in DNS

1. Open Docker Desktop Settings
2. Go to "Resources" → "Network"
3. Enable "Use kernel networking for UDP"
4. Apply & Restart

## 🧪 Test Your Fix

After trying a solution, test if DNS works:

```powershell
# Test Docker can reach the internet
docker run --rm alpine ping -c 3 google.com

# Test Docker can pull an image
docker pull hello-world
```

If both work, try your compose command again:
```powershell
docker compose -f docker-compose.yml up --build
```

## 🔄 Alternative: Pull Images Manually

If DNS issues persist, you can try pulling images one at a time:

```powershell
# Pull LiveKit server
docker pull livekit/livekit-server:latest

# Pull llama.cpp (CPU version)
docker pull ghcr.io/ggml-org/llama.cpp:server

# Or GPU version if you chose GPU mode
docker pull ghcr.io/ggml-org/llama.cpp:server-cuda

# Then try compose again
docker compose -f docker-compose.yml up --build
```

## 🌐 Check Your Internet Connection

```powershell
# Test general connectivity
Test-NetConnection -ComputerName google.com -Port 443

# Test Docker registry specifically
Test-NetConnection -ComputerName registry-1.docker.io -Port 443

# Test DNS resolution
nslookup registry-1.docker.io
```

## 📝 Most Common Causes

1. **VPN/Proxy interference** - Disable temporarily
2. **Corporate firewall** - May block Docker registry
3. **DNS server issues** - Switch to Google DNS (8.8.8.8)
4. **Docker Desktop bug** - Restart usually fixes it
5. **Windows Firewall** - May need to allow Docker

## ✅ Recommended Quick Fix

**Try this first (works 90% of the time):**

1. Quit Docker Desktop completely
2. Open Docker Desktop Settings → Docker Engine
3. Add this to the JSON:
   ```json
   "dns": ["8.8.8.8", "8.8.4.4"]
   ```
4. Apply & Restart
5. Wait for Docker to fully start
6. Run: `docker pull hello-world`
7. If that works, run your compose command

## 🆘 Still Not Working?

If none of these solutions work:

1. Check if you're behind a corporate firewall
2. Check if your antivirus is blocking Docker
3. Try using mobile hotspot temporarily to test
4. Check Docker Desktop logs:
   - Settings → Troubleshoot → View logs

## 📞 Need More Help?

- Docker Desktop logs: Settings → Troubleshoot → View logs
- Docker forums: https://forums.docker.com/
- Docker Desktop issues: https://github.com/docker/for-win/issues

---

**Most likely fix:** Restart Docker Desktop + Add Google DNS (8.8.8.8) to Docker Engine settings
