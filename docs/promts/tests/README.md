# Testing and Validation Framework - MVP Project

## Overview
This directory contains testing prompts organized by the hybrid approach for the Renewable Energy IoT Monitoring System MVP.

## Testing Strategy
- **JavaScript/Node.js**: Node-RED flows, MQTT communication, data validation
- **Python**: Data analysis, complex validation, renewable energy calculations
- **SQL**: Database schema validation, query performance, data integrity
- **Shell Scripts**: System-level testing, Docker orchestration, health checks

## Task Organization

### Phase 1: Test Infrastructure
1. **00-test-directory-structure.md** - Comprehensive test directory organization

### Phase 2: Foundation Testing
2. **01-mqtt-communication-testing.md** - MQTT broker and message validation
3. **02-node-red-flow-testing.md** - Node-RED flow logic and data processing
4. **03-database-schema-testing.md** - InfluxDB 3.x schema and data integrity

### Phase 3: Integration Testing
5. **04-end-to-end-data-flow.md** - Complete data pipeline validation
6. **05-device-simulation-testing.md** - Renewable energy device data simulation
7. **06-grafana-dashboard-testing.md** - Dashboard functionality and data visualization

### Phase 4: System Testing
8. **07-performance-testing.md** - System performance under load
9. **08-error-handling-testing.md** - Error scenarios and recovery
10. **09-security-testing.md** - Authentication and authorization validation

### Phase 5: Validation Framework
11. **10-data-quality-validation.md** - Data accuracy and completeness
12. **11-business-logic-validation.md** - Renewable energy calculations and rules
13. **12-monitoring-alerting-testing.md** - Health checks and alerting system

## Usage
Each prompt file contains:
- **Objective**: What the test should accomplish
- **Scope**: What components are being tested
- **Approach**: Which language/framework to use
- **Success Criteria**: How to determine if the test passes
- **Implementation Notes**: Technical considerations for MVP

## MVP Considerations
- Keep tests simple and focused
- Prioritize critical path functionality
- Use realistic but manageable test data
- Focus on automated testing where possible
- Maintain quick feedback loops for development 