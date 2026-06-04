#!/bin/bash

# =============================================================================
# PM Standup Script
# =============================================================================
# This script generates a daily team standup report from Monday.com and 
# compares it with the previous day's report to identify changes.
# =============================================================================

export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
MONDAY_WORKSPACE= #YOUR MONDAY WORKSPACE NAME HERE
REPORT_DIR="$HOME/monday-reports"
mkdir -p "$REPORT_DIR"
DATE=$(date +%Y-%m-%d)
PREV_DATE=$(date -v-1d +%Y-%m-%d)
PREV_REPORT="$REPORT_DIR/team_standup_$PREV_DATE.md"
TODAY_REPORT="$REPORT_DIR/team_standup_$DATE.md"

# ---- STEP 1: Generate today's team report ----
echo "Generating today's team standup report..."

bob --yolo --hide-intermediary-output --output-format text \
  "Get all tasks in Monday.com workspace '$MONDAY_WORKSPACE'. Look across all boards and all members.
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
   Flag any tasks that are Blocked or overdue based on target date." \
  > "$TODAY_REPORT"

echo "Today's report saved to $TODAY_REPORT"

# ---- STEP 2: Compare with previous report if it exists ----
if [ -f "$PREV_REPORT" ]; then
  echo "Previous report found. Analyzing changes..."

  DELTA=$(bob --yolo --hide-intermediary-output --output-format text \
    "Compare these two standup reports and identify what changed between $PREV_DATE and $DATE.
     Return ONLY the markdown section content. Do not save any files. Do not add commentary.

     PREVIOUS REPORT ($PREV_DATE):
     $(cat "$PREV_REPORT")

     TODAY'S REPORT ($DATE):
     $(cat "$TODAY_REPORT")

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
     Be direct and concise. Flag concerns clearly.")

  # Prepend delta to today's report
  TEMP_FILE=$(mktemp)
  echo "$DELTA" > "$TEMP_FILE"
  echo "" >> "$TEMP_FILE"
  echo "---" >> "$TEMP_FILE"
  echo "" >> "$TEMP_FILE"
  cat "$TODAY_REPORT" >> "$TEMP_FILE"
  mv "$TEMP_FILE" "$TODAY_REPORT"

  echo "Delta prepended to $TODAY_REPORT"
else
  echo "No previous report found for $PREV_DATE — skipping delta analysis."
fi

echo "Done. Report saved to $TODAY_REPORT"
echo "Done"
