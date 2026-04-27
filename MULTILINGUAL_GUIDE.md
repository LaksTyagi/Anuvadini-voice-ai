# 🌍 Multilingual Voice AI - User Guide

## Supported Languages

✅ **Hindi (हिंदी)**  
✅ **Punjabi (ਪੰਜਾਬੀ)**  
✅ **Tamil (தமிழ்)**  
✅ **English**

---

## How It Works

The AI automatically detects which language you're speaking and responds in the same language!

```
You speak Hindi → AI responds in Hindi
You speak Punjabi → AI responds in Punjabi
You speak Tamil → AI responds in Tamil
You speak English → AI responds in English
```

---

## Setup & Installation

### 1. Start the System

```bash
# Windows
.\start-simple.ps1

# Linux/Mac
./start.sh
```

### 2. Wait for Services to Start

The system will download models on first run (this may take 10-15 minutes):
- Whisper multilingual model (~3GB)
- Qwen language model (~2GB)
- Kokoro voice model (~500MB)

### 3. Open the Web Interface

```
http://localhost:3000
```

---

## Testing Each Language

### Test Hindi (हिंदी)
```
You: "नमस्ते, आप कैसे हैं?"
AI: "नमस्ते! मैं बिल्कुल ठीक हूँ, धन्यवाद। मैं आपकी कैसे मदद कर सकता हूँ?"

You: "मौसम कैसा है?"
AI: "मुझे खेद है, मेरे पास वर्तमान मौसम की जानकारी नहीं है। क्या मैं आपकी किसी और चीज़ में मदद कर सकता हूँ?"

You: "दो गुणा तीन क्या होता है?"
AI: "दो और तीन का गुणनफल छह है।"
```

### Test Punjabi (ਪੰਜਾਬੀ)
```
You: "ਸਤ ਸ੍ਰੀ ਅਕਾਲ, ਤੁਸੀਂ ਕਿਵੇਂ ਹੋ?"
AI: "ਸਤ ਸ੍ਰੀ ਅਕਾਲ! ਮੈਂ ਬਿਲਕੁਲ ਠੀਕ ਹਾਂ, ਧੰਨਵਾਦ। ਮੈਂ ਤੁਹਾਡੀ ਕਿਵੇਂ ਮਦਦ ਕਰ ਸਕਦਾ ਹਾਂ?"

You: "ਤੁਸੀਂ ਕੀ ਕਰ ਸਕਦੇ ਹੋ?"
AI: "ਮੈਂ ਤੁਹਾਡੇ ਸਵਾਲਾਂ ਦੇ ਜਵਾਬ ਦੇ ਸਕਦਾ ਹਾਂ, ਜਾਣਕਾਰੀ ਪ੍ਰਦਾਨ ਕਰ ਸਕਦਾ ਹਾਂ ਅਤੇ ਵੱਖ-ਵੱਖ ਕੰਮਾਂ ਵਿੱਚ ਮਦਦ ਕਰ ਸਕਦਾ ਹਾਂ।"
```

### Test Tamil (தமிழ்)
```
You: "வணக்கம், நீங்கள் எப்படி இருக்கிறீர்கள்?"
AI: "வணக்கம்! நான் நன்றாக இருக்கிறேன், நன்றி। நான் உங்களுக்கு எப்படி உதவ முடியும்?"

You: "நீங்கள் என்ன செய்ய முடியும்?"
AI: "நான் உங்கள் கேள்விகளுக்கு பதிலளிக்க முடியும், தகவல் வழங்க முடியும் மற்றும் பல்வேறு பணிகளில் உதவ முடியும்."
```

### Test English
```
You: "Hello, how are you?"
AI: "Hello! I'm doing great, thank you. How can I help you today?"

You: "What can you do?"
AI: "I can answer your questions, provide information, and help with various tasks. What would you like to know?"
```

---

## Language Switching

You can switch languages mid-conversation:

```
You (English): "Hello"
AI (English): "Hello! How can I help you?"

You (Hindi): "मुझे हिंदी में बात करनी है"
AI (Hindi): "बिल्कुल! मैं हिंदी में आपकी मदद कर सकता हूँ। आप क्या जानना चाहते हैं?"

You (Punjabi): "ਪੰਜਾਬੀ ਵਿੱਚ ਗੱਲ ਕਰੋ"
AI (Punjabi): "ਜ਼ਰੂਰ! ਮੈਂ ਪੰਜਾਬੀ ਵਿੱਚ ਤੁਹਾਡੀ ਮਦਦ ਕਰ ਸਕਦਾ ਹਾਂ।"
```

---

## Technical Details

### Architecture

```
User Speech (Any Language)
    ↓
Whisper STT (Multilingual)
    ├─ Transcribes speech to text
    └─ Supports 99 languages
    ↓
Language Detection (langdetect)
    ├─ Detects: Hindi, Punjabi, Tamil, English
    └─ Falls back to English if unsure
    ↓
Qwen LLM (Multilingual)
    ├─ Understands all 4 languages
    └─ Responds in same language
    ↓
Kokoro TTS (Text-to-Speech)
    ├─ Converts text to speech
    └─ Attempts proper pronunciation
    ↓
User Hears Response (Same Language)
```

### Models Used

| Component | Model | Languages |
|-----------|-------|-----------|
| **STT** | Whisper Large V3 | 99 languages |
| **LLM** | Qwen 2.5 3B | Multilingual |
| **TTS** | Kokoro | English (attempts others) |
| **VAD** | Silero | Language-agnostic |

---

## Configuration

### Environment Variables (.env)

```bash
# Speech-to-Text (Multilingual)
STT_PROVIDER=whisper
STT_MODEL=Systran/faster-whisper-large-v3
WHISPER_LANGUAGE=auto

# Language Model (Multilingual)
LLAMA_MODEL=qwen3-4b
LLAMA_BASE_URL=http://llama_cpp:11434/v1

# Text-to-Speech
TTS_MODEL=kokoro
TTS_VOICE=af_nova
```

### Switching Back to English-Only (Nemotron)

If you want faster performance and only need English:

```bash
# In .env file
STT_PROVIDER=nemotron
STT_BASE_URL=http://nemotron:8000/v1
STT_MODEL=nemotron-speech-streaming
```

Then rebuild:
```bash
docker-compose down
docker-compose up --build
```

---

## Troubleshooting

### Issue: AI responds in wrong language

**Solution:** Speak more clearly or use longer sentences. Short phrases like "hi" or "ok" may be detected as English.

### Issue: Poor pronunciation in Hindi/Punjabi/Tamil

**Solution:** This is expected. Kokoro TTS is optimized for English. For better quality:
1. Use language-specific TTS models (future enhancement)
2. Or accept current pronunciation as "English accent"

### Issue: Whisper model download is slow

**Solution:** First-time download is ~3GB. Be patient. Subsequent starts will be fast.

### Issue: Language detection is incorrect

**Solution:** 
- Speak in complete sentences (not single words)
- Avoid mixing languages in one sentence
- Check logs: `docker-compose logs livekit_agent`

---

## Performance

| Language | STT Accuracy | LLM Quality | TTS Quality |
|----------|--------------|-------------|-------------|
| **English** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| **Hindi** | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐ |
| **Punjabi** | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐ |
| **Tamil** | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐ |

---

## Logs & Debugging

### View Agent Logs
```bash
docker-compose logs -f livekit_agent
```

### Check Language Detection
Look for lines like:
```
INFO: Detected language: Hindi (hi)
INFO: User spoke in Hindi: 'नमस्ते, आप कैसे हैं?'
INFO: Conversation language set to: Hindi (hi)
```

### Check STT Service
```bash
# Whisper
curl http://localhost:11437/health

# Nemotron (if using)
curl http://localhost:11435/health
```

---

## Future Enhancements

1. **Better TTS for Indian Languages**
   - Add language-specific TTS models
   - Better pronunciation for Hindi/Punjabi/Tamil

2. **More Languages**
   - Bengali, Marathi, Telugu, etc.
   - Easy to add with current architecture

3. **Language Preference**
   - User can set preferred language
   - Persist across sessions

4. **Mixed Language Support**
   - Handle code-switching (Hinglish, etc.)
   - Detect dominant language

---

## Credits

- **STT**: OpenAI Whisper (via faster-whisper)
- **LLM**: Qwen 2.5 by Alibaba Cloud
- **TTS**: Kokoro
- **Framework**: LiveKit Agents
- **Language Detection**: langdetect

---

## Support

For issues or questions:
1. Check logs: `docker-compose logs livekit_agent`
2. Verify services: `docker-compose ps`
3. Restart: `docker-compose restart livekit_agent`

---

**Enjoy your multilingual voice AI! 🎉**

बहुभाषी आवाज़ AI का आनंद लें! 🎉  
ਬਹੁ-ਭਾਸ਼ਾਈ ਆਵਾਜ਼ AI ਦਾ ਅਨੰਦ ਲਓ! 🎉  
பன்மொழி குரல் AI ஐ அனுபவிக்கவும்! 🎉
