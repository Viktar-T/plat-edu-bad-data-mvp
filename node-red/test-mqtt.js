#!/usr/bin/env node

/**
 * MQTT Test Script for Renewable Energy Device Simulation
 * 
 * This script tests MQTT communication by subscribing to device topics
 * and displaying received messages.
 */

const mqtt = require('mqtt');

// Configuration
const config = {
    host: process.env.MQTT_BROKER_HOST || 'localhost',
    port: process.env.MQTT_BROKER_PORT || 1883,
    clientId: 'mqtt-test-client',
    username: process.env.MQTT_USERNAME || 'node-red',
    password: process.env.MQTT_PASSWORD || 'node-red-password',
    topics: [
        'devices/photovoltaic/+/telemetry',
        'devices/wind_turbine/+/telemetry',
        'devices/biogas_plant/+/telemetry',
        'devices/heat_boiler/+/telemetry',
        'devices/energy_storage/+/telemetry'
    ]
};

// Statistics
let stats = {
    totalMessages: 0,
    deviceTypes: {},
    errors: 0,
    startTime: new Date()
};

// Connect to MQTT broker
console.log(`Connecting to MQTT broker at ${config.host}:${config.port}...`);

const client = mqtt.connect(`mqtt://${config.host}:${config.port}`, {
    clientId: config.clientId,
    username: config.username,
    password: config.password,
    clean: true,
    reconnectPeriod: 5000,
    connectTimeout: 30000
});

// Connection event handlers
client.on('connect', () => {
    console.log('✅ Connected to MQTT broker');
    console.log('📡 Subscribing to device topics...');
    
    // Subscribe to all device topics
    config.topics.forEach(topic => {
        client.subscribe(topic, (err) => {
            if (err) {
                console.error(`❌ Failed to subscribe to ${topic}:`, err);
            } else {
                console.log(`✅ Subscribed to ${topic}`);
            }
        });
    });
    
    console.log('\n🎯 Listening for device messages...\n');
});

client.on('message', (topic, message) => {
    try {
        const data = JSON.parse(message.toString());
        stats.totalMessages++;
        
        // Update device type statistics
        const deviceType = data.device_type;
        if (!stats.deviceTypes[deviceType]) {
            stats.deviceTypes[deviceType] = 0;
        }
        stats.deviceTypes[deviceType]++;
        
        // Display message
        console.log(`📨 [${new Date().toISOString()}] ${topic}`);
        console.log(`   Device: ${data.device_id} (${data.device_type})`);
        console.log(`   Status: ${data.status}`);
        console.log(`   Location: ${data.location}`);
        
        if (data.fault_type) {
            console.log(`   ⚠️  Fault: ${data.fault_type}`);
        }
        
        // Display key data parameters
        const dataKeys = Object.keys(data.data);
        if (dataKeys.length > 0) {
            console.log(`   Data: ${dataKeys.map(key => `${key}=${data.data[key]}`).join(', ')}`);
        }
        
        console.log('');
        
    } catch (error) {
        console.error('❌ Error parsing message:', error);
        stats.errors++;
    }
});

client.on('error', (error) => {
    console.error('❌ MQTT Error:', error);
    stats.errors++;
});

client.on('close', () => {
    console.log('🔌 MQTT connection closed');
});

client.on('reconnect', () => {
    console.log('🔄 Reconnecting to MQTT broker...');
});

// Handle process termination
process.on('SIGINT', () => {
    console.log('\n📊 Final Statistics:');
    console.log(`   Total Messages: ${stats.totalMessages}`);
    console.log(`   Errors: ${stats.errors}`);
    console.log(`   Duration: ${Math.round((new Date() - stats.startTime) / 1000)}s`);
    console.log('\n   Device Types:');
    Object.entries(stats.deviceTypes).forEach(([type, count]) => {
        console.log(`     ${type}: ${count} messages`);
    });
    
    console.log('\n👋 Disconnecting from MQTT broker...');
    client.end();
    process.exit(0);
});

// Periodic statistics display
setInterval(() => {
    const duration = Math.round((new Date() - stats.startTime) / 1000);
    const rate = duration > 0 ? (stats.totalMessages / duration).toFixed(2) : 0;
    
    console.log(`📈 Stats: ${stats.totalMessages} messages, ${rate} msg/s, ${stats.errors} errors`);
}, 30000);

// Test message publishing (optional)
if (process.argv.includes('--publish-test')) {
    console.log('🧪 Publishing test messages...');
    
    const testMessages = [
        {
            topic: 'devices/photovoltaic/pv_test/telemetry',
            message: {
                device_id: 'pv_test',
                device_type: 'photovoltaic',
                timestamp: new Date().toISOString(),
                data: {
                    irradiance: 850.5,
                    temperature: 45.2,
                    voltage: 48.3,
                    current: 12.1,
                    power_output: 584.43
                },
                status: 'operational',
                location: 'test_site',
                fault_type: null
            }
        },
        {
            topic: 'devices/wind_turbine/wt_test/telemetry',
            message: {
                device_id: 'wt_test',
                device_type: 'wind_turbine',
                timestamp: new Date().toISOString(),
                data: {
                    wind_speed: 8.5,
                    wind_direction: 180,
                    rotor_speed: 12.3,
                    vibration: 2.1,
                    power_output: 1200.0,
                    temperature: 25.5
                },
                status: 'operational',
                location: 'test_site',
                fault_type: null
            }
        }
    ];
    
    testMessages.forEach(({ topic, message }) => {
        client.publish(topic, JSON.stringify(message), { qos: 1 }, (err) => {
            if (err) {
                console.error(`❌ Failed to publish test message to ${topic}:`, err);
            } else {
                console.log(`✅ Published test message to ${topic}`);
            }
        });
    });
}

console.log('🚀 MQTT Test Client Started');
console.log('   Press Ctrl+C to stop and view statistics\n'); 