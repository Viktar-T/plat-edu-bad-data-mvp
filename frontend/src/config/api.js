// API Configuration
const config = {
  apiUrl: import.meta.env.VITE_API_URL || 'http://localhost:3001',
  apiBaseUrl: import.meta.env.VITE_API_BASE_URL || 'http://localhost:3001/api',
  influxOrg: import.meta.env.VITE_INFLUXDB_ORG || 'renewable_energy_org',
  influxBucket: import.meta.env.VITE_INFLUXDB_BUCKET || 'renewable_energy',
  timeout: 10000, // 10 seconds
};

export default config;

