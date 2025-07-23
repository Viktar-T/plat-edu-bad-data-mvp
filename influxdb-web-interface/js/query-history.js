/**
 * Query History Module for InfluxDB 3.x
 * Manages query history, saved queries, and execution logs
 * Renewable Energy IoT Monitoring System
 */

class QueryHistory {
    constructor() {
        this.maxHistoryItems = 100;
        this.maxSavedQueries = 50;
        this.storageKeys = {
            history: 'influx_query_history',
            saved: 'influx_saved_queries',
            favorites: 'influx_favorite_queries'
        };
        
        this.queryHistory = [];
        this.savedQueries = [];
        this.favoriteQueries = [];
        
        this.initializeHistory();
    }

    /**
     * Initialize query history from localStorage
     */
    initializeHistory() {
        try {
            // Load query history
            const historyData = localStorage.getItem(this.storageKeys.history);
            if (historyData) {
                this.queryHistory = JSON.parse(historyData);
            }

            // Load saved queries
            const savedData = localStorage.getItem(this.storageKeys.saved);
            if (savedData) {
                this.savedQueries = JSON.parse(savedData);
            }

            // Load favorite queries
            const favoritesData = localStorage.getItem(this.storageKeys.favorites);
            if (favoritesData) {
                this.favoriteQueries = JSON.parse(favoritesData);
            }

            console.log('Query history initialized:', {
                history: this.queryHistory.length,
                saved: this.savedQueries.length,
                favorites: this.favoriteQueries.length
            });

        } catch (error) {
            console.error('Error loading query history:', error);
            this.resetHistory();
        }
    }

    /**
     * Add query to execution history
     */
    addToHistory(query, database = '', status = 'executed') {
        if (!query || !query.trim()) return;

        const historyItem = {
            id: this.generateId(),
            query: query.trim(),
            database: database,
            timestamp: new Date().toISOString(),
            status: status,
            executionTime: null
        };

        // Remove duplicate if exists
        this.queryHistory = this.queryHistory.filter(item => 
            item.query !== historyItem.query || item.database !== historyItem.database
        );

        // Add to beginning of array
        this.queryHistory.unshift(historyItem);

        // Limit history size
        if (this.queryHistory.length > this.maxHistoryItems) {
            this.queryHistory = this.queryHistory.slice(0, this.maxHistoryItems);
        }

        this.saveHistory();
        this.updateHistoryDisplay();

        return historyItem.id;
    }

    /**
     * Save a named query
     */
    saveQuery(name, query, database = '', description = '') {
        if (!name || !query) {
            throw new Error('Query name and content are required');
        }

        const savedQuery = {
            id: this.generateId(),
            name: name.trim(),
            query: query.trim(),
            database: database,
            description: description.trim(),
            createdAt: new Date().toISOString(),
            lastUsed: null,
            useCount: 0,
            tags: []
        };

        // Check for duplicate names
        const existingIndex = this.savedQueries.findIndex(q => q.name === savedQuery.name);
        if (existingIndex >= 0) {
            // Update existing query
            this.savedQueries[existingIndex] = {
                ...this.savedQueries[existingIndex],
                ...savedQuery,
                id: this.savedQueries[existingIndex].id,
                createdAt: this.savedQueries[existingIndex].createdAt
            };
        } else {
            // Add new query
            this.savedQueries.unshift(savedQuery);
        }

        // Limit saved queries
        if (this.savedQueries.length > this.maxSavedQueries) {
            this.savedQueries = this.savedQueries.slice(0, this.maxSavedQueries);
        }

        this.saveSavedQueries();
        this.updateSavedQueriesDisplay();

        return savedQuery.id;
    }

    /**
     * Delete a saved query
     */
    deleteSavedQuery(queryId) {
        this.savedQueries = this.savedQueries.filter(q => q.id !== queryId);
        this.saveSavedQueries();
        this.updateSavedQueriesDisplay();
    }

    /**
     * Execute a query from history or saved queries
     */
    async executeStoredQuery(queryId, type = 'history') {
        let query = null;

        if (type === 'history') {
            query = this.queryHistory.find(q => q.id === queryId);
        } else if (type === 'saved') {
            query = this.savedQueries.find(q => q.id === queryId);
            
            // Update usage statistics
            if (query) {
                query.lastUsed = new Date().toISOString();
                query.useCount = (query.useCount || 0) + 1;
                this.saveSavedQueries();
            }
        }

        if (!query) {
            throw new Error('Query not found');
        }

        // Set database context if specified
        if (query.database && window.queryEditor) {
            window.queryEditor.setDatabase(query.database);
        }

        // Load query into editor
        if (window.queryEditor) {
            window.queryEditor.setValue(query.query);
            window.queryEditor.focus();
        }

        // Execute query if executor is available
        if (window.queryExecutor) {
            await window.queryExecutor.executeQuery(query.query, query.database);
        }
    }

    /**
     * Add/remove query from favorites
     */
    toggleFavorite(queryId, type = 'saved') {
        let query = null;

        if (type === 'saved') {
            query = this.savedQueries.find(q => q.id === queryId);
        } else if (type === 'history') {
            query = this.queryHistory.find(q => q.id === queryId);
        }

        if (!query) return;

        const favoriteIndex = this.favoriteQueries.findIndex(f => f.sourceId === queryId);
        
        if (favoriteIndex >= 0) {
            // Remove from favorites
            this.favoriteQueries.splice(favoriteIndex, 1);
        } else {
            // Add to favorites
            this.favoriteQueries.unshift({
                id: this.generateId(),
                sourceId: queryId,
                sourceType: type,
                name: query.name || this.truncateQuery(query.query),
                query: query.query,
                database: query.database,
                addedAt: new Date().toISOString()
            });
        }

        this.saveFavorites();
        this.updateHistoryDisplay();
        this.updateSavedQueriesDisplay();
    }

    /**
     * Search through queries
     */
    searchQueries(searchTerm, type = 'all') {
        const term = searchTerm.toLowerCase().trim();
        if (!term) return [];

        const results = [];

        if (type === 'all' || type === 'history') {
            const historyResults = this.queryHistory.filter(item =>
                item.query.toLowerCase().includes(term) ||
                item.database.toLowerCase().includes(term)
            ).map(item => ({ ...item, type: 'history' }));
            results.push(...historyResults);
        }

        if (type === 'all' || type === 'saved') {
            const savedResults = this.savedQueries.filter(item =>
                item.name.toLowerCase().includes(term) ||
                item.query.toLowerCase().includes(term) ||
                item.description.toLowerCase().includes(term) ||
                item.database.toLowerCase().includes(term)
            ).map(item => ({ ...item, type: 'saved' }));
            results.push(...savedResults);
        }

        return results.slice(0, 20); // Limit results
    }

    /**
     * Get queries by database
     */
    getQueriesByDatabase(database) {
        const results = [];
        
        // Add from history
        const historyForDb = this.queryHistory
            .filter(item => item.database === database)
            .map(item => ({ ...item, type: 'history' }));
        results.push(...historyForDb);

        // Add from saved queries
        const savedForDb = this.savedQueries
            .filter(item => item.database === database)
            .map(item => ({ ...item, type: 'saved' }));
        results.push(...savedForDb);

        return results;
    }

    /**
     * Get most frequently used queries
     */
    getMostUsedQueries(limit = 10) {
        return this.savedQueries
            .filter(q => q.useCount > 0)
            .sort((a, b) => (b.useCount || 0) - (a.useCount || 0))
            .slice(0, limit)
            .map(item => ({ ...item, type: 'saved' }));
    }

    /**
     * Get recent queries
     */
    getRecentQueries(limit = 10) {
        return this.queryHistory
            .slice(0, limit)
            .map(item => ({ ...item, type: 'history' }));
    }

    /**
     * Export query history
     */
    exportHistory(format = 'json') {
        const exportData = {
            history: this.queryHistory,
            saved: this.savedQueries,
            favorites: this.favoriteQueries,
            exportedAt: new Date().toISOString(),
            version: '1.0'
        };

        const timestamp = new Date().toISOString().slice(0, 19).replace(/[:.]/g, '-');
        let content = '';
        let filename = '';
        let mimeType = '';

        switch (format.toLowerCase()) {
            case 'json':
                content = JSON.stringify(exportData, null, 2);
                filename = `influxdb-query-history-${timestamp}.json`;
                mimeType = 'application/json';
                break;
            
            default:
                throw new Error('Unsupported export format');
        }

        this.downloadFile(content, filename, mimeType);
    }

    /**
     * Import query history
     */
    async importHistory(file) {
        return new Promise((resolve, reject) => {
            const reader = new FileReader();
            
            reader.onload = (e) => {
                try {
                    const importData = JSON.parse(e.target.result);
                    
                    if (importData.history) {
                        this.queryHistory = [...importData.history, ...this.queryHistory];
                        this.queryHistory = this.queryHistory.slice(0, this.maxHistoryItems);
                    }
                    
                    if (importData.saved) {
                        // Merge saved queries, avoiding duplicates by name
                        importData.saved.forEach(importedQuery => {
                            const existingIndex = this.savedQueries.findIndex(q => q.name === importedQuery.name);
                            if (existingIndex >= 0) {
                                this.savedQueries[existingIndex] = importedQuery;
                            } else {
                                this.savedQueries.push(importedQuery);
                            }
                        });
                        this.savedQueries = this.savedQueries.slice(0, this.maxSavedQueries);
                    }
                    
                    if (importData.favorites) {
                        this.favoriteQueries = [...importData.favorites, ...this.favoriteQueries];
                    }

                    this.saveAll();
                    this.updateAllDisplays();
                    
                    resolve(importData);
                } catch (error) {
                    reject(new Error('Invalid import file format'));
                }
            };
            
            reader.onerror = () => reject(new Error('Error reading file'));
            reader.readAsText(file);
        });
    }

    /**
     * Display management methods
     */
    updateHistoryDisplay() {
        const container = document.getElementById('query-history-list');
        if (!container) return;

        if (this.queryHistory.length === 0) {
            container.innerHTML = '<p class="empty-state">No query history available</p>';
            return;
        }

        const html = this.queryHistory.slice(0, 20).map(item => `
            <div class="history-item" data-query-id="${item.id}">
                <div class="history-item-header">
                    <span class="history-query-preview">${this.truncateQuery(item.query)}</span>
                    <div class="history-item-actions">
                        <button class="btn btn-small" onclick="queryHistory.executeStoredQuery('${item.id}', 'history')" title="Execute">▶️</button>
                        <button class="btn btn-small" onclick="queryHistory.loadQueryToEditor('${item.id}', 'history')" title="Load to Editor">📝</button>
                        <button class="btn btn-small ${this.isFavorite(item.id) ? 'active' : ''}" onclick="queryHistory.toggleFavorite('${item.id}', 'history')" title="Toggle Favorite">⭐</button>
                    </div>
                </div>
                <div class="history-item-meta">
                    <span class="timestamp">${this.formatTimestamp(item.timestamp)}</span>
                    ${item.database ? `<span class="database">📁 ${item.database}</span>` : ''}
                    <span class="status status-${item.status}">${item.status}</span>
                </div>
            </div>
        `).join('');

        container.innerHTML = html;
    }

    updateSavedQueriesDisplay() {
        const container = document.getElementById('saved-queries-list');
        if (!container) return;

        if (this.savedQueries.length === 0) {
            container.innerHTML = '<p class="empty-state">No saved queries available</p>';
            return;
        }

        const html = this.savedQueries.map(item => `
            <div class="saved-query-item" data-query-id="${item.id}">
                <div class="saved-query-header">
                    <h4 class="saved-query-name">${item.name}</h4>
                    <div class="saved-query-actions">
                        <button class="btn btn-small" onclick="queryHistory.executeStoredQuery('${item.id}', 'saved')" title="Execute">▶️</button>
                        <button class="btn btn-small" onclick="queryHistory.loadQueryToEditor('${item.id}', 'saved')" title="Load to Editor">📝</button>
                        <button class="btn btn-small" onclick="queryHistory.editSavedQuery('${item.id}')" title="Edit">✏️</button>
                        <button class="btn btn-small ${this.isFavorite(item.id) ? 'active' : ''}" onclick="queryHistory.toggleFavorite('${item.id}', 'saved')" title="Toggle Favorite">⭐</button>
                        <button class="btn btn-small btn-danger" onclick="queryHistory.deleteSavedQuery('${item.id}')" title="Delete">🗑️</button>
                    </div>
                </div>
                ${item.description ? `<p class="saved-query-description">${item.description}</p>` : ''}
                <div class="saved-query-preview">
                    <code>${this.truncateQuery(item.query)}</code>
                </div>
                <div class="saved-query-meta">
                    <span class="created-at">Created: ${this.formatTimestamp(item.createdAt)}</span>
                    ${item.database ? `<span class="database">📁 ${item.database}</span>` : ''}
                    ${item.useCount ? `<span class="use-count">Used ${item.useCount} times</span>` : ''}
                </div>
            </div>
        `).join('');

        container.innerHTML = html;
    }

    updateAllDisplays() {
        this.updateHistoryDisplay();
        this.updateSavedQueriesDisplay();
    }

    /**
     * Load query to editor without executing
     */
    loadQueryToEditor(queryId, type = 'history') {
        let query = null;

        if (type === 'history') {
            query = this.queryHistory.find(q => q.id === queryId);
        } else if (type === 'saved') {
            query = this.savedQueries.find(q => q.id === queryId);
        }

        if (!query) return;

        // Set database context if specified
        if (query.database && window.queryEditor) {
            window.queryEditor.setDatabase(query.database);
        }

        // Load query into editor
        if (window.queryEditor) {
            window.queryEditor.setValue(query.query);
            window.queryEditor.focus();
        }
    }

    /**
     * Edit saved query
     */
    editSavedQuery(queryId) {
        const query = this.savedQueries.find(q => q.id === queryId);
        if (!query) return;

        // Show edit modal or form
        this.showEditQueryModal(query);
    }

    /**
     * Show edit query modal (simplified version)
     */
    showEditQueryModal(query) {
        const newName = prompt('Query Name:', query.name);
        if (!newName) return;

        const newDescription = prompt('Description (optional):', query.description || '');

        // Update query
        query.name = newName.trim();
        query.description = newDescription ? newDescription.trim() : '';

        this.saveSavedQueries();
        this.updateSavedQueriesDisplay();
    }

    /**
     * Utility methods
     */
    generateId() {
        return Date.now().toString(36) + Math.random().toString(36).substr(2);
    }

    truncateQuery(query, maxLength = 100) {
        if (!query) return '';
        
        const cleaned = query.replace(/\s+/g, ' ').trim();
        if (cleaned.length <= maxLength) return cleaned;
        
        return cleaned.substring(0, maxLength) + '...';
    }

    formatTimestamp(timestamp) {
        try {
            const date = new Date(timestamp);
            const now = new Date();
            const diffMs = now - date;
            const diffMins = Math.floor(diffMs / 60000);
            const diffHours = Math.floor(diffMs / 3600000);
            const diffDays = Math.floor(diffMs / 86400000);

            if (diffMins < 1) return 'Just now';
            if (diffMins < 60) return `${diffMins}m ago`;
            if (diffHours < 24) return `${diffHours}h ago`;
            if (diffDays < 7) return `${diffDays}d ago`;
            
            return date.toLocaleDateString();
        } catch (error) {
            return timestamp;
        }
    }

    isFavorite(queryId) {
        return this.favoriteQueries.some(f => f.sourceId === queryId);
    }

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
     * Storage methods
     */
    saveHistory() {
        try {
            localStorage.setItem(this.storageKeys.history, JSON.stringify(this.queryHistory));
        } catch (error) {
            console.error('Error saving query history:', error);
        }
    }

    saveSavedQueries() {
        try {
            localStorage.setItem(this.storageKeys.saved, JSON.stringify(this.savedQueries));
        } catch (error) {
            console.error('Error saving saved queries:', error);
        }
    }

    saveFavorites() {
        try {
            localStorage.setItem(this.storageKeys.favorites, JSON.stringify(this.favoriteQueries));
        } catch (error) {
            console.error('Error saving favorites:', error);
        }
    }

    saveAll() {
        this.saveHistory();
        this.saveSavedQueries();
        this.saveFavorites();
    }

    resetHistory() {
        this.queryHistory = [];
        this.savedQueries = [];
        this.favoriteQueries = [];
        this.saveAll();
        this.updateAllDisplays();
    }

    /**
     * Get statistics
     */
    getStatistics() {
        return {
            totalQueries: this.queryHistory.length,
            savedQueries: this.savedQueries.length,
            favorites: this.favoriteQueries.length,
            mostUsedQuery: this.getMostUsedQueries(1)[0] || null,
            oldestQuery: this.queryHistory[this.queryHistory.length - 1] || null,
            newestQuery: this.queryHistory[0] || null
        };
    }
}

// Export for use in other modules
if (typeof module !== 'undefined' && module.exports) {
    module.exports = QueryHistory;
} else if (typeof window !== 'undefined') {
    window.QueryHistory = QueryHistory;
} 