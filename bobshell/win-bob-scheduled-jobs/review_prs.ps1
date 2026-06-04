# PowerShell version of review_prs.sh
# Reviews all open PRs in a GitHub repository and posts comments

# Set error action preference to stop on errors
$ErrorActionPreference = "Stop"

# ---- CONFIG ----
$GITHUB_TOKEN= #YOUR GITHUB TOKEN HERE
$ORG = #YOUR ORG HERE
$REPO = #YOUR REPO HERE
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

# ---- FETCH OPEN PRs ----
Write-Host "Fetching open PRs..."

# PowerShell equivalent of: curl with headers
# Use Invoke-RestMethod instead of curl for JSON responses
$headers = @{
    "Authorization" = "token $GITHUB_TOKEN"
    "Accept" = "application/vnd.github.v3+json"
}

$apiUrl = "https://$GITHUB_HOST/api/v3/repos/$ORG/$REPO/pulls?state=open"

try {
    $OPEN_PRS = Invoke-RestMethod -Uri $apiUrl -Headers $headers -Method Get
} catch {
    Write-Error "Failed to fetch PRs: $_"
    exit 1
}

# ---- LOOP THROUGH EACH PR ----
# PowerShell equivalent of: echo "$OPEN_PRS" | jq -r '.[].number'
$PR_NUMBERS = $OPEN_PRS | ForEach-Object { $_.number }

Write-Host "Found $($PR_NUMBERS.Count) open PR(s): $($PR_NUMBERS -join ', ')"

foreach ($PR_NUMBER in $PR_NUMBERS) {
    
    # Check if already reviewed
    # PowerShell equivalent of: grep -q "^$PR_NUMBER$" "$ALREADY_REVIEWED"
    $alreadyReviewed = Get-Content $ALREADY_REVIEWED -ErrorAction SilentlyContinue | Where-Object { $_ -eq $PR_NUMBER }
    
    if ($alreadyReviewed) {
        Write-Host "PR #$PR_NUMBER already reviewed, skipping."
        continue
    }
    
    Write-Host "Reviewing PR #$PR_NUMBER..."
    
    # Get the PR diff
    # PowerShell equivalent of: curl with Accept: application/vnd.github.v3.diff
    $diffHeaders = @{
        "Authorization" = "token $GITHUB_TOKEN"
        "Accept" = "application/vnd.github.v3.diff"
    }
    
    $diffUrl = "https://$GITHUB_HOST/api/v3/repos/$ORG/$REPO/pulls/$PR_NUMBER"
    $diffFile = Join-Path $REVIEW_DIR "pr_$PR_NUMBER.diff"
    
    try {
        Invoke-RestMethod -Uri $diffUrl -Headers $diffHeaders -Method Get -OutFile $diffFile
    } catch {
        Write-Warning "Failed to fetch diff for PR #$PR_NUMBER: $_"
        continue
    }
    
    # Get PR title
    # PowerShell equivalent of: echo "$OPEN_PRS" | jq -r ".[] | select(.number == $PR_NUMBER) | .title"
    $PR_TITLE = ($OPEN_PRS | Where-Object { $_.number -eq $PR_NUMBER }).title
    Write-Host "PR Title: $PR_TITLE"
    
    # Run Bob Shell on the diff
    $bobPrompt = "Review this pull request diff. Identify what changed, flag any issues or security concerns, and summarize the key changes. Be concise. @$diffFile"
    
    try {
        $REVIEW = & bob --yolo --hide-intermediary-output --output-format text $bobPrompt
    } catch {
        Write-Warning "Failed to generate review for PR #$PR_NUMBER: $_"
        continue
    }
    
    # Post the review as a PR comment
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
        Write-Warning "Failed to post comment for PR #$PR_NUMBER: $_"
    }
    
    # Update Monday.com
    $mondayPrompt = "Find a Monday.com task that matches PR #$PR_NUMBER titled '$PR_TITLE' in any of my boards in Workspace $MONDAY_WORKSPACE. If found, add a comment saying 'PR #$PR_NUMBER has been reviewed by Bob Shell. Review posted on GitHub.' and update the status to In Review if it's not already."
    
    try {
        $MONDAY_UPDATE = & bob --yolo --hide-intermediary-output --output-format text $mondayPrompt
        Write-Host "Monday.com update: $MONDAY_UPDATE"
    } catch {
        Write-Warning "Failed to update Monday.com for PR #$PR_NUMBER: $_"
    }
    
    # Mark as reviewed
    # PowerShell equivalent of: echo "$PR_NUMBER" >> "$ALREADY_REVIEWED"
    Add-Content -Path $ALREADY_REVIEWED -Value $PR_NUMBER
    Write-Host "PR #$PR_NUMBER reviewed and commented."
    
    # Clean up diff file
    # PowerShell equivalent of: rm "$HOME/bob-pr-reviewer/pr_$PR_NUMBER.diff"
    Remove-Item -Path $diffFile -Force -ErrorAction SilentlyContinue
}

Write-Host "All PRs processed."
