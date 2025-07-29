const { InfluxDB, Point } = require('@influxdata/influxdb-client');

// InfluxDB configuration
const url = 'http://localhost:8086';
const token = 'renewable_energy_admin_token_123';
const org = 'renewable_energy_org';
const bucket = 'renewable_energy';

console.log('🔍 Testing InfluxDB Connection...');
console.log(`URL: ${url}`);
console.log(`Token: ${token}`);
console.log(`Organization: ${org}`);
console.log(`Bucket: ${bucket}`);

// Create InfluxDB client
const influxDB = new InfluxDB({ url, token });

// Test query API
const queryApi = influxDB.getQueryApi(org);

async function testConnection() {
    try {
        console.log('\n📊 Testing query connection...');
        
        // Test a simple query
        const query = `from(bucket: "${bucket}")
            |> range(start: -1m)
            |> limit(n: 1)`;
        
        console.log(`Query: ${query}`);
        
        const result = await queryApi.queryRaw(query);
        console.log('✅ Query successful!');
        console.log('Result:', result);
        
    } catch (error) {
        console.error('❌ Query failed:', error.message);
        
        if (error.statusCode === 401) {
            console.error('🔐 Authentication failed - check token and organization');
        } else if (error.statusCode === 404) {
            console.error('📦 Bucket not found - check bucket name');
        }
    }
    
    // Test write API
    try {
        console.log('\n✍️  Testing write connection...');
        
        const writeApi = influxDB.getWriteApi(org, bucket, 'ms');
        
        // Create a test point
        const point = new Point('test_connection')
            .tag('test', 'true')
            .floatField('value', 1.0);
        
        await writeApi.writePoint(point);
        await writeApi.close();
        
        console.log('✅ Write successful!');
        
    } catch (error) {
        console.error('❌ Write failed:', error.message);
        
        if (error.statusCode === 401) {
            console.error('🔐 Authentication failed - check token and organization');
        } else if (error.statusCode === 404) {
            console.error('📦 Bucket not found - check bucket name');
        }
    }
    
    // Test health endpoint
    try {
        console.log('\n🏥 Testing health endpoint...');
        
        const response = await fetch(`${url}/health`);
        const health = await response.json();
        
        console.log('✅ Health check successful!');
        console.log('Health status:', health);
        
    } catch (error) {
        console.error('❌ Health check failed:', error.message);
    }
}

testConnection().then(() => {
    console.log('\n🏁 Test completed');
    process.exit(0);
}).catch(error => {
    console.error('💥 Test failed:', error);
    process.exit(1);
}); 