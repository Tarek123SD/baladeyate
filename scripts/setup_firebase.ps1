# Run this script in an interactive terminal after Firebase CLI is installed.
# Usage: .\scripts\setup_firebase.ps1

$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot\..

Write-Host "`n=== Baladeyate Firebase setup ===" -ForegroundColor Cyan
Write-Host "Step 1/2: Sign in to Firebase (browser will open)`n"
npx firebase login

Write-Host "`nStep 2/2: Link this Flutter app to your Firebase project`n"
& "$PSScriptRoot\firebase_configure.ps1"

Write-Host "`nDone. Run: flutter pub get; flutter run" -ForegroundColor Green
