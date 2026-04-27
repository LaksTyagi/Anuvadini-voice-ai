#!/bin/bash
# Quick start script for Anuvadini Voice AI (Multilingual)

echo "🚀 Starting Anuvadini Voice AI - Multilingual Edition"
echo "   Supports: Hindi, Punjabi, Tamil, English"
echo ""

# Check if Docker is running
echo "Checking Docker..."
if ! docker info > /dev/null 2>&1; then
    echo "❌ Docker is not running!"
    echo "   Please start Docker and try again."
    exit 1
fi
echo "✅ Docker is running"
echo ""

# Start services
echo "Starting all services..."
echo "   - LiveKit (WebRTC server)"
echo "   - Whisper (Multilingual STT)"
echo "   - Qwen LLM (AI Brain)"
echo "   - Kokoro (Text-to-Speech)"
echo "   - Frontend (Web UI)"
echo ""

docker-compose up --build

echo ""
echo "🎉 Services started!"
echo ""
echo "📱 Open your browser:"
echo "   http://localhost:3000"
echo ""
echo "🌍 Test languages:"
echo "   Hindi:   नमस्ते, आप कैसे हैं?"
echo "   Punjabi: ਸਤ ਸ੍ਰੀ ਅਕਾਲ"
echo "   Tamil:   வணக்கம்"
echo "   English: Hello, how are you?"
echo ""
echo "Press Ctrl+C to stop"
