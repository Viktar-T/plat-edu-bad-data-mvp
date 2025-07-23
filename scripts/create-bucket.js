const { InfluxDB, Point } = require('@influxdata/influxdb-client');

// InfluxDB configuration
const url = 'http://localhost:8086';
const token = ''; // No token since we're running without auth
const org = 'renewable_energy';
const bucket = 'renewable_energy';

// Create InfluxDB client
const client = new InfluxDB({ url, token });

// Write API
const writeApi = client.getWriteApi(org, bucket, 'ms');

// Create test data points for different device types
const createTestData = () => {
  const now = new Date();
  
  // Photovoltaic data
  const pvPoint = new Point('renewable_energy_data')
    .tag('device_type', 'photovoltaic')
    .tag('device_id', 'pv_001')
    .tag('location', 'solar_farm_1')
    .tag('status', 'operational')
    .floatField('voltage', 48.5)
    .floatField('current', 10.2)
    .floatField('power_output', 494.7)
    .floatField('irradiance', 850.0)
    .floatField('temperature', 45.2)
    .floatField('efficiency', 0.18)
    .timestamp(now);

  // Wind turbine data
  const windPoint = new Point('renewable_energy_data')
    .tag('device_type', 'wind_turbine')
    .tag('device_id', 'wt_001')
    .tag('location', 'wind_farm_1')
    .tag('status', 'operational')
    .floatField('wind_speed', 12.5)
    .floatField('power_output', 850.0)
    .floatField('rotor_speed', 15.2)
    .floatField('blade_angle', 5.0)
    .floatField('efficiency', 0.35)
    .timestamp(now);

  // Biogas plant data
  const biogasPoint = new Point('renewable_energy_data')
    .tag('device_type', 'biogas_plant')
    .tag('device_id', 'bg_001')
    .tag('location', 'biogas_facility_1')
    .tag('status', 'operational')
    .floatField('gas_flow_rate', 25.5)
    .floatField('methane_concentration', 65.2)
    .floatField('temperature', 38.5)
    .floatField('pressure', 1.2)
    .floatField('power_output', 120.0)
    .timestamp(now);

  // Heat boiler data
  const boilerPoint = new Point('renewable_energy_data')
    .tag('device_type', 'heat_boiler')
    .tag('device_id', 'hb_001')
    .tag('location', 'heating_plant_1')
    .tag('status', 'operational')
    .floatField('temperature', 85.0)
    .floatField('pressure', 2.5)
    .floatField('fuel_consumption', 15.2)
    .floatField('efficiency', 0.88)
    .floatField('heat_output', 450.0)
    .timestamp(now);

  // Energy storage data
  const storagePoint = new Point('renewable_energy_data')
    .tag('device_type', 'energy_storage')
    .tag('device_id', 'es_001')
    .tag('location', 'storage_facility_1')
    .tag('status', 'operational')
    .floatField('state_of_charge', 75.5)
    .floatField('voltage', 400.0)
    .floatField('current', 25.0)
    .floatField('temperature', 25.0)
    .floatField('power_output', 10.0)
    .floatField('cycle_count', 1250)
    .timestamp(now);

  return [pvPoint, windPoint, biogasPoint, boilerPoint, storagePoint];
};

// Write data to InfluxDB
const writeData = async () => {
  try {
    console.log('Writing test data to InfluxDB...');
    const points = createTestData();
    
    for (const point of points) {
      writeApi.writePoint(point);
    }
    
    await writeApi.close();
    console.log('✅ Test data written successfully!');
    console.log('✅ Bucket "renewable_energy" should now exist');
    console.log('✅ You can now view the dashboards in Grafana');
    
  } catch (error) {
    console.error('❌ Error writing data:', error);
  } finally {
    client.close();
  }
};

// Run the script
writeData(); 