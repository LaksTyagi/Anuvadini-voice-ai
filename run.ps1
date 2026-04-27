#!/usr/bin/env pwsh
# Quick start script for Anuvadini Voice AI (Multilingual)

Write-Host "🚀 Starting Anuvadini Voice AI - Multilingual Edition" -ForegroundColor Cyan
Write-Host "   Supports: Hindi, Punjabi, Tamil, English" -ForegroundColor Green
Write-Host ""

# Check if Docker is running
Write-Host "Checking Docker..." -ForegroundColor Yellow
$dockerRunning = docker info 2>&1 | Out-Null
if ($LASTEXITCODE -ne 0) {
    Write-Host "❌ Docker is not running!" -ForegroundColor Red
    Write-Host "   Please start Docker Desktop and try again." -ForegroundColor Yellow
    exit 1
}
Write-Host "✅ Docker is running" -ForegroundColor Green
Write-Host ""

# Start services
Write-Host "Starting all services..." -ForegroundColor Yellow
Write-Host "   - LiveKit (WebRTC server)" -ForegroundColor Gray
Write-Host "   - Whisper (Multilingual STT)" -ForegroundColor Gray
Write-Host "   - Qwen LLM (AI Brain)" -ForegroundColor Gray
Write-Host "   - Kokoro (Text-to-Speech)" -ForegroundColor Gray
Write-Host "   - Frontend (Web UI)" -ForegroundColor Gray
Write-Host ""

docker-compose up --build

Write-Host ""
Write-Host "🎉 Services started!" -ForegroundColor Green
Write-Host ""
Write-Host "📱 Open your browser:" -ForegroundColor Cyan
Write-Host "   http://localhost:3000" -ForegroundColor White
Write-Host ""
Write-Host "🌍 Test languages:" -ForegroundColor Cyan
Write-Host "   Hindi:   नमस्ते, आप कैसे हैं?" -ForegroundColor White
Write-Host "   Punjabi: ਸਤ ਸ੍ਰੀ ਅਕਾਲ" -ForegroundColor White
Write-Host "   Tamil:   வணக்கம்" -ForegroundColor White
Write-Host "   English: Hello, how are you?" -ForegroundColor White
Write-Host ""
Write-Host "Press Ctrl+C to stop" -ForegroundColor Yellow
