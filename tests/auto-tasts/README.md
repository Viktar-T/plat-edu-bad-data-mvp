# Automated Test Suite

## Overview

This directory contains automated tests for the Renewable Energy IoT Monitoring System. The automated test suite provides comprehensive validation of system prerequisites, integration, data flow, and performance characteristics.

## Test Structure

```
tests/auto-tasts/
├── test-prerequisites.ps1          # Automated prerequisites check
├── run-prerequisites-test.ps1      # Prerequisites test runner
├── run-all-auto-tests.ps1          # Comprehensive test suite runner
└── README.md                       # This documentation
```

## Available Tests

### 1. Prerequisites Test (`test-prerequisites.ps1`)

**Purpose**: Automated validation of all system prerequisites before running other tests.

**Tests Performed**:
- Docker and Docker Compose availability
- Docker services health status (Mosquitto, InfluxDB, Node-RED, Grafana)
- Network connectivity to all service ports
- Service health endpoints validation
- Node.js and npm version requirements
- Environment variable configuration
- MQTT dependencies and connectivity
- PowerShell execution policy

**Usage**:
```powershell
# Run basic prerequisites check
.\test-prerequisites.ps1

# Run with verbose output
.\test-prerequisites.ps1 -Verbose

# Skip specific checks
.\test-prerequisites.ps1 -SkipDockerCheck -SkipNetworkCheck
```

**Parameters**:
- `-Verbose`: Enable detailed debugging output
- `-SkipDockerCheck`: Skip Docker service health checks
- `-SkipNetworkCheck`: Skip network connectivity tests
- `-SkipEnvironmentCheck`: Skip environment variable validation

### 2. Prerequisites Test Runner (`run-prerequisites-test.ps1`)

**Purpose**: Enhanced runner for prerequisites test with result saving and formatting options.

**Usage**:
```powershell
# Run with console output
.\run-prerequisites-test.ps1

# Save results to file
.\run-prerequisites-test.ps1 -SaveResults

# Specify output format and results path
.\run-prerequisites-test.ps1 -OutputFormat JSON -SaveResults -ResultsPath "custom/path"
```

**Parameters**:
- `-OutputFormat`: Output format (Console, JSON, XML)
- `-SaveResults`: Save test results to file
- `-ResultsPath`: Path to save results (default: tests/results/)

### 3. Comprehensive Test Suite (`run-all-auto-tests.ps1`)

**Purpose**: Runs all automated tests in the correct sequence with proper dependency management.

**Test Sequence**:
1. **Prerequisites Check** (Required)
2. **Integration Tests** (Optional)
3. **Data Flow Tests** (Optional)
4. **Performance Tests** (Optional)

**Usage**:
```powershell
# Run all tests
.\run-all-auto-tests.ps1

# Skip performance tests
.\run-all-auto-tests.ps1 -SkipPerformance

# Save results and run with custom configuration
.\run-all-auto-tests.ps1 -SaveResults -OutputFormat JSON -SkipIntegration
```

**Parameters**:
- `-SkipPrerequisites`: Skip prerequisites check (not recommended)
- `-SkipIntegration`: Skip integration tests
- `-SkipPerformance`: Skip performance tests
- `-Parallel`: Run tests in parallel where possible
- `-OutputFormat`: Output format (Console, JSON, XML)
- `-SaveResults`: Save test results to file
- `-ResultsPath`: Path to save results (default: tests/results/)

## Integration with Existing Test Framework

The automated tests integrate seamlessly with the existing test framework:

### Manual Tests Integration
- Automated tests can be run before manual tests to ensure prerequisites
- Results can be used to determine which manual tests to run
- Automated tests provide quick validation for CI/CD pipelines

### Scripts Integration
- Uses existing test scripts from `tests/scripts/`
- Leverages common testing utilities and configurations
- Maintains consistency with existing test patterns

### Test Results Integration
- Results are saved in a consistent format
- Can be used by the main test runner (`tests/run-all-tests.ps1`)
- Supports integration with external reporting tools

## Test Configuration

### Service Configuration
The tests are configured to validate these services:
- **Mosquitto MQTT Broker**: Port 1883, WebSocket 9001
- **InfluxDB**: Port 8086, Health endpoint `/health`
- **Node-RED**: Port 1880, Health endpoint `/`
- **Grafana**: Port 3000, Health endpoint `/api/health`

### Version Requirements
- **Node.js**: 18.0.0 or higher
- **NPM**: 8.0.0 or higher
- **Docker**: Latest stable version
- **Docker Compose**: Latest stable version

### Environment Variables
Required environment variables:
- `INFLUXDB_TOKEN`
- `INFLUXDB_ORG`
- `INFLUXDB_BUCKET`
- `GRAFANA_ADMIN_PASSWORD`

## Test Results

### Console Output
Tests provide real-time console output with color-coded results:
- 🟢 **Green**: Passed tests
- 🔴 **Red**: Failed tests
- 🟡 **Yellow**: Skipped tests
- 🔵 **Cyan**: Information and headers

### Result Files
When saving results, files are created with timestamps:
- `prerequisites-test-results-YYYYMMDD_HHMMSS.json`
- `auto-test-suite-results-YYYYMMDD_HHMMSS.json`

### Result Structure
```json
{
  "StartTime": "2024-01-01T12:00:00",
  "EndTime": "2024-01-01T12:05:00",
  "Tests": [
    {
      "TestName": "Docker Command Available",
      "Description": "Docker command is available",
      "Passed": true,
      "Message": "Docker command is available",
      "ExitCode": 0,
      "Timestamp": "2024-01-01T12:00:30",
      "Duration": "00:00:30"
    }
  ],
  "TotalTests": 15,
  "PassedTests": 14,
  "FailedTests": 1,
  "SkippedTests": 0
}
```

## Troubleshooting

### Common Issues

#### 1. PowerShell Execution Policy
**Problem**: Scripts fail to execute
**Solution**:
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

#### 2. Docker Services Not Running
**Problem**: Docker service health checks fail
**Solution**:
```powershell
docker-compose up -d
docker-compose ps
```

#### 3. Port Conflicts
**Problem**: Network connectivity tests fail
**Solution**:
```powershell
# Check what's using the port
netstat -ano | findstr :1883

# Stop conflicting services or change ports in docker-compose.yml
```

#### 4. Environment Variables Missing
**Problem**: Environment validation fails
**Solution**:
```powershell
# Check current environment variables
Get-Content .env

# Set missing variables
$env:INFLUXDB_TOKEN = "your_token"
```

#### 5. Node.js Version Issues
**Problem**: Node.js version check fails
**Solution**:
```powershell
# Check current version
node --version

# Update Node.js if needed
# Download from https://nodejs.org/
```

### Debug Mode
Enable verbose output for detailed debugging:
```powershell
.\test-prerequisites.ps1 -Verbose
```

### Skip Specific Tests
Skip tests that are not relevant for your environment:
```powershell
.\test-prerequisites.ps1 -SkipDockerCheck -SkipEnvironmentCheck
```

## Best Practices

### 1. Test Execution Order
- Always run prerequisites check first
- Run integration tests after prerequisites pass
- Run performance tests last

### 2. Environment Preparation
- Ensure all Docker services are running
- Verify environment variables are set
- Check PowerShell execution policy

### 3. Result Analysis
- Review failed tests first
- Check test details for specific error messages
- Use verbose output for debugging

### 4. CI/CD Integration
- Use automated tests in CI/CD pipelines
- Save results for trend analysis
- Set appropriate exit codes for pipeline integration

## Future Enhancements

### Planned Features
- **Parallel Test Execution**: Run independent tests in parallel
- **Test Result Comparison**: Compare results across runs
- **Performance Benchmarking**: Track performance trends
- **Custom Test Configuration**: Allow custom test parameters
- **Integration with External Tools**: Connect with monitoring and alerting systems

### Extensibility
The test framework is designed to be easily extensible:
- Add new test scripts to the test suite
- Customize test configurations
- Integrate with external validation tools
- Add custom result formats

## Support

For issues with automated tests:
1. Check the troubleshooting section
2. Enable verbose output for debugging
3. Review test result files for details
4. Check the main project documentation
5. Create an issue with detailed error information 