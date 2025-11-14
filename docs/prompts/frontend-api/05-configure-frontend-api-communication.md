# Step 5: Configure Frontend-API Communication

## Context
Your React frontend needs to communicate with the Express API to fetch data from InfluxDB. Currently, the frontend has API service files in `src/api/` that need to be configured to use the containerized API.

## Current Frontend API Structure
```
frontend/src/api/
├── Server.jsx            # API communication utilities
├── Photovoltaic.jsx      # Photovoltaic data fetching
├── WindTurbine.jsx       # Wind turbine data fetching
├── RoomsData.jsx         # Rooms data fetching
├── MarkersData.jsx       # Map markers data
└── EletricLinesData.jsx  # Electric lines data
```

## Task
1. Create environment variable configuration for the frontend
2. Update API service files to use the containerized API endpoint
3. Implement proper error handling and loading states
4. Configure CORS properly in the API

## Implementation

### 1. Create Frontend Environment Configuration

Create `frontend/.env.development`:
```bash
# Development Environment
VITE_API_URL=http://localhost:3001
VITE_API_BASE_URL=http://localhost:3001/api
VITE_INFLUXDB_ORG=renewable_energy_org
VITE_INFLUXDB_BUCKET=renewable_energy
```

Create `frontend/.env.production`:
```bash
# Production Environment (VPS)
VITE_API_URL=http://robert108.mikrus.xyz:40102
VITE_API_BASE_URL=http://robert108.mikrus.xyz:40102/api
VITE_INFLUXDB_ORG=renewable_energy_org
VITE_INFLUXDB_BUCKET=renewable_energy
```

Create `frontend/.env.local.example`:
```bash
# Local Development with Docker
VITE_API_URL=http://localhost:3001
VITE_API_BASE_URL=http://localhost:3001/api
```

### 2. Create API Configuration File

Create `frontend/src/config/api.js`:
```javascript
// API Configuration
const config = {
  apiUrl: import.meta.env.VITE_API_URL || 'http://localhost:3001',
  apiBaseUrl: import.meta.env.VITE_API_BASE_URL || 'http://localhost:3001/api',
  influxOrg: import.meta.env.VITE_INFLUXDB_ORG || 'renewable_energy_org',
  influxBucket: import.meta.env.VITE_INFLUXDB_BUCKET || 'renewable_energy',
  timeout: 10000, // 10 seconds
};

export default config;
```

### 3. Create Centralized API Service

Create `frontend/src/services/apiService.js`:
```javascript
import config from '../config/api';

/**
 * Centralized API service for all HTTP requests
 */
class ApiService {
  constructor() {
    this.baseUrl = config.apiBaseUrl;
    this.timeout = config.timeout;
  }

  /**
   * Generic fetch wrapper with timeout and error handling
   */
  async fetchWithTimeout(url, options = {}) {
    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), this.timeout);

    try {
      const response = await fetch(url, {
        ...options,
        signal: controller.signal,
        headers: {
          'Content-Type': 'application/json',
          ...options.headers,
        },
      });

      clearTimeout(timeoutId);

      if (!response.ok) {
        throw new Error(`HTTP error! status: ${response.status}`);
      }

      return await response.json();
    } catch (error) {
      clearTimeout(timeoutId);
      if (error.name === 'AbortError') {
        throw new Error('Request timeout');
      }
      throw error;
    }
  }

  /**
   * Health check
   */
  async healthCheck() {
    try {
      const response = await this.fetchWithTimeout(`${config.apiUrl}/health`);
      return response;
    } catch (error) {
      console.error('Health check failed:', error);
      throw error;
    }
  }

  /**
   * Get machine summary data
   * @param {string} machine - Machine type (big_turbine, charger, heat_boiler, biogas, storage)
   * @param {string} startTime - Time range (e.g., "2m", "1h", "24h")
   */
  async getMachineSummary(machine, startTime = '2m') {
    const url = `${this.baseUrl}/summary/${machine}?start=${startTime}`;
    return await this.fetchWithTimeout(url);
  }

  /**
   * Execute custom Flux query
   * @param {string} fluxQuery - Flux query string
   */
  async executeQuery(fluxQuery) {
    const url = `${this.baseUrl}/query`;
    return await this.fetchWithTimeout(url, {
      method: 'POST',
      body: JSON.stringify({ fluxQuery }),
    });
  }

  /**
   * Get photovoltaic data
   */
  async getPhotovoltaicData(startTime = '2m') {
    return await this.getMachineSummary('charger', startTime);
  }

  /**
   * Get wind turbine data
   */
  async getWindTurbineData(startTime = '2m') {
    return await this.getMachineSummary('big_turbine', startTime);
  }

  /**
   * Get heat boiler data
   */
  async getHeatBoilerData(startTime = '2m') {
    return await this.getMachineSummary('heat_boiler', startTime);
  }

  /**
   * Get biogas plant data
   */
  async getBiogasData(startTime = '2m') {
    return await this.getMachineSummary('biogas', startTime);
  }

  /**
   * Get energy storage data
   */
  async getEnergyStorageData(startTime = '2m') {
    return await this.getMachineSummary('storage', startTime);
  }
}

export const apiService = new ApiService();
export default apiService;
```

### 4. Update API CORS Configuration

Update `api/src/index.js` to handle CORS properly:

**Find the CORS configuration:**
```javascript
app.use(cors())
```

**Replace with:**
```javascript
// CORS Configuration
const corsOptions = {
  origin: process.env.CORS_ORIGIN || [
    'http://localhost:5173',
    'http://localhost:3000',
    'http://robert108.mikrus.xyz:40103'
  ],
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization'],
  credentials: true,
  optionsSuccessStatus: 200
};

app.use(cors(corsOptions));
```

### 5. Create React Hook for Data Fetching

Create `frontend/src/hooks/useDeviceData.js`:
```javascript
import { useState, useEffect, useCallback } from 'react';
import apiService from '../services/apiService';

/**
 * Custom hook for fetching device data
 * @param {string} deviceType - Type of device (photovoltaic, wind_turbine, etc.)
 * @param {string} timeRange - Time range for data (default: '2m')
 * @param {number} refreshInterval - Auto-refresh interval in ms (default: 30000)
 */
export const useDeviceData = (deviceType, timeRange = '2m', refreshInterval = 30000) => {
  const [data, setData] = useState(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [lastUpdate, setLastUpdate] = useState(null);

  const fetchData = useCallback(async () => {
    try {
      setLoading(true);
      setError(null);

      let result;
      switch (deviceType) {
        case 'photovoltaic':
          result = await apiService.getPhotovoltaicData(timeRange);
          break;
        case 'wind_turbine':
          result = await apiService.getWindTurbineData(timeRange);
          break;
        case 'heat_boiler':
          result = await apiService.getHeatBoilerData(timeRange);
          break;
        case 'biogas':
          result = await apiService.getBiogasData(timeRange);
          break;
        case 'storage':
          result = await apiService.getEnergyStorageData(timeRange);
          break;
        default:
          throw new Error(`Unknown device type: ${deviceType}`);
      }

      setData(result);
      setLastUpdate(new Date());
    } catch (err) {
      setError(err.message || 'Failed to fetch data');
      console.error(`Error fetching ${deviceType} data:`, err);
    } finally {
      setLoading(false);
    }
  }, [deviceType, timeRange]);

  useEffect(() => {
    fetchData();

    // Set up auto-refresh
    if (refreshInterval > 0) {
      const intervalId = setInterval(fetchData, refreshInterval);
      return () => clearInterval(intervalId);
    }
  }, [fetchData, refreshInterval]);

  return { data, loading, error, lastUpdate, refetch: fetchData };
};

export default useDeviceData;
```

### 6. Example Usage in Component

Update one of your existing components to use the new service. For example, update `frontend/src/api/Photovoltaic.jsx`:

```javascript
import { useDeviceData } from '../hooks/useDeviceData';

export const PhotovoltaicData = () => {
  const { data, loading, error, lastUpdate, refetch } = useDeviceData(
    'photovoltaic',
    '2m',
    30000 // Refresh every 30 seconds
  );

  if (loading && !data) {
    return <div>Loading photovoltaic data...</div>;
  }

  if (error) {
    return (
      <div>
        <p>Error: {error}</p>
        <button onClick={refetch}>Retry</button>
      </div>
    );
  }

  return (
    <div>
      <h2>Photovoltaic Data</h2>
      {lastUpdate && (
        <p>Last updated: {lastUpdate.toLocaleTimeString()}</p>
      )}
      <pre>{JSON.stringify(data, null, 2)}</pre>
      <button onClick={refetch}>Refresh</button>
    </div>
  );
};
```

## Verification Steps

### 1. Test API Health
```powershell
# Test from host
curl http://localhost:3001/health

# Test from within frontend container
docker exec iot-frontend wget -O- http://api:3001/health
```

### 2. Test CORS
```powershell
# Test CORS headers
curl -H "Origin: http://localhost:5173" -I http://localhost:3001/health
```

### 3. Test API Endpoint
```powershell
# Test machine summary
curl http://localhost:3001/api/summary/charger?start=2m
```

### 4. Test Frontend Connection
1. Start all services:
```powershell
docker-compose up -d
```

2. Open browser console at http://localhost:5173
3. Run in console:
```javascript
fetch('http://localhost:3001/health')
  .then(r => r.json())
  .then(console.log)
```

## Troubleshooting

### CORS Errors
If you see CORS errors in the browser console:

1. Check API CORS configuration:
```powershell
docker exec iot-api env | Select-String "CORS"
```

2. Verify the origin in browser matches CORS_ORIGIN

3. Check API logs:
```powershell
docker-compose logs api | Select-String "CORS"
```

### Connection Refused
If frontend cannot connect to API:

1. Verify API is running:
```powershell
docker-compose ps api
```

2. Check API logs:
```powershell
docker-compose logs api
```

3. Test network connectivity:
```powershell
docker exec iot-frontend ping api -c 3
```

### Environment Variables Not Working
If env vars aren't being read:

1. Rebuild the frontend:
```powershell
docker-compose build frontend
docker-compose up -d frontend
```

2. Verify env vars in build:
```powershell
docker exec iot-frontend env | Select-String "VITE"
```

Note: Vite embeds env vars at build time, so you need to rebuild after changing them.

## Next Steps
- Proceed to Step 6: End-to-End Testing
- Test all device data endpoints
- Verify real-time data updates

## Notes
- Vite env variables must be prefixed with `VITE_`
- Vite embeds env variables at build time
- For production, rebuild frontend with production env vars
- API uses Docker internal networking to connect to InfluxDB
- Frontend uses host networking to connect to API (or configure nginx proxy)
- Consider adding request caching for better performance
- Implement proper error boundaries in React components

