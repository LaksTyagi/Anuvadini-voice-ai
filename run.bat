@echo off
REM Quick start script for Anuvadini Voice AI (Multilingual)

echo.
echo ========================================
echo   Anuvadini Voice AI - Multilingual
echo   Hindi, Punjabi, Tamil, English
echo ========================================
echo.

REM Check if Docker is running
echo Checking Docker...
docker info >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Docker is not running!
    echo Please start Docker Desktop and try again.
    pause
    exit /b 1
)
echo [OK] Docker is running
echo.

REM Start services
echo Starting all services...
echo   - LiveKit (WebRTC server)
echo   - Whisper (Multilingual STT)
echo   - Qwen LLM (AI Brain)
echo   - Kokoro (Text-to-Speech)
echo   - Frontend (Web UI)
echo.
echo This may take 10-15 minutes on first run (downloading models)...
echo.

docker-compose up --build

echo.
echo Services started!
echo.
echo Open your browser: http://localhost:3000
echo.
echo Test languages:
echo   Hindi:   namaste, aap kaise hain?
echo   Punjabi: sat sri akal
echo   Tamil:   vanakkam
echo   English: hello, how are you?
echo.
pause
