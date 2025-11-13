# PowerShell script to fix Android keystore lock issues
# Run this before building if you encounter keystore lock errors

Write-Host "Fixing Android keystore lock issues..." -ForegroundColor Cyan

$androidDir = "$env:USERPROFILE\.android"
$lockFile = "$androidDir\debug.keystore.lock"

# Ensure .android directory exists
if (-not (Test-Path $androidDir)) {
    New-Item -ItemType Directory -Path $androidDir -Force | Out-Null
    Write-Host "Created .android directory" -ForegroundColor Green
}

# Remove lock file if it exists
if (Test-Path $lockFile) {
    try {
        Remove-Item $lockFile -Force -ErrorAction Stop
        Write-Host "✓ Removed lock file: $lockFile" -ForegroundColor Green
    } catch {
        Write-Host "✗ Could not remove lock file: $_" -ForegroundColor Red
        Write-Host "  Try closing Android Studio and other Gradle processes, then run this script again." -ForegroundColor Yellow
        exit 1
    }
} else {
    Write-Host "✓ No lock file found" -ForegroundColor Green
}

# Stop any running Gradle daemons that might hold locks
Write-Host "`nChecking for Gradle/Java processes..." -ForegroundColor Cyan
$gradleProcesses = Get-Process -Name "java", "gradle" -ErrorAction SilentlyContinue
if ($gradleProcesses) {
    Write-Host "Found $($gradleProcesses.Count) Gradle/Java process(es)" -ForegroundColor Yellow
    $gradleProcesses | ForEach-Object {
        try {
            Stop-Process -Id $_.Id -Force -ErrorAction Stop
            Write-Host "  ✓ Stopped process: $($_.ProcessName) (PID: $($_.Id))" -ForegroundColor Green
        } catch {
            Write-Host "  ✗ Could not stop process: $($_.ProcessName) (PID: $($_.Id))" -ForegroundColor Red
        }
    }
} else {
    Write-Host "✓ No Gradle/Java processes found" -ForegroundColor Green
}

# Verify .android directory permissions
Write-Host "`nVerifying directory permissions..." -ForegroundColor Cyan
try {
    $testFile = "$androidDir\test_write.tmp"
    "test" | Out-File -FilePath $testFile -ErrorAction Stop
    Remove-Item $testFile -Force -ErrorAction Stop
    Write-Host "✓ Directory is writable" -ForegroundColor Green
} catch {
    Write-Host "✗ Directory is not writable: $_" -ForegroundColor Red
    Write-Host "  Run PowerShell as Administrator and execute:" -ForegroundColor Yellow
    Write-Host "  icacls `"$androidDir`" /grant `"$env:USERNAME`":F /T" -ForegroundColor Yellow
    exit 1
}

Write-Host "`n✓ All checks passed! You can now build your app." -ForegroundColor Green
Write-Host "  Run: flutter build apk --release" -ForegroundColor Cyan

