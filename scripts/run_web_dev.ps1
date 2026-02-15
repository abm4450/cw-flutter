# Run Flutter web on Chrome with CORS disabled (development only).
# Use this when the backend at cw.abdullah9.sa does not send CORS headers yet.
# See project root CORS.md for details.

$flutter = if ($env:FLUTTER_ROOT) { "$env:FLUTTER_ROOT\bin\flutter.bat" } else { "$env:USERPROFILE\flutter\bin\flutter.bat" }
$projectRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$chromeProfile = Join-Path $projectRoot ".chrome_dev_profile"

if (-not (Test-Path $flutter)) {
    Write-Error "Flutter not found at: $flutter"
    exit 1
}

Set-Location $projectRoot
& $flutter run -d chrome `
    --web-browser-flag "--disable-web-security" `
    --web-browser-flag "--user-data-dir=$chromeProfile"
