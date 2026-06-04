#!/bin/bash

export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"

MONDAY_WORKSPACE= #YOUR MONDAY WORKSPACE NAME HERE

REPORT_DIR="$HOME/monday-reports"
mkdir -p "$REPORT_DIR"
DATE=$(date +%Y-%m-%d)

bob --yolo --hide-intermediary-output --output-format text \
  "Get all tasks assigned to me in Monday.com where workspace is $MONDAY_WORKSPACE. Look across all boards. Find tasks where the person column or PIC column contains my username. Group them by status. Format as a clean markdown standup report for $DATE." \
  > "$REPORT_DIR/standup_$DATE.md"
echo "Standup report saved to $REPORT_DIR/standup_$DATE.md"
