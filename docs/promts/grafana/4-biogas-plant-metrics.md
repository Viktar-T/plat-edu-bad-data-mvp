# Task 4: Biogas Plant Metrics Dashboard

## Objective
Create a comprehensive dashboard for biogas plant monitoring, including gas production metrics, methane concentration analysis, temperature and pressure monitoring, and operational efficiency tracking.

## Prerequisites
- Task 1 completed (core dashboard setup)
- Task 2 completed (photovoltaic monitoring)
- Task 3 completed (wind turbine analytics)
- InfluxDB 3.x with biogas plant data flowing from Node-RED simulations
- Access to Grafana web interface (http://localhost:3000)

## Task Steps

### Step 1: Create Biogas Plant Dashboard Structure
Create `grafana/dashboards/biogas-plant-metrics.json` with the following configuration:

**Dashboard Properties**:
- **Title**: "Biogas Plant Metrics"
- **Description**: "Real-time monitoring of biogas production, gas quality, and plant efficiency"
- **Tags**: ["biogas", "gas-production", "methane", "mvp"]
- **Time Range**: Last 24 hours (default)
- **Refresh**: 30 seconds
- **Editable**: true
- **Graph Tooltip**: Shared crosshair
- **Timezone**: UTC

### Step 2: Configure Dashboard Variables
Add the following variables:

1. **Plant ID Variable**:
   - Name: `plant_id`
   - Type: Query
   - Query: `from(bucket: "renewable_energy") |> range(start: -1h) |> filter(fn: (r) => r.device_type == "biogas_plant") |> group(columns: ["device_id"]) |> distinct(column: "device_id")`

2. **Gas Quality Range Variable**:
   - Name: `methane_range`
   - Type: Custom
   - Values: <50%, 50-60%, 60-70%, 70-80%, >80%

### Step 3: Create Dashboard Panels

#### Panel 1: Total Gas Production (Stat Panel)
- **Title**: "Total Gas Production"
- **Type**: Stat
- **Position**: Top row, left
- **Flux Query**:
```flux
from(bucket: "renewable_energy")
  |> range(start: -1h)
  |> filter(fn: (r) => r.device_type == "biogas_plant")
  |> filter(fn: (r) => r._field == "gas_flow_rate")
  |> sum()
```
- **Display**: Large number with unit (m³/h)
- **Color Mode**: Value
- **Thresholds**: 
  - Green: > 0
  - Yellow: > 100
  - Red: > 200

#### Panel 2: Methane Concentration (Gauge)
- **Title**: "Methane Concentration"
- **Type**: Gauge
- **Position**: Top row, center
- **Flux Query**:
```flux
from(bucket: "renewable_energy")
  |> range(start: -5m)
  |> filter(fn: (r) => r.device_type == "biogas_plant")
  |> filter(fn: (r) => r._field == "methane_concentration")
  |> mean()
```
- **Min/Max**: 0-100
- **Unit**: %
- **Thresholds**:
  - Red: 0-50 (poor quality)
  - Yellow: 50-70 (medium quality)
  - Green: 70-100 (high quality)

#### Panel 3: Plant Temperature (Stat Panel)
- **Title**: "Plant Temperature"
- **Type**: Stat
- **Position**: Top row, right
- **Flux Query**:
```flux
from(bucket: "renewable_energy")
  |> range(start: -5m)
  |> filter(fn: (r) => r.device_type == "biogas_plant")
  |> filter(fn: (r) => r._field == "temperature")
  |> mean()
```
- **Display**: Large number with unit (°C)
- **Color Mode**: Value
- **Thresholds**:
  - Blue: < 30°C
  - Green: 30-45°C (optimal)
  - Yellow: 45-55°C
  - Red: > 55°C

#### Panel 4: Gas Flow and Methane Correlation (Time Series)
- **Title**: "Gas Flow vs Methane Concentration"
- **Type**: Time Series
- **Position**: Second row, full width
- **Flux Query**:
```flux
from(bucket: "renewable_energy")
  |> range(start: -24h)
  |> filter(fn: (r) => r.device_type == "biogas_plant")
  |> filter(fn: (r) => r._field == "gas_flow_rate" or r._field == "methane_concentration")
  |> aggregateWindow(every: 5m, fn: mean, createEmpty: false)
  |> pivot(rowKey:["_time"], columnKey: ["_field"], valueColumn: "_value")
```
- **Y-Axis**: Dual axis (left: Gas Flow m³/h, right: Methane %)
- **Legend**: Show legend
- **Tooltip**: Shared crosshair

#### Panel 5: Temperature and Pressure Trends (Time Series)
- **Title**: "Temperature and Pressure Trends"
- **Type**: Time Series
- **Position**: Third row, left
- **Flux Query**:
```flux
from(bucket: "renewable_energy")
  |> range(start: -24h)
  |> filter(fn: (r) => r.device_type == "biogas_plant")
  |> filter(fn: (r) => r._field == "temperature" or r._field == "pressure")
  |> aggregateWindow(every: 5m, fn: mean, createEmpty: false)
  |> pivot(rowKey:["_time"], columnKey: ["_field"], valueColumn: "_value")
```
- **Y-Axis**: Dual axis (left: Temperature °C, right: Pressure bar)
- **Legend**: Show legend
- **Tooltip**: Shared crosshair

#### Panel 6: Plant Efficiency (Gauge)
- **Title**: "Plant Efficiency"
- **Type**: Gauge
- **Position**: Third row, right
- **Flux Query**:
```flux
from(bucket: "renewable_energy")
  |> range(start: -1h)
  |> filter(fn: (r) => r.device_type == "biogas_plant")
  |> filter(fn: (r) => r._field == "efficiency")
  |> mean()
```
- **Min/Max**: 0-100
- **Unit**: %
- **Thresholds**:
  - Green: > 80
  - Yellow: > 60
  - Red: < 60

#### Panel 7: Daily Gas Production Comparison (Bar Chart)
- **Title**: "Daily Gas Production (7 Days)"
- **Type**: Bar Chart
- **Position**: Fourth row, left
- **Flux Query**:
```flux
from(bucket: "renewable_energy")
  |> range(start: -7d)
  |> filter(fn: (r) => r.device_type == "biogas_plant")
  |> filter(fn: (r) => r._field == "gas_flow_rate")
  |> aggregateWindow(every: 1d, fn: sum, createEmpty: false)
```
- **Y-Axis**: Gas Production (m³/day)
- **X-Axis**: Date
- **Orientation**: Vertical
- **Color**: By plant ID

#### Panel 8: Methane Quality Distribution (Histogram)
- **Title**: "Methane Concentration Distribution"
- **Type**: Histogram
- **Position**: Fourth row, right
- **Flux Query**:
```flux
from(bucket: "renewable_energy")
  |> range(start: -24h)
  |> filter(fn: (r) => r.device_type == "biogas_plant")
  |> filter(fn: (r) => r._field == "methane_concentration")
  |> histogram(bins: 20)
```
- **X-Axis**: Methane Concentration (%)
- **Y-Axis**: Frequency
- **Buckets**: 20 bins from 0-100%

#### Panel 9: Individual Plant Performance (Table)
- **Title**: "Individual Plant Status"
- **Type**: Table
- **Position**: Fifth row, full width
- **Flux Query**:
```flux
from(bucket: "renewable_energy")
  |> range(start: -5m)
  |> filter(fn: (r) => r.device_type == "biogas_plant")
  |> filter(fn: (r) => r._field == "gas_flow_rate" or r._field == "methane_concentration" or r._field == "temperature" or r._field == "efficiency" or r._field == "status")
  |> pivot(rowKey:["_time"], columnKey: ["_field"], valueColumn: "_value")
  |> group(columns: ["device_id"])
  |> last()
  |> sort(columns: ["device_id"])
```
- **Columns**: Device ID, Gas Flow (m³/h), Methane (%), Temperature (°C), Efficiency (%), Status
- **Transformations**: 
  - Organize fields
  - Add color coding for status column
  - Format methane concentration as percentage

#### Panel 10: Gas Quality Score (Stat Panel)
- **Title**: "Gas Quality Score"
- **Type**: Stat
- **Position**: Sixth row, left
- **Flux Query**:
```flux
from(bucket: "renewable_energy")
  |> range(start: -1h)
  |> filter(fn: (r) => r.device_type == "biogas_plant")
  |> filter(fn: (r) => r._field == "methane_concentration")
  |> mean()
  |> map(fn: (r) => ({r with _value: if r._value >= 70 then 100 else if r._value >= 50 then 70 else 30}))
```
- **Display**: Score with unit (0-100)
- **Color Mode**: Value
- **Thresholds**:
  - Green: 100 (excellent)
  - Yellow: 70 (good)
  - Red: 30 (poor)

#### Panel 11: Production Efficiency (Stat Panel)
- **Title**: "Production Efficiency"
- **Type**: Stat
- **Position**: Sixth row, right
- **Flux Query**:
```flux
from(bucket: "renewable_energy")
  |> range(start: -24h)
  |> filter(fn: (r) => r.device_type == "biogas_plant")
  |> filter(fn: (r) => r._field == "gas_flow_rate")
  |> mean()
  |> map(fn: (r) => ({r with _value: r._value / 150.0 * 100})) // Assuming 150 m³/h as optimal
```
- **Display**: Percentage with unit (%)
- **Color Mode**: Value
- **Thresholds**:
  - Green: > 80
  - Yellow: > 60
  - Red: < 60

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

1. **Feedstock Changes**: Mark when different feedstocks are added
2. **Temperature Events**: Highlight temperature excursions
3. **Maintenance**: Mark scheduled maintenance periods
4. **Quality Issues**: Highlight when methane concentration drops

### Step 6: Configure Alerting Rules
Set up basic alerting for biogas plant monitoring:

1. **Low Methane Concentration Alert**:
   - Condition: Methane concentration < 50%
   - Severity: Warning
   - Message: "Biogas methane concentration below 50%"

2. **High Temperature Alert**:
   - Condition: Temperature > 55°C
   - Severity: Critical
   - Message: "Biogas plant temperature critical"

3. **Low Gas Flow Alert**:
   - Condition: Gas flow rate < 10 m³/h for > 1 hour
   - Severity: Warning
   - Message: "Biogas production rate low"

4. **No Data Alert**:
   - Condition: No data for > 5 minutes
   - Severity: Critical
   - Message: "Biogas plant data not received"

### Step 7: Add Quality Thresholds
Create reference lines for gas quality standards:

**Gas Quality Standards**:
- **High Quality**: > 70% methane
- **Medium Quality**: 50-70% methane
- **Low Quality**: < 50% methane

### Step 8: Test Dashboard
1. Verify all panels are displaying biogas plant data
2. Test dashboard variables (plant_id, methane_range)
3. Check gas flow and methane correlations
4. Validate alert conditions
5. Test responsive layout on different screen sizes
6. Verify gas quality calculations

### Step 9: Validation Checklist
- [ ] Dashboard JSON file created with proper structure
- [ ] All 11 panels configured with correct Flux queries
- [ ] Dashboard variables configured and functional
- [ ] Panel layout responsive and well-organized
- [ ] Time series panels showing proper correlations
- [ ] Table panel displaying individual plant data
- [ ] Histogram showing methane concentration distribution
- [ ] Bar chart showing daily production comparison
- [ ] Alert rules configured for critical conditions
- [ ] Dashboard loads within 5 seconds
- [ ] Auto-refresh working (30-second intervals)
- [ ] Mobile responsiveness verified
- [ ] Gas quality score calculation accurate
- [ ] Production efficiency calculations correct

## Expected Output
- Complete biogas plant metrics dashboard
- Real-time visualization of gas production and quality
- Methane concentration analysis and distribution
- Temperature and pressure monitoring
- Fault detection and alerting capabilities
- Responsive design for field monitoring
- Integration with system overview dashboard

## Success Criteria
- Dashboard displays real-time biogas plant data from InfluxDB
- All panels show accurate biogas production metrics
- Gas quality analysis demonstrates realistic methane concentrations
- Alert rules trigger appropriately for quality and production issues
- Dashboard variables allow filtering by plant and methane range
- Mobile-responsive design works on tablets and phones
- Performance metrics match expected biogas production patterns
- Gas quality score and efficiency calculations are accurate

## Next Steps
After completing this task, proceed to Task 5: Heat Boiler Monitoring Dashboard. 