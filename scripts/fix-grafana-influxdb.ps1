# =============================================================================
# Grafana-InfluxDB Connection Fix Script (PowerShell)
# Renewable Energy IoT Monitoring System
# =============================================================================

param(
    [switch]$Force,
    [switch]$Verbose
)

# Set error action preference
$ErrorActionPreference = "Continue"

Write-Host "🔧 Starting Grafana-InfluxDB Connection Fix..." -ForegroundColor Cyan
Write-Host "=============================================" -ForegroundColor Cyan

# Function to print colored output
function Write-Status {
    param(
        [string]$Status,
        [string]$Message
    )
    
    switch ($Status) {
        "SUCCESS" { Write-Host "✅ $Message" -ForegroundColor Green }
        "ERROR" { Write-Host "❌ $Message" -ForegroundColor Red }
        "WARNING" { Write-Host "⚠️  $Message" -ForegroundColor Yellow }
        "INFO" { Write-Host "ℹ️  $Message" -ForegroundColor Blue }
    }
}

# Function to check if containers are running
function Test-ContainerRunning {
    param([string]$ContainerName)
    
    $running = docker ps --format "table {{.Names}}" 2>$null | Select-String "^$ContainerName$"
    return [bool]$running
}

# Function to restart container
function Restart-Container {
    param([string]$ContainerName)
    
    Write-Status "INFO" "Restarting container: $ContainerName"
    docker restart $ContainerName 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Status "SUCCESS" "Container $ContainerName restarted successfully"
        Start-Sleep -Seconds 10
    } else {
        Write-Status "ERROR" "Failed to restart container $ContainerName"
    }
}

# Step 1: Check and restart containers if needed
Write-Host "1. Checking and fixing container status..." -ForegroundColor White

$containers = @{
    "iot-mosquitto" = "MQTT Broker"
    "iot-influxdb2" = "InfluxDB Database"
    "iot-node-red" = "Node-RED Processing"
    "iot-grafana" = "Grafana Visualization"
}

foreach ($container in $containers.GetEnumerator()) {
    if (Test-ContainerRunning $container.Key) {
        Write-Status "SUCCESS" "$($container.Value) ($($container.Key)) is running"
    } else {
        Write-Status "WARNING" "$($container.Value) ($($container.Key)) is not running"
        if ($Force -or (Read-Host "Restart $($container.Value)? (y/N)") -eq "y") {
            Restart-Container $container.Key
        }
    }
}

# Step 2: Fix InfluxDB configuration
Write-Host "2. Checking and fixing InfluxDB configuration..." -ForegroundColor White

# Check if InfluxDB is accessible
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8086/health" -Method GET -TimeoutSec 10 -ErrorAction Stop
    if ($response.StatusCode -eq 200) {
        Write-Status "SUCCESS" "InfluxDB is healthy"
    } else {
        Write-Status "ERROR" "InfluxDB returned status code: $($response.StatusCode)"
    }
} catch {
    Write-Status "ERROR" "InfluxDB is not responding: $($_.Exception.Message)"
    Write-Status "INFO" "Attempting to restart InfluxDB..."
    Restart-Container "iot-influxdb2"
}

# Step 3: Fix Grafana configuration
Write-Host "3. Checking and fixing Grafana configuration..." -ForegroundColor White

# Check if Grafana is accessible
try {
    $response = Invoke-WebRequest -Uri "http://localhost:3000/api/health" -Method GET -TimeoutSec 10 -ErrorAction Stop
    if ($response.StatusCode -eq 200) {
        Write-Status "SUCCESS" "Grafana is healthy"
    } else {
        Write-Status "ERROR" "Grafana returned status code: $($response.StatusCode)"
    }
} catch {
    Write-Status "ERROR" "Grafana is not responding: $($_.Exception.Message)"
    Write-Status "INFO" "Attempting to restart Grafana..."
    Restart-Container "iot-grafana"
}

# Step 4: Fix Grafana data source configuration
Write-Host "4. Fixing Grafana data source configuration..." -ForegroundColor White

# Create a script to fix Grafana data source
$fixDataSourceScript = @"
const https = require('http');

async function fixGrafanaDataSource() {
    try {
        const baseURL = 'http://localhost:3000';
        const auth = {
            username: 'admin',
            password: 'admin'
        };
        
        // Get existing data sources
        const getOptions = {
            hostname: 'localhost',
            port: 3000,
            path: '/api/datasources',
            method: 'GET',
            headers: {
                'Authorization': 'Basic ' + Buffer.from('admin:admin').toString('base64'),
                'Content-Type': 'application/json'
            }
        };

        const req = https.request(getOptions, (res) => {
            let data = '';
            res.on('data', (chunk) => {
                data += chunk;
            });
            res.on('end', () => {
                try {
                    const datasources = JSON.parse(data);
                    const influxDS = datasources.find(ds => ds.type === 'influxdb');
                    
                    if (influxDS) {
                        console.log('✅ InfluxDB data source found, checking configuration...');
                        
                        // Check if configuration is correct
                        const isCorrect = influxDS.url === 'http://influxdb:8086' &&
                                        influxDS.jsonData?.organization === 'renewable_energy_org' &&
                                        influxDS.jsonData?.defaultBucket === 'renewable_energy';
                        
                        if (isCorrect) {
                            console.log('✅ Data source configuration is correct');
                        } else {
                            console.log('⚠️  Data source configuration needs updating');
                            
                            // Update the data source
                            const updateData = {
                                name: 'InfluxDB 2.x',
                                type: 'influxdb',
                                access: 'proxy',
                                url: 'http://influxdb:8086',
                                isDefault: true,
                                editable: true,
                                jsonData: {
                                    version: 'Flux',
                                    organization: 'renewable_energy_org',
                                    defaultBucket: 'renewable_energy',
                                    tlsSkipVerify: true
                                },
                                secureJsonData: {
                                    token: 'renewable_energy_admin_token_123'
                                }
                            };
                            
                            const updateOptions = {
                                hostname: 'localhost',
                                port: 3000,
                                path: \`/api/datasources/\${influxDS.id}\`,
                                method: 'PUT',
                                headers: {
                                    'Authorization': 'Basic ' + Buffer.from('admin:admin').toString('base64'),
                                    'Content-Type': 'application/json'
                                }
                            };
                            
                            const updateReq = https.request(updateOptions, (updateRes) => {
                                let updateData = '';
                                updateRes.on('data', (chunk) => {
                                    updateData += chunk;
                                });
                                updateRes.on('end', () => {
                                    if (updateRes.statusCode === 200) {
                                        console.log('✅ Data source updated successfully');
                                    } else {
                                        console.log('❌ Failed to update data source:', updateRes.statusCode);
                                    }
                                });
                            });
                            
                            updateReq.on('error', (error) => {
                                console.error('❌ Error updating data source:', error.message);
                            });
                            
                            updateReq.write(JSON.stringify(updateData));
                            updateReq.end();
                        }
                    } else {
                        console.log('❌ InfluxDB data source not found, creating new one...');
                        
                        // Create new data source
                        const createData = {
                            name: 'InfluxDB 2.x',
                            type: 'influxdb',
                            access: 'proxy',
                            url: 'http://influxdb:8086',
                            isDefault: true,
                            editable: true,
                            jsonData: {
                                version: 'Flux',
                                organization: 'renewable_energy_org',
                                defaultBucket: 'renewable_energy',
                                tlsSkipVerify: true
                            },
                            secureJsonData: {
                                token: 'renewable_energy_admin_token_123'
                            }
                        };
                        
                        const createOptions = {
                            hostname: 'localhost',
                            port: 3000,
                            path: '/api/datasources',
                            method: 'POST',
                            headers: {
                                'Authorization': 'Basic ' + Buffer.from('admin:admin').toString('base64'),
                                'Content-Type': 'application/json'
                            }
                        };
                        
                        const createReq = https.request(createOptions, (createRes) => {
                            let createResponseData = '';
                            createRes.on('data', (chunk) => {
                                createResponseData += chunk;
                            });
                            createRes.on('end', () => {
                                if (createRes.statusCode === 200) {
                                    console.log('✅ Data source created successfully');
                                } else {
                                    console.log('❌ Failed to create data source:', createRes.statusCode);
                                }
                            });
                        });
                        
                        createReq.on('error', (error) => {
                            console.error('❌ Error creating data source:', error.message);
                        });
                        
                        createReq.write(JSON.stringify(createData));
                        createReq.end();
                    }
                } catch (error) {
                    console.error('❌ Failed to parse response:', error.message);
                }
            });
        });

        req.on('error', (error) => {
            console.error('❌ Grafana API request failed:', error.message);
        });

        req.end();
    } catch (error) {
        console.error('❌ Error fixing Grafana data source:', error.message);
    }
}

fixGrafanaDataSource();
"@

$fixDataSourceScript | Out-File -FilePath "$env:TEMP\fix_grafana_datasource.js" -Encoding UTF8

# Run the fix script
try {
    $result = node "$env:TEMP\fix_grafana_datasource.js" 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Status "SUCCESS" "Grafana data source configuration fixed"
        if ($Verbose) { Write-Host $result -ForegroundColor Gray }
    } else {
        Write-Status "ERROR" "Failed to fix Grafana data source configuration"
    }
} catch {
    Write-Status "ERROR" "Failed to run Grafana data source fix: $($_.Exception.Message)"
}

# Step 5: Check and fix Node-RED flows
Write-Host "5. Checking Node-RED flows..." -ForegroundColor White

if (Test-ContainerRunning "iot-node-red") {
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:1880" -Method GET -TimeoutSec 10 -ErrorAction Stop
        if ($response.StatusCode -eq 200) {
            Write-Status "SUCCESS" "Node-RED is accessible"
        } else {
            Write-Status "ERROR" "Node-RED returned status code: $($response.StatusCode)"
        }
    } catch {
        Write-Status "ERROR" "Node-RED is not responding: $($_.Exception.Message)"
        Write-Status "INFO" "Attempting to restart Node-RED..."
        Restart-Container "iot-node-red"
    }
} else {
    Write-Status "WARNING" "Node-RED is not running"
}

# Step 6: Verify data flow
Write-Host "6. Verifying data flow..." -ForegroundColor White

# Wait a moment for services to stabilize
Start-Sleep -Seconds 5

# Check if data exists in InfluxDB
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
        Write-Status "WARNING" "No data found in InfluxDB"
        Write-Status "INFO" "This might be normal if Node-RED flows haven't started yet"
        Write-Status "INFO" "Check Node-RED at http://localhost:1880 to verify flows are running"
    }
} catch {
    Write-Status "WARNING" "Could not verify InfluxDB data: $($_.Exception.Message)"
}

# Step 7: Test Grafana-InfluxDB connection
Write-Host "7. Testing Grafana-InfluxDB connection..." -ForegroundColor White

$testConnectionScript = @"
const https = require('http');

async function testGrafanaInfluxDBConnection() {
    try {
        const options = {
            hostname: 'localhost',
            port: 3000,
            path: '/api/datasources/proxy/1/query?org=renewable_energy_org&q=from(bucket:"renewable_energy")|>range(start:-1h)|>limit(n:1)',
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
                if (res.statusCode === 200) {
                    console.log('✅ Grafana-InfluxDB connection successful');
                    if (data.includes('result')) {
                        console.log('📊 Data query returned results');
                    } else {
                        console.log('⚠️  Data query returned no results (this might be normal)');
                    }
                } else {
                    console.log('❌ Grafana-InfluxDB connection failed:', res.statusCode);
                }
            });
        });

        req.on('error', (error) => {
            console.error('❌ Connection test failed:', error.message);
        });

        req.end();
    } catch (error) {
        console.error('❌ Error testing connection:', error.message);
    }
}

testGrafanaInfluxDBConnection();
"@

$testConnectionScript | Out-File -FilePath "$env:TEMP\test_connection.js" -Encoding UTF8

# Run the connection test
try {
    $result = node "$env:TEMP\test_connection.js" 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Status "SUCCESS" "Grafana-InfluxDB connection test completed"
        if ($Verbose) { Write-Host $result -ForegroundColor Gray }
    } else {
        Write-Status "ERROR" "Grafana-InfluxDB connection test failed"
    }
} catch {
    Write-Status "ERROR" "Failed to run connection test: $($_.Exception.Message)"
}

# Cleanup
Remove-Item "$env:TEMP\fix_grafana_datasource.js" -ErrorAction SilentlyContinue
Remove-Item "$env:TEMP\test_connection.js" -ErrorAction SilentlyContinue

Write-Host ""
Write-Host "=============================================" -ForegroundColor Cyan
Write-Host "🎯 Fix completed! Next steps:" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. Access Grafana at: http://localhost:3000 (admin/admin)" -ForegroundColor White
Write-Host "2. Check if dashboards are loading data" -ForegroundColor White
Write-Host "3. If no data, check Node-RED flows at: http://localhost:1880" -ForegroundColor White
Write-Host "4. Verify data in InfluxDB at: http://localhost:8086" -ForegroundColor White
Write-Host ""
Write-Host "💡 Common troubleshooting:" -ForegroundColor Yellow
Write-Host "   - If dashboards show no data, check the time range" -ForegroundColor Gray
Write-Host "   - If Node-RED flows aren't running, deploy them" -ForegroundColor Gray
Write-Host "   - If data source shows errors, check the token and organization" -ForegroundColor Gray

Write-Status "SUCCESS" "Fix script completed!" 