#!/usr/bin/env pwsh
# Quick start script for Anuvadini Voice AI (Multilingual)

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Anuvadini Voice AI - Multilingual" -ForegroundColor Cyan
Write-Host "  Hindi, Punjabi, Tamil, English" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check if Docker is running
Write-Host "Checking Docker..." -ForegroundColor Yellow
try {
    $null = docker info 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "Docker not running"
    }
    Write-Host "[OK] Docker is running" -ForegroundColor Green
} catch {
    Write-Host "[ERROR] Docker is not running!" -ForegroundColor Red
    Write-Host "Please start Docker Desktop and try again." -ForegroundColor Yellow
    Write-Host ""
    Read-Host "Press Enter to exit"
    exit 1
}
Write-Host ""

# Start services
Write-Host "Starting all services..." -ForegroundColor Yellow
Write-Host "  - LiveKit (WebRTC server)" -ForegroundColor Gray
Write-Host "  - Whisper (Multilingual STT)" -ForegroundColor Gray
Write-Host "  - Qwen LLM (AI Brain)" -ForegroundColor Gray
Write-Host "  - Kokoro (Text-to-Speech)" -ForegroundColor Gray
Write-Host "  - Frontend (Web UI)" -ForegroundColor Gray
Write-Host ""
Write-Host "This may take 10-15 minutes on first run (downloading models)..." -ForegroundColor Yellow
Write-Host ""

# Run docker-compose
docker-compose up --build

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Services Started!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Open your browser: http://localhost:3000" -ForegroundColor White
Write-Host ""
Write-Host "Test languages:" -ForegroundColor Cyan
Write-Host "  Hindi:   namaste, aap kaise hain?" -ForegroundColor White
Write-Host "  Punjabi: sat sri akal" -ForegroundColor White
Write-Host "  Tamil:   vanakkam" -ForegroundColor White
Write-Host "  English: hello, how are you?" -ForegroundColor White
Write-Host ""
Write-Host "Press Ctrl+C to stop" -ForegroundColor Yellow
