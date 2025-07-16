# 2024-01-15 - Node-RED Docker Configuration Optimization

## Status
**Accepted**

## Context
The user had a custom Dockerfile for Node-RED that pre-installed all required plugins, but wanted to keep their existing docker-compose.yml approach while eliminating the need for a custom Dockerfile. The goal was to maintain all functionality for the renewable energy IoT monitoring system while simplifying the build process and improving development workflow.

## Decision
We decided to eliminate the custom Dockerfile and use the official Node-RED image (`nodered/node-red:3.1-minimal`) with a custom startup script that automatically installs all required plugins on container startup.

## Consequences

### Positive
- **Simplified Build Process**: No custom Dockerfile to maintain or build
- **Faster Development Cycles**: Volume mounts enable immediate changes without rebuilding
- **Official Image Benefits**: Automatic security updates and maintenance from Node-RED team
- **Flexible Plugin Management**: Easy to add/remove plugins by editing startup script
- **Better Debugging**: Direct access to logs and data through volume mounts
- **Reduced Image Size**: Uses minimal official image instead of custom build
- **Consistent Environment**: Same approach works across different development environments

### Negative
- **Initial Startup Time**: First container startup takes longer due to plugin installation
- **Dependency on Internet**: Plugin installation requires internet connectivity
- **Script Maintenance**: Need to maintain plugin list in startup script
- **Potential Installation Failures**: Individual plugin installation failures need handling

## Alternatives Considered

### 1. Keep Custom Dockerfile
- **Why Rejected**: Requires rebuilding image for plugin changes, slower development cycles, more complex maintenance

### 2. Use Node-RED's Built-in Plugin Management
- **Why Rejected**: Less control over plugin versions, manual installation steps required

### 3. Multi-stage Build with Plugin Installation
- **Why Rejected**: Still requires custom Dockerfile, more complex than startup script approach

### 4. Environment Variable Plugin List
- **Why Rejected**: Less flexible than startup script, harder to manage complex plugin configurations

## Implementation Notes

### Key Components
1. **Startup Script** (`node-red/startup.sh`):
   - Checks if required plugins are already installed
   - Installs plugins from comprehensive list
   - Handles installation errors gracefully
   - Sets proper permissions

2. **Docker Compose Configuration**:
   - Uses official Node-RED image
   - Mounts startup script as entrypoint
   - Preserves all existing volume mounts and settings

3. **Simplified Package.json**:
   - Contains only essential Node-RED dependency
   - Plugins managed via startup script

### Plugin Categories Included
- Core functionality (dashboard, InfluxDB, MQTT)
- Data processing (JSON, aggregation, transformation)
- Simulation (time-based triggers, random data)
- Visualization (charts, gauges, maps)
- Communication (email, Telegram, Slack)
- Flow control (routing, transformation, batching)
- Error handling (catch nodes, status monitoring)
- Analytics (statistical analysis, forecasting)
- Signal processing (filtering, smoothing, interpolation)
- Advanced estimation (Kalman filters, particle filters)

### Error Handling
- Graceful handling of failed plugin installations
- Continues installation process even if individual plugins fail
- Clear logging of installation status
- Proper user permissions set for Node-RED operation

## Related Documents
- `docs/design/node-red-docker-configuration/design.md` - Detailed design document
- `docs/design/node-red-docker-configuration/tasks.md` - Implementation tasks
- `docs/design/node-red-docker-configuration/history.md` - Development history
- `node-red/README.md` - Usage instructions and troubleshooting
- `node-red/startup.sh` - Implementation of automatic plugin installation

## Future Considerations
- Performance optimization for plugin installation speed
- Production security hardening (authentication, HTTPS)
- Multi-environment support (dev/staging/prod configurations)
- Automated plugin version management and updates
- Monitoring and alerting for plugin installation status 