# Renewable Energy Device Simulation Script for Windows PowerShell
# Simulates realistic data from renewable energy devices

param(
    [string]$Host = "localhost",
    [int]$Port = 1883,
    [string]$Username = "admin",
    [string]$Password = "admin_password_456",
    [int]$Interval = 5000,
    [int]$Duration = 0,  # 0 = run indefinitely
    [switch]$Photovoltaic,
    [switch]$WindTurbine,
    [switch]$BiogasPlant,
    [switch]$HeatBoiler,
    [switch]$EnergyStorage,
    [switch]$AllDevices
)

Write-Host "🌱 Renewable Energy Device Simulation" -ForegroundColor Cyan
Write-Host "=====================================" -ForegroundColor Cyan

# Check if Node.js is available
if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
    Write-Host "❌ Node.js is not installed or not in PATH" -ForegroundColor Red
    Write-Host "Please install Node.js from https://nodejs.org/" -ForegroundColor Yellow
    exit 1
}

# Check if MQTT package is installed
$mqttPackagePath = Join-Path $PSScriptRoot "node_modules\mqtt"
if (-not (Test-Path $mqttPackagePath)) {
    Write-Host "📦 Installing MQTT package..." -ForegroundColor Yellow
    Set-Location $PSScriptRoot
    npm install mqtt
    if ($LASTEXITCODE -ne 0) {
        Write-Host "❌ Failed to install MQTT package" -ForegroundColor Red
        exit 1
    }
}

# Device configuration
$devices = @()

if ($AllDevices -or $Photovoltaic) {
    $devices += @{ type = "photovoltaic"; count = 3; prefix = "pv" }
}
if ($AllDevices -or $WindTurbine) {
    $devices += @{ type = "wind_turbine"; count = 2; prefix = "wt" }
}
if ($AllDevices -or $BiogasPlant) {
    $devices += @{ type = "biogas_plant"; count = 2; prefix = "bg" }
}
if ($AllDevices -or $HeatBoiler) {
    $devices += @{ type = "heat_boiler"; count = 2; prefix = "hb" }
}
if ($AllDevices -or $EnergyStorage) {
    $devices += @{ type = "energy_storage"; count = 1; prefix = "es" }
}

if ($devices.Count -eq 0) {
    $devices = @(
        @{ type = "photovoltaic"; count = 3; prefix = "pv" },
        @{ type = "wind_turbine"; count = 2; prefix = "wt" },
        @{ type = "biogas_plant"; count = 2; prefix = "bg" },
        @{ type = "heat_boiler"; count = 2; prefix = "hb" },
        @{ type = "energy_storage"; count = 1; prefix = "es" }
    )
}

# Create simulation script
$simulationScript = @'
const mqtt = require('mqtt');

const config = {
    host: '$Host',
    port: $Port,
    username: '$Username',
    password: '$Password',
    interval: $Interval
};

const devices = $DevicesJson;

console.log('🔌 Connecting to MQTT broker at ' + config.host + ':' + config.port + '...');

const client = mqtt.connect('mqtt://' + config.host + ':' + config.port, {
    username: config.username,
    password: config.password,
    clean: true,
    reconnectPeriod: 5000,
    connectTimeout: 10000
});

let stats = {
    totalMessages: 0,
    deviceTypes: {},
    startTime: new Date()
};

// Utility functions
function addNoise(value, noiseLevel = 0.05) {
    const noise = (Math.random() - 0.5) * noiseLevel * 2;
    return value + noise;
}

function getSeasonalFactor() {
    const now = new Date();
    const hour = now.getHours();
    const dayOfYear = Math.floor((now - new Date(now.getFullYear(), 0, 0)) / (1000 * 60 * 60 * 24));
    
    // Solar seasonal variation (higher in summer, lower in winter)
    const solarFactor = 0.5 + 0.5 * Math.sin((dayOfYear - 172) * 2 * Math.PI / 365);
    
    // Daily variation (higher during day, lower at night)
    let dailyFactor = 0;
    if (hour >= 6 && hour <= 18) {
        dailyFactor = 0.3 + 0.7 * Math.sin((hour - 6) * Math.PI / 12);
    }
    
    return solarFactor * dailyFactor;
}

// Device simulation functions
function simulatePhotovoltaic(deviceId) {
    const timestamp = new Date().toISOString();
    const seasonalFactor = getSeasonalFactor();
    
    const irradiance = addNoise(850.5 * seasonalFactor, 0.1);
    const temperature = addNoise(25 + irradiance * 0.02, 0.05);
    const voltage = addNoise(48.3, 0.02);
    const current = addNoise(12.1 * seasonalFactor, 0.1);
    const powerOutput = voltage * current;
    
    const status = Math.random() < 0.01 ? 'fault' : 'operational';
    
    return {
        device_id: `pv_\${deviceId}`,
        device_type: 'photovoltaic',
        timestamp: timestamp,
        data: {
            irradiance: Math.round(irradiance * 100) / 100,
            temperature: Math.round(temperature * 100) / 100,
            voltage: Math.round(voltage * 100) / 100,
            current: Math.round(current * 100) / 100,
            power_output: Math.round(powerOutput * 100) / 100
        },
        status: status,
        location: 'site_a'
    };
}

function simulateWindTurbine(deviceId) {
    const timestamp = new Date().toISOString();
    
    const windSpeed = addNoise(8.5 + Math.random() * 4, 0.1);
    const windDirection = Math.random() * 360;
    const rotorSpeed = windSpeed * 1.5;
    const powerOutput = windSpeed > 3 ? Math.pow(windSpeed, 3) * 0.1 : 0;
    const temperature = addNoise(25, 0.05);
    
    const status = Math.random() < 0.01 ? 'fault' : 'operational';
    
    return {
        device_id: `wt_\${deviceId}`,
        device_type: 'wind_turbine',
        timestamp: timestamp,
        data: {
            wind_speed: Math.round(windSpeed * 100) / 100,
            wind_direction: Math.round(windDirection * 100) / 100,
            rotor_speed: Math.round(rotorSpeed * 100) / 100,
            power_output: Math.round(powerOutput * 100) / 100,
            temperature: Math.round(temperature * 100) / 100
        },
        status: status,
        location: 'site_b'
    };
}

function simulateBiogasPlant(deviceId) {
    const timestamp = new Date().toISOString();
    
    const gasFlowRate = addNoise(50 + (Math.random() - 0.5) * 20, 0.1);
    const methaneConcentration = addNoise(55 + Math.random() * 15, 0.05);
    const temperature = addNoise(35 + Math.random() * 10, 0.05);
    const pressure = addNoise(1.2 + Math.random() * 0.3, 0.02);
    const powerOutput = gasFlowRate * methaneConcentration * 0.01;
    
    const status = Math.random() < 0.01 ? 'fault' : 'operational';
    
    return {
        device_id: `bg_\${deviceId}`,
        device_type: 'biogas_plant',
        timestamp: timestamp,
        data: {
            gas_flow_rate: Math.round(gasFlowRate * 100) / 100,
            methane_concentration: Math.round(methaneConcentration * 100) / 100,
            temperature: Math.round(temperature * 100) / 100,
            pressure: Math.round(pressure * 100) / 100,
            power_output: Math.round(powerOutput * 100) / 100
        },
        status: status,
        location: 'site_c'
    };
}

function simulateHeatBoiler(deviceId) {
    const timestamp = new Date().toISOString();
    
    const temperature = addNoise(80 + Math.random() * 20, 0.05);
    const pressure = addNoise(2.5 + Math.random() * 0.5, 0.02);
    const fuelConsumption = addNoise(10 + Math.random() * 5, 0.1);
    const efficiency = addNoise(85 + Math.random() * 10, 0.02);
    const heatOutput = fuelConsumption * efficiency * 0.1;
    
    const status = Math.random() < 0.01 ? 'fault' : 'operational';
    
    return {
        device_id: `hb_\${deviceId}`,
        device_type: 'heat_boiler',
        timestamp: timestamp,
        data: {
            temperature: Math.round(temperature * 100) / 100,
            pressure: Math.round(pressure * 100) / 100,
            fuel_consumption: Math.round(fuelConsumption * 100) / 100,
            efficiency: Math.round(efficiency * 100) / 100,
            heat_output: Math.round(heatOutput * 100) / 100
        },
        status: status,
        location: 'site_d'
    };
}

function simulateEnergyStorage(deviceId) {
    const timestamp = new Date().toISOString();
    
    const stateOfCharge = addNoise(60 + (Math.random() - 0.5) * 20, 0.02);
    const voltage = 400 + stateOfCharge * 2;
    const current = addNoise((Math.random() - 0.5) * 100, 0.1);
    const temperature = addNoise(25 + Math.random() * 10, 0.05);
    const cycleCount = Math.floor(Math.random() * 1000);
    const power = voltage * current / 1000;
    
    const status = Math.random() < 0.01 ? 'fault' : 'operational';
    
    return {
        device_id: `es_\${deviceId}`,
        device_type: 'energy_storage',
        timestamp: timestamp,
        data: {
            state_of_charge: Math.round(stateOfCharge * 100) / 100,
            voltage: Math.round(voltage * 100) / 100,
            current: Math.round(current * 100) / 100,
            temperature: Math.round(temperature * 100) / 100,
            cycle_count: cycleCount,
            power: Math.round(power * 100) / 100
        },
        status: status,
        location: 'site_e'
    };
}

const simulationFunctions = {
    photovoltaic: simulatePhotovoltaic,
    wind_turbine: simulateWindTurbine,
    biogas_plant: simulateBiogasPlant,
    heat_boiler: simulateHeatBoiler,
    energy_storage: simulateEnergyStorage
};

client.on('connect', () => {
    console.log('✅ Connected to MQTT broker');
    console.log('🚀 Starting device simulation...');
    console.log(`📊 Simulating \${devices.reduce((sum, d) => sum + d.count, 0)} devices`);
    console.log(`⏱️  Interval: \${config.interval}ms`);
    console.log('');
    
    // Start simulation
    const intervalId = setInterval(() => {
        devices.forEach(device => {
            for (let i = 1; i <= device.count; i++) {
                const data = simulationFunctions[device.type](i);
                const topic = `devices/\${device.type}/\${data.device_id}/telemetry`;
                
                client.publish(topic, JSON.stringify(data), { qos: 1 }, (err) => {
                    if (err) {
                        console.error(`❌ Failed to publish \${device.type} data:`, err.message);
                    } else {
                        stats.totalMessages++;
                        if (!stats.deviceTypes[device.type]) {
                            stats.deviceTypes[device.type] = 0;
                        }
                        stats.deviceTypes[device.type]++;
                        
                        const powerKey = device.type === 'photovoltaic' ? 'power_output' :
                                        device.type === 'wind_turbine' ? 'power_output' :
                                        device.type === 'biogas_plant' ? 'power_output' :
                                        device.type === 'heat_boiler' ? 'heat_output' : 'power';
                        
                        console.log(`📤 [\${new Date().toISOString()}] \${data.device_id}: \${data.data[powerKey]}kW (\${data.status})`);
                    }
                });
            }
        });
    }, config.interval);
    
    // Stop simulation after duration (if specified)
    if ($Duration -gt 0) {
        setTimeout(() => {
            clearInterval(intervalId);
            console.log('\\n📊 Final Statistics:');
            console.log(`   Total Messages: \${stats.totalMessages}`);
            console.log(`   Duration: \${Math.round((new Date() - stats.startTime) / 1000)}s`);
            console.log('\\n   Device Types:');
            Object.entries(stats.deviceTypes).forEach(([type, count]) => {
                console.log(`     \${type}: \${count} messages`);
            });
            client.end();
            process.exit(0);
        }, $Duration * 1000);
    }
    
    // Handle Ctrl+C
    process.on('SIGINT', () => {
        clearInterval(intervalId);
        console.log('\\n📊 Final Statistics:');
        console.log(`   Total Messages: \${stats.totalMessages}`);
        console.log(`   Duration: \${Math.round((new Date() - stats.startTime) / 1000)}s`);
        console.log('\\n   Device Types:');
        Object.entries(stats.deviceTypes).forEach(([type, count]) => {
            console.log(`     \${type}: \${count} messages`);
        });
        console.log('\\n👋 Stopping simulation...');
        client.end();
        process.exit(0);
    });
});

client.on('error', (error) => {
    console.error('❌ MQTT Error:', error.message);
    process.exit(1);
});

client.on('close', () => {
    console.log('🔌 MQTT connection closed');
});

// Periodic statistics
setInterval(() => {
    const duration = Math.round((new Date() - stats.startTime) / 1000);
    const rate = duration > 0 ? (stats.totalMessages / duration).toFixed(2) : 0;
    console.log(`📈 Stats: \${stats.totalMessages} messages, \${rate} msg/s`);
}, 30000);
'@

# Convert devices to JSON and replace variables
$devicesJson = $devices | ConvertTo-Json -Depth 10

# Replace PowerShell variables in the JavaScript code
$simulationScript = $simulationScript -replace '\$Host', $Host
$simulationScript = $simulationScript -replace '\$Port', $Port
$simulationScript = $simulationScript -replace '\$Username', $Username
$simulationScript = $simulationScript -replace '\$Password', $Password
$simulationScript = $simulationScript -replace '\$Interval', $Interval
$simulationScript = $simulationScript -replace '\$Duration', $Duration
$simulationScript = $simulationScript -replace '\$DevicesJson', $devicesJson

# Write simulation script to temporary file
$tempScriptPath = Join-Path $PSScriptRoot "temp-simulation.js"
$simulationScript | Out-File -FilePath $tempScriptPath -Encoding UTF8

try {
    Write-Host "🚀 Starting device simulation..." -ForegroundColor Green
    Write-Host "Press Ctrl+C to stop" -ForegroundColor Yellow
    Set-Location $PSScriptRoot
    node $tempScriptPath
} catch {
    Write-Host "❌ Error running simulation: $_" -ForegroundColor Red
} finally {
    # Clean up temporary file
    if (Test-Path $tempScriptPath) {
        Remove-Item $tempScriptPath -Force
    }
}

Write-Host "`n📋 Usage Examples:" -ForegroundColor Cyan
Write-Host "  .\simulate-devices.ps1 -AllDevices" -ForegroundColor White
Write-Host "  .\simulate-devices.ps1 -Photovoltaic -WindTurbine" -ForegroundColor White
Write-Host "  .\simulate-devices.ps1 -Interval 2000 -Duration 60" -ForegroundColor White
Write-Host "  .\simulate-devices.ps1 -Host '192.168.1.100' -Port 1883" -ForegroundColor White 