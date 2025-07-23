# Task 6: Energy Storage Monitoring Dashboard

## Objective
Create a comprehensive dashboard for energy storage system monitoring, including battery state of charge, voltage and current monitoring, temperature tracking, charge/discharge cycles, and battery health indicators.

## Prerequisites
- Task 1 completed (core dashboard setup)
- Task 2 completed (photovoltaic monitoring)
- Task 3 completed (wind turbine analytics)
- Task 4 completed (biogas plant metrics)
- Task 5 completed (heat boiler monitoring)
- InfluxDB 3.x with energy storage data flowing from Node-RED simulations
- Access to Grafana web interface (http://localhost:3000)

## Task Steps

### Step 1: Create Energy Storage Dashboard Structure
Create `grafana/dashboards/energy-storage-monitoring.json` with the following configuration:

**Dashboard Properties**:
- **Title**: "Energy Storage Monitoring"
- **Description**: "Real-time monitoring of battery systems, state of charge, and energy management"
- **Tags**: ["energy-storage", "battery", "soc", "mvp"]
- **Time Range**: Last 24 hours (default)
- **Refresh**: 30 seconds
- **Editable**: true
- **Graph Tooltip**: Shared crosshair
- **Timezone**: UTC

### Step 2: Configure Dashboard Variables
Add the following variables:

1. **Battery ID Variable**:
   - Name: `battery_id`
   - Type: Query
   - Query: `from(bucket: "renewable_energy") |> range(start: -1h) |> filter(fn: (r) => r.device_type == "energy_storage") |> group(columns: ["device_id"]) |> distinct(column: "device_id")`

2. **State of Charge Range Variable**:
   - Name: `soc_range`
   - Type: Custom
   - Values: <20%, 20-40%, 40-60%, 60-80%, 80-100%

### Step 3: Create Dashboard Panels

#### Panel 1: Total Stored Energy (Stat Panel)
- **Title**: "Total Stored Energy"
- **Type**: Stat
- **Position**: Top row, left
- **Flux Query**:
```flux
from(bucket: "renewable_energy")
  |> range(start: -5m)
  |> filter(fn: (r) => r.device_type == "energy_storage")
  |> filter(fn: (r) => r._field == "stored_energy")
  |> sum()
```
- **Display**: Large number with unit (kWh)
- **Color Mode**: Value
- **Thresholds**: 
  - Red: < 10
  - Yellow: 10-50
  - Green: > 50

#### Panel 2: Average State of Charge (Gauge)
- **Title**: "Average State of Charge"
- **Type**: Gauge
- **Position**: Top row, center
- **Flux Query**:
```flux
from(bucket: "renewable_energy")
  |> range(start: -5m)
  |> filter(fn: (r) => r.device_type == "energy_storage")
  |> filter(fn: (r) => r._field == "state_of_charge")
  |> mean()
```
- **Min/Max**: 0-100
- **Unit**: %
- **Thresholds**:
  - Red: 0-20 (critical)
  - Yellow: 20-40 (low)
  - Green: 40-80 (normal)
  - Yellow: 80-90 (high)
  - Red: 90-100 (full)

#### Panel 3: Battery Temperature (Stat Panel)
- **Title**: "Battery Temperature"
- **Type**: Stat
- **Position**: Top row, right
- **Flux Query**:
```flux
from(bucket: "renewable_energy")
  |> range(start: -5m)
  |> filter(fn: (r) => r.device_type == "energy_storage")
  |> filter(fn: (r) => r._field == "temperature")
  |> mean()
```
- **Display**: Large number with unit (°C)
- **Color Mode**: Value
- **Thresholds**:
  - Blue: < 10°C (cold)
  - Green: 10-35°C (optimal)
  - Yellow: 35-45°C (warm)
  - Red: > 45°C (hot)

#### Panel 4: State of Charge Over Time (Time Series)
- **Title**: "State of Charge Trends"
- **Type**: Time Series
- **Position**: Second row, full width
- **Flux Query**:
```flux
from(bucket: "renewable_energy")
  |> range(start: -24h)
  |> filter(fn: (r) => r.device_type == "energy_storage")
  |> filter(fn: (r) => r._field == "state_of_charge")
  |> aggregateWindow(every: 5m, fn: mean, createEmpty: false)
  |> group(columns: ["device_id"])
```
- **Y-Axis**: State of Charge (%)
- **Legend**: Show legend
- **Tooltip**: Shared crosshair
- **Thresholds**: Add reference lines at 20% and 80%

#### Panel 5: Voltage and Current Trends (Time Series)
- **Title**: "Voltage and Current Trends"
- **Type**: Time Series
- **Position**: Third row, left
- **Flux Query**:
```flux
from(bucket: "renewable_energy")
  |> range(start: -24h)
  |> filter(fn: (r) => r.device_type == "energy_storage")
  |> filter(fn: (r) => r._field == "voltage" or r._field == "current")
  |> aggregateWindow(every: 5m, fn: mean, createEmpty: false)
  |> pivot(rowKey:["_time"], columnKey: ["_field"], valueColumn: "_value")
```
- **Y-Axis**: Dual axis (left: Voltage V, right: Current A)
- **Legend**: Show legend
- **Tooltip**: Shared crosshair

#### Panel 6: Battery Health (Gauge)
- **Title**: "Battery Health"
- **Type**: Gauge
- **Position**: Third row, right
- **Flux Query**:
```flux
from(bucket: "renewable_energy")
  |> range(start: -1h)
  |> filter(fn: (r) => r.device_type == "energy_storage")
  |> filter(fn: (r) => r._field == "health")
  |> mean()
```
- **Min/Max**: 0-100
- **Unit**: %
- **Thresholds**:
  - Green: > 80
  - Yellow: > 60
  - Red: < 60

#### Panel 7: Charge/Discharge Cycles (Time Series)
- **Title**: "Charge/Discharge Cycles"
- **Type**: Time Series
- **Position**: Fourth row, left
- **Flux Query**:
```flux
from(bucket: "renewable_energy")
  |> range(start: -24h)
  |> filter(fn: (r) => r.device_type == "energy_storage")
  |> filter(fn: (r) => r._field == "charge_cycles" or r._field == "discharge_cycles")
  |> aggregateWindow(every: 5m, fn: mean, createEmpty: false)
  |> pivot(rowKey:["_time"], columnKey: ["_field"], valueColumn: "_value")
```
- **Y-Axis**: Cycle Count
- **Legend**: Show legend
- **Tooltip**: Shared crosshair

#### Panel 8: Energy Flow Distribution (Pie Chart)
- **Title**: "Energy Flow Distribution"
- **Type**: Pie Chart
- **Position**: Fourth row, right
- **Flux Query**:
```flux
from(bucket: "renewable_energy")
  |> range(start: -1h)
  |> filter(fn: (r) => r.device_type == "energy_storage")
  |> filter(fn: (r) => r._field == "charge_power" or r._field == "discharge_power")
  |> group(columns: ["_field"])
  |> sum()
```
- **Display**: Percentage distribution
- **Legend**: Show legend
- **Colors**: Green for charging, Red for discharging

#### Panel 9: Individual Battery Performance (Table)
- **Title**: "Individual Battery Status"
- **Type**: Table
- **Position**: Fifth row, full width
- **Flux Query**:
```flux
from(bucket: "renewable_energy")
  |> range(start: -5m)
  |> filter(fn: (r) => r.device_type == "energy_storage")
  |> filter(fn: (r) => r._field == "state_of_charge" or r._field == "voltage" or r._field == "temperature" or r._field == "health" or r._field == "status")
  |> pivot(rowKey:["_time"], columnKey: ["_field"], valueColumn: "_value")
  |> group(columns: ["device_id"])
  |> last()
  |> sort(columns: ["device_id"])
```
- **Columns**: Device ID, State of Charge (%), Voltage (V), Temperature (°C), Health (%), Status
- **Transformations**: 
  - Organize fields
  - Add color coding for status column
  - Format state of charge as percentage

#### Panel 10: Daily Energy Throughput (Bar Chart)
- **Title**: "Daily Energy Throughput (7 Days)"
- **Type**: Bar Chart
- **Position**: Sixth row, left
- **Flux Query**:
```flux
from(bucket: "renewable_energy")
  |> range(start: -7d)
  |> filter(fn: (r) => r.device_type == "energy_storage")
  |> filter(fn: (r) => r._field == "charge_power" or r._field == "discharge_power")
  |> aggregateWindow(every: 1d, fn: sum, createEmpty: false)
  |> pivot(rowKey:["_time"], columnKey: ["_field"], valueColumn: "_value")
  |> map(fn: (r) => ({r with _value: r.charge_power + r.discharge_power}))
```
- **Y-Axis**: Energy Throughput (kWh/day)
- **X-Axis**: Date
- **Orientation**: Vertical
- **Color**: By battery ID

#### Panel 11: Cycle Count (Stat Panel)
- **Title**: "Total Cycle Count"
- **Type**: Stat
- **Position**: Sixth row, right
- **Flux Query**:
```flux
from(bucket: "renewable_energy")
  |> range(start: -1h)
  |> filter(fn: (r) => r.device_type == "energy_storage")
  |> filter(fn: (r) => r._field == "charge_cycles" or r._field == "discharge_cycles")
  |> pivot(rowKey:["_time"], columnKey: ["_field"], valueColumn: "_value")
  |> map(fn: (r) => ({r with _value: r.charge_cycles + r.discharge_cycles}))
  |> mean()
```
- **Display**: Number with unit (cycles)
- **Color Mode**: Value
- **Thresholds**:
  - Green: < 1000
  - Yellow: 1000-2000
  - Red: > 2000

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

1. **Charge/Discharge Events**: Mark when batteries start charging/discharging
2. **Temperature Events**: Highlight temperature excursions
3. **Maintenance**: Mark scheduled maintenance periods
4. **Health Degradation**: Highlight when battery health drops

### Step 6: Configure Alerting Rules
Set up basic alerting for energy storage monitoring:

1. **Low State of Charge Alert**:
   - Condition: State of charge < 20%
   - Severity: Critical
   - Message: "Battery state of charge critical"

2. **High Temperature Alert**:
   - Condition: Temperature > 45°C
   - Severity: Critical
   - Message: "Battery temperature critical"

3. **Low Battery Health Alert**:
   - Condition: Health < 60%
   - Severity: Warning
   - Message: "Battery health below 60%"

4. **No Data Alert**:
   - Condition: No data for > 5 minutes
   - Severity: Critical
   - Message: "Battery data not received"

### Step 7: Add Battery Management Thresholds
Create reference lines for battery management:

**Battery Management Standards**:
- **Optimal SOC Range**: 20-80%
- **Safe Temperature**: 10-35°C
- **Good Health**: > 80%
- **Critical Limits**: SOC < 10%, Temperature > 50°C

### Step 8: Test Dashboard
1. Verify all panels are displaying energy storage data
2. Test dashboard variables (battery_id, soc_range)
3. Check state of charge trends
4. Validate alert conditions
5. Test responsive layout on different screen sizes
6. Verify cycle count calculations

### Step 9: Validation Checklist
- [ ] Dashboard JSON file created with proper structure
- [ ] All 11 panels configured with correct Flux queries
- [ ] Dashboard variables configured and functional
- [ ] Panel layout responsive and well-organized
- [ ] Time series panels showing proper trends
- [ ] Table panel displaying individual battery data
- [ ] Pie chart showing energy flow distribution
- [ ] Bar chart showing daily energy throughput
- [ ] Alert rules configured for critical conditions
- [ ] Dashboard loads within 5 seconds
- [ ] Auto-refresh working (30-second intervals)
- [ ] Mobile responsiveness verified
- [ ] Cycle count calculation accurate
- [ ] State of charge trends visible with thresholds

## Expected Output
- Complete energy storage monitoring dashboard
- Real-time visualization of battery performance
- State of charge and health monitoring
- Charge/discharge cycle tracking
- Temperature and voltage monitoring
- Fault detection and alerting capabilities
- Responsive design for field monitoring
- Integration with system overview dashboard

## Success Criteria
- Dashboard displays real-time energy storage data from InfluxDB
- All panels show accurate battery performance metrics
- State of charge trends demonstrate realistic charge/discharge patterns
- Alert rules trigger appropriately for critical conditions
- Dashboard variables allow filtering by battery and SOC range
- Mobile-responsive design works on tablets and phones
- Performance metrics match expected battery behavior patterns
- Cycle count and health calculations are accurate

## Next Steps
After completing this task, proceed to Task 7: Advanced Features and Alerting Integration. 