# publish-lab.ps1
# Creates a GitHub repo from THIS folder and pushes everything in one go.
# Run from PowerShell inside the extracted folder:
#   powershell -ExecutionPolicy Bypass -File .\publish-lab.ps1

$ErrorActionPreference = "Stop"

$GitHubUser  = "mlwere1977"
$RepoName    = "aws-s3-glacier-lifecycle-lab"
$Visibility  = "--public"   # change to --private if you prefer
$Description = "AWS S3 lifecycle policy: automated archiving to Glacier Flexible Retrieval (CS 79B)"

if (-not (Get-Command git -ErrorAction SilentlyContinue)) { throw "Git is not installed: https://git-scm.com/download/win" }
if (-not (Get-Command gh  -ErrorAction SilentlyContinue)) { throw "GitHub CLI is not installed. Run: winget install --id GitHub.cli  (then reopen PowerShell)" }

gh auth status 2>$null
if ($LASTEXITCODE -ne 0) { gh auth login --hostname github.com --git-protocol https --web }

Set-Location $PSScriptRoot

if (-not (Test-Path ".git")) { git init -b main }

git add .
git diff --cached --quiet
if ($LASTEXITCODE -ne 0) { git commit -m "Initial commit: $RepoName" }

gh repo view "$GitHubUser/$RepoName" 2>$null | Out-Null
if ($LASTEXITCODE -eq 0) {
    Write-Host "Repo already exists. Pushing..." -ForegroundColor Yellow
    if (-not (git remote | Select-String "^origin$")) { git remote add origin "https://github.com/$GitHubUser/$RepoName.git" }
    git push -u origin main
} else {
    gh repo create "$GitHubUser/$RepoName" $Visibility --description "$Description" --source=. --remote=origin --push
}

Write-Host "`nDone: https://github.com/$GitHubUser/$RepoName" -ForegroundColor Green
