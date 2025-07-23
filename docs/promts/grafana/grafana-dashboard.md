@docs/architecture.md Create Grafana dashboards for renewable energy monitoring:

1. Design dashboard structure:
   - Overview dashboard: total power generation, system status
   - Device-specific dashboards: PV panels, wind turbines, biogas, heat boilers
   - Alerts dashboard: system faults, maintenance needs
   - Performance dashboard: efficiency metrics, trends

2. Create grafana/dashboards/ with JSON files:
   - renewable-energy-overview.json
   - photovoltaic-monitoring.json
   - wind-turbine-analytics.json
   - biogas-plant-metrics.json
   - heat-boiler-monitoring.json

3. Configure data sources:
   - InfluxDB connection settings
   - Flux queries for data retrieval
   - Proper time range handling

4. Implement panel types:
   - Time series graphs for power output
   - Stat panels for current values
   - Gauge panels for efficiency metrics
   - Tables for device status
   - Heatmaps for performance analysis

5. Set up provisioning files:
   - grafana/provisioning/datasources/
   - grafana/provisioning/dashboards/

6. Create alerting rules for:
   - Power generation anomalies
   - Device failures
   - Maintenance schedules

Use responsive design principles and include proper error handling.