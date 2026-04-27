<div align="center">
  <img src="./frontend/.github/assets/template-light.webp" alt="App Icon" width="80" />
  <h1>Anuvadini Voice AI - Multilingual Edition</h1>
  <p>🌍 Powerful, private, local voice AI supporting <strong>Hindi, Punjabi, Tamil, and English</strong></p>
  <p>A full-stack, Dockerized AI voice assistant with multilingual speech recognition, text processing, and voice synthesis delivered via WebRTC powered by <a href="https://docs.livekit.io/agents?utm_source=local-voice-ai">LiveKit Agents</a>.</p>
</div>

## 🎯 Features

- ✅ **Multilingual Support**: Hindi (हिंदी), Punjabi (ਪੰਜਾਬੀ), Tamil (தமிழ்), English
- ✅ **Automatic Language Detection**: Speaks your language automatically
- ✅ **Real-time Voice Conversation**: Low-latency WebRTC audio
- ✅ **100% Local & Private**: No cloud APIs, all processing on your machine
- ✅ **Easy Setup**: One command to run everything

## 🚀 Quick Start

### One Command to Run:

**Windows (PowerShell):**
```powershell
.\run.ps1
```

**Windows (Batch):**
```batch
run.bat
```

**Linux/Mac:**
```bash
./run.sh
```

### Or use Docker Compose directly:
```bash
docker-compose up --build
```

Then open: **http://localhost:3000**

---

## 🌍 Test Each Language

### Hindi (हिंदी):
```
"नमस्ते, आप कैसे हैं?"
"मौसम कैसा है?"
```

### Punjabi (ਪੰਜਾਬੀ):
```
"ਸਤ ਸ੍ਰੀ ਅਕਾਲ"
"ਤੁਸੀਂ ਕਿਵੇਂ ਹੋ?"
```

### Tamil (தமிழ்):
```
"வணக்கம்"
"நீங்கள் எப்படி இருக்கிறீர்கள்?"
```

### English:
```
"Hello, how are you?"
"What can you do?"
```

---

## Overview

This repo contains everything needed to run a real-time multilingual AI voice assistant locally using:

- **LiveKit** for WebRTC realtime audio + rooms.
- **LiveKit Agents (Python)** to orchestrate the STT → LLM → TTS pipeline.
- **Whisper Large V3 (default)** for multilingual speech-to-text (99 languages).
- **Nemotron Speech (optional)** for faster English-only STT.
- **llama.cpp (llama-server)** running Qwen 2.5 3B (multilingual LLM).
- **Kokoro** for text-to-speech voice synthesis.
- **Next.js + Tailwind** frontend UI.
- **Language Detection** via langdetect for automatic language switching.
- Fully containerized via Docker Compose.

## Getting Started

### Method 1: Quick Start Scripts (Recommended)

Windows:
```powershell
.\run.ps1
```

Mac / Linux:
```bash
chmod +x run.sh
./run.sh
```

### Method 2: Original Scripts

Windows:
```bash
./compose-up.ps1
```

Mac / Linux:
```bash
chmod +x compose-up.sh
./compose-up.sh
```

Once it's up, visit [http://localhost:3000](http://localhost:3000) in your browser to start chatting.

### Notes on models and resources

- **Multilingual STT**: Whisper Large V3 (~3GB) auto-downloads on first boot
- **LLM**: Qwen 2.5 3B (~2GB) runs via `llama-server` and auto-downloads from Hugging Face
- **TTS**: Kokoro (~500MB) for voice synthesis
- The default repo is `unsloth/Qwen3-4B-Instruct-2507-GGUF` (change `LLAMA_HF_REPO` to use a different model)
- STT defaults to Whisper for multilingual support (`STT_PROVIDER=whisper`)
- Switch to Nemotron for faster English-only: `STT_PROVIDER=nemotron`
- You can swap out the LLM/STT/TTS URLs to use cloud models if you want (see `livekit_agent/src/agent.py`)
- The first run downloads a lot of data (often 5-10 GB) for models and supporting libraries
- Installing takes a while. On an i9-14900hx it takes about 10-15 minutes to get everything ready
- Ongoing VRAM/RAM usage depends heavily on the model, context size, and GPU offload settings

### Startup readiness

`llama_cpp` returns 503s while the model is downloading/loading/warming up. Nemotron also needs startup time on first boot to download weights. The Compose stack includes healthchecks, and `livekit_agent` waits for both `llama_cpp` and `nemotron` to be healthy before starting.

## Architecture

Each service is containerized and communicates over a shared Docker network:

- `livekit`: WebRTC signaling server
- `livekit_agent`: Python agent (LiveKit Agents SDK)
- `nemotron`: Speech-to-text (NVIDIA Nemotron Speech, OpenAI-compatible API)
- `whisper` (optional profile): Fallback STT backend (VoxBox + Whisper)
- `llama_cpp`: Local LLM provider (`llama-server`)
- `kokoro`: TTS engine
- `frontend`: Next.js client UI

## Agent

The agent entrypoint is `livekit_agent/src/agent.py`. It uses the LiveKit Agents OpenAI-compatible plugins to talk to local inference services:

- `openai.STT` → Nemotron by default (configurable via `STT_PROVIDER` / `STT_BASE_URL` / `STT_MODEL`)
- Optional `whisper` profile can be selected as a fallback STT backend.
- `openai.LLM` → `llama_cpp` (`llama-server`)
- `openai.TTS` → the Kokoro container
- `silero.VAD` for voice activity detection

## Environment variables

Example env files:

- `.env` (used by Docker Compose)
- `frontend/.env.example`
- `livekit_agent/.env.example`

For local (non-Docker) development, use `.env.local` files:

- `frontend/.env.local`
- `livekit_agent/.env.local`

### LiveKit URLs (important)

The LiveKit URL is used in two different contexts:

- `LIVEKIT_URL` is the internal, server-to-server address (e.g. `ws://livekit:7880`) used by containers like the agent.
- `NEXT_PUBLIC_LIVEKIT_URL` is the browser-reachable LiveKit address returned by the frontend API (e.g. `ws://localhost:7880`).

The frontend only signs tokens; it does not connect to LiveKit directly. The browser connects using the `serverUrl` returned by `/api/connection-details`, so make sure `NEXT_PUBLIC_LIVEKIT_URL` points to a reachable LiveKit endpoint.

### LLM (llama.cpp) settings

The Compose stack runs `llama-server` with `--hf-repo` so models are fetched automatically and cached on disk:

- `LLAMA_HF_REPO`: Hugging Face repo, optionally with `:quant` (e.g. `unsloth/Qwen3-4B-Instruct-2507-GGUF:q4_k_m`)
- `LLAMA_MODEL_ALIAS`: Name exposed via the API (and returned from `/v1/models`)
- `LLAMA_MODEL`: What the agent requests (should match `LLAMA_MODEL_ALIAS`)
- `LLAMA_BASE_URL`: LLM base URL for the agent (default `http://llama_cpp:11434/v1`)
- `LLAMA_HOST_PORT`: Host port mapping for llama-server (default `11436`)

Models are cached in a Docker volume (`llama-models`, mounted as `/models` in the container).

### STT settings (Nemotron default)

- `STT_PROVIDER`: `nemotron` (default) or `whisper`
- `STT_BASE_URL`: OpenAI-compatible STT base URL used by the agent
- `STT_MODEL`: STT model id (default `nemotron-speech-streaming`)
- `STT_API_KEY`: Optional API key for OpenAI-compatible STT servers
- `NEMOTRON_MODEL_NAME`: Hugging Face model id loaded by the Nemotron container
- `NEMOTRON_MODEL_ID`: Model id returned from `/v1/models`

Whisper fallback is available as a profile-only service:

```bash
docker compose --profile whisper up
```

When using Whisper fallback, set:

- `STT_PROVIDER=whisper`
- `STT_BASE_URL=http://whisper:80/v1`
- `STT_MODEL=Systran/faster-whisper-small` (or your preferred VoxBox model)

### TTS settings (Kokoro default)

- `TTS_BASE_URL`: OpenAI-compatible TTS base URL used by the agent (default `http://kokoro:8880/v1`)
- `TTS_MODEL`: TTS model id (default `kokoro`)
- `TTS_VOICE`: TTS voice name (default `af_nova`)
- `TTS_API_KEY`: Optional API key for OpenAI-compatible TTS servers

## TUI (Terminal Client)

An alternative terminal-based client built with Rust and [ratatui](https://ratatui.rs). Supports text chat and voice chat with an audio visualizer.

### Build & run

```bash
cd tui
cargo build --release
```

With the Docker stack running:

```bash
# Uses default devkey/secret to connect to local LiveKit
cargo run -- --url ws://localhost:7880

# Or fetch a token from the frontend
cargo run -- --frontend-url http://localhost:3000
```

### Controls

- **Ctrl+T** — Toggle between text and voice mode
- **Ctrl+M** — Toggle mic mute (voice mode)
- **Enter** — Send message (text mode)
- **Esc / Ctrl+C** — Quit

### Requirements

- Rust toolchain (`rustup`)
- System audio I/O (microphone + speakers) for voice mode

## Development

Use `.env.local` files in both `frontend` and `livekit_agent` dirs to set the dev environment variables for the project. This way, you can run either of those with `pnpm dev` or `uv run python src/agent.py dev` and test them without needing to build the Docker projects.

## Rebuild / redeploy

```bash
docker compose down -v --remove-orphans
docker compose up --build
```

## Project structure

```
.
├─ frontend/        # Next.js UI client
├─ tui/             # Terminal UI client (Rust/ratatui)
├─ inference/       # Local inference services (llama/nemotron/whisper/kokoro)
├─ livekit_agent/   # Python voice agent (LiveKit Agents)
├─ docker-compose.yml
└─ docker-compose.gpu.yml
```

## Requirements

- Docker + Docker Compose
- No GPU required (CPU works)
- Recommended RAM: 12GB+

## Credits

- Built with LiveKit: https://livekit.io/
- Uses LiveKit Agents: https://docs.livekit.io/agents/
- STT via NVIDIA Nemotron Speech: https://huggingface.co/nvidia/nemotron-speech-streaming-en-0.6b
- Whisper fallback via VoxBox: https://pypi.org/project/vox-box/
- Local LLM via llama.cpp: https://github.com/ggml-org/llama.cpp
- TTS via Kokoro: https://github.com/remsky/kokoro
