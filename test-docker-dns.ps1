# Test Docker DNS and connectivity

Write-Host "==================================" -ForegroundColor Cyan
Write-Host "Docker DNS Troubleshooting" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""

# Test 1: Check if Docker is running
Write-Host "Test 1: Checking if Docker is running..." -ForegroundColor Yellow
try {
    docker ps 2>&1 | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ Docker is running" -ForegroundColor Green
    } else {
        Write-Host "✗ Docker is not running" -ForegroundColor Red
        Write-Host "Please start Docker Desktop first" -ForegroundColor Yellow
        exit 1
    }
} catch {
    Write-Host "✗ Docker is not running" -ForegroundColor Red
    exit 1
}

# Test 2: Check Windows DNS resolution
Write-Host ""
Write-Host "Test 2: Checking Windows DNS resolution..." -ForegroundColor Yellow
try {
    $result = Test-NetConnection -ComputerName registry-1.docker.io -Port 443 -WarningAction SilentlyContinue
    if ($result.TcpTestSucceeded) {
        Write-Host "✓ Windows can reach Docker registry" -ForegroundColor Green
    } else {
        Write-Host "✗ Windows cannot reach Docker registry" -ForegroundColor Red
    }
} catch {
    Write-Host "✗ Network test failed" -ForegroundColor Red
}

# Test 3: Test Docker DNS
Write-Host ""
Write-Host "Test 3: Testing Docker DNS resolution..." -ForegroundColor Yellow
try {
    $output = docker run --rm alpine ping -c 1 google.com 2>&1
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ Docker can resolve DNS" -ForegroundColor Green
    } else {
        Write-Host "✗ Docker cannot resolve DNS" -ForegroundColor Red
        Write-Host "This is the problem!" -ForegroundColor Yellow
    }
} catch {
    Write-Host "✗ Docker DNS test failed" -ForegroundColor Red
}

# Test 4: Try pulling a small image
Write-Host ""
Write-Host "Test 4: Testing Docker image pull..." -ForegroundColor Yellow
try {
    Write-Host "Attempting to pull hello-world image..." -ForegroundColor Gray
    docker pull hello-world 2>&1 | Out-Null
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ Docker can pull images" -ForegroundColor Green
    } else {
        Write-Host "✗ Docker cannot pull images" -ForegroundColor Red
    }
} catch {
    Write-Host "✗ Image pull failed" -ForegroundColor Red
}

Write-Host ""
Write-Host "==================================" -ForegroundColor Cyan
Write-Host "Diagnosis Complete" -ForegroundColor Cyan
Write-Host "==================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "If Docker DNS is failing, try these fixes:" -ForegroundColor Yellow
Write-Host "1. Restart Docker Desktop" -ForegroundColor White
Write-Host "2. Add Google DNS to Docker Engine settings" -ForegroundColor White
Write-Host "3. See FIX_DOCKER_DNS.md for detailed solutions" -ForegroundColor White
Write-Host ""
