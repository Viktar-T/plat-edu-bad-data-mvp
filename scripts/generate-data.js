const { InfluxDB, Point } = require('@influxdata/influxdb-client');

// InfluxDB configuration
const url = 'http://localhost:8086';
const token = ''; // No token since we're running without auth
const org = 'renewable_energy';
const bucket = 'renewable_energy';

// Create InfluxDB client
const writeApi = new InfluxDB({ url, token }).getWriteApi(org, bucket, 'ms');

// Generate realistic renewable energy data
const generateData = () => {
  const now = new Date();
  const points = [];

  // Photovoltaic data with realistic variations
  const pvEfficiency = 0.15 + Math.random() * 0.08; // 15-23% efficiency
  const irradiance = 200 + Math.random() * 800; // 200-1000 W/m²
  const temperature = 20 + Math.random() * 40; // 20-60°C
  const voltage = 45 + Math.random() * 10; // 45-55V
  const current = voltage * pvEfficiency * irradiance / 1000; // Realistic current
  const powerOutput = voltage * current;

  points.push(new Point('renewable_energy_data')
    .tag('device_type', 'photovoltaic')
    .tag('device_id', 'pv_001')
    .tag('location', 'solar_farm_1')
    .tag('status', 'operational')
    .floatField('voltage', voltage)
    .floatField('current', current)
    .floatField('power_output', powerOutput)
    .floatField('irradiance', irradiance)
    .floatField('temperature', temperature)
    .floatField('efficiency', pvEfficiency)
    .timestamp(now));

  // Wind turbine data
  const windSpeed = 5 + Math.random() * 20; // 5-25 m/s
  const rotorSpeed = windSpeed * 0.8; // Proportional to wind speed
  const bladeAngle = Math.random() * 10; // 0-10 degrees
  const windEfficiency = Math.min(0.4, windSpeed / 50); // Efficiency based on wind speed
  const windPowerOutput = windSpeed * windSpeed * windEfficiency * 10; // Power curve

  points.push(new Point('renewable_energy_data')
    .tag('device_type', 'wind_turbine')
    .tag('device_id', 'wt_001')
    .tag('location', 'wind_farm_1')
    .tag('status', 'operational')
    .floatField('wind_speed', windSpeed)
    .floatField('power_output', windPowerOutput)
    .floatField('rotor_speed', rotorSpeed)
    .floatField('blade_angle', bladeAngle)
    .floatField('efficiency', windEfficiency)
    .timestamp(now));

  // Biogas plant data
  const gasFlowRate = 20 + Math.random() * 30; // 20-50 m³/h
  const methaneConcentration = 50 + Math.random() * 30; // 50-80%
  const biogasTemp = 35 + Math.random() * 10; // 35-45°C
  const biogasPressure = 1.0 + Math.random() * 0.5; // 1.0-1.5 bar
  const biogasPowerOutput = gasFlowRate * methaneConcentration / 100 * 0.5; // Power calculation

  points.push(new Point('renewable_energy_data')
    .tag('device_type', 'biogas_plant')
    .tag('device_id', 'bg_001')
    .tag('location', 'biogas_facility_1')
    .tag('status', 'operational')
    .floatField('gas_flow_rate', gasFlowRate)
    .floatField('methane_concentration', methaneConcentration)
    .floatField('temperature', biogasTemp)
    .floatField('pressure', biogasPressure)
    .floatField('power_output', biogasPowerOutput)
    .timestamp(now));

  // Heat boiler data
  const boilerTemp = 70 + Math.random() * 30; // 70-100°C
  const boilerPressure = 2.0 + Math.random() * 1.0; // 2.0-3.0 bar
  const fuelConsumption = 10 + Math.random() * 20; // 10-30 L/h
  const boilerEfficiency = 0.8 + Math.random() * 0.15; // 80-95%
  const heatOutput = fuelConsumption * boilerEfficiency * 10; // Heat output calculation

  points.push(new Point('renewable_energy_data')
    .tag('device_type', 'heat_boiler')
    .tag('device_id', 'hb_001')
    .tag('location', 'heating_plant_1')
    .tag('status', 'operational')
    .floatField('temperature', boilerTemp)
    .floatField('pressure', boilerPressure)
    .floatField('fuel_consumption', fuelConsumption)
    .floatField('efficiency', boilerEfficiency)
    .floatField('heat_output', heatOutput)
    .timestamp(now));

  // Energy storage data
  const stateOfCharge = 20 + Math.random() * 60; // 20-80%
  const storageVoltage = 350 + Math.random() * 100; // 350-450V
  const storageCurrent = -10 + Math.random() * 20; // -10 to +10A (charge/discharge)
  const storageTemp = 20 + Math.random() * 15; // 20-35°C
  const storagePowerOutput = storageVoltage * storageCurrent / 1000; // kW
  const cycleCount = 1000 + Math.floor(Math.random() * 500); // 1000-1500 cycles

  points.push(new Point('renewable_energy_data')
    .tag('device_type', 'energy_storage')
    .tag('device_id', 'es_001')
    .tag('location', 'storage_facility_1')
    .tag('status', 'operational')
    .floatField('state_of_charge', stateOfCharge)
    .floatField('voltage', storageVoltage)
    .floatField('current', storageCurrent)
    .floatField('temperature', storageTemp)
    .floatField('power_output', storagePowerOutput)
    .floatField('cycle_count', cycleCount)
    .timestamp(now));

  return points;
};

// Write data continuously
const writeDataContinuously = async () => {
  console.log('🚀 Starting continuous data generation...');
  console.log('📊 Writing data every 30 seconds...');
  console.log('🔄 Press Ctrl+C to stop');
  
  const writeData = async () => {
    try {
      const points = generateData();
      
      for (const point of points) {
        writeApi.writePoint(point);
      }
      
      await writeApi.flush();
      console.log(`✅ Data written at ${new Date().toLocaleTimeString()}`);
      
    } catch (error) {
      console.error('❌ Error writing data:', error);
    }
  };

  // Write initial data
  await writeData();
  
  // Write data every 30 seconds
  setInterval(writeData, 30000);
};

// Handle graceful shutdown
process.on('SIGINT', async () => {
  console.log('\n🛑 Stopping data generation...');
  await writeApi.close();
  process.exit(0);
});

// Start data generation
writeDataContinuously().catch(console.error); 