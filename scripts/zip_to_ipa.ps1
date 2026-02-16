# Convert Runner.app.zip (Codemagic build) to .ipa for iOS installation.
# Place Runner.app.zip in the project root, then run this script.

$ErrorActionPreference = "Stop"
$projectRoot = Split-Path -Parent $PSScriptRoot
$zipPath = Join-Path $projectRoot "Runner.app.zip"
$workDir = Join-Path $projectRoot "ipa_build"
$payloadDir = Join-Path $workDir "Payload"
$ipaPath = Join-Path $projectRoot "Runner.ipa"

if (-not (Test-Path $zipPath)) {
    Write-Error "Runner.app.zip not found at: $zipPath"
    exit 1
}

# Clean previous run
if (Test-Path $workDir) {
    Remove-Item $workDir -Recurse -Force
}
New-Item -ItemType Directory -Path $workDir -Force | Out-Null

# Unzip Runner.app.zip
Expand-Archive -Path $zipPath -DestinationPath $workDir -Force

# Find Runner.app (may be at workDir\Runner.app or inside one folder)
$runnerApp = Join-Path $workDir "Runner.app"
if (-not (Test-Path $runnerApp)) {
    $found = Get-ChildItem -Path $workDir -Filter "Runner.app" -Recurse -Directory | Select-Object -First 1
    if ($found) { $runnerApp = $found.FullName } else {
        Write-Error "Runner.app not found inside the zip."
        exit 1
    }
}

# IPA = zip containing Payload/Runner.app
New-Item -ItemType Directory -Path $payloadDir -Force | Out-Null
$destApp = Join-Path $payloadDir "Runner.app"
if (Test-Path $destApp) { Remove-Item $destApp -Recurse -Force }
Move-Item -Path $runnerApp -Destination $destApp -Force

# Create IPA (zip Payload folder and rename to .ipa)
$ipaZip = Join-Path $projectRoot "Runner_temp.zip"
if (Test-Path $ipaZip) { Remove-Item $ipaZip -Force }
Compress-Archive -Path $payloadDir -DestinationPath $ipaZip -Force
if (Test-Path $ipaPath) { Remove-Item $ipaPath -Force }
Rename-Item -Path $ipaZip -NewName "Runner.ipa"

# Cleanup
Remove-Item $workDir -Recurse -Force

Write-Host "Done: $ipaPath"
