# Node-RED Docker Configuration - Design

## Overview
This document describes the optimized Docker configuration for Node-RED in the Renewable Energy IoT Monitoring System. The design focuses on using the official Node-RED image with automatic plugin installation via a startup script, eliminating the need for a custom Dockerfile while maintaining all required functionality.

## Requirements

### Functional Requirements
- Use official Node-RED Docker image for consistency and reliability
- Automatically install all required Node-RED plugins on container startup
- Support development workflow with fast iteration cycles
- Maintain all existing functionality for renewable energy device simulation
- Provide easy plugin management and updates

### Non-Functional Requirements
- Fast container startup times after initial plugin installation
- Minimal image size by avoiding custom Dockerfile
- Easy debugging and log access during development
- Flexible plugin configuration without rebuilding images
- Consistent behavior across different environments

### Constraints
- Must work with existing docker-compose.yml structure
- Must support Windows development environment
- Must maintain compatibility with existing volume mounts
- Must preserve all current Node-RED settings and flows

## Design Decisions

### 1. Official Image with Startup Script
**Decision**: Use `nodered/node-red:3.1-minimal` with custom startup script instead of custom Dockerfile

**Rationale**:
- Leverages official image maintenance and security updates
- Reduces build complexity and image size
- Enables faster development cycles with volume mounts
- Provides flexibility for plugin management

**Alternatives Considered**:
- Custom Dockerfile with pre-installed plugins
- Multi-stage build with plugin installation
- Using Node-RED's built-in plugin management

### 2. Automatic Plugin Installation
**Decision**: Implement startup script that checks and installs plugins on container startup

**Rationale**:
- Ensures consistent plugin availability across environments
- Avoids manual plugin installation steps
- Provides clear visibility into plugin installation process
- Enables easy plugin updates by modifying script

### 3. Simplified Package.json
**Decision**: Keep only essential Node-RED dependency in package.json, install plugins via startup script

**Rationale**:
- Reduces package.json complexity
- Avoids version conflicts between package.json and startup script
- Provides single source of truth for plugin versions
- Enables dynamic plugin management

## Implementation Plan

### Phase 1: Infrastructure Setup
1. Create startup script with plugin installation logic
2. Update docker-compose.yml with entrypoint configuration
3. Simplify package.json to essential dependencies
4. Test plugin installation process

### Phase 2: Plugin Management
1. Define comprehensive plugin list for renewable energy monitoring
2. Implement plugin existence checking
3. Add error handling for failed plugin installations
4. Optimize installation process for speed

### Phase 3: Documentation and Testing
1. Create comprehensive documentation
2. Test across different environments
3. Validate all Node-RED flows work correctly
4. Performance testing and optimization

## Testing Strategy

### Unit Testing
- Test startup script plugin installation logic
- Verify plugin existence checking functionality
- Validate error handling for failed installations

### Integration Testing
- Test complete container startup process
- Verify all Node-RED flows load correctly
- Validate MQTT and InfluxDB connections
- Test plugin functionality in renewable energy simulations

### Performance Testing
- Measure container startup time with and without plugins
- Test memory usage with all plugins installed
- Validate Node-RED performance with simulation flows

### Success Criteria
- Container starts successfully on first run with plugin installation
- Subsequent starts are faster (plugins already installed)
- All renewable energy simulation flows work correctly
- No degradation in Node-RED performance
- Easy addition/removal of plugins via startup script modification

## Configuration Details

### Docker Compose Configuration
```yaml
node-red:
  image: nodered/node-red:3.1-minimal
  entrypoint: ["/bin/bash", "/startup.sh"]
  volumes:
    - ./node-red/startup.sh:/startup.sh
    - ./node-red/data:/data
    - ./node-red/flows:/data/flows
    - ./node-red/settings.js:/data/settings.js
    - ./node-red/package.json:/data/package.json
```

### Startup Script Features
- Plugin existence checking before installation
- Comprehensive error handling for failed installations
- Proper permission setting for Node-RED user
- Clear logging of installation process

### Plugin Categories
- **Core Functionality**: Dashboard, InfluxDB, MQTT integration
- **Data Processing**: JSON handling, aggregation, transformation
- **Simulation**: Time-based triggers, random data generation
- **Visualization**: Charts, gauges, geographic displays
- **Communication**: Email, Telegram, Slack integration
- **Flow Control**: Message routing, transformation, batching
- **Error Handling**: Catch nodes, status monitoring
- **Analytics**: Statistical analysis, forecasting, anomaly detection
- **Signal Processing**: Filtering, smoothing, interpolation
- **Advanced Estimation**: Kalman filters, particle filters

## Security Considerations

### Development Mode
- No authentication required for local development
- Direct access to Node-RED interface
- Full debugging capabilities enabled

### Production Considerations
- Enable authentication in settings.js
- Implement HTTPS/TLS encryption
- Secure MQTT broker with authentication
- Use environment variables for sensitive data
- Implement proper access controls

## Maintenance and Updates

### Plugin Updates
1. Modify plugin versions in startup.sh
2. Restart container to trigger reinstallation
3. Test functionality after updates

### Adding New Plugins
1. Add plugin to plugins array in startup.sh
2. Restart container for installation
3. Update documentation if needed

### Troubleshooting
- Check container logs for installation errors
- Verify plugin compatibility with Node-RED version
- Monitor memory usage with all plugins installed
- Test individual plugin functionality if issues arise 