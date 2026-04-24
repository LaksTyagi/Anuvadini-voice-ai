# Local Voice AI - Quick Reference

## 🚀 Start Application

```powershell
# Windows - Quick start
./start.ps1

# Windows - Manual
docker compose -f docker-compose.yml up --build

# With GPU
docker compose -f docker-compose.yml -f docker-compose.gpu.yml up --build
```

## 🛑 Stop Application

```powershell
# Graceful stop (Ctrl+C in terminal, then)
docker compose down

# Force stop and remove volumes
docker compose down -v
```

## 🔗 Access Points

| Service | URL | Purpose |
|---------|-----|---------|
| **Frontend** | http://localhost:3000 | Main UI |
| **LiveKit** | ws://localhost:7880 | WebRTC server |
| **LLM API** | http://localhost:11436/v1 | Language model |
| **STT API** | http://localhost:11435/v1 | Speech-to-text |
| **TTS API** | http://localhost:8880/v1 | Text-to-speech |

## 📊 Check Status

```powershell
# List running containers
docker ps

# View all logs
docker compose logs

# View specific service logs
docker compose logs frontend
docker compose logs livekit_agent
docker compose logs nemotron
docker compose logs llama_cpp
docker compose logs kokoro

# Follow logs in real-time
docker compose logs -f livekit_agent
```

## 🔧 Common Commands

```powershell
# Restart a specific service
docker compose restart livekit_agent

# Rebuild a specific service
docker compose up --build livekit_agent

# Stop a specific service
docker compose stop frontend

# Start a specific service
docker compose start frontend

# Remove all containers and volumes
docker compose down -v --remove-orphans

# View resource usage
docker stats
```

## 🐛 Troubleshooting

```powershell
# Check if Docker is running
docker ps

# Check Docker version
docker --version
docker compose version

# View container health
docker compose ps

# Inspect a container
docker compose logs nemotron --tail 100

# Restart everything
docker compose restart

# Clean rebuild
docker compose down -v
docker compose up --build
```

## ⚙️ Configuration Files

| File | Purpose |
|------|---------|
| `.env` | Main environment variables |
| `docker-compose.yml` | Service definitions |
| `frontend/.env.local` | Frontend config |
| `livekit_agent/src/agent.py` | Agent logic |

## 🎛️ Environment Variables

### LLM Configuration
```bash
LLAMA_MODEL=qwen2.5-3b-instruct
LLAMA_HF_REPO=Qwen/Qwen2.5-3B-Instruct-GGUF:qwen2.5-3b-instruct-q4_k_m.gguf
LLAMA_CTX_SIZE=16384
```

### STT Configuration
```bash
STT_PROVIDER=nemotron
STT_MODEL=nemotron-speech-streaming
STT_BASE_URL=http://nemotron:8000/v1
```

### TTS Configuration
```bash
TTS_MODEL=kokoro
TTS_VOICE=af_nova
TTS_BASE_URL=http://kokoro:8880/v1
```

## 🔄 Switch Models

### Use Different LLM
Edit `.env`:
```bash
LLAMA_HF_REPO=Qwen/Qwen2.5-7B-Instruct-GGUF:qwen2.5-7b-instruct-q4_k_m.gguf
LLAMA_MODEL=qwen2.5-7b-instruct
LLAMA_MODEL_ALIAS=qwen2.5-7b-instruct
```

### Use Whisper STT
Edit `.env`:
```bash
STT_PROVIDER=whisper
STT_BASE_URL=http://whisper:80/v1
STT_MODEL=Systran/faster-whisper-small
```

Then run:
```powershell
docker compose --profile whisper up --build
```

### Change TTS Voice
Edit `.env`:
```bash
TTS_VOICE=af_bella  # or af_sarah, af_nicole, etc.
```

## 📦 Docker Volumes

```powershell
# List volumes
docker volume ls

# Inspect volume
docker volume inspect local-voice-ai_llama-models

# Remove unused volumes
docker volume prune

# Remove specific volume
docker volume rm local-voice-ai_llama-models
```

## 🧪 Development Mode

### Run Frontend Locally
```powershell
cd frontend
pnpm install
pnpm dev
# Access at http://localhost:3000
```

### Run Agent Locally
```powershell
cd livekit_agent
uv sync
uv run python src/agent.py dev
```

## 📈 Performance Tips

### Reduce Memory Usage
- Use smaller models (1.5B instead of 3B)
- Reduce context size: `LLAMA_CTX_SIZE=4096`
- Limit Docker memory in settings

### Speed Up Inference
- Use GPU mode if available
- Use quantized models (Q4_K_M)
- Reduce context window

### Faster Startup
- Don't use `--build` after first run
- Keep volumes (don't use `-v` flag)
- Pre-download models

## 🎯 Testing

```powershell
# Test LLM API
curl http://localhost:11436/v1/models

# Test STT API
curl http://localhost:11435/v1/models

# Test TTS API
curl http://localhost:8880/v1/models

# Test LiveKit
curl http://localhost:7880
```

## 📱 Alternative Clients

### Terminal UI (TUI)
```powershell
cd tui
cargo build --release
cargo run -- --url ws://localhost:7880
```

### Custom Frontend
Connect to: `ws://localhost:7880`
Use API key: `devkey`
Use secret: `secret`

## 🔐 Security Notes

**Development Mode:**
- Default credentials: `devkey` / `secret`
- No authentication required
- Not for production use

**Production:**
- Change `LIVEKIT_API_KEY` and `LIVEKIT_API_SECRET`
- Use proper authentication
- Enable HTTPS/WSS
- Restrict network access

## 💾 Backup & Restore

### Backup Models
```powershell
docker run --rm -v local-voice-ai_llama-models:/data -v ${PWD}:/backup ubuntu tar czf /backup/models-backup.tar.gz /data
```

### Restore Models
```powershell
docker run --rm -v local-voice-ai_llama-models:/data -v ${PWD}:/backup ubuntu tar xzf /backup/models-backup.tar.gz -C /
```

## 📊 System Requirements

| Component | Minimum | Recommended |
|-----------|---------|-------------|
| RAM | 8GB | 12GB+ |
| Disk | 15GB | 20GB+ |
| CPU | 4 cores | 8+ cores |
| GPU | None | NVIDIA with CUDA |

## 🆘 Emergency Commands

```powershell
# Kill all containers
docker compose kill

# Remove everything
docker compose down -v --remove-orphans

# Clean Docker system
docker system prune -a --volumes

# Restart Docker Desktop
# (Use Docker Desktop UI)
```

## 📚 Documentation

- **Setup Guide:** [SETUP_GUIDE.md](SETUP_GUIDE.md)
- **Checklist:** [CHECKLIST.md](CHECKLIST.md)
- **Main README:** [README.md](README.md)
- **Agent README:** [livekit_agent/README.md](livekit_agent/README.md)

---

**Quick Start:** `./start.ps1` → Wait 10-30 min → Open http://localhost:3000
