// To-Do List Application - JavaScript
// IBM Carbon Design System Implementation

// DOM Elements
const todoInput = document.getElementById('todoInput');
const addBtn = document.getElementById('addBtn');
const todoList = document.getElementById('todoList');
const announcements = document.getElementById('announcements');

// Constants
const MAX_TODO_LENGTH = 500;
const NOTIFICATION_DURATION = 3000;

// Initialize todos array from localStorage with error handling
let todos = [];
try {
    const storedTodos = localStorage.getItem('todos');
    todos = storedTodos ? JSON.parse(storedTodos) : [];
} catch (error) {
    console.error('Error loading todos from localStorage:', error);
    showNotification('Failed to load saved tasks', 'error');
    todos = [];
}

// Initialize the app
document.addEventListener('DOMContentLoaded', () => {
    renderTodos();

    // Event Listeners
    addBtn.addEventListener('click', addTodo);
    todoInput.addEventListener('keypress', (e) => {
        if (e.key === 'Enter') {
            addTodo();
        }
    });

    // Keyboard shortcuts for todo list
    todoList.addEventListener('keydown', (e) => {
        if (e.key === 'Delete' && e.target.classList.contains('todo-item')) {
            const id = parseInt(e.target.dataset.id);
            deleteTodo(id);
        }
    });
});

// Add a new todo with validation and error handling
function addTodo() {
    const text = todoInput.value.trim();

    // Remove error state
    todoInput.classList.remove('error');

    // Validation: Empty input
    if (text === '') {
        showNotification('Please enter a task', 'error');
        todoInput.classList.add('error');
        todoInput.focus();
        return;
    }

    // Validation: Max length
    if (text.length > MAX_TODO_LENGTH) {
        showNotification(`Task is too long (max ${MAX_TODO_LENGTH} characters)`, 'error');
        todoInput.classList.add('error');
        todoInput.focus();
        return;
    }

    // Validation: Check for duplicates
    const isDuplicate = todos.some(todo =>
        todo.text.toLowerCase() === text.toLowerCase()
    );
    if (isDuplicate) {
        showNotification('This task already exists', 'error');
        todoInput.classList.add('error');
        todoInput.focus();
        return;
    }

    // Sanitize input to prevent XSS
    const sanitizedText = sanitizeInput(text);

    const todo = {
        id: Date.now(),
        text: sanitizedText,
        completed: false
    };

    todos.push(todo);
    saveTodos();
    renderTodos();

    // Show success message
    showNotification('Task added successfully', 'success');
    announce(`Task added: ${sanitizedText}`);

    // Clear input and focus
    todoInput.value = '';
    todoInput.focus();
}

// Toggle todo completion status with feedback
function toggleTodo(id) {
    const todo = todos.find(t => t.id === id);
    if (!todo) return;

    todos = todos.map(t =>
        t.id === id ? { ...t, completed: !t.completed } : t
    );
    saveTodos();
    renderTodos();

    // Announce status change
    const status = todo.completed ? 'incomplete' : 'complete';
    announce(`Task marked as ${status}: ${todo.text}`);

    // Maintain focus on the toggled item
    setTimeout(() => {
        const toggledItem = document.querySelector(`[data-id="${id}"]`);
        if (toggledItem) {
            const checkbox = toggledItem.querySelector('.checkbox');
            if (checkbox) checkbox.focus();
        }
    }, 0);
}

// Delete a todo with feedback and focus management
function deleteTodo(id) {
    const todo = todos.find(t => t.id === id);
    if (!todo) return;

    // Find the next focusable element before deletion
    const currentItem = document.querySelector(`[data-id="${id}"]`);
    const nextItem = currentItem?.nextElementSibling;
    const prevItem = currentItem?.previousElementSibling;

    todos = todos.filter(t => t.id !== id);
    saveTodos();
    renderTodos();

    // Show success message
    showNotification('Task deleted', 'success');
    announce(`Task deleted: ${todo.text}`);

    // Restore focus to next or previous item, or input if list is empty
    setTimeout(() => {
        if (todos.length === 0) {
            todoInput.focus();
        } else if (nextItem && nextItem.dataset.id) {
            const nextElement = document.querySelector(`[data-id="${nextItem.dataset.id}"]`);
            if (nextElement) nextElement.querySelector('.checkbox')?.focus();
        } else if (prevItem && prevItem.dataset.id) {
            const prevElement = document.querySelector(`[data-id="${prevItem.dataset.id}"]`);
            if (prevElement) prevElement.querySelector('.checkbox')?.focus();
        } else {
            todoInput.focus();
        }
    }, 0);
}

// Save todos to localStorage with error handling
function saveTodos() {
    try {
        localStorage.setItem('todos', JSON.stringify(todos));
    } catch (error) {
        console.error('Error saving todos to localStorage:', error);

        // Handle quota exceeded error
        if (error.name === 'QuotaExceededError') {
            showNotification('Storage quota exceeded. Please delete some tasks.', 'error');
        } else {
            showNotification('Failed to save tasks. Changes may not persist.', 'error');
        }
    }
}

// Render todos to the DOM with improved accessibility
function renderTodos() {
    // Clear the list
    todoList.innerHTML = '';

    // If no todos, show empty state
    if (todos.length === 0) {
        const emptyState = document.createElement('li');
        emptyState.className = 'empty-state';
        emptyState.textContent = 'No tasks yet. Add one above to get started!';
        emptyState.setAttribute('role', 'status');
        todoList.appendChild(emptyState);
        return;
    }

    // Render each todo
    todos.forEach((todo, index) => {
        const li = document.createElement('li');
        li.className = 'todo-item';
        if (todo.completed) {
            li.classList.add('completed');
        }
        li.dataset.id = todo.id;
        li.setAttribute('role', 'listitem');
        li.setAttribute('tabindex', '0');

        // Checkbox with proper ARIA label
        const checkbox = document.createElement('input');
        checkbox.type = 'checkbox';
        checkbox.className = 'checkbox';
        checkbox.id = `todo-${todo.id}`;
        checkbox.checked = todo.completed;
        checkbox.setAttribute('aria-label', `Mark task as ${todo.completed ? 'incomplete' : 'complete'}: ${todo.text}`);
        checkbox.addEventListener('change', () => toggleTodo(todo.id));

        // Todo text as label
        const label = document.createElement('label');
        label.className = 'todo-text';
        label.htmlFor = `todo-${todo.id}`;
        label.textContent = todo.text;

        // Delete button with descriptive aria-label
        const deleteBtn = document.createElement('button');
        deleteBtn.className = 'delete-btn';
        deleteBtn.innerHTML = '×';
        deleteBtn.setAttribute('aria-label', `Delete task: ${todo.text}`);
        deleteBtn.addEventListener('click', () => deleteTodo(todo.id));

        // Append elements
        li.appendChild(checkbox);
        li.appendChild(label);
        li.appendChild(deleteBtn);
        todoList.appendChild(li);
    });
}

// Helper function to sanitize input and prevent XSS
function sanitizeInput(input) {
    const div = document.createElement('div');
    div.textContent = input;
    return div.innerHTML;
}

// Helper function to show notification messages
function showNotification(message, type = 'success') {
    // Remove any existing notifications
    const existingNotification = document.querySelector('.notification');
    if (existingNotification) {
        existingNotification.remove();
    }

    // Create notification element
    const notification = document.createElement('div');
    notification.className = `notification ${type}`;
    notification.textContent = message;
    notification.setAttribute('role', 'alert');
    notification.setAttribute('aria-live', 'assertive');

    // Add to DOM
    document.body.appendChild(notification);

    // Auto-remove after duration
    setTimeout(() => {
        notification.classList.add('hiding');
        setTimeout(() => {
            notification.remove();
        }, 300);
    }, NOTIFICATION_DURATION);
}

// Helper function to announce to screen readers
function announce(message) {
    if (announcements) {
        announcements.textContent = message;
        // Clear after a short delay to allow for multiple announcements
        setTimeout(() => {
            announcements.textContent = '';
        }, 1000);
    }
}

// Made with Bob
