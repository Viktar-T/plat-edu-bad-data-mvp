/**
 * Database Administration Module for InfluxDB 3.x
 * Renewable Energy IoT Monitoring System
 */

class DatabaseAdmin {
    constructor() {
        this.influxUrl = 'http://localhost:8086';
        this.currentDatabase = null;
        this.databases = [];
        this.backups = [];
        this.statsInterval = null;
        
        this.initializeAdmin();
    }

    /**
     * Initialize admin interface
     */
    initializeAdmin() {
        this.loadBackupsMetadata();
        this.startStatisticsUpdates();
    }

    /**
     * Enhanced database creation with validation
     */
    async createDatabase(dbName) {
        if (!this.validateDatabaseName(dbName)) {
            throw new Error('Invalid database name. Use only alphanumeric characters, underscores, and hyphens.');
        }

        try {
            const response = await fetch(`${this.influxUrl}/api/v3/configure/database`, {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/json',
                },
                body: JSON.stringify({ db: dbName })
            });

            if (!response.ok) {
                const error = await response.text();
                throw new Error(`Failed to create database: ${error}`);
            }

            // Store database metadata
            const metadata = {
                name: dbName,
                createdAt: new Date().toISOString(),
                size: 0,
                recordCount: 0
            };
            
            this.saveDatabaseMetadata(metadata);
            this.showNotification(`Database "${dbName}" created successfully!`, 'success');
            
            return true;
        } catch (error) {
            this.showNotification(error.message, 'error');
            throw error;
        }
    }

    /**
     * Enhanced database deletion with confirmation
     */
    async deleteDatabase(dbName) {
        if (!await this.showConfirmation(`Are you sure you want to delete database "${dbName}"? This action cannot be undone.`)) {
            return false;
        }

        try {
            // Note: InfluxDB 3.x doesn't have direct delete API, so we'll handle this gracefully
            this.showNotification(`Database "${dbName}" marked for deletion. Manual cleanup may be required.`, 'info');
            
            // Remove from metadata
            this.removeDatabaseMetadata(dbName);
            
            return true;
        } catch (error) {
            this.showNotification(`Error deleting database: ${error.message}`, 'error');
            throw error;
        }
    }

    /**
     * Load databases with detailed information
     */
    async loadDatabasesWithInfo() {
        try {
            this.showProgressIndicator('Loading databases...');
            
            const response = await fetch(`${this.influxUrl}/api/v3/configure/database?format=json`);
            
            if (!response.ok) {
                throw new Error('Failed to load databases');
            }

            const data = await response.json();
            this.databases = data.databases || [];
            
            // Enhance with metadata
            const enhancedDatabases = await Promise.all(
                this.databases.map(async (dbName) => {
                    const metadata = this.getDatabaseMetadata(dbName);
                    const stats = await this.getDatabaseStats(dbName);
                    
                    return {
                        name: dbName,
                        ...metadata,
                        ...stats
                    };
                })
            );

            this.hideProgressIndicator();
            return enhancedDatabases;
            
        } catch (error) {
            this.hideProgressIndicator();
            this.showNotification(`Error loading databases: ${error.message}`, 'error');
            throw error;
        }
    }

    /**
     * Get database statistics
     */
    async getDatabaseStats(dbName) {
        try {
            // Get basic stats through queries
            const [recordCount, sizeInfo] = await Promise.all([
                this.getRecordCount(dbName),
                this.getDatabaseSize(dbName)
            ]);

            return {
                recordCount: recordCount || 0,
                size: sizeInfo.size || 0,
                sizeFormatted: this.formatBytes(sizeInfo.size || 0),
                lastUpdated: new Date().toISOString(),
                status: this.getDatabaseHealthStatus(recordCount, sizeInfo)
            };
        } catch (error) {
            return {
                recordCount: 0,
                size: 0,
                sizeFormatted: '0 B',
                lastUpdated: new Date().toISOString(),
                status: 'unknown'
            };
        }
    }

    /**
     * Get record count for a database
     */
    async getRecordCount(dbName) {
        try {
            // First get all measurements
            const measurementsResponse = await fetch(
                `${this.influxUrl}/api/v3/query_sql?db=${encodeURIComponent(dbName)}&q=${encodeURIComponent('SHOW MEASUREMENTS')}`
            );
            
            if (!measurementsResponse.ok) return 0;
            
            const measurementsText = await measurementsResponse.text();
            const measurements = this.parseMeasurements(measurementsText);
            
            let totalCount = 0;
            for (const measurement of measurements) {
                const countResponse = await fetch(
                    `${this.influxUrl}/api/v3/query_sql?db=${encodeURIComponent(dbName)}&q=${encodeURIComponent(`SELECT COUNT(*) FROM ${measurement}`)}`
                );
                
                if (countResponse.ok) {
                    const countText = await countResponse.text();
                    const count = this.parseCountResult(countText);
                    totalCount += count;
                }
            }
            
            return totalCount;
        } catch (error) {
            return 0;
        }
    }

    /**
     * Get database size (estimated)
     */
    async getDatabaseSize(dbName) {
        try {
            // Since InfluxDB 3.x doesn't expose direct size info, we'll estimate
            const recordCount = await this.getRecordCount(dbName);
            const estimatedSize = recordCount * 100; // Rough estimate: 100 bytes per record
            
            return {
                size: estimatedSize,
                estimated: true
            };
        } catch (error) {
            return { size: 0, estimated: true };
        }
    }

    /**
     * Create manual backup
     */
    async createBackup(dbName) {
        try {
            this.showProgressIndicator(`Creating backup for ${dbName}...`);
            
            const backupId = `backup_${dbName}_${Date.now()}`;
            const timestamp = new Date().toISOString();
            
            // Get all data from database
            const measurements = await this.getAllMeasurements(dbName);
            const backupData = {
                database: dbName,
                timestamp: timestamp,
                measurements: measurements,
                version: '1.0'
            };
            
            // Store backup metadata
            const backup = {
                id: backupId,
                database: dbName,
                timestamp: timestamp,
                size: JSON.stringify(backupData).length,
                status: 'completed'
            };
            
            this.saveBackup(backupId, backupData);
            this.saveBackupMetadata(backup);
            
            this.hideProgressIndicator();
            this.showNotification(`Backup created successfully: ${backupId}`, 'success');
            
            return backup;
        } catch (error) {
            this.hideProgressIndicator();
            this.showNotification(`Backup failed: ${error.message}`, 'error');
            throw error;
        }
    }

    /**
     * Restore from backup
     */
    async restoreBackup(backupId) {
        try {
            if (!await this.showConfirmation(`Are you sure you want to restore from backup "${backupId}"? This will overwrite existing data.`)) {
                return false;
            }

            this.showProgressIndicator(`Restoring from backup ${backupId}...`);
            
            const backupData = this.loadBackup(backupId);
            if (!backupData) {
                throw new Error('Backup not found');
            }
            
            // Restore each measurement
            for (const measurement of backupData.measurements) {
                await this.restoreMeasurement(backupData.database, measurement);
            }
            
            this.hideProgressIndicator();
            this.showNotification(`Backup restored successfully: ${backupId}`, 'success');
            
            return true;
        } catch (error) {
            this.hideProgressIndicator();
            this.showNotification(`Restore failed: ${error.message}`, 'error');
            throw error;
        }
    }

    /**
     * Get all measurements from a database
     */
    async getAllMeasurements(dbName) {
        try {
            const response = await fetch(
                `${this.influxUrl}/api/v3/query_sql?db=${encodeURIComponent(dbName)}&q=${encodeURIComponent('SHOW MEASUREMENTS')}`
            );
            
            if (!response.ok) return [];
            
            const text = await response.text();
            const measurementNames = this.parseMeasurements(text);
            
            const measurements = [];
            for (const name of measurementNames) {
                const data = await this.getMeasurementData(dbName, name);
                measurements.push({
                    name: name,
                    data: data
                });
            }
            
            return measurements;
        } catch (error) {
            return [];
        }
    }

    /**
     * Utility methods
     */
    
    validateDatabaseName(name) {
        return /^[a-zA-Z0-9_-]+$/.test(name) && name.length > 0 && name.length <= 64;
    }

    getDatabaseHealthStatus(recordCount, sizeInfo) {
        if (recordCount === 0) return 'empty';
        if (recordCount < 1000) return 'low';
        if (recordCount < 100000) return 'normal';
        return 'high';
    }

    formatBytes(bytes) {
        if (bytes === 0) return '0 B';
        const k = 1024;
        const sizes = ['B', 'KB', 'MB', 'GB'];
        const i = Math.floor(Math.log(bytes) / Math.log(k));
        return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
    }

    parseMeasurements(text) {
        // Parse measurement names from SHOW MEASUREMENTS result
        const lines = text.split('\n').filter(line => line.trim());
        return lines.slice(1).map(line => line.trim()).filter(Boolean);
    }

    parseCountResult(text) {
        // Parse count from SELECT COUNT(*) result
        const lines = text.split('\n').filter(line => line.trim());
        if (lines.length > 1) {
            const countLine = lines[1];
            const match = countLine.match(/\d+/);
            return match ? parseInt(match[0]) : 0;
        }
        return 0;
    }

    /**
     * Local storage methods for metadata and backups
     */
    
    saveDatabaseMetadata(metadata) {
        const key = `db_metadata_${metadata.name}`;
        localStorage.setItem(key, JSON.stringify(metadata));
    }

    getDatabaseMetadata(dbName) {
        const key = `db_metadata_${dbName}`;
        const stored = localStorage.getItem(key);
        return stored ? JSON.parse(stored) : { createdAt: null, size: 0, recordCount: 0 };
    }

    removeDatabaseMetadata(dbName) {
        const key = `db_metadata_${dbName}`;
        localStorage.removeItem(key);
    }

    saveBackup(backupId, data) {
        const key = `backup_data_${backupId}`;
        localStorage.setItem(key, JSON.stringify(data));
    }

    loadBackup(backupId) {
        const key = `backup_data_${backupId}`;
        const stored = localStorage.getItem(key);
        return stored ? JSON.parse(stored) : null;
    }

    saveBackupMetadata(backup) {
        const backups = this.loadBackupsMetadata();
        backups.push(backup);
        localStorage.setItem('backup_metadata', JSON.stringify(backups));
        this.backups = backups;
    }

    loadBackupsMetadata() {
        const stored = localStorage.getItem('backup_metadata');
        this.backups = stored ? JSON.parse(stored) : [];
        return this.backups;
    }

    /**
     * UI Helper methods
     */
    
    showNotification(message, type = 'info') {
        const notification = document.createElement('div');
        notification.className = `notification ${type}`;
        notification.innerHTML = `
            <span>${message}</span>
            <button onclick="this.parentElement.remove()">&times;</button>
        `;
        
        document.body.appendChild(notification);
        
        setTimeout(() => {
            if (notification.parentElement) {
                notification.remove();
            }
        }, 5000);
    }

    showProgressIndicator(message) {
        const indicator = document.getElementById('progress-indicator') || 
                         document.createElement('div');
        indicator.id = 'progress-indicator';
        indicator.className = 'progress-indicator';
        indicator.innerHTML = `<div class="loading">${message}</div>`;
        
        if (!document.getElementById('progress-indicator')) {
            document.body.appendChild(indicator);
        }
    }

    hideProgressIndicator() {
        const indicator = document.getElementById('progress-indicator');
        if (indicator) {
            indicator.remove();
        }
    }

    async showConfirmation(message) {
        return new Promise((resolve) => {
            const confirmed = confirm(message);
            resolve(confirmed);
        });
    }

    /**
     * Statistics updates
     */
    
    startStatisticsUpdates() {
        // Update statistics every 30 seconds
        this.statsInterval = setInterval(() => {
            this.updateDashboardStats();
        }, 30000);
    }

    stopStatisticsUpdates() {
        if (this.statsInterval) {
            clearInterval(this.statsInterval);
            this.statsInterval = null;
        }
    }

    async updateDashboardStats() {
        try {
            const databases = await this.loadDatabasesWithInfo();
            this.updateDashboard(databases);
        } catch (error) {
            console.error('Failed to update dashboard stats:', error);
        }
    }

    updateDashboard(databases) {
        const dashboardElement = document.getElementById('stats-dashboard');
        if (!dashboardElement) return;

        const totalDatabases = databases.length;
        const totalRecords = databases.reduce((sum, db) => sum + (db.recordCount || 0), 0);
        const totalSize = databases.reduce((sum, db) => sum + (db.size || 0), 0);

        dashboardElement.innerHTML = `
            <div class="stats-grid">
                <div class="stat-card">
                    <h4>Total Databases</h4>
                    <div class="stat-value">${totalDatabases}</div>
                </div>
                <div class="stat-card">
                    <h4>Total Records</h4>
                    <div class="stat-value">${totalRecords.toLocaleString()}</div>
                </div>
                <div class="stat-card">
                    <h4>Total Storage</h4>
                    <div class="stat-value">${this.formatBytes(totalSize)}</div>
                </div>
                <div class="stat-card">
                    <h4>Active Backups</h4>
                    <div class="stat-value">${this.backups.length}</div>
                </div>
            </div>
        `;

        // Update charts
        this.updateCharts(databases);
    }

    /**
     * Update charts with current data
     */
    updateCharts(databases) {
        this.updateStorageChart(databases);
        this.updateRecordCountChart(databases);
    }

    /**
     * Create simple storage growth chart
     */
    updateStorageChart(databases) {
        const chartContainer = document.querySelector('.chart-card .chart-placeholder');
        if (!chartContainer) return;

        // Generate sample data for demonstration
        const data = this.generateStorageGrowthData(databases);
        
        chartContainer.innerHTML = `
            <canvas id="storage-chart" width="300" height="180"></canvas>
        `;

        const canvas = document.getElementById('storage-chart');
        const ctx = canvas.getContext('2d');
        
        this.drawLineChart(ctx, data, {
            title: 'Storage Growth',
            color: '#667eea',
            width: 300,
            height: 180
        });
    }

    /**
     * Create simple record count chart
     */
    updateRecordCountChart(databases) {
        const chartContainers = document.querySelectorAll('.chart-card .chart-placeholder');
        if (chartContainers.length < 2) return;

        const chartContainer = chartContainers[1];
        const data = this.generateRecordCountData(databases);
        
        chartContainer.innerHTML = `
            <canvas id="records-chart" width="300" height="180"></canvas>
        `;

        const canvas = document.getElementById('records-chart');
        const ctx = canvas.getContext('2d');
        
        this.drawLineChart(ctx, data, {
            title: 'Record Count Trends',
            color: '#27ae60',
            width: 300,
            height: 180
        });
    }

    /**
     * Generate storage growth data (simulated for demonstration)
     */
    generateStorageGrowthData(databases) {
        const now = new Date();
        const data = [];
        
        for (let i = 6; i >= 0; i--) {
            const date = new Date(now);
            date.setDate(date.getDate() - i);
            
            // Simulate growth based on current database sizes
            const totalSize = databases.reduce((sum, db) => sum + (db.size || 0), 0);
            const growthFactor = Math.random() * 0.2 + 0.9; // 90-110% of current
            const value = Math.floor(totalSize * growthFactor * (0.5 + i * 0.1));
            
            data.push({
                label: date.toLocaleDateString(),
                value: value
            });
        }
        
        return data;
    }

    /**
     * Generate record count data (simulated for demonstration)
     */
    generateRecordCountData(databases) {
        const now = new Date();
        const data = [];
        
        for (let i = 6; i >= 0; i--) {
            const date = new Date(now);
            date.setDate(date.getDate() - i);
            
            // Simulate growth based on current record counts
            const totalRecords = databases.reduce((sum, db) => sum + (db.recordCount || 0), 0);
            const growthFactor = Math.random() * 0.3 + 0.8; // 80-110% of current
            const value = Math.floor(totalRecords * growthFactor * (0.3 + i * 0.1));
            
            data.push({
                label: date.toLocaleDateString(),
                value: value
            });
        }
        
        return data;
    }

    /**
     * Draw a simple line chart using Canvas
     */
    drawLineChart(ctx, data, options) {
        const { width, height, color, title } = options;
        const padding = 40;
        const chartWidth = width - (padding * 2);
        const chartHeight = height - (padding * 2);
        
        // Clear canvas
        ctx.clearRect(0, 0, width, height);
        
        // Set up styling
        ctx.fillStyle = '#2c3e50';
        ctx.strokeStyle = color;
        ctx.lineWidth = 2;
        ctx.font = '12px Arial';
        
        if (data.length === 0) {
            ctx.fillText('No data available', width / 2 - 50, height / 2);
            return;
        }
        
        // Calculate scaling
        const maxValue = Math.max(...data.map(d => d.value));
        const minValue = Math.min(...data.map(d => d.value));
        const valueRange = maxValue - minValue || 1;
        
        // Draw axes
        ctx.beginPath();
        ctx.strokeStyle = '#e9ecef';
        ctx.lineWidth = 1;
        
        // Y-axis
        ctx.moveTo(padding, padding);
        ctx.lineTo(padding, height - padding);
        
        // X-axis
        ctx.moveTo(padding, height - padding);
        ctx.lineTo(width - padding, height - padding);
        ctx.stroke();
        
        // Draw grid lines
        ctx.strokeStyle = '#f8f9fa';
        for (let i = 1; i <= 4; i++) {
            const y = padding + (chartHeight / 4) * i;
            ctx.beginPath();
            ctx.moveTo(padding, y);
            ctx.lineTo(width - padding, y);
            ctx.stroke();
        }
        
        // Draw data line
        if (data.length > 1) {
            ctx.beginPath();
            ctx.strokeStyle = color;
            ctx.lineWidth = 3;
            
            data.forEach((point, index) => {
                const x = padding + (chartWidth / (data.length - 1)) * index;
                const y = height - padding - ((point.value - minValue) / valueRange) * chartHeight;
                
                if (index === 0) {
                    ctx.moveTo(x, y);
                } else {
                    ctx.lineTo(x, y);
                }
            });
            
            ctx.stroke();
            
            // Draw data points
            ctx.fillStyle = color;
            data.forEach((point, index) => {
                const x = padding + (chartWidth / (data.length - 1)) * index;
                const y = height - padding - ((point.value - minValue) / valueRange) * chartHeight;
                
                ctx.beginPath();
                ctx.arc(x, y, 4, 0, 2 * Math.PI);
                ctx.fill();
            });
        }
        
        // Draw labels
        ctx.fillStyle = '#6c757d';
        ctx.font = '10px Arial';
        
        // Y-axis labels
        for (let i = 0; i <= 4; i++) {
            const value = minValue + (valueRange / 4) * (4 - i);
            const y = padding + (chartHeight / 4) * i;
            const label = this.formatChartValue(value);
            ctx.fillText(label, 5, y + 3);
        }
        
        // X-axis labels (every other point to avoid crowding)
        data.forEach((point, index) => {
            if (index % 2 === 0 || index === data.length - 1) {
                const x = padding + (chartWidth / (data.length - 1)) * index;
                const label = point.label.split('/').slice(0, 2).join('/'); // Short date format
                ctx.save();
                ctx.translate(x, height - 5);
                ctx.rotate(-Math.PI / 4);
                ctx.fillText(label, -20, 0);
                ctx.restore();
            }
        });
    }

    /**
     * Format chart values for display
     */
    formatChartValue(value) {
        if (value >= 1000000) {
            return (value / 1000000).toFixed(1) + 'M';
        } else if (value >= 1000) {
            return (value / 1000).toFixed(1) + 'K';
        }
        return Math.round(value).toString();
    }
}

// Initialize the database admin when DOM is loaded
let dbAdmin;
document.addEventListener('DOMContentLoaded', function() {
    dbAdmin = new DatabaseAdmin();
}); 