# MQTT Loop Implementation Guide

## Overview

This document explains how to implement **Option 2: MQTT Loop** in your renewable energy IoT monitoring system. The MQTT loop creates a complete data flow where Node-RED publishes data to the MQTT broker and then subscribes to receive that data back for processing.

## Current Flow vs MQTT Loop

### Current Flow (Direct Processing)
```
30s Interval → PV Data Generator → Data Validation → Error Check → Store Data
```

### MQTT Loop (Complete IoT Pattern)
```
30s Interval → PV Data Generator → MQTT Output (publish to broker)
                                    ↓
                              [MQTT Broker]
                                    ↓
                              MQTT Input (subscribe from broker)
                                    ↓
                              Data Validation → Error Check → Store Data
```

## Benefits of MQTT Loop

1. **Realistic IoT Architecture**: Simulates how real devices communicate
2. **Decoupled Processing**: Data generation and processing are separated
3. **Scalability**: Multiple subscribers can receive the same data
4. **Testing**: Easy to test individual components
5. **Monitoring**: Can monitor MQTT traffic independently

## Implementation Steps

### Step 1: Create MQTT Input Node

Add an MQTT Input node that subscribes to the same topic pattern:

**Configuration:**
- **Topic**: `devices/photovoltaic/+/telemetry`
- **QoS**: 1
- **Broker**: Same as MQTT Output
- **Data Type**: JSON

### Step 2: Modify Data Flow

1. **Remove direct connection** from PV Data Generator to Data Validation
2. **Connect MQTT Output** to publish data to broker
3. **Connect MQTT Input** to receive data from broker
4. **Connect MQTT Input** to Data Validation

### Step 3: Update Topic Structure

Ensure consistent topic naming:
- **Publish**: `devices/photovoltaic/{device_id}/telemetry`
- **Subscribe**: `devices/photovoltaic/+/telemetry`

## Complete Flow Structure

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   30s Interval  │───▶│ PV Data Generator│───▶│ MQTT Output     │
└─────────────────┘    └──────────────────┘    └─────────────────┘
                                                         │
                                                         ▼ (publishes to)
                                              ┌─────────────────┐
                                              │  MQTT Broker    │
                                              │   (Mosquitto)   │
                                              └─────────────────┘
                                                         │
                                                         ▼ (forwards to subscribers)
                                                         │
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Store Data    │◀───│   Error Check    │◀───│ Data Validation │◀───┐
└─────────────────┘    └──────────────────┘    └─────────────────┘    │
                                                                      │
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐    │
│   Error Log     │◀───│   Error Check    │◀───│ MQTT Input      │◀───┘
└─────────────────┘    └──────────────────┘    └─────────────────┘
                                                         ▲
                                                         │ (subscribes to)
                                                         │ devices/photovoltaic/+/telemetry
                                                         │
                                              ┌─────────────────┐
                                              │  MQTT Broker    │
                                              │   (Mosquitto)   │
                                              └─────────────────┘
```

## Testing the MQTT Loop

### 1. Verify MQTT Communication
```powershell
# Subscribe to photovoltaic data
.\test-mqtt.ps1 -Subscribe -MqttHost "localhost" -Topic "devices/photovoltaic/+/telemetry"
```

### 2. Monitor Node-RED Debug Output
- Check MQTT Input node for received messages
- Verify data validation is working
- Confirm InfluxDB storage

### 3. Check InfluxDB Data
```powershell
# Query stored data
$params = @{
    db = "renewable_energy"
    q = "SELECT * FROM photovoltaic_data ORDER BY time DESC LIMIT 10"
}
Invoke-WebRequest -Uri "http://localhost:8086/query" -Method GET -Body $params -UseBasicParsing
```

## Troubleshooting

### Common Issues

1. **No messages received by MQTT Input**
   - Check MQTT broker connection
   - Verify topic subscription pattern
   - Ensure QoS levels match

2. **Data not stored in InfluxDB**
   - Check InfluxDB connection
   - Verify data validation passes
   - Check error logs

3. **Circular dependency errors**
   - Ensure MQTT broker config node has unique ID
   - Check all MQTT nodes reference correct broker

### Debug Steps

1. **Enable debug nodes** for MQTT Input and Output
2. **Check Node-RED logs** for connection errors
3. **Verify MQTT broker** is running and accessible
4. **Test with external MQTT client** to isolate issues

## Extending to Other Device Types

Apply the same pattern to other renewable energy devices:

- **Wind Turbine**: `devices/wind_turbine/+/telemetry`
- **Biogas Plant**: `devices/biogas/+/telemetry`
- **Heat Boiler**: `devices/heat_boiler/+/telemetry`
- **Energy Storage**: `devices/energy_storage/+/telemetry`

## Performance Considerations

1. **QoS Levels**: Use QoS 1 for reliable delivery
2. **Message Retention**: Configure appropriate retention policies
3. **Connection Limits**: Monitor broker connection limits
4. **Data Volume**: Consider message size and frequency

## Security Considerations

1. **Authentication**: Implement MQTT authentication
2. **Authorization**: Use ACLs to control topic access
3. **Encryption**: Enable TLS for secure communication
4. **Topic Security**: Use hierarchical topic structure

## Next Steps

1. **Deploy the MQTT loop flow**
2. **Test with real device data**
3. **Monitor system performance**
4. **Add alerting and monitoring**
5. **Scale to multiple device types** 