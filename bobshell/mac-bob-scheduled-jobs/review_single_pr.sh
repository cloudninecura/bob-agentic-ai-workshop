#!/bin/bash

# ---- CONFIG ----
export PATH="/opt/homebrew/bin:/usr/local/bin:$PATH"
GITHUB_TOKEN="" #YOUR GITHUB TOKEN HERE
ORG="" #YOUR ORG HERE
REPO="" #YOUR REPO HERE
PR_NUMBER=1 # The PR number to review
MONDAY_WORKSPACE="" #YOUR MONDAY WORKSPACE NAME HERE

GITHUB_HOST="github.ibm.com"
ALREADY_REVIEWED="$HOME/bob-pr-reviewer/reviewed_prs.txt"

touch "$ALREADY_REVIEWED"

echo "Reviewing PR #$PR_NUMBER..."

# PR_DATA:
PR_DATA=$(curl -s \
  -H "Authorization: token $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  "https://$GITHUB_HOST/api/v3/repos/$ORG/$REPO/pulls/$PR_NUMBER")

PR_TITLE=$(echo "$PR_DATA" | jq -r '.title')

# Get the diff
curl -s \
  -H "Authorization: token $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github.v3.diff" \
  "https://$GITHUB_HOST/api/v3/repos/$ORG/$REPO/pulls/$PR_NUMBER" > "$HOME/bob-pr-reviewer/pr_$PR_NUMBER.diff"

# Run Bob Shell on the diff
REVIEW=$(bob --yolo --hide-intermediary-output --output-format text "Review this pull request diff. Identify what changed, flag any issues or security concerns, and summarize the key changes. Be concise. @$HOME/bob-pr-reviewer/pr_$PR_NUMBER.diff")

# Post the review as a PR comment
BODY=$(echo "$REVIEW" | python3 -c "import sys,json; print(json.dumps(sys.stdin.read()))")

curl -s -X POST \
  -H "Authorization: token $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  "https://$GITHUB_HOST/api/v3/repos/$ORG/$REPO/issues/$PR_NUMBER/comments" \
  -d "{\"body\": $BODY}"

MONDAY_UPDATE=$(bob --yolo --hide-intermediary-output --output-format text \
"Find a Monday.com task that matches PR #$PR_NUMBER titled '$PR_TITLE' in any of my boards in Workspace $MONDAY_WORKSPACE. If found, add a comment saying 'PR #$PR_NUMBER has been reviewed by Bob Shell. Review posted on GitHub.' and update the status to In Review if it's not already.")

echo "Monday.com update: $MONDAY_UPDATE"

# Mark as reviewed
echo "$PR_NUMBER" >> "$ALREADY_REVIEWED"
echo "PR #$PR_NUMBER reviewed and commented."

# Clean up diff file
rm "$HOME/bob-pr-reviewer/pr_$PR_NUMBER.diff"

echo "All PRs processed."
