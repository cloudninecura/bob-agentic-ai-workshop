# PowerShell version of pm_standup.sh
# Generates a team standup report with delta analysis from previous day

# Set error action preference to stop on errors
$ErrorActionPreference = "Stop"

# Configuration
$MONDAY_WORKSPACE = #YOUR MONDAY WORKSPACE NAME HERE

$REPORT_DIR = Join-Path $env:USERPROFILE "monday-reports"

# Create report directory if it doesn't exist
# PowerShell equivalent of: mkdir -p "$REPORT_DIR"
if (-not (Test-Path $REPORT_DIR)) {
    New-Item -ItemType Directory -Path $REPORT_DIR -Force | Out-Null
}

# Get dates in YYYY-MM-DD format
# PowerShell equivalent of: date +%Y-%m-%d and date -v-1d +%Y-%m-%d
$DATE = Get-Date -Format "yyyy-MM-dd"
$PREV_DATE = (Get-Date).AddDays(-1).ToString("yyyy-MM-dd")

# Build file paths
$PREV_REPORT = Join-Path $REPORT_DIR "team_standup_$PREV_DATE.md"
$TODAY_REPORT = Join-Path $REPORT_DIR "team_standup_$DATE.md"

# ---- STEP 1: Generate today's team report ----
Write-Host "Generating today's team standup report..."

$bobPrompt1 = @"
Get all tasks in Monday.com workspace '$MONDAY_WORKSPACE'. Look across all boards and all members.
Return ONLY the markdown report content below. Do not save any files. Do not add any commentary.

IMPORTANT: Only include parent tasks, exclude all subitems.
IMPORTANT: Deduplicate tasks by their Monday.com task ID - if you see the same task ID multiple times, include it only once.
IMPORTANT: Include the Monday.com task ID for each task in parentheses after the task name, like: 'Task Name (ID: 12345678)'.

Format as a clean markdown report titled 'Team Standup Report - $DATE'.

Use this exact section order:
1. Overall Team Progress Summary (counts and percentages by status)
2. Critical Items Requiring Attention — blocked tasks and overdue tasks, flagged clearly
3. Progress Insights — top contributor, completion rate, backlog percentage, board-level breakdown
4. Unassigned Tasks
5. Tasks by Team Member — grouped by person, then by status

For each task include: task name with ID, status, priority, and target date if available.
Flag any tasks that are Blocked or overdue based on target date.
"@

# Execute bob command and save to file
& bob --yolo --hide-intermediary-output --output-format text $bobPrompt1 | Out-File -FilePath $TODAY_REPORT -Encoding utf8

Write-Host "Today's report saved to $TODAY_REPORT"

# ---- STEP 2: Compare with previous report if it exists ----
if (Test-Path $PREV_REPORT) {
    Write-Host "Previous report found. Analyzing changes..."
    
    # Read both reports
    # PowerShell equivalent of: cat "$PREV_REPORT"
    $prevContent = Get-Content -Path $PREV_REPORT -Raw
    $todayContent = Get-Content -Path $TODAY_REPORT -Raw
    
    $bobPrompt2 = @"
Compare these two standup reports and identify what changed between $PREV_DATE and $DATE.
Return ONLY the markdown section content. Do not save any files. Do not add commentary.

PREVIOUS REPORT ($PREV_DATE):
$prevContent

TODAY'S REPORT ($DATE):
$todayContent

IMPORTANT: When comparing tasks, use task IDs if available, not just task names.
IMPORTANT: If you see the same task name appearing multiple times with different IDs, note this as a potential duplicate issue.
IMPORTANT: When mentioning PR reviews or specific work items, include the full title or ID to avoid confusion.

Identify:
1. Tasks that moved to Done since yesterday (use task IDs to match)
2. Tasks that are newly Blocked or still Blocked
3. Tasks that are newly added
4. Team members with no progress since yesterday
5. Any overdue tasks that still have not moved

Format as a clean markdown section titled 'Progress Delta: $PREV_DATE → $DATE'.
Be direct and concise. Flag concerns clearly.
"@
    
    # Get delta analysis
    $DELTA = & bob --yolo --hide-intermediary-output --output-format text $bobPrompt2
    
    # Prepend delta to today's report
    # PowerShell equivalent of: mktemp, echo > file, cat >> file, mv
    $tempContent = $DELTA + "`n`n---`n`n" + $todayContent
    $tempContent | Out-File -FilePath $TODAY_REPORT -Encoding utf8
    
    Write-Host "Delta prepended to $TODAY_REPORT"
} else {
    Write-Host "No previous report found for $PREV_DATE — skipping delta analysis."
}

Write-Host "Done. Report saved to $TODAY_REPORT"
Write-Host "Done"
