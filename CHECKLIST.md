# Local Voice AI - Pre-Flight Checklist

## ✅ Configuration Status

### Environment Files
- ✅ `.env` - Main configuration file (configured)
- ✅ `frontend/.env.local` - Frontend configuration (configured)
- ✅ `livekit_agent/.env.example` - Agent example (present)

### Docker Configuration
- ✅ `docker-compose.yml` - Main compose file (verified)
- ✅ `docker-compose.gpu.yml` - GPU configuration (verified)
- ✅ `docker-compose.macos.yml` - macOS configuration (present)

### Dockerfiles
- ✅ `frontend/Dockerfile` - Frontend build (verified)
- ✅ `livekit_agent/Dockerfile` - Agent build (verified)
- ✅ `inference/kokoro/Dockerfile` - TTS service (verified)
- ✅ `inference/nemotron/Dockerfile` - STT service (verified)
- ✅ `inference/whisper/Dockerfile` - Alternative STT (present)
- ✅ `inference/llama/Dockerfile` - LLM service (present)

### Application Code
- ✅ `livekit_agent/src/agent.py` - Main agent logic (verified)
- ✅ `frontend/app/` - Next.js application (verified)
- ✅ `frontend/components/` - React components (verified)

## 🔧 System Requirements

### Installed
- ✅ Docker 29.4.0
- ✅ Docker Compose 5.1.1

### Required (User Action)
- ⚠️ **Docker Desktop must be running**
- ⚠️ **12GB+ RAM recommended** (check Docker Desktop settings)
- ⚠️ **20GB+ free disk space** (for models)

## 📋 Configuration Summary

### Current Model Configuration
```
LLM:  Qwen 2.5 3B Instruct (Q4_K_M quantized)
STT:  Nemotron Speech Streaming (0.6B)
TTS:  Kokoro (af_nova voice)
VAD:  Silero
```

### Service Ports
```
Frontend:     http://localhost:3000
LiveKit:      ws://localhost:7880
LLM API:      http://localhost:11436
STT API:      http://localhost:11435
TTS API:      http://localhost:8880
```

### Network Configuration
```
Network:      agent_network (bridge)
LiveKit URL:  ws://livekit:7880 (internal)
              ws://localhost:7880 (browser)
```

## 🚀 Quick Start Commands

### Windows (PowerShell)
```powershell
# Option 1: Use the quick start script
./start.ps1

# Option 2: Direct Docker Compose
docker compose -f docker-compose.yml up --build

# Option 3: With GPU support
docker compose -f docker-compose.yml -f docker-compose.gpu.yml up --build
```

### Linux/Mac (Bash)
```bash
# Option 1: Use the quick start script
./start.sh

# Option 2: Direct Docker Compose
docker compose -f docker-compose.yml up --build

# Option 3: With GPU support
docker compose -f docker-compose.yml -f docker-compose.gpu.yml up --build
```

## 📊 Expected Startup Sequence

1. **Building Images** (5-10 minutes)
   - kokoro
   - livekit (pulls from registry)
   - nemotron
   - llama_cpp (pulls from registry)
   - livekit_agent
   - frontend

2. **Starting Services** (1-2 minutes)
   - livekit → Ready
   - kokoro → Ready
   - nemotron → Downloading model...
   - llama_cpp → Downloading model...

3. **Model Downloads** (5-20 minutes, first run only)
   - Nemotron: ~600MB
   - Qwen 2.5 3B: ~2GB
   - Kokoro: ~500MB
   - Silero VAD: ~50MB

4. **Health Checks** (1-2 minutes)
   - nemotron → healthy
   - llama_cpp → healthy
   - livekit_agent → healthy

5. **Ready!** 🎉
   - All services running
   - Frontend accessible at http://localhost:3000

## 🔍 Verification Steps

### 1. Check Docker Desktop
```powershell
docker ps
```
Should show no errors.

### 2. Start Services
```powershell
docker compose -f docker-compose.yml up --build
```

### 3. Monitor Logs
Watch for these key messages:
- `livekit_1 | LiveKit server started`
- `nemotron_1 | Model loaded successfully`
- `llama_cpp_1 | HTTP server listening`
- `kokoro_1 | Server ready`
- `livekit_agent_1 | Agent started`
- `frontend_1 | Ready on http://0.0.0.0:3000`

### 4. Test Frontend
Open browser: http://localhost:3000

### 5. Test Voice Connection
1. Click "Connect" or "Start Session"
2. Allow microphone access
3. Say "Hello, can you hear me?"
4. Wait for AI response

## 🐛 Common Issues & Solutions

### Issue: Docker Desktop Not Running
**Symptom:** `failed to connect to the docker API`
**Solution:** Start Docker Desktop, wait for full initialization

### Issue: Port Already in Use
**Symptom:** `port is already allocated`
**Solution:** 
```powershell
# Find process using port
netstat -ano | findstr :3000
# Kill process or change port in docker-compose.yml
```

### Issue: Out of Memory
**Symptom:** Container crashes, system slow
**Solution:**
- Open Docker Desktop → Settings → Resources
- Increase Memory to 12GB+
- Restart Docker Desktop

### Issue: Model Download Fails
**Symptom:** `Failed to download from Hugging Face`
**Solution:**
- Check internet connection
- Verify Hugging Face is accessible
- Restart the service (downloads resume)

### Issue: Services Not Healthy
**Symptom:** Agent waiting forever
**Solution:**
```powershell
# Check specific service logs
docker compose logs nemotron
docker compose logs llama_cpp

# Restart specific service
docker compose restart nemotron
```

## 📝 Post-Startup Checklist

- [ ] All containers running (`docker ps` shows 6 containers)
- [ ] No error messages in logs
- [ ] Frontend loads at http://localhost:3000
- [ ] Can connect to voice session
- [ ] Microphone access granted
- [ ] AI responds to voice input
- [ ] Audio output working

## 🎯 Success Criteria

Your Local Voice AI is working correctly when:

1. ✅ Frontend UI loads without errors
2. ✅ Can create a new session
3. ✅ Microphone captures audio
4. ✅ Speech is transcribed (STT working)
5. ✅ AI generates responses (LLM working)
6. ✅ Responses are spoken (TTS working)
7. ✅ Conversation flows naturally

## 📚 Additional Resources

- **Setup Guide:** [SETUP_GUIDE.md](SETUP_GUIDE.md)
- **Project README:** [README.md](README.md)
- **Agent Docs:** [livekit_agent/README.md](livekit_agent/README.md)
- **LiveKit Docs:** https://docs.livekit.io/

## 🆘 Getting Help

If you encounter issues:

1. Check logs: `docker compose logs [service-name]`
2. Review SETUP_GUIDE.md troubleshooting section
3. Verify all prerequisites are met
4. Try rebuilding: `docker compose down -v && docker compose up --build`

---

**Ready to start?** Run `./start.ps1` (Windows) or `./start.sh` (Linux/Mac)
