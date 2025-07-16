# 2025-01-XX - MQTT Topic Structure Decision

## Status
**Accepted**

## Context
The renewable energy IoT monitoring system needs a structured approach to organize MQTT messages from multiple device types (photovoltaic, wind turbine, biogas, heat boiler, energy storage). The topic structure must support efficient filtering, routing, and future expansion.

## Decision
Use hierarchical topic structure: `devices/{device_type}/{device_id}/{data_type}`

**Examples**:
- `devices/photovoltaic/pv001/telemetry`
- `devices/wind_turbine/wt001/status`
- `devices/energy_storage/es001/alerts`
- `devices/biogas/bg001/faults`

## Consequences

### Positive
- **Clear Organization**: Easy to understand and navigate
- **Wildcard Support**: Can subscribe to `devices/photovoltaic/+/telemetry` for all PV telemetry
- **Scalability**: Supports unlimited device types and IDs
- **Filtering**: Node-RED can easily filter by device type or data type
- **Future-Proof**: Easy to add new device types or data types

### Negative
- **Topic Length**: Longer topic names (acceptable trade-off)
- **Permission Complexity**: ACLs need to be carefully planned
- **Schema Evolution**: Need to plan for topic structure changes

## Alternatives Considered

### Flat Structure: `{device_id}_{data_type}`
- **Why Rejected**: No device type grouping, harder to filter, less scalable

### UUID-Based: `devices/{uuid}/{data_type}`
- **Why Rejected**: Not human-readable, harder to debug, no device type information

### Type-First: `{device_type}/{data_type}/{device_id}`
- **Why Rejected**: Less intuitive, harder to subscribe to specific device data

### Custom Format: `{location}/{device_type}/{device_id}`
- **Why Rejected**: Adds unnecessary complexity, location can be in message payload

## Implementation Notes
- Use consistent device type names (lowercase with underscores)
- Device IDs should be descriptive (e.g., `pv001`, `wt001`)
- Data types: `telemetry`, `status`, `alerts`, `faults`
- Consider adding versioning: `devices/v1/{device_type}/{device_id}/{data_type}`

## Related Documents
- [MQTT Communication Design](../design/mqtt-communication/design.md)
- [MQTT Development History](../design/mqtt-communication/history.md)
- [Initial Design Session](../design/mqtt-communication/archive/2025-01-XX-initial-design-session.md)

## Review Date
**2025-02-XX** - Review after initial implementation and testing 