# Local Voice AI - Quick Start Script for Windows
# This script checks prerequisites and starts the application

Write-Host "==================================" -ForegroundColor Cyan
Write-Host "Local Voice AI - Quick Start" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""

# Check Docker
Write-Host "Checking Docker..." -ForegroundColor Yellow
try {
    $dockerVersion = docker --version 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ Docker installed: $dockerVersion" -ForegroundColor Green
    } else {
        Write-Host "✗ Docker not found" -ForegroundColor Red
        Write-Host "Please install Docker Desktop from https://www.docker.com/products/docker-desktop" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "✗ Docker not found" -ForegroundColor Red
    Write-Host "Please install Docker Desktop from https://www.docker.com/products/docker-desktop" -ForegroundColor Red
    exit 1
}

# Check if Docker daemon is running
Write-Host "Checking Docker daemon..." -ForegroundColor Yellow
try {
    docker ps 2>&1 | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ Docker daemon is running" -ForegroundColor Green
    } else {
        Write-Host "✗ Docker daemon is not running" -ForegroundColor Red
        Write-Host "Please start Docker Desktop and wait for it to fully initialize" -ForegroundColor Yellow
        Write-Host "Then run this script again" -ForegroundColor Yellow
        exit 1
    }
} catch {
    Write-Host "✗ Docker daemon is not running" -ForegroundColor Red
    Write-Host "Please start Docker Desktop and wait for it to fully initialize" -ForegroundColor Yellow
    Write-Host "Then run this script again" -ForegroundColor Yellow
    exit 1
}

# Check Docker Compose
Write-Host "Checking Docker Compose..." -ForegroundColor Yellow
try {
    $composeVersion = docker compose version 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ Docker Compose installed: $composeVersion" -ForegroundColor Green
    } else {
        Write-Host "✗ Docker Compose not found" -ForegroundColor Red
        exit 1
    }
} catch {
    Write-Host "✗ Docker Compose not found" -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "==================================" -ForegroundColor Cyan
Write-Host "All prerequisites met!" -ForegroundColor Green
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""

# Ask user for CPU or GPU mode
Write-Host "Select target:" -ForegroundColor Yellow
Write-Host "  1) CPU (works on all systems)"
Write-Host "  2) GPU (requires NVIDIA GPU with CUDA)"
Write-Host ""
$choice = Read-Host "Enter choice (1/2)"

$composeFiles = @("-f", "docker-compose.yml")
$mode = "CPU"

if ($choice -eq "2") {
    $composeFiles += @("-f", "docker-compose.gpu.yml")
    $mode = "GPU"
    Write-Host ""
    Write-Host "⚠ GPU mode requires NVIDIA GPU with CUDA support" -ForegroundColor Yellow
} elseif ($choice -ne "1") {
    Write-Host "Invalid choice. Defaulting to CPU mode." -ForegroundColor Yellow
    $mode = "CPU"
}

Write-Host ""
Write-Host "==================================" -ForegroundColor Cyan
Write-Host "Starting Local Voice AI - $mode mode" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "⏳ First run will take 10-30 minutes to:" -ForegroundColor Yellow
Write-Host "   - Build Docker images" -ForegroundColor Yellow
Write-Host "   - Download AI models (several GB)" -ForegroundColor Yellow
Write-Host ""
Write-Host "📊 You can monitor progress in the output below" -ForegroundColor Yellow
Write-Host ""
Write-Host "🌐 Once ready, open: http://localhost:3000" -ForegroundColor Green
Write-Host ""
Write-Host "Press Ctrl+C to stop the application" -ForegroundColor Yellow
Write-Host ""
Write-Host "Starting in 3 seconds..." -ForegroundColor Cyan
Start-Sleep -Seconds 3

# Start Docker Compose
$cmd = @("compose") + $composeFiles + @("up", "--build")
& docker @cmd
