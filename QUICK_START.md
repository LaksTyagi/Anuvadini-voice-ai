# 🚀 Quick Start Guide - Anuvadini Voice AI

## One Command to Run Everything!

### Windows (PowerShell):
```powershell
.\run.ps1
```

### Linux/Mac:
```bash
./run.sh
```

---

## Alternative Commands

### Start (Build + Run):
```bash
docker-compose up --build
```

### Start (Without Rebuild):
```bash
docker-compose up
```

### Stop:
```bash
docker-compose down
```

### Restart:
```bash
docker-compose restart
```

### View Logs:
```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f livekit_agent
docker-compose logs -f whisper
```

---

## First Time Setup

### 1. Start Docker Desktop
Make sure Docker Desktop is running on your system.

### 2. Run the Project
```powershell
# Windows
.\run.ps1

# Or manually
docker-compose up --build
```

### 3. Wait for Models to Download
First time will take 10-15 minutes to download:
- Whisper model (~3GB)
- Qwen LLM (~2GB)
- Kokoro TTS (~500MB)

### 4. Open Browser
```
http://localhost:3000
```

---

## Test Each Language

### Hindi (हिंदी):
```
"नमस्ते, आप कैसे हैं?"
"मौसम कैसा है?"
"दो गुणा तीन क्या होता है?"
```

### Punjabi (ਪੰਜਾਬੀ):
```
"ਸਤ ਸ੍ਰੀ ਅਕਾਲ"
"ਤੁਸੀਂ ਕਿਵੇਂ ਹੋ?"
"ਤੁਸੀਂ ਕੀ ਕਰ ਸਕਦੇ ਹੋ?"
```

### Tamil (தமிழ்):
```
"வணக்கம்"
"நீங்கள் எப்படி இருக்கிறீர்கள்?"
"நீங்கள் என்ன செய்ய முடியும்?"
```

### English:
```
"Hello, how are you?"
"What's the weather like?"
"What can you do?"
```

---

## Troubleshooting

### Docker Not Running
```
❌ Error: Cannot connect to Docker daemon
✅ Solution: Start Docker Desktop
```

### Port Already in Use
```
❌ Error: Port 3000 is already allocated
✅ Solution: Stop other services or change port in docker-compose.yml
```

### Models Not Downloading
```
❌ Error: Connection timeout
✅ Solution: Check internet connection, wait longer (first time takes 10-15 min)
```

### Services Not Starting
```bash
# Check status
docker-compose ps

# Restart specific service
docker-compose restart livekit_agent

# Full restart
docker-compose down
docker-compose up --build
```

---

## Service URLs

| Service | URL | Purpose |
|---------|-----|---------|
| **Frontend** | http://localhost:3000 | Web UI |
| **LiveKit** | ws://localhost:7880 | WebRTC Server |
| **Whisper STT** | http://localhost:11437 | Speech-to-Text |
| **Llama LLM** | http://localhost:11436 | AI Brain |
| **Kokoro TTS** | http://localhost:8880 | Text-to-Speech |

---

## Development Commands

### Rebuild Specific Service:
```bash
docker-compose up --build livekit_agent
```

### Shell into Container:
```bash
docker-compose exec livekit_agent bash
```

### Check Service Health:
```bash
# Whisper
curl http://localhost:11437/health

# Llama
curl http://localhost:11436/v1/models
```

---

## Performance Tips

### Faster Startup (Skip Rebuild):
```bash
docker-compose up
```

### Use GPU (if available):
```bash
docker-compose -f docker-compose.gpu.yml up
```

### Reduce Memory Usage:
Edit `.env`:
```bash
LLAMA_CTX_SIZE=8192  # Reduce from 16384
```

---

## Stopping the Project

### Graceful Stop:
```bash
docker-compose down
```

### Stop + Remove Volumes:
```bash
docker-compose down -v
```

### Stop + Remove Everything:
```bash
docker-compose down -v --rmi all
```

---

## Next Steps

1. ✅ Run the project: `.\run.ps1`
2. ✅ Open browser: http://localhost:3000
3. ✅ Test Hindi: "नमस्ते"
4. ✅ Test Punjabi: "ਸਤ ਸ੍ਰੀ ਅਕਾਲ"
5. ✅ Test Tamil: "வணக்கம்"
6. ✅ Test English: "Hello"

---

## Need Help?

Check logs:
```bash
docker-compose logs -f livekit_agent
```

View all services:
```bash
docker-compose ps
```

Restart everything:
```bash
docker-compose restart
```

---

**Enjoy your multilingual voice AI! 🎉**
