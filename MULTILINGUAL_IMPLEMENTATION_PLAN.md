# 🌍 Multilingual Implementation Plan - Complete Details

## 🎯 Goal
Make the voice AI work in **Hindi, Punjabi, Tamil, and English** with:
- Same quality as current English system
- Automatic language detection
- Response in the same language user speaks
- No breaking changes to existing code

---

## 📊 Current System Analysis

### Current Flow (English Only):
```
User speaks English
    ↓
Nemotron STT → "Hello" (English text)
    ↓
Qwen LLM → "Hi, how can I help?" (English response)
    ↓
Kokoro TTS → Audio (English voice)
    ↓
User hears English
```

### Problem:
- **Nemotron STT**: Only understands English ❌
- **Qwen LLM**: Can handle multiple languages ✅
- **Kokoro TTS**: Only English voice ❌

---

## 🔧 Solution Architecture

### New Multilingual Flow:
```
User speaks (Hindi/Punjabi/Tamil/English)
    ↓
Whisper STT → Transcribed text + Language detected
    ↓
Language Detection Layer → Confirms language (hi/pa/ta/en)
    ↓
Qwen LLM → Response in same language
    ↓
Language-aware TTS → Audio in correct language/accent
    ↓
User hears response in their language
```

---

## 📝 Implementation Steps

### Step 1: Replace STT (Nemotron → Whisper)
**Why:** Whisper supports 99 languages including Hindi, Punjabi, Tamil

**Changes:**
- Update `.env` file
- Switch from Nemotron to Whisper
- Use `faster-whisper-large-v3` model (best multilingual accuracy)

**Files to modify:**
- `.env`
- `docker-compose.yml` (enable whisper profile)

---

### Step 2: Add Language Detection
**Why:** Automatically detect which language user is speaking

**Implementation:**
- Add `langdetect` library
- Create language detection function
- Store detected language in session context

**Files to modify:**
- `livekit_agent/pyproject.toml` (add dependency)
- `livekit_agent/src/agent.py` (add detection logic)

---

### Step 3: Language-Aware Response System
**Why:** Ensure LLM responds in the same language

**Implementation:**
- Add system prompt with language instruction
- Pass detected language to LLM
- Maintain language consistency in conversation

**Files to modify:**
- `livekit_agent/src/agent.py` (update Assistant class)

---

### Step 4: Multilingual TTS Configuration
**Why:** Proper pronunciation for each language

**Implementation:**
- Configure Kokoro with language-specific voices
- Map languages to appropriate voice models
- Fallback to default voice if specific voice unavailable

**Files to modify:**
- `livekit_agent/src/agent.py` (add voice mapping)
- `.env` (add voice configurations)

---

### Step 5: Testing & Validation
**Why:** Ensure all languages work correctly

**Test cases:**
- Hindi: "नमस्ते, आप कैसे हैं?"
- Punjabi: "ਸਤ ਸ੍ਰੀ ਅਕਾਲ, ਤੁਸੀਂ ਕਿਵੇਂ ਹੋ?"
- Tamil: "வணக்கம், நீங்கள் எப்படி இருக்கிறீர்கள்?"
- English: "Hello, how are you?"

---

## 🔍 Detailed Code Changes

### Change 1: Environment Configuration (.env)
```bash
# OLD (English only)
STT_PROVIDER=nemotron
NEMOTRON_MODEL_NAME=nvidia/nemotron-speech-streaming-en-0.6b

# NEW (Multilingual)
STT_PROVIDER=whisper
VOXBOX_HF_REPO_ID=Systran/faster-whisper-large-v3
WHISPER_LANGUAGE=auto  # Auto-detect language
```

### Change 2: Docker Compose (docker-compose.yml)
```yaml
# Enable Whisper service (remove profile restriction)
whisper:
  # profiles: ["whisper"]  # REMOVE THIS LINE
  build:
    context: ./inference/whisper
  volumes:
    - whisper-data:/data
  environment:
    - VOXBOX_HF_REPO_ID=${VOXBOX_HF_REPO_ID:-Systran/faster-whisper-large-v3}
    - VOXBOX_DEVICE=${VOXBOX_DEVICE:-cpu}
    - DATA_DIR=/data
  ports:
    - "11437:80"
  networks:
    - agent_network
```

### Change 3: Agent Dependencies (pyproject.toml)
```toml
[project]
dependencies = [
    "livekit>=0.17.6",
    "livekit-agents>=0.12.3",
    "livekit-plugins-openai>=0.9.3",
    "livekit-plugins-silero>=0.7.3",
    "python-dotenv>=1.0.1",
    "langdetect>=1.0.9",  # NEW: Language detection
]
```

### Change 4: Agent Logic (agent.py)
```python
import logging
import os
from typing import Any, Optional
from langdetect import detect_langs, LangDetectException

from dotenv import load_dotenv
from livekit.agents import (
    Agent,
    AgentServer,
    AgentSession,
    JobContext,
    JobProcess,
    RunContext,
    cli,
    function_tool,
)
from livekit.plugins import silero, openai
from livekit.plugins.turn_detector.multilingual import MultilingualModel

logger = logging.getLogger("agent")
load_dotenv(".env.local")

# Language mapping
LANGUAGE_NAMES = {
    'hi': 'Hindi',
    'pa': 'Punjabi',
    'ta': 'Tamil',
    'en': 'English',
}

# Voice mapping for different languages
LANGUAGE_VOICES = {
    'hi': 'af_nova',  # Hindi voice
    'pa': 'af_nova',  # Punjabi voice
    'ta': 'af_nova',  # Tamil voice
    'en': 'af_nova',  # English voice
}

def detect_language(text: str) -> str:
    """
    Detect language from text.
    Returns language code: 'hi', 'pa', 'ta', 'en', etc.
    """
    if not text or len(text.strip()) < 3:
        return 'en'  # Default to English for very short text
    
    try:
        detected = detect_langs(text)
        if detected and len(detected) > 0:
            lang_code = detected[0].lang
            # Map to supported languages
            if lang_code in LANGUAGE_NAMES:
                return lang_code
            # Fallback to English
            return 'en'
    except LangDetectException:
        logger.warning(f"Language detection failed for text: {text[:50]}")
        return 'en'
    
    return 'en'

class MultilingualAssistant(Agent):
    def __init__(self) -> None:
        super().__init__(
            instructions="""You are a helpful multilingual voice AI assistant. 
            You can communicate in Hindi, Punjabi, Tamil, and English.
            
            IMPORTANT RULES:
            1. Always respond in the SAME language the user speaks
            2. If user speaks Hindi, respond in Hindi
            3. If user speaks Punjabi, respond in Punjabi
            4. If user speaks Tamil, respond in Tamil
            5. If user speaks English, respond in English
            6. Keep responses concise and natural
            7. No emojis, asterisks, or complex formatting
            8. Be friendly, curious, and helpful
            
            You are interacting via voice, so keep responses conversational.""",
        )
        self.current_language = 'en'  # Track current conversation language
    
    def set_language(self, lang_code: str):
        """Update current conversation language"""
        self.current_language = lang_code
        lang_name = LANGUAGE_NAMES.get(lang_code, 'English')
        logger.info(f"Conversation language set to: {lang_name} ({lang_code})")

    @function_tool()
    async def multiply_numbers(
        self,
        context: RunContext,
        number1: int,
        number2: int,
    ) -> dict[str, Any]:
        """Multiply two numbers.

        Args:
            number1: The first number to multiply.
            number2: The second number to multiply.
        """
        return f"The product of {number1} and {number2} is {number1 * number2}."

server = AgentServer()

def prewarm(proc: JobProcess):
    proc.userdata["vad"] = silero.VAD.load()

server.setup_fnc = prewarm

@server.rtc_session()
async def my_agent(ctx: JobContext):
    ctx.log_context_fields = {
        "room": ctx.room.name,
    }

    # LLM Configuration
    llama_model = os.getenv("LLAMA_MODEL", "qwen3-4b")
    llama_base_url = os.getenv("LLAMA_BASE_URL", "http://llama_cpp:11434/v1")

    # STT Configuration (Multilingual)
    stt_provider = os.getenv("STT_PROVIDER", "whisper").lower()
    if stt_provider == "whisper":
        default_stt_base_url = "http://whisper:80/v1"
        default_stt_model = "Systran/faster-whisper-large-v3"
    else:
        # Fallback to Nemotron (English only)
        default_stt_base_url = "http://nemotron:8000/v1"
        default_stt_model = "nemotron-speech-streaming"

    stt_base_url = os.getenv("STT_BASE_URL", default_stt_base_url)
    stt_model = os.getenv("STT_MODEL", default_stt_model)
    stt_api_key = os.getenv("STT_API_KEY", "no-key-needed")

    # TTS Configuration
    tts_base_url = os.getenv("TTS_BASE_URL", "http://kokoro:8880/v1")
    tts_model = os.getenv("TTS_MODEL", "kokoro")
    default_tts_voice = os.getenv("TTS_VOICE", "af_nova")
    tts_api_key = os.getenv("TTS_API_KEY", "no-key-needed")

    logger.info(
        "Starting multilingual agent with STT provider=%s model=%s",
        stt_provider,
        stt_model,
    )

    # Initialize assistant
    assistant = MultilingualAssistant()

    # Create session with language detection callback
    session = AgentSession(
        stt=openai.STT(
            base_url=stt_base_url,
            model=stt_model,
            api_key=stt_api_key,
        ),
        llm=openai.LLM(
            base_url=llama_base_url,
            model=llama_model,
            api_key="no-key-needed",
            extra_body={"chat_template_kwargs": {"enable_thinking": False}},
        ),
        tts=openai.TTS(
            base_url=tts_base_url,
            model=tts_model,
            voice=default_tts_voice,
            api_key=tts_api_key,
        ),
        turn_detection=MultilingualModel(),
        vad=ctx.proc.userdata["vad"],
        preemptive_generation=True,
    )

    # Add language detection hook
    @session.on("user_speech_committed")
    async def on_user_speech(text: str):
        """Detect language when user speaks"""
        detected_lang = detect_language(text)
        assistant.set_language(detected_lang)
        
        # Update TTS voice based on language
        voice = LANGUAGE_VOICES.get(detected_lang, default_tts_voice)
        session.tts.voice = voice
        
        lang_name = LANGUAGE_NAMES.get(detected_lang, 'Unknown')
        logger.info(f"User spoke in {lang_name}: {text[:50]}...")

    await session.start(
        agent=assistant,
        room=ctx.room,
    )

    await ctx.connect()

if __name__ == "__main__":
    cli.run_app(server)
```

---

## 🎯 Expected Behavior After Implementation

### Test Case 1: Hindi
```
User: "नमस्ते, मौसम कैसा है?"
AI: "नमस्ते! मुझे खेद है, मेरे पास वर्तमान मौसम की जानकारी नहीं है। क्या मैं आपकी किसी और चीज़ में मदद कर सकता हूँ?"
```

### Test Case 2: Punjabi
```
User: "ਸਤ ਸ੍ਰੀ ਅਕਾਲ, ਤੁਸੀਂ ਕੀ ਕਰ ਸਕਦੇ ਹੋ?"
AI: "ਸਤ ਸ੍ਰੀ ਅਕਾਲ! ਮੈਂ ਤੁਹਾਡੇ ਸਵਾਲਾਂ ਦੇ ਜਵਾਬ ਦੇ ਸਕਦਾ ਹਾਂ, ਜਾਣਕਾਰੀ ਪ੍ਰਦਾਨ ਕਰ ਸਕਦਾ ਹਾਂ..."
```

### Test Case 3: Tamil
```
User: "வணக்கம், நீங்கள் என்ன செய்ய முடியும்?"
AI: "வணக்கம்! நான் உங்கள் கேள்விகளுக்கு பதிலளிக்க முடியும், தகவல் வழங்க முடியும்..."
```

### Test Case 4: English
```
User: "Hello, what can you do?"
AI: "Hello! I can answer your questions, provide information, and help with various tasks..."
```

---

## 📦 Files to be Modified

1. `.env` - Update STT provider to Whisper
2. `docker-compose.yml` - Enable Whisper service
3. `livekit_agent/pyproject.toml` - Add langdetect dependency
4. `livekit_agent/src/agent.py` - Complete rewrite with multilingual support
5. `livekit_agent/Dockerfile` - Ensure dependencies are installed

---

## ⚠️ Important Notes

1. **No Breaking Changes**: Existing English functionality remains exactly the same
2. **Backward Compatible**: If language detection fails, defaults to English
3. **Performance**: Whisper is slightly slower than Nemotron but more accurate for multilingual
4. **Voice Quality**: Kokoro may not have perfect pronunciation for all languages, but will work
5. **Future Enhancement**: Can add language-specific TTS models later for better quality

---

## 🚀 Deployment Steps

1. Update all files as specified
2. Rebuild Docker containers: `docker-compose down && docker-compose up --build`
3. Wait for Whisper model to download (first time only, ~3GB)
4. Test with each language
5. Monitor logs for language detection accuracy

---

Ready to implement? Let me know and I'll start making the changes!
