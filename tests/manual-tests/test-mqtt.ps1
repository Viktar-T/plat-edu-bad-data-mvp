# MQTT Test Script for Windows PowerShell
# Tests MQTT communication using Node.js

param(
    [string]$MqttHost = "localhost",
    [int]$Port = 1883,
    [switch]$PublishTest,
    [switch]$Subscribe,
    [string]$Topic = "test/mqtt",
    [string]$Message = "Hello from PowerShell!"
)

Write-Host "MQTT Test Script for Windows" -ForegroundColor Cyan
Write-Host "============================" -ForegroundColor Cyan

# Check if Node.js is available
if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
    Write-Host "ERROR: Node.js is not installed or not in PATH" -ForegroundColor Red
    Write-Host "Please install Node.js from https://nodejs.org/" -ForegroundColor Yellow
    exit 1
}

# Check if MQTT package is installed
$mqttPackagePath = Join-Path $PSScriptRoot "node_modules\mqtt"
if (-not (Test-Path $mqttPackagePath)) {
    Write-Host "Installing MQTT package..." -ForegroundColor Yellow
    Set-Location $PSScriptRoot
    npm install mqtt
    if ($LASTEXITCODE -ne 0) {
        Write-Host "ERROR: Failed to install MQTT package" -ForegroundColor Red
        exit 1
    }
}

# Prepare JS booleans for injection
$publishTestJs = if ($PublishTest.IsPresent) { 'true' } else { 'false' }
$subscribeJs = if ($Subscribe.IsPresent) { 'true' } else { 'false' }

# Build JavaScript content line by line to avoid PowerShell string interpolation issues
$jsLines = @(
    "const mqtt = require('mqtt');",
    "",
    "const config = {",
    "    host: '$MqttHost',",
    "    port: $Port,",
    "    clientId: 'powershell-test-' + Math.random().toString(16).substr(2, 8)",
    "};",
    "",
    "console.log('Connecting to MQTT broker at ' + config.host + ':' + config.port + '...');",
    "",
    "const client = mqtt.connect('mqtt://' + config.host + ':' + config.port, {",
    "    clientId: config.clientId,",
    "    clean: true,",
    "    connectTimeout: 10000",
    "});",
    "",
    "client.on('connect', () => {",
    "    console.log('Connected to MQTT broker');",
    "    ",
    "    const publishTest = $publishTestJs;",
    "    const subscribe = $subscribeJs;",
    "    const topic = '$Topic';",
    "    const message = '$Message';",
    "    ",
    "    if (publishTest) {",
    "        const testMessage = {",
    "            timestamp: new Date().toISOString(),",
    "            message: message,",
    "            source: 'PowerShell Test Script'",
    "        };",
    "        ",
    "        client.publish(topic, JSON.stringify(testMessage), { qos: 1 }, (err) => {",
    "            if (err) {",
    "                console.error('Failed to publish message:', err.message);",
    "                process.exit(1);",
    "            } else {",
    "                console.log('Published test message to ' + topic);",
    "                console.log('Message:', JSON.stringify(testMessage, null, 2));",
    "            }",
    "            ",
    "            setTimeout(() => {",
    "                client.end();",
    "                process.exit(0);",
    "            }, 1000);",
    "        });",
    "    }",
    "    ",
    "    if (subscribe) {",
    "        console.log('Subscribing to ' + topic + '...');",
    "        client.subscribe(topic, (err) => {",
    "            if (err) {",
    "                console.error('Failed to subscribe:', err.message);",
    "                process.exit(1);",
    "            } else {",
    "                console.log('Subscribed to ' + topic);",
    "                console.log('Waiting for messages... (Press Ctrl+C to stop)');",
    "            }",
    "        });",
    "    }",
    "    ",
    "    if (!publishTest && !subscribe) {",
    "        console.log('Connection test completed');",
    "        setTimeout(() => {",
    "            client.end();",
    "            process.exit(0);",
    "        }, 5000);",
    "    }",
    "});",
    "",
    "client.on('message', (topic, message) => {",
    "    try {",
    "        const data = JSON.parse(message.toString());",
    "        console.log('Received message:');",
    "        console.log('   Topic:', topic);",
    "        console.log('   Data:', JSON.stringify(data, null, 2));",
    "    } catch (error) {",
    "        console.log('Received message:');",
    "        console.log('   Topic:', topic);",
    "        console.log('   Raw:', message.toString());",
    "    }",
    "});",
    "",
    "client.on('error', (error) => {",
    "    console.error('MQTT Error:', error.message);",
    "    process.exit(1);",
    "});",
    "",
    "client.on('close', () => {",
    "    console.log('Connection closed');",
    "});",
    "",
    "process.on('SIGINT', () => {",
    "    console.log('Disconnecting...');",
    "    client.end();",
    "    process.exit(0);",
    "});"
)

# Write JavaScript content to temporary file
$tempScriptPath = Join-Path $PSScriptRoot "temp-mqtt-test.js"
$jsLines | Out-File -FilePath $tempScriptPath -Encoding UTF8

try {
    Write-Host "Running MQTT test..." -ForegroundColor Green
    Set-Location $PSScriptRoot
    node $tempScriptPath
} catch {
    Write-Host "Error running MQTT test: $_" -ForegroundColor Red
} finally {
    # Clean up temporary file
    if (Test-Path $tempScriptPath) {
        Remove-Item $tempScriptPath -Force
    }
}

Write-Host "`nUsage Examples:" -ForegroundColor Cyan
Write-Host "  .\test-mqtt.ps1 -PublishTest -Topic 'test/hello' -Message 'Hello World!'" -ForegroundColor White
Write-Host "  .\test-mqtt.ps1 -Subscribe -Topic 'devices/+/+/telemetry'" -ForegroundColor White
Write-Host "  .\test-mqtt.ps1 -MqttHost '192.168.1.100' -Port 1883" -ForegroundColor White 