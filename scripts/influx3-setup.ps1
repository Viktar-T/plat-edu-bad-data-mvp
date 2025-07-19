# InfluxDB 3.x Setup Script for Renewable Energy Monitoring System (PowerShell)
# This script initializes databases, creates tokens, and validates schema

param(
    [string]$InfluxDBHost = "localhost",
    [int]$InfluxDBPort = 8086,
    [string]$AdminToken = $env:INFLUXDB3_ADMIN_TOKEN,
    [string]$Organization = $env:INFLUXDB3_ORG
)

# Configuration
$InfluxDBUrl = "http://${InfluxDBHost}:${InfluxDBPort}"

# Colors for output
$Red = "Red"
$Green = "Green"
$Yellow = "Yellow"
$Blue = "Blue"

# Logging functions
function Write-Info {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor $Blue
}

function Write-Success {
    param([string]$Message)
    Write-Host "[SUCCESS] $Message" -ForegroundColor $Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host "[WARNING] $Message" -ForegroundColor $Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor $Red
}

# Wait for InfluxDB to be ready
function Wait-ForInfluxDB {
    Write-Info "Waiting for InfluxDB to be ready..."
    $maxAttempts = 30
    $attempt = 1
    
    while ($attempt -le $maxAttempts) {
        try {
            $response = Invoke-WebRequest -Uri "$InfluxDBUrl/health" -Method GET -TimeoutSec 5 -ErrorAction Stop
            if ($response.StatusCode -eq 200) {
                Write-Success "InfluxDB is ready!"
                return $true
            }
        }
        catch {
            # Continue to next attempt
        }
        
        Write-Info "Attempt $attempt/$maxAttempts - InfluxDB not ready yet, waiting..."
        Start-Sleep -Seconds 2
        $attempt++
    }
    
    Write-Error "InfluxDB failed to start within expected time"
    return $false
}

# Create database
function New-InfluxDBDatabase {
    param(
        [string]$DatabaseName,
        [int]$RetentionDays,
        [string]$Description
    )
    
    Write-Info "Creating database: $DatabaseName"
    
    $body = @{
        name = $DatabaseName
        description = $Description
        retention_days = $RetentionDays
    } | ConvertTo-Json
    
    $headers = @{
        "Authorization" = "Bearer $AdminToken"
        "Content-Type" = "application/json"
    }
    
    try {
        $response = Invoke-WebRequest -Uri "$InfluxDBUrl/api/v3/configure/database" -Method POST -Body $body -Headers $headers -ErrorAction Stop
        
        if ($response.StatusCode -eq 201 -or $response.StatusCode -eq 409) {
            Write-Success "Database '$DatabaseName' created successfully (HTTP: $($response.StatusCode))"
            return $true
        }
        else {
            Write-Error "Failed to create database '$DatabaseName' (HTTP: $($response.StatusCode))"
            return $false
        }
    }
    catch {
        Write-Error "Failed to create database '$DatabaseName': $($_.Exception.Message)"
        return $false
    }
}

# Create table schema
function New-InfluxDBTable {
    param(
        [string]$DatabaseName,
        [string]$TableName,
        [string]$SchemaFile
    )
    
    Write-Info "Creating table schema: $TableName in database: $DatabaseName"
    
    if (-not (Test-Path $SchemaFile)) {
        Write-Warning "Schema file not found: $SchemaFile, skipping table creation"
        return $true
    }
    
    $schema = Get-Content $SchemaFile -Raw
    
    $headers = @{
        "Authorization" = "Bearer $AdminToken"
        "Content-Type" = "application/json"
    }
    
    try {
        $response = Invoke-WebRequest -Uri "$InfluxDBUrl/api/v3/configure/database/$DatabaseName/table" -Method POST -Body $schema -Headers $headers -ErrorAction Stop
        
        if ($response.StatusCode -eq 201 -or $response.StatusCode -eq 409) {
            Write-Success "Table '$TableName' created successfully (HTTP: $($response.StatusCode))"
            return $true
        }
        else {
            Write-Error "Failed to create table '$TableName' (HTTP: $($response.StatusCode))"
            return $false
        }
    }
    catch {
        Write-Error "Failed to create table '$TableName': $($_.Exception.Message)"
        return $false
    }
}

# Create token
function New-InfluxDBToken {
    param(
        [string]$TokenName,
        [string]$Description,
        [string]$Permissions
    )
    
    Write-Info "Creating token: $TokenName"
    
    $body = @{
        name = $TokenName
        description = $Description
        permissions = $Permissions | ConvertFrom-Json
    } | ConvertTo-Json -Depth 10
    
    $headers = @{
        "Authorization" = "Bearer $AdminToken"
        "Content-Type" = "application/json"
    }
    
    try {
        $response = Invoke-WebRequest -Uri "$InfluxDBUrl/api/v3/configure/token" -Method POST -Body $body -Headers $headers -ErrorAction Stop
        
        if ($response.StatusCode -eq 201) {
            $responseData = $response.Content | ConvertFrom-Json
            if ($responseData.token) {
                Write-Success "Token '$TokenName' created successfully"
                $responseData.token | Out-File -FilePath "$env:TEMP\influxdb3_${TokenName}_token.txt" -Encoding UTF8
                Write-Info "Token saved to $env:TEMP\influxdb3_${TokenName}_token.txt"
            }
            else {
                Write-Warning "Token created but could not extract token value"
            }
            return $true
        }
        elseif ($response.StatusCode -eq 409) {
            Write-Warning "Token '$TokenName' already exists"
            return $true
        }
        else {
            Write-Error "Failed to create token '$TokenName' (HTTP: $($response.StatusCode))"
            return $false
        }
    }
    catch {
        Write-Error "Failed to create token '$TokenName': $($_.Exception.Message)"
        return $false
    }
}

# Validate database schema
function Test-InfluxDBSchema {
    param([string]$DatabaseName)
    
    Write-Info "Validating schema for database: $DatabaseName"
    
    $headers = @{
        "Authorization" = "Bearer $AdminToken"
    }
    
    try {
        $response = Invoke-WebRequest -Uri "$InfluxDBUrl/api/v3/configure/database/$DatabaseName/table" -Method GET -Headers $headers -ErrorAction Stop
        
        if ($response.StatusCode -eq 200) {
            $responseData = $response.Content | ConvertFrom-Json
            $tableCount = $responseData.tables.Count
            Write-Success "Database '$DatabaseName' validation successful - found $tableCount tables"
            
            foreach ($table in $responseData.tables) {
                Write-Info "  - Table: $($table.name)"
            }
            return $true
        }
        else {
            Write-Error "Failed to validate database '$DatabaseName' (HTTP: $($response.StatusCode))"
            return $false
        }
    }
    catch {
        Write-Error "Failed to validate database '$DatabaseName': $($_.Exception.Message)"
        return $false
    }
}

# Test data insertion
function Test-InfluxDBDataInsertion {
    param(
        [string]$DatabaseName,
        [string]$TestToken
    )
    
    Write-Info "Testing data insertion for database: $DatabaseName"
    
    $testData = @{
        timestamp = (Get-Date).ToUniversalTime().ToString("yyyy-MM-ddTHH:mm:ssZ")
        device_id = "test_pv_001"
        location = "test_site"
        device_type = "photovoltaic"
        status = "operational"
        power_output = 584.43
        voltage = 48.3
        current = 12.1
        temperature = 45.2
        irradiance = 850.5
        efficiency = 18.5
    } | ConvertTo-Json
    
    $headers = @{
        "Authorization" = "Bearer $TestToken"
        "Content-Type" = "application/json"
    }
    
    try {
        $response = Invoke-WebRequest -Uri "$InfluxDBUrl/api/v3/write/$DatabaseName/photovoltaic_data" -Method POST -Body $testData -Headers $headers -ErrorAction Stop
        
        if ($response.StatusCode -eq 204) {
            Write-Success "Test data insertion successful"
            return $true
        }
        else {
            Write-Error "Test data insertion failed (HTTP: $($response.StatusCode))"
            return $false
        }
    }
    catch {
        Write-Error "Test data insertion failed: $($_.Exception.Message)"
        return $false
    }
}

# Main setup function
function Start-InfluxDBSetup {
    Write-Info "Starting InfluxDB 3.x setup for Renewable Energy Monitoring System"
    
    # Wait for InfluxDB to be ready
    if (-not (Wait-ForInfluxDB)) {
        return $false
    }
    
    # Create databases
    Write-Info "Creating databases..."
    New-InfluxDBDatabase -DatabaseName "renewable-energy-monitoring" -RetentionDays 10 -Description "Primary database for renewable energy device data"
    New-InfluxDBDatabase -DatabaseName "sensor-data" -RetentionDays 7 -Description "Raw sensor data from all devices"
    New-InfluxDBDatabase -DatabaseName "alerts" -RetentionDays 30 -Description "System alerts and notifications"
    New-InfluxDBDatabase -DatabaseName "system-metrics" -RetentionDays 15 -Description "System performance and health metrics"
    
    # Create application token with permissions
    $appPermissions = @(
        @{
            database = "renewable-energy-monitoring"
            permissions = @("READ", "WRITE")
        },
        @{
            database = "sensor-data"
            permissions = @("READ", "WRITE")
        },
        @{
            database = "alerts"
            permissions = @("READ", "WRITE")
        },
        @{
            database = "system-metrics"
            permissions = @("READ", "WRITE")
        }
    ) | ConvertTo-Json
    
    New-InfluxDBToken -TokenName "application-token" -Description "Application token for data ingestion and queries" -Permissions $appPermissions
    
    # Create read-only token
    $readPermissions = @(
        @{
            database = "renewable-energy-monitoring"
            permissions = @("READ")
        },
        @{
            database = "sensor-data"
            permissions = @("READ")
        },
        @{
            database = "alerts"
            permissions = @("READ")
        },
        @{
            database = "system-metrics"
            permissions = @("READ")
        }
    ) | ConvertTo-Json
    
    New-InfluxDBToken -TokenName "read-only-token" -Description "Read-only token for dashboards and analytics" -Permissions $readPermissions
    
    # Create table schemas
    Write-Info "Creating table schemas..."
    $schemaDir = "..\influxdb\config\schemas"
    
    # Renewable energy monitoring database tables
    New-InfluxDBTable -DatabaseName "renewable-energy-monitoring" -TableName "photovoltaic_data" -SchemaFile "$schemaDir\photovoltaic_data.json"
    New-InfluxDBTable -DatabaseName "renewable-energy-monitoring" -TableName "wind_turbine_data" -SchemaFile "$schemaDir\wind_turbine_data.json"
    New-InfluxDBTable -DatabaseName "renewable-energy-monitoring" -TableName "biogas_plant_data" -SchemaFile "$schemaDir\biogas_plant_data.json"
    New-InfluxDBTable -DatabaseName "renewable-energy-monitoring" -TableName "heat_boiler_data" -SchemaFile "$schemaDir\heat_boiler_data.json"
    New-InfluxDBTable -DatabaseName "renewable-energy-monitoring" -TableName "energy_storage_data" -SchemaFile "$schemaDir\energy_storage_data.json"
    New-InfluxDBTable -DatabaseName "renewable-energy-monitoring" -TableName "laboratory_equipment_data" -SchemaFile "$schemaDir\laboratory_equipment_data.json"
    
    # Validate schemas
    Write-Info "Validating database schemas..."
    Test-InfluxDBSchema -DatabaseName "renewable-energy-monitoring"
    Test-InfluxDBSchema -DatabaseName "sensor-data"
    Test-InfluxDBSchema -DatabaseName "alerts"
    Test-InfluxDBSchema -DatabaseName "system-metrics"
    
    # Test data insertion if application token exists
    $tokenFile = "$env:TEMP\influxdb3_application-token_token.txt"
    if (Test-Path $tokenFile) {
        $testToken = Get-Content $tokenFile -Raw
        Test-InfluxDBDataInsertion -DatabaseName "renewable-energy-monitoring" -TestToken $testToken.Trim()
    }
    
    Write-Success "InfluxDB 3.x setup completed successfully!"
    
    # Display summary
    Write-Host ""
    Write-Info "Setup Summary:"
    Write-Info "  - Databases created: renewable-energy-monitoring, sensor-data, alerts, system-metrics"
    Write-Info "  - Tokens created: application-token, read-only-token"
    Write-Info "  - Token files saved to $env:TEMP\influxdb3_*_token.txt"
    Write-Host ""
    Write-Info "Next steps:"
    Write-Info "  1. Update your application configuration with the generated tokens"
    Write-Info "  2. Configure Node-RED flows to use the new InfluxDB 3.x endpoints"
    Write-Info "  3. Update Grafana data sources to use InfluxDB 3.x"
    Write-Info "  4. Test data ingestion and querying"
    
    return $true
}

# Run main setup function
if (-not $AdminToken) {
    Write-Error "INFLUXDB3_ADMIN_TOKEN environment variable is required"
    exit 1
}

Start-InfluxDBSetup 