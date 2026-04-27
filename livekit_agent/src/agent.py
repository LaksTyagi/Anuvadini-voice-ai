import logging
import os
from typing import Any

from dotenv import load_dotenv
from livekit.agents import (
    Agent,
    AgentServer,
    AgentSession,
    JobContext,
    JobProcess,
    cli,
    function_tool,
    RunContext,
)
from livekit.plugins import silero, openai
from livekit.plugins.turn_detector.multilingual import MultilingualModel

# Language detection
try:
    from langdetect import detect_langs, LangDetectException
    LANGDETECT_AVAILABLE = True
except ImportError:
    LANGDETECT_AVAILABLE = False
    logger = logging.getLogger("agent")
    logger.warning("langdetect not available, language detection disabled")

logger = logging.getLogger("agent")

load_dotenv(".env.local")

# Supported languages
LANGUAGE_NAMES = {
    'hi': 'Hindi',
    'pa': 'Punjabi',
    'ta': 'Tamil',
    'en': 'English',
}

# Voice mapping for different languages
# Note: Kokoro may not have perfect pronunciation for all languages
# but will attempt to speak them
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
    Falls back to 'en' if detection fails.
    """
    if not LANGDETECT_AVAILABLE:
        return 'en'
    
    if not text or len(text.strip()) < 3:
        return 'en'  # Default to English for very short text
    
    try:
        detected = detect_langs(text)
        if detected and len(detected) > 0:
            lang_code = detected[0].lang
            # Map to supported languages
            if lang_code in LANGUAGE_NAMES:
                logger.info(f"Detected language: {LANGUAGE_NAMES[lang_code]} ({lang_code})")
                return lang_code
            # Fallback to English for unsupported languages
            logger.info(f"Unsupported language detected: {lang_code}, falling back to English")
            return 'en'
    except (LangDetectException, Exception) as e:
        logger.warning(f"Language detection failed: {e}, falling back to English")
        return 'en'
    
    return 'en'


class MultilingualAssistant(Agent):
    """
    Multilingual voice AI assistant supporting Hindi, Punjabi, Tamil, and English.
    Automatically detects user's language and responds in the same language.
    """
    
    def __init__(self) -> None:
        super().__init__(
            instructions="""You are a helpful multilingual voice AI assistant. 
You can communicate fluently in Hindi (हिंदी), Punjabi (ਪੰਜਾਬੀ), Tamil (தமிழ்), and English.

CRITICAL LANGUAGE RULES:
1. ALWAYS respond in the SAME language the user speaks
2. If user speaks Hindi, respond ONLY in Hindi (हिंदी में जवाब दें)
3. If user speaks Punjabi, respond ONLY in Punjabi (ਪੰਜਾਬੀ ਵਿੱਚ ਜਵਾਬ ਦਿਓ)
4. If user speaks Tamil, respond ONLY in Tamil (தமிழில் பதிலளிக்கவும்)
5. If user speaks English, respond ONLY in English
6. NEVER mix languages in a single response
7. Maintain the same language throughout the conversation unless user switches

RESPONSE STYLE:
- Keep responses concise and natural (2-3 sentences max)
- No emojis, asterisks, or complex formatting
- No markdown or special characters
- Be friendly, curious, and helpful
- You are interacting via voice, so speak naturally

EXAMPLES:
User (Hindi): "नमस्ते, आप कैसे हैं?"
You (Hindi): "नमस्ते! मैं बिल्कुल ठीक हूँ, धन्यवाद। मैं आपकी कैसे मदद कर सकता हूँ?"

User (Punjabi): "ਸਤ ਸ੍ਰੀ ਅਕਾਲ, ਤੁਸੀਂ ਕੀ ਕਰ ਸਕਦੇ ਹੋ?"
You (Punjabi): "ਸਤ ਸ੍ਰੀ ਅਕਾਲ! ਮੈਂ ਤੁਹਾਡੇ ਸਵਾਲਾਂ ਦੇ ਜਵਾਬ ਦੇ ਸਕਦਾ ਹਾਂ ਅਤੇ ਜਾਣਕਾਰੀ ਪ੍ਰਦਾਨ ਕਰ ਸਕਦਾ ਹਾਂ।"

User (Tamil): "வணக்கம், நீங்கள் என்ன செய்ய முடியும்?"
You (Tamil): "வணக்கம்! நான் உங்கள் கேள்விகளுக்கு பதிலளிக்க முடியும் மற்றும் தகவல் வழங்க முடியும்।"

User (English): "Hello, what can you do?"
You (English): "Hello! I can answer your questions, provide information, and help with various tasks. What would you like to know?"
""",
        )
        self.current_language = 'en'  # Track current conversation language
    
    def set_language(self, lang_code: str):
        """Update current conversation language"""
        if lang_code in LANGUAGE_NAMES:
            self.current_language = lang_code
            lang_name = LANGUAGE_NAMES[lang_code]
            logger.info(f"Conversation language set to: {lang_name} ({lang_code})")
        else:
            logger.warning(f"Unknown language code: {lang_code}, keeping current: {self.current_language}")

    @function_tool()
    async def multiply_numbers(
        self,
        context: RunContext,
        number1: int,
        number2: int,
    ) -> str:
        """Multiply two numbers.

        Args:
            number1: The first number to multiply.
            number2: The second number to multiply.
        """
        result = number1 * number2
        
        # Respond in current language
        if self.current_language == 'hi':
            return f"{number1} और {number2} का गुणनफल {result} है।"
        elif self.current_language == 'pa':
            return f"{number1} ਅਤੇ {number2} ਦਾ ਗੁਣਾ {result} ਹੈ।"
        elif self.current_language == 'ta':
            return f"{number1} மற்றும் {number2} இன் பெருக்கல் {result} ஆகும்."
        else:  # English
            return f"The product of {number1} and {number2} is {result}."


server = AgentServer()


def prewarm(proc: JobProcess):
    """Prewarm function to load VAD model before agent starts"""
    proc.userdata["vad"] = silero.VAD.load()


server.setup_fnc = prewarm


@server.rtc_session()
async def my_agent(ctx: JobContext):
    """Main agent session handler with multilingual support"""
    
    ctx.log_context_fields = {
        "room": ctx.room.name,
    }

    # LLM Configuration (Qwen supports multiple languages)
    llama_model = os.getenv("LLAMA_MODEL", "qwen3-4b")
    llama_base_url = os.getenv("LLAMA_BASE_URL", "http://llama_cpp:11434/v1")

    # STT Configuration (Multilingual with Whisper)
    stt_provider = os.getenv("STT_PROVIDER", "whisper").lower()
    if stt_provider == "whisper":
        default_stt_base_url = "http://whisper:80/v1"
        default_stt_model = "Systran/faster-whisper-large-v3"
        logger.info("Using Whisper for multilingual STT (Hindi, Punjabi, Tamil, English)")
    else:
        # Fallback to Nemotron (English only)
        default_stt_base_url = "http://nemotron:8000/v1"
        default_stt_model = "nemotron-speech-streaming"
        logger.warning("Using Nemotron - English only! Switch to Whisper for multilingual support")

    stt_base_url = os.getenv("STT_BASE_URL", default_stt_base_url)
    stt_model = os.getenv("STT_MODEL", default_stt_model)
    stt_api_key = os.getenv("STT_API_KEY", "no-key-needed")

    # TTS Configuration
    tts_base_url = os.getenv("TTS_BASE_URL", "http://kokoro:8880/v1")
    tts_model = os.getenv("TTS_MODEL", "kokoro")
    default_tts_voice = os.getenv("TTS_VOICE", "af_nova")
    tts_api_key = os.getenv("TTS_API_KEY", "no-key-needed")

    logger.info(
        "Starting multilingual agent: STT=%s, LLM=%s, TTS=%s",
        stt_provider,
        llama_model,
        tts_model,
    )

    # Initialize multilingual assistant
    assistant = MultilingualAssistant()

    # Create agent session
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
        turn_detection=MultilingualModel(),  # Already supports multiple languages
        vad=ctx.proc.userdata["vad"],
        preemptive_generation=True,
    )

    # Language detection callback
    # Note: This is a conceptual implementation
    # LiveKit Agents may handle this differently in practice
    original_on_user_speech = None
    if hasattr(session, '_on_user_speech_committed'):
        original_on_user_speech = session._on_user_speech_committed
    
    async def on_user_speech_with_detection(text: str):
        """Detect language when user speaks and update TTS voice"""
        if text and len(text.strip()) > 0:
            detected_lang = detect_language(text)
            assistant.set_language(detected_lang)
            
            # Update TTS voice based on detected language
            voice = LANGUAGE_VOICES.get(detected_lang, default_tts_voice)
            if hasattr(session, 'tts') and hasattr(session.tts, 'voice'):
                session.tts.voice = voice
            
            lang_name = LANGUAGE_NAMES.get(detected_lang, 'Unknown')
            logger.info(f"User spoke in {lang_name}: '{text[:50]}{'...' if len(text) > 50 else ''}'")
        
        # Call original handler if it exists
        if original_on_user_speech:
            await original_on_user_speech(text)
    
    # Attach language detection callback
    if hasattr(session, '_on_user_speech_committed'):
        session._on_user_speech_committed = on_user_speech_with_detection

    # Start the session
    await session.start(
        agent=assistant,
        room=ctx.room,
    )

    await ctx.connect()

    logger.info("Multilingual agent session started successfully")


if __name__ == "__main__":
    cli.run_app(server)
