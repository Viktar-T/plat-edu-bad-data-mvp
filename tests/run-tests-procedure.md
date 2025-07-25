# MQTT Communication Testing - Step-by-Step Procedure

## Overview
This procedure guides you through running MQTT communication tests in a containerized environment. All tests run in a separate container while the main services (mosquitto, influxdb, node-red, grafana) run in their own containers.

## Prerequisites
- Docker and Docker Compose installed
- Windows PowerShell
- Main application containers running

## 1. Environment Preparation

### 1.1 Navigate to Project Directory
```powershell
cd C:\Users\vtaustyka\ProjectsGitHub\plat-edu-bad-data-mvp
```

### 1.2 Start Main Services
```powershell
# Start all main containers (mosquitto, influxdb, node-red, grafana)
docker-compose up -d
```

### 1.3 Verify Main Services Are Running
```powershell
# Check container status
docker-compose ps

# Expected output should show all services as "Up":
# mosquitto    Up
# influxdb     Up  
# node-red     Up
# grafana      Up
```

## 2. Test Execution

### 2.1 Navigate to Tests Directory
```powershell
cd tests
```

### 2.2 Run Containerized Tests
```powershell
# Run all tests in container (includes health checks and MQTT tests)
docker-compose -f docker-compose.test.yml up --build
```

**What happens:**
- Container builds and installs dependencies
- Runs automated health checks first
- If health checks pass, runs MQTT communication tests
- All tests run in isolated container environment

### 2.3 Monitor Test Execution
```powershell
# Watch test output in real-time
docker-compose -f docker-compose.test.yml logs -f test-runner
```

## 3. Test Results Analysis

### 3.1 Check Test Exit Code
```powershell
# Check if tests completed successfully
docker-compose -f docker-compose.test.yml ps

# Exit code 0 = success, non-zero = failure
```

### 3.2 View Test Output
```powershell
# Get complete test output
docker-compose -f docker-compose.test.yml logs test-runner
```

## 4. Log File Analysis

### 4.1 Navigate to Test Results
```powershell
cd tests\javascript\mqtt\test-results
```

### 4.2 Locate Log Files
```powershell
# List all test result files with date/time information
Get-ChildItem -Filter "*.md" | Format-Table Name, CreationTime, LastWriteTime

# Expected file format:
# 2024-01-15_10-30-00_MQTT_Tests.md
```

**File Naming Convention:**
- Format: `YYYY-MM-DD_HH-MM-SS_MQTT_Tests.md`
- Example: `2024-01-15_10-30-00_MQTT_Tests.md`
- Only one file per test run containing all test results

### 4.3 Analyze Test Results
```powershell
# Open the latest log file
Get-ChildItem -Filter "*.md" | Sort-Object LastWriteTime -Descending | Select-Object -First 1 | ForEach-Object { 
    Write-Host "Opening: $($_.Name)"
    Start-Process $_.FullName
}
```

**Log File Structure:**
- **Overall Summary**: Test run statistics
- **Test Results Summary**: Table of all tests with pass/fail status
- **Overall Metrics**: Total connections, messages, errors
- **All Errors**: Detailed error information by test
- **All Warnings**: Warning details by test
- **Detailed Logs**: Complete chronological log with test names

### 4.4 PowerShell Function for Timestamp Conversion
```powershell
function Convert-TimestampToDate {
    param([string]$filename)
    
    # Extract timestamp from filename like "2024-01-15_10-30-00_MQTT_Tests.md"
    if ($filename -match "(\d{4}-\d{2}-\d{2})_(\d{2}-\d{2}-\d{2})_MQTT_Tests\.md") {
        $date = $matches[1]
        $time = $matches[2] -replace "-", ":"
        return "Date: $date, Time: $time"
    }
    return "Unknown format"
}

# Usage example:
Get-ChildItem -Filter "*.md" | ForEach-Object {
    $timestamp = Convert-TimestampToDate $_.Name
    Write-Host "$($_.Name) - $timestamp"
}
```

## 5. Troubleshooting

### 5.1 Container Build Issues
```powershell
# Clean and rebuild
docker-compose -f docker-compose.test.yml down
docker-compose -f docker-compose.test.yml up --build --force-recreate
```

### 5.2 Network Issues
```powershell
# Check if test container can reach main services
docker-compose -f docker-compose.test.yml run --rm test-runner ping mosquitto
docker-compose -f docker-compose.test.yml run --rm test-runner ping influxdb
```

### 5.3 Permission Issues
```powershell
# Check file permissions
Get-ChildItem tests\javascript\mqtt\test-results -Force
```

### 5.4 Service Health Issues
```powershell
# Check main service logs
docker-compose logs mosquitto
docker-compose logs influxdb
docker-compose logs node-red
docker-compose logs grafana
```

## 6. Quick Reference Commands

### 6.1 Start Everything
```powershell
cd C:\Users\vtaustyka\ProjectsGitHub\plat-edu-bad-data-mvp
docker-compose up -d
cd tests
docker-compose -f docker-compose.test.yml up --build
```

### 6.2 View Latest Results
```powershell
Get-ChildItem tests\javascript\mqtt\test-results\*.md | Sort-Object LastWriteTime -Descending | Select-Object -First 1 | ForEach-Object { Start-Process $_.FullName }
```

### 6.3 Clean Up
```powershell
docker-compose -f docker-compose.test.yml down
docker-compose down
```

## 7. Best Practices

### 7.1 Before Running Tests
- Ensure main services are healthy and running
- Check available disk space for log files
- Verify network connectivity between containers

### 7.2 During Test Execution
- Monitor container resource usage
- Watch for timeout errors
- Check for memory leaks in long-running tests

### 7.3 After Test Completion
- Review log files for patterns
- Clean up old log files periodically
- Document any failures for investigation

### 7.4 Log File Management
- Each test run creates only one log file
- Files are automatically named with datetime prefix
- Old log files can be safely deleted
- Consider archiving important test results

## 8. Environment Variables

### 8.1 Why Environment Variables Are Needed
Environment variables provide configuration flexibility and security:

**Configuration Flexibility:**
- Different environments (dev, test, prod) can use different settings
- No hardcoded values in test code
- Easy to change settings without modifying code

**Security:**
- Sensitive data (passwords, tokens) not stored in code
- Different credentials for different environments
- Follows security best practices

**Container Isolation:**
- Each container can have its own configuration
- Tests run in isolated environment
- No conflicts between different test runs

### 8.2 Key Environment Variables
```powershell
# MQTT Configuration
$env:MQTT_HOST = "mosquitto"
$env:MQTT_PORT = "1883"
$env:MQTT_USERNAME = "admin"
$env:MQTT_PASSWORD = "admin_password_456"

# Service URLs
$env:NODE_RED_HOST = "node-red"
$env:INFLUXDB_HOST = "influxdb"
$env:GRAFANA_HOST = "grafana"

# Test Configuration
$env:TEST_TIMEOUT = "30000"
$env:TEST_RETRIES = "3"
```

## 9. Automated Health Checks

### 9.1 What Are Automated Health Checks
Automated health checks verify that all required services are running and accessible before running MQTT tests.

**Benefits:**
- No manual verification required
- Faster test execution
- Consistent environment validation
- Clear error messages if services are down

### 9.2 Health Check Tests
- **Mosquitto MQTT Broker**: Verifies MQTT connection and basic operations
- **InfluxDB**: Checks database connectivity and basic queries
- **Node-RED**: Validates web interface accessibility
- **Grafana**: Confirms dashboard service availability

### 9.3 Health Check Process
1. Tests run automatically before MQTT tests
2. If any health check fails, MQTT tests are skipped
3. Detailed error messages help identify issues
4. All health check results are logged

---

**Note:** This procedure ensures reliable, repeatable test execution in a containerized environment with comprehensive logging and easy result analysis.
