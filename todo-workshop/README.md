# To-Do List Web App

A simple, accessible, and elegant to-do list application built with vanilla JavaScript and styled using IBM Carbon Design System principles.

![IBM Carbon Design System](https://img.shields.io/badge/Design-IBM%20Carbon-0f62fe)
![HTML5](https://img.shields.io/badge/HTML5-E34F26?logo=html5&logoColor=white)
![CSS3](https://img.shields.io/badge/CSS3-1572B6?logo=css3&logoColor=white)
![JavaScript](https://img.shields.io/badge/JavaScript-F7DF1E?logo=javascript&logoColor=black)

## 📋 Description

A lightweight, browser-based to-do list application that helps you organize your tasks efficiently. Built with modern web standards and accessibility in mind, this app provides a clean, professional interface for managing your daily tasks with persistent storage.

## ✨ Features

### Core Functionality
- ✅ **Add Tasks** - Quickly add new tasks with a simple input field
- ✅ **Complete Tasks** - Mark tasks as complete with a checkbox
- ✅ **Delete Tasks** - Remove tasks you no longer need
- 💾 **Persistent Storage** - Tasks are automatically saved to localStorage
- 🔄 **Auto-Save** - Changes are saved instantly without manual intervention

### User Experience
- 🎨 **IBM Carbon Design System** - Professional, enterprise-grade styling
- 📱 **Responsive Design** - Works seamlessly on desktop, tablet, and mobile
- ⚡ **Real-time Feedback** - Toast notifications for user actions
- 🎯 **Empty State** - Helpful message when no tasks exist
- ✏️ **Input Validation** - Prevents empty, duplicate, and overly long tasks

### Accessibility
- ♿ **WCAG 2.1 Compliant** - Meets accessibility standards
- ⌨️ **Keyboard Navigation** - Full keyboard support (Tab, Enter, Delete)
- 🔊 **Screen Reader Support** - ARIA labels and live regions
- 👁️ **Focus Indicators** - Clear visual focus states
- 🎯 **Semantic HTML** - Proper HTML5 structure

### Security
- 🛡️ **XSS Prevention** - Input sanitization to prevent cross-site scripting
- ✅ **Input Validation** - Maximum length enforcement (500 characters)
- 🚫 **Duplicate Detection** - Prevents adding identical tasks

## 🚀 Technologies Used

- **HTML5** - Semantic markup with accessibility attributes
- **CSS3** - Modern styling with CSS variables and animations
- **JavaScript (ES6+)** - Vanilla JavaScript with modern features
- **IBM Plex Sans** - Professional typography from IBM's design system
- **localStorage API** - Browser-based persistent storage

## 🎨 Design System

This application follows the **IBM Carbon Design System** principles:

- **Flat Corners** - All elements use 0px border radius for a clean, professional look
- **IBM Blue (#0f62fe)** - Single accent color for consistency
- **IBM Plex Sans** - Typography at weight 300 for display, 400 for body
- **Precise Spacing** - 4px base unit with consistent spacing tokens
- **Minimal Shadows** - Depth through surface changes and hairline borders
- **High Contrast** - Charcoal text (#161616) on white canvas (#ffffff)

## 📦 Getting Started

### Prerequisites

- A modern web browser (Chrome, Firefox, Safari, Edge)
- No server or build tools required!

### Installation

1. **Clone or download** this repository:
   ```bash
   git clone https://github.com/yourusername/todo-list-app.git
   ```

2. **Navigate** to the project directory:
   ```bash
   cd todo-list-app
   ```

3. **Open** `index.html` in your web browser:
   - Double-click the file, or
   - Right-click and select "Open with" your browser, or
   - Use a local server (optional):
     ```bash
     # Python 3
     python -m http.server 8000
     
     # Node.js (with http-server)
     npx http-server
     ```

4. **Start using** the app immediately!

### Usage

1. **Add a Task**
   - Type your task in the input field
   - Press Enter or click the "Add" button
   - Task appears in the list below

2. **Complete a Task**
   - Click the checkbox next to a task
   - Task text becomes strikethrough
   - Status is saved automatically

3. **Delete a Task**
   - Click the × button on the right side of a task
   - Task is removed from the list
   - Change is saved automatically

4. **Keyboard Shortcuts**
   - `Tab` - Navigate between elements
   - `Enter` - Add task (when input is focused)
   - `Space` - Toggle checkbox (when focused)
   - `Delete` - Remove task (when task item is focused)

## 📁 Project Structure

```
todo-list-app/
├── index.html          # Main HTML structure with semantic markup
├── styles.css          # IBM Carbon Design System styling
├── script.js           # Application logic and localStorage handling
├── DESIGN.md           # Detailed design system documentation
├── IMPROVEMENT_PLAN.md # Future enhancements and roadmap
└── README.md           # This file
```

### File Descriptions

- **index.html** - Contains the semantic HTML structure with proper ARIA labels, meta tags, and accessibility attributes
- **styles.css** - Implements IBM Carbon Design System with CSS variables, responsive breakpoints, and animations
- **script.js** - Handles all application logic including task management, validation, localStorage persistence, and accessibility features
- **DESIGN.md** - Comprehensive documentation of the IBM Carbon Design System implementation
- **IMPROVEMENT_PLAN.md** - Detailed plan for future enhancements categorized by priority

## ♿ Accessibility Features

This application is built with accessibility as a core principle:

### WCAG 2.1 Compliance
- ✅ **Level AA** color contrast ratios
- ✅ Keyboard-only navigation support
- ✅ Screen reader compatibility
- ✅ Focus management and indicators

### Semantic HTML
- Proper use of `<main>`, `<section>`, `<header>` elements
- ARIA roles and labels on interactive elements
- Live regions for dynamic content announcements

### Keyboard Support
- Full keyboard navigation with Tab key
- Enter key to submit tasks
- Space to toggle checkboxes
- Delete key to remove tasks
- Visible focus indicators on all interactive elements

### Screen Reader Support
- Descriptive ARIA labels on all controls
- Live region announcements for task changes
- Proper heading hierarchy
- Alternative text for visual elements

## 🌐 Browser Compatibility

Tested and working on:

- ✅ **Chrome** 90+ (Desktop & Mobile)
- ✅ **Firefox** 88+ (Desktop & Mobile)
- ✅ **Safari** 14+ (Desktop & Mobile)
- ✅ **Edge** 90+ (Desktop)
- ✅ **Opera** 76+ (Desktop)

### Required Browser Features
- ES6+ JavaScript support
- CSS Grid and Flexbox
- localStorage API
- CSS Custom Properties (variables)

## 🔒 Privacy & Data

- **All data is stored locally** in your browser's localStorage
- **No server communication** - your tasks never leave your device
- **No tracking or analytics** - completely private
- **Clear data** by clearing your browser's localStorage or cache

## 🚧 Future Enhancements

See [IMPROVEMENT_PLAN.md](IMPROVEMENT_PLAN.md) for a comprehensive list of planned features:

### Medium Priority
- Task filtering (All, Active, Completed)
- Task sorting options
- Data export/import (JSON format)
- Task editing capability
- Undo/redo functionality

### Low Priority
- Task categories and tags
- Due dates and reminders
- Task priority levels
- Dark mode support
- Multi-language support

## 🤝 Contributing

Contributions are welcome! Here's how you can help:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

Please ensure your code:
- Follows the existing code style
- Maintains IBM Carbon Design System principles
- Includes proper accessibility features
- Is well-documented with comments

## 📝 License

This project is licensed under the MIT License - see below for details:

```
MIT License

Copyright (c) 2026 [Your Name]

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
```

## 🙏 Acknowledgments

- **IBM Carbon Design System** - For the excellent design system and guidelines
- **IBM Plex Sans** - For the beautiful open-source typeface
- **Web Accessibility Initiative (WAI)** - For WCAG guidelines and best practices

## 📧 Contact

For questions, suggestions, or issues:
- Open an issue on GitHub
- Email: your.email@example.com

---

**Made with ❤️ and IBM Carbon Design System**