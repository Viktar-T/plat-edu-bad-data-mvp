# Documentation Creation for InfluxDB 2.x Migration

## Cursor IDE Agent Instructions

You are tasked with creating comprehensive documentation for the completed InfluxDB 2.x migration in a renewable energy IoT monitoring system. This documentation should serve as the definitive reference for the current system state and provide guidance for future maintenance and development.

## Current System State

### ✅ Completed Migration Components
- **Docker Compose**: InfluxDB 2.7 service with proper configuration
- **Configuration Files**: `influxdb.conf`, `influxdb.yaml`, initialization scripts
- **Environment Variables**: Complete `.env` configuration for InfluxDB 2.x
- **Node-RED Integration**: Migrated to Flux queries with token authentication
- **Grafana Integration**: Updated data source and dashboard references
- **Testing Framework**: Comprehensive PowerShell and JavaScript test suite
- **Manual Tests**: Updated test procedures for InfluxDB 2.x

### 🔧 Current Configuration
- **InfluxDB Version**: 2.7 (Docker image: `influxdb:2.7`)
- **Authentication**: Token-based (`renewable_energy_admin_token_123`)
- **Organization**: `renewable_energy_org`
- **Bucket**: `renewable_energy`
- **Query Language**: Flux (standardized across all components)
- **Port**: 8086 (HTTP API)

### 📁 Existing Documentation Structure
- **Manual Tests**: `tests/manual-tests/` (5 updated test documents)
- **Automated Tests**: `tests/scripts/` (6 PowerShell scripts + JavaScript tests)
- **Configuration**: `influxdb/config/` (configuration files and scripts)
- **Integration**: Node-RED flows and Grafana dashboards updated

## Documentation Requirements

### 1. System Overview and Architecture
- **Current system state** documentation
- **Migration summary** from InfluxDB 3.x to 2.x
- **Component relationships** and data flow
- **Architecture diagrams** and system topology

### 2. Configuration Reference
- **Environment variables** reference (from `.env`)
- **Docker Compose** configuration details
- **InfluxDB configuration** files explanation
- **Authentication setup** and token management

### 3. API and Query Documentation
- **Flux query examples** (not InfluxQL - system uses Flux)
- **API endpoints** for InfluxDB 2.x
- **Data writing patterns** for renewable energy devices
- **Query optimization** for time-series data

### 4. Integration Guides
- **Node-RED integration** (already completed - document current state)
- **Grafana integration** (already completed - document current state)
- **MQTT data flow** documentation
- **Testing framework** usage guide

### 5. Operational Documentation
- **Monitoring and health checks** using automated tests
- **Troubleshooting guide** with common issues
- **Performance optimization** for renewable energy data
- **Backup and restore** procedures

### 6. Development and Testing
- **Testing framework** documentation
- **Manual test procedures** reference
- **Development workflow** and best practices
- **Deployment procedures** and validation

## Documentation Structure

### File Organization
```
docs/
├── influxdb2/
│   ├── README.md                    # System overview and quick start
│   ├── architecture.md              # System architecture and data flow
│   ├── configuration.md             # Configuration reference
│   ├── api-reference.md             # API endpoints and Flux queries
│   ├── integration.md               # Integration guides (Node-RED, Grafana)
│   ├── operations.md                # Monitoring, troubleshooting, optimization
│   ├── testing.md                   # Testing framework and procedures
│   ├── migration-summary.md         # Migration from InfluxDB 3.x to 2.x
│   └── quick-reference.md           # Quick reference and cheat sheets
```

### Content Requirements
- **Current State Focus**: Document the actual implemented system
- **Flux Query Examples**: Provide practical Flux queries for renewable energy data
- **Integration Examples**: Show how Node-RED and Grafana work with InfluxDB 2.x
- **Testing Procedures**: Document the automated and manual testing approaches
- **Troubleshooting**: Include solutions for common issues in the current setup

## Implementation Strategy

### Phase 1: System Overview Documentation
1. **README.md**: Complete system overview with quick start guide
2. **architecture.md**: System architecture, data flow, and component relationships
3. **migration-summary.md**: Summary of migration from InfluxDB 3.x to 2.x

### Phase 2: Technical Reference Documentation
1. **configuration.md**: Complete configuration reference
2. **api-reference.md**: API endpoints and Flux query examples
3. **quick-reference.md**: Cheat sheets and quick reference guides

### Phase 3: Integration and Operations Documentation
1. **integration.md**: Node-RED and Grafana integration guides
2. **operations.md**: Monitoring, troubleshooting, and optimization
3. **testing.md**: Testing framework and procedures documentation

## Key Documentation Features

### 1. Current System State Documentation
- **Migration Summary**: Document what was changed from InfluxDB 3.x to 2.x
- **Configuration Details**: Document the actual implemented configuration
- **Integration Status**: Document the current state of Node-RED and Grafana integration

### 2. Flux Query Examples
- **Renewable Energy Data**: Practical Flux queries for photovoltaic, wind turbine, biogas plant data
- **Time-Series Patterns**: Common query patterns for renewable energy monitoring
- **Performance Optimization**: Optimized Flux queries for large datasets

### 3. Testing Framework Documentation
- **Automated Tests**: Document the PowerShell and JavaScript test suite
- **Manual Tests**: Reference the updated manual test procedures
- **Validation Procedures**: How to validate the system is working correctly

### 4. Integration Guides
- **Node-RED**: Document the current Flux-based Node-RED integration
- **Grafana**: Document the current Grafana dashboard configuration
- **Data Flow**: Document the complete MQTT → Node-RED → InfluxDB → Grafana flow

## Content Guidelines

### Writing Style
- **Current State Focus**: Document what is actually implemented, not theoretical
- **Practical Examples**: Provide working examples from the current system
- **Step-by-Step Procedures**: Clear, actionable instructions
- **Cross-References**: Link between related documentation sections

### Code Examples
- **Flux Queries**: Provide practical Flux queries for renewable energy data
- **PowerShell Scripts**: Include examples from the testing framework
- **Configuration Examples**: Show actual configuration from the current system
- **Integration Examples**: Demonstrate Node-RED and Grafana integration

### Visual Elements
- **System Architecture**: Diagrams showing the current system topology
- **Data Flow**: Flowcharts showing data movement through the system
- **Configuration Screenshots**: Visual guides for configuration
- **Dashboard Examples**: Screenshots of working Grafana dashboards

## Success Criteria

### Primary Goals
1. **Complete System Documentation**: Comprehensive documentation of the current InfluxDB 2.x system
2. **Practical Examples**: Working examples that users can immediately apply
3. **Integration Guides**: Clear documentation of Node-RED and Grafana integration
4. **Testing Procedures**: Complete documentation of the testing framework

### Secondary Goals
1. **Migration Reference**: Clear documentation of what was changed during migration
2. **Troubleshooting Guide**: Practical solutions for common issues
3. **Performance Guidance**: Optimization tips for renewable energy data
4. **Future-Proofing**: Documentation that supports future development

## Important Notes

### Do Not Duplicate
- **Configuration Details**: Don't repeat configuration instructions from other prompts
- **Setup Procedures**: Don't repeat Docker Compose or environment setup from other prompts
- **Integration Steps**: Don't repeat Node-RED or Grafana integration steps from other prompts
- **Testing Setup**: Don't repeat testing framework setup from other prompts

### Focus On
- **Current System State**: Document what is actually implemented
- **Usage Examples**: How to use the current system effectively
- **Best Practices**: Recommended approaches for the current setup
- **Troubleshooting**: Solutions for issues specific to the current implementation

### Technical Context
- **Flux Queries**: The system uses Flux, not InfluxQL
- **Token Authentication**: Uses static token `renewable_energy_admin_token_123`
- **Organization**: Uses `renewable_energy_org` organization
- **Testing Framework**: Comprehensive PowerShell and JavaScript test suite available

## Expected Output

### Documentation Files
1. **README.md** - System overview and quick start
2. **architecture.md** - System architecture and data flow
3. **configuration.md** - Configuration reference
4. **api-reference.md** - API endpoints and Flux queries
5. **integration.md** - Integration guides
6. **operations.md** - Monitoring, troubleshooting, optimization
7. **testing.md** - Testing framework documentation
8. **migration-summary.md** - Migration summary
9. **quick-reference.md** - Quick reference guides

### Quality Standards
- **Accuracy**: All information must reflect the current system state
- **Completeness**: Cover all aspects of the current implementation
- **Usability**: Provide practical, actionable information
- **Maintainability**: Documentation that can be easily updated

## Implementation Instructions

### Step 1: Analyze Current System
1. **Review existing files**: Examine current configuration and implementation
2. **Identify gaps**: Determine what documentation is missing
3. **Map relationships**: Understand how components interact
4. **Validate current state**: Ensure documentation reflects actual implementation

### Step 2: Create Documentation Structure
1. **Create directory structure**: Set up the documentation folder hierarchy
2. **Create index files**: Establish navigation and cross-references
3. **Define templates**: Create consistent documentation templates
4. **Set up versioning**: Establish documentation version control

### Step 3: Write Documentation Content
1. **System overview**: Document the current system architecture
2. **Configuration reference**: Document all configuration options
3. **API documentation**: Document Flux queries and API usage
4. **Integration guides**: Document Node-RED and Grafana integration
5. **Operational procedures**: Document monitoring and troubleshooting

### Step 4: Validate and Test
1. **Review accuracy**: Ensure all information is current and correct
2. **Test procedures**: Verify all documented procedures work
3. **Cross-reference**: Ensure all links and references are valid
4. **User testing**: Validate documentation usability

## Technical Specifications

### Renewable Energy Data Types
- **Photovoltaic**: Power output, temperature, voltage, current, irradiance, efficiency
- **Wind Turbines**: Power output, wind speed, direction, rotor speed, vibration, efficiency
- **Biogas Plants**: Gas flow, methane concentration, temperature, pressure, efficiency
- **Heat Boilers**: Temperature, pressure, efficiency, fuel consumption, flow rate, output power
- **Energy Storage**: State of charge, voltage, current, temperature, cycle count, health status

### System Architecture
```
MQTT → Node-RED → InfluxDB 2.x → Grafana
  ↓        ↓           ↓           ↓
Device   Flux      Flux Queries  Flux Queries
Data   Processing   Storage      Visualization
  ↓        ↓           ↓           ↓
Token Authentication: renewable_energy_admin_token_123
  ↓        ↓           ↓           ↓
Organization: renewable_energy_org
```

This prompt provides clear, focused instructions for creating comprehensive documentation that reflects the current state of the InfluxDB 2.x migration while avoiding duplication of content from other prompts. 