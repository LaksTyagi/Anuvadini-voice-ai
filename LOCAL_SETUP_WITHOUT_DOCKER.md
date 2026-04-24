    # Local Voice AI - Setup Without Docker

This guide will help you run the Local Voice AI project directly on your machine without Docker.

## 📋 Prerequisites

### Required Software
- **Python 3.10+** - [Download](https://www.python.org/downloads/)
- **Node.js 20+** - [Download](https://nodejs.org/)
- **pnpm** - `npm install -g pnpm`
- **uv** (Python package manager) - [Install Guide](https://docs.astral.sh/uv/getting-started/installation/)
- **Git** - [Download](https://git-scm.com/)

### System Requirements
- **RAM:** 12GB+ recommended
- **Disk:** 20GB+ free space
- **OS:** Windows 10/11, macOS, or Linux

---

## 🚀 Step-by-Step Setup

### Step 1: Install LiveKit Server

#### Option A: Download Binary (Recommended)

**Windows:**
```powershell
# Download LiveKit server
Invoke-WebRequest -Uri "https://github.com/livekit/livekit/releases/latest/download/livekit-server-windows-amd64.exe" -OutFile "livekit-server.exe"

# Create config file
@"
port: 7880
rtc:
  port_range_start: 50000
  port_range_end: 60000
keys:
  devkey: secret
"@ | Out-File -FilePath livekit.yaml -Encoding UTF8
```

**macOS/Linux:**
```bash
# Download LiveKit server
curl -L https://github.com/livekit/livekit/releases/latest/download/livekit-server-$(uname -s | tr '[:upper:]' '[:lower:]')-amd64 -o livekit-server
chmod +x livekit-server

# Create config file
cat > livekit.yaml << EOF
port: 7880
rtc:
  port_range_start: 50000
  port_range_end: 60000
keys:
  devkey: secret
EOF
```

#### Option B: Install via Package Manager

**macOS (Homebrew):**
```bash
brew install livekit
```

**Linux (apt):**
```bash
curl -sSL https://get.livekit.io | bash
```

---

### Step 2: Install Python Dependencies (uv)

```bash
# Install uv if not already installed
# Windows (PowerShell)
powershell -ExecutionPolicy ByPass -c "irm https://astral.sh/uv/install.ps1 | iex"

# macOS/Linux
curl -LsSf https://astral.sh/uv/install.sh | sh

# Or using pip
pip install uv
```

---

### Step 3: Setup STT (Speech-to-Text) - Nemotron

Create a new directory for Nemotron:

```bash
mkdir nemotron-stt
cd nemotron-stt
```

Create `requirements.txt`:
```txt
fastapi
uvicorn[standard]
torch
torchaudio
nemo-toolkit[asr]
huggingface_hub
python-multipart
```

Create `server.py`:
```python
import os
import logging
from fastapi import FastAPI, File, UploadFile, Form
from fastapi.responses import JSONResponse
import torch
import nemo.collections.asr as nemo_asr

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = FastAPI()

# Load model
MODEL_NAME = os.getenv("NEMOTRON_MODEL_NAME", "nvidia/nemotron-speech-streaming-en-0.6b")
MODEL_ID = os.getenv("NEMOTRON_MODEL_ID", "nemotron-speech-streaming")

logger.info(f"Loading model: {MODEL_NAME}")
asr_model = nemo_asr.models.ASRModel.from_pretrained(MODEL_NAME)
logger.info("Model loaded successfully")

@app.get("/health")
async def health():
    return {"status": "healthy", "model_loaded": True}

@app.get("/v1/models")
async def list_models():
    return {
        "object": "list",
        "data": [{"id": MODEL_ID, "object": "model", "owned_by": "nvidia"}]
    }

@app.post("/v1/audio/transcriptions")
async def transcribe(
    file: UploadFile = File(...),
    model: str = Form(...)
):
    try:
        # Save uploaded file temporarily
        temp_path = f"/tmp/{file.filename}"
        with open(temp_path, "wb") as f:
            f.write(await file.read())
        
        # Transcribe
        transcription = asr_model.transcribe([temp_path])[0]
        
        # Clean up
        os.remove(temp_path)
        
        return {"text": transcription}
    except Exception as e:
        logger.error(f"Transcription error: {e}")
        return JSONResponse(status_code=500, content={"error": str(e)})

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
```

Install and run:
```bash
# Install dependencies
pip install -r requirements.txt

# Run server
python server.py
```

**Note:** Nemotron requires significant resources. For a lighter alternative, see Step 3B below.

---

### Step 3B: Alternative STT - Faster Whisper (Lighter)

```bash
pip install faster-whisper openai-whisper fastapi uvicorn
```

Create `whisper_server.py`:
```python
from fastapi import FastAPI, File, UploadFile, Form
from faster_whisper import WhisperModel
import tempfile
import os

app = FastAPI()

# Load Whisper model
model = WhisperModel("base", device="cpu", compute_type="int8")

@app.get("/health")
async def health():
    return {"status": "healthy", "model_loaded": True}

@app.get("/v1/models")
async def list_models():
    return {
        "object": "list",
        "data": [{"id": "whisper-base", "object": "model"}]
    }

@app.post("/v1/audio/transcriptions")
async def transcribe(file: UploadFile = File(...), model: str = Form(...)):
    with tempfile.NamedTemporaryFile(delete=False, suffix=".wav") as tmp:
        tmp.write(await file.read())
        tmp_path = tmp.name
    
    segments, info = model.transcribe(tmp_path)
    text = " ".join([segment.text for segment in segments])
    
    os.unlink(tmp_path)
    return {"text": text}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
```

Run:
```bash
python whisper_server.py
```

---

### Step 4: Setup LLM - llama.cpp

#### Download llama.cpp

**Windows:**
```powershell
# Download pre-built binary
Invoke-WebRequest -Uri "https://github.com/ggml-org/llama.cpp/releases/latest/download/llama-server-windows-x64.exe" -OutFile "llama-server.exe"
```

**macOS:**
```bash
brew install llama.cpp
```

**Linux:**
```bash
# Build from source
git clone https://github.com/ggml-org/llama.cpp
cd llama.cpp
make
```

#### Download Model

```bash
# Create models directory
mkdir models
cd models

# Download Qwen 2.5 3B model (Q4_K_M quantized, ~2GB)
# Using huggingface-cli
pip install huggingface-hub

# Download model
huggingface-cli download Qwen/Qwen2.5-3B-Instruct-GGUF qwen2.5-3b-instruct-q4_k_m.gguf --local-dir .
```

#### Run llama-server

**Windows:**
```powershell
./llama-server.exe `
  --model models/qwen2.5-3b-instruct-q4_k_m.gguf `
  --host 0.0.0.0 `
  --port 11434 `
  --ctx-size 16384 `
  --alias qwen2.5-3b-instruct
```

**macOS/Linux:**
```bash
./llama-server \
  --model models/qwen2.5-3b-instruct-q4_k_m.gguf \
  --host 0.0.0.0 \
  --port 11434 \
  --ctx-size 16384 \
  --alias qwen2.5-3b-instruct
```

---

### Step 5: Setup TTS (Text-to-Speech) - Kokoro

#### Install Kokoro

```bash
pip install kokoro-onnx fastapi uvicorn
```

#### Create TTS Server

Create `kokoro_server.py`:
```python
from fastapi import FastAPI, HTTPException
from fastapi.responses import Response
from pydantic import BaseModel
import kokoro
import io

app = FastAPI()

# Initialize Kokoro
tts = kokoro.Kokoro()

class TTSRequest(BaseModel):
    input: str
    model: str = "kokoro"
    voice: str = "af_nova"

@app.get("/v1/models")
async def list_models():
    return {
        "object": "list",
        "data": [{"id": "kokoro", "object": "model"}]
    }

@app.post("/v1/audio/speech")
async def synthesize(request: TTSRequest):
    try:
        # Generate audio
        audio = tts.create(text=request.input, voice=request.voice)
        
        # Convert to bytes
        audio_bytes = io.BytesIO()
        audio.export(audio_bytes, format="mp3")
        audio_bytes.seek(0)
        
        return Response(content=audio_bytes.read(), media_type="audio/mpeg")
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8880)
```

Run:
```bash
python kokoro_server.py
```

#### Alternative: Use Piper TTS (Lighter)

```bash
pip install piper-tts fastapi uvicorn
```

Create `piper_server.py`:
```python
from fastapi import FastAPI
from fastapi.responses import Response
from pydantic import BaseModel
import subprocess
import tempfile
import os

app = FastAPI()

class TTSRequest(BaseModel):
    input: str
    model: str = "piper"
    voice: str = "en_US-lessac-medium"

@app.post("/v1/audio/speech")
async def synthesize(request: TTSRequest):
    with tempfile.NamedTemporaryFile(delete=False, suffix=".wav") as tmp:
        tmp_path = tmp.name
    
    # Run piper
    process = subprocess.run(
        ["piper", "--model", request.voice, "--output_file", tmp_path],
        input=request.input.encode(),
        capture_output=True
    )
    
    with open(tmp_path, "rb") as f:
        audio_data = f.read()
    
    os.unlink(tmp_path)
    return Response(content=audio_data, media_type="audio/wav")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8880)
```

---

### Step 6: Setup LiveKit Agent

```bash
cd livekit_agent

# Install dependencies using uv
uv sync

# Download required models
uv run python src/agent.py download-files
```

Create `.env.local` file in `livekit_agent/` directory:
```bash
LIVEKIT_URL=ws://localhost:7880
LIVEKIT_API_KEY=devkey
LIVEKIT_API_SECRET=secret

# STT Configuration
STT_PROVIDER=nemotron
STT_BASE_URL=http://localhost:8000/v1
STT_MODEL=nemotron-speech-streaming
STT_API_KEY=no-key-needed

# LLM Configuration
LLAMA_BASE_URL=http://localhost:11434/v1
LLAMA_MODEL=qwen2.5-3b-instruct

# TTS Configuration
TTS_BASE_URL=http://localhost:8880/v1
TTS_MODEL=kokoro
TTS_VOICE=af_nova
TTS_API_KEY=no-key-needed
```

Run the agent:
```bash
uv run python src/agent.py dev
```

---

### Step 7: Setup Frontend

```bash
cd frontend

# Install dependencies
pnpm install
```

Create `.env.local` file in `frontend/` directory:
```bash
LIVEKIT_URL=ws://localhost:7880
LIVEKIT_API_KEY=devkey
LIVEKIT_API_SECRET=secret
NEXT_PUBLIC_LIVEKIT_URL=ws://localhost:7880
```

Run the frontend:
```bash
pnpm dev
```

---

## 🎯 Running Everything

You need to run all services in separate terminal windows:

### Terminal 1: LiveKit Server
```bash
./livekit-server --dev --bind 0.0.0.0
```

### Terminal 2: STT Service (Nemotron or Whisper)
```bash
python server.py
# or
python whisper_server.py
```

### Terminal 3: LLM Service (llama.cpp)
```bash
./llama-server --model models/qwen2.5-3b-instruct-q4_k_m.gguf --host 0.0.0.0 --port 11434 --ctx-size 16384
```

### Terminal 4: TTS Service (Kokoro or Piper)
```bash
python kokoro_server.py
# or
python piper_server.py
```

### Terminal 5: LiveKit Agent
```bash
cd livekit_agent
uv run python src/agent.py dev
```

### Terminal 6: Frontend
```bash
cd frontend
pnpm dev
```

---

## 🌐 Access the Application

Once all services are running, open your browser:

**http://localhost:3000**

---

## 📊 Service Ports

| Service | Port | URL |
|---------|------|-----|
| Frontend | 3000 | http://localhost:3000 |
| LiveKit | 7880 | ws://localhost:7880 |
| STT (Nemotron/Whisper) | 8000 | http://localhost:8000 |
| LLM (llama.cpp) | 11434 | http://localhost:11434 |
| TTS (Kokoro/Piper) | 8880 | http://localhost:8880 |

---

## 🔧 Troubleshooting

### Port Already in Use
```bash
# Windows - Find process using port
netstat -ano | findstr :3000

# Kill process
taskkill /PID <PID> /F

# macOS/Linux
lsof -ti:3000 | xargs kill -9
```

### Python Module Not Found
```bash
# Reinstall dependencies
pip install --upgrade -r requirements.txt
```

### Model Download Failed
```bash
# Manually download from Hugging Face
# Visit: https://huggingface.co/Qwen/Qwen2.5-3B-Instruct-GGUF
# Download: qwen2.5-3b-instruct-q4_k_m.gguf
# Place in: models/ directory
```

### LiveKit Connection Failed
- Check if LiveKit server is running
- Verify port 7880 is not blocked by firewall
- Check `livekit.yaml` configuration

---

## 💡 Optimization Tips

### Use GPU Acceleration

**For llama.cpp (NVIDIA GPU):**
```bash
# Download CUDA version
# Windows: llama-server-cuda.exe
# Linux: Build with CUDA support

./llama-server-cuda --model models/qwen2.5-3b-instruct-q4_k_m.gguf --n-gpu-layers 35
```

**For Whisper (GPU):**
```bash
pip install faster-whisper[gpu]
# Modify whisper_server.py: device="cuda"
```

### Reduce Memory Usage

1. **Use smaller models:**
   - LLM: Qwen 1.5B instead of 3B
   - STT: Whisper tiny/base instead of Nemotron
   - Reduce context size: `--ctx-size 4096`

2. **Close unnecessary applications**

3. **Limit concurrent requests**

---

## 🔄 Alternative Lightweight Setup

For systems with limited resources:

### Minimal Configuration

1. **STT:** Faster Whisper (base model)
2. **LLM:** Qwen 1.5B or TinyLlama 1.1B
3. **TTS:** Piper TTS
4. **Context Size:** 4096 tokens

### Download Smaller Model

```bash
# Download TinyLlama (1.1B, ~600MB)
huggingface-cli download TheBloke/TinyLlama-1.1B-Chat-v1.0-GGUF tinyllama-1.1b-chat-v1.0.Q4_K_M.gguf --local-dir models
```

Run with:
```bash
./llama-server --model models/tinyllama-1.1b-chat-v1.0.Q4_K_M.gguf --ctx-size 4096
```

---

## 📚 Additional Resources

- **LiveKit Docs:** https://docs.livekit.io/
- **llama.cpp:** https://github.com/ggml-org/llama.cpp
- **Faster Whisper:** https://github.com/SYSTRAN/faster-whisper
- **Hugging Face Models:** https://huggingface.co/models

---

## 🆘 Need Help?

1. Check all services are running: `netstat -an | findstr "7880 8000 8880 11434"`
2. Check logs in each terminal window
3. Verify `.env.local` files are configured correctly
4. Ensure all ports are accessible (not blocked by firewall)

---

## ✅ Quick Start Script (Windows)

Create `start-all.ps1`:
```powershell
# Start all services in separate windows

Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$PWD'; ./livekit-server --dev"
Start-Sleep 2

Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$PWD/nemotron-stt'; python server.py"
Start-Sleep 2

Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$PWD'; ./llama-server --model models/qwen2.5-3b-instruct-q4_k_m.gguf --host 0.0.0.0 --port 11434"
Start-Sleep 2

Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$PWD'; python kokoro_server.py"
Start-Sleep 2

Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$PWD/livekit_agent'; uv run python src/agent.py dev"
Start-Sleep 2

Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd '$PWD/frontend'; pnpm dev"

Write-Host "All services starting... Wait 30 seconds then open http://localhost:3000"
```

Run:
```powershell
./start-all.ps1
```

---

**Your Local Voice AI is now running without Docker! 🎉**
