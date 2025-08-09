# Task 3: Wind Turbine Analytics Dashboard

## Objective
Create a comprehensive dashboard for wind turbine performance analytics, including power curve analysis, wind speed correlations, efficiency metrics, and operational status monitoring.

## Prerequisites
- Task 1 completed (core dashboard setup)
- Task 2 completed (photovoltaic monitoring)
- InfluxDB 3.x with wind turbine data flowing from Node-RED simulations
- Access to Grafana web interface (http://localhost:3000)

## Task Steps

### Step 1: Create Wind Turbine Dashboard Structure
Create `grafana/dashboards/wind-turbine-analytics.json` with the following configuration:

**Dashboard Properties**:
- **Title**: "Wind Turbine Analytics"
- **Description**: "Advanced analytics and performance monitoring for wind turbines"
- **Tags**: ["wind-turbine", "analytics", "power-curve", "mvp"]
- **Time Range**: Last 24 hours (default)
- **Refresh**: 30 seconds
- **Editable**: true
- **Graph Tooltip**: Shared crosshair
- **Timezone**: UTC

### Step 2: Configure Dashboard Variables
Add the following variables:

1. **Turbine ID Variable**:
   - Name: `turbine_id`
   - Type: Query
   - Query: `from(bucket: "renewable_energy") |> range(start: -1h) |> filter(fn: (r) => r.device_type == "wind_turbine") |> group(columns: ["device_id"]) |> distinct(column: "device_id")`

2. **Wind Speed Range Variable**:
   - Name: `wind_speed_range`
   - Type: Custom
   - Values: 0-5, 5-10, 10-15, 15-20, 20+

### Step 3: Create Dashboard Panels

#### Panel 1: Total Wind Power Generation (Stat Panel)
- **Title**: "Total Wind Power Output"
- **Type**: Stat
- **Position**: Top row, left
- **Flux Query**:
```flux
from(bucket: "renewable_energy")
  |> range(start: -1h)
  |> filter(fn: (r) => r.device_type == "wind_turbine")
  |> filter(fn: (r) => r._field == "power_output")
  |> sum()
```
- **Display**: Large number with unit (W)
- **Color Mode**: Value
- **Thresholds**: 
  - Green: > 0
  - Yellow: > 5000
  - Red: > 10000

#### Panel 2: Current Wind Speed (Gauge)
- **Title**: "Current Wind Speed"
- **Type**: Gauge
- **Position**: Top row, center
- **Flux Query**:
```flux
from(bucket: "renewable_energy")
  |> range(start: -5m)
  |> filter(fn: (r) => r.device_type == "wind_turbine")
  |> filter(fn: (r) => r._field == "wind_speed")
  |> mean()
```
- **Min/Max**: 0-25
- **Unit**: m/s
- **Thresholds**:
  - Blue: 0-3 (cut-in)
  - Green: 3-12 (operational)
  - Yellow: 12-20 (high wind)
  - Red: 20-25 (cut-out)

#### Panel 3: Wind Direction (Stat Panel)
- **Title**: "Wind Direction"
- **Type**: Stat
- **Position**: Top row, right
- **Flux Query**:
```flux
from(bucket: "renewable_energy")
  |> range(start: -5m)
  |> filter(fn: (r) => r.device_type == "wind_turbine")
  |> filter(fn: (r) => r._field == "wind_direction")
  |> mean()
```
- **Display**: Large number with unit (degrees)
- **Color Mode**: Value
- **Custom Display**: Add compass direction (N, NE, E, SE, S, SW, W, NW)

#### Panel 4: Power Curve Analysis (Scatter Plot)
- **Title**: "Power Curve (Wind Speed vs Power Output)"
- **Type**: Scatter Plot
- **Position**: Second row, full width
- **Flux Query**:
```flux
from(bucket: "renewable_energy")
  |> range(start: -24h)
  |> filter(fn: (r) => r.device_type == "wind_turbine")
  |> filter(fn: (r) => r._field == "power_output" or r._field == "wind_speed")
  |> pivot(rowKey:["_time"], columnKey: ["_field"], valueColumn: "_value")
  |> filter(fn: (r) => r.wind_speed > 0)
```
- **X-Axis**: Wind Speed (m/s)
- **Y-Axis**: Power Output (W)
- **Point Size**: Based on frequency
- **Color**: By turbine ID

#### Panel 5: Wind Speed vs Power Output (Time Series)
- **Title**: "Wind Speed vs Power Output Over Time"
- **Type**: Time Series
- **Position**: Third row, left
- **Flux Query**:
```flux
from(bucket: "renewable_energy")
  |> range(start: -24h)
  |> filter(fn: (r) => r.device_type == "wind_turbine")
  |> filter(fn: (r) => r._field == "power_output" or r._field == "wind_speed")
  |> aggregateWindow(every: 5m, fn: mean, createEmpty: false)
  |> pivot(rowKey:["_time"], columnKey: ["_field"], valueColumn: "_value")
```
- **Y-Axis**: Dual axis (left: Power Output W, right: Wind Speed m/s)
- **Legend**: Show legend
- **Tooltip**: Shared crosshair

#### Panel 6: Turbine Efficiency (Gauge)
- **Title**: "Turbine Efficiency"
- **Type**: Gauge
- **Position**: Third row, right
- **Flux Query**:
```flux
from(bucket: "renewable_energy")
  |> range(start: -1h)
  |> filter(fn: (r) => r.device_type == "wind_turbine")
  |> filter(fn: (r) => r._field == "efficiency")
  |> mean()
```
- **Min/Max**: 0-100
- **Unit**: %
- **Thresholds**:
  - Green: > 80
  - Yellow: > 60
  - Red: < 60

#### Panel 7: Rotor Speed and Temperature (Time Series)
- **Title**: "Rotor Speed and Temperature"
- **Type**: Time Series
- **Position**: Fourth row, left
- **Flux Query**:
```flux
from(bucket: "renewable_energy")
  |> range(start: -24h)
  |> filter(fn: (r) => r.device_type == "wind_turbine")
  |> filter(fn: (r) => r._field == "rotor_speed" or r._field == "temperature")
  |> aggregateWindow(every: 5m, fn: mean, createEmpty: false)
  |> pivot(rowKey:["_time"], columnKey: ["_field"], valueColumn: "_value")
```
- **Y-Axis**: Dual axis (left: Rotor Speed RPM, right: Temperature °C)
- **Legend**: Show legend
- **Tooltip**: Shared crosshair

#### Panel 8: Wind Speed Distribution (Histogram)
- **Title**: "Wind Speed Distribution"
- **Type**: Histogram
- **Position**: Fourth row, right
- **Flux Query**:
```flux
from(bucket: "renewable_energy")
  |> range(start: -24h)
  |> filter(fn: (r) => r.device_type == "wind_turbine")
  |> filter(fn: (r) => r._field == "wind_speed")
  |> histogram(bins: 20)
```
- **X-Axis**: Wind Speed (m/s)
- **Y-Axis**: Frequency
- **Buckets**: 20 bins from 0-25 m/s

#### Panel 9: Individual Turbine Performance (Table)
- **Title**: "Individual Turbine Status"
- **Type**: Table
- **Position**: Fifth row, full width
- **Flux Query**:
```flux
from(bucket: "renewable_energy")
  |> range(start: -5m)
  |> filter(fn: (r) => r.device_type == "wind_turbine")
  |> filter(fn: (r) => r._field == "power_output" or r._field == "wind_speed" or r._field == "efficiency" or r._field == "status")
  |> pivot(rowKey:["_time"], columnKey: ["_field"], valueColumn: "_value")
  |> group(columns: ["device_id"])
  |> last()
  |> sort(columns: ["device_id"])
```
- **Columns**: Device ID, Power Output (W), Wind Speed (m/s), Efficiency (%), Status
- **Transformations**: 
  - Organize fields
  - Add color coding for status column

#### Panel 10: Capacity Factor (Stat Panel)
- **Title**: "Capacity Factor"
- **Type**: Stat
- **Position**: Sixth row, left
- **Flux Query**:
```flux
from(bucket: "renewable_energy")
  |> range(start: -24h)
  |> filter(fn: (r) => r.device_type == "wind_turbine")
  |> filter(fn: (r) => r._field == "power_output")
  |> mean()
  |> map(fn: (r) => ({r with _value: r._value / 10000.0 * 100})) // Assuming 10kW rated capacity
```
- **Display**: Percentage with unit (%)
- **Color Mode**: Value
- **Thresholds**:
  - Green: > 30
  - Yellow: > 20
  - Red: < 20

#### Panel 11: Operational Hours (Stat Panel)
- **Title**: "Operational Hours (24h)"
- **Type**: Stat
- **Position**: Sixth row, right
- **Flux Query**:
```flux
from(bucket: "renewable_energy")
  |> range(start: -24h)
  |> filter(fn: (r) => r.device_type == "wind_turbine")
  |> filter(fn: (r) => r._field == "power_output")
  |> filter(fn: (r) => r._value > 0)
  |> count()
  |> map(fn: (r) => ({r with _value: r._value * 0.5})) // Assuming 30-second intervals
```
- **Display**: Hours with unit (h)
- **Color Mode**: Value
- **Thresholds**:
  - Green: > 20
  - Yellow: > 15
  - Red: < 15

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

1. **Cut-in/Cut-out Events**: Mark when turbines start/stop operating
2. **High Wind Events**: Highlight periods of high wind speed
3. **Maintenance**: Mark scheduled maintenance periods
4. **Fault Events**: Highlight when turbines go into fault state

### Step 6: Configure Alerting Rules
Set up basic alerting for wind turbine monitoring:

1. **Low Wind Speed Alert**:
   - Condition: Wind speed < 3 m/s for > 1 hour
   - Severity: Info
   - Message: "Wind speed below cut-in threshold"

2. **High Wind Speed Alert**:
   - Condition: Wind speed > 20 m/s
   - Severity: Warning
   - Message: "Wind speed approaching cut-out threshold"

3. **Low Efficiency Alert**:
   - Condition: Efficiency < 60%
   - Severity: Warning
   - Message: "Wind turbine efficiency below 60%"

4. **No Data Alert**:
   - Condition: No data for > 5 minutes
   - Severity: Critical
   - Message: "Wind turbine data not received"

### Step 7: Add Power Curve Reference
Create a reference line for theoretical power curve:

**Theoretical Power Curve**:
- Cut-in speed: 3 m/s
- Rated speed: 12 m/s
- Cut-out speed: 25 m/s
- Rated power: 10,000 W

### Step 8: Test Dashboard
1. Verify all panels are displaying wind turbine data
2. Test dashboard variables (turbine_id, wind_speed_range)
3. Check power curve analysis
4. Validate alert conditions
5. Test responsive layout on different screen sizes
6. Verify wind direction display with compass directions

### Step 9: Validation Checklist
- [ ] Dashboard JSON file created with proper structure
- [ ] All 11 panels configured with correct Flux queries
- [ ] Dashboard variables configured and functional
- [ ] Panel layout responsive and well-organized
- [ ] Power curve scatter plot showing wind speed vs power correlation
- [ ] Time series panels showing proper correlations
- [ ] Table panel displaying individual turbine data
- [ ] Histogram showing wind speed distribution
- [ ] Alert rules configured for critical conditions
- [ ] Dashboard loads within 5 seconds
- [ ] Auto-refresh working (30-second intervals)
- [ ] Mobile responsiveness verified
- [ ] Wind direction display with compass directions
- [ ] Capacity factor calculation accurate

## Expected Output
- Complete wind turbine analytics dashboard
- Real-time visualization of wind turbine performance
- Power curve analysis and wind speed correlations
- Fault detection and alerting capabilities
- Responsive design for field monitoring
- Integration with system overview dashboard

## Success Criteria
- Dashboard displays real-time wind turbine data from InfluxDB
- All panels show accurate wind turbine metrics
- Power curve analysis demonstrates realistic wind-power relationships
- Alert rules trigger appropriately for wind conditions
- Dashboard variables allow filtering by turbine and wind speed range
- Mobile-responsive design works on tablets and phones
- Performance metrics match expected wind generation patterns
- Capacity factor calculations are accurate

## Next Steps
After completing this task, proceed to Task 4: Biogas Plant Metrics Dashboard. 