# Grafana/InfluxDB Queries for Renewable Energy Monitoring System

## Overview
This document contains useful queries for testing, debugging, and monitoring the renewable energy IoT system using Grafana and InfluxDB 2.x.

## Table of Contents

### [How to Build Flux Queries](#how-to-build-flux-queries)
- [Understanding Flux Query Structure](#understanding-flux-query-structure)
- [Key Components Explained](#key-components-explained)
  - [Data Source (`from()`)](#1-data-source-from)
  - [Time Range (`range()`)](#2-time-range-range)
  - [Filtering (`filter()`)](#3-filtering-filter)
  - [Grouping (`group()`)](#4-grouping-group)
  - [Aggregation (`aggregateWindow()`)](#5-aggregation-aggregatewindow)
  - [Data Selection (`limit()`, `distinct()`)](#6-data-selection-limit-distinct)
- [Understanding Your Data Structure](#understanding-your-data-structure)
  - [Measurements (Device Types)](#measurements-device-types)
  - [Fields (Data Points)](#fields-data-points)
  - [Tags (Metadata)](#tags-metadata)
- [Building Your Own Queries](#building-your-own-queries)
  - [Step-by-Step Process](#step-by-step-process)
  - [Common Query Patterns](#common-query-patterns)
- [Tips for Effective Queries](#tips-for-effective-queries)
- [Common Mistakes to Avoid](#common-mistakes-to-avoid)
- [Testing Your Queries](#testing-your-queries)

### [Basic Data Exploration Queries](#basic-data-exploration-queries)
- [1. List All Measurements (Device Types)](#1-list-all-measurements-device-types)
- [1a. Check All Available Tags](#1a-check-all-available-tags)
- [1a. Alternative: Check All Available Tags (Simplified)](#1a-alternative-check-all-available-tags-simplified)
- [1a. Alternative: Check Tags by Looking at Sample Data](#1a-alternative-check-tags-by-looking-at-sample-data)
- [1b. Check Sample Data Structure](#1b-check-sample-data-structure)
- [2. List All Fields in a Measurement](#2-list-all-fields-in-a-measurement)
- [3. List All Device Types (by Measurement)](#3-list-all-device-types-by-measurement)
- [4. List All Device IDs](#4-list-all-device-ids)

### [Data Verification Queries](#data-verification-queries)
- [5. Check Recent Data (Last 10 Records)](#5-check-recent-data-last-10-records)
- [6. Check Data Count by Measurement](#6-check-data-count-by-measurement)
- [7. Check Data Count by Device Type (Measurement)](#7-check-data-count-by-device-type-measurement)

### [Photovoltaic System Queries](#photovoltaic-system-queries)
- [8. Photovoltaic Power Output (Last Hour)](#8-photovoltaic-power-output-last-hour)
- [9. Photovoltaic Efficiency](#9-photovoltaic-efficiency)
- [10. Photovoltaic Temperature](#10-photovoltaic-temperature)
- [11. Photovoltaic Irradiance](#11-photovoltaic-irradiance)

### [Wind Turbine Queries](#wind-turbine-queries)
- [12. Wind Turbine Power Output](#12-wind-turbine-power-output)
- [13. Wind Speed](#13-wind-speed)
- [14. Wind Turbine RPM](#14-wind-turbine-rpm)

### [Biogas Plant Queries](#biogas-plant-queries)
- [15. Biogas Plant Power Output](#15-biogas-plant-power-output)
- [16. Gas Flow Rate](#16-gas-flow-rate)
- [17. Methane Concentration](#17-methane-concentration)

### [Energy Storage Queries](#energy-storage-queries)
- [18. Battery State of Charge](#18-battery-state-of-charge)
- [19. Battery Voltage](#19-battery-voltage)
- [20. Battery Temperature](#20-battery-temperature)

### [Heat Boiler Queries](#heat-boiler-queries)
- [21. Heat Boiler Power Output](#21-heat-boiler-power-output)
- [22. Boiler Temperature](#22-boiler-temperature)
- [23. Boiler Efficiency](#23-boiler-efficiency)

### [System Overview Queries](#system-overview-queries)
- [24. Total Power Generation (All Devices)](#24-total-power-generation-all-devices)
- [25. Power Generation by Device Type (Measurement)](#25-power-generation-by-device-type-measurement)
- [26. Active Devices Count](#26-active-devices-count)
- [27. Device Status Summary](#27-device-status-summary)

### [Fault Detection Queries](#fault-detection-queries)
- [28. Faulty Devices](#28-faulty-devices)
- [29. Low Efficiency Devices](#29-low-efficiency-devices)
- [30. High Temperature Alerts](#30-high-temperature-alerts)

### [Performance Monitoring Queries](#performance-monitoring-queries)
- [31. Data Points per Minute](#31-data-points-per-minute)
- [32. Data Points by Measurement](#32-data-points-by-measurement)
- [33. Latest Values for All Devices](#33-latest-values-for-all-devices)

### [Time Range Variations](#time-range-variations)
- [34. Last 24 Hours](#34-last-24-hours)
- [35. Last 7 Days](#35-last-7-days)
- [36. Last 30 Days](#36-last-30-days)

### [Debugging Queries](#debugging-queries)
- [37. Check for Missing Data](#37-check-for-missing-data)
- [38. Data Quality Check](#38-data-quality-check)
- [39. Device Communication Status](#39-device-communication-status)

### [Usage Instructions](#usage-instructions)
### [Notes](#notes)

## How to Build Flux Queries

### Understanding Flux Query Structure
Flux is InfluxDB 2.x's query language. Every Flux query follows this basic pattern:

```flux
from(bucket: "bucket_name")
  |> range(start: -1h)
  |> filter(fn: (r) => r._field == "field_name")
  |> aggregateWindow(every: 1m, fn: mean, createEmpty: false)
```

### Key Components Explained

#### 1. **Data Source** (`from()`)
```flux
from(bucket: "renewable_energy")
```
- **Purpose**: Specifies which bucket to query
- **Your bucket**: `renewable_energy`
- **Alternative**: You can also use `from(bucket: "bucket_name", measurement: "measurement_name")`

#### 2. **Time Range** (`range()`)
```flux
|> range(start: -1h)    // Last hour
|> range(start: -24h)   // Last 24 hours
|> range(start: -7d)    // Last 7 days
|> range(start: -30d)   // Last 30 days
```
- **Purpose**: Defines the time window for your query
- **Common ranges**: `-5m`, `-1h`, `-24h`, `-7d`, `-30d`
- **Note**: Use longer ranges for historical analysis, shorter for real-time monitoring

#### 3. **Filtering** (`filter()`)
```flux
// Filter by measurement (device type)
|> filter(fn: (r) => r._measurement == "photovoltaic_data")

// Filter by field (data point)
|> filter(fn: (r) => r._field == "power_output")

// Filter by tag
|> filter(fn: (r) => r.device_id == "pv_001")

// Multiple conditions
|> filter(fn: (r) => r._field == "power_output" and r._value > 1000)
```
- **Purpose**: Selects specific data based on conditions
- **Common filters**: `_measurement`, `_field`, `device_id`, `location`
- **Operators**: `==`, `!=`, `>`, `<`, `>=`, `<=`, `and`, `or`

#### 4. **Grouping** (`group()`)
```flux
// Group by measurement (device type)
|> group(columns: ["_measurement"])

// Group by multiple columns
|> group(columns: ["_measurement", "device_id"])

// Group by field
|> group(columns: ["_field"])
```
- **Purpose**: Groups data for aggregation or analysis
- **Common groupings**: `_measurement`, `device_id`, `_field`
- **Note**: Grouping affects how aggregations work

#### 5. **Aggregation** (`aggregateWindow()`)
```flux
// Average over time windows
|> aggregateWindow(every: 1m, fn: mean, createEmpty: false)

// Sum over time windows
|> aggregateWindow(every: 5m, fn: sum, createEmpty: false)

// Count data points
|> aggregateWindow(every: 1m, fn: count, createEmpty: false)
```
- **Purpose**: Combines data points over time periods
- **Common functions**: `mean`, `sum`, `count`, `min`, `max`
- **Time windows**: `1m`, `5m`, `1h`, `6h`, `1d`
- **createEmpty**: `false` = skip empty windows, `true` = include empty windows

#### 6. **Data Selection** (`limit()`, `distinct()`)
```flux
// Limit number of results
|> limit(n: 10)

// Get unique values
|> distinct(column: "_measurement")

// Get last value
|> last()
```
- **Purpose**: Controls output format and quantity
- **Common uses**: Limiting results, getting unique values, finding latest data

### Understanding Your Data Structure

#### **Measurements** (Device Types)
Your data uses measurements to represent device types:
- `photovoltaic_data` = Solar panels
- `wind_turbine_data` = Wind turbines  
- `biogas_plant_data` = Biogas plants
- `energy_storage_data` = Batteries
- `heat_boiler_data` = Heat boilers

#### **Fields** (Data Points)
Each measurement contains multiple fields:
- `power_output` = Power generation in watts
- `temperature` = Temperature in Celsius
- `efficiency` = Efficiency percentage
- `voltage` = Voltage in volts
- `current` = Current in amperes

#### **Tags** (Metadata)
Your data includes these tags:
- `device_id` = Individual device identifier
- `location` = Device location
- `status` = Device status (operational, fault, etc.)

### Building Your Own Queries

#### **Step-by-Step Process**

1. **Start with data source**:
   ```flux
   from(bucket: "renewable_energy")
   ```

2. **Add time range**:
   ```flux
   |> range(start: -1h)
   ```

3. **Filter by device type** (if needed):
   ```flux
   |> filter(fn: (r) => r._measurement == "photovoltaic_data")
   ```

4. **Filter by data point** (if needed):
   ```flux
   |> filter(fn: (r) => r._field == "power_output")
   ```

5. **Group for analysis** (if needed):
   ```flux
   |> group(columns: ["_measurement"])
   ```

6. **Aggregate over time** (if needed):
   ```flux
   |> aggregateWindow(every: 1m, fn: mean, createEmpty: false)
   ```

#### **Common Query Patterns**

**Pattern 1: Simple Data Retrieval**
```flux
from(bucket: "renewable_energy")
  |> range(start: -1h)
  |> filter(fn: (r) => r._measurement == "photovoltaic_data")
```

**Pattern 2: Time-Series Aggregation**
```flux
from(bucket: "renewable_energy")
  |> range(start: -24h)
  |> filter(fn: (r) => r._field == "power_output")
  |> aggregateWindow(every: 5m, fn: sum, createEmpty: false)
```

**Pattern 3: Device Comparison**
```flux
from(bucket: "renewable_energy")
  |> range(start: -1h)
  |> filter(fn: (r) => r._field == "power_output")
  |> group(columns: ["_measurement"])
  |> aggregateWindow(every: 1m, fn: sum, createEmpty: false)
```

**Pattern 4: Fault Detection**
```flux
from(bucket: "renewable_energy")
  |> range(start: -1h)
  |> filter(fn: (r) => r._field == "efficiency")
  |> filter(fn: (r) => r._value < 70)
```

### Tips for Effective Queries

1. **Start Simple**: Begin with basic queries and add complexity gradually
2. **Use Appropriate Time Ranges**: 
   - Real-time monitoring: `-5m` to `-1h`
   - Daily analysis: `-24h`
   - Weekly trends: `-7d`
   - Monthly analysis: `-30d`
3. **Test with Small Data Sets**: Use `limit(n: 5)` to test queries
4. **Use Meaningful Aggregations**: 
   - `mean` for averages
   - `sum` for totals
   - `count` for data volume
   - `min`/`max` for extremes
5. **Group Appropriately**: Group by device type (`_measurement`) or device ID as needed
6. **Handle Missing Data**: Use `createEmpty: false` to skip empty time windows

### Common Mistakes to Avoid

1. **Wrong Time Range**: Using `-1h` when you need `-24h`
2. **Missing Filters**: Not filtering by specific measurements or fields
3. **Incorrect Grouping**: Grouping by non-existent tags
4. **Over-Aggregation**: Using too large time windows for detailed analysis
5. **Ignoring Data Structure**: Not understanding that device types are in `_measurement`

### Testing Your Queries

1. **Start in Grafana Explore**: Use the Explore feature to test queries
2. **Check Data Availability**: Use Query #1 to see what measurements exist
3. **Verify Time Ranges**: Ensure your time range includes data
4. **Test Incrementally**: Add filters and aggregations one at a time
5. **Use Sample Data**: Start with `limit(n: 5)` to see raw data structure

## Basic Data Exploration Queries

### 1. List All Measurements (Device Types)
**Purpose**: Shows all measurement names in your bucket for the last 24 hours. Use this to see what types of data are being collected.
**When to use**: Start here to understand what data is available in your system.
**Expected result**: A list of measurement names like `photovoltaic_data`, `wind_turbine_data`, etc.

```flux
from(bucket: "renewable_energy")
  |> range(start: -24h)
  |> group(columns: ["_measurement"])
  |> distinct(column: "_measurement")
```

### 1a. Check All Available Tags
**Purpose**: Shows all tag keys available in your data. Use this to see what tags are actually being used.
**When to use**: When you need to understand the data structure and available tags.
**Expected result**: A list of tag keys like `device_id`, `location`, etc.

```flux
from(bucket: "renewable_energy")
  |> range(start: -24h)
  |> keys()
```

### 1a. Alternative: Check All Available Tags (Simplified)
**Purpose**: Alternative way to check available tags using a simpler approach.
**When to use**: If the above query doesn't work, try this simpler version.
**Expected result**: A list of tag keys available in your data.

```flux
from(bucket: "renewable_energy")
  |> range(start: -24h)
  |> keys()
```

### 1a. Alternative: Check Tags by Looking at Sample Data
**Purpose**: Shows sample data with all available tags to understand the structure.
**When to use**: To see exactly what tags are present in your data.
**Expected result**: Sample records showing all available tags.

```flux
from(bucket: "renewable_energy")
  |> range(start: -24h)
  |> limit(n: 3)
```

### 1b. Check Sample Data Structure
**Purpose**: Shows a few sample records with all their tags and fields. Use this to understand the actual data structure.
**When to use**: To see exactly how your data is structured and what tags/fields exist.
**Expected result**: Sample records showing all available tags and fields.

```flux
from(bucket: "renewable_energy")
  |> range(start: -24h)
  |> limit(n: 5)
```

### 2. List All Fields in a Measurement
**Purpose**: Shows all field names (data points) available in a specific measurement. Use this to see what sensors/values are being recorded.
**When to use**: After finding a measurement, use this to see what data fields are available.
**Expected result**: A list of field names like `power_output`, `temperature`, `efficiency`, etc.

```flux
from(bucket: "renewable_energy")
  |> range(start: -24h)
  |> filter(fn: (r) => r._measurement == "photovoltaic_data")
  |> group(columns: ["_field"])
  |> distinct(column: "_field")
```

### 3. List All Device Types (by Measurement)
**Purpose**: Shows all device types in your system by measurement names. Use this to see what categories of renewable energy devices are being monitored.
**When to use**: To understand the scope of your monitoring system.
**Expected result**: A list of device types like `photovoltaic_data`, `wind_turbine_data`, `biogas_plant_data`, etc.

```flux
from(bucket: "renewable_energy")
  |> range(start: -24h)
  |> group(columns: ["_measurement"])
  |> distinct(column: "_measurement")
```

### 4. List All Device IDs
**Purpose**: Shows all individual device IDs in your system. Use this to see how many specific devices are being monitored.
**When to use**: To understand the scale of your monitoring system and identify specific devices.
**Expected result**: A list of device IDs like `pv_001`, `wt_001`, `bg_001`, etc.

```flux
from(bucket: "renewable_energy")
  |> range(start: -24h)
  |> group(columns: ["device_id"])
  |> distinct(column: "device_id")
```

## Data Verification Queries

### 5. Check Recent Data (Last 10 Records)
**Purpose**: Shows the 10 most recent data points from all measurements. Use this to verify that data is being written and see the actual values.
**When to use**: To quickly verify that your system is generating and storing data.
**Expected result**: 10 rows showing recent timestamp, measurement, field, and value data.

```flux
from(bucket: "renewable_energy")
  |> range(start: -1h)
  |> limit(n: 10)
```

### 6. Check Data Count by Measurement
**Purpose**: Shows how many data points each measurement has received in the last hour. Use this to verify data flow and identify any missing data.
**When to use**: To check if all device types are generating data consistently.
**Expected result**: A count for each measurement showing data volume.

```flux
from(bucket: "renewable_energy")
  |> range(start: -1h)
  |> group(columns: ["_measurement"])
  |> count()
```

### 7. Check Data Count by Device Type (Measurement)
**Purpose**: Shows how many data points each device type has generated in the last hour. Use this to verify that all device categories are working.
**When to use**: To check if all renewable energy device types are generating data.
**Expected result**: A count for each device type showing data volume.

```flux
from(bucket: "renewable_energy")
  |> range(start: -1h)
  |> group(columns: ["_measurement"])
  |> count()
```

## Photovoltaic System Queries

### 8. Photovoltaic Power Output (Last Hour)
**Purpose**: Shows the average power output from all photovoltaic panels over the last hour, aggregated by minute. Use this to monitor solar energy generation.
**When to use**: To track solar power production and identify peak generation periods.
**Expected result**: Time series data showing power output in watts over time.

```flux
from(bucket: "renewable_energy")
  |> range(start: -1h)
  |> filter(fn: (r) => r._measurement == "photovoltaic_data")
  |> filter(fn: (r) => r._field == "power_output")
  |> aggregateWindow(every: 1m, fn: mean, createEmpty: false)
```

### 9. Photovoltaic Efficiency
**Purpose**: Shows the average efficiency of photovoltaic panels over the last hour. Use this to monitor how well solar panels are converting sunlight to electricity.
**When to use**: To track panel performance and identify when efficiency drops.
**Expected result**: Time series data showing efficiency percentage over time.

```flux
from(bucket: "renewable_energy")
  |> range(start: -1h)
  |> filter(fn: (r) => r._measurement == "photovoltaic_data")
  |> filter(fn: (r) => r._field == "efficiency")
  |> aggregateWindow(every: 1m, fn: mean, createEmpty: false)
```

### 10. Photovoltaic Temperature
**Purpose**: Shows the average temperature of photovoltaic panels over the last hour. Use this to monitor thermal performance and detect overheating.
**When to use**: To track panel temperature and identify thermal issues that affect efficiency.
**Expected result**: Time series data showing temperature in Celsius over time.

```flux
from(bucket: "renewable_energy")
  |> range(start: -1h)
  |> filter(fn: (r) => r._measurement == "photovoltaic_data")
  |> filter(fn: (r) => r._field == "temperature")
  |> aggregateWindow(every: 1m, fn: mean, createEmpty: false)
```

### 11. Photovoltaic Irradiance
**Purpose**: Shows the average solar irradiance (sunlight intensity) over the last hour. Use this to monitor available solar energy and correlate with power output.
**When to use**: To track solar resource availability and understand power generation patterns.
**Expected result**: Time series data showing irradiance in W/m² over time.

```flux
from(bucket: "renewable_energy")
  |> range(start: -1h)
  |> filter(fn: (r) => r._measurement == "photovoltaic_data")
  |> filter(fn: (r) => r._field == "irradiance")
  |> aggregateWindow(every: 1m, fn: mean, createEmpty: false)
```

## Wind Turbine Queries

### 12. Wind Turbine Power Output
**Purpose**: Shows the average power output from all wind turbines over the last hour. Use this to monitor wind energy generation.
**When to use**: To track wind power production and identify optimal wind conditions.
**Expected result**: Time series data showing power output in watts over time.

```flux
from(bucket: "renewable_energy")
  |> range(start: -1h)
  |> filter(fn: (r) => r._measurement == "wind_turbine_data")
  |> filter(fn: (r) => r._field == "power_output")
  |> aggregateWindow(every: 1m, fn: mean, createEmpty: false)
```

### 13. Wind Speed
**Purpose**: Shows the average wind speed over the last hour. Use this to monitor wind conditions and correlate with turbine performance.
**When to use**: To track wind resource availability and understand power generation patterns.
**Expected result**: Time series data showing wind speed in m/s over time.

```flux
from(bucket: "renewable_energy")
  |> range(start: -1h)
  |> filter(fn: (r) => r._measurement == "wind_turbine_data")
  |> filter(fn: (r) => r._field == "wind_speed")
  |> aggregateWindow(every: 1m, fn: mean, createEmpty: false)
```

### 14. Wind Turbine RPM
**Purpose**: Shows the average rotational speed of wind turbines over the last hour. Use this to monitor turbine operation and mechanical performance.
**When to use**: To track turbine operation and identify mechanical issues.
**Expected result**: Time series data showing RPM over time.

```flux
from(bucket: "renewable_energy")
  |> range(start: -1h)
  |> filter(fn: (r) => r._measurement == "wind_turbine_data")
  |> filter(fn: (r) => r._field == "rpm")
  |> aggregateWindow(every: 1m, fn: mean, createEmpty: false)
```

## Biogas Plant Queries

### 15. Biogas Plant Power Output
**Purpose**: Shows the average power output from biogas plants over the last hour. Use this to monitor biogas energy generation.
**When to use**: To track biogas power production and ensure consistent operation.
**Expected result**: Time series data showing power output in watts over time.

```flux
from(bucket: "renewable_energy")
  |> range(start: -1h)
  |> filter(fn: (r) => r._measurement == "biogas_plant_data")
  |> filter(fn: (r) => r._field == "power_output")
  |> aggregateWindow(every: 1m, fn: mean, createEmpty: false)
```

### 16. Gas Flow Rate
**Purpose**: Shows the average gas flow rate in biogas plants over the last hour. Use this to monitor gas production and system efficiency.
**When to use**: To track biogas production and identify flow rate issues.
**Expected result**: Time series data showing gas flow rate in m³/h over time.

```flux
from(bucket: "renewable_energy")
  |> range(start: -1h)
  |> filter(fn: (r) => r._measurement == "biogas_plant_data")
  |> filter(fn: (r) => r._field == "gas_flow_rate")
  |> aggregateWindow(every: 1m, fn: mean, createEmpty: false)
```

### 17. Methane Concentration
**Purpose**: Shows the average methane concentration in biogas over the last hour. Use this to monitor gas quality and energy content.
**When to use**: To track biogas quality and ensure optimal methane content for power generation.
**Expected result**: Time series data showing methane concentration percentage over time.

```flux
from(bucket: "renewable_energy")
  |> range(start: -1h)
  |> filter(fn: (r) => r._measurement == "biogas_plant_data")
  |> filter(fn: (r) => r._field == "methane_concentration")
  |> aggregateWindow(every: 1m, fn: mean, createEmpty: false)
```

## Energy Storage Queries

### 18. Battery State of Charge
**Purpose**: Shows the average battery state of charge over the last hour. Use this to monitor energy storage levels and battery health.
**When to use**: To track battery capacity and plan charging/discharging cycles.
**Expected result**: Time series data showing state of charge percentage over time.

```flux
from(bucket: "renewable_energy")
  |> range(start: -1h)
  |> filter(fn: (r) => r._measurement == "energy_storage_data")
  |> filter(fn: (r) => r._field == "state_of_charge")
  |> aggregateWindow(every: 1m, fn: mean, createEmpty: false)
```

### 19. Battery Voltage
**Purpose**: Shows the average battery voltage over the last hour. Use this to monitor electrical performance and detect voltage issues.
**When to use**: To track battery electrical performance and identify voltage problems.
**Expected result**: Time series data showing voltage in volts over time.

```flux
from(bucket: "renewable_energy")
  |> range(start: -1h)
  |> filter(fn: (r) => r._measurement == "energy_storage_data")
  |> filter(fn: (r) => r._field == "voltage")
  |> aggregateWindow(every: 1m, fn: mean, createEmpty: false)
```

### 20. Battery Temperature
**Purpose**: Shows the average battery temperature over the last hour. Use this to monitor thermal performance and prevent overheating.
**When to use**: To track battery temperature and identify thermal issues that affect performance and safety.
**Expected result**: Time series data showing temperature in Celsius over time.

```flux
from(bucket: "renewable_energy")
  |> range(start: -1h)
  |> filter(fn: (r) => r._measurement == "energy_storage_data")
  |> filter(fn: (r) => r._field == "temperature")
  |> aggregateWindow(every: 1m, fn: mean, createEmpty: false)
```

## Heat Boiler Queries

### 21. Heat Boiler Power Output
**Purpose**: Shows the average power output from heat boilers over the last hour. Use this to monitor thermal energy generation.
**When to use**: To track heat boiler performance and ensure consistent thermal energy production.
**Expected result**: Time series data showing power output in watts over time.

```flux
from(bucket: "renewable_energy")
  |> range(start: -1h)
  |> filter(fn: (r) => r._measurement == "heat_boiler_data")
  |> filter(fn: (r) => r._field == "power_output")
  |> aggregateWindow(every: 1m, fn: mean, createEmpty: false)
```

### 22. Boiler Temperature
**Purpose**: Shows the average boiler temperature over the last hour. Use this to monitor thermal performance and ensure safe operation.
**When to use**: To track boiler temperature and identify overheating or underheating issues.
**Expected result**: Time series data showing temperature in Celsius over time.

```flux
from(bucket: "renewable_energy")
  |> range(start: -1h)
  |> filter(fn: (r) => r._measurement == "heat_boiler_data")
  |> filter(fn: (r) => r._field == "temperature")
  |> aggregateWindow(every: 1m, fn: mean, createEmpty: false)
```

### 23. Boiler Efficiency
**Purpose**: Shows the average boiler efficiency over the last hour. Use this to monitor how well the boiler converts fuel to heat energy.
**When to use**: To track boiler performance and identify efficiency issues.
**Expected result**: Time series data showing efficiency percentage over time.

```flux
from(bucket: "renewable_energy")
  |> range(start: -1h)
  |> filter(fn: (r) => r._measurement == "heat_boiler_data")
  |> filter(fn: (r) => r._field == "efficiency")
  |> aggregateWindow(every: 1m, fn: mean, createEmpty: false)
```

## System Overview Queries

### 24. Total Power Generation (All Devices)
**Purpose**: Shows the total power generation from all renewable energy devices combined over the last hour. Use this to monitor overall system performance.
**When to use**: To track total energy production and understand system-wide generation patterns.
**Expected result**: Time series data showing total power output in watts over time.

```flux
from(bucket: "renewable_energy")
  |> range(start: -1h)
  |> filter(fn: (r) => r._field == "power_output")
  |> aggregateWindow(every: 1m, fn: sum, createEmpty: false)
```

### 25. Power Generation by Device Type (Measurement)
**Purpose**: Shows power generation broken down by device type (solar, wind, biogas, etc.) over the last hour. Use this to compare different energy sources.
**When to use**: To understand which energy sources are contributing most to total generation.
**Expected result**: Time series data showing power output by device type over time.

```flux
from(bucket: "renewable_energy")
  |> range(start: -1h)
  |> filter(fn: (r) => r._field == "power_output")
  |> group(columns: ["_measurement"])
  |> aggregateWindow(every: 1m, fn: sum, createEmpty: false)
```

### 26. Active Devices Count
**Purpose**: Shows how many devices are currently operational (status = "operational") in the last 5 minutes. Use this to monitor system availability.
**When to use**: To quickly check how many devices are working and identify any offline devices.
**Expected result**: A single number showing count of operational devices.

```flux
from(bucket: "renewable_energy")
  |> range(start: -5m)
  |> filter(fn: (r) => r._field == "status")
  |> filter(fn: (r) => r._value == "operational")
  |> group()
  |> count()
```

### 27. Device Status Summary
**Purpose**: Shows a breakdown of device statuses (operational, fault, maintenance, etc.) in the last 5 minutes. Use this to understand system health.
**When to use**: To get an overview of system status and identify any problematic devices.
**Expected result**: A count for each status type (operational, fault, etc.).

```flux
from(bucket: "renewable_energy")
  |> range(start: -5m)
  |> filter(fn: (r) => r._field == "status")
  |> group(columns: ["_value"])
  |> count()
```

## Fault Detection Queries

### 28. Faulty Devices
**Purpose**: Shows all devices that have a fault status in the last hour. Use this to identify devices that need attention.
**When to use**: To quickly identify problematic devices that require maintenance or repair.
**Expected result**: A list of device types and IDs that are in fault status.

```flux
from(bucket: "renewable_energy")
  |> range(start: -1h)
  |> filter(fn: (r) => r._field == "status")
  |> filter(fn: (r) => r._value == "fault")
  |> group(columns: ["_measurement", "device_id"])
```

### 29. Low Efficiency Devices
**Purpose**: Shows all devices with efficiency below 70% in the last hour. Use this to identify underperforming devices.
**When to use**: To identify devices that are not operating at optimal efficiency and may need maintenance.
**Expected result**: A list of device types and IDs with efficiency below 70%.

```flux
from(bucket: "renewable_energy")
  |> range(start: -1h)
  |> filter(fn: (r) => r._field == "efficiency")
  |> filter(fn: (r) => r._value < 70)
  |> group(columns: ["_measurement", "device_id"])
```

### 30. High Temperature Alerts
**Purpose**: Shows all devices with temperature above 80°C in the last hour. Use this to identify overheating devices.
**When to use**: To identify devices that are overheating and may need immediate attention.
**Expected result**: A list of device types and IDs with temperature above 80°C.

```flux
from(bucket: "renewable_energy")
  |> range(start: -1h)
  |> filter(fn: (r) => r._field == "temperature")
  |> filter(fn: (r) => r._value > 80)
  |> group(columns: ["_measurement", "device_id"])
```

## Performance Monitoring Queries

### 31. Data Points per Minute
**Purpose**: Shows how many data points are being written per minute over the last hour. Use this to monitor data flow and system activity.
**When to use**: To verify that data is being written consistently and identify any gaps in data collection.
**Expected result**: Time series data showing data point count per minute over time.

```flux
from(bucket: "renewable_energy")
  |> range(start: -1h)
  |> aggregateWindow(every: 1m, fn: count, createEmpty: false)
```

### 32. Data Points by Measurement
**Purpose**: Shows how many data points each measurement type is generating per minute over the last hour. Use this to monitor data flow by device type.
**When to use**: To verify that all device types are generating data consistently.
**Expected result**: Time series data showing data point count per measurement over time.

```flux
from(bucket: "renewable_energy")
  |> range(start: -1h)
  |> group(columns: ["_measurement"])
  |> aggregateWindow(every: 1m, fn: count, createEmpty: false)
```

### 33. Latest Values for All Devices
**Purpose**: Shows the most recent value for each field of each device in the last 5 minutes. Use this to get a current snapshot of all device states.
**When to use**: To get a comprehensive view of current system status across all devices.
**Expected result**: One row per device-field combination showing the latest value.

```flux
from(bucket: "renewable_energy")
  |> range(start: -5m)
  |> group(columns: ["_measurement", "device_id", "_field"])
  |> last()
```

## Time Range Variations

### 34. Last 24 Hours
**Purpose**: Shows total power generation over the last 24 hours, aggregated every 5 minutes. Use this to see daily generation patterns.
**When to use**: To analyze daily energy production patterns and identify peak generation periods.
**Expected result**: Time series data showing total power output over 24 hours.

```flux
from(bucket: "renewable_energy")
  |> range(start: -24h)
  |> filter(fn: (r) => r._field == "power_output")
  |> aggregateWindow(every: 5m, fn: sum, createEmpty: false)
```

### 35. Last 7 Days
**Purpose**: Shows total power generation over the last 7 days, aggregated every hour. Use this to see weekly generation patterns.
**When to use**: To analyze weekly energy production trends and compare daily performance.
**Expected result**: Time series data showing total power output over 7 days.

```flux
from(bucket: "renewable_energy")
  |> range(start: -7d)
  |> filter(fn: (r) => r._field == "power_output")
  |> aggregateWindow(every: 1h, fn: sum, createEmpty: false)
```

### 36. Last 30 Days
**Purpose**: Shows total power generation over the last 30 days, aggregated every 6 hours. Use this to see monthly generation patterns.
**When to use**: To analyze monthly energy production trends and long-term performance.
**Expected result**: Time series data showing total power output over 30 days.

```flux
from(bucket: "renewable_energy")
  |> range(start: -30d)
  |> filter(fn: (r) => r._field == "power_output")
  |> aggregateWindow(every: 6h, fn: sum, createEmpty: false)
```

## Debugging Queries

### 37. Check for Missing Data
**Purpose**: Identifies time periods where no power output data was recorded in the last hour. Use this to detect data gaps or system issues.
**When to use**: To identify when data collection failed or devices were offline.
**Expected result**: Time periods (if any) where no power output data was recorded.

```flux
from(bucket: "renewable_energy")
  |> range(start: -1h)
  |> filter(fn: (r) => r._field == "power_output")
  |> aggregateWindow(every: 1m, fn: count, createEmpty: true)
  |> filter(fn: (r) => r._value == 0)
```

### 38. Data Quality Check
**Purpose**: Identifies power output values that are outside expected ranges (negative or above 10,000W). Use this to detect sensor errors or data corruption.
**When to use**: To identify anomalous data that may indicate sensor problems or data quality issues.
**Expected result**: Any power output values that are negative or exceed 10,000W.

```flux
from(bucket: "renewable_energy")
  |> range(start: -1h)
  |> filter(fn: (r) => r._field == "power_output")
  |> filter(fn: (r) => r._value < 0 or r._value > 10000)
```

### 39. Device Communication Status
**Purpose**: Identifies devices that have not sent any data in the last 5 minutes. Use this to detect communication failures or offline devices.
**When to use**: To identify devices that may be offline or experiencing communication issues.
**Expected result**: A list of device types and IDs that have not communicated recently.

```flux
from(bucket: "renewable_energy")
  |> range(start: -5m)
  |> group(columns: ["_measurement", "device_id"])
  |> count()
  |> filter(fn: (r) => r._value == 0)
```

## Usage Instructions

1. **Copy the query** you want to test
2. **Open Grafana Explore** (compass icon)
3. **Select "InfluxDB 2.x"** as data source
4. **Paste the query** in the editor
5. **Adjust time range** as needed
6. **Click "Run query"**

## Notes

- **Time ranges**: Adjust `start: -1h` to your needs (e.g., `-24h`, `-7d`)
- **Aggregation windows**: Modify `every: 1m` for different resolutions
- **Filters**: Add more filters based on your specific needs
- **Grouping**: Use `group(columns: [...])` to group by specific tags
- **Device Types**: Use `_measurement` instead of `device_type` tag since device types are encoded in measurement names