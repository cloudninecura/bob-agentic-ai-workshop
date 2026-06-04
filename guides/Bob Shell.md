# Agentic AI Workshop

## Hands-On Lab Guide

### Using Bob Shell for Automation

**What you'll build:** Automated workflows that run without human intervention — a PR review cron job that fetches open pull requests, reviews them with AI, and posts comments to GitHub; and a Monday.com standup report generator. You'll set up both as scheduled jobs on your machine.

---

**Estimated Duration:** ~30 minutes | **Difficulty:** Beginner

## Table of Contents

- [Introduction](#introduction)
  - [What is Bob Shell?](#what-is-bob-shell)
  - [Key Concepts](#key-concepts)
- [Prerequisites](#prerequisites)
  - [Prerequisite 1 of 4 — Node.js](#prerequisite-1-of-4--nodejs)
    - [MacOS/Linux](#macoslinux)
    - [Windows](#windows)
  - [Prerequisite 2 of 4 — IBM Bob Shell](#prerequisite-2-of-4--ibm-bob-shell)
    - [MacOS/Linux](#macoslinux-1)
    - [Windows](#windows-1)
    - [How to verify: IBM Bob Shell is ready](#how-to-verify-ibm-bob-shell-is-ready)
  - [Prerequisite 3 of 4 — jq (MacOS/Linux only)](#prerequisite-3-of-4--jq-macoslinux-only)
  - [Prerequisite 4 of 4 — GitHub Personal Access Token (For Devs only)](#prerequisite-4-of-4--github-personal-access-token-for-devs-only)
  - [Pre-Workshop Checklist](#pre-workshop-checklist)
- [Bob Shell Session at a Glance](#bob-shell-session-at-a-glance)
- [Part 1 — Bob Shell Sessions](#part-1--bob-shell-sessions)
  - [Interactive Session 💬](#interactive-session-)
    - [Exercise 1A — Explore the App Structure](#exercise-1a--explore-the-app-structure)
  - [Non-Interactive Mode ⚡](#non-interactive-mode-)
    - [Exercise 1B — Run a One-Shot Task](#exercise-1b--run-a-one-shot-task)
- [Part 2 — Monday.com Integration](#part-2--mondaycom-integration)
  - [Connecting Bob Shell to Monday.com](#connecting-bob-shell-to-mondaycom)
  - [Exercise 2A — Download and Configure the Scripts](#exercise-2a--download-and-configure-the-scripts)
  - [Exercise 2B — Generate a Standup Report](#exercise-2b--generate-a-standup-report)
  - [Exercise 2C — Schedule the Standup Report](#exercise-2c--schedule-the-standup-report)
    - [MacOS – Cron](#macos--cron)
    - [Windows – Task Scheduler](#windows--task-scheduler)
- [Part 3 — PR Review Automation](#part-3--pr-review-automation)
  - [How the PR Review Works](#how-the-pr-review-works)
  - [Exercise 3A — Download and Configure the Scripts](#exercise-3a--download-and-configure-the-scripts)
  - [Exercise 3B — Test the Script Manually](#exercise-3b--test-the-script-manually)
  - [Exercise 3C — Schedule the Review Job](#exercise-3c--schedule-the-review-job)
    - [MacOS – Cron](#macos--cron-1)
    - [Windows – Task Scheduler](#windows--task-scheduler-1)
- [Wrap-Up & Next Steps](#wrap-up--next-steps)
  - [What You Built Today](#what-you-built-today)
  - [Where to Go Next](#where-to-go-next)

---

## Introduction

### What is Bob Shell?

Bob Shell is IBM Bob's terminal-based interface. It shares the same AI engine as Bob IDE — same reasoning, same MCP support, same tool access — but it runs in your command line and does not require a graphical editor.

The key difference is **autonomy**. Bob IDE always has a human in the loop — you open it, type, review, and approve. Bob Shell can operate without any human present, making it ideal for automation, scheduled jobs, CI/CD pipelines, and event-driven workflows.

### Key Concepts

- **Interactive Session** — a conversational session in your terminal, exactly like Bob IDE but without the graphical interface
- **Non-Interactive Session** — pass Bob a task in one command; it runs, completes it, and exits with no session required

---

## Prerequisites

This workshop uses shell scripts (bash on Mac/Linux, PowerShell on Windows). No build tools or special runtimes are required beyond the items below. You only need three things installed before the session: Node.js, IBM Bob Shell and jq (Mac/Linux only). Follow the steps below carefully and verify each one before the workshop begins.

### Prerequisite 1 of 4 — Node.js

Bob Shell is built on Node.js and requires it to run. Node.js provides the runtime environment that powers Bob Shell's command-line interface and automation capabilities.

#### MacOS/Linux

Using Homebrew (recommended):

1. Open your terminal
2. Run the installation command.

```bash
# Install Homebrew if you don't have it
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install Node.js LTS
brew install node
```

**Verify Installation**

```bash
which node
which npm
```

You should see output similar to:

```
/opt/homebrew/bin/node
/opt/homebrew/bin/npm
```

#### Windows

Direct download (recommended):

1. Visit https://nodejs.org/
2. Download the LTS version for Windows
3. Run the installer (.msi file)
4. Follow the installation wizard (accept defaults)

**Verify Installation**

```powershell
# Check Node.js version
node --version

# Check npm version
npm --version
```

You should see output similar to:

```
v24.16.0
11.13.0
```

---

### Prerequisite 2 of 4 — IBM Bob Shell

Bob Shell is a standalone CLI tool available to IBM employees. If you completed the Bob IDE session, you already have access to Bob Shell.

#### MacOS/Linux

1. Open your terminal
2. Run the installation command.

```bash
curl -fsSL https://bob.ibm.com/download/bobshell.sh | bash
```

3. Follow the on-screen prompts to complete the installation.
4. Restart your terminal or run:

```bash
source ~/.bashrc  # or ~/.zshrc for zsh users
```

#### Windows

1. Open PowerShell as Administrator (right-click PowerShell → "Run as Administrator")
2. Run the installation command.

```powershell
powershell -ep Bypass 'irm -Uri "https://bob.ibm.com/download/bobshell.ps1" | iex'
```

3. Follow the on-screen prompts to complete the installation.
4. Restart Powershell

#### How to verify: IBM Bob Shell is ready

After installation, verify Bob Shell is working correctly:

```bash
bob --version
```

You should see output similar to:

```
1.0.4
```

If the command is not found, you may need to:
- Restart your terminal/PowerShell
- Check that Bob Shell was added to your PATH
- Refer to the official installation guide for troubleshooting

---

### Prerequisite 3 of 4 — jq (MacOS/Linux only)

jq is a lightweight command-line JSON processor used to parse GitHub API responses in the automation scripts.

1. Open your terminal
2. Run the installation command.

```bash
# macOS
brew install jq

# Linux
sudo apt-get install jq
```

**Verify installation**

```bash
jq --version
```

---

### Prerequisite 4 of 4 — GitHub Personal Access Token (For Devs only)

You will need the following credentials set as environment variables before running the automation scripts.

1. Log in to GitHub and click your profile picture in the top-right corner
2. Navigate to Settings → Developer settings (at the bottom of the left sidebar)
3. Click Personal access tokens → Tokens (classic)
4. Click Generate new token → Generate new token (classic)
5. Name your token (e.g., "Development Machine" or "Automation Scripts")
6. Set expiration (recommended: 90 days for security, or custom date)
7. Select scopes based on your needs (see Best Practices section below)
8. Click Generate token at the bottom
9. **IMPORTANT:** Copy the token immediately - you won't be able to see it again

### Pre-Workshop Checklist

- ✅ Node.js, IBM Bob Shell, jq installed — returns a version number in your terminal
- ✅ Have a copy of your GitHub PAT

---

## Bob Shell Session at a Glance

Bob Shell operates in two distinct sessions, each designed for different scenarios:

| Session | When to Use | Key Behavior | Best For |
|---------|-------------|--------------|----------|
| 💬 Interactive | Exploratory work, debugging, learning | Conversational — you type, Bob responds, you approve | Development, experimentation |
| ⚡ Non-Interactive | Automation, pipelines, scheduled jobs | Single command — Bob runs, completes, exits | Cron jobs, CI/CD, webhooks |

---

## Part 1 — Bob Shell Sessions

In this part you will experience both modes hands-on. Start with interactive mode to explore a project, then switch to non-interactive to see how Bob behaves as an autonomous tool.

### Interactive Session 💬

**Best for:** exploration, debugging, and tasks that benefit from back-and-forth conversation.

Interactive mode launches a Bob Shell session in your terminal. You can ask questions, request changes, and work through problems step by step — just like Bob IDE, but entirely in the command line.

#### Exercise 1A — Explore the App Structure

| # | Action | What to Do |
|---|--------|------------|
| 1 | Navigate to your project | In your terminal, cd into any project folder you have available. If you don't have one, use the bob-agentic-ai-workshop repo shared in the workshop resources. |
| 2 | Launch interactive mode | Type: `bob`<br>Bob Shell starts. You'll see the IBM logo, version number, and a prompt at the bottom. |
| 3 | Ask about the project | Type: `What does this project do?`<br>Bob reads the project files and explains the codebase in plain language. |
| 4 | Ask a follow-up | Type: `What files are in this project and what does each one do?`<br>Bob will list and describe each file without making any changes. |
| 5 | Exit the session | Type: `/exit`<br>The session closes and you return to your normal terminal prompt. |

**What you learned:** Interactive mode gives you a conversational AI assistant in your terminal. Bob reads your project files and responds to your questions without making any changes unless you explicitly ask it to.

---

### Non-Interactive Mode ⚡

**Best for:** automation, scheduled jobs, and any scenario where no human needs to be present.

In non-interactive mode, you pass Bob a task directly as a command-line argument. Bob executes the task completely on its own and exits. No session, no approvals, no human in the loop.

| Flag | What it does |
|------|--------------|
| `--yolo` / `-y` | Auto-approves all tool calls and file operations. No confirmation prompts. Essential for automation and non-interactive use. |
| `--hide-intermediary-output` | Suppresses Bob's step-by-step reasoning output and shows only the final result. Use this when capturing output in a script. |
| `--output-format text` | Returns plain text output. Use `json` or `stream-json` for structured output in pipelines. |
| `--chat-mode` | Sets the reasoning mode. Options: `ask`, `code`, `plan`, `advanced`. Each optimizes Bob's behavior for a specific task type. |
| `--approval-mode` | Fine-grained approval control. `default` prompts for everything. `auto_edit` approves file edits only. `yolo` approves everything silently. |
| `--resume` / `-r` | Resumes a previous session. Use `--resume latest` to continue the most recent session, or pass a session index number. |
| `--allowed-tools` | Whitelist specific tools that Bob can call without asking for confirmation. Useful for trusted MCP tools in automation. |
| `--prompt-interactive` / `-i` | Executes an initial prompt then drops into interactive mode. Good for seeding a session with context before taking over. |

#### Exercise 1B — Run a One-Shot Task

| # | Action | What to Do |
|---|--------|------------|
| 1 | Run a simple task | In your terminal (in the same project folder), type:<br>`bob "Summarize what this project does in 3 bullet points"`<br>Bob runs, outputs the summary, and exits. |
| 2 | Try with clean output | Add the `--hide-intermediary-output` flag for cleaner results:<br>`bob --hide-intermediary-output "Summarize what this project does in 3 bullet points"`<br>This suppresses the step-by-step tool calls and shows only the final output. |
| 3 | Compare the difference | Run both commands and notice the difference in output. The first shows Bob's reasoning steps; the second shows only the final result. |

**What you learned:** Non-interactive mode is what makes Bob Shell an automation tool rather than just an assistant. That same command can be placed inside a shell script, a cron job, or a CI/CD pipeline — and Bob just runs it on its own.

---

## Part 2 — Monday.com Integration

In this part you will connect Bob Shell to Monday.com via MCP and set up an automated standup report generator. Bob will query your boards and write a daily report — no manual input needed.

### Connecting Bob Shell to Monday.com

Since you have installed Monday.com MCP globally, it is automatically connected to Bob Shell.

But in case you have installed in in your project only, you can create the `mcp_settings.json` in `/root-directory/.bob/mcp_settings.json`:

```json
{
  "mcpServers": {
    "monday": {
      "type": "sse",
      "url": "https://mcp.monday.com/sse",
      "headers": {
        "Authorization": "YOUR-MONDAY.COM-AUTH-TOKEN"
      }
    }
  }
}
```

### Exercise 2A — Download and Configure the Scripts

1. **Download Scripts:**
   - Windows: win-bob-scheduled-jobs
   - Mac/Linux: mac-bob-scheduled-jobs

2. **Open the script `pm_standup` in your text editor**
   - Windows: `pm_standup.ps1`
   - Mac/Linux: `pm_standup.sh`

3. **Update the config**
   
   Find the configuration section at the top and update:
   
   ```bash
   MONDAY_WORKSPACE= #YOUR MONDAY WORKSPACE NAME HERE
   ```

4. **Make executable**
   
   **Mac/Linux**
   ```bash
   chmod +x ~/mac-bob-scheduled-jobs/*.sh
   ```
   
   **Windows**
   ```powershell
   Get-ChildItem *.ps1 | Unblock-File
   ```

### Exercise 2B — Generate a Standup Report

1. **Run in non-interactive mode – with Monday.com MCP configured**

```bash
bob --yolo --hide-intermediary-output "Get all tasks assigned to me in Monday.com in Workspace YOUR-WORKSPACE-HERE. Group by status. Format as a markdown standup report for today."
```

2. **Review the output.** Bob queries Monday.com and returns a formatted standup report. No human interaction was needed.

3. **Run the script**
   
   **Windows**
   ```powershell
   .\win-bob-scheduled-jobs\pm_standup.ps1
   ```
   
   **MacOs**
   ```bash
   ~/mac-bob-scheduled-jobs/pm_standup.sh
   ```

4. **Watch the output for the progress**

5. **View the report.**

### Exercise 2C — Schedule the Standup Report

#### MacOS – Cron

```bash
# Open crontab editor
crontab -e

# Add this line to generate a standup report every day at 8am
0 8 * * * /Users/yourusername/mac-bob-scheduled-jobs/pm_standup.sh >> /Users/yourusername/mac-bob-scheduled-jobs/pm_standup.log 2>&1

# Save and exit (ESC, then :wq in vim)

# Verify the job is registered
crontab -l
```

#### Windows – Task Scheduler

1. Press Win + R, type `taskschd.msc`, press Enter
2. Click **Create Task** (not Create Basic Task) → Name the task: **Bob Daily Standup**
3. In the **General** tab:
   - Check **Run whether user is logged on or not**
   - (Optional) Check **Run with highest privileges**
4. **Triggers** tab → New → Daily, 8:00 AM
5. **Actions** tab → New → Program: `powershell.exe`, Arguments: `-ExecutionPolicy Bypass -File "C:\...\pm_standup\.ps1"`
6. Save and right-click the task → **Run** to test

**What you learned:** Bob Shell + MCP transforms Monday.com from a tool you manually check into a system Bob actively monitors on your behalf. The same pattern — connect an MCP server, run Bob in non-interactive mode, schedule it — applies to any system with an API.

---

## Part 3 — PR Review Automation

In this part you will set up an automated PR review job. Bob Shell will fetch open pull requests from GitHub, review each one using AI, and post the review as a comment — all without any human triggering it.

### How the PR Review Works

The automation follows this flow for each open PR that has not been reviewed yet:

| # | Action | What to Do |
|---|--------|------------|
| 1 | Fetch PR | curl calls the GitHub API to get the specified PR |
| 2 | Fetch diff | curl downloads the PR diff file |
| 3 | Bob reviews | `bob --yolo` reads the diff and generates a review |
| 4 | Post comment | curl posts the review as a comment on the PR |

### Exercise 3A — Download and Configure the Scripts

1. **Download Scripts:**
   - Windows: win-bob-scheduled-jobs
   - MacOs: mac-bob-scheduled-jobs

2. **Open the script in your text editor**
   - Windows: `review_single_pr.ps1`
   - MacOs: `review_single_pr.sh`

3. **Update the config**
   
   Find the configuration section at the top and update:
   
   ```bash
   GITHUB_TOKEN="" #YOUR GITHUB TOKEN HERE
   ORG="" #YOUR ORG HERE
   REPO="" #YOUR REPO HERE
   PR_NUMBER=1 # The PR number to review
   MONDAY_WORKSPACE="" #YOUR MONDAY WORKSPACE NAME HERE
   ```

4. **Make executable (Mac/Linux only)**
   
   ```bash
   chmod +x ~/mac-bob-scheduled-jobs/*.sh
   ```

### Exercise 3B — Test the Script Manually

1. **Run the script:**
   
   **Windows**
   ```powershell
   .\win-bob-scheduled-jobs\review_single_pr.ps1
   ```
   
   **MacOs**
   ```bash
   ~/mac-bob-scheduled-jobs/review_single_pr.sh
   ```

2. **Watch the output for the progress**

3. **Verify on Github.** Open your GitHub repository and check the PR comment. You should see a review comment posted by your account.

**What you learned:** The PR review script demonstrates non-interactive mode in a real automation workflow. Bob Shell does not open a session — it receives a task (the diff), reasons about it, and returns output that the script posts to GitHub.

### Exercise 3C — Schedule the Review Job

#### MacOS – Cron

Cron is the built-in job scheduler on macOS and Linux. It runs commands at specified intervals.

```bash
# Open crontab editor
crontab -e

# Add this line to run PR reviews every 2 hours, Mon–Fri, 9am–5pm
0 9-17/2 * * 1-5 /Users/yourusername/mac-bob-scheduled-jobs/review_prs.sh >> /Users/yourusername/mac-bob-scheduled-jobs/review.log 2>&1

# Save and exit (ESC, then :wq in vim)

# Verify the job is registered
crontab -l
```

#### Windows – Task Scheduler

1. Press Win + R, type `taskschd.msc`, press Enter
2. Click **Create Task** (not Create Basic Task)
3. Name the task **Bob PR Review Automation**
4. In the **General** tab:
   - Check **Run whether user is logged on or not**
   - (Optional) Check **Run with highest privileges**
5. **Triggers** tab → New → Weekly, repeat every 2 hours for 8 hours, Mon–Fri, starting 9:00 AM
6. **Actions** tab → New → Program: `powershell.exe`, Arguments: `-ExecutionPolicy Bypass -File "C:\...\review_prs.ps1"`
7. Save and right-click the task → **Run** to test

---

## Wrap-Up & Next Steps

### What You Built Today

| What | How |
|------|-----|
| Standup Report Generator | Bob Shell non-interactive mode + Monday.com MCP + cron / Task Scheduler |
| PR Review Automation | Bob Shell non-interactive mode + GitHub API + cron / Task Scheduler |

### Where to Go Next

- Try adding the GitHub MCP server to `.bob/mcp_settings.json` to let Bob interact with PRs directly
- Build a custom MCP server for an internal system your team uses
- Trigger the PR review script from a webhook or pipeline step instead of a cron job
- Chain multiple Bob Shell commands into a single automation script
