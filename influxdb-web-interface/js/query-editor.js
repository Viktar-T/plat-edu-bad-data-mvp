/**
 * Query Editor Module for InfluxDB 3.x
 * Provides SQL editor with syntax highlighting and auto-completion
 * Renewable Energy IoT Monitoring System
 */

class QueryEditor {
    constructor(containerId, options = {}) {
        this.containerId = containerId;
        this.container = document.getElementById(containerId);
        this.editor = null;
        this.options = {
            theme: 'default',
            lineNumbers: true,
            mode: 'sql',
            autoCloseBrackets: true,
            matchBrackets: true,
            indentWithTabs: false,
            indentUnit: 2,
            lineWrapping: false,
            extraKeys: {
                'Ctrl-Enter': () => this.executeQuery(),
                'Cmd-Enter': () => this.executeQuery(),
                'Ctrl-S': () => this.saveQuery(),
                'Cmd-S': () => this.saveQuery(),
                'Ctrl-Space': 'autocomplete'
            },
            hintOptions: {
                completeSingle: false,
                closeOnUnfocus: false
            },
            ...options
        };
        
        // Use relative URL to work with nginx proxy and avoid CORS
        this.influxUrl = window.location.protocol + '//' + window.location.host;
        this.currentDatabase = '';
        this.availableDatabases = [];
        this.availableMeasurements = {};
        this.completionCache = new Map();
        
        this.initializeEditor();
        this.loadCompletionData();
    }

    /**
     * Initialize the CodeMirror editor
     */
    async initializeEditor() {
        if (!this.container) {
            console.error('Query editor container not found');
            return;
        }

        // Check if CodeMirror is available
        if (typeof CodeMirror === 'undefined') {
            console.error('CodeMirror library not loaded');
            this.createFallbackEditor();
            return;
        }

        try {
            this.editor = CodeMirror(this.container, this.options);
            
            // Set up event listeners
            this.setupEventListeners();
            
            // Load saved query if exists
            this.loadSavedQuery();
            
            console.log('Query editor initialized successfully');
        } catch (error) {
            console.error('Error initializing CodeMirror:', error);
            this.createFallbackEditor();
        }
    }

    /**
     * Create fallback textarea editor if CodeMirror fails
     */
    createFallbackEditor() {
        this.container.innerHTML = `
            <div class="fallback-editor">
                <div class="editor-toolbar">
                    <button onclick="queryEditor.executeQuery()" class="btn btn-success">▶️ Execute Query</button>
                    <button onclick="queryEditor.formatQuery()" class="btn">🎨 Format</button>
                    <button onclick="queryEditor.saveQuery()" class="btn">💾 Save</button>
                </div>
                <textarea id="fallback-sql-editor" class="form-control" rows="10" placeholder="Enter your SQL query here..."></textarea>
            </div>
        `;
        
        this.editor = {
            getValue: () => document.getElementById('fallback-sql-editor').value,
            setValue: (value) => document.getElementById('fallback-sql-editor').value = value,
            focus: () => document.getElementById('fallback-sql-editor').focus(),
            getSelection: () => document.getElementById('fallback-sql-editor').selectionStart,
            replaceSelection: (text) => {
                const textarea = document.getElementById('fallback-sql-editor');
                const start = textarea.selectionStart;
                const end = textarea.selectionEnd;
                const value = textarea.value;
                textarea.value = value.substring(0, start) + text + value.substring(end);
            }
        };
    }

    /**
     * Setup event listeners for the editor
     */
    setupEventListeners() {
        if (!this.editor || !this.editor.on) return;

        // Auto-completion on Ctrl+Space
        this.editor.on('keyup', (cm, event) => {
            if (event.ctrlKey && event.code === 'Space') {
                this.showAutoCompletion();
            }
        });

        // Save query on change
        this.editor.on('change', () => {
            this.autoSaveQuery();
        });

        // Update line numbers and status
        this.editor.on('cursorActivity', () => {
            this.updateEditorStatus();
        });
    }

    /**
     * Load completion data from InfluxDB
     */
    async loadCompletionData() {
        try {
            // Load databases
            const dbResponse = await fetch(`${this.influxUrl}/api/v3/configure/database?format=json`);
            if (dbResponse.ok) {
                const data = await dbResponse.json();
                this.availableDatabases = data.databases || [];
                console.log('Loaded databases for completion:', this.availableDatabases);
            }
        } catch (error) {
            console.error('Error loading completion data:', error);
        }
    }

    /**
     * Load measurements for a specific database
     */
    async loadMeasurements(database) {
        if (this.availableMeasurements[database]) {
            return this.availableMeasurements[database];
        }

        try {
            const query = 'SHOW MEASUREMENTS';
            const encodedQuery = encodeURIComponent(query);
            const response = await fetch(`${this.influxUrl}/api/v3/query_sql?db=${encodeURIComponent(database)}&q=${encodedQuery}`);
            
            if (response.ok) {
                const resultText = await response.text();
                const measurements = this.parseMeasurements(resultText);
                this.availableMeasurements[database] = measurements;
                return measurements;
            }
        } catch (error) {
            console.error('Error loading measurements:', error);
        }
        
        return [];
    }

    /**
     * Parse measurements from SHOW MEASUREMENTS result
     */
    parseMeasurements(resultText) {
        try {
            const lines = resultText.split('\n').filter(line => line.trim());
            if (lines.length <= 1) return [];
            
            return lines.slice(1).map(line => {
                const parts = line.includes('\t') ? line.split('\t') : line.split(',');
                return parts[0].trim();
            }).filter(Boolean);
        } catch (error) {
            return [];
        }
    }

    /**
     * Show auto-completion suggestions
     */
    async showAutoCompletion() {
        if (!this.editor || !this.editor.showHint) return;

        const cursor = this.editor.getCursor();
        const line = this.editor.getLine(cursor.line);
        const currentWord = this.getCurrentWord(line, cursor.ch);
        
        const completions = await this.getCompletions(currentWord, line);
        
        if (completions.length > 0) {
            this.editor.showHint({
                hint: () => ({
                    list: completions,
                    from: this.editor.getCursor(),
                    to: this.editor.getCursor()
                })
            });
        }
    }

    /**
     * Get completion suggestions based on context
     */
    async getCompletions(currentWord, line) {
        const completions = [];
        const lowerLine = line.toLowerCase();
        const lowerWord = currentWord.toLowerCase();

        // SQL keywords
        const sqlKeywords = [
            'SELECT', 'FROM', 'WHERE', 'ORDER BY', 'GROUP BY', 'HAVING', 'LIMIT',
            'INSERT', 'UPDATE', 'DELETE', 'CREATE', 'DROP', 'ALTER', 'INDEX',
            'DISTINCT', 'COUNT', 'SUM', 'AVG', 'MIN', 'MAX', 'AS', 'AND', 'OR',
            'NOT', 'NULL', 'TRUE', 'FALSE', 'LIKE', 'IN', 'BETWEEN', 'EXISTS',
            'SHOW DATABASES', 'SHOW MEASUREMENTS', 'SHOW FIELD KEYS', 'SHOW TAG KEYS'
        ];

        // Add SQL keywords
        sqlKeywords.forEach(keyword => {
            if (keyword.toLowerCase().startsWith(lowerWord)) {
                completions.push({
                    text: keyword,
                    displayText: keyword,
                    className: 'cm-keyword'
                });
            }
        });

        // Add databases
        if (lowerLine.includes('from') || lowerLine.includes('database')) {
            this.availableDatabases.forEach(db => {
                if (db.toLowerCase().startsWith(lowerWord)) {
                    completions.push({
                        text: db,
                        displayText: `📁 ${db}`,
                        className: 'cm-database'
                    });
                }
            });
        }

        // Add measurements if we have a database context
        if (this.currentDatabase && (lowerLine.includes('from') || lowerLine.includes('select'))) {
            const measurements = await this.loadMeasurements(this.currentDatabase);
            measurements.forEach(measurement => {
                if (measurement.toLowerCase().startsWith(lowerWord)) {
                    completions.push({
                        text: measurement,
                        displayText: `📊 ${measurement}`,
                        className: 'cm-measurement'
                    });
                }
            });
        }

        // Common InfluxDB functions
        const influxFunctions = [
            'COUNT(*)', 'SUM()', 'AVG()', 'MIN()', 'MAX()', 'FIRST()', 'LAST()',
            'MEAN()', 'MEDIAN()', 'STDDEV()', 'now()', 'time'
        ];
        
        influxFunctions.forEach(func => {
            if (func.toLowerCase().startsWith(lowerWord)) {
                completions.push({
                    text: func,
                    displayText: `⚡ ${func}`,
                    className: 'cm-function'
                });
            }
        });

        return completions.slice(0, 20); // Limit to 20 suggestions
    }

    /**
     * Get current word at cursor position
     */
    getCurrentWord(line, ch) {
        let start = ch;
        let end = ch;
        
        // Find word boundaries
        while (start > 0 && /\w/.test(line[start - 1])) {
            start--;
        }
        while (end < line.length && /\w/.test(line[end])) {
            end++;
        }
        
        return line.substring(start, end);
    }

    /**
     * Execute the current query
     */
    async executeQuery() {
        const query = this.getValue().trim();
        if (!query) {
            this.showMessage('Please enter a query to execute', 'warning');
            return;
        }

        if (window.queryExecutor) {
            await window.queryExecutor.executeQuery(query, this.currentDatabase);
        } else {
            this.showMessage('Query executor not available', 'error');
        }
    }

    /**
     * Format the SQL query
     */
    formatQuery() {
        const query = this.getValue();
        if (!query.trim()) return;

        try {
            const formatted = this.basicSQLFormat(query);
            this.setValue(formatted);
            this.showMessage('Query formatted successfully', 'success');
        } catch (error) {
            this.showMessage('Error formatting query', 'error');
        }
    }

    /**
     * Basic SQL formatting
     */
    basicSQLFormat(sql) {
        // Simple SQL formatting - can be enhanced with a proper SQL formatter library
        return sql
            .replace(/\s+/g, ' ')
            .replace(/\s*,\s*/g, ',\n    ')
            .replace(/\s+(SELECT|FROM|WHERE|GROUP BY|ORDER BY|HAVING|LIMIT)/gi, '\n$1')
            .replace(/\s+(AND|OR)\s+/gi, '\n    $1 ')
            .replace(/^\s+/gm, '')
            .trim();
    }

    /**
     * Save current query
     */
    saveQuery() {
        const query = this.getValue().trim();
        if (!query) return;

        if (window.queryHistory) {
            const queryName = prompt('Enter a name for this query:') || `Query ${Date.now()}`;
            window.queryHistory.saveQuery(queryName, query, this.currentDatabase);
            this.showMessage('Query saved successfully', 'success');
        }
    }

    /**
     * Auto-save query to localStorage
     */
    autoSaveQuery() {
        const query = this.getValue();
        try {
            localStorage.setItem('influx_current_query', query);
        } catch (error) {
            console.error('Error auto-saving query:', error);
        }
    }

    /**
     * Load saved query from localStorage
     */
    loadSavedQuery() {
        try {
            const savedQuery = localStorage.getItem('influx_current_query');
            if (savedQuery) {
                this.setValue(savedQuery);
            }
        } catch (error) {
            console.error('Error loading saved query:', error);
        }
    }

    /**
     * Update editor status (line numbers, etc.)
     */
    updateEditorStatus() {
        if (!this.editor || !this.editor.getCursor) return;

        const cursor = this.editor.getCursor();
        const statusElement = document.getElementById('editor-status');
        if (statusElement) {
            statusElement.textContent = `Line ${cursor.line + 1}, Column ${cursor.ch + 1}`;
        }
    }

    /**
     * Set database context for auto-completion
     */
    setDatabase(database) {
        this.currentDatabase = database;
        // Pre-load measurements for this database
        this.loadMeasurements(database);
    }

    /**
     * Get current query text
     */
    getValue() {
        return this.editor ? this.editor.getValue() : '';
    }

    /**
     * Set query text
     */
    setValue(value) {
        if (this.editor) {
            this.editor.setValue(value);
        }
    }

    /**
     * Focus the editor
     */
    focus() {
        if (this.editor && this.editor.focus) {
            this.editor.focus();
        }
    }

    /**
     * Clear the editor
     */
    clear() {
        this.setValue('');
    }

    /**
     * Insert text at cursor position
     */
    insertText(text) {
        if (this.editor && this.editor.replaceSelection) {
            this.editor.replaceSelection(text);
            this.focus();
        }
    }

    /**
     * Show message to user
     */
    showMessage(message, type = 'info') {
        // Create or update message element
        let messageElement = document.getElementById('editor-message');
        if (!messageElement) {
            messageElement = document.createElement('div');
            messageElement.id = 'editor-message';
            messageElement.className = 'editor-message';
            this.container.parentNode.insertBefore(messageElement, this.container);
        }

        messageElement.className = `editor-message ${type}`;
        messageElement.textContent = message;
        messageElement.style.display = 'block';

        // Auto-hide after 3 seconds
        setTimeout(() => {
            messageElement.style.display = 'none';
        }, 3000);
    }

    /**
     * Get editor instance for external access
     */
    getEditor() {
        return this.editor;
    }

    /**
     * Destroy the editor
     */
    destroy() {
        if (this.editor && this.editor.toTextArea) {
            this.editor.toTextArea();
        }
        this.editor = null;
    }
}

// Export for use in other modules
if (typeof module !== 'undefined' && module.exports) {
    module.exports = QueryEditor;
} else if (typeof window !== 'undefined') {
    window.QueryEditor = QueryEditor;
} 