# Local Voice AI - Setup Guide

## Prerequisites Check

✅ Docker installed (version 29.4.0 detected)
✅ Docker Compose installed (version 5.1.1 detected)
✅ All configuration files are present
✅ Environment variables configured

## Current Status

⚠️ **Docker Desktop is not running** - You need to start it before proceeding.

## Step-by-Step Setup

### 1. Start Docker Desktop

**Windows:**
- Open Docker Desktop from the Start menu
- Wait for Docker Desktop to fully start (the whale icon in the system tray should be steady)
- Verify it's running by opening a terminal and running: `docker ps`

### 2. Launch the Application

Once Docker Desktop is running, use one of these methods:

**Option A: Using Docker Compose directly (Recommended for Windows)**
```bash
docker compose -f docker-compose.yml up --build
```

**Option B: Using the PowerShell script**
If you want to use the provided script, first set the execution policy:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
./compose-up.ps1 cpu --build
```

**Option C: For GPU support (if you have NVIDIA GPU)**
```bash
docker compose -f docker-compose.yml -f docker-compose.gpu.yml up --build
```

### 3. Wait for Services to Start

The first run will take 10-30 minutes because it needs to:
- Build Docker images for all services
- Download AI models (several GB):
  - Qwen 2.5 3B LLM model (~2GB)
  - Nemotron speech-to-text model (~600MB)
  - Kokoro text-to-speech model
  - Silero VAD model

You'll see output like:
```
[+] Building...
[+] Running...
livekit_1        | LiveKit server started
nemotron_1       | Downloading model...
llama_cpp_1      | Downloading from Hugging Face...
kokoro_1         | Server ready
livekit_agent_1  | Waiting for dependencies...
frontend_1       | Server listening on port 3000
```

### 4. Access the Application

Once all services show "healthy" or "started":

🌐 **Open your browser and go to:** http://localhost:3000

You should see the Local Voice AI interface!

### 5. Test the Voice Assistant

1. Click "Connect" or "Start Session"
2. Allow microphone access when prompted
3. Start speaking to the AI assistant
4. The assistant will respond with voice

## Service Ports

- **Frontend UI:** http://localhost:3000
- **LiveKit Server:** ws://localhost:7880
- **LLM API (llama.cpp):** http://localhost:11436
- **STT API (Nemotron):** http://localhost:11435
- **TTS API (Kokoro):** http://localhost:8880

## Configuration

### Current Settings (from .env)

- **LLM Model:** Qwen 2.5 3B Instruct (4-bit quantized)
- **STT Provider:** Nemotron Speech Streaming
- **TTS Voice:** Kokoro (af_nova voice)
- **Context Size:** 16,384 tokens

### To Change Models

Edit the `.env` file:

```bash
# For a different LLM model
LLAMA_HF_REPO=Qwen/Qwen2.5-7B-Instruct-GGUF:qwen2.5-7b-instruct-q4_k_m.gguf
LLAMA_MODEL=qwen2.5-7b-instruct
LLAMA_MODEL_ALIAS=qwen2.5-7b-instruct

# For Whisper STT instead of Nemotron
STT_PROVIDER=whisper
docker compose --profile whisper up --build
```

## Troubleshooting

### Docker Desktop Not Running
**Error:** `failed to connect to the docker API`
**Solution:** Start Docker Desktop and wait for it to fully initialize

### Port Already in Use
**Error:** `port is already allocated`
**Solution:** Stop other services using ports 3000, 7880, 8880, 11435, or 11436

### Out of Memory
**Error:** Container crashes or system freezes
**Solution:** 
- Increase Docker Desktop memory limit (Settings → Resources → Memory)
- Recommended: 12GB+ RAM
- Use a smaller model (e.g., Qwen 1.5B instead of 3B)

### Model Download Fails
**Error:** `Failed to download model from Hugging Face`
**Solution:**
- Check internet connection
- Verify Hugging Face is accessible
- Try again - downloads resume automatically

### Services Not Healthy
**Error:** `livekit_agent_1 | Waiting for dependencies...` (stuck)
**Solution:**
- Check logs: `docker compose logs nemotron`
- Check logs: `docker compose logs llama_cpp`
- Ensure models are downloading/loaded

## Stopping the Application

Press `Ctrl+C` in the terminal where Docker Compose is running, then:

```bash
docker compose down
```

To also remove volumes (downloaded models):
```bash
docker compose down -v
```

## Development Mode

To run individual services locally (without Docker):

### Frontend
```bash
cd frontend
pnpm install
pnpm dev
```

### Agent
```bash
cd livekit_agent
uv sync
uv run python src/agent.py dev
```

## System Requirements

- **OS:** Windows 10/11, macOS, or Linux
- **RAM:** 12GB+ recommended (8GB minimum)
- **Disk:** 20GB+ free space for models
- **CPU:** Modern multi-core processor
- **GPU:** Optional (NVIDIA GPU with CUDA support for faster inference)

## Next Steps

1. ✅ Start Docker Desktop
2. ✅ Run `docker compose -f docker-compose.yml up --build`
3. ✅ Wait for all services to start (10-30 minutes first time)
4. ✅ Open http://localhost:3000
5. ✅ Start chatting with your local voice AI!

## Additional Resources

- **Project README:** [README.md](README.md)
- **Agent Documentation:** [livekit_agent/README.md](livekit_agent/README.md)
- **LiveKit Docs:** https://docs.livekit.io/
- **Model Hub:** https://huggingface.co/

---

**Need Help?** Check the logs with `docker compose logs [service-name]`
