# Local Voice AI - Architecture Overview

## 🏗️ System Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                         YOUR BROWSER                             │
│                     http://localhost:3000                        │
│                                                                   │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │              Next.js Frontend (React)                    │   │
│  │  - Voice UI                                              │   │
│  │  - Session Management                                    │   │
│  │  - WebRTC Client                                         │   │
│  └─────────────────────────────────────────────────────────┘   │
└───────────────────────────┬─────────────────────────────────────┘
                            │ WebSocket (ws://localhost:7880)
                            ▼
┌─────────────────────────────────────────────────────────────────┐
│                      DOCKER NETWORK                              │
│                     (agent_network)                              │
│                                                                   │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │                  LiveKit Server                          │   │
│  │  - WebRTC Signaling                                      │   │
│  │  - Room Management                                       │   │
│  │  - Audio Streaming                                       │   │
│  │  Port: 7880 (WebSocket), 7881 (HTTP)                    │   │
│  └─────────────────────────────────────────────────────────┘   │
│                            │                                     │
│                            │ WebSocket                           │
│                            ▼                                     │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │              LiveKit Agent (Python)                      │   │
│  │  - Voice Pipeline Orchestration                          │   │
│  │  - VAD (Voice Activity Detection)                        │   │
│  │  - Turn Detection                                        │   │
│  │  - Function Tools                                        │   │
│  └─────────────────────────────────────────────────────────┘   │
│         │                  │                  │                  │
│         │ HTTP             │ HTTP             │ HTTP             │
│         ▼                  ▼                  ▼                  │
│  ┌──────────┐      ┌──────────┐      ┌──────────┐             │
│  │ Nemotron │      │  Llama   │      │  Kokoro  │             │
│  │   STT    │      │   LLM    │      │   TTS    │             │
│  │          │      │          │      │          │             │
│  │ Speech   │      │ Language │      │  Voice   │             │
│  │   to     │      │  Model   │      │ Synth    │             │
│  │  Text    │      │          │      │          │             │
│  │          │      │          │      │          │             │
│  │ Port:    │      │ Port:    │      │ Port:    │             │
│  │ 11435    │      │ 11436    │      │ 8880     │             │
│  └──────────┘      └──────────┘      └──────────┘             │
│                                                                   │
└─────────────────────────────────────────────────────────────────┘
```

## 🔄 Data Flow

### Voice Input → AI Response

```
1. USER SPEAKS
   │
   ├─→ Browser captures audio via microphone
   │
   ├─→ WebRTC streams audio to LiveKit Server
   │
   └─→ LiveKit Server forwards to Agent

2. SPEECH TO TEXT (STT)
   │
   ├─→ Agent sends audio to Nemotron
   │
   ├─→ Nemotron transcribes: "Hello, how are you?"
   │
   └─→ Returns text to Agent

3. LANGUAGE MODEL (LLM)
   │
   ├─→ Agent sends text to Llama (Qwen 2.5)
   │
   ├─→ LLM generates response: "I'm doing great! How can I help you?"
   │
   └─→ Returns text to Agent

4. TEXT TO SPEECH (TTS)
   │
   ├─→ Agent sends text to Kokoro
   │
   ├─→ Kokoro synthesizes voice audio
   │
   └─→ Returns audio to Agent

5. AUDIO OUTPUT
   │
   ├─→ Agent streams audio to LiveKit Server
   │
   ├─→ LiveKit Server streams to Browser via WebRTC
   │
   └─→ Browser plays audio through speakers
```

## 🧩 Component Details

### Frontend (Next.js)
- **Technology:** React 19, Next.js 15, TypeScript
- **UI Framework:** Tailwind CSS, Radix UI
- **WebRTC:** LiveKit Client SDK
- **Responsibilities:**
  - User interface
  - Session token generation
  - WebRTC connection management
  - Audio visualization

### LiveKit Server
- **Technology:** Go-based WebRTC server
- **Responsibilities:**
  - WebRTC signaling
  - Room management
  - Audio/video routing
  - Participant management

### LiveKit Agent (Python)
- **Technology:** Python 3.13, LiveKit Agents SDK
- **Responsibilities:**
  - Voice pipeline orchestration
  - VAD (Silero)
  - Turn detection (Multilingual)
  - STT/LLM/TTS coordination
  - Function tool execution

### Nemotron STT
- **Technology:** NVIDIA Nemotron Speech (0.6B)
- **Model:** nvidia/nemotron-speech-streaming-en-0.6b
- **Responsibilities:**
  - Real-time speech recognition
  - Audio transcription
  - OpenAI-compatible API

### Llama LLM
- **Technology:** llama.cpp (llama-server)
- **Model:** Qwen 2.5 3B Instruct (Q4_K_M)
- **Responsibilities:**
  - Natural language understanding
  - Response generation
  - Context management (16K tokens)
  - OpenAI-compatible API

### Kokoro TTS
- **Technology:** Kokoro FastAPI
- **Voice:** af_nova (default)
- **Responsibilities:**
  - Text-to-speech synthesis
  - Voice generation
  - OpenAI-compatible API

## 🔌 API Endpoints

### Frontend API
```
GET  /api/connection-details
     → Returns LiveKit connection token
```

### LiveKit Server
```
WebSocket: ws://localhost:7880
HTTP:      http://localhost:7881
```

### LLM API (OpenAI-compatible)
```
POST http://localhost:11436/v1/chat/completions
GET  http://localhost:11436/v1/models
```

### STT API (OpenAI-compatible)
```
POST http://localhost:11435/v1/audio/transcriptions
GET  http://localhost:11435/v1/models
```

### TTS API (OpenAI-compatible)
```
POST http://localhost:8880/v1/audio/speech
GET  http://localhost:8880/v1/models
```

## 🔐 Authentication

### Development Mode (Default)
```
LIVEKIT_API_KEY=devkey
LIVEKIT_API_SECRET=secret
```

### Token Generation
- Frontend generates JWT tokens
- Tokens include room name and participant identity
- Tokens are signed with API secret
- Browser uses token to connect to LiveKit

## 💾 Data Storage

### Docker Volumes
```
llama-models:     LLM model cache (~2GB)
nemotron-cache:   STT model cache (~600MB)
whisper-data:     Optional Whisper models
```

### Model Locations
```
Llama:    /models (in container)
Nemotron: /root/.cache/huggingface (in container)
Kokoro:   Built into image
```

## 🌐 Network Configuration

### Docker Network
```
Name:   agent_network
Type:   bridge
Driver: bridge
```

### Internal URLs (Container-to-Container)
```
LiveKit:  ws://livekit:7880
Nemotron: http://nemotron:8000
Llama:    http://llama_cpp:11434
Kokoro:   http://kokoro:8880
```

### External URLs (Host-to-Container)
```
Frontend: http://localhost:3000
LiveKit:  ws://localhost:7880
Nemotron: http://localhost:11435
Llama:    http://localhost:11436
Kokoro:   http://localhost:8880
```

## 🔄 Service Dependencies

```
frontend
  └─→ depends_on: livekit

livekit_agent
  ├─→ depends_on: livekit
  ├─→ depends_on: kokoro
  ├─→ depends_on: nemotron (healthy)
  └─→ depends_on: llama_cpp (healthy)

(All services connect via agent_network)
```

## 📊 Resource Usage

### Typical Resource Consumption (CPU Mode)

| Service | RAM | CPU | Disk |
|---------|-----|-----|------|
| Frontend | ~100MB | Low | ~500MB |
| LiveKit | ~50MB | Low | ~100MB |
| Agent | ~200MB | Low | ~200MB |
| Nemotron | ~2GB | Medium | ~600MB |
| Llama | ~4GB | High | ~2GB |
| Kokoro | ~1GB | Medium | ~500MB |
| **Total** | **~7.5GB** | **Medium-High** | **~4GB** |

### GPU Mode
- Significantly faster inference
- Lower CPU usage
- Higher VRAM usage (4-8GB)

## 🔧 Configuration Flow

```
.env
  ├─→ docker-compose.yml (environment variables)
  │     ├─→ livekit_agent (LLAMA_MODEL, STT_*, TTS_*)
  │     ├─→ nemotron (NEMOTRON_MODEL_NAME)
  │     ├─→ llama_cpp (LLAMA_HF_REPO)
  │     └─→ frontend (NEXT_PUBLIC_LIVEKIT_URL)
  │
  └─→ livekit_agent/src/agent.py (runtime config)
```

## 🎯 Key Features

### Voice Activity Detection (VAD)
- **Model:** Silero VAD
- **Purpose:** Detect when user starts/stops speaking
- **Benefit:** Natural conversation flow

### Turn Detection
- **Model:** LiveKit Multilingual Turn Detector
- **Purpose:** Determine when to respond
- **Benefit:** Context-aware interruptions

### Preemptive Generation
- **Feature:** Start generating response before user finishes
- **Benefit:** Lower latency, faster responses

### Streaming
- **STT:** Streaming transcription
- **LLM:** Streaming text generation
- **TTS:** Streaming audio synthesis
- **Benefit:** Real-time, low-latency experience

## 🔄 Upgrade Paths

### Swap LLM
```bash
# Edit .env
LLAMA_HF_REPO=Qwen/Qwen2.5-7B-Instruct-GGUF:qwen2.5-7b-instruct-q4_k_m.gguf
LLAMA_MODEL=qwen2.5-7b-instruct
```

### Swap STT
```bash
# Edit .env
STT_PROVIDER=whisper
STT_BASE_URL=http://whisper:80/v1

# Run with whisper profile
docker compose --profile whisper up
```

### Use Cloud Services
```bash
# Edit .env to point to cloud APIs
LLAMA_BASE_URL=https://api.openai.com/v1
STT_BASE_URL=https://api.openai.com/v1
TTS_BASE_URL=https://api.openai.com/v1
```

## 📚 Technology Stack Summary

| Layer | Technology |
|-------|------------|
| **Frontend** | Next.js 15, React 19, TypeScript, Tailwind |
| **WebRTC** | LiveKit Server, LiveKit Client SDK |
| **Agent** | Python 3.13, LiveKit Agents SDK |
| **LLM** | llama.cpp, Qwen 2.5 3B |
| **STT** | NVIDIA Nemotron Speech 0.6B |
| **TTS** | Kokoro |
| **VAD** | Silero |
| **Container** | Docker, Docker Compose |

---

**This architecture provides a complete, local, privacy-focused voice AI system with no cloud dependencies!**
