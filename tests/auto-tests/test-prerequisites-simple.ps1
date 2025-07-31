# Simple Prerequisites Check
Write-Host "Starting Prerequisites Check..." -ForegroundColor Cyan

$passed = 0
$failed = 0

# Test Docker
Write-Host "Testing Docker..." -ForegroundColor Yellow
try {
    $dockerVersion = docker --version
    Write-Host "Docker: $dockerVersion" -ForegroundColor Green
    $passed++
} catch {
    Write-Host "Docker: Not Available" -ForegroundColor Red
    $failed++
}

# Test Docker Compose
try {
    $composeVersion = docker-compose --version
    Write-Host "Docker Compose: $composeVersion" -ForegroundColor Green
    $passed++
} catch {
    Write-Host "Docker Compose: Not Available" -ForegroundColor Red
    $failed++
}

# Test Node.js
Write-Host "Testing Node.js..." -ForegroundColor Yellow
try {
    $nodeVersion = node --version
    Write-Host "Node.js: $nodeVersion" -ForegroundColor Green
    $passed++
} catch {
    Write-Host "Node.js: Not Available" -ForegroundColor Red
    $failed++
}

# Test NPM
try {
    $npmVersion = npm --version
    Write-Host "NPM: $npmVersion" -ForegroundColor Green
    $passed++
} catch {
    Write-Host "NPM: Not Available" -ForegroundColor Red
    $failed++
}

# Test PowerShell Execution Policy
Write-Host "Testing PowerShell..." -ForegroundColor Yellow
$executionPolicy = Get-ExecutionPolicy
if ($executionPolicy -eq "Restricted") {
    Write-Host "Execution Policy: $executionPolicy (Restricted)" -ForegroundColor Red
    $failed++
} else {
    Write-Host "Execution Policy: $executionPolicy" -ForegroundColor Green
    $passed++
}

# Summary
Write-Host ""
Write-Host "Summary:" -ForegroundColor Cyan
Write-Host "Passed: $passed" -ForegroundColor Green
Write-Host "Failed: $failed" -ForegroundColor Red

if ($failed -eq 0) {
    Write-Host "Overall: PASSED" -ForegroundColor Green
    exit 0
} else {
    Write-Host "Overall: FAILED" -ForegroundColor Red
    exit 1
} 