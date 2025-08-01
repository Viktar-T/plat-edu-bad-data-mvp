# Manual Test 05: Grafana Data Visualization

## Overview
This test verifies that Grafana is properly configured, can connect to InfluxDB, and displays renewable energy monitoring data in meaningful dashboards.

**🔍 What This Test Does:**
This test checks if Grafana is working correctly as the "control room" of your IoT system. Think of Grafana as a sophisticated dashboard that takes raw data from InfluxDB and turns it into beautiful charts, graphs, and visualizations that help you understand your renewable energy system's performance.

**🏗️ Why This Matters:**
Grafana is where you actually see and interact with your monitoring data. If Grafana isn't working:
- You can't see real-time system status
- Historical trends are invisible
- Alerts and notifications don't work
- The entire monitoring system becomes useless to operators

## Technical Architecture Overview

### Grafana Architecture
Grafana is a multi-tenant, open-source analytics and visualization platform with the following architecture:

```
┌─────────────────────────────────────────────────────────────┐
│                    Grafana Architecture                     │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐         │
│  │   Web UI    │  │   API       │  │   Alerting  │         │
│  │   (Frontend)│  │   (REST)    │  │   Engine    │         │
│  │             │  │             │  │             │         │
│  └─────────────┘  └─────────────┘  └─────────────┘         │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐         │
│  │   Dashboard │  │   Query     │  │   Plugin    │         │
│  │   Engine    │  │   Engine    │  │   System    │         │
│  │             │  │             │  │             │         │
│  └─────────────┘  └─────────────┘  └─────────────┘         │
├─────────────────────────────────────────────────────────────┤
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐         │
│  │   Data      │  │   User      │  │   Security  │         │
│  │   Sources   │  │   Management│  │   & Auth    │         │
│  │             │  │             │  │             │         │
│  └─────────────┘  └─────────────┘  └─────────────┘         │
└─────────────────────────────────────────────────────────────┘
```

### Dashboard Architecture
Grafana dashboards are composed of multiple components:

**Dashboard Structure:**
- **Dashboard**: Container for multiple panels
- **Panel**: Individual visualization (chart, graph, table, etc.)
- **Query**: Data source query (Flux for InfluxDB)
- **Variables**: Dynamic parameters for dashboards
- **Annotations**: Time-based markers on charts

**Panel Types:**
- **Time Series**: Line charts for time-based data
- **Stat**: Single value displays
- **Gauge**: Circular progress indicators
- **Table**: Tabular data display
- **Heatmap**: 2D data visualization
- **Bar Chart**: Categorical data comparison

### Data Source Integration
Grafana connects to InfluxDB 2.x through the InfluxDB data source plugin:

**Connection Configuration:**
- **URL**: http://influxdb:8086 (internal Docker network)
- **Access**: Server (proxy) mode
- **Authentication**: Token-based
- **Organization**: renewable_energy_org
- **Default Bucket**: renewable_energy_data

**Query Language:**
- **Flux**: InfluxDB 2.x query language
- **Query Builder**: Visual query builder
- **Raw Query**: Direct Flux syntax
- **Template Variables**: Dynamic query parameters

### Alerting System
Grafana includes a comprehensive alerting system:

**Alert Components:**
- **Alert Rules**: Conditions that trigger alerts
- **Notification Channels**: Email, Slack, webhook, etc.
- **Alert States**: OK, Pending, Firing, Resolved
- **Silencing**: Temporarily disable alerts
- **Escalation**: Progressive notification levels

## Test Objective
Ensure Grafana is properly configured, can display data from InfluxDB, and provides meaningful visualizations for renewable energy monitoring.

**🎯 What We're Checking:**
- **Interface Access**: Can we access the Grafana web interface?
- **Data Source**: Is Grafana connected to InfluxDB?
- **Dashboard Functionality**: Do dashboards display data correctly?
- **Real-time Updates**: Does data update in real-time?
- **Performance**: How well do dashboards perform?
- **Alerting**: Do alerts work properly?

## Prerequisites
- Manual Tests 01, 02, 03, and 04 completed successfully
- Grafana accessible at http://localhost:3000
- InfluxDB running and containing data
- Node-RED sending data to InfluxDB

**📋 What These Prerequisites Mean:**
- **Tests 01-04**: All previous components are working
- **Grafana**: The visualization service must be running
- **InfluxDB**: Must contain data to visualize
- **Node-RED**: Must be sending data to InfluxDB

## Automated Testing Framework

### Quick Grafana Validation
Before running manual tests, you can use the automated testing framework for quick validation:

```powershell
# Run comprehensive Grafana testing
.\tests\scripts\test-grafana-health.ps1

# Run data flow test (includes Grafana validation)
.\tests\scripts\test-data-flow.ps1

# Run integration tests (includes Grafana connectivity)
.\tests\scripts\test-integration.ps1

# Run all tests
.\tests\run-all-tests.ps1
```

**🤖 What These Scripts Do:**
These automated scripts test Grafana functionality quickly and consistently. They verify connectivity, dashboard loading, and data visualization capabilities.

### Test Framework Features
- **Health Checks**: Service status, connectivity, authentication
- **Data Flow**: End-to-end testing from MQTT to Grafana
- **Integration**: Cross-component connectivity validation
- **Performance**: Dashboard loading and rendering performance

## Test Steps

### Step 1: Access Grafana Interface

#### 1.1 Open Grafana Dashboard
**🔍 What This Does:**
Opens the Grafana web interface where you can view and configure dashboards. This is like opening the control room of your renewable energy monitoring system.

**💡 Why This Matters:**
Grafana is your primary interface for monitoring renewable energy systems. It's where operators and engineers go to:
- **Monitor Real-time Status**: See current power generation
- **Analyze Trends**: Understand performance over time
- **Detect Problems**: Identify issues quickly
- **Generate Reports**: Create performance reports

**Action:**
1. Open web browser
2. Navigate to http://localhost:3000
3. Login with credentials (if required)

**📋 Understanding the Interface:**
- **Dashboard**: Main area showing charts and graphs
- **Sidebar**: Navigation menu and search
- **Toolbar**: Time range selector and refresh controls
- **Panels**: Individual charts and visualizations

**Expected Result:**
- Grafana interface loads successfully
- Login screen appears (if authentication enabled)
- No error messages

#### 1.2 Verify Service Health
**🔍 What This Does:**
Tests if Grafana is running and responding to health checks. This verifies that the visualization service is operational.

**Command:**
```powershell
# Check Grafana health endpoint
Invoke-WebRequest -Uri http://localhost:3000/api/health -UseBasicParsing
```

**📋 Understanding the Command:**
- `Invoke-WebRequest`: PowerShell command to make an HTTP request
- `http://localhost:3000/api/health`: The health check URL for Grafana
- `localhost:3000`: The address where Grafana runs

**Expected Result:**
- Returns HTTP 200 OK
- JSON response with "ok" status
- No error messages

### Step 2: Test Data Source Configuration

#### 2.1 Verify InfluxDB Data Source
**🔍 What This Does:**
Tests if Grafana is properly connected to InfluxDB. This is like checking if the control room has a working connection to the data warehouse.

**💡 Why This Matters:**
Without a working data source connection:
- Dashboards won't show any data
- Charts will be empty
- Alerts won't work
- The entire visualization system fails

**Action in Grafana:**
1. Go to Configuration → Data Sources
2. Check if InfluxDB data source is configured
3. Test the connection

**📋 Understanding Data Source Configuration:**
- **Name**: InfluxDB (or similar)
- **Type**: InfluxDB
- **URL**: http://influxdb:8086
- **Access**: Server (proxy)
- **Auth**: Token-based authentication
- **Organization**: renewable_energy_org
- **Default Bucket**: renewable_energy_data

**Expected Result:**
- InfluxDB data source is configured
- Connection test passes
- No authentication errors
- Data source is working

#### 2.2 Test Data Source Query
**🔍 What This Does:**
Tests if Grafana can actually query data from InfluxDB. This verifies that the connection is not just established but functional.

**Action in Grafana:**
1. Go to Explore (compass icon)
2. Select InfluxDB data source
3. Write a simple Flux query
4. Execute the query

**📋 Understanding the Query:**
```flux
from(bucket: "renewable_energy_data")
  |> range(start: -1h)
  |> filter(fn: (r) => r._measurement == "photovoltaic_data")
  |> filter(fn: (r) => r._field == "power")
```

**Expected Result:**
- Query executes successfully
- Data is returned
- No connection errors
- Results are displayed in table format

### Step 3: Test Dashboard Access

#### 3.1 Access Renewable Energy Overview Dashboard
**🔍 What This Does:**
Tests if the main renewable energy monitoring dashboard is accessible and displays data. This is the primary dashboard for system overview.

**💡 Why This Matters:**
The overview dashboard provides:
- **System Status**: Overall health of all devices
- **Power Generation**: Total power output from all sources
- **Key Metrics**: Important performance indicators
- **Quick Alerts**: Immediate problem identification

**Action in Grafana:**
1. Go to Dashboards → Browse
2. Find "Renewable Energy Overview" dashboard
3. Open the dashboard
4. Check if panels display data

**📋 Understanding Dashboard Panels:**
- **Total Power Output**: Sum of all device power
- **Device Status**: Online/offline status of devices
- **Power Generation Chart**: Time series of power output
- **Efficiency Metrics**: Performance indicators
- **Alert Summary**: Current alerts and warnings

**Expected Result:**
- Dashboard loads successfully
- Panels display data
- No error messages
- Charts are populated with data

#### 3.2 Access Device-Specific Dashboards
**🔍 What This Does:**
Tests if individual device dashboards are working. These provide detailed views of specific device types.

**Action in Grafana:**
1. Access Photovoltaic Monitoring dashboard
2. Access Wind Turbine Analytics dashboard
3. Access Energy Storage Monitoring dashboard
4. Check if each dashboard shows relevant data

**📋 Understanding Device Dashboards:**
- **Photovoltaic**: Solar panel power, voltage, current, efficiency
- **Wind Turbine**: Wind speed, power output, RPM, direction
- **Energy Storage**: Battery SOC, voltage, charge/discharge power

**Expected Result:**
- All device dashboards load
- Data is specific to device type
- Charts show relevant metrics
- No cross-contamination of data

### Step 4: Test Data Visualization

#### 4.1 Test Time Series Charts
**🔍 What This Does:**
Tests line charts that show how values change over time. This is like watching a heart rate monitor - you can see trends and patterns.

**💡 Why This Matters:**
Time series charts are essential for renewable energy monitoring because they show:
- **Power Generation Trends**: How much energy you're producing over time
- **Performance Patterns**: Daily, weekly, seasonal variations
- **Problem Detection**: Sudden drops or spikes in performance
- **Optimization Opportunities**: When systems are most/least efficient

**Action in Grafana:**
1. Look for time series charts in dashboards
2. Check if data points are plotted correctly
3. Verify time axis shows correct ranges
4. Test zoom and pan functionality

**📋 Understanding Time Series Charts:**
- **X-Axis**: Time (hours, days, weeks)
- **Y-Axis**: Values (power, voltage, temperature)
- **Data Points**: Individual measurements over time
- **Trends**: Lines showing patterns and changes

**Expected Result:**
- Charts display time series data
- Time axis is correct
- Data points are plotted accurately
- Zoom and pan work properly

#### 4.2 Test Gauge and Stat Panels
**🔍 What This Does:**
Tests single-value displays that show current status and key metrics. These are like dashboard gauges in a car.

**💡 Why This Matters:**
Gauge and stat panels provide:
- **Current Status**: Real-time values at a glance
- **Quick Assessment**: Immediate understanding of system state
- **Threshold Monitoring**: Visual indication of normal/abnormal values
- **Performance Metrics**: Key performance indicators

**Action in Grafana:**
1. Look for gauge panels showing current values
2. Check stat panels for key metrics
3. Verify values are current and accurate
4. Test color coding (green/yellow/red)

**📋 Understanding Gauge/Stat Panels:**
- **Current Power**: Real-time power generation
- **System Efficiency**: Overall system performance
- **Battery SOC**: State of charge percentage
- **Device Status**: Online/offline indicators

**Expected Result:**
- Panels show current values
- Values are accurate and up-to-date
- Color coding works correctly
- No stale or incorrect data

#### 4.3 Test Table Panels
**🔍 What This Does:**
Tests tabular data displays that show detailed information in a structured format. These are like spreadsheets of your data.

**💡 Why This Matters:**
Table panels provide:
- **Detailed Data**: Comprehensive information in organized format
- **Data Comparison**: Side-by-side comparison of values
- **Historical Records**: Past measurements and trends
- **Export Capability**: Data for further analysis

**Action in Grafana:**
1. Look for table panels in dashboards
2. Check if data is properly formatted
3. Verify column headers are correct
4. Test sorting and filtering

**Expected Result:**
- Tables display data correctly
- Column headers are accurate
- Data is properly formatted
- Sorting works correctly

### Step 5: Test Real-time Data Updates

#### 5.1 Test Live Data Updates
**🔍 What This Does:**
Tests if dashboards update automatically as new data arrives. This ensures you're seeing real-time information.

**💡 Why This Matters:**
Real-time updates are crucial for:
- **Live Monitoring**: See current system status
- **Immediate Problem Detection**: Catch issues as they happen
- **Operational Decisions**: Make decisions based on current data
- **Alert Response**: Respond to alerts quickly

**Action:**
1. Open a dashboard with real-time data
2. Send new data through the system (MQTT → Node-RED → InfluxDB)
3. Watch for dashboard updates
4. Check refresh intervals

**📋 Understanding Real-time Updates:**
- **Auto-refresh**: Dashboards update automatically
- **Refresh Intervals**: How often data is updated (5s, 10s, 30s, etc.)
- **Live Data**: Current values from devices
- **Historical Context**: Recent data for trend analysis

**Expected Result:**
- Dashboards update automatically
- New data appears within refresh interval
- No manual refresh required
- Updates are smooth and consistent

#### 5.2 Test Time Range Selection
**🔍 What This Does:**
Tests if you can change the time range to view different periods of data. This is like zooming in and out on a timeline.

**💡 Why This Matters:**
Time range selection allows:
- **Historical Analysis**: View data from past periods
- **Trend Analysis**: Compare different time periods
- **Problem Investigation**: Look at data around specific events
- **Performance Comparison**: Compare current vs. historical performance

**Action in Grafana:**
1. Use time range selector in dashboard
2. Try different time ranges (Last 1 hour, Last 6 hours, Last 24 hours, etc.)
3. Check if data updates accordingly
4. Test custom time ranges

**Expected Result:**
- Time range selector works
- Data updates for different ranges
- Custom ranges function properly
- No errors when changing ranges

### Step 6: Test Dashboard Performance

#### 6.1 Test Dashboard Loading Speed
**🔍 What This Does:**
Tests how quickly dashboards load and display data. This is important for user experience and operational efficiency.

**💡 Why This Matters:**
Fast dashboard loading is essential for:
- **Operational Efficiency**: Quick access to information
- **User Experience**: Responsive interface
- **Emergency Response**: Fast access during problems
- **System Reliability**: Consistent performance

**Action:**
1. Measure dashboard load time
2. Check panel rendering speed
3. Test with different data volumes
4. Monitor resource usage

**📋 Understanding Performance Metrics:**
- **Load Time**: Time to display dashboard
- **Query Time**: Time for data source queries
- **Render Time**: Time to draw charts
- **Resource Usage**: CPU and memory consumption

**Expected Result:**
- Dashboards load within 5 seconds
- Panels render quickly
- Performance is consistent
- No timeout errors

#### 6.2 Test Concurrent User Access
**🔍 What This Does:**
Tests if multiple users can access dashboards simultaneously. This simulates real-world usage scenarios.

**💡 Why This Matters:**
In real operations:
- **Multiple Operators**: Several people monitor the system
- **Different Roles**: Engineers, operators, managers
- **Simultaneous Access**: Multiple users at the same time
- **System Stability**: Must handle concurrent load

**Action:**
1. Open dashboard in multiple browser tabs
2. Access different dashboards simultaneously
3. Check for performance degradation
4. Monitor system resources

**Expected Result:**
- Multiple sessions work correctly
- No performance degradation
- System remains stable
- No conflicts between users

### Step 7: Test Alerting and Notifications

#### 7.1 Test Alert Rules
**🔍 What This Does:**
Tests if Grafana can detect when values exceed thresholds and trigger alerts. This is like having a smart alarm system.

**💡 Why This Matters:**
Alerting is crucial for:
- **Problem Detection**: Automatic identification of issues
- **Immediate Response**: Quick action when problems occur
- **Preventive Maintenance**: Catch issues before they become serious
- **System Reliability**: Maintain optimal performance

**Action in Grafana:**
1. Go to Alerting → Alert Rules
2. Check if alert rules are configured
3. Test alert conditions
4. Verify alert states

**📋 Understanding Alert Rules:**
- **Thresholds**: Values that trigger alerts
- **Conditions**: Logic for when alerts fire
- **Evaluation**: How often rules are checked
- **States**: OK, Pending, Firing, Resolved

**Expected Result:**
- Alert rules are configured
- Rules evaluate correctly
- Alert states update properly
- No false positives/negatives

#### 7.2 Test Notification Channels
**🔍 What This Does:**
Tests if alerts can be sent to different notification channels (email, Slack, etc.). This ensures alerts reach the right people.

**Action in Grafana:**
1. Go to Alerting → Notification Channels
2. Check configured channels
3. Test notification delivery
4. Verify message content

**Expected Result:**
- Notification channels are configured
- Alerts are delivered successfully
- Message content is correct
- No delivery failures

### Step 8: Test User Interface and Navigation

#### 8.1 Test Dashboard Navigation
**🔍 What This Does:**
Tests if users can navigate between different dashboards and panels easily. This ensures good user experience.

**Action in Grafana:**
1. Navigate between different dashboards
2. Use dashboard search functionality
3. Test panel linking
4. Check breadcrumb navigation

**Expected Result:**
- Navigation works smoothly
- Search finds dashboards
- Panel links function correctly
- Breadcrumbs are accurate

#### 8.2 Test Dashboard Sharing
**🔍 What This Does:**
Tests if dashboards can be shared with other users or exported. This is important for collaboration and reporting.

**Action in Grafana:**
1. Test dashboard sharing options
2. Export dashboard as JSON
3. Test snapshot functionality
4. Check sharing permissions

**Expected Result:**
- Sharing options work
- Exports are successful
- Snapshots function properly
- Permissions are enforced

## Advanced Technical Testing

### Dashboard Performance Analysis
Analyze dashboard performance and identify bottlenecks:

```javascript
// Performance monitoring for dashboard panels
const panelLoadTime = performance.now();
// Panel rendering logic
const renderTime = performance.now() - panelLoadTime;
console.log(`Panel render time: ${renderTime}ms`);
```

### Query Optimization Testing
Test and optimize Flux queries for better dashboard performance:

```flux
// Optimized query for dashboard panels
from(bucket: "renewable_energy_data")
  |> range(start: -1h)
  |> filter(fn: (r) => r._measurement == "photovoltaic_data")
  |> filter(fn: (r) => r._field == "power")
  |> aggregateWindow(every: 1m, fn: mean)
  |> yield(name: "power_avg")
```

### Alert Rule Testing
Test comprehensive alert scenarios:

```yaml
# Example alert rule configuration
alert: High Power Output
expr: avg_over_time(power_output[5m]) > 10000
for: 2m
labels:
  severity: warning
annotations:
  summary: "High power output detected"
  description: "Power output is {{ $value }}W"
```

### Dashboard Template Testing
Test dashboard templates and variables:

```json
{
  "templating": {
    "list": [
      {
        "name": "device_id",
        "type": "query",
        "query": "label_values(device_id)",
        "refresh": 2
      }
    ]
  }
}
```

## Professional Best Practices

### Dashboard Design Best Practices
- **Information Hierarchy**: Organize information by importance
- **Visual Consistency**: Use consistent colors, fonts, and layouts
- **Responsive Design**: Ensure dashboards work on different screen sizes
- **Performance Optimization**: Optimize queries and panel configurations
- **User Experience**: Design for ease of use and quick comprehension

### Data Visualization Best Practices
- **Chart Selection**: Choose appropriate chart types for data
- **Color Usage**: Use colors meaningfully and accessibly
- **Data Density**: Balance information density with readability
- **Context**: Provide context for data interpretation
- **Interactivity**: Enable user interaction where appropriate

### Performance Optimization
- **Query Optimization**: Write efficient Flux queries
- **Panel Limits**: Limit number of panels per dashboard
- **Refresh Intervals**: Set appropriate refresh rates
- **Caching**: Use query caching where possible
- **Resource Monitoring**: Monitor Grafana resource usage

### Security Best Practices
- **Authentication**: Implement proper user authentication
- **Authorization**: Use role-based access control
- **Data Source Security**: Secure data source connections
- **Dashboard Permissions**: Control dashboard access
- **Audit Logging**: Log user actions and access

### Monitoring and Alerting
- **Dashboard Monitoring**: Monitor dashboard performance
- **Alert Management**: Manage alert rules and notifications
- **User Activity**: Track user engagement and usage
- **System Health**: Monitor Grafana system health
- **Capacity Planning**: Plan for growth and scaling

## Test Results Documentation

### Pass Criteria
- Grafana interface is accessible
- Data source connection is working
- Dashboards load and display data
- Real-time updates function properly
- Performance is acceptable
- Alerting system works correctly
- User interface is functional

### Fail Criteria
- Grafana interface not accessible
- Data source connection failures
- Dashboard loading issues
- Real-time updates not working
- Performance problems
- Alerting system failures
- User interface issues

## Troubleshooting

### Common Issues

#### 1. Grafana Interface Not Accessible
**Problem:** Can't access http://localhost:3000
**🔍 What This Means:** Grafana service might not be running or there's a network issue.

**Solution:**
```powershell
# Check Grafana container status
docker-compose ps grafana

# Check Grafana logs
docker-compose logs grafana

# Restart Grafana
docker-compose restart grafana
```

#### 2. Data Source Connection Issues
**Problem:** Grafana can't connect to InfluxDB
**🔍 What This Means:** There might be network or authentication issues.

**Solution:**
```powershell
# Check InfluxDB connectivity
Invoke-WebRequest -Uri http://localhost:8086/health -UseBasicParsing

# Check Docker network
docker network ls
docker network inspect plat-edu-bad-data-mvp_iot-network
```

#### 3. Dashboard Not Loading Data
**Problem:** Dashboards load but show no data
**🔍 What This Means:** There might be query issues or no data in InfluxDB.

**Solution:**
1. Check if InfluxDB contains data
2. Verify Flux queries are correct
3. Check data source configuration
4. Test queries in Explore mode

#### 4. Performance Issues
**Problem:** Dashboards load slowly or timeout
**🔍 What This Means:** There might be query performance issues or resource constraints.

**Solution:**
```powershell
# Check system resources
docker stats

# Optimize Flux queries
# Reduce refresh intervals
# Limit number of panels
```

#### 5. Alerting Issues
**Problem:** Alerts not firing or notifications not sent
**🔍 What This Means:** Alert rules or notification channels might be misconfigured.

**Solution:**
1. Check alert rule configuration
2. Verify notification channels
3. Test alert evaluation
4. Check alert logs

## Next Steps
If all Grafana tests pass, proceed to:
- [Manual Test 06: End-to-End Data Flow](./06-end-to-end-data-flow.md)

## Test Report Template

```
Test Date: [YYYY-MM-DD]
Tester: [Name]
Environment: [Windows/Linux/Mac]

Results:
□ Grafana interface accessible
□ Data source connection working
□ Dashboards load and display data
□ Real-time updates functional
□ Performance acceptable
□ Alerting system working
□ User interface functional

Overall Status: PASS/FAIL

Notes:
[Any observations or issues encountered]
``` 