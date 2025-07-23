# InfluxDB 3.x Web Interface

A comprehensive web-based administration interface for InfluxDB 3.x, specifically designed for the Renewable Energy IoT Monitoring System.

## Features

### 🗄️ Database Administration
- **Database Management**: Create, delete, and list databases
- **Connection Testing**: Real-time connection status monitoring
- **Statistics Dashboard**: Database metrics and performance indicators
- **Backup & Restore**: Basic backup/restore functionality
- **Progress Indicators**: Visual feedback for long-running operations

### 📊 Schema Management
- **Schema Browser**: Interactive tree view of database schema
- **Measurement Explorer**: Browse measurements, fields, and tags
- **Schema Designer**: Create new measurements with field definitions
- **Data Type Validation**: Automatic field type detection
- **Sample Data Preview**: View sample data for measurements

### 🔍 Advanced Query Management
- **SQL Editor**: CodeMirror-powered editor with syntax highlighting
- **Auto-completion**: Context-aware suggestions for databases, measurements, and SQL keywords
- **Query Execution**: Async query execution with progress tracking
- **Result Display**: Formatted table display with pagination
- **Export Functionality**: CSV and JSON export of query results
- **Query History**: Persistent history with localStorage
- **Saved Queries**: Named query storage with usage statistics
- **Query Templates**: Pre-built queries for renewable energy data
- **Multiple Tabs**: Support for multiple query sessions (coming soon)

### 🔧 Additional Features
- **Responsive Design**: Mobile-friendly interface
- **Error Handling**: Comprehensive error reporting
- **Notifications**: Toast notifications for user feedback
- **Keyboard Shortcuts**: Productivity shortcuts (Ctrl+Enter to execute)

## Quick Start

1. **Prerequisites**
   - InfluxDB 3.x running on `localhost:8086`
   - Modern web browser with JavaScript enabled

2. **Setup**
   ```bash
   # Clone the repository
   git clone <repository-url>
   cd influxdb-web-interface
   
   # Serve the files (using Python 3)
   python -m http.server 8080
   
   # Or using Node.js
   npx serve .
   ```

3. **Access**
   - Open `http://localhost:8080` in your browser
   - The interface will automatically detect and connect to InfluxDB

## Query Management Guide

### SQL Editor

The advanced SQL editor provides:

- **Syntax Highlighting**: SQL keywords, functions, and identifiers
- **Auto-completion**: Press `Ctrl+Space` for suggestions
- **Formatting**: Use the Format button for SQL beautification
- **Execution**: Press `Ctrl+Enter` or click Execute button

### Query Templates

Pre-built templates for renewable energy monitoring:

1. **Show Databases** - List all available databases
2. **Show Measurements** - List measurements in current database
3. **Recent Photovoltaic Data** - Latest solar panel readings
4. **Wind Turbine Analytics** - Wind power analysis queries
5. **Energy Storage Status** - Battery monitoring queries
6. **Biogas Production** - Biogas plant metrics
7. **Heat Boiler Efficiency** - Boiler performance queries

### Query History

- **Automatic Logging**: All executed queries are automatically saved
- **Search & Filter**: Find queries by content or database
- **Re-execution**: One-click to re-run previous queries
- **Export/Import**: Save and share query collections

### Saved Queries

- **Named Storage**: Save frequently used queries with descriptions
- **Usage Statistics**: Track how often queries are used
- **Favorites**: Mark important queries for quick access
- **Organization**: Search and categorize saved queries

## API Integration

### InfluxDB 3.x Endpoints

The interface uses these InfluxDB API endpoints:

- `GET /api/v3/configure/database` - Database management
- `GET /api/v3/query_sql` - SQL query execution
- `POST /api/v3/configure/database` - Database creation

### Database Schema

Supports renewable energy measurements:

- `photovoltaic_data` - Solar panel metrics
- `wind_turbine_data` - Wind turbine performance
- `energy_storage_data` - Battery system status
- `biogas_plant_data` - Biogas production metrics
- `heat_boiler_data` - Boiler efficiency data

## Development

### Project Structure

```
influxdb-web-interface/
├── index.html              # Main application
├── css/
│   └── admin.css           # Comprehensive styling
├── js/
│   ├── database-admin.js   # Database administration
│   ├── schema-browser.js   # Schema exploration
│   ├── schema-designer.js  # Schema creation
│   ├── query-editor.js     # SQL editor with CodeMirror
│   ├── query-executor.js   # Query execution & results
│   └── query-history.js    # History & saved queries
├── components/
│   └── tree-view.js        # Reusable tree component
└── README.md
```

### Adding New Features

1. **New Query Templates**:
   ```javascript
   // Add to initializeQueryTemplates() function
   {
       name: 'Your Template Name',
       query: 'SELECT * FROM your_measurement',
       description: 'Template description'
   }
   ```

2. **Custom Auto-completion**:
   ```javascript
   // Extend getCompletions() in query-editor.js
   if (contextCondition) {
       completions.push({
           text: 'your_suggestion',
           displayText: '🔧 your_suggestion',
           className: 'cm-custom'
       });
   }
   ```

3. **New Result Formatters**:
   ```javascript
   // Add to createResultsTable() in query-executor.js
   if (header === 'your_field') {
       td.textContent = customFormatter(value);
       td.className += ' custom-cell';
   }
   ```

### Browser Compatibility

- **Chrome**: Full support (recommended)
- **Firefox**: Full support
- **Safari**: Full support
- **Edge**: Full support
- **Mobile**: Responsive design for tablets/phones

### Performance Considerations

- **Pagination**: Large result sets are automatically paginated
- **Caching**: Auto-completion data is cached for performance
- **Lazy Loading**: Schema data loaded on-demand
- **Memory Management**: Query history limited to prevent memory issues

## Troubleshooting

### Common Issues

1. **Connection Failed**
   - Verify InfluxDB is running on localhost:8086
   - Check CORS settings if using different ports
   - Ensure InfluxDB 3.x API is enabled

2. **CodeMirror Not Loading**
   - Check internet connection (CDN dependency)
   - Verify JavaScript is enabled
   - Fallback editor will be used automatically

3. **Query Execution Errors**
   - Validate SQL syntax
   - Ensure database exists
   - Check field/measurement names

4. **Export Not Working**
   - Check browser permissions for downloads
   - Ensure results contain data
   - Try different export format

### Debug Mode

Enable debug logging in browser console:
```javascript
localStorage.setItem('debug', 'true');
```

## Configuration

### Environment Variables

Configure InfluxDB connection in the JavaScript:

```javascript
// In query-editor.js and query-executor.js
this.influxUrl = 'http://your-influxdb-host:8086';
```

### Customization

- **Themes**: Modify CSS variables for color schemes
- **Templates**: Add custom query templates
- **Page Size**: Adjust pagination size in query-executor.js
- **History Limits**: Modify max items in query-history.js

## Security

- **Client-side Only**: No server-side storage
- **Local Storage**: Query history stored locally
- **HTTPS**: Use HTTPS in production
- **Input Validation**: SQL injection protection through InfluxDB

## Contributing

1. Fork the repository
2. Create feature branch
3. Implement changes with tests
4. Update documentation
5. Submit pull request

## License

MIT License - see LICENSE file for details.

## Support

For issues and questions:
- Create GitHub issue
- Check documentation
- Review browser console for errors

---

**Renewable Energy IoT Monitoring System**  
Advanced InfluxDB 3.x Web Interface with comprehensive query management capabilities. 