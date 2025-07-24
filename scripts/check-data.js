const { InfluxDB } = require('@influxdata/influxdb-client');

// InfluxDB configuration
const url = 'http://localhost:8086';
const token = ''; // No token since we're running without auth
const org = 'renewable_energy';
const bucket = 'renewable_energy';

// Create InfluxDB client
const client = new InfluxDB({ url, token });
const queryApi = client.getQueryApi(org);

// Check data in InfluxDB
const checkData = async () => {
  try {
    console.log('🔍 Checking data in InfluxDB...\n');
    
    // Check device types
    const deviceTypesQuery = `
      from(bucket: "renewable_energy")
        |> range(start: -1h)
        |> group(columns: ["device_type"])
        |> distinct(column: "device_type")
    `;
    
    const deviceTypes = await queryApi.collectRows(deviceTypesQuery);
    console.log('📊 Device Types Found:');
    deviceTypes.forEach(row => {
      console.log(`   - ${row.device_type}`);
    });
    
    // Check total data points
    const countQuery = `
      from(bucket: "renewable_energy")
        |> range(start: -1h)
        |> count()
    `;
    
    const countResult = await queryApi.collectRows(countQuery);
    console.log(`\n📈 Total Data Points (last hour): ${countResult[0]?._value || 0}`);
    
    // Check latest data for each device type
    const latestDataQuery = `
      from(bucket: "renewable_energy")
        |> range(start: -5m)
        |> filter(fn: (r) => r._field == "power_output")
        |> group(columns: ["device_type", "device_id"])
        |> last()
    `;
    
    const latestData = await queryApi.collectRows(latestDataQuery);
    console.log('\n⚡ Latest Power Output by Device:');
    latestData.forEach(row => {
      console.log(`   ${row.device_type} (${row.device_id}): ${row._value.toFixed(2)} W`);
    });
    
    console.log('\n✅ Data verification complete!');
    console.log('🌐 You can now view the dashboards at: http://localhost:3000');
    
  } catch (error) {
    console.error('❌ Error checking data:', error);
  } finally {
    client.close();
  }
};

// Run the check
checkData(); 