# Manual Test 05: Grafana Data Visualization

## Overview
This test verifies that Grafana is properly connecting to InfluxDB, displaying data through dashboards, and providing real-time monitoring capabilities for the renewable energy system.

## Test Objective
Ensure Grafana dashboards are functional, data is displayed correctly, and visualization features work as expected.

## Prerequisites
- Manual Test 01, 02, 03, and 04 completed successfully
- Grafana accessible at http://localhost:3000
- InfluxDB containing test data
- Web browser for dashboard testing

## Test Steps

### Step 1: Access Grafana Interface

#### 1.1 Open Grafana Dashboard
**Action:**
1. Open web browser
2. Navigate to http://localhost:3000
3. Login with credentials: admin/admin

**Expected Result:**
- Grafana login page loads
- Login is successful
- Dashboard appears without errors

#### 1.2 Verify Grafana Service Status
**Command:**
```powershell
Invoke-WebRequest -Uri http://localhost:3000/api/health -UseBasicParsing
```

**Expected Result:**
- Returns HTTP 200 OK
- JSON response with "ok" status
- Service is healthy

### Step 2: Test Data Source Configuration

#### 2.1 Verify InfluxDB Data Source
**Action:**
1. In Grafana, go to Configuration → Data Sources
2. Check if InfluxDB data source is configured
3. Test the connection

**Expected Result:**
- InfluxDB data source is listed
- Connection test passes
- No configuration errors

#### 2.2 Test Data Source Connection
**Action:**
1. Click on the InfluxDB data source
2. Click "Test" button
3. Verify connection status

**Expected Result:**
- Connection test shows "Success"
- No error messages
- Data source is accessible

### Step 3: Test Dashboard Access

#### 3.1 Browse Available Dashboards
**Action:**
1. Go to Dashboards → Browse
2. Check for available dashboards
3. Verify dashboard list

**Expected Result:**
- Dashboards are listed
- Should include:
  - Renewable Energy Overview
  - Photovoltaic Monitoring
  - Wind Turbine Analytics
  - Biogas Plant Metrics
  - Heat Boiler Monitoring
  - Energy Storage Monitoring

#### 3.2 Open Main Overview Dashboard
**Action:**
1. Click on "Renewable Energy Overview" dashboard
2. Wait for dashboard to load
3. Check all panels

**Expected Result:**
- Dashboard loads successfully
- All panels display data
- No error messages

### Step 4: Test Real-time Data Display

#### 4.1 Send Test Data and Verify Display
**Command:**
```powershell
# Send photovoltaic test data
$pvData = @{
    device_id = "pv_001"
    device_type = "photovoltaic"
    timestamp = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ssZ")
    data = @{
        irradiance = 850.5
        temperature = 45.2
        voltage = 48.3
        current = 12.1
        power_output = 584.43
    }
    status = "operational"
    location = "site_a"
} | ConvertTo-Json -Depth 3

mosquitto_pub -h localhost -p 1883 -u pv_001 -P device_password_123 -t devices/photovoltaic/pv_001/data -m $pvData
```

**Action in Grafana:**
1. Open Photovoltaic Monitoring dashboard
2. Check if new data appears
3. Verify real-time updates

**Expected Result:**
- New data appears in dashboard
- Real-time updates work
- Data values are correct

#### 4.2 Test Multiple Device Types
**Command:**
```powershell
# Send wind turbine data
$wtData = @{
    device_id = "wt_001"
    device_type = "wind_turbine"
    timestamp = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ssZ")
    data = @{
        wind_speed = 12.5
        power_output = 850.2
        rpm = 1200
        temperature = 35.1
    }
    status = "operational"
    location = "site_b"
} | ConvertTo-Json -Depth 3

mosquitto_pub -h localhost -p 1883 -u wt_001 -P device_password_123 -t devices/wind_turbine/wt_001/data -m $wtData

# Send biogas plant data
$bgData = @{
    device_id = "bg_001"
    device_type = "biogas_plant"
    timestamp = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ssZ")
    data = @{
        gas_flow = 25.5
        methane_concentration = 65.2
        temperature = 38.5
        pressure = 1.2
    }
    status = "operational"
    location = "site_c"
} | ConvertTo-Json -Depth 3

mosquitto_pub -h localhost -p 1883 -u bg_001 -P device_password_123 -t devices/biogas_plant/bg_001/data -m $bgData
```

**Action in Grafana:**
1. Check Wind Turbine Analytics dashboard
2. Check Biogas Plant Metrics dashboard
3. Verify data appears in both

**Expected Result:**
- Data appears in respective dashboards
- All device types are displayed
- No cross-contamination of data

### Step 5: Test Dashboard Functionality

#### 5.1 Test Time Range Selection
**Action:**
1. In any dashboard, change time range
2. Try different ranges: Last 1 hour, Last 6 hours, Last 24 hours
3. Verify data updates accordingly

**Expected Result:**
- Time range changes work
- Data updates based on selected range
- No errors during range changes

#### 5.2 Test Panel Interactions
**Action:**
1. Click on different panels
2. Test zoom functionality
3. Check panel options

**Expected Result:**
- Panel interactions work
- Zoom functionality operates correctly
- Panel options are accessible

#### 5.3 Test Variable Selection (if applicable)
**Action:**
1. Check for dashboard variables
2. Test variable selection
3. Verify data filtering

**Expected Result:**
- Variables work correctly
- Data filtering functions properly
- No variable-related errors

### Step 6: Test Data Visualization Types

#### 6.1 Test Time Series Graphs
**Action:**
1. Open Photovoltaic Monitoring dashboard
2. Check time series panels
3. Verify graph displays correctly

**Expected Result:**
- Time series graphs display data
- X-axis shows time correctly
- Y-axis shows appropriate values

#### 6.2 Test Gauge Panels
**Action:**
1. Look for gauge-type panels
2. Check gauge readings
3. Verify gauge ranges

**Expected Result:**
- Gauges display current values
- Ranges are appropriate
- Colors indicate status correctly

#### 6.3 Test Stat Panels
**Action:**
1. Check stat panels
2. Verify current values
3. Test trend indicators

**Expected Result:**
- Stat panels show current values
- Trend indicators work
- Values are accurate

#### 6.4 Test Table Panels
**Action:**
1. Look for table panels
2. Check data rows
3. Test sorting functionality

**Expected Result:**
- Tables display data correctly
- Sorting works
- All columns are visible

### Step 7: Test Query Performance

#### 7.1 Test Dashboard Load Time
**Action:**
1. Open dashboard
2. Measure load time
3. Check for performance issues

**Expected Result:**
- Dashboard loads within reasonable time (< 10 seconds)
- No timeout errors
- Smooth user experience

#### 7.2 Test Query Execution
**Action:**
1. Open panel edit mode
2. Check query execution time
3. Verify query results

**Expected Result:**
- Queries execute quickly
- Results are accurate
- No query errors

### Step 8: Test Alerting (if configured)

#### 8.1 Check Alert Rules
**Action:**
1. Go to Alerting → Alert Rules
2. Check for configured alerts
3. Verify alert conditions

**Expected Result:**
- Alert rules are configured (if applicable)
- Alert conditions are appropriate
- No alert configuration errors

#### 8.2 Test Alert Triggers
**Command:**
```powershell
# Send data that might trigger alerts
$alertData = @{
    device_id = "pv_001"
    device_type = "photovoltaic"
    timestamp = (Get-Date).ToString("yyyy-MM-ddTHH:mm:ssZ")
    data = @{
        irradiance = 850.5
        temperature = 90.0  # High temperature
        voltage = 48.3
        current = 12.1
        power_output = 584.43
    }
    status = "operational"
    location = "site_a"
} | ConvertTo-Json -Depth 3

mosquitto_pub -h localhost -p 1883 -u pv_001 -P device_password_123 -t devices/photovoltaic/pv_001/data -m $alertData
```

**Action in Grafana:**
1. Check alert status
2. Verify alert notifications
3. Test alert acknowledgment

**Expected Result:**
- Alerts trigger appropriately (if configured)
- Alert notifications work
- Alert management functions correctly

### Step 9: Test Dashboard Export/Import

#### 9.1 Test Dashboard Export
**Action:**
1. Open any dashboard
2. Go to Settings → JSON Model
3. Copy dashboard JSON

**Expected Result:**
- Dashboard JSON is accessible
- JSON format is valid
- Export functionality works

#### 9.2 Test Dashboard Import
**Action:**
1. Go to Dashboards → Import
2. Paste dashboard JSON
3. Verify import

**Expected Result:**
- Import completes successfully
- Dashboard appears correctly
- All panels are functional

### Step 10: Test User Interface

#### 10.1 Test Responsive Design
**Action:**
1. Resize browser window
2. Check dashboard responsiveness
3. Test on different screen sizes

**Expected Result:**
- Dashboard adapts to screen size
- Panels resize appropriately
- No layout issues

#### 10.2 Test Navigation
**Action:**
1. Navigate between dashboards
2. Test breadcrumb navigation
3. Check menu functionality

**Expected Result:**
- Navigation works smoothly
- Breadcrumbs are accurate
- Menu functions correctly

## Test Results Documentation

### Pass Criteria
- Grafana interface is accessible
- Data source connection works
- All dashboards load successfully
- Real-time data updates work
- Dashboard functionality operates correctly
- All visualization types display properly
- Query performance is acceptable
- Alerting works (if configured)
- Export/import functionality works
- User interface is responsive

### Fail Criteria
- Grafana interface is not accessible
- Data source connection fails
- Dashboards do not load
- Real-time updates do not work
- Dashboard functionality issues
- Visualization display problems
- Poor query performance
- Alerting failures
- Export/import problems
- User interface issues

## Troubleshooting

### Common Issues

#### 1. Grafana Not Accessible
**Problem:** Cannot access http://localhost:3000
**Solution:**
```powershell
# Check Grafana container status
docker-compose ps grafana

# Check Grafana logs
docker-compose logs grafana

# Restart Grafana service
docker-compose restart grafana
```

#### 2. Data Source Connection Issues
**Problem:** InfluxDB data source connection fails
**Solution:**
```powershell
# Check InfluxDB status
docker-compose ps influxdb

# Verify InfluxDB is accessible
Invoke-WebRequest -Uri http://localhost:8086/health -UseBasicParsing

# Check data source configuration in Grafana
```

#### 3. Dashboard Not Loading
**Problem:** Dashboards show no data or errors
**Solution:**
```powershell
# Check if data exists in InfluxDB
$params = @{
    db = "renewable_energy"
    q = "SELECT COUNT(*) FROM photovoltaic_data"
}
Invoke-WebRequest -Uri "http://localhost:8086/query" -Method GET -Body $params -UseBasicParsing

# Verify dashboard queries
# Check panel configurations
```

#### 4. Performance Issues
**Problem:** Slow dashboard loading or query execution
**Solution:**
```powershell
# Check system resources
docker stats

# Optimize queries
# Check InfluxDB performance
```

## Next Steps
If Grafana data visualization testing passes, proceed to:
- [Manual Test 06: End-to-End Data Flow](./06-end-to-end-data-flow.md)

## Test Report Template

```
Test Date: [YYYY-MM-DD]
Tester: [Name]
Environment: [Windows/Linux/Mac]

Results:
□ Grafana interface accessible
□ Data source connection
□ Dashboard loading
□ Real-time updates
□ Dashboard functionality
□ Visualization types
□ Query performance
□ Alerting (if configured)
□ Export/import
□ User interface

Overall Status: PASS/FAIL

Notes:
[Any observations or issues encountered]
``` 