# 🔧 Troubleshooting Guide

## Common Issues and Solutions

### Issue 1: Docker API Error (500 Internal Server Error)

**Error:**
```
unable to get image: request returned 500 Internal Server Error
```

**Solution:**
1. Restart Docker Desktop
2. Wait for Docker to fully start (green icon in system tray)
3. Run again: `.\start.ps1`

**Or clean restart:**
```powershell
# Stop all containers
docker-compose down

# Remove old images (optional)
docker system prune -a

# Restart Docker Desktop

# Start fresh
.\start.ps1
```

---

### Issue 2: PowerShell Script Encoding Error

**Error:**
```
The string is missing the terminator
```

**Solution:**
Use the simple start script instead:
```powershell
.\start.ps1
```

Or run Docker directly:
```powershell
docker-compose up --build
```

---

### Issue 3: Docker Not Running

**Error:**
```
Cannot connect to Docker daemon
```

**Solution:**
1. Open Docker Desktop
2. Wait for it to start (green icon)
3. Run: `.\start.ps1`

---

### Issue 4: Port Already in Use

**Error:**
```
Port 3000 is already allocated
```

**Solution:**

**Option 1: Stop other services**
```powershell
# Find what's using port 3000
netstat -ano | findstr :3000

# Kill the process (replace PID with actual number)
taskkill /PID <PID> /F
```

**Option 2: Change port**
Edit `docker-compose.yml`:
```yaml
frontend:
  ports:
    - "3001:3000"  # Change 3000 to 3001
```

---

### Issue 5: Models Not Downloading

**Error:**
```
Connection timeout
Failed to download model
```

**Solution:**
1. Check internet connection
2. Wait longer (first time takes 10-15 minutes)
3. Check logs:
```powershell
docker-compose logs -f whisper
docker-compose logs -f llama_cpp
```

4. If still failing, try manual download:
```powershell
# Stop services
docker-compose down

# Remove volumes
docker volume rm local-voice-ai_whisper-data
docker volume rm local-voice-ai_llama-models

# Start fresh
docker-compose up --build
```

---

### Issue 6: Service Won't Start

**Check which service failed:**
```powershell
docker-compose ps
```

**View logs:**
```powershell
# All services
docker-compose logs

# Specific service
docker-compose logs whisper
docker-compose logs livekit_agent
docker-compose logs llama_cpp
```

**Restart specific service:**
```powershell
docker-compose restart whisper
docker-compose restart livekit_agent
```

---

### Issue 7: Out of Memory

**Error:**
```
OOMKilled
Container killed due to memory
```

**Solution:**

**Option 1: Increase Docker memory**
1. Open Docker Desktop
2. Settings → Resources
3. Increase Memory to 8GB or more
4. Apply & Restart

**Option 2: Use smaller model**
Edit `.env`:
```bash
# Use smaller LLM
LLAMA_HF_REPO=unsloth/Qwen2.5-1.5B-Instruct-GGUF
LLAMA_CTX_SIZE=8192
```

---

### Issue 8: Slow Performance

**Solutions:**

**1. Use GPU (if available):**
```powershell
docker-compose -f docker-compose.gpu.yml up --build
```

**2. Reduce context size:**
Edit `.env`:
```bash
LLAMA_CTX_SIZE=8192  # Reduce from 16384
```

**3. Use faster STT (English only):**
Edit `.env`:
```bash
STT_PROVIDER=nemotron  # Faster than Whisper
```

---

### Issue 9: Language Detection Not Working

**Problem:** AI responds in wrong language

**Solutions:**

1. **Speak clearly and in complete sentences**
   - Bad: "hi"
   - Good: "नमस्ते, आप कैसे हैं?"

2. **Don't mix languages**
   - Bad: "Hello, aap kaise ho?"
   - Good: "Hello, how are you?" OR "नमस्ते, आप कैसे हैं?"

3. **Check logs:**
```powershell
docker-compose logs -f livekit_agent | Select-String "Detected language"
```

---

### Issue 10: Web UI Not Loading

**Error:**
```
Cannot connect to localhost:3000
```

**Solutions:**

1. **Check if frontend is running:**
```powershell
docker-compose ps frontend
```

2. **Check frontend logs:**
```powershell
docker-compose logs -f frontend
```

3. **Restart frontend:**
```powershell
docker-compose restart frontend
```

4. **Try different browser:**
   - Chrome
   - Firefox
   - Edge

---

## Quick Fixes

### Complete Reset:
```powershell
# Stop everything
docker-compose down -v

# Remove all images
docker system prune -a

# Restart Docker Desktop

# Start fresh
docker-compose up --build
```

### Check Docker Status:
```powershell
docker info
docker-compose ps
docker stats
```

### View All Logs:
```powershell
docker-compose logs -f
```

### Restart Everything:
```powershell
docker-compose restart
```

---

## Still Having Issues?

### 1. Check System Requirements:
- Docker Desktop installed
- 8GB+ RAM available
- 20GB+ free disk space
- Internet connection

### 2. Verify Docker is Working:
```powershell
docker run hello-world
```

### 3. Check Docker Version:
```powershell
docker --version
docker-compose --version
```

Should be:
- Docker: 20.10+
- Docker Compose: 2.0+

### 4. View Detailed Logs:
```powershell
# Save logs to file
docker-compose logs > logs.txt

# View specific service
docker-compose logs livekit_agent > agent-logs.txt
```

---

## Emergency Commands

### Force Stop Everything:
```powershell
docker stop $(docker ps -aq)
docker rm $(docker ps -aq)
```

### Clean Everything:
```powershell
docker system prune -a --volumes
```

### Restart Docker Desktop:
```powershell
# Windows
Restart-Service docker

# Or manually restart Docker Desktop application
```

---

## Getting Help

If none of these solutions work:

1. **Check logs:**
```powershell
docker-compose logs > full-logs.txt
```

2. **Check system resources:**
```powershell
docker stats
```

3. **Verify configuration:**
```powershell
docker-compose config
```

4. **Share error details:**
   - Error message
   - Logs from `docker-compose logs`
   - System specs (RAM, CPU, OS)
   - Docker version

---

## Prevention Tips

1. **Always wait for Docker to fully start** before running commands
2. **Don't interrupt model downloads** on first run
3. **Keep Docker Desktop updated**
4. **Allocate enough resources** (8GB+ RAM)
5. **Check disk space** before starting (need 20GB+)

---

**Most issues are solved by restarting Docker Desktop! 🔄**
