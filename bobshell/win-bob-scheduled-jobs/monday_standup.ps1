# PowerShell version of monday_standup.sh
# Generates a Monday.com standup report for tasks assigned to the current user

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

# Get current date in YYYY-MM-DD format
# PowerShell equivalent of: date +%Y-%m-%d
$DATE = Get-Date -Format "yyyy-MM-dd"

# Build the output file path
$OUTPUT_FILE = Join-Path $REPORT_DIR "standup_$DATE.md"

# Run Bob CLI command to generate standup report
# PowerShell uses & to call external commands with arguments
Write-Host "Generating standup report for $DATE..."

$bobPrompt = @"
Get all tasks assigned to me in Monday.com where workspace is $MONDAY_WORKSPACE. Look across all boards. Find tasks where the person column or PIC column contains my username. Group them by status. Format as a clean markdown standup report for $DATE.
"@

# Execute bob command and redirect output to file
# PowerShell equivalent of command > file
& bob --yolo --hide-intermediary-output --output-format text $bobPrompt | Out-File -FilePath $OUTPUT_FILE -Encoding utf8

Write-Host "Standup report saved to $OUTPUT_FILE"
