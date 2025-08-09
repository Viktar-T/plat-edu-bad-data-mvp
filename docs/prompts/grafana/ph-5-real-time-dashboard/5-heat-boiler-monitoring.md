# Task 5: Heat Boiler Monitoring Dashboard

## Objective
Create a comprehensive dashboard for heat boiler monitoring, including temperature and pressure monitoring, fuel consumption tracking, thermal efficiency analysis, and operational status visualization.

## Prerequisites
- Task 1 completed (core dashboard setup)
- Task 2 completed (photovoltaic monitoring)
- Task 3 completed (wind turbine analytics)
- Task 4 completed (biogas plant metrics)
- InfluxDB 3.x with heat boiler data flowing from Node-RED simulations
- Access to Grafana web interface (http://localhost:3000)

## Task Steps

### Step 1: Create Heat Boiler Dashboard Structure
Create `grafana/dashboards/heat-boiler-monitoring.json` with the following configuration:

**Dashboard Properties**:
- **Title**: "Heat Boiler Monitoring"
- **Description**: "Real-time monitoring of heat boiler performance, efficiency, and operational parameters"
- **Tags**: ["heat-boiler", "thermal", "efficiency", "mvp"]
- **Time Range**: Last 24 hours (default)
- **Refresh**: 30 seconds
- **Editable**: true
- **Graph Tooltip**: Shared crosshair
- **Timezone**: UTC

### Step 2: Configure Dashboard Variables
Add the following variables:

1. **Boiler ID Variable**:
   - Name: `boiler_id`
   - Type: Query
   - Query: `from(bucket: "renewable_energy") |> range(start: -1h) |> filter(fn: (r) => r.device_type == "heat_boiler") |> group(columns: ["device_id"]) |> distinct(column: "device_id")`

2. **Temperature Range Variable**:
   - Name: `temp_range`
   - Type: Custom
   - Values: <50°C, 50-80°C, 80-100°C, 100-120°C, >120°C

### Step 3: Create Dashboard Panels

#### Panel 1: Total Heat Output (Stat Panel)
- **Title**: "Total Heat Output"
- **Type**: Stat
- **Position**: Top row, left
- **Flux Query**:
```flux
from(bucket: "renewable_energy")
  |> range(start: -1h)
  |> filter(fn: (r) => r.device_type == "heat_boiler")
  |> filter(fn: (r) => r._field == "heat_output")
  |> sum()
```
- **Display**: Large number with unit (kW)
- **Color Mode**: Value
- **Thresholds**: 
  - Green: > 0
  - Yellow: > 50
  - Red: > 100

#### Panel 2: Boiler Temperature (Gauge)
- **Title**: "Boiler Temperature"
- **Type**: Gauge
- **Position**: Top row, center
- **Flux Query**:
```flux
from(bucket: "renewable_energy")
  |> range(start: -5m)
  |> filter(fn: (r) => r.device_type == "heat_boiler")
  |> filter(fn: (r) => r._field == "temperature")
  |> mean()
```
- **Min/Max**: 0-150
- **Unit**: °C
- **Thresholds**:
  - Blue: 0-50°C (cold)
  - Green: 50-100°C (operational)
  - Yellow: 100-120°C (high)
  - Red: 120-150°C (critical)

#### Panel 3: System Pressure (Stat Panel)
- **Title**: "System Pressure"
- **Type**: Stat
- **Position**: Top row, right
- **Flux Query**:
```flux
from(bucket: "renewable_energy")
  |> range(start: -5m)
  |> filter(fn: (r) => r.device_type == "heat_boiler")
  |> filter(fn: (r) => r._field == "pressure")
  |> mean()
```
- **Display**: Large number with unit (bar)
- **Color Mode**: Value
- **Thresholds**:
  - Green: 1-3 bar (normal)
  - Yellow: 3-4 bar (high)
  - Red: > 4 bar (critical)

#### Panel 4: Temperature vs Efficiency Correlation (Time Series)
- **Title**: "Temperature vs Efficiency Correlation"
- **Type**: Time Series
- **Position**: Second row, full width
- **Flux Query**:
```flux
from(bucket: "renewable_energy")
  |> range(start: -24h)
  |> filter(fn: (r) => r.device_type == "heat_boiler")
  |> filter(fn: (r) => r._field == "temperature" or r._field == "efficiency")
  |> aggregateWindow(every: 5m, fn: mean, createEmpty: false)
  |> pivot(rowKey:["_time"], columnKey: ["_field"], valueColumn: "_value")
```
- **Y-Axis**: Dual axis (left: Temperature °C, right: Efficiency %)
- **Legend**: Show legend
- **Tooltip**: Shared crosshair

#### Panel 5: Pressure and Temperature Trends (Time Series)
- **Title**: "Pressure and Temperature Trends"
- **Type**: Time Series
- **Position**: Third row, left
- **Flux Query**:
```flux
from(bucket: "renewable_energy")
  |> range(start: -24h)
  |> filter(fn: (r) => r.device_type == "heat_boiler")
  |> filter(fn: (r) => r._field == "pressure" or r._field == "temperature")
  |> aggregateWindow(every: 5m, fn: mean, createEmpty: false)
  |> pivot(rowKey:["_time"], columnKey: ["_field"], valueColumn: "_value")
```
- **Y-Axis**: Dual axis (left: Pressure bar, right: Temperature °C)
- **Legend**: Show legend
- **Tooltip**: Shared crosshair

#### Panel 6: Thermal Efficiency (Gauge)
- **Title**: "Thermal Efficiency"
- **Type**: Gauge
- **Position**: Third row, right
- **Flux Query**:
```flux
from(bucket: "renewable_energy")
  |> range(start: -1h)
  |> filter(fn: (r) => r.device_type == "heat_boiler")
  |> filter(fn: (r) => r._field == "efficiency")
  |> mean()
```
- **Min/Max**: 0-100
- **Unit**: %
- **Thresholds**:
  - Green: > 85
  - Yellow: > 70
  - Red: < 70

#### Panel 7: Fuel Consumption (Time Series)
- **Title**: "Fuel Consumption Over Time"
- **Type**: Time Series
- **Position**: Fourth row, left
- **Flux Query**:
```flux
from(bucket: "renewable_energy")
  |> range(start: -24h)
  |> filter(fn: (r) => r.device_type == "heat_boiler")
  |> filter(fn: (r) => r._field == "fuel_consumption")
  |> aggregateWindow(every: 5m, fn: mean, createEmpty: false)
```
- **Y-Axis**: Fuel Consumption (L/h)
- **Legend**: Show legend
- **Tooltip**: Shared crosshair

#### Panel 8: Heat Output Distribution (Histogram)
- **Title**: "Heat Output Distribution"
- **Type**: Histogram
- **Position**: Fourth row, right
- **Flux Query**:
```flux
from(bucket: "renewable_energy")
  |> range(start: -24h)
  |> filter(fn: (r) => r.device_type == "heat_boiler")
  |> filter(fn: (r) => r._field == "heat_output")
  |> histogram(bins: 20)
```
- **X-Axis**: Heat Output (kW)
- **Y-Axis**: Frequency
- **Buckets**: 20 bins from 0-150 kW

#### Panel 9: Individual Boiler Performance (Table)
- **Title**: "Individual Boiler Status"
- **Type**: Table
- **Position**: Fifth row, full width
- **Flux Query**:
```flux
from(bucket: "renewable_energy")
  |> range(start: -5m)
  |> filter(fn: (r) => r.device_type == "heat_boiler")
  |> filter(fn: (r) => r._field == "heat_output" or r._field == "temperature" or r._field == "pressure" or r._field == "efficiency" or r._field == "status")
  |> pivot(rowKey:["_time"], columnKey: ["_field"], valueColumn: "_value")
  |> group(columns: ["device_id"])
  |> last()
  |> sort(columns: ["device_id"])
```
- **Columns**: Device ID, Heat Output (kW), Temperature (°C), Pressure (bar), Efficiency (%), Status
- **Transformations**: 
  - Organize fields
  - Add color coding for status column

#### Panel 10: Daily Heat Production (Bar Chart)
- **Title**: "Daily Heat Production (7 Days)"
- **Type**: Bar Chart
- **Position**: Sixth row, left
- **Flux Query**:
```flux
from(bucket: "renewable_energy")
  |> range(start: -7d)
  |> filter(fn: (r) => r.device_type == "heat_boiler")
  |> filter(fn: (r) => r._field == "heat_output")
  |> aggregateWindow(every: 1d, fn: sum, createEmpty: false)
  |> map(fn: (r) => ({r with _value: r._value * 24})) // Convert to daily kWh
```
- **Y-Axis**: Heat Production (kWh/day)
- **X-Axis**: Date
- **Orientation**: Vertical
- **Color**: By boiler ID

#### Panel 11: Fuel Efficiency (Stat Panel)
- **Title**: "Fuel Efficiency"
- **Type**: Stat
- **Position**: Sixth row, right
- **Flux Query**:
```flux
from(bucket: "renewable_energy")
  |> range(start: -24h)
  |> filter(fn: (r) => r.device_type == "heat_boiler")
  |> filter(fn: (r) => r._field == "heat_output" or r._field == "fuel_consumption")
  |> pivot(rowKey:["_time"], columnKey: ["_field"], valueColumn: "_value")
  |> filter(fn: (r) => r.fuel_consumption > 0)
  |> map(fn: (r) => ({r with _value: r.heat_output / r.fuel_consumption}))
  |> mean()
```
- **Display**: Efficiency with unit (kW/L)
- **Color Mode**: Value
- **Thresholds**:
  - Green: > 10
  - Yellow: > 8
  - Red: < 8

### Step 4: Configure Panel Layout
Arrange panels in a responsive grid layout:

```
Row 1: [Panel 1] [Panel 2] [Panel 3]
Row 2: [Panel 4 - Full Width]
Row 3: [Panel 5] [Panel 6]
Row 4: [Panel 7] [Panel 8]
Row 5: [Panel 9 - Full Width]
Row 6: [Panel 10] [Panel 11]
```

### Step 5: Add Annotations
Configure annotations for important events:

1. **Startup/Shutdown Events**: Mark when boilers start/stop operating
2. **Temperature Events**: Highlight temperature excursions
3. **Maintenance**: Mark scheduled maintenance periods
4. **Fuel Refills**: Highlight when fuel is added

### Step 6: Configure Alerting Rules
Set up basic alerting for heat boiler monitoring:

1. **High Temperature Alert**:
   - Condition: Temperature > 120°C
   - Severity: Critical
   - Message: "Boiler temperature critical"

2. **High Pressure Alert**:
   - Condition: Pressure > 4 bar
   - Severity: Critical
   - Message: "Boiler pressure critical"

3. **Low Efficiency Alert**:
   - Condition: Efficiency < 70%
   - Severity: Warning
   - Message: "Boiler efficiency below 70%"

4. **No Data Alert**:
   - Condition: No data for > 5 minutes
   - Severity: Critical
   - Message: "Boiler data not received"

### Step 7: Add Operational Thresholds
Create reference lines for operational standards:

**Operational Standards**:
- **Optimal Temperature**: 80-100°C
- **Safe Pressure**: 1-3 bar
- **High Efficiency**: > 85%
- **Critical Limits**: Temperature > 120°C, Pressure > 4 bar

### Step 8: Test Dashboard
1. Verify all panels are displaying heat boiler data
2. Test dashboard variables (boiler_id, temp_range)
3. Check temperature and efficiency correlations
4. Validate alert conditions
5. Test responsive layout on different screen sizes
6. Verify fuel efficiency calculations

### Step 9: Validation Checklist
- [ ] Dashboard JSON file created with proper structure
- [ ] All 11 panels configured with correct Flux queries
- [ ] Dashboard variables configured and functional
- [ ] Panel layout responsive and well-organized
- [ ] Time series panels showing proper correlations
- [ ] Table panel displaying individual boiler data
- [ ] Histogram showing heat output distribution
- [ ] Bar chart showing daily heat production
- [ ] Alert rules configured for critical conditions
- [ ] Dashboard loads within 5 seconds
- [ ] Auto-refresh working (30-second intervals)
- [ ] Mobile responsiveness verified
- [ ] Fuel efficiency calculation accurate
- [ ] Temperature vs efficiency correlation visible

## Expected Output
- Complete heat boiler monitoring dashboard
- Real-time visualization of thermal performance
- Temperature and pressure monitoring
- Fuel consumption and efficiency tracking
- Fault detection and alerting capabilities
- Responsive design for field monitoring
- Integration with system overview dashboard

## Success Criteria
- Dashboard displays real-time heat boiler data from InfluxDB
- All panels show accurate thermal performance metrics
- Temperature vs efficiency correlation demonstrates realistic relationships
- Alert rules trigger appropriately for critical conditions
- Dashboard variables allow filtering by boiler and temperature range
- Mobile-responsive design works on tablets and phones
- Performance metrics match expected thermal generation patterns
- Fuel efficiency calculations are accurate

## Next Steps
After completing this task, proceed to Task 6: Energy Storage Monitoring Dashboard. 