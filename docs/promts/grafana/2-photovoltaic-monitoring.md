# Task 2: Photovoltaic Monitoring Dashboard

## Objective
Create a comprehensive dashboard for monitoring photovoltaic panel performance, including power output, efficiency metrics, fault detection, and environmental conditions.

## Prerequisites
- Task 1 completed (core dashboard setup)
- InfluxDB 3.x with photovoltaic data flowing from Node-RED simulations
- Access to Grafana web interface (http://localhost:3000)

## Task Steps

### Step 1: Create Photovoltaic Dashboard Structure
Create `grafana/dashboards/photovoltaic-monitoring.json` with the following configuration:

**Dashboard Properties**:
- **Title**: "Photovoltaic Panel Monitoring"
- **Description**: "Real-time monitoring of solar panel performance and efficiency"
- **Tags**: ["photovoltaic", "solar", "monitoring", "mvp"]
- **Time Range**: Last 24 hours (default)
- **Refresh**: 30 seconds
- **Editable**: true
- **Graph Tooltip**: Shared crosshair
- **Timezone**: UTC

### Step 2: Configure Dashboard Variables
Add the following variables:

1. **Panel ID Variable**:
   - Name: `panel_id`
   - Type: Query
   - Query: `from(bucket: "renewable_energy") |> range(start: -1h) |> filter(fn: (r) => r.device_type == "photovoltaic") |> group(columns: ["device_id"]) |> distinct(column: "device_id")`

2. **Location Variable**:
   - Name: `location`
   - Type: Query
   - Query: `from(bucket: "renewable_energy") |> range(start: -1h) |> filter(fn: (r) => r.device_type == "photovoltaic") |> group(columns: ["location"]) |> distinct(column: "location")`

### Step 3: Create Dashboard Panels

#### Panel 1: Total PV Power Generation (Stat Panel)
- **Title**: "Total PV Power Output"
- **Type**: Stat
- **Position**: Top row, left
- **Flux Query**:
```flux
from(bucket: "renewable_energy")
  |> range(start: -1h)
  |> filter(fn: (r) => r.device_type == "photovoltaic")
  |> filter(fn: (r) => r._field == "power_output")
  |> sum()
```
- **Display**: Large number with unit (W)
- **Color Mode**: Value
- **Thresholds**: 
  - Green: > 0
  - Yellow: > 1000
  - Red: > 2000

#### Panel 2: Current Efficiency (Gauge)
- **Title**: "System Efficiency"
- **Type**: Gauge
- **Position**: Top row, center
- **Flux Query**:
```flux
from(bucket: "renewable_energy")
  |> range(start: -5m)
  |> filter(fn: (r) => r.device_type == "photovoltaic")
  |> filter(fn: (r) => r._field == "efficiency")
  |> mean()
```
- **Min/Max**: 0-100
- **Unit**: %
- **Thresholds**:
  - Green: > 80
  - Yellow: > 60
  - Red: < 60

#### Panel 3: Solar Irradiance (Stat Panel)
- **Title**: "Solar Irradiance"
- **Type**: Stat
- **Position**: Top row, right
- **Flux Query**:
```flux
from(bucket: "renewable_energy")
  |> range(start: -5m)
  |> filter(fn: (r) => r.device_type == "photovoltaic")
  |> filter(fn: (r) => r._field == "irradiance")
  |> mean()
```
- **Display**: Large number with unit (W/m²)
- **Color Mode**: Value
- **Thresholds**:
  - Green: > 800
  - Yellow: > 400
  - Red: < 400

#### Panel 4: Power Output vs Irradiance (Time Series)
- **Title**: "Power Output vs Irradiance Correlation"
- **Type**: Time Series
- **Position**: Second row, full width
- **Flux Query**:
```flux
from(bucket: "renewable_energy")
  |> range(start: -24h)
  |> filter(fn: (r) => r.device_type == "photovoltaic")
  |> filter(fn: (r) => r._field == "power_output" or r._field == "irradiance")
  |> aggregateWindow(every: 5m, fn: mean, createEmpty: false)
  |> pivot(rowKey:["_time"], columnKey: ["_field"], valueColumn: "_value")
```
- **Y-Axis**: Dual axis (left: Power Output W, right: Irradiance W/m²)
- **Legend**: Show legend
- **Tooltip**: Shared crosshair

#### Panel 5: Panel Temperature Distribution (Heatmap)
- **Title**: "Panel Temperature Distribution"
- **Type**: Heatmap
- **Position**: Third row, left
- **Flux Query**:
```flux
from(bucket: "renewable_energy")
  |> range(start: -24h)
  |> filter(fn: (r) => r.device_type == "photovoltaic")
  |> filter(fn: (r) => r._field == "temperature")
  |> aggregateWindow(every: 1h, fn: mean, createEmpty: false)
  |> group(columns: ["device_id"])
```
- **Y-Axis**: Device ID
- **X-Axis**: Time
- **Color**: Temperature (°C)
- **Thresholds**:
  - Blue: < 25°C
  - Green: 25-45°C
  - Yellow: 45-60°C
  - Red: > 60°C

#### Panel 6: Voltage and Current Trends (Time Series)
- **Title**: "Voltage and Current Trends"
- **Type**: Time Series
- **Position**: Third row, right
- **Flux Query**:
```flux
from(bucket: "renewable_energy")
  |> range(start: -24h)
  |> filter(fn: (r) => r.device_type == "photovoltaic")
  |> filter(fn: (r) => r._field == "voltage" or r._field == "current")
  |> aggregateWindow(every: 5m, fn: mean, createEmpty: false)
  |> pivot(rowKey:["_time"], columnKey: ["_field"], valueColumn: "_value")
```
- **Y-Axis**: Dual axis (left: Voltage V, right: Current A)
- **Legend**: Show legend
- **Tooltip**: Shared crosshair

#### Panel 7: Individual Panel Performance (Table)
- **Title**: "Individual Panel Status"
- **Type**: Table
- **Position**: Fourth row, full width
- **Flux Query**:
```flux
from(bucket: "renewable_energy")
  |> range(start: -5m)
  |> filter(fn: (r) => r.device_type == "photovoltaic")
  |> filter(fn: (r) => r._field == "power_output" or r._field == "efficiency" or r._field == "temperature" or r._field == "status")
  |> pivot(rowKey:["_time"], columnKey: ["_field"], valueColumn: "_value")
  |> group(columns: ["device_id"])
  |> last()
  |> sort(columns: ["device_id"])
```
- **Columns**: Device ID, Power Output (W), Efficiency (%), Temperature (°C), Status
- **Transformations**: 
  - Organize fields
  - Add color coding for status column

#### Panel 8: Daily Energy Production (Bar Chart)
- **Title**: "Daily Energy Production"
- **Type**: Bar Chart
- **Position**: Fifth row, left
- **Flux Query**:
```flux
from(bucket: "renewable_energy")
  |> range(start: -7d)
  |> filter(fn: (r) => r.device_type == "photovoltaic")
  |> filter(fn: (r) => r._field == "power_output")
  |> aggregateWindow(every: 1d, fn: sum, createEmpty: false)
  |> map(fn: (r) => ({r with _value: r._value * 0.001})) // Convert to kWh
```
- **Y-Axis**: Energy (kWh)
- **X-Axis**: Date
- **Orientation**: Vertical

#### Panel 9: Fault Detection Summary (Stat Panel)
- **Title**: "Faulty Panels"
- **Type**: Stat
- **Position**: Fifth row, right
- **Flux Query**:
```flux
from(bucket: "renewable_energy")
  |> range(start: -5m)
  |> filter(fn: (r) => r.device_type == "photovoltaic")
  |> filter(fn: (r) => r._field == "status")
  |> filter(fn: (r) => r._value == "fault")
  |> group()
  |> count()
```
- **Display**: Number with icon
- **Color Mode**: Value
- **Thresholds**:
  - Green: 0
  - Red: > 0

### Step 4: Configure Panel Layout
Arrange panels in a responsive grid layout:

```
Row 1: [Panel 1] [Panel 2] [Panel 3]
Row 2: [Panel 4 - Full Width]
Row 3: [Panel 5] [Panel 6]
Row 4: [Panel 7 - Full Width]
Row 5: [Panel 8] [Panel 9]
```

### Step 5: Add Annotations
Configure annotations for important events:

1. **Sunrise/Sunset**: Mark solar generation periods
2. **Fault Events**: Highlight when panels go into fault state
3. **Maintenance**: Mark scheduled maintenance periods

### Step 6: Configure Alerting Rules
Set up basic alerting for photovoltaic monitoring:

1. **Low Efficiency Alert**:
   - Condition: Efficiency < 60%
   - Severity: Warning
   - Message: "PV panel efficiency below 60%"

2. **High Temperature Alert**:
   - Condition: Temperature > 70°C
   - Severity: Critical
   - Message: "PV panel temperature critical"

3. **No Data Alert**:
   - Condition: No data for > 5 minutes
   - Severity: Critical
   - Message: "PV panel data not received"

### Step 7: Test Dashboard
1. Verify all panels are displaying photovoltaic data
2. Test dashboard variables (panel_id, location)
3. Check time series correlations
4. Validate alert conditions
5. Test responsive layout on different screen sizes

### Step 8: Validation Checklist
- [ ] Dashboard JSON file created with proper structure
- [ ] All 9 panels configured with correct Flux queries
- [ ] Dashboard variables configured and functional
- [ ] Panel layout responsive and well-organized
- [ ] Time series panels showing proper correlations
- [ ] Table panel displaying individual panel data
- [ ] Heatmap showing temperature distribution
- [ ] Alert rules configured for critical conditions
- [ ] Dashboard loads within 5 seconds
- [ ] Auto-refresh working (30-second intervals)
- [ ] Mobile responsiveness verified

## Expected Output
- Complete photovoltaic monitoring dashboard
- Real-time visualization of solar panel performance
- Fault detection and alerting capabilities
- Responsive design for field monitoring
- Integration with system overview dashboard

## Success Criteria
- Dashboard displays real-time PV data from InfluxDB
- All panels show accurate photovoltaic metrics
- Alert rules trigger appropriately for fault conditions
- Dashboard variables allow filtering by panel and location
- Mobile-responsive design works on tablets and phones
- Performance metrics match expected solar generation patterns

## Next Steps
After completing this task, proceed to Task 3: Wind Turbine Analytics Dashboard. 