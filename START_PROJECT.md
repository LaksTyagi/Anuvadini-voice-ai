# 🚀 START PROJECT - Simple Commands

## ⚡ Quickest Way to Run

### Windows:
```powershell
.\run.ps1
```

### Linux/Mac:
```bash
./run.sh
```

### Windows (Alternative):
```batch
run.bat
```

---

## 📋 What Happens When You Run?

1. ✅ Checks if Docker is running
2. ✅ Starts all services (LiveKit, Whisper, Qwen, Kokoro, Frontend)
3. ✅ Downloads models on first run (~5-10 GB, takes 10-15 minutes)
4. ✅ Opens web interface at http://localhost:3000

---

## 🌍 Supported Languages

| Language | Example Phrase | Response |
|----------|----------------|----------|
| **Hindi** | नमस्ते, आप कैसे हैं? | नमस्ते! मैं बिल्कुल ठीक हूँ... |
| **Punjabi** | ਸਤ ਸ੍ਰੀ ਅਕਾਲ | ਸਤ ਸ੍ਰੀ ਅਕਾਲ! ਮੈਂ ਤੁਹਾਡੀ ਕਿਵੇਂ ਮਦਦ ਕਰ ਸਕਦਾ ਹਾਂ? |
| **Tamil** | வணக்கம் | வணக்கம்! நான் உங்களுக்கு எப்படி உதவ முடியும்? |
| **English** | Hello, how are you? | Hello! I'm doing great, thank you... |

---

## 🔧 All Available Commands

### Start Project:
```bash
# Quick start (recommended)
.\run.ps1              # Windows PowerShell
./run.sh               # Linux/Mac
run.bat                # Windows Batch

# Manual start
docker-compose up --build
```

### Stop Project:
```bash
docker-compose down
```

### Restart Project:
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

### Check Status:
```bash
docker-compose ps
```

---

## 📱 Access Points

| Service | URL | Purpose |
|---------|-----|---------|
| **Web UI** | http://localhost:3000 | Main interface |
| **LiveKit** | ws://localhost:7880 | WebRTC server |
| **Whisper** | http://localhost:11437 | Speech-to-Text |
| **Qwen LLM** | http://localhost:11436 | AI Brain |
| **Kokoro TTS** | http://localhost:8880 | Text-to-Speech |

---

## ⏱️ First Time Setup Timeline

| Step | Time | What's Happening |
|------|------|------------------|
| Docker build | 2-3 min | Building containers |
| Whisper download | 5-7 min | Downloading STT model (~3GB) |
| Qwen download | 3-5 min | Downloading LLM (~2GB) |
| Kokoro download | 1-2 min | Downloading TTS (~500MB) |
| **Total** | **10-15 min** | First run only |

**Subsequent runs:** ~30 seconds to start!

---

## 🎯 Quick Test Script

After starting, test each language:

```bash
# Open browser
http://localhost:3000

# Test Hindi
Say: "नमस्ते, आप कैसे हैं?"

# Test Punjabi
Say: "ਸਤ ਸ੍ਰੀ ਅਕਾਲ"

# Test Tamil
Say: "வணக்கம்"

# Test English
Say: "Hello, how are you?"
```

---

## 🐛 Troubleshooting

### Docker Not Running
```
Error: Cannot connect to Docker daemon
Solution: Start Docker Desktop
```

### Port Already in Use
```
Error: Port 3000 is already allocated
Solution: 
1. Stop other services using port 3000
2. Or change port in docker-compose.yml
```

### Models Not Downloading
```
Error: Connection timeout
Solution:
1. Check internet connection
2. Wait longer (first time takes 10-15 min)
3. Check logs: docker-compose logs -f whisper
```

### Service Not Starting
```bash
# Check which service failed
docker-compose ps

# View logs
docker-compose logs -f [service-name]

# Restart specific service
docker-compose restart [service-name]

# Full restart
docker-compose down
docker-compose up --build
```

---

## 📚 Documentation

| File | Purpose |
|------|---------|
| `QUICK_START.md` | Comprehensive quick start guide |
| `MULTILINGUAL_GUIDE.md` | Multilingual features and testing |
| `MULTILINGUAL_IMPLEMENTATION_PLAN.md` | Technical implementation details |
| `README.md` | Project overview |
| `START_HERE.md` | Original setup guide |

---

## 🎉 Success Checklist

- [ ] Docker Desktop is running
- [ ] Run `.\run.ps1` or `./run.sh`
- [ ] Wait for models to download (first time only)
- [ ] Open http://localhost:3000
- [ ] Test Hindi: "नमस्ते"
- [ ] Test Punjabi: "ਸਤ ਸ੍ਰੀ ਅਕਾਲ"
- [ ] Test Tamil: "வணக்கம்"
- [ ] Test English: "Hello"

---

## 💡 Pro Tips

1. **First run takes time**: Be patient, models are downloading
2. **Speak clearly**: Better recognition for all languages
3. **Use complete sentences**: Better language detection
4. **Check logs if issues**: `docker-compose logs -f`
5. **Restart if stuck**: `docker-compose restart`

---

## 🚀 Ready to Start?

```powershell
# Windows
.\run.ps1

# Linux/Mac
./run.sh
```

**Then open:** http://localhost:3000

**Enjoy your multilingual voice AI! 🎉**
