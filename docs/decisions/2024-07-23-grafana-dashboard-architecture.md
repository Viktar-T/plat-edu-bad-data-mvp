# 2024-07-23 - Grafana Dashboard Architecture

## Status
**Accepted**

## Context
Needed to implement a comprehensive monitoring system for renewable energy IoT devices including photovoltaic panels, wind turbines, biogas plants, heat boilers, and energy storage systems. Required real-time visualization, historical analysis, and operational monitoring capabilities.

## Decision
Implemented a modular dashboard architecture with separate, specialized dashboards for each device type, integrated with InfluxDB 3.x using Flux queries, and deployed via JSON provisioning for automated deployment and version control.

### Architecture Components:
1. **System Overview Dashboard**: Aggregated metrics across all device types
2. **Device-Specific Dashboards**: Specialized monitoring for each renewable energy type
3. **InfluxDB 3.x Integration**: Native Flux query language for optimal performance
4. **JSON Dashboard Provisioning**: Automated deployment with version control
5. **Variable-Based Filtering**: Dynamic filtering using Grafana template variables
6. **Standardized Panel Structure**: Consistent 11-panel layout per dashboard

## Consequences

### Positive
- **Modular Design**: Easier maintenance and focused analytics per device type
- **Scalability**: Easy to add new device types or modify existing ones
- **Performance**: Optimized Flux queries for InfluxDB 3.x
- **Consistency**: Uniform user experience across all dashboards
- **Automation**: Reproducible deployments via JSON provisioning
- **Flexibility**: Dynamic filtering reduces dashboard clutter
- **Professional Quality**: Production-ready monitoring system

### Negative
- **Complexity**: Multiple dashboards to manage and maintain
- **Learning Curve**: Users need to navigate between different dashboards
- **Resource Usage**: Multiple dashboard instances may consume more resources
- **Configuration Overhead**: More configuration files to manage

## Alternatives Considered

### Single Mega-Dashboard
- **Description**: One large dashboard with all device types
- **Why Rejected**: Would be too cluttered, difficult to navigate, and hard to maintain

### InfluxQL Compatibility Mode
- **Description**: Use InfluxDB 2.x compatibility mode
- **Why Rejected**: Would not leverage full InfluxDB 3.x capabilities and performance

### Manual Dashboard Creation
- **Description**: Create dashboards manually through Grafana UI
- **Why Rejected**: No version control, difficult to reproduce, error-prone

### Static Filtering
- **Description**: Fixed dashboards without dynamic variables
- **Why Rejected**: Limited flexibility and poor user experience

## Implementation Notes

### Dashboard Structure
- **System Overview**: 8 panels covering all device types
- **Device-Specific**: 11 panels each for detailed monitoring
- **Panel Types**: Stat, Gauge, Time Series, Table, Bar Chart, Histogram, Pie Chart, Scatter Plot
- **Refresh Rate**: 30-second intervals for real-time monitoring

### Technical Specifications
- **Grafana Version**: 10.x with InfluxDB 3.x support
- **Query Language**: Flux for optimal InfluxDB 3.x performance
- **Provisioning**: JSON-based automated deployment
- **Theme**: Dark theme for field monitoring
- **Timezone**: UTC for consistency

### File Organization
```
grafana/
├── dashboards/
│   ├── renewable-energy-overview.json
│   ├── photovoltaic-monitoring.json
│   ├── wind-turbine-analytics.json
│   ├── biogas-plant-metrics.json
│   ├── heat-boiler-monitoring.json
│   └── energy-storage-monitoring.json
└── provisioning/
    ├── datasources/
    │   └── influxdb.yaml
    └── dashboards/
        └── dashboard-provider.yaml
```

## Related Documents
- `docs/design/grafana-dashboard-system/design.md`
- `docs/design/grafana-dashboard-system/tasks.md`
- `docs/design/grafana-dashboard-system/history.md`
- `docs/promts/grafana/` (task prompt files) 