# Restart Docker Desktop

Write-Host "Restarting Docker Desktop..." -ForegroundColor Cyan
Write-Host ""

# Stop Docker Desktop
Write-Host "Stopping Docker Desktop..." -ForegroundColor Yellow
Stop-Process -Name "Docker Desktop" -Force -ErrorAction SilentlyContinue
Start-Sleep -Seconds 5

# Start Docker Desktop
Write-Host "Starting Docker Desktop..." -ForegroundColor Yellow
Start-Process "C:\Program Files\Docker\Docker\Docker Desktop.exe"

Write-Host ""
Write-Host "Waiting for Docker to start (30 seconds)..." -ForegroundColor Yellow
Start-Sleep -Seconds 30

# Check if Docker is ready
Write-Host ""
Write-Host "Checking Docker status..." -ForegroundColor Yellow
$maxAttempts = 12
$attempt = 0
$dockerReady = $false

while ($attempt -lt $maxAttempts -and -not $dockerReady) {
    try {
        docker ps 2>&1 | Out-Null
        if ($LASTEXITCODE -eq 0) {
            $dockerReady = $true
            Write-Host "✓ Docker is ready!" -ForegroundColor Green
        } else {
            $attempt++
            Write-Host "Waiting... (attempt $attempt/$maxAttempts)" -ForegroundColor Gray
            Start-Sleep -Seconds 5
        }
    } catch {
        $attempt++
        Write-Host "Waiting... (attempt $attempt/$maxAttempts)" -ForegroundColor Gray
        Start-Sleep -Seconds 5
    }
}

if ($dockerReady) {
    Write-Host ""
    Write-Host "Docker Desktop is ready!" -ForegroundColor Green
    Write-Host "You can now run: ./start-simple.ps1" -ForegroundColor Cyan
} else {
    Write-Host ""
    Write-Host "Docker Desktop is taking longer than expected to start." -ForegroundColor Yellow
    Write-Host "Please wait a bit more and check the Docker Desktop icon in the system tray." -ForegroundColor Yellow
}
