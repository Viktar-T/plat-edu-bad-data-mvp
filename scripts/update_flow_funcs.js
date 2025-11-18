const fs = require('fs');
const path = require('path');

const updates = [
  {
    file: 'node-red/flows/v2.0-algae-farm-1-simulation.json',
    nodeId: 'algy-simulation-function',
    label: 'Algae Farm 1',
    deviceType: 'algae_farm',
    deviceId: 'algy',
    location: 'site_f',
    baseValues: {
      temperature: 25.0,
      ph: 7.5,
      nitrogen: 14.9,
      phosphorus: 1.99,
      biomass: 500,
      biomass_production: 50.0,
      co2_consumption: 90.0,
      oxygen_production: 60.0,
      growth_rate: 10.0
    },
    limits: {
      temperature: { min: 15, max: 40 },
      ph: { min: 6.5, max: 8.5 },
      nitrogen: { min: 5, max: 30 },
      phosphorus: { min: 0.5, max: 5 },
      biomass: { min: 100, max: 1000 },
      biomass_production: { min: 0, max: 100 },
      co2_consumption: { min: 0, max: 200 },
      oxygen_production: { min: 0, max: 150 },
      growth_rate: { min: 0, max: 20 }
    }
  },
  {
    file: 'node-red/flows/v2.0-algae-farm-2-simulation.json',
    nodeId: 'big-algy-simulation-function',
    label: 'Algae Farm 2',
    deviceType: 'algae_farm',
    deviceId: 'big_algy',
    location: 'site_g',
    baseValues: {
      temperature: 25.0,
      ph: 7.5,
      nitrogen: 17.88,
      phosphorus: 2.49,
      biomass: 600,
      biomass_production: 60.0,
      co2_consumption: 108.0,
      oxygen_production: 72.0,
      growth_rate: 10.0
    },
    limits: {
      temperature: { min: 15, max: 40 },
      ph: { min: 6.5, max: 8.5 },
      nitrogen: { min: 5, max: 30 },
      phosphorus: { min: 0.5, max: 5 },
      biomass: { min: 100, max: 1200 },
      biomass_production: { min: 0, max: 100 },
      co2_consumption: { min: 0, max: 200 },
      oxygen_production: { min: 0, max: 150 },
      growth_rate: { min: 0, max: 20 }
    }
  },
  {
    file: 'node-red/flows/v2.0-pv-hulajnogi-simulation.json',
    nodeId: 'pv-simulation-function',
    label: 'Photovoltaic Charger',
    deviceType: 'photovoltaic',
    deviceId: 'ladowarka_sloneczna',
    location: 'site_a',
    baseValues: {
      irradiance: 68.78,
      temperature: 54.82,
      voltage: 48.09,
      current: 0.65,
      power_output: 24.37
    },
    limits: {
      irradiance: { min: 0, max: 1200 },
      temperature: { min: -40, max: 100 },
      voltage: { min: 0, max: 100 },
      current: { min: 0, max: 20 },
      power_output: { min: 0, max: 1000 }
    }
  },
  {
    file: 'node-red/flows/v2.0-pv-hybrid-simulation.json',
    nodeId: 'pv-panels-simulation-function',
    label: 'PV Hybrid Panels',
    deviceType: 'photovoltaic',
    deviceId: 'pv_panels',
    location: 'site_a',
    baseValues: {
      irradiance: 47.1,
      temperature: 53.82,
      voltage: 48.49,
      current: 0.77,
      power_output: 37.85
    },
    limits: {
      irradiance: { min: 0, max: 1200 },
      temperature: { min: -40, max: 100 },
      voltage: { min: 0, max: 100 },
      current: { min: 0, max: 20 },
      power_output: { min: 0, max: 1000 }
    }
  },
  {
    file: 'node-red/flows/v2.0-biogas-plant-simulation.json',
    nodeId: 'bg-simulation-function',
    label: 'Biogas Plant',
    deviceType: 'biogas_plant',
    deviceId: 'biogas',
    location: 'site_c',
    baseValues: {
      temperature: 35.0,
      ph: 7.2,
      gas_flow_rate: 50.0,
      methane_concentration: 65.0,
      pressure: 1.2,
      energy_content: 6.5
    },
    limits: {
      temperature: { min: 20, max: 60 },
      ph: { min: 6.0, max: 8.5 },
      gas_flow_rate: { min: 0, max: 100 },
      methane_concentration: { min: 40, max: 85 },
      pressure: { min: 0.5, max: 2.0 },
      energy_content: { min: 4.0, max: 8.0 }
    }
  },
  {
    file: 'node-red/flows/v2.0-wind-vawt-simulation.json',
    nodeId: 'wt-simulation-function',
    label: 'Wind Turbine VAWT',
    deviceType: 'wind_turbine',
    deviceId: 'turbine_vertical',
    location: 'site_b',
    baseValues: {
      wind_speed: 6.09,
      power_output: 174.07,
      rotor_speed: 21.65,
      blade_pitch: 0.0,
      generator_temperature: 33.31
    },
    limits: {
      wind_speed: { min: 0, max: 50 },
      power_output: { min: 0, max: 2500 },
      rotor_speed: { min: 0, max: 50 },
      blade_pitch: { min: 0, max: 90 },
      generator_temperature: { min: -20, max: 120 }
    }
  },
  {
    file: 'node-red/flows/v2.0-wind-hawt-hybrid-simulation.json',
    nodeId: 'wt-hawt-simulation-function',
    label: 'Wind Turbine HAWT',
    deviceType: 'wind_turbine',
    deviceId: 'wind_turbine',
    location: 'site_b',
    baseValues: {
      wind_speed: 7.41,
      power_output: 235.75,
      rotor_speed: 22.35,
      blade_pitch: 0.0,
      generator_temperature: 30.8
    },
    limits: {
      wind_speed: { min: 0, max: 50 },
      power_output: { min: 0, max: 2500 },
      rotor_speed: { min: 0, max: 50 },
      blade_pitch: { min: 0, max: 90 },
      generator_temperature: { min: -20, max: 120 }
    }
  },
  {
    file: 'node-red/flows/v2.0-heat-boiler-simulation.json',
    nodeId: 'hb-simulation-function',
    label: 'Heat Boiler',
    deviceType: 'heat_boiler',
    deviceId: 'heat_system',
    location: 'site_d',
    baseValues: {
      ambient_temperature: 20.0,
      fuel_flow_rate: 15.0,
      water_temperature: 80.0,
      pressure: 2.0,
      efficiency: 85.0,
      heat_output: 133.88
    },
    limits: {
      ambient_temperature: { min: -20, max: 50 },
      fuel_flow_rate: { min: 0, max: 30 },
      water_temperature: { min: 50, max: 100 },
      pressure: { min: 1.0, max: 4.0 },
      efficiency: { min: 60, max: 98 },
      heat_output: { min: 0, max: 300 }
    }
  },
  {
    file: 'node-red/flows/v2.0-energy-storage-simulation.json',
    nodeId: 'es-simulation-function',
    label: 'Energy Storage',
    deviceType: 'energy_storage',
    deviceId: 'turbine_is',
    location: 'site_e',
    baseValues: {
      temperature: 25.0,
      state_of_charge: 50.0,
      voltage: 48.0,
      current: 10.0,
      power: 480.0,
      capacity: 100.0,
      degradation: 1.0
    },
    limits: {
      temperature: { min: -10, max: 60 },
      state_of_charge: { min: 5, max: 100 },
      voltage: { min: 40, max: 60 },
      current: { min: -50, max: 50 },
      power: { min: -2000, max: 2000 },
      capacity: { min: 50, max: 120 },
      degradation: { min: 0.7, max: 1.0 }
    }
  },
  {
    file: 'node-red/flows/v2.0-engine-test-bench-simulation.json',
    nodeId: 'etb-simulation-function',
    label: 'Engine Test Bench',
    deviceType: 'engine_test_bench',
    deviceId: 'engine_bench',
    location: 'site_e',
    baseValues: {
      engine_speed: 1500,
      torque: 150,
      power_output: 23.57,
      coolant_temperature: 85,
      oil_temperature: 90,
      exhaust_temperature: 400,
      fuel_consumption: 15,
      oil_pressure: 4,
      fuel_pressure: 3.5,
      efficiency: 35,
      load: 50
    },
    limits: {
      engine_speed: { min: 800, max: 3000 },
      torque: { min: 50, max: 300 },
      power_output: { min: 0, max: 100 },
      coolant_temperature: { min: 70, max: 100 },
      oil_temperature: { min: 75, max: 110 },
      exhaust_temperature: { min: 300, max: 600 },
      fuel_consumption: { min: 5, max: 30 },
      oil_pressure: { min: 2, max: 6 },
      fuel_pressure: { min: 2.5, max: 4.5 },
      efficiency: { min: 25, max: 45 },
      load: { min: 0, max: 100 }
    }
  }
];

function sanitizeJson(text) {
  const withoutBom = text.replace(/^\uFEFF/, '');
  const lastBracket = withoutBom.lastIndexOf(']');
  if (lastBracket === -1) {
    throw new Error('Could not find closing bracket in flow file');
  }
  return withoutBom.slice(0, lastBracket + 1);
}

function buildFunction({ label, baseValues, limits, deviceId, deviceType, location }) {
  const baseStr = JSON.stringify(baseValues, null, 4);
  const limitStr = JSON.stringify(limits, null, 4);
  const topic = `devices/${deviceType}/${deviceId}/telemetry`;

  return `// ${label} Data Simulation with strict +/-2% corridor
const now = new Date();

const BASE_VALUES = ${baseStr};

const LIMITS = ${limitStr};

function randomWithinCorridor(key) {
    const base = BASE_VALUES[key];
    if (typeof base !== 'number') {
        return base;
    }
    const corridor = Math.abs(base) * 0.02;
    const limit = LIMITS[key] || {};
    const min = typeof limit.min === 'number' ? limit.min : base - corridor;
    const max = typeof limit.max === 'number' ? limit.max : base + corridor;
    const noise = corridor === 0 ? 0 : (Math.random() - 0.5) * 2 * corridor;
    const value = base + noise;
    return Math.max(min, Math.min(max, value));
}

function roundValue(value) {
    return Math.round(value * 100) / 100;
}

const data = {};
for (const key of Object.keys(BASE_VALUES)) {
    data[key] = roundValue(randomWithinCorridor(key));
}

const payload = {
    device_id: '${deviceId}',
    device_type: '${deviceType}',
    timestamp: now.toISOString(),
    data,
    status: 'operational',
    location: '${location}',
    fault_type: null
};

msg.payload = payload;
msg.topic = '${topic}';

return msg;`;
}

for (const update of updates) {
  const filePath = path.resolve(__dirname, '..', update.file);
  const raw = fs.readFileSync(filePath, 'utf8');
  const nodes = JSON.parse(sanitizeJson(raw));
  const target = nodes.find((node) => node.id === update.nodeId);
  if (!target) {
    throw new Error(`Node ${update.nodeId} not found in ${update.file}`);
  }
  target.func = buildFunction(update);
  fs.writeFileSync(filePath, JSON.stringify(nodes, null, 2));
  console.log(`Updated ${update.file}`);
}

