# PowerShell version of review_single_pr.sh
# Reviews a single PR in a GitHub repository and posts a comment

# Set error action preference to stop on errors
$ErrorActionPreference = "Stop"

# ---- CONFIG ----
$GITHUB_TOKEN= #YOUR GITHUB TOKEN HERE
$ORG = #YOUR ORG HERE
$REPO = #YOUR REPO HERE
$PR_NUMBER = 1  # The PR number to review
$MONDAY_WORKSPACE = #YOUR MONDAY WORKSPACE NAME HERE

$GITHUB_HOST = "github.ibm.com"

$REVIEW_DIR = Join-Path $env:USERPROFILE "bob-pr-reviewer"
$ALREADY_REVIEWED = Join-Path $REVIEW_DIR "reviewed_prs.txt"

# Create review directory if it doesn't exist
if (-not (Test-Path $REVIEW_DIR)) {
    New-Item -ItemType Directory -Path $REVIEW_DIR -Force | Out-Null
}

# Create reviewed PRs file if it doesn't exist
# PowerShell equivalent of: touch "$ALREADY_REVIEWED"
if (-not (Test-Path $ALREADY_REVIEWED)) {
    New-Item -ItemType File -Path $ALREADY_REVIEWED -Force | Out-Null
}

Write-Host "Reviewing PR #$PR_NUMBER..."

# ---- FETCH PR DATA ----
# PowerShell equivalent of: curl with headers
# Use Invoke-RestMethod instead of curl for JSON responses
$headers = @{
    "Authorization" = "token $GITHUB_TOKEN"
    "Accept" = "application/vnd.github.v3+json"
}

$prUrl = "https://$GITHUB_HOST/api/v3/repos/$ORG/$REPO/pulls/$PR_NUMBER"

try {
    $PR_DATA = Invoke-RestMethod -Uri $prUrl -Headers $headers -Method Get
} catch {
    Write-Error "Failed to fetch PR #$PR_NUMBER: $_"
    exit 1
}

# Get PR title
# PowerShell equivalent of: echo "$PR_DATA" | jq -r '.title'
$PR_TITLE = $PR_DATA.title
Write-Host "PR Title: $PR_TITLE"

# ---- GET THE DIFF ----
# PowerShell equivalent of: curl with Accept: application/vnd.github.v3.diff
$diffHeaders = @{
    "Authorization" = "token $GITHUB_TOKEN"
    "Accept" = "application/vnd.github.v3.diff"
}

$diffFile = Join-Path $REVIEW_DIR "pr_$PR_NUMBER.diff"

try {
    Invoke-RestMethod -Uri $prUrl -Headers $diffHeaders -Method Get -OutFile $diffFile
} catch {
    Write-Error "Failed to fetch diff for PR #$PR_NUMBER: $_"
    exit 1
}

# ---- RUN BOB SHELL ON THE DIFF ----
$bobPrompt = "Review this pull request diff. Identify what changed, flag any issues or security concerns, and summarize the key changes. Be concise. @$diffFile"

try {
    $REVIEW = & bob --yolo --hide-intermediary-output --output-format text $bobPrompt
} catch {
    Write-Error "Failed to generate review for PR #$PR_NUMBER: $_"
    exit 1
}

# ---- POST THE REVIEW AS A PR COMMENT ----
# PowerShell equivalent of: echo "$REVIEW" | python3 -c "import sys,json; print(json.dumps(sys.stdin.read()))"
# Use ConvertTo-Json instead of python for JSON encoding
$commentBody = @{
    body = $REVIEW
} | ConvertTo-Json

$commentUrl = "https://$GITHUB_HOST/api/v3/repos/$ORG/$REPO/issues/$PR_NUMBER/comments"

try {
    Invoke-RestMethod -Uri $commentUrl -Headers $headers -Method Post -Body $commentBody -ContentType "application/json" | Out-Null
    Write-Host "Review comment posted for PR #$PR_NUMBER"
} catch {
    Write-Error "Failed to post comment for PR #$PR_NUMBER: $_"
    exit 1
}

# ---- UPDATE MONDAY.COM ----
$mondayPrompt = "Find a Monday.com task that matches PR #$PR_NUMBER titled '$PR_TITLE' in any of my boards in Workspace $MONDAY_WORKSPACE. If found, add a comment saying 'PR #$PR_NUMBER has been reviewed by Bob Shell. Review posted on GitHub.' and update the status to In Review if it's not already."

try {
    $MONDAY_UPDATE = & bob --yolo --hide-intermediary-output --output-format text $mondayPrompt
    Write-Host "Monday.com update: $MONDAY_UPDATE"
} catch {
    Write-Warning "Failed to update Monday.com for PR #$PR_NUMBER: $_"
}

# ---- MARK AS REVIEWED ----
# PowerShell equivalent of: echo "$PR_NUMBER" >> "$ALREADY_REVIEWED"
Add-Content -Path $ALREADY_REVIEWED -Value $PR_NUMBER
Write-Host "PR #$PR_NUMBER reviewed and commented."

# ---- CLEAN UP DIFF FILE ----
# PowerShell equivalent of: rm "$HOME/bob-pr-reviewer/pr_$PR_NUMBER.diff"
Remove-Item -Path $diffFile -Force -ErrorAction SilentlyContinue

Write-Host "All PRs processed."
