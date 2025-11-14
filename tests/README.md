# End-to-End Testing Suite

This directory contains PowerShell test scripts for validating the complete data flow of the Renewable Energy IoT Monitoring System.

## Test Scripts

### 1. `test-all-services.ps1`
Tests health checks for all services:
- Mosquitto (MQTT Broker)
- InfluxDB
- Node-RED
- Grafana
- API (Express.js)
- Frontend (React)

**Usage:**
```powershell
.\tests\test-all-services.ps1
```

### 2. `test-network-connectivity.ps1`
Tests network connectivity between Docker containers:
- API → InfluxDB
- Frontend → API
- API → Mosquitto
- Node-RED → InfluxDB
- Node-RED → Mosquitto

**Usage:**
```powershell
.\tests\test-network-connectivity.ps1
```

### 3. `test-api-influxdb.ps1`
Tests API connection to InfluxDB:
- Health check
- Photovoltaic data fetching
- Wind turbine data fetching
- Energy storage data fetching
- Custom Flux query execution

**Usage:**
```powershell
.\tests\test-api-influxdb.ps1
```

### 4. `test-complete-flow.ps1`
Tests complete data flow for all device types:
- Photovoltaic Panel
- Wind Turbine
- Biogas Plant
- Heat Boiler
- Energy Storage

**Usage:**
```powershell
.\tests\test-complete-flow.ps1
```

### 5. `test-performance.ps1`
Performance testing for API endpoints:
- Response time measurements
- Average, min, and max times
- Multiple iterations for accuracy

**Usage:**
```powershell
.\tests\test-performance.ps1
```

### 6. `test-realtime-updates.ps1`
Monitors real-time data updates:
- Fetches data every 5 seconds
- Runs for 30 seconds (6 iterations)
- Displays timestamp and values

**Usage:**
```powershell
.\tests\test-realtime-updates.ps1
```

### 7. `run-all-tests.ps1`
Master test runner that executes all test scripts in sequence.

**Usage:**
```powershell
.\tests\run-all-tests.ps1
```

## Prerequisites

Before running tests, ensure:

1. **All services are running:**
   ```powershell
   docker-compose up -d
   ```

2. **Services are healthy:**
   ```powershell
   docker-compose ps
   ```
   All services should show "Up" and "healthy" status.

3. **Data is being generated:**
   - Node-RED flows should be running
   - MQTT messages should be published
   - InfluxDB should have recent data

## Quick Start

1. **Start all services:**
   ```powershell
   docker-compose up -d
   ```

2. **Wait for services to be healthy:**
   ```powershell
   docker-compose ps
   ```

3. **Run all tests:**
   ```powershell
   .\tests\run-all-tests.ps1
   ```

4. **Or run individual tests:**
   ```powershell
   .\tests\test-all-services.ps1
   .\tests\test-api-influxdb.ps1
   ```

## Expected Results

### Healthy System Indicators:
- ✅ All services show "healthy" status
- ✅ API connects to InfluxDB without errors
- ✅ Frontend can fetch data from API
- ✅ Data is recent (within last few minutes)
- ✅ All device types return data
- ✅ Response times < 500ms for most queries
- ✅ Real-time data updates every 30-60 seconds

## Troubleshooting

### No Data Available
```powershell
# Check if Node-RED is sending data
docker-compose logs node-red | Select-String "success"

# Check InfluxDB for recent data
curl -X POST "http://localhost:40101/api/v2/query?org=renewable_energy_org" `
  -H "Authorization: Token renewable_energy_admin_token_123" `
  -H "Content-Type: application/vnd.flux" `
  -d 'from(bucket: "renewable_energy") |> range(start: -5m) |> limit(n: 10)'
```

### API Errors
```powershell
# Check API logs
docker-compose logs --tail=100 api

# Restart API
docker-compose restart api

# Check API environment
docker exec iot-api env | Select-String "INFLUX"
```

### Frontend Issues
```powershell
# Rebuild frontend with correct env vars
docker-compose build frontend
docker-compose up -d frontend

# Check frontend logs
docker-compose logs frontend
```

### Network Issues
```powershell
# Check Docker network
docker network inspect plat-edu-bad-data-mvp_iot-network

# Verify containers are on the same network
docker network ls
```

## Test Data Flow

The complete data flow being tested:
```
MQTT (Mosquitto)
    ↓
Node-RED (Data Processing)
    ↓
InfluxDB (Time-Series Database)
    ↓
API (Express.js Backend)
    ↓
Frontend (React Web App)
```

## Port Configuration

Default ports (can be changed via environment variables):
- **Mosquitto**: 40098 (production) / 1883 (local)
- **InfluxDB**: 40101 (production) / 8086 (local)
- **Node-RED**: 40100 (production) / 1880 (local)
- **Grafana**: 40099 (production) / 3000 (local)
- **API**: 3001
- **Frontend**: 5173

## Notes

- Tests use PowerShell and require Windows or PowerShell Core
- Some tests may take time to complete (especially real-time monitoring)
- Performance may vary based on system resources
- Ensure all simulations are running (Node-RED flows)
- Test regularly to catch integration issues early
- Check logs for detailed error information

## Continuous Integration

These tests can be integrated into CI/CD pipelines:
```yaml
# Example GitHub Actions
- name: Run E2E Tests
  run: |
    docker-compose up -d
    Start-Sleep -Seconds 30
    .\tests\run-all-tests.ps1
```

## Contributing

When adding new tests:
1. Follow the existing naming convention: `test-*.ps1`
2. Include error handling and colored output
3. Add the test to `run-all-tests.ps1`
4. Update this README with test description

