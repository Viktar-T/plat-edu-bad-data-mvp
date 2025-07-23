# Task 1: Core Dashboard Setup and System Overview Dashboard

## Objective
Set up the foundational Grafana infrastructure and create the main system overview dashboard for the renewable energy IoT MVP monitoring system.

## Prerequisites
- Docker Compose environment running with Grafana, InfluxDB, and Node-RED
- InfluxDB 3.x with renewable energy data flowing from Node-RED simulations
- Access to Grafana web interface (http://localhost:3000)

## Task Steps

### Step 1: Create Directory Structure
Create the required directory structure for Grafana configuration:

```bash
grafana/
├── provisioning/
│   ├── datasources/
│   └── dashboards/
└── dashboards/
```

### Step 2: Configure InfluxDB Data Source
Create `grafana/provisioning/datasources/influxdb.yaml`:

```yaml
apiVersion: 1

datasources:
  - name: InfluxDB 3.x
    type: influxdb
    access: proxy
    url: http://influxdb:8086
    database: renewable_energy
    version: Flux
    isDefault: true
    editable: true
    jsonData:
      version: Flux
      organization: renewable_energy
      defaultBucket: renewable_energy
      tlsSkipVerify: true
    secureJsonData:
      token: ${INFLUXDB_TOKEN:-}
```

### Step 3: Create Dashboard Provider Configuration
Create `grafana/provisioning/dashboards/dashboard-provider.yaml`:

```yaml
apiVersion: 1

providers:
  - name: 'Renewable Energy Dashboards'
    orgId: 1
    folder: 'Renewable Energy'
    type: file
    disableDeletion: false
    updateIntervalSeconds: 10
    allowUiUpdates: true
    options:
      path: /var/lib/grafana/dashboards
```

### Step 4: Create System Overview Dashboard
Create `grafana/dashboards/renewable-energy-overview.json` with the following panels:

#### Panel 1: Total Power Generation (Stat Panel)
- **Query**: Sum of all device power outputs
- **Display**: Large number with trend indicator
- **Refresh**: 30 seconds
- **Flux Query**:
```flux
from(bucket: "renewable_energy")
  |> range(start: -1h)
  |> filter(fn: (r) => r._field == "power_output")
  |> sum()
```

#### Panel 2: Active Devices Count (Stat Panel)
- **Query**: Count of operational devices
- **Display**: Number with color coding (green for operational)
- **Flux Query**:
```flux
from(bucket: "renewable_energy")
  |> range(start: -5m)
  |> filter(fn: (r) => r._field == "status")
  |> filter(fn: (r) => r._value == "operational")
  |> group()
  |> count()
```

#### Panel 3: Power Generation by Device Type (Pie Chart)
- **Query**: Power distribution across device types
- **Display**: Pie chart with percentages
- **Flux Query**:
```flux
from(bucket: "renewable_energy")
  |> range(start: -1h)
  |> filter(fn: (r) => r._field == "power_output")
  |> group(columns: ["device_type"])
  |> sum()
```

#### Panel 4: Power Generation Trends (Time Series)
- **Query**: Power output over time
- **Display**: Line graph with multiple device types
- **Time Range**: Last 24 hours
- **Flux Query**:
```flux
from(bucket: "renewable_energy")
  |> range(start: -24h)
  |> filter(fn: (r) => r._field == "power_output")
  |> aggregateWindow(every: 5m, fn: mean, createEmpty: false)
  |> group(columns: ["device_type"])
```

#### Panel 5: System Efficiency (Gauge)
- **Query**: Overall system efficiency percentage
- **Display**: Circular gauge (0-100%)
- **Flux Query**:
```flux
from(bucket: "renewable_energy")
  |> range(start: -1h)
  |> filter(fn: (r) => r._field == "efficiency")
  |> mean()
```

#### Panel 6: Device Status Summary (Table)
- **Query**: Current status of all devices
- **Display**: Table with device ID, type, status, last update
- **Columns**: Device ID, Type, Status, Last Update, Power Output
- **Flux Query**:
```flux
from(bucket: "renewable_energy")
  |> range(start: -5m)
  |> filter(fn: (r) => r._field == "status" or r._field == "power_output")
  |> pivot(rowKey:["_time"], columnKey: ["_field"], valueColumn: "_value")
  |> group(columns: ["device_id", "device_type"])
  |> last()
```

### Step 5: Configure Dashboard Variables
Add the following variables to the dashboard:

1. **Time Range Variable**:
   - Name: `$__timeFilter()`
   - Type: Built-in time range

2. **Device Type Variable**:
   - Name: `device_type`
   - Type: Query
   - Query: `from(bucket: "renewable_energy") |> range(start: -1h) |> group(columns: ["device_type"]) |> distinct(column: "device_type")`

3. **Location Variable**:
   - Name: `location`
   - Type: Query
   - Query: `from(bucket: "renewable_energy") |> range(start: -1h) |> group(columns: ["location"]) |> distinct(column: "location")`

### Step 6: Dashboard Configuration
Set the following dashboard properties:

- **Title**: "Renewable Energy System Overview"
- **Description**: "Real-time monitoring of all renewable energy devices"
- **Tags**: ["renewable-energy", "overview", "mvp"]
- **Time Range**: Last 24 hours (default)
- **Refresh**: 30 seconds
- **Editable**: true
- **Graph Tooltip**: Shared crosshair
- **Timezone**: UTC

### Step 7: Test Dashboard
1. Restart Grafana container to load new configuration
2. Verify data source connection
3. Check all panels are displaying data correctly
4. Test dashboard variables functionality
5. Verify auto-refresh is working

### Step 8: Validation Checklist
- [ ] Directory structure created correctly
- [ ] Data source configuration file created
- [ ] Dashboard provider configuration created
- [ ] System overview dashboard JSON file created
- [ ] All 6 panels configured with proper Flux queries
- [ ] Dashboard variables configured
- [ ] Dashboard properties set correctly
- [ ] Data source connection verified
- [ ] All panels displaying data
- [ ] Auto-refresh working (30-second intervals)
- [ ] Dashboard variables functioning properly

## Expected Output
- Complete Grafana provisioning setup
- Functional system overview dashboard with real-time data
- Proper InfluxDB 3.x integration with Flux queries
- Responsive dashboard with auto-refresh capability

## Success Criteria
- Dashboard loads within 5 seconds
- All panels display data from InfluxDB
- Auto-refresh updates data every 30 seconds
- Dashboard variables allow filtering by device type and location
- Mobile-responsive design works on different screen sizes

## Next Steps
After completing this task, proceed to Task 2: Device-Specific Dashboards for photovoltaic monitoring. 