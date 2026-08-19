# Install self-hosted Automaton (OpenAI, no Conway Cloud).
# Usage:
#   irm https://raw.githubusercontent.com/ValentynPi/automaton/main/scripts/install.ps1 | iex
#   or:  powershell -ExecutionPolicy Bypass -File scripts/install.ps1

$ErrorActionPreference = "Stop"

$RepoUrl = if ($env:AUTOMATON_REPO) { $env:AUTOMATON_REPO } else { "https://github.com/ValentynPi/automaton.git" }
$InstallDir = if ($env:AUTOMATON_DIR) { $env:AUTOMATON_DIR } else { Join-Path $HOME "automaton" }
$Branch = if ($env:AUTOMATON_BRANCH) { $env:AUTOMATON_BRANCH } else { "main" }

function Test-Cmd($name) {
  if (-not (Get-Command $name -ErrorAction SilentlyContinue)) {
    throw "Missing '$name'. Install it, then re-run this script."
  }
}

Test-Cmd git
Test-Cmd node
Test-Cmd npm

$nodeMajor = [int]((node -p "process.versions.node.split('.')[0]").Trim())
if ($nodeMajor -lt 20) {
  throw "Node.js 20+ is required (found $(node -v))."
}

$gitDir = Join-Path $InstallDir ".git"
if (Test-Path $gitDir) {
  Write-Host "Updating existing install at $InstallDir"
  git -C $InstallDir fetch origin
  git -C $InstallDir checkout $Branch
  git -C $InstallDir pull --ff-only origin $Branch
} else {
  Write-Host "Cloning $RepoUrl -> $InstallDir"
  git clone --branch $Branch $RepoUrl $InstallDir
}

Set-Location $InstallDir
npm install
npx tsc
npm install -g .

Write-Host ""
Write-Host "Installed. Run:"
Write-Host "  automaton --run"
Write-Host ""
Write-Host "First run opens the setup wizard (OpenAI key + name + genesis prompt)."
Write-Host "Config is stored in $env:USERPROFILE\.automaton\"
