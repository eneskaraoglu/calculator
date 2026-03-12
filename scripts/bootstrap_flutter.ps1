$ErrorActionPreference = "Stop"

if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
    Write-Error "Flutter SDK was not found on PATH. Install Flutter first, then reopen PowerShell."
}

Write-Host "Running flutter doctor..."
flutter doctor

Write-Host "Creating Flutter project in the current repository..."
flutter create .

Write-Host "Fetching packages..."
flutter pub get

Write-Host "Bootstrap complete. Start the app with: flutter run"
