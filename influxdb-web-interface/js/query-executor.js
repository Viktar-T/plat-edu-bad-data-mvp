/**
 * Query Executor Module for InfluxDB 3.x
 * Handles query execution, results display, and export functionality
 * Renewable Energy IoT Monitoring System
 */

class QueryExecutor {
    constructor() {
        // Use relative URL to work with nginx proxy and avoid CORS
        this.influxUrl = window.location.protocol + '//' + window.location.host;
        this.currentQuery = null;
        this.currentDatabase = null;
        this.currentResults = null;
        this.executionStartTime = null;
        this.currentPage = 1;
        this.pageSize = 100;
        this.totalRows = 0;
        this.abortController = null;
        
        this.initializeExecutor();
    }

    /**
     * Initialize the query executor
     */
    initializeExecutor() {
        this.setupResultsContainer();
        this.setupEventListeners();
    }

    /**
     * Setup results container if not exists
     */
    setupResultsContainer() {
        let resultsContainer = document.getElementById('query-results-container');
        if (!resultsContainer) {
            // Create results container dynamically if needed
            const querySection = document.getElementById('query');
            if (querySection) {
                resultsContainer = document.createElement('div');
                resultsContainer.id = 'query-results-container';
                resultsContainer.innerHTML = `
                    <div class="results-header">
                        <div class="results-controls">
                            <span id="query-execution-info" class="execution-info"></span>
                            <div class="results-actions">
                                <button id="export-csv-btn" class="btn btn-small" disabled>📄 Export CSV</button>
                                <button id="export-json-btn" class="btn btn-small" disabled>📋 Export JSON</button>
                                <button id="cancel-query-btn" class="btn btn-small btn-danger" disabled>❌ Cancel</button>
                            </div>
                        </div>
                    </div>
                    <div id="query-results" class="query-results"></div>
                    <div id="results-pagination" class="results-pagination"></div>
                `;
                querySection.appendChild(resultsContainer);
            }
        }
    }

    /**
     * Setup event listeners
     */
    setupEventListeners() {
        // Export buttons
        const exportCsvBtn = document.getElementById('export-csv-btn');
        if (exportCsvBtn) {
            exportCsvBtn.addEventListener('click', () => this.exportResults('csv'));
        }

        const exportJsonBtn = document.getElementById('export-json-btn');
        if (exportJsonBtn) {
            exportJsonBtn.addEventListener('click', () => this.exportResults('json'));
        }

        // Cancel button
        const cancelBtn = document.getElementById('cancel-query-btn');
        if (cancelBtn) {
            cancelBtn.addEventListener('click', () => this.cancelQuery());
        }
    }

    /**
     * Execute a SQL query
     */
    async executeQuery(query, database = '') {
        if (!query || !query.trim()) {
            this.showError('Please enter a query to execute');
            return;
        }

        // Store current query info
        this.currentQuery = query.trim();
        this.currentDatabase = database;
        this.executionStartTime = Date.now();
        this.currentPage = 1;

        // Setup abort controller for cancellation
        this.abortController = new AbortController();

        try {
            // Show loading state
            this.showLoading('Executing query...');
            this.enableCancelButton(true);

            // Add query to history
            if (window.queryHistory) {
                window.queryHistory.addToHistory(this.currentQuery, this.currentDatabase);
            }

            // Execute the query
            const result = await this.executeHTTPQuery(this.currentQuery, this.currentDatabase);
            
            // Process and display results
            await this.processResults(result);

        } catch (error) {
            if (error.name === 'AbortError') {
                this.showInfo('Query was cancelled');
            } else {
                this.showError(`Query execution failed: ${error.message}`);
            }
        } finally {
            this.enableCancelButton(false);
            this.abortController = null;
        }
    }

    /**
     * Execute HTTP query against InfluxDB
     */
    async executeHTTPQuery(query, database) {
        const encodedQuery = encodeURIComponent(query);
        let url = `${this.influxUrl}/api/v3/query_sql?q=${encodedQuery}`;
        
        if (database && database.trim()) {
            url += `&db=${encodeURIComponent(database)}`;
        }

        console.log('Executing query:', query);
        console.log('URL:', url);

        const response = await fetch(url, {
            method: 'GET',
            signal: this.abortController.signal,
            headers: {
                'Accept': 'text/plain'
            }
        });

        if (!response.ok) {
            const errorText = await response.text();
            throw new Error(`HTTP ${response.status}: ${errorText}`);
        }

        const resultText = await response.text();
        console.log('Query result:', resultText);

        return resultText;
    }

    /**
     * Process query results
     */
    async processResults(resultText) {
        const executionTime = Date.now() - this.executionStartTime;
        
        try {
            // Parse the results
            const parsedResults = this.parseResults(resultText);
            this.currentResults = parsedResults;
            
            // Update execution info
            this.updateExecutionInfo(executionTime, parsedResults.totalRows);
            
            // Display results
            this.displayResults(parsedResults);
            
            // Enable export buttons
            this.enableExportButtons(true);
            
        } catch (error) {
            console.error('Error processing results:', error);
            this.showError(`Error processing results: ${error.message}`);
        }
    }

    /**
     * Parse query results from text format
     */
    parseResults(resultText) {
        if (!resultText || !resultText.trim()) {
            return {
                headers: [],
                rows: [],
                totalRows: 0,
                isEmpty: true
            };
        }

        const lines = resultText.split('\n').filter(line => line.trim());
        
        if (lines.length === 0) {
            return {
                headers: [],
                rows: [],
                totalRows: 0,
                isEmpty: true
            };
        }

        // First line contains headers
        const headers = lines[0].split('\t').map(h => h.trim());
        
        // Remaining lines contain data
        const rows = [];
        for (let i = 1; i < lines.length; i++) {
            const line = lines[i].trim();
            if (line) {
                const columns = line.split('\t');
                const row = {};
                headers.forEach((header, index) => {
                    row[header] = columns[index] ? columns[index].trim() : '';
                });
                rows.push(row);
            }
        }

        return {
            headers: headers,
            rows: rows,
            totalRows: rows.length,
            isEmpty: rows.length === 0
        };
    }

    /**
     * Display query results in table format
     */
    displayResults(results) {
        const resultsContainer = document.getElementById('query-results');
        if (!resultsContainer) return;

        if (results.isEmpty) {
            resultsContainer.innerHTML = `
                <div class="results-empty">
                    <p>Query executed successfully but returned no results.</p>
                </div>
            `;
            return;
        }

        // Create table
        const table = this.createResultsTable(results);
        resultsContainer.innerHTML = '';
        resultsContainer.appendChild(table);

        // Setup pagination if needed
        this.setupPagination(results);
    }

    /**
     * Create results table element
     */
    createResultsTable(results) {
        const table = document.createElement('table');
        table.className = 'results-table';

        // Create header
        const thead = document.createElement('thead');
        const headerRow = document.createElement('tr');
        
        results.headers.forEach(header => {
            const th = document.createElement('th');
            th.textContent = header;
            th.className = 'results-header-cell';
            headerRow.appendChild(th);
        });
        
        thead.appendChild(headerRow);
        table.appendChild(thead);

        // Create body with paginated data
        const tbody = document.createElement('tbody');
        const startIndex = (this.currentPage - 1) * this.pageSize;
        const endIndex = Math.min(startIndex + this.pageSize, results.rows.length);
        
        for (let i = startIndex; i < endIndex; i++) {
            const row = results.rows[i];
            const tr = document.createElement('tr');
            
            results.headers.forEach(header => {
                const td = document.createElement('td');
                td.className = 'results-data-cell';
                
                const value = row[header] || '';
                
                // Format different data types
                if (header.toLowerCase() === 'time' || header.toLowerCase().includes('timestamp')) {
                    td.textContent = this.formatTimestamp(value);
                    td.className += ' timestamp-cell';
                } else if (this.isNumeric(value)) {
                    td.textContent = this.formatNumber(value);
                    td.className += ' numeric-cell';
                } else {
                    td.textContent = value;
                }
                
                tr.appendChild(td);
            });
            
            tbody.appendChild(tr);
        }
        
        table.appendChild(tbody);
        return table;
    }

    /**
     * Setup pagination controls
     */
    setupPagination(results) {
        const paginationContainer = document.getElementById('results-pagination');
        if (!paginationContainer || results.totalRows <= this.pageSize) {
            if (paginationContainer) {
                paginationContainer.innerHTML = '';
            }
            return;
        }

        const totalPages = Math.ceil(results.totalRows / this.pageSize);
        
        paginationContainer.innerHTML = `
            <div class="pagination-controls">
                <button class="btn btn-small" ${this.currentPage <= 1 ? 'disabled' : ''} 
                        onclick="queryExecutor.goToPage(${this.currentPage - 1})">
                    « Previous
                </button>
                <span class="pagination-info">
                    Page ${this.currentPage} of ${totalPages} 
                    (${results.totalRows} total rows)
                </span>
                <button class="btn btn-small" ${this.currentPage >= totalPages ? 'disabled' : ''} 
                        onclick="queryExecutor.goToPage(${this.currentPage + 1})">
                    Next »
                </button>
            </div>
        `;
    }

    /**
     * Navigate to specific page
     */
    goToPage(page) {
        if (!this.currentResults || page < 1) return;
        
        const totalPages = Math.ceil(this.currentResults.totalRows / this.pageSize);
        if (page > totalPages) return;

        this.currentPage = page;
        this.displayResults(this.currentResults);
    }

    /**
     * Export results in specified format
     */
    exportResults(format) {
        if (!this.currentResults || this.currentResults.isEmpty) {
            this.showError('No results to export');
            return;
        }

        try {
            let content = '';
            let filename = '';
            let mimeType = '';

            const timestamp = new Date().toISOString().slice(0, 19).replace(/[:.]/g, '-');

            switch (format.toLowerCase()) {
                case 'csv':
                    content = this.convertToCSV(this.currentResults);
                    filename = `influxdb-results-${timestamp}.csv`;
                    mimeType = 'text/csv';
                    break;
                
                case 'json':
                    content = JSON.stringify(this.currentResults.rows, null, 2);
                    filename = `influxdb-results-${timestamp}.json`;
                    mimeType = 'application/json';
                    break;
                
                default:
                    throw new Error('Unsupported export format');
            }

            this.downloadFile(content, filename, mimeType);
            this.showSuccess(`Results exported as ${format.toUpperCase()}`);

        } catch (error) {
            this.showError(`Export failed: ${error.message}`);
        }
    }

    /**
     * Convert results to CSV format
     */
    convertToCSV(results) {
        if (!results || !results.headers || !results.rows) {
            return '';
        }

        // Create CSV header
        const csvRows = [];
        csvRows.push(results.headers.map(h => this.escapeCSV(h)).join(','));

        // Add data rows
        results.rows.forEach(row => {
            const csvRow = results.headers.map(header => {
                const value = row[header] || '';
                return this.escapeCSV(value.toString());
            });
            csvRows.push(csvRow.join(','));
        });

        return csvRows.join('\n');
    }

    /**
     * Escape CSV values
     */
    escapeCSV(value) {
        if (value.includes(',') || value.includes('"') || value.includes('\n')) {
            return `"${value.replace(/"/g, '""')}"`;
        }
        return value;
    }

    /**
     * Download file to user's browser
     */
    downloadFile(content, filename, mimeType) {
        const blob = new Blob([content], { type: mimeType });
        const url = URL.createObjectURL(blob);
        
        const link = document.createElement('a');
        link.href = url;
        link.download = filename;
        link.style.display = 'none';
        
        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);
        
        URL.revokeObjectURL(url);
    }

    /**
     * Cancel current query execution
     */
    cancelQuery() {
        if (this.abortController) {
            this.abortController.abort();
            console.log('Query cancelled by user');
        }
    }

    /**
     * Update execution information display
     */
    updateExecutionInfo(executionTime, rowCount) {
        const infoElement = document.getElementById('query-execution-info');
        if (infoElement) {
            infoElement.innerHTML = `
                ✅ Query completed in ${executionTime}ms | 
                ${rowCount.toLocaleString()} rows returned
            `;
        }
    }

    /**
     * Enable/disable export buttons
     */
    enableExportButtons(enabled) {
        const exportCsvBtn = document.getElementById('export-csv-btn');
        const exportJsonBtn = document.getElementById('export-json-btn');
        
        if (exportCsvBtn) exportCsvBtn.disabled = !enabled;
        if (exportJsonBtn) exportJsonBtn.disabled = !enabled;
    }

    /**
     * Enable/disable cancel button
     */
    enableCancelButton(enabled) {
        const cancelBtn = document.getElementById('cancel-query-btn');
        if (cancelBtn) {
            cancelBtn.disabled = !enabled;
        }
    }

    /**
     * Utility methods for data formatting
     */
    formatTimestamp(value) {
        if (!value) return '';
        
        try {
            const date = new Date(value);
            if (isNaN(date.getTime())) return value;
            
            return date.toLocaleString();
        } catch (error) {
            return value;
        }
    }

    formatNumber(value) {
        if (!value || !this.isNumeric(value)) return value;
        
        const num = parseFloat(value);
        if (num % 1 === 0) {
            return num.toLocaleString();
        } else {
            return num.toLocaleString(undefined, { maximumFractionDigits: 4 });
        }
    }

    isNumeric(value) {
        return !isNaN(parseFloat(value)) && isFinite(value);
    }

    /**
     * Display methods for different message types
     */
    showLoading(message) {
        const resultsContainer = document.getElementById('query-results');
        if (resultsContainer) {
            resultsContainer.innerHTML = `
                <div class="results-loading">
                    <div class="loading-spinner"></div>
                    <p>${message}</p>
                </div>
            `;
        }
    }

    showError(message) {
        const resultsContainer = document.getElementById('query-results');
        if (resultsContainer) {
            resultsContainer.innerHTML = `
                <div class="results-error">
                    <p>❌ ${message}</p>
                </div>
            `;
        }
        
        this.updateExecutionInfo(Date.now() - (this.executionStartTime || Date.now()), 0);
        this.enableExportButtons(false);
    }

    showSuccess(message) {
        const infoElement = document.getElementById('query-execution-info');
        if (infoElement) {
            const originalContent = infoElement.innerHTML;
            infoElement.innerHTML = `✅ ${message}`;
            
            setTimeout(() => {
                infoElement.innerHTML = originalContent;
            }, 3000);
        }
    }

    showInfo(message) {
        const resultsContainer = document.getElementById('query-results');
        if (resultsContainer) {
            resultsContainer.innerHTML = `
                <div class="results-info">
                    <p>ℹ️ ${message}</p>
                </div>
            `;
        }
    }

    /**
     * Clear results display
     */
    clearResults() {
        const resultsContainer = document.getElementById('query-results');
        const paginationContainer = document.getElementById('results-pagination');
        const infoElement = document.getElementById('query-execution-info');
        
        if (resultsContainer) resultsContainer.innerHTML = '';
        if (paginationContainer) paginationContainer.innerHTML = '';
        if (infoElement) infoElement.innerHTML = '';
        
        this.currentResults = null;
        this.enableExportButtons(false);
    }

    /**
     * Get current results for external access
     */
    getCurrentResults() {
        return this.currentResults;
    }

    /**
     * Set page size for pagination
     */
    setPageSize(size) {
        this.pageSize = Math.max(10, Math.min(1000, size));
        
        if (this.currentResults && !this.currentResults.isEmpty) {
            this.currentPage = 1;
            this.displayResults(this.currentResults);
        }
    }
}

// Export for use in other modules
if (typeof module !== 'undefined' && module.exports) {
    module.exports = QueryExecutor;
} else if (typeof window !== 'undefined') {
    window.QueryExecutor = QueryExecutor;
} 