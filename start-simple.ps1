# Simple start script for Local Voice AI

Write-Host "Starting Local Voice AI..." -ForegroundColor Cyan
Write-Host ""
Write-Host "Select mode:" -ForegroundColor Yellow
Write-Host "  1) CPU"
Write-Host "  2) GPU"
$choice = Read-Host "Enter choice (1 or 2)"

if ($choice -eq "2") {
    Write-Host "Starting with GPU support..." -ForegroundColor Green
    docker compose -f docker-compose.yml -f docker-compose.gpu.yml up --build
} else {
    Write-Host "Starting with CPU mode..." -ForegroundColor Green
    docker compose -f docker-compose.yml up --build
}
