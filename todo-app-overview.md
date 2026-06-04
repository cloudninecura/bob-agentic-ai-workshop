# To-Do List Web App — Project Overview

## What We Built

A lightweight, browser-based To-Do List app built with plain HTML, CSS, and JavaScript — no frameworks, no build tools, no dependencies. The app runs entirely in the browser by opening `index.html` directly — no server, no installation, no configuration required.

The goal was to build something functional end-to-end: a real interface, real interactivity, and real code — while keeping the scope small enough that every decision is visible and understandable. The result is a three-file project that covers the full spectrum of front-end fundamentals: structure, style, and behavior. The design follows **IBM Carbon Design System** principles, giving it a clean, professional, enterprise-grade aesthetic.

---

## The Problem It Solves

Most task management tools are over-engineered for simple use cases. They require accounts, internet access, onboarding flows, and ongoing maintenance. For a developer who just needs to track what they are working on right now, that overhead is friction.

This app strips everything back to the essentials. No login. No sync. No notifications. Just a list of things to do, with the ability to mark them done and remove them when finished — and tasks persist across sessions so nothing is lost on a page refresh. It is the kind of tool that gets out of your way — and building it from scratch makes every part of how it works completely transparent.

---

## Features

### Add a Task
Type any text into the input field and click the **Add** button — or press **Enter** — to append a new item to the list. The input clears automatically after each addition. Empty submissions, duplicates, and inputs exceeding 500 characters are rejected, keeping the list clean and valid. Input is also sanitized to prevent cross-site scripting (XSS).

### Complete a Task
Each task item has a checkbox. Clicking it toggles the task's completion state. A completed task displays with a strikethrough style, giving a clear visual indication that it is done without removing it from view. Clicking again un-completes it, in case something was marked done by mistake.

### Delete a Task
Every task item includes a small **×** button on the right side. Clicking it removes that item from the list immediately. Deletions are permanent within the session — there is no undo — which keeps the logic simple and the interface uncluttered.

### Persistent Storage
Tasks are automatically saved to the browser's `localStorage` and restored on page load. The list survives tab closes, refreshes, and browser restarts without any manual save action. All data remains local to the device — nothing is sent to a server.

### Real-Time Feedback
Toast notifications appear briefly after user actions (adding, completing, deleting), confirming what just happened without interrupting the workflow.

### Empty State
When no tasks exist, a helpful message is displayed in place of an empty list — a small but important detail that makes the app feel considered rather than broken.

### Accessible, Keyboard-Friendly Interface
The app is built to WCAG 2.1 Level AA standards. Every interactive element is reachable and operable by keyboard alone, with visible focus indicators throughout. Screen readers are supported via ARIA labels and live regions that announce task changes. Key shortcuts include `Tab` to navigate, `Enter` to add a task, `Space` to toggle a checkbox, and `Delete` to remove a focused task.

### Responsive Design
The layout adapts cleanly to desktop, tablet, and mobile screen sizes using CSS Flexbox and responsive breakpoints.

---

## Technical Decisions

### No Frameworks
The app uses no libraries or frameworks — no React, no Vue, no jQuery. This was a deliberate choice to keep the code readable for anyone with basic web knowledge and to avoid any dependency installation or build step. The browser is the runtime, and the files are the app.

### localStorage Persistence
Tasks are saved to `localStorage` on every change and loaded on startup. This gives the app durable state without a backend, keeping the scope focused while still solving the most common real-world pain point: losing your list when you close the tab.

### Input Validation and XSS Prevention
Rather than accepting any input blindly, the app validates length, rejects duplicates, and sanitizes text before inserting it into the DOM. This keeps the list clean and prevents a class of security issues that even simple apps should handle.

### Event Delegation
Rather than attaching individual click listeners to each task item as they are created, a single listener on the parent `<ul>` handles all clicks. This is more efficient and avoids memory leaks from listeners on elements that get removed from the DOM.

### CSS Classes for State
Completion state is managed entirely through a CSS class. JavaScript adds or removes `.done` from a list item; CSS handles the visual result. This keeps styling decisions in the stylesheet where they belong and keeps JavaScript focused on behavior.

### Accessibility as a Core Principle
WCAG 2.1 compliance was built in from the start rather than added afterward. Semantic HTML, ARIA attributes, keyboard support, and live regions are part of the initial implementation — not optional enhancements.

### Separation of Concerns
Each file has one job. HTML defines structure, CSS defines appearance, JavaScript defines behavior. Nothing bleeds between files except the class names and element IDs that connect them. This makes the project easy to read, easy to modify, and easy to extend.

---

## How It Was Built — Bob IDE Modes

The app was built incrementally using all five Bob IDE modes, each playing a distinct role in the development process.

### Ask Mode — Research and Exploration
Before writing a single line of code, Ask Mode was used to explore the problem. Prompts like *"What files do I need to build a simple To-Do List web app?"* and *"What should go inside the HTML file?"* produced clear explanations of the structure without touching the file system. Ask Mode acts like a senior developer you can question freely — it reads and explains but never writes.

### Plan Mode — Architecture Before Implementation
Plan Mode produced a structured markdown document laying out the file structure, the features to build, and the order in which to build them. This created a shared blueprint for the rest of the session and prevented the common mistake of jumping into implementation before the approach is clear. The output of Plan Mode was a plan to be reviewed and approved, not code to be accepted blindly.

### Code Mode — Targeted File Creation
Code Mode was used to create `index.html` and `styles.css`. Each prompt was scoped to a specific file and a specific outcome — *"Create a basic To-Do List HTML page with a title, input, button, and empty list"* — and the result was reviewed and accepted before moving on. Code Mode is precise and surgical: it changes what you ask it to change and nothing else.

### Advanced Mode — End-to-End Integration
Advanced Mode took over for the most complex step: creating `script.js` with full task logic, localStorage persistence, and accessibility features, then linking it to `index.html` automatically. Rather than stepping through each sub-task manually, a single high-level prompt described the complete goal and Advanced Mode read files, wrote code, and wired everything together. The result was reviewed as a summary of changes before being accepted.

### Orchestrator Mode — Review and Refactor
With the app working, Orchestrator Mode was given a broad instruction: review the whole project, identify improvements, plan changes, implement them, and verify the app still works. It broke this into subtasks and delegated each one to the appropriate mode automatically — switching between Plan, Code, and Advanced as needed. The developer reviewed the final result and accepted or rejected individual changes.

---

## What This Demonstrates

The To-Do app is a microcosm of how real software projects are built. The same phases — research, planning, implementation, integration, review — apply whether the project is three files or three hundred. Keeping the app simple makes each phase visible and comprehensible in a way that a larger project would not.

It also demonstrates that agentic AI is not about replacing developer judgment. At every step, the developer reviewed what Bob produced and decided whether to accept it. The AI accelerated execution; the developer directed it.

Key concepts illustrated by this project:

- **Incremental development** — building and verifying one piece at a time
- **Separation of concerns** — each file has a single, clear responsibility
- **Event-driven programming** — the app responds to user actions rather than running a loop
- **Accessible design** — WCAG 2.1 compliance built in from the start, not bolted on after
- **Agentic workflow** — different AI modes for different types of work, coordinated by the developer

---

## Extending the App

The current app is intentionally scoped, with a clear roadmap for further development:

**Medium Priority**
- **Task filtering** — toggle views between All, Active, and Completed tasks.
- **Task sorting** — reorder by date added, alphabetical, or completion status.
- **Data export/import** — serialize the task list to JSON for backup or transfer between devices.
- **Task editing** — allow users to click a task text to edit it in place, rather than deleting and re-adding.
- **Undo/redo** — recover from accidental deletions or completions.

**Lower Priority**
- **Categories and tags** — group tasks by project, priority, or context with filterable labels.
- **Due dates** — add a date picker to each task and apply visual indicators for overdue items.
- **Drag-to-reorder** — implement drag-and-drop reordering using the HTML5 Drag and Drop API.
- **Dark mode** — a dark theme variant following Carbon Design System tokens.
- **Export to a project board** — connect to a project management tool via MCP to push tasks directly to a shared team board, turning a personal list into a collaborative workflow.

---

## Outcome

The finished app is a fully functional, browser-native task manager styled with IBM Carbon Design System principles. It runs without a server, installs nothing, persists tasks across sessions via `localStorage`, and is readable by any developer with front-end experience. It meets WCAG 2.1 Level AA accessibility standards and works across all modern browsers on desktop and mobile.

More importantly, it was built through a structured, agentic workflow where each mode contributed something distinct — and where the developer remained in control of every decision from start to finish.
