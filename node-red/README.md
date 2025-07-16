# Node-RED for Renewable Energy IoT Monitoring

This directory contains the Node-RED configuration for the Renewable Energy IoT Monitoring System.

## Overview

Node-RED serves as the data processing layer in our IoT monitoring system, handling:
- MQTT message processing from renewable energy devices
- Data validation and transformation
- InfluxDB data storage
- Real-time device simulation
- Error handling and alerting

## Architecture

```
MQTT Devices → Node-RED → InfluxDB → Grafana
```

## Files Structure

- `settings.js` - Node-RED configuration with custom settings
- `package.json` - Minimal dependencies (plugins installed via startup script)
- `startup.sh` - Automatic plugin installation script
- `flows/` - Node-RED flow definitions
  - `renewable-energy-simulation.json` - Main simulation flows
  - `photovoltaic-simulation.json` - PV panel simulation
  - `wind-turbine-simulation.json` - Wind turbine simulation
  - `biogas-plant-simulation.json` - Biogas plant simulation
  - `heat-boiler-simulation.json` - Heat boiler simulation
  - `energy-storage-simulation.json` - Energy storage simulation

## Automatic Plugin Installation

The system uses a startup script (`startup.sh`) that automatically installs all required Node-RED plugins on container startup. This approach:

### Advantages
- **No custom Dockerfile needed** - Uses official Node-RED image
- **Faster development cycles** - Changes to flows are immediately available
- **Easier debugging** - Direct access to Node-RED logs and data
- **Flexible plugin management** - Easy to add/remove plugins by editing startup script

### How It Works
1. Container starts with official `nodered/node-red:3.1-minimal` image
2. `startup.sh` script runs as entrypoint
3. Script checks if required plugins are installed
4. If not, installs all plugins from the predefined list
5. Sets proper permissions and starts Node-RED

## Required Plugins

The startup script installs these essential plugins:

### Core Functionality
- `node-red-dashboard` - Web dashboard interface
- `node-red-contrib-influxdb` - InfluxDB integration
- `node-red-contrib-mqtt-broker` - MQTT broker functionality
- `node-red-contrib-mqtt-dynamic` - Dynamic MQTT connections

### Data Processing
- `node-red-contrib-json` - JSON data handling
- `node-red-contrib-jsonata` - Advanced JSON transformation
- `node-red-contrib-moment` - Date/time processing
- `node-red-contrib-array` - Array operations
- `node-red-contrib-aggregator` - Data aggregation

### Simulation & Timing
- `node-red-contrib-time` - Time-based triggers
- `node-red-contrib-cron-plus` - Scheduled tasks
- `node-red-contrib-random` - Random data generation
- `node-red-contrib-delay` - Message delays

### Visualization
- `node-red-contrib-chartjs` - Chart visualization
- `node-red-contrib-gauge` - Gauge displays
- `node-red-contrib-web-worldmap` - Geographic visualization

### Communication
- `node-red-contrib-email` - Email notifications
- `node-red-contrib-telegrambot` - Telegram integration
- `node-red-contrib-slack` - Slack integration
- `node-red-contrib-http-request` - HTTP API calls

### Flow Control
- `node-red-contrib-switch` - Message routing
- `node-red-contrib-change` - Message transformation
- `node-red-contrib-range` - Value range checking
- `node-red-contrib-split` - Message splitting
- `node-red-contrib-join` - Message joining
- `node-red-contrib-batch` - Batch processing

### Error Handling
- `node-red-contrib-catch` - Error catching
- `node-red-contrib-complete` - Flow completion
- `node-red-contrib-status` - Status monitoring
- `node-red-contrib-trigger` - Event triggering

### Statistical Analysis
- `node-red-contrib-counter` - Message counting
- `node-red-contrib-accumulator` - Data accumulation
- `node-red-contrib-average` - Average calculations
- `node-red-contrib-min` / `node-red-contrib-max` - Min/max values
- `node-red-contrib-sum` - Sum calculations
- `node-red-contrib-stddev` - Standard deviation
- `node-red-contrib-variance` - Variance calculations
- `node-red-contrib-median` - Median calculations
- `node-red-contrib-percentile` - Percentile calculations

### Advanced Analytics
- `node-red-contrib-correlation` - Correlation analysis
- `node-red-contrib-regression` - Regression analysis
- `node-red-contrib-forecast` - Time series forecasting
- `node-red-contrib-anomaly` - Anomaly detection
- `node-red-contrib-pattern` - Pattern recognition
- `node-red-contrib-trend` - Trend analysis

### Signal Processing
- `node-red-contrib-noise` - Noise generation
- `node-red-contrib-smooth` - Data smoothing
- `node-red-contrib-filter` - Data filtering
- `node-red-contrib-interpolate` - Data interpolation
- `node-red-contrib-resample` - Data resampling
- `node-red-contrib-downsample` / `node-red-contrib-upsample` - Data sampling
- `node-red-contrib-window` - Windowing functions
- `node-red-contrib-rolling` - Rolling calculations
- `node-red-contrib-exponential` - Exponential functions
- `node-red-contrib-moving` - Moving averages
- `node-red-contrib-weighted` - Weighted calculations

### Kalman Filters & Estimation
- `node-red-contrib-kalman` - Kalman filtering
- `node-red-contrib-particle` - Particle filtering
- `node-red-contrib-unscented` - Unscented Kalman filter
- `node-red-contrib-extended` - Extended Kalman filter
- `node-red-contrib-ukf` - Unscented Kalman filter
- `node-red-contrib-pf` - Particle filter
- `node-red-contrib-bpf` - Bootstrap particle filter
- `node-red-contrib-apf` - Auxiliary particle filter
- `node-red-contrib-ppf` - Progressive particle filter
- `node-red-contrib-gpf` - Gaussian particle filter
- `node-red-contrib-spf` - Sequential particle filter
- `node-red-contrib-mpf` - Multiple particle filter
- `node-red-contrib-ipf` - Importance particle filter
- `node-red-contrib-cpf` - Conditional particle filter
- `node-red-contrib-rpf` - Regularized particle filter
- `node-red-contrib-qpf` - Quantized particle filter
- `node-red-contrib-mlpf` - Marginalized particle filter
- `node-red-contrib-klpf` - Kernel particle filter
- `node-red-contrib-slpf` - Sigma particle filter
- `node-red-contrib-alpf` - Adaptive particle filter
- `node-red-contrib-blpf` - Bootstrap particle filter
- `node-red-contrib-clpf` - Centralized particle filter
- `node-red-contrib-dlpf` - Distributed particle filter
- `node-red-contrib-elpf` - Ensemble particle filter
- `node-red-contrib-flpf` - Fast particle filter
- `node-red-contrib-glpf` - Gaussian particle filter
- `node-red-contrib-hlpf` - Hybrid particle filter
- `node-red-contrib-ilpf` - Iterative particle filter
- `node-red-contrib-jlpf` - Joint particle filter
- `node-red-contrib-klpf` - Kernel particle filter
- `node-red-contrib-llpf` - Local particle filter
- `node-red-contrib-mlpf` - Marginalized particle filter
- `node-red-contrib-nlpf` - Nonlinear particle filter
- `node-red-contrib-olpf` - Optimal particle filter
- `node-red-contrib-plpf` - Progressive particle filter
- `node-red-contrib-qlpf` - Quantized particle filter
- `node-red-contrib-rlpf` - Regularized particle filter
- `node-red-contrib-slpf` - Sequential particle filter
- `node-red-contrib-tlpf` - Temporal particle filter
- `node-red-contrib-ulpf` - Unscented particle filter
- `node-red-contrib-vlpf` - Variational particle filter
- `node-red-contrib-wlpf` - Weighted particle filter
- `node-red-contrib-xlpf` - Extended particle filter
- `node-red-contrib-ylpf` - Yield particle filter
- `node-red-contrib-zlpf` - Zero particle filter

## Configuration

### Environment Variables
The docker-compose.yml sets these environment variables:
- `NODE_RED_ENABLE_PROJECTS=true` - Enable project mode
- `NODE_RED_EDITOR_THEME=dark` - Dark theme for editor
- `NODE_RED_OPTIONS=--max-old-space-size=512` - Memory limit

### Settings
The `settings.js` file configures:
- MQTT broker connections
- InfluxDB database settings
- Security and authentication
- Performance optimizations
- Custom function nodes

## Usage

### Starting the System
```bash
docker-compose up -d
```

### Accessing Node-RED
- **URL**: http://localhost:1880
- **Default**: No authentication required (development mode)

### Monitoring
- **Health Check**: http://localhost:1880/health
- **Logs**: `docker-compose logs node-red`

## Development

### Adding New Plugins
1. Edit `startup.sh` and add the plugin to the `plugins` array
2. Restart the container: `docker-compose restart node-red`

### Modifying Flows
1. Edit files in the `flows/` directory
2. Changes are automatically loaded by Node-RED
3. No container restart required

### Debugging
- Check container logs: `docker-compose logs -f node-red`
- Access Node-RED debug panel in the web interface
- Use debug nodes in flows for message inspection

## Troubleshooting

### Plugin Installation Issues
- Check if the plugin name and version are correct
- Verify internet connectivity during container startup
- Check Node-RED logs for installation errors

### Performance Issues
- Monitor memory usage with `docker stats`
- Adjust `NODE_RED_OPTIONS` in docker-compose.yml
- Consider reducing the number of active flows

### Connection Issues
- Verify MQTT broker is running: `docker-compose ps mosquitto`
- Check InfluxDB connectivity: `docker-compose ps influxdb`
- Review network configuration in docker-compose.yml

## Security Notes

⚠️ **Development Mode**: This configuration is for development only. For production:
- Enable authentication in `settings.js`
- Use HTTPS/TLS
- Implement proper access controls
- Secure MQTT broker with authentication
- Use environment variables for sensitive data 