# Manual Test 03: Node-RED Data Processing

## Overview
This test verifies that Node-RED is properly processing MQTT messages, validating data, transforming it, and forwarding it to InfluxDB for storage.

## Test Objective
Ensure Node-RED flows are correctly receiving MQTT messages, processing device data, and sending it to the database.

## Prerequisites
- Manual Test 01 and 02 completed successfully
- Node-RED accessible at http://localhost:1880
- MQTT broker running and tested
- InfluxDB running and accessible

## Test Steps

### Step 1: Access Node-RED Interface

#### 1.1 Open Node-RED Dashboard
**Action:**
1. Open web browser
2. Navigate to http://localhost:1880
3. Login with credentials (if required)

**Expected Result:**
- Node-RED editor loads successfully
- Dashboard shows all deployed flows
- No error messages

#### 1.2 Verify Flow Status
**Action:**
1. Check that all flows are deployed (green status)
2. Verify no red error indicators
3. Check flow tabs for different device types

**Expected Result:**
- All flows show green status (deployed)
- No red error indicators
- Flows visible for:
  - Photovoltaic simulation
  - Wind turbine simulation
  - Biogas plant simulation
  - Heat boiler simulation
  - Energy storage simulation

### Step 2: Test MQTT Input Processing

#### 2.1 Test Photovoltaic Data Reception


**Action in Node-RED:**
1. Open the photovoltaic simulation flow
2. Look for MQTT input node
3. Check debug output for EACH received message. Check in Node-RED debuger panel.
4. Verify message structure

