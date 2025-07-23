/**
 * Schema Browser Module for InfluxDB 3.x
 * Discovers and displays database schema information
 * Renewable Energy IoT Monitoring System
 */

class SchemaBrowser {
    constructor() {
        // Use relative URL to work with nginx proxy and avoid CORS
        this.influxUrl = window.location.protocol + '//' + window.location.host;
        this.schemaCache = new Map();
        this.treeView = null;
        this.currentDatabase = null;
        this.currentMeasurement = null;
        
        this.initializeBrowser();
    }

    /**
     * Initialize the schema browser
     */
    initializeBrowser() {
        this.setupTreeView();
        this.loadDatabases();
    }

    /**
     * Setup the tree view for schema navigation
     */
    setupTreeView() {
        this.treeView = new TreeView('schema-tree', {
            onNodeClick: (nodeId, nodeData) => this.handleNodeClick(nodeId, nodeData),
            onNodeExpand: (nodeId, nodeData) => this.handleNodeExpand(nodeId, nodeData),
            showIcons: true
        });
    }

    /**
     * Load all databases and populate tree
     */
    async loadDatabases() {
        try {
            this.showLoading('Loading databases...');
            
            const response = await fetch(`${this.influxUrl}/api/v3/configure/database?format=json`);
            if (!response.ok) {
                throw new Error('Failed to load databases');
            }

            const data = await response.json();
            const databases = data.databases || [];
            
            const treeData = databases.map(dbName => ({
                id: `db_${dbName}`,
                label: dbName,
                type: 'database',
                name: dbName,
                children: [{
                    id: `${dbName}_loading`,
                    label: 'Loading measurements...',
                    type: 'loading',
                    loading: true
                }]
            }));

            this.treeView.render(treeData);
            this.hideLoading();
            
        } catch (error) {
            this.showError(`Error loading databases: ${error.message}`);
        }
    }

    /**
     * Handle tree node clicks
     */
    async handleNodeClick(nodeId, nodeData) {
        if (nodeData.type === 'database') {
            this.currentDatabase = nodeData.name;
            await this.loadDatabaseInfo(nodeData.name);
            
        } else if (nodeData.type === 'measurement') {
            this.currentMeasurement = nodeData.name;
            await this.loadMeasurementInfo(nodeData.database, nodeData.name);
            
        } else if (nodeData.type === 'field' || nodeData.type === 'tag') {
            await this.loadFieldInfo(nodeData);
        }
    }

    /**
     * Handle tree node expansion
     */
    async handleNodeExpand(nodeId, nodeData) {
        if (nodeData.type === 'database') {
            await this.loadMeasurements(nodeData.name);
        } else if (nodeData.type === 'measurement') {
            await this.loadMeasurementFields(nodeData.database, nodeData.name);
        }
    }

    /**
     * Load measurements for a database
     */
    async loadMeasurements(dbName) {
        try {
            const cacheKey = `measurements_${dbName}`;
            
            if (this.schemaCache.has(cacheKey)) {
                this.updateDatabaseNode(dbName, this.schemaCache.get(cacheKey));
                return;
            }

            const measurements = await this.discoverMeasurements(dbName);
            this.schemaCache.set(cacheKey, measurements);
            this.updateDatabaseNode(dbName, measurements);
            
        } catch (error) {
            console.error('Error loading measurements:', error);
            this.updateDatabaseNode(dbName, []);
        }
    }

    /**
     * Discover measurements in a database
     */
    async discoverMeasurements(dbName) {
        try {
            const query = 'SHOW MEASUREMENTS';
            const response = await fetch(
                `${this.influxUrl}/api/v3/query_sql?db=${encodeURIComponent(dbName)}&q=${encodeURIComponent(query)}`
            );

            if (!response.ok) {
                return [];
            }

            const resultText = await response.text();
            const measurements = this.parseMeasurements(resultText);
            
            // Get record counts for each measurement
            const measurementsWithCounts = await Promise.all(
                measurements.map(async (measurement) => {
                    const count = await this.getMeasurementRecordCount(dbName, measurement);
                    return {
                        name: measurement,
                        recordCount: count
                    };
                })
            );

            return measurementsWithCounts;
            
        } catch (error) {
            console.error('Error discovering measurements:', error);
            return [];
        }
    }

    /**
     * Parse measurements from SHOW MEASUREMENTS result
     */
    parseMeasurements(resultText) {
        try {
            const lines = resultText.split('\n').filter(line => line.trim());
            if (lines.length <= 1) return []; // No data or header only
            
            // Skip header line, get measurement names
            // Handle both tab-separated and comma-separated formats
            return lines.slice(1).map(line => {
                // Split by tab first, then by comma if no tabs
                const parts = line.includes('\t') ? line.split('\t') : line.split(',');
                return parts[0].trim();
            }).filter(Boolean);
        } catch (error) {
            console.error('Error parsing measurements:', error);
            return [];
        }
    }

    /**
     * Get record count for a measurement
     */
    async getMeasurementRecordCount(dbName, measurement) {
        try {
            const query = `SELECT COUNT(*) FROM ${measurement}`;
            const response = await fetch(
                `${this.influxUrl}/api/v3/query_sql?db=${encodeURIComponent(dbName)}&q=${encodeURIComponent(query)}`
            );

            if (!response.ok) return 0;

            const resultText = await response.text();
            const lines = resultText.split('\n').filter(line => line.trim());
            if (lines.length > 1) {
                const countLine = lines[1];
                const match = countLine.match(/\d+/);
                return match ? parseInt(match[0]) : 0;
            }
            return 0;
            
        } catch (error) {
            return 0;
        }
    }

    /**
     * Update database node with measurements
     */
    updateDatabaseNode(dbName, measurements) {
        const nodeId = `db_${dbName}`;
        
        // Create measurement nodes
        const measurementNodes = measurements.length > 0 
            ? measurements.map(measurement => ({
                id: `${dbName}_${measurement.name}`,
                label: measurement.name,
                type: 'measurement',
                name: measurement.name,
                database: dbName,
                metadata: `${measurement.recordCount} records`,
                children: [{
                    id: `${dbName}_${measurement.name}_loading`,
                    label: 'Loading fields...',
                    type: 'loading',
                    loading: true
                }]
            }))
            : [{
                id: `${dbName}_empty`,
                label: 'No measurements found',
                type: 'empty'
            }];

        // Update the tree view
        const databaseNode = document.querySelector(`[data-node-id="${nodeId}"]`);
        if (databaseNode) {
            const childrenContainer = databaseNode.querySelector('.tree-children');
            if (childrenContainer) {
                childrenContainer.innerHTML = '';
                
                measurementNodes.forEach(node => {
                    const childElement = this.treeView.createTreeNode(node, 1);
                    childrenContainer.appendChild(childElement);
                });
            }
        }
    }

    /**
     * Load fields for a measurement
     */
    async loadMeasurementFields(dbName, measurement) {
        try {
            const cacheKey = `fields_${dbName}_${measurement}`;
            
            if (this.schemaCache.has(cacheKey)) {
                this.updateMeasurementNode(dbName, measurement, this.schemaCache.get(cacheKey));
                return;
            }

            const schema = await this.discoverMeasurementSchema(dbName, measurement);
            this.schemaCache.set(cacheKey, schema);
            this.updateMeasurementNode(dbName, measurement, schema);
            
        } catch (error) {
            console.error('Error loading measurement fields:', error);
        }
    }

    /**
     * Discover schema for a specific measurement
     */
    async discoverMeasurementSchema(dbName, measurement) {
        try {
            // Get a sample of records to analyze schema
            const query = `SELECT * FROM ${measurement} LIMIT 10`;
            const response = await fetch(
                `${this.influxUrl}/api/v3/query_sql?db=${encodeURIComponent(dbName)}&q=${encodeURIComponent(query)}`
            );

            if (!response.ok) {
                return { fields: [], tags: [] };
            }

            const resultText = await response.text();
            const schema = this.parseSchemaFromResults(resultText);
            
            // Get time range
            const timeRange = await this.getMeasurementTimeRange(dbName, measurement);
            schema.timeRange = timeRange;
            
            return schema;
            
        } catch (error) {
            console.error('Error discovering schema:', error);
            return { fields: [], tags: [] };
        }
    }

    /**
     * Parse schema information from query results
     */
    parseSchemaFromResults(resultText) {
        const lines = resultText.split('\n').filter(line => line.trim());
        
        if (lines.length < 2) {
            return { fields: [], tags: [] };
        }

        // Parse header to get column names
        const headers = lines[0].split('\t').map(h => h.trim());
        
        // Analyze data types from sample records
        const fields = [];
        const tags = [];
        
        // Sample data lines (skip header)
        const dataLines = lines.slice(1).filter(line => line.trim());
        
        headers.forEach((header, index) => {
            if (header === 'time') return; // Skip time column
            
            // Analyze column values to determine type
            const values = dataLines.map(line => {
                const cols = line.split('\t');
                return cols[index] ? cols[index].trim() : '';
            }).filter(Boolean);
            
            const dataType = this.inferDataType(values);
            const isTag = this.isTagColumn(values);
            
            const fieldInfo = {
                name: header,
                type: dataType,
                sampleValues: values.slice(0, 3), // First 3 sample values
                distinctCount: new Set(values).size
            };
            
            if (isTag) {
                tags.push(fieldInfo);
            } else {
                fields.push(fieldInfo);
            }
        });

        return { fields, tags };
    }

    /**
     * Infer data type from sample values
     */
    inferDataType(values) {
        if (values.length === 0) return 'unknown';
        
        // Check if all values are numbers
        const numericValues = values.filter(v => !isNaN(parseFloat(v)) && isFinite(v));
        if (numericValues.length === values.length) {
            // Check if integers or floats
            const hasDecimals = values.some(v => v.includes('.'));
            return hasDecimals ? 'float' : 'integer';
        }
        
        // Check if boolean
        const booleanValues = values.filter(v => 
            v.toLowerCase() === 'true' || v.toLowerCase() === 'false'
        );
        if (booleanValues.length === values.length) {
            return 'boolean';
        }
        
        return 'string';
    }

    /**
     * Determine if a column contains tag data (low cardinality)
     */
    isTagColumn(values) {
        const distinctCount = new Set(values).size;
        const totalCount = values.length;
        
        // If less than 50% distinct values and less than 20 distinct values total
        return distinctCount < totalCount * 0.5 && distinctCount < 20;
    }

    /**
     * Get time range for a measurement
     */
    async getMeasurementTimeRange(dbName, measurement) {
        try {
            const minQuery = `SELECT MIN(time) as min_time FROM ${measurement}`;
            const maxQuery = `SELECT MAX(time) as max_time FROM ${measurement}`;
            
            const [minResponse, maxResponse] = await Promise.all([
                fetch(`${this.influxUrl}/api/v3/query_sql?db=${encodeURIComponent(dbName)}&q=${encodeURIComponent(minQuery)}`),
                fetch(`${this.influxUrl}/api/v3/query_sql?db=${encodeURIComponent(dbName)}&q=${encodeURIComponent(maxQuery)}`)
            ]);

            const minText = await minResponse.text();
            const maxText = await maxResponse.text();
            
            const minTime = this.parseTimeFromResult(minText);
            const maxTime = this.parseTimeFromResult(maxText);
            
            return { minTime, maxTime };
            
        } catch (error) {
            return { minTime: null, maxTime: null };
        }
    }

    /**
     * Parse time value from query result
     */
    parseTimeFromResult(resultText) {
        const lines = resultText.split('\n').filter(line => line.trim());
        if (lines.length > 1) {
            const dataLine = lines[1];
            const timeValue = dataLine.split('\t')[0];
            return timeValue ? new Date(timeValue).toISOString() : null;
        }
        return null;
    }

    /**
     * Update measurement node with field information
     */
    updateMeasurementNode(dbName, measurement, schema) {
        const nodeId = `${dbName}_${measurement}`;
        
        // Create field and tag nodes
        const fieldNodes = schema.fields && schema.fields.length > 0 
            ? schema.fields.map(field => ({
                id: `${nodeId}_field_${field.name}`,
                label: field.name,
                type: 'field',
                name: field.name,
                database: dbName,
                measurement: measurement,
                fieldType: field.type,
                metadata: `${field.type}`,
                data: field
            }))
            : [];

        const tagNodes = schema.tags && schema.tags.length > 0 
            ? schema.tags.map(tag => ({
                id: `${nodeId}_tag_${tag.name}`,
                label: tag.name,
                type: 'tag',
                name: tag.name,
                database: dbName,
                measurement: measurement,
                fieldType: tag.type,
                metadata: `tag (${tag.distinctCount} values)`,
                data: tag
            }))
            : [];

        const allNodes = [...fieldNodes, ...tagNodes];
        
        // If no fields or tags found, show empty state
        if (allNodes.length === 0) {
            allNodes.push({
                id: `${nodeId}_empty`,
                label: 'No fields or tags found',
                type: 'empty'
            });
        }

        // Update the tree view
        const measurementNode = document.querySelector(`[data-node-id="${nodeId}"]`);
        if (measurementNode) {
            const childrenContainer = measurementNode.querySelector('.tree-children');
            if (childrenContainer) {
                childrenContainer.innerHTML = '';
                
                allNodes.forEach(node => {
                    const childElement = this.treeView.createTreeNode(node, 2);
                    childrenContainer.appendChild(childElement);
                });
            }
        }
    }

    /**
     * Load detailed database information
     */
    async loadDatabaseInfo(dbName) {
        this.showDatabaseInfo({
            name: dbName,
            measurements: await this.getMeasurementCount(dbName),
            totalRecords: await this.getTotalRecords(dbName),
            sizeEstimate: await this.estimateDatabaseSize(dbName)
        });
    }

    /**
     * Load detailed measurement information
     */
    async loadMeasurementInfo(dbName, measurement) {
        const schema = await this.discoverMeasurementSchema(dbName, measurement);
        const recordCount = await this.getMeasurementRecordCount(dbName, measurement);
        const timeRange = schema.timeRange;

        this.showMeasurementInfo({
            name: measurement,
            database: dbName,
            recordCount: recordCount,
            fields: schema.fields,
            tags: schema.tags,
            timeRange: timeRange
        });
    }

    /**
     * Load detailed field information
     */
    async loadFieldInfo(fieldData) {
        const stats = await this.getFieldStatistics(
            fieldData.database, 
            fieldData.measurement, 
            fieldData.name, 
            fieldData.fieldType
        );
        
        this.showFieldInfo({
            ...fieldData.data,
            ...stats,
            database: fieldData.database,
            measurement: fieldData.measurement
        });
    }

    /**
     * Get field statistics
     */
    async getFieldStatistics(dbName, measurement, fieldName, fieldType) {
        try {
            let query;
            
            if (fieldType === 'float' || fieldType === 'integer') {
                query = `SELECT MIN(${fieldName}) as min_val, MAX(${fieldName}) as max_val, AVG(${fieldName}) as avg_val FROM ${measurement}`;
            } else {
                query = `SELECT COUNT(DISTINCT ${fieldName}) as distinct_count FROM ${measurement}`;
            }
            
            const response = await fetch(
                `${this.influxUrl}/api/v3/query_sql?db=${encodeURIComponent(dbName)}&q=${encodeURIComponent(query)}`
            );

            if (!response.ok) return {};

            const resultText = await response.text();
            return this.parseStatistics(resultText, fieldType);
            
        } catch (error) {
            return {};
        }
    }

    /**
     * Parse field statistics from query result
     */
    parseStatistics(resultText, fieldType) {
        const lines = resultText.split('\n').filter(line => line.trim());
        if (lines.length < 2) return {};

        const dataLine = lines[1];
        const values = dataLine.split('\t');

        if (fieldType === 'float' || fieldType === 'integer') {
            return {
                minValue: values[0] ? parseFloat(values[0]) : null,
                maxValue: values[1] ? parseFloat(values[1]) : null,
                avgValue: values[2] ? parseFloat(values[2]) : null
            };
        } else {
            return {
                distinctCount: values[0] ? parseInt(values[0]) : 0
            };
        }
    }

    /**
     * Helper methods for database statistics
     */
    async getMeasurementCount(dbName) {
        const measurements = await this.discoverMeasurements(dbName);
        return measurements.length;
    }

    async getTotalRecords(dbName) {
        const measurements = await this.discoverMeasurements(dbName);
        return measurements.reduce((total, m) => total + m.recordCount, 0);
    }

    async estimateDatabaseSize(dbName) {
        const totalRecords = await this.getTotalRecords(dbName);
        return totalRecords * 100; // Rough estimate: 100 bytes per record
    }

    /**
     * UI Helper methods
     */
    showLoading(message) {
        const loadingElement = document.getElementById('schema-loading');
        if (loadingElement) {
            loadingElement.innerHTML = `<div class="loading">${message}</div>`;
            loadingElement.style.display = 'block';
        }
    }

    hideLoading() {
        const loadingElement = document.getElementById('schema-loading');
        if (loadingElement) {
            loadingElement.style.display = 'none';
        }
    }

    showError(message) {
        const errorElement = document.getElementById('schema-error');
        if (errorElement) {
            errorElement.innerHTML = `<div class="status error">${message}</div>`;
            errorElement.style.display = 'block';
        }
        this.hideLoading();
    }

    showDatabaseInfo(dbInfo) {
        const infoElement = document.getElementById('schema-info');
        if (!infoElement) return;

        infoElement.innerHTML = `
            <div class="schema-info-content">
                <h3>🗃️ Database: ${dbInfo.name}</h3>
                <div class="info-grid">
                    <div class="info-item">
                        <strong>Measurements:</strong> ${dbInfo.measurements}
                    </div>
                    <div class="info-item">
                        <strong>Total Records:</strong> ${dbInfo.totalRecords.toLocaleString()}
                    </div>
                    <div class="info-item">
                        <strong>Estimated Size:</strong> ${this.formatBytes(dbInfo.sizeEstimate)}
                    </div>
                </div>
            </div>
        `;
    }

    showMeasurementInfo(measurementInfo) {
        const infoElement = document.getElementById('schema-info');
        if (!infoElement) return;

        infoElement.innerHTML = `
            <div class="schema-info-content">
                <h3>📊 Measurement: ${measurementInfo.name}</h3>
                <div class="info-grid">
                    <div class="info-item">
                        <strong>Database:</strong> ${measurementInfo.database}
                    </div>
                    <div class="info-item">
                        <strong>Records:</strong> ${measurementInfo.recordCount.toLocaleString()}
                    </div>
                    <div class="info-item">
                        <strong>Fields:</strong> ${measurementInfo.fields.length}
                    </div>
                    <div class="info-item">
                        <strong>Tags:</strong> ${measurementInfo.tags.length}
                    </div>
                </div>
                
                ${measurementInfo.timeRange.minTime ? `
                <div class="time-range">
                    <strong>Time Range:</strong><br>
                    From: ${new Date(measurementInfo.timeRange.minTime).toLocaleString()}<br>
                    To: ${new Date(measurementInfo.timeRange.maxTime).toLocaleString()}
                </div>
                ` : ''}
                
                <div class="field-list">
                    <h4>Fields:</h4>
                    ${measurementInfo.fields.map(field => `
                        <div class="field-item">
                            <span class="field-name">${field.name}</span>
                            <span class="field-type">${field.type}</span>
                        </div>
                    `).join('')}
                </div>
                
                ${measurementInfo.tags.length > 0 ? `
                <div class="tag-list">
                    <h4>Tags:</h4>
                    ${measurementInfo.tags.map(tag => `
                        <div class="tag-item">
                            <span class="tag-name">${tag.name}</span>
                            <span class="tag-cardinality">${tag.distinctCount} values</span>
                        </div>
                    `).join('')}
                </div>
                ` : ''}
            </div>
        `;
    }

    showFieldInfo(fieldInfo) {
        const infoElement = document.getElementById('schema-info');
        if (!infoElement) return;

        infoElement.innerHTML = `
            <div class="schema-info-content">
                <h3>📋 ${fieldInfo.type === 'tag' ? 'Tag' : 'Field'}: ${fieldInfo.name}</h3>
                <div class="info-grid">
                    <div class="info-item">
                        <strong>Measurement:</strong> ${fieldInfo.measurement}
                    </div>
                    <div class="info-item">
                        <strong>Data Type:</strong> ${fieldInfo.type}
                    </div>
                    <div class="info-item">
                        <strong>Distinct Values:</strong> ${fieldInfo.distinctCount}
                    </div>
                </div>
                
                ${fieldInfo.minValue !== undefined ? `
                <div class="statistics">
                    <h4>Statistics:</h4>
                    <div class="stat-grid">
                        <div class="stat-item">Min: ${fieldInfo.minValue}</div>
                        <div class="stat-item">Max: ${fieldInfo.maxValue}</div>
                        <div class="stat-item">Avg: ${fieldInfo.avgValue?.toFixed(2)}</div>
                    </div>
                </div>
                ` : ''}
                
                <div class="sample-values">
                    <h4>Sample Values:</h4>
                    ${fieldInfo.sampleValues.map(value => `<span class="sample-value">${value}</span>`).join(', ')}
                </div>
            </div>
        `;
    }

    formatBytes(bytes) {
        if (bytes === 0) return '0 B';
        const k = 1024;
        const sizes = ['B', 'KB', 'MB', 'GB'];
        const i = Math.floor(Math.log(bytes) / Math.log(k));
        return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
    }

    /**
     * Search functionality
     */
    searchSchema(searchTerm) {
        if (this.treeView) {
            this.treeView.filter(searchTerm);
        }
    }

    /**
     * Refresh schema cache
     */
    refreshSchema() {
        this.schemaCache.clear();
        this.loadDatabases();
    }
}

// Initialize schema browser when DOM is loaded
let schemaBrowser;
document.addEventListener('DOMContentLoaded', function() {
    // Will be initialized when schema section is first accessed
}); 