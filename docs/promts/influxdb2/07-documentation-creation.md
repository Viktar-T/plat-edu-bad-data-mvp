# Documentation Creation for InfluxDB 2.x

## Prompt for Cursor IDE

Create comprehensive documentation for my InfluxDB 2.x setup.

## Requirements

1. **Installation and setup guide**
2. **Configuration details**
3. **API endpoints and usage**
4. **Query examples (InfluxQL)**
5. **Troubleshooting guide**
6. **Performance optimization tips**
7. **Backup and restore procedures**
8. **Integration with Node-RED and Grafana**

## Documentation Structure

### 1. Installation and Setup Guide
- **Prerequisites**: System requirements and dependencies
- **Docker installation**: Step-by-step Docker setup
- **Service configuration**: Docker Compose configuration
- **Initial setup**: First-time setup and configuration
- **Verification**: How to verify the installation

### 2. Configuration Details
- **Environment variables**: All configuration options
- **Database setup**: Database and retention policy configuration
- **User management**: Admin user and token setup
- **Network configuration**: Docker network setup
- **Volume management**: Data persistence configuration

### 3. API Endpoints and Usage
- **HTTP API**: Available endpoints and methods
- **Authentication**: Token-based authentication
- **Data writing**: How to write data to InfluxDB
- **Data querying**: How to query data from InfluxDB
- **Error handling**: Common errors and solutions

### 4. Query Examples (InfluxQL)
- **Basic queries**: Simple data retrieval
- **Aggregation queries**: Sum, mean, count operations
- **Time-based queries**: Time range filtering
- **Device-specific queries**: Filtering by device type
- **Performance queries**: Optimized query patterns

### 5. Troubleshooting Guide
- **Common issues**: Frequently encountered problems
- **Error messages**: Error code explanations
- **Debugging steps**: Step-by-step debugging procedures
- **Log analysis**: How to read and interpret logs
- **Performance issues**: Identifying and fixing performance problems

### 6. Performance Optimization Tips
- **Query optimization**: Writing efficient queries
- **Indexing**: Proper tag and field indexing
- **Compression**: Data compression strategies
- **Memory management**: Memory usage optimization
- **Storage optimization**: Storage efficiency tips

### 7. Backup and Restore Procedures
- **Backup strategies**: Different backup approaches
- **Automated backups**: Setting up automated backup scripts
- **Manual backups**: How to create manual backups
- **Restore procedures**: How to restore from backups
- **Data migration**: Moving data between environments

### 8. Integration Documentation
- **Node-RED integration**: Complete Node-RED setup guide
- **Grafana integration**: Grafana dashboard configuration
- **MQTT integration**: MQTT to InfluxDB data flow
- **API integration**: External application integration
- **Monitoring integration**: System monitoring setup

## Documentation Format

### File Structure
```
docs/
├── influxdb2/
│   ├── installation.md
│   ├── configuration.md
│   ├── api-reference.md
│   ├── query-examples.md
│   ├── troubleshooting.md
│   ├── performance.md
│   ├── backup-restore.md
│   ├── integration.md
│   └── README.md
```

### Content Requirements
- **Step-by-step instructions**: Clear, numbered steps
- **Code examples**: Practical code snippets
- **Screenshots**: Visual guides where helpful
- **Troubleshooting**: Common issues and solutions
- **Best practices**: Recommended approaches

## Target Audience

### Primary Audience
- **System administrators**: Setting up and maintaining the system
- **Developers**: Integrating applications with InfluxDB
- **Data analysts**: Querying and analyzing data
- **DevOps engineers**: Monitoring and troubleshooting

### Secondary Audience
- **Project managers**: Understanding system capabilities
- **End users**: Basic usage and monitoring
- **Support teams**: Troubleshooting and support

## Documentation Standards

### Writing Style
- **Clear and concise**: Easy to understand language
- **Technical accuracy**: Precise technical information
- **Consistent formatting**: Uniform document structure
- **Cross-references**: Links between related sections

### Code Examples
- **Working examples**: Tested and verified code
- **Multiple languages**: PowerShell, Shell, JavaScript
- **Error handling**: Include error handling in examples
- **Comments**: Well-commented code examples

### Visual Elements
- **Diagrams**: System architecture diagrams
- **Screenshots**: GUI screenshots where relevant
- **Flowcharts**: Process flow diagrams
- **Tables**: Configuration reference tables

## Expected Output

### Documentation Files
1. **README.md** - Overview and quick start guide
2. **installation.md** - Complete installation guide
3. **configuration.md** - Configuration reference
4. **api-reference.md** - API documentation
5. **query-examples.md** - Query examples and patterns
6. **troubleshooting.md** - Troubleshooting guide
7. **performance.md** - Performance optimization guide
8. **backup-restore.md** - Backup and restore procedures
9. **integration.md** - Integration guides

### Additional Resources
1. **Quick reference cards** - Cheat sheets for common tasks
2. **Video tutorials** - Links to video guides
3. **Community resources** - Links to external documentation
4. **FAQ** - Frequently asked questions

## Context

This documentation is for a renewable energy monitoring system that:
- **Processes real-time data** from multiple device types
- **Requires high availability** for continuous monitoring
- **Needs scalability** to handle growing data volumes
- **Supports multiple users** with different access levels

The documentation should enable users to successfully deploy, configure, and maintain the InfluxDB 2.x system while following best practices for performance and reliability. 