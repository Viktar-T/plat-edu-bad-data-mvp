/**
 * Schema Designer Module for InfluxDB 3.x
 * Creates new measurements with defined schema
 * Renewable Energy IoT Monitoring System
 */

class SchemaDesigner {
    constructor() {
        // Use relative URL to work with nginx proxy and avoid CORS
        this.influxUrl = window.location.protocol + '//' + window.location.host;
        this.currentMeasurement = {
            name: '',
            database: '',
            fields: [],
            tags: [],
            description: ''
        };
        this.fieldCounter = 0;
        this.tagCounter = 0;
        
        this.initializeDesigner();
    }

    /**
     * Initialize the schema designer
     */
    initializeDesigner() {
        this.setupEventListeners();
        this.loadDatabaseOptions();
    }

    /**
     * Setup event listeners for the designer interface
     */
    setupEventListeners() {
        // Measurement name validation
        const measurementNameInput = document.getElementById('measurement-name');
        if (measurementNameInput) {
            measurementNameInput.addEventListener('input', (e) => {
                this.validateMeasurementName(e.target.value);
            });
        }

        // Add field button
        const addFieldBtn = document.getElementById('add-field-btn');
        if (addFieldBtn) {
            addFieldBtn.addEventListener('click', () => this.addField());
        }

        // Add tag button
        const addTagBtn = document.getElementById('add-tag-btn');
        if (addTagBtn) {
            addTagBtn.addEventListener('click', () => this.addTag());
        }

        // Create measurement button
        const createMeasurementBtn = document.getElementById('create-measurement-btn');
        if (createMeasurementBtn) {
            createMeasurementBtn.addEventListener('click', () => this.createMeasurement());
        }

        // Preview button
        const previewBtn = document.getElementById('preview-schema-btn');
        if (previewBtn) {
            previewBtn.addEventListener('click', () => this.previewSchema());
        }

        // Reset button
        const resetBtn = document.getElementById('reset-schema-btn');
        if (resetBtn) {
            resetBtn.addEventListener('click', () => this.resetForm());
        }
    }

    /**
     * Load available databases for selection
     */
    async loadDatabaseOptions() {
        try {
            const response = await fetch(`${this.influxUrl}/api/v3/configure/database?format=json`);
            if (!response.ok) return;

            const data = await response.json();
            const databases = data.databases || [];
            
            const select = document.getElementById('measurement-database');
            if (select) {
                select.innerHTML = '<option value="">Select database...</option>' +
                    databases.map(db => `<option value="${db}">${db}</option>`).join('');
            }
        } catch (error) {
            console.error('Error loading databases:', error);
        }
    }

    /**
     * Validate measurement name
     */
    validateMeasurementName(name) {
        const validation = document.getElementById('measurement-name-validation');
        if (!validation) return;

        if (!name) {
            validation.innerHTML = '';
            return false;
        }

        // Check naming rules
        const isValid = /^[a-zA-Z][a-zA-Z0-9_]*$/.test(name);
        
        if (isValid) {
            validation.innerHTML = '<span class="validation-success">✓ Valid measurement name</span>';
            validation.className = 'form-validation success';
            return true;
        } else {
            validation.innerHTML = '<span class="validation-error">✗ Must start with letter, use only letters, numbers, and underscores</span>';
            validation.className = 'form-validation error';
            return false;
        }
    }

    /**
     * Add a new field to the measurement
     */
    addField() {
        this.fieldCounter++;
        const fieldId = `field_${this.fieldCounter}`;
        
        const field = {
            id: fieldId,
            name: '',
            type: 'float',
            required: true,
            description: '',
            defaultValue: ''
        };

        this.currentMeasurement.fields.push(field);
        this.renderFieldEditor(field);
        this.updatePreview();
    }

    /**
     * Add a new tag to the measurement
     */
    addTag() {
        this.tagCounter++;
        const tagId = `tag_${this.tagCounter}`;
        
        const tag = {
            id: tagId,
            name: '',
            required: false,
            description: '',
            possibleValues: []
        };

        this.currentMeasurement.tags.push(tag);
        this.renderTagEditor(tag);
        this.updatePreview();
    }

    /**
     * Render field editor
     */
    renderFieldEditor(field) {
        const container = document.getElementById('fields-container');
        if (!container) return;

        const fieldDiv = document.createElement('div');
        fieldDiv.className = 'field-editor';
        fieldDiv.setAttribute('data-field-id', field.id);

        fieldDiv.innerHTML = `
            <div class="field-header">
                <h4>Field Configuration</h4>
                <button type="button" class="btn-remove" onclick="schemaDesigner.removeField('${field.id}')">Remove</button>
            </div>
            <div class="field-form">
                <div class="form-row">
                    <div class="form-group">
                        <label>Field Name:</label>
                        <input type="text" class="form-control" value="${field.name}" 
                               onchange="schemaDesigner.updateField('${field.id}', 'name', this.value)"
                               placeholder="e.g., temperature, voltage">
                        <div class="field-name-validation"></div>
                    </div>
                    <div class="form-group">
                        <label>Data Type:</label>
                        <select class="form-control" onchange="schemaDesigner.updateField('${field.id}', 'type', this.value)">
                            <option value="float" ${field.type === 'float' ? 'selected' : ''}>Float</option>
                            <option value="integer" ${field.type === 'integer' ? 'selected' : ''}>Integer</option>
                            <option value="string" ${field.type === 'string' ? 'selected' : ''}>String</option>
                            <option value="boolean" ${field.type === 'boolean' ? 'selected' : ''}>Boolean</option>
                        </select>
                    </div>
                </div>
                <div class="form-row">
                    <div class="form-group">
                        <label>Description:</label>
                        <input type="text" class="form-control" value="${field.description}" 
                               onchange="schemaDesigner.updateField('${field.id}', 'description', this.value)"
                               placeholder="Brief description of this field">
                    </div>
                    <div class="form-group">
                        <label>
                            <input type="checkbox" ${field.required ? 'checked' : ''} 
                                   onchange="schemaDesigner.updateField('${field.id}', 'required', this.checked)">
                            Required Field
                        </label>
                    </div>
                </div>
                ${this.renderFieldTypeSpecificOptions(field)}
            </div>
        `;

        container.appendChild(fieldDiv);
    }

    /**
     * Render type-specific options for fields
     */
    renderFieldTypeSpecificOptions(field) {
        switch (field.type) {
            case 'float':
            case 'integer':
                return `
                    <div class="form-row">
                        <div class="form-group">
                            <label>Default Value:</label>
                            <input type="number" class="form-control" value="${field.defaultValue}" 
                                   onchange="schemaDesigner.updateField('${field.id}', 'defaultValue', this.value)"
                                   placeholder="Default numeric value">
                        </div>
                    </div>
                `;
            case 'string':
                return `
                    <div class="form-row">
                        <div class="form-group">
                            <label>Default Value:</label>
                            <input type="text" class="form-control" value="${field.defaultValue}" 
                                   onchange="schemaDesigner.updateField('${field.id}', 'defaultValue', this.value)"
                                   placeholder="Default string value">
                        </div>
                    </div>
                `;
            case 'boolean':
                return `
                    <div class="form-row">
                        <div class="form-group">
                            <label>Default Value:</label>
                            <select class="form-control" onchange="schemaDesigner.updateField('${field.id}', 'defaultValue', this.value)">
                                <option value="">No default</option>
                                <option value="true" ${field.defaultValue === 'true' ? 'selected' : ''}>True</option>
                                <option value="false" ${field.defaultValue === 'false' ? 'selected' : ''}>False</option>
                            </select>
                        </div>
                    </div>
                `;
            default:
                return '';
        }
    }

    /**
     * Render tag editor
     */
    renderTagEditor(tag) {
        const container = document.getElementById('tags-container');
        if (!container) return;

        const tagDiv = document.createElement('div');
        tagDiv.className = 'tag-editor';
        tagDiv.setAttribute('data-tag-id', tag.id);

        tagDiv.innerHTML = `
            <div class="tag-header">
                <h4>Tag Configuration</h4>
                <button type="button" class="btn-remove" onclick="schemaDesigner.removeTag('${tag.id}')">Remove</button>
            </div>
            <div class="tag-form">
                <div class="form-row">
                    <div class="form-group">
                        <label>Tag Name:</label>
                        <input type="text" class="form-control" value="${tag.name}" 
                               onchange="schemaDesigner.updateTag('${tag.id}', 'name', this.value)"
                               placeholder="e.g., sensor_id, location">
                        <div class="tag-name-validation"></div>
                    </div>
                    <div class="form-group">
                        <label>
                            <input type="checkbox" ${tag.required ? 'checked' : ''} 
                                   onchange="schemaDesigner.updateTag('${tag.id}', 'required', this.checked)">
                            Required Tag
                        </label>
                    </div>
                </div>
                <div class="form-group">
                    <label>Description:</label>
                    <input type="text" class="form-control" value="${tag.description}" 
                           onchange="schemaDesigner.updateTag('${tag.id}', 'description', this.value)"
                           placeholder="Brief description of this tag">
                </div>
                <div class="form-group">
                    <label>Possible Values (comma-separated):</label>
                    <input type="text" class="form-control" value="${tag.possibleValues.join(', ')}" 
                           onchange="schemaDesigner.updateTag('${tag.id}', 'possibleValues', this.value.split(',').map(v => v.trim()).filter(Boolean))"
                           placeholder="value1, value2, value3">
                    <small class="form-text">Leave empty for any string value</small>
                </div>
            </div>
        `;

        container.appendChild(tagDiv);
    }

    /**
     * Update field properties
     */
    updateField(fieldId, property, value) {
        const field = this.currentMeasurement.fields.find(f => f.id === fieldId);
        if (field) {
            field[property] = value;
            
            // Validate field name
            if (property === 'name') {
                this.validateFieldName(fieldId, value);
            }
            
            // Update type-specific options if type changed
            if (property === 'type') {
                this.updateFieldTypeOptions(fieldId);
            }
            
            this.updatePreview();
        }
    }

    /**
     * Update tag properties
     */
    updateTag(tagId, property, value) {
        const tag = this.currentMeasurement.tags.find(t => t.id === tagId);
        if (tag) {
            tag[property] = value;
            
            // Validate tag name
            if (property === 'name') {
                this.validateTagName(tagId, value);
            }
            
            this.updatePreview();
        }
    }

    /**
     * Validate field name
     */
    validateFieldName(fieldId, name) {
        const fieldDiv = document.querySelector(`[data-field-id="${fieldId}"]`);
        const validation = fieldDiv?.querySelector('.field-name-validation');
        if (!validation) return;

        if (!name) {
            validation.innerHTML = '';
            return false;
        }

        // Check if name is unique among fields
        const duplicateField = this.currentMeasurement.fields.find(f => f.id !== fieldId && f.name === name);
        const duplicateTag = this.currentMeasurement.tags.find(t => t.name === name);
        
        if (duplicateField || duplicateTag) {
            validation.innerHTML = '<span class="validation-error">✗ Name must be unique</span>';
            validation.className = 'form-validation error';
            return false;
        }

        // Check naming rules
        const isValid = /^[a-zA-Z][a-zA-Z0-9_]*$/.test(name);
        
        if (isValid) {
            validation.innerHTML = '<span class="validation-success">✓ Valid field name</span>';
            validation.className = 'form-validation success';
            return true;
        } else {
            validation.innerHTML = '<span class="validation-error">✗ Must start with letter, use only letters, numbers, and underscores</span>';
            validation.className = 'form-validation error';
            return false;
        }
    }

    /**
     * Validate tag name
     */
    validateTagName(tagId, name) {
        const tagDiv = document.querySelector(`[data-tag-id="${tagId}"]`);
        const validation = tagDiv?.querySelector('.tag-name-validation');
        if (!validation) return;

        if (!name) {
            validation.innerHTML = '';
            return false;
        }

        // Check if name is unique among tags and fields
        const duplicateTag = this.currentMeasurement.tags.find(t => t.id !== tagId && t.name === name);
        const duplicateField = this.currentMeasurement.fields.find(f => f.name === name);
        
        if (duplicateTag || duplicateField) {
            validation.innerHTML = '<span class="validation-error">✗ Name must be unique</span>';
            validation.className = 'form-validation error';
            return false;
        }

        // Check naming rules
        const isValid = /^[a-zA-Z][a-zA-Z0-9_]*$/.test(name);
        
        if (isValid) {
            validation.innerHTML = '<span class="validation-success">✓ Valid tag name</span>';
            validation.className = 'form-validation success';
            return true;
        } else {
            validation.innerHTML = '<span class="validation-error">✗ Must start with letter, use only letters, numbers, and underscores</span>';
            validation.className = 'form-validation error';
            return false;
        }
    }

    /**
     * Update field type-specific options
     */
    updateFieldTypeOptions(fieldId) {
        const fieldDiv = document.querySelector(`[data-field-id="${fieldId}"]`);
        const field = this.currentMeasurement.fields.find(f => f.id === fieldId);
        
        if (!fieldDiv || !field) return;

        // Find the type-specific options container and update it
        const existingOptions = fieldDiv.querySelector('.field-type-options');
        if (existingOptions) {
            existingOptions.remove();
        }

        const optionsDiv = document.createElement('div');
        optionsDiv.className = 'field-type-options';
        optionsDiv.innerHTML = this.renderFieldTypeSpecificOptions(field);
        
        fieldDiv.querySelector('.field-form').appendChild(optionsDiv);
    }

    /**
     * Remove a field
     */
    removeField(fieldId) {
        this.currentMeasurement.fields = this.currentMeasurement.fields.filter(f => f.id !== fieldId);
        
        const fieldDiv = document.querySelector(`[data-field-id="${fieldId}"]`);
        if (fieldDiv) {
            fieldDiv.remove();
        }
        
        this.updatePreview();
    }

    /**
     * Remove a tag
     */
    removeTag(tagId) {
        this.currentMeasurement.tags = this.currentMeasurement.tags.filter(t => t.id !== tagId);
        
        const tagDiv = document.querySelector(`[data-tag-id="${tagId}"]`);
        if (tagDiv) {
            tagDiv.remove();
        }
        
        this.updatePreview();
    }

    /**
     * Preview the schema
     */
    previewSchema() {
        const preview = document.getElementById('schema-preview');
        if (!preview) return;

        // Update current measurement info from form
        this.currentMeasurement.name = document.getElementById('measurement-name')?.value || '';
        this.currentMeasurement.database = document.getElementById('measurement-database')?.value || '';
        this.currentMeasurement.description = document.getElementById('measurement-description')?.value || '';

        const lineProtocolExample = this.generateLineProtocolExample();
        const schemaValidation = this.validateSchema();

        preview.innerHTML = `
            <div class="schema-preview-content">
                <h3>📋 Schema Preview</h3>
                
                <div class="preview-section">
                    <h4>Measurement Information</h4>
                    <div class="info-grid">
                        <div class="info-item"><strong>Name:</strong> ${this.currentMeasurement.name || 'Not specified'}</div>
                        <div class="info-item"><strong>Database:</strong> ${this.currentMeasurement.database || 'Not specified'}</div>
                        <div class="info-item"><strong>Fields:</strong> ${this.currentMeasurement.fields.length}</div>
                        <div class="info-item"><strong>Tags:</strong> ${this.currentMeasurement.tags.length}</div>
                    </div>
                    ${this.currentMeasurement.description ? `<p><strong>Description:</strong> ${this.currentMeasurement.description}</p>` : ''}
                </div>

                <div class="preview-section">
                    <h4>Schema Validation</h4>
                    <div class="validation-results">
                        ${schemaValidation.map(v => `
                            <div class="validation-item ${v.type}">
                                ${v.type === 'error' ? '❌' : v.type === 'warning' ? '⚠️' : '✅'} ${v.message}
                            </div>
                        `).join('')}
                    </div>
                </div>

                <div class="preview-section">
                    <h4>Example Line Protocol</h4>
                    <div class="line-protocol-example">
                        <code>${lineProtocolExample}</code>
                    </div>
                </div>

                <div class="preview-section">
                    <h4>Field Definitions</h4>
                    <div class="field-definitions">
                        ${this.currentMeasurement.fields.map(field => `
                            <div class="field-def">
                                <strong>${field.name}</strong> (${field.type})
                                ${field.required ? '<span class="required">*</span>' : ''}
                                ${field.description ? `<br><small>${field.description}</small>` : ''}
                            </div>
                        `).join('')}
                    </div>
                </div>

                ${this.currentMeasurement.tags.length > 0 ? `
                <div class="preview-section">
                    <h4>Tag Definitions</h4>
                    <div class="tag-definitions">
                        ${this.currentMeasurement.tags.map(tag => `
                            <div class="tag-def">
                                <strong>${tag.name}</strong>
                                ${tag.required ? '<span class="required">*</span>' : ''}
                                ${tag.possibleValues.length > 0 ? `<br><small>Values: ${tag.possibleValues.join(', ')}</small>` : ''}
                                ${tag.description ? `<br><small>${tag.description}</small>` : ''}
                            </div>
                        `).join('')}
                    </div>
                </div>
                ` : ''}
            </div>
        `;
    }

    /**
     * Generate example line protocol
     */
    generateLineProtocolExample() {
        if (!this.currentMeasurement.name) {
            return 'measurement_name,tag1=value1 field1=1.0 timestamp';
        }

        const measurement = this.currentMeasurement.name;
        const tags = this.currentMeasurement.tags.map(tag => 
            `${tag.name}=${tag.possibleValues[0] || 'value'}`
        ).join(',');
        
        const fields = this.currentMeasurement.fields.map(field => {
            let exampleValue;
            switch (field.type) {
                case 'float': exampleValue = '1.5'; break;
                case 'integer': exampleValue = '10'; break;
                case 'boolean': exampleValue = 'true'; break;
                case 'string': exampleValue = '"example"'; break;
                default: exampleValue = 'value';
            }
            return `${field.name}=${exampleValue}`;
        }).join(',');

        return `${measurement}${tags ? ',' + tags : ''} ${fields || 'value=1'} ${Date.now()}000000`;
    }

    /**
     * Validate the current schema
     */
    validateSchema() {
        const validation = [];

        // Check measurement name
        if (!this.currentMeasurement.name) {
            validation.push({ type: 'error', message: 'Measurement name is required' });
        } else if (!this.validateMeasurementName(this.currentMeasurement.name)) {
            validation.push({ type: 'error', message: 'Invalid measurement name format' });
        }

        // Check database selection
        if (!this.currentMeasurement.database) {
            validation.push({ type: 'error', message: 'Database selection is required' });
        }

        // Check fields
        if (this.currentMeasurement.fields.length === 0) {
            validation.push({ type: 'warning', message: 'No fields defined. At least one field is recommended' });
        }

        // Check for duplicate names
        const allNames = [
            ...this.currentMeasurement.fields.map(f => f.name),
            ...this.currentMeasurement.tags.map(t => t.name)
        ];
        const duplicates = allNames.filter((name, index) => allNames.indexOf(name) !== index);
        if (duplicates.length > 0) {
            validation.push({ type: 'error', message: `Duplicate names found: ${[...new Set(duplicates)].join(', ')}` });
        }

        // Check for empty names
        const emptyFields = this.currentMeasurement.fields.filter(f => !f.name);
        const emptyTags = this.currentMeasurement.tags.filter(t => !t.name);
        if (emptyFields.length > 0 || emptyTags.length > 0) {
            validation.push({ type: 'error', message: 'All fields and tags must have names' });
        }

        if (validation.length === 0) {
            validation.push({ type: 'success', message: 'Schema is valid and ready to create' });
        }

        return validation;
    }

    /**
     * Create the measurement
     */
    async createMeasurement() {
        // Update measurement from form
        this.currentMeasurement.name = document.getElementById('measurement-name')?.value || '';
        this.currentMeasurement.database = document.getElementById('measurement-database')?.value || '';
        
        const validation = this.validateSchema();
        const hasErrors = validation.some(v => v.type === 'error');
        
        if (hasErrors) {
            this.showError('Please fix validation errors before creating the measurement');
            return;
        }

        try {
            this.showLoading('Creating measurement...');
            
            // Generate sample data to establish schema
            const sampleData = this.generateSampleData();
            
            // Write sample data to establish the measurement
            const response = await fetch(
                `${this.influxUrl}/api/v3/write_lp?db=${encodeURIComponent(this.currentMeasurement.database)}`,
                {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'text/plain',
                    },
                    body: sampleData
                }
            );

            if (!response.ok) {
                throw new Error('Failed to create measurement');
            }

            this.showSuccess(`Measurement "${this.currentMeasurement.name}" created successfully!`);
            this.resetForm();
            
            // Refresh schema browser if it exists
            if (window.schemaBrowser) {
                window.schemaBrowser.refreshSchema();
            }
            
        } catch (error) {
            this.showError(`Error creating measurement: ${error.message}`);
        }
    }

    /**
     * Generate sample data for the measurement
     */
    generateSampleData() {
        const measurement = this.currentMeasurement.name;
        const tags = this.currentMeasurement.tags.map(tag => {
            const value = tag.possibleValues.length > 0 ? tag.possibleValues[0] : 'sample';
            return `${tag.name}=${value}`;
        }).join(',');
        
        const fields = this.currentMeasurement.fields.map(field => {
            let sampleValue;
            switch (field.type) {
                case 'float': sampleValue = field.defaultValue || '0.0'; break;
                case 'integer': sampleValue = field.defaultValue || '0'; break;
                case 'boolean': sampleValue = field.defaultValue || 'false'; break;
                case 'string': sampleValue = `"${field.defaultValue || 'sample'}"`;break;
                default: sampleValue = '0';
            }
            return `${field.name}=${sampleValue}`;
        }).join(',');

        return `${measurement}${tags ? ',' + tags : ''} ${fields} ${Date.now()}000000`;
    }

    /**
     * Reset the form
     */
    resetForm() {
        this.currentMeasurement = {
            name: '',
            database: '',
            fields: [],
            tags: [],
            description: ''
        };
        this.fieldCounter = 0;
        this.tagCounter = 0;

        // Clear form inputs
        const inputs = ['measurement-name', 'measurement-database', 'measurement-description'];
        inputs.forEach(id => {
            const element = document.getElementById(id);
            if (element) element.value = '';
        });

        // Clear containers
        const containers = ['fields-container', 'tags-container'];
        containers.forEach(id => {
            const container = document.getElementById(id);
            if (container) container.innerHTML = '';
        });

        // Clear preview
        const preview = document.getElementById('schema-preview');
        if (preview) {
            preview.innerHTML = '<p>Configure your measurement schema above to see a preview.</p>';
        }

        this.hideNotifications();
    }

    /**
     * Update preview
     */
    updatePreview() {
        // Auto-update preview if it's visible
        const preview = document.getElementById('schema-preview');
        if (preview && preview.innerHTML.includes('Schema Preview')) {
            this.previewSchema();
        }
    }

    /**
     * UI Helper methods
     */
    showLoading(message) {
        const statusElement = document.getElementById('schema-designer-status');
        if (statusElement) {
            statusElement.innerHTML = `<div class="status info">${message}</div>`;
        }
    }

    showSuccess(message) {
        const statusElement = document.getElementById('schema-designer-status');
        if (statusElement) {
            statusElement.innerHTML = `<div class="status success">${message}</div>`;
        }
    }

    showError(message) {
        const statusElement = document.getElementById('schema-designer-status');
        if (statusElement) {
            statusElement.innerHTML = `<div class="status error">${message}</div>`;
        }
    }

    hideNotifications() {
        const statusElement = document.getElementById('schema-designer-status');
        if (statusElement) {
            statusElement.innerHTML = '';
        }
    }
}

// Initialize schema designer when DOM is loaded
let schemaDesigner;
document.addEventListener('DOMContentLoaded', function() {
    // Will be initialized when schema section is first accessed
}); 