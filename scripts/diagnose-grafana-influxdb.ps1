# =============================================================================
# Grafana-InfluxDB Connection Diagnostic Script (PowerShell)
# Renewable Energy IoT Monitoring System
# =============================================================================

param(
    [switch]$Fix,
    [switch]$Verbose
)

# Set error action preference
$ErrorActionPreference = "Continue"

Write-Host "🔍 Starting Grafana-InfluxDB Connection Diagnostic..." -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan

# Function to print colored output
function Write-Status {
    param(
        [string]$Status,
        [string]$Message
    )
    
    switch ($Status) {
        "SUCCESS" { Write-Host "✓ $Message" -ForegroundColor Green }
        "ERROR" { Write-Host "✗ $Message" -ForegroundColor Red }
        "WARNING" { Write-Host "! $Message" -ForegroundColor Yellow }
        "INFO" { Write-Host "i  $Message" -ForegroundColor Blue }
    }
}

# Check if Docker is running
Write-Host "1. Checking Docker status..." -ForegroundColor White
try {
    $dockerInfo = docker info 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Status "SUCCESS" "Docker is running"
    } else {
        Write-Status "ERROR" "Docker is not running. Please start Docker first."
        exit 1
    }
} catch {
    Write-Status "ERROR" "Docker is not available"
    exit 1
}

# Check if containers are running
Write-Host "2. Checking container status..." -ForegroundColor White
$containers = @("iot-mosquitto", "iot-influxdb2", "iot-node-red", "iot-grafana")
foreach ($container in $containers) {
    $running = docker ps --format "table {{.Names}}" 2>$null | Select-String "^$container$"
    if ($running) {
        Write-Status "SUCCESS" "Container $container is running"
    } else {
        Write-Status "ERROR" "Container $container is not running"
    }
}

# Check InfluxDB health
Write-Host "3. Checking InfluxDB health..." -ForegroundColor White
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8086/health" -Method GET -TimeoutSec 10 -ErrorAction Stop
    if ($response.StatusCode -eq 200) {
        Write-Status "SUCCESS" "InfluxDB is healthy"
    } else {
        Write-Status "ERROR" "InfluxDB returned status code: $($response.StatusCode)"
    }
} catch {
    Write-Status "ERROR" "InfluxDB is not responding: $($_.Exception.Message)"
}

# Check Grafana health
Write-Host "4. Checking Grafana health..." -ForegroundColor White
try {
    $response = Invoke-WebRequest -Uri "http://localhost:3000/api/health" -Method GET -TimeoutSec 10 -ErrorAction Stop
    if ($response.StatusCode -eq 200) {
        Write-Status "SUCCESS" "Grafana is healthy"
    } else {
        Write-Status "ERROR" "Grafana returned status code: $($response.StatusCode)"
    }
} catch {
    Write-Status "ERROR" "Grafana is not responding: $($_.Exception.Message)"
}

# Check InfluxDB data
Write-Host "5. Checking InfluxDB data..." -ForegroundColor White
Write-Host "   Testing InfluxDB connection and data..." -ForegroundColor Gray

# Create a temporary script to test InfluxDB
$testScript = @"
const { InfluxDB } = require('@influxdata/influxdb-client');

const url = 'http://localhost:8086';
const token = 'renewable_energy_admin_token_123';
const org = 'renewable_energy_org';
const bucket = 'renewable_energy';

const client = new InfluxDB({ url, token });

async function testConnection() {
    try {
        const queryApi = client.getQueryApi(org);
        const query = \`from(bucket: "\${bucket}")
            |> range(start: -1h)
            |> limit(n: 1)\`;
        
        const results = await queryApi.queryRaw(query);
        console.log('✅ InfluxDB connection successful');
        console.log('📊 Data found:', results.length > 0 ? 'Yes' : 'No');
        
        if (results.length > 0) {
            console.log('📈 Sample data:', results.substring(0, 200) + '...');
        }
        
        return true;
    } catch (error) {
        console.error('❌ InfluxDB connection failed:', error.message);
        return false;
    } finally {
        client.close();
    }
}

testConnection();
"@

$testScript | Out-File -FilePath "$env:TEMP\test_influxdb.js" -Encoding UTF8

# Run the test
try {
    $result = node "$env:TEMP\test_influxdb.js" 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Status "SUCCESS" "InfluxDB connection and data access working"
        if ($Verbose) { Write-Host $result -ForegroundColor Gray }
    } else {
        Write-Status "ERROR" "InfluxDB connection or data access failed"
    }
} catch {
    Write-Status "ERROR" "Failed to test InfluxDB: $($_.Exception.Message)"
}

# Check Grafana data source configuration
Write-Host "6. Checking Grafana data source..." -ForegroundColor White
Write-Host "   Testing Grafana-InfluxDB connection..." -ForegroundColor Gray

# Create a temporary script to test Grafana data source
$grafanaTestScript = @"
const https = require('http');

async function testGrafanaDataSource() {
    try {
        const options = {
            hostname: 'localhost',
            port: 3000,
            path: '/api/datasources',
            method: 'GET',
            headers: {
                'Authorization': 'Basic ' + Buffer.from('admin:admin').toString('base64')
            }
        };

        const req = https.request(options, (res) => {
            let data = '';
            res.on('data', (chunk) => {
                data += chunk;
            });
            res.on('end', () => {
                try {
                    const datasources = JSON.parse(data);
                    console.log('✅ Grafana API accessible');
                    console.log('📊 Found data sources:', datasources.length);
                    
                    const influxDS = datasources.find(ds => ds.type === 'influxdb');
                    if (influxDS) {
                        console.log('✅ InfluxDB data source found:', influxDS.name);
                        console.log('🔗 URL:', influxDS.url);
                        console.log('🏢 Organization:', influxDS.jsonData?.organization);
                        console.log('🪣 Bucket:', influxDS.jsonData?.defaultBucket);
                    } else {
                        console.log('❌ InfluxDB data source not found');
                    }
                } catch (error) {
                    console.error('❌ Failed to parse response:', error.message);
                }
            });
        });

        req.on('error', (error) => {
            console.error('❌ Grafana data source test failed:', error.message);
        });

        req.end();
    } catch (error) {
        console.error('❌ Grafana data source test failed:', error.message);
    }
}

testGrafanaDataSource();
"@

$grafanaTestScript | Out-File -FilePath "$env:TEMP\test_grafana_datasource.js" -Encoding UTF8

# Run the test
try {
    $result = node "$env:TEMP\test_grafana_datasource.js" 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Status "SUCCESS" "Grafana data source configuration verified"
        if ($Verbose) { Write-Host $result -ForegroundColor Gray }
    } else {
        Write-Status "ERROR" "Grafana data source configuration failed"
    }
} catch {
    Write-Status "ERROR" "Failed to test Grafana data source: $($_.Exception.Message)"
}

# Check for common issues
Write-Host "7. Checking for common configuration issues..." -ForegroundColor White

# Check if .env file exists
if (Test-Path ".env") {
    Write-Status "SUCCESS" ".env file exists"
} else {
    Write-Status "WARNING" ".env file not found, using defaults"
}

# Check InfluxDB authentication
if ((Test-Path ".env") -and (Get-Content ".env" | Select-String "INFLUXDB_HTTP_AUTH_ENABLED=false")) -or (-not (Test-Path ".env")) {
    Write-Status "INFO" "InfluxDB authentication is disabled (development mode)"
} else {
    Write-Status "INFO" "InfluxDB authentication is enabled"
}

# Check bucket name consistency
Write-Host "8. Checking bucket name consistency..." -ForegroundColor White
$expected_bucket = "renewable_energy"
if ((Test-Path ".env") -and (Get-Content ".env" | Select-String "INFLUXDB_BUCKET=$expected_bucket")) -or (-not (Test-Path ".env")) {
    Write-Status "SUCCESS" "Bucket name is consistent: $expected_bucket"
} else {
    Write-Status "WARNING" "Bucket name may be inconsistent"
}

# Check organization name consistency
Write-Host "9. Checking organization name consistency..." -ForegroundColor White
$expected_org = "renewable_energy_org"
if ((Test-Path ".env") -and (Get-Content ".env" | Select-String "INFLUXDB_ORG=$expected_org")) -or (-not (Test-Path ".env")) {
    Write-Status "SUCCESS" "Organization name is consistent: $expected_org"
} else {
    Write-Status "WARNING" "Organization name may be inconsistent"
}

# Check token consistency
Write-Host "10. Checking token consistency..." -ForegroundColor White
$expected_token = "renewable_energy_admin_token_123"
if ((Test-Path ".env") -and (Get-Content ".env" | Select-String "INFLUXDB_ADMIN_TOKEN=$expected_token")) -or (-not (Test-Path ".env")) {
    Write-Status "SUCCESS" "Token is consistent"
} else {
    Write-Status "WARNING" "Token may be inconsistent"
}

Write-Host ""
Write-Host "==================================================" -ForegroundColor Cyan
Write-Host "🔧 Recommended fixes:" -ForegroundColor Yellow
Write-Host ""

# Check if data exists in InfluxDB
Write-Host "📊 Checking if data exists in InfluxDB..." -ForegroundColor White
try {
    $query = "from(bucket:`"renewable_energy`")|>range(start:-1h)|>count()"
    $encodedQuery = [System.Web.HttpUtility]::UrlEncode($query)
    $url = "http://localhost:8086/query?org=renewable_energy_org&q=$encodedQuery"
    
    $headers = @{
        "Authorization" = "Token renewable_energy_admin_token_123"
    }
    
    $response = Invoke-WebRequest -Uri $url -Headers $headers -Method GET -TimeoutSec 10 -ErrorAction Stop
    if ($response.Content -match "result") {
        Write-Status "SUCCESS" "Data exists in InfluxDB"
    } else {
        Write-Status "WARNING" "No data found in InfluxDB - check Node-RED flows"
        Write-Host "   💡 Try restarting Node-RED: docker restart iot-node-red" -ForegroundColor Gray
    }
} catch {
    Write-Status "WARNING" "Could not check InfluxDB data: $($_.Exception.Message)"
}

# Cleanup
Remove-Item "$env:TEMP\test_influxdb.js" -ErrorAction SilentlyContinue
Remove-Item "$env:TEMP\test_grafana_datasource.js" -ErrorAction SilentlyContinue

Write-Host ""
Write-Host "🎯 Next steps:" -ForegroundColor Yellow
Write-Host "1. If containers are not running: docker-compose up -d" -ForegroundColor White
Write-Host "2. If no data in InfluxDB: Check Node-RED flows and restart" -ForegroundColor White
Write-Host "3. If Grafana shows no data: Check data source configuration" -ForegroundColor White
Write-Host "4. Access Grafana at: http://localhost:3000 (admin/admin)" -ForegroundColor White
Write-Host "5. Access InfluxDB at: http://localhost:8086" -ForegroundColor White
Write-Host "6. Access Node-RED at: http://localhost:1880" -ForegroundColor White

Write-Status "SUCCESS" "Diagnostic completed!" 