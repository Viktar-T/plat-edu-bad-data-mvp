# Frontend & API Architecture Explanation
**Version:** 1.0  
**Date:** 2024-11-25  
**Project:** Renewable Energy IoT Monitoring System - MVP

---

## Table of Contents

1. [System Overview](#system-overview)
2. [API Backend Architecture](#api-backend-architecture)
3. [Frontend Architecture](#frontend-architecture)
4. [Data Flow & Communication](#data-flow--communication)
5. [Key Components & Files](#key-components--files)
6. [Configuration & Environment](#configuration--environment)
7. [Development Workflow](#development-workflow)
8. [Deployment Architecture](#deployment-architecture)
9. [API Endpoints Reference](#api-endpoints-reference)
10. [Frontend Components Reference](#frontend-components-reference)

---

## System Overview

### Architecture Pattern

The system follows a **separation of concerns** architecture with two main components:

1. **API Backend** (`/api`): Express.js server that acts as a middleware between the frontend and InfluxDB
2. **Frontend** (`/frontend`): React application with Vite that provides the user interface

### Data Flow

```
MQTT → Node-RED → InfluxDB → Express API → React Frontend
```

The frontend and API are part of **Flow 2** in the dual-setup architecture:
- **Flow 1**: MQTT → Node-RED → InfluxDB → Grafana (existing monitoring)
- **Flow 2**: MQTT → Node-RED → InfluxDB → Express API → React Frontend (custom web app)

### Technology Stack

**API Backend:**
- **Runtime**: Node.js 20
- **Framework**: Express.js 4.18.2
- **Database Client**: @influxdata/influxdb-client 1.35.0
- **CORS**: cors 2.8.5
- **Environment**: dotenv 17.2.3

**Frontend:**
- **Framework**: React 19.1.1
- **Build Tool**: Vite 7.1.7
- **Routing**: react-router-dom 7.9.3
- **Maps**: react-leaflet 5.0.0, leaflet 1.9.4
- **Icons**: @fortawesome/react-fontawesome 3.1.0
- **Styling**: SCSS/CSS
- **Web Server**: Nginx (production)

---

## API Backend Architecture

### Directory Structure

```
api/
├── src/
│   └── index.js          # Main Express server file
├── public/               # Static files (if any)
├── components/           # HTML components (legacy)
├── Dockerfile            # Multi-stage Docker build
├── package.json          # Dependencies and scripts
└── README.md            # Basic documentation
```

### Core Functionality

The API backend serves as a **RESTful API gateway** that:

1. **Connects to InfluxDB**: Uses InfluxDB client library to query time-series data
2. **Executes Flux Queries**: Accepts custom Flux queries from the frontend
3. **Provides Machine Summaries**: Pre-built endpoints for specific device types
4. **Handles CORS**: Configures cross-origin resource sharing for frontend access
5. **Health Monitoring**: Provides health check endpoints

### Main Server File (`api/src/index.js`)

#### Key Features:

1. **InfluxDB Connection Setup**
   ```javascript
   const influx = new InfluxDB({ 
     url: INFLUXDB_BASE_URL, 
     token, 
     timeout: 10000 
   });
   const queryApi = influx.getQueryApi(org);
   ```

2. **CORS Configuration**
   - Supports multiple origins (development and production)
   - Configurable via `CORS_ORIGIN` environment variable
   - Default origins: `localhost:5173`, `localhost:3000`, production VPS

3. **Query Function**
   - Wraps InfluxDB query execution in a Promise
   - Transforms Flux query results into JavaScript objects
   - Handles errors gracefully

4. **API Endpoints**:
   - `POST /api/query`: Execute custom Flux queries
   - `GET /api/summary/:machine`: Get latest data for specific machine types
   - `GET /health`: Health check endpoint
   - `GET /`: Service information endpoint

### Machine Type Mapping

The API maps user-friendly machine names to InfluxDB measurement names:

```javascript
const machines = {
    "big_turbine": "wind_turbine_data",
    "charger": "photovoltaic_data",
    "heat_boiler": "heat_boiler_data",
    "biogas": "biogas_plant_data",
    "storage": "energy_storage_data"
}
```

### Environment Variables

Required environment variables for the API:

- `INFLUXDB_URL`: InfluxDB server URL (default: `http://robert108.mikrus.xyz:40101`)
- `TEST_TOKEN`: InfluxDB authentication token
- `INFLUXDB_ORG`: Organization name (default: `renewable_energy_org`)
- `INFLUXDB_BUCKET`: Bucket name (default: `renewable_energy`)
- `CORS_ORIGIN`: Allowed CORS origins (comma-separated)
- `PORT`: Server port (default: `3001`)
- `VERCEL`: Deployment platform flag (for Vercel compatibility)

### Docker Configuration

The API uses a **multi-stage Docker build**:

1. **Builder Stage**: Installs production dependencies
2. **Production Stage**: 
   - Creates non-root user for security
   - Copies application files
   - Exposes port 3001
   - Includes health check

**Health Check**: `GET /health` endpoint every 30 seconds

---

## Frontend Architecture

### Directory Structure

```
frontend/
├── src/
│   ├── api/                    # API client functions
│   │   ├── Server.jsx          # API base URL configuration
│   │   ├── Photovoltaic.jsx    # Photovoltaic data fetcher
│   │   ├── WindTurbine.jsx     # Wind turbine data fetcher
│   │   ├── MarkersData.jsx     # Map markers configuration
│   │   ├── RoomsData.jsx       # Room overlay data
│   │   └── EletricLinesData.jsx # Electrical lines overlay
│   ├── components/             # Reusable React components
│   │   ├── Header.jsx          # Navigation header
│   │   ├── Footer.jsx          # Page footer
│   │   ├── MapSVG.jsx          # SVG map component
│   │   ├── DarkModeToggle.jsx  # Dark mode switcher
│   │   └── AutoFitText.jsx     # Auto-sizing text component
│   ├── pages/                  # Page components
│   │   ├── Home.jsx            # Main map page
│   │   ├── Device.jsx          # Device detail page
│   │   └── About.jsx           # About page
│   ├── services/               # Service layer
│   │   └── apiService.js       # Centralized API service
│   ├── hooks/                  # Custom React hooks
│   │   └── useDeviceData.js    # Device data fetching hook
│   ├── config/                 # Configuration files
│   │   └── api.js              # API configuration
│   ├── styles/                 # Stylesheets
│   │   ├── index.css           # Global styles
│   │   ├── App.css             # App component styles
│   │   ├── Home.scss           # Home page styles
│   │   ├── Device.scss         # Device page styles
│   │   └── Header.scss         # Header styles
│   ├── assets/                 # Static assets
│   ├── App.jsx                 # Main app component
│   └── main.jsx                # Application entry point
├── public/                     # Public static files
│   ├── *.png                   # Device images
│   └── *.svg                   # SVG assets
├── Dockerfile                  # Multi-stage Docker build
├── nginx.conf                  # Nginx configuration
├── vite.config.js              # Vite build configuration
├── package.json                # Dependencies
└── ENV_SETUP.md                # Environment setup guide
```

### Core Functionality

The frontend is a **Single Page Application (SPA)** that provides:

1. **Interactive Map Visualization**: Leaflet-based map with SVG overlays
2. **Real-time Device Monitoring**: Displays live data from renewable energy devices
3. **Device Detail Pages**: Individual device information and controls
4. **Responsive Design**: Works on desktop and mobile devices
5. **Dark Mode Support**: Theme switching capability

### Key Components

#### 1. **App.jsx** - Main Application Component

- Sets up React Router for navigation
- Defines application routes
- Renders Header, Footer, and main content area
- Routes:
  - `/`: Home page (map view)
  - `/about`: About page
  - `/device/:deviceID`: Device detail page

#### 2. **Home.jsx** - Main Map Page

**Features:**
- Interactive Leaflet map with custom CRS (Coordinate Reference System)
- SVG overlay showing facility layout
- Real-time data markers for devices
- Layer controls (rooms, electrical lines, markers)
- Auto-refreshing device data (1 second interval)

**Data Fetching:**
- Fetches wind turbine and photovoltaic data
- Updates marker information in real-time
- Displays device metrics (wind speed, power output, temperature, etc.)

**Map Configuration:**
- Custom bounds and zoom levels
- Simple CRS for custom coordinate system
- SVG overlay with device markers
- Interactive markers with click navigation

#### 3. **Device.jsx** - Device Detail Page

- Displays device information based on URL parameter
- Shows device image
- Placeholder for SCADA interface (future implementation)

#### 4. **API Service Layer** (`services/apiService.js`)

**Centralized API Client** with:
- Timeout handling (10 seconds default)
- Error handling and retry logic
- Type-safe method signatures
- Convenience methods for each device type:
  - `getPhotovoltaicData()`
  - `getWindTurbineData()`
  - `getHeatBoilerData()`
  - `getBiogasData()`
  - `getEnergyStorageData()`
  - `executeQuery()` - Custom Flux queries

#### 5. **Custom Hook** (`hooks/useDeviceData.js`)

**React Hook** for device data management:
- Automatic data fetching
- Loading and error states
- Auto-refresh capability (configurable interval)
- Manual refetch function
- Last update timestamp

**Usage:**
```javascript
const { data, loading, error, lastUpdate, refetch } = useDeviceData(
  'photovoltaic',  // device type
  '2m',            // time range
  30000            // refresh interval (ms)
);
```

#### 6. **API Client Functions** (`api/` directory)

**Legacy API Functions** (being replaced by `apiService`):
- `Photovoltaic.jsx`: Fetches photovoltaic data
- `WindTurbine.jsx`: Fetches wind turbine data
- `Server.jsx`: API base URL configuration

**Note**: New code should use `apiService` from `services/apiService.js`

#### 7. **Map Components**

**MarkersData.jsx**:
- Defines device marker positions and configurations
- Handles marker rendering with SVG overlays
- Manages marker interactions and navigation
- Displays real-time device metrics

**MapSVG.jsx**:
- Renders the facility layout as SVG
- Provides base map layer

**RoomsData.jsx** & **EletricLinesData.jsx**:
- Overlay components for rooms and electrical lines
- Toggleable via layer controls

### Configuration

#### API Configuration (`config/api.js`)

```javascript
{
  apiUrl: 'http://localhost:3001',           // Base API URL
  apiBaseUrl: 'http://localhost:3001/api',   // API base path
  influxOrg: 'renewable_energy_org',         // InfluxDB org
  influxBucket: 'renewable_energy',          // InfluxDB bucket
  timeout: 10000                             // Request timeout (ms)
}
```

**Environment Variables** (Vite):
- `VITE_API_URL`: API base URL
- `VITE_API_BASE_URL`: API base path
- `VITE_INFLUXDB_ORG`: InfluxDB organization
- `VITE_INFLUXDB_BUCKET`: InfluxDB bucket

**Important**: Vite environment variables are embedded at **build time**, not runtime. Changes require rebuilding.

### Build Configuration

#### Vite Configuration (`vite.config.js`)

- **React Plugin**: With React Compiler enabled
- **Development Server**: Port 5173, accessible from all interfaces
- **Build Optimization**:
  - Code splitting: React vendor bundle, map vendor bundle
  - Minification: esbuild
  - Source maps: Disabled in production

#### Nginx Configuration (`nginx.conf`)

**Production Web Server**:
- Serves static files from `/usr/share/nginx/html`
- SPA routing: All routes fallback to `index.html`
- Gzip compression enabled
- Security headers configured
- Static asset caching (1 year)
- Health check endpoint: `/health`

### Docker Configuration

**Multi-stage Build**:

1. **Builder Stage**:
   - Installs all dependencies (including dev)
   - Builds the React application
   - Embeds environment variables at build time

2. **Production Stage**:
   - Uses Nginx Alpine image
   - Copies built assets
   - Configures Nginx
   - Exposes port 80
   - Health check configured

---

## Data Flow & Communication

### Request Flow

```
User Action (Frontend)
    ↓
React Component
    ↓
apiService / API Client Function
    ↓
HTTP Request (fetch)
    ↓
Express API Endpoint
    ↓
InfluxDB Query (Flux)
    ↓
InfluxDB Database
    ↓
Response (JSON)
    ↓
Frontend Component
    ↓
UI Update
```

### Example: Fetching Photovoltaic Data

1. **User**: Views the Home page
2. **Home.jsx**: Calls `Photovoltaic()` function
3. **API Client**: Makes `GET /api/summary/charger?start=2m` request
4. **Express API**: Receives request, constructs Flux query:
   ```flux
   from(bucket: "renewable_energy")
     |> range(start: -2m)
     |> filter(fn: (r) => r["_measurement"] == "photovoltaic_data")
     |> last()
   ```
5. **InfluxDB**: Executes query, returns latest data points
6. **Express API**: Transforms data to JSON format
7. **Frontend**: Receives JSON, updates marker display

### Real-time Updates

The Home page implements **polling-based real-time updates**:

- **Interval**: 1 second (1000ms)
- **Devices**: Wind turbine and photovoltaic
- **Method**: `useEffect` with `setTimeout` loop
- **Cancellation**: Cleanup function prevents memory leaks

**Future Enhancement**: Consider WebSocket connection for true real-time updates.

### Error Handling

**Frontend**:
- Try-catch blocks in async functions
- Error state management in components
- Console logging for debugging
- Graceful degradation (shows "N/A" for missing data)

**API**:
- Try-catch in route handlers
- HTTP status codes (500 for errors)
- Error messages in JSON response
- Connection timeout handling

---

## Key Components & Files

### API Backend Files

| File | Purpose | Key Features |
|------|---------|--------------|
| `api/src/index.js` | Main server file | Express setup, InfluxDB connection, API routes |
| `api/Dockerfile` | Docker build config | Multi-stage build, security, health checks |
| `api/package.json` | Dependencies | Express, InfluxDB client, CORS, dotenv |

### Frontend Files

| File | Purpose | Key Features |
|------|---------|--------------|
| `frontend/src/main.jsx` | Entry point | React root, Router setup |
| `frontend/src/App.jsx` | Main app component | Route definitions, layout |
| `frontend/src/pages/Home.jsx` | Map page | Interactive map, real-time data |
| `frontend/src/services/apiService.js` | API client | Centralized HTTP requests |
| `frontend/src/hooks/useDeviceData.js` | Data hook | Device data fetching logic |
| `frontend/src/config/api.js` | API config | Environment-based configuration |
| `frontend/vite.config.js` | Build config | Vite settings, code splitting |
| `frontend/nginx.conf` | Web server | Nginx configuration for production |

---

## Configuration & Environment

### API Environment Variables

**Required**:
```bash
INFLUXDB_URL=http://influxdb:8086
TEST_TOKEN=renewable_energy_admin_token_123
INFLUXDB_ORG=renewable_energy_org
INFLUXDB_BUCKET=renewable_energy
CORS_ORIGIN=http://localhost:5173,http://localhost:3000
PORT=3001
```

**Optional**:
```bash
VERCEL=false  # Deployment platform flag
NODE_ENV=development
```

### Frontend Environment Variables

**Required** (build-time):
```bash
VITE_API_URL=http://localhost:3001
VITE_API_BASE_URL=http://localhost:3001/api
VITE_INFLUXDB_ORG=renewable_energy_org
VITE_INFLUXDB_BUCKET=renewable_energy
```

**Note**: These are embedded at build time. Create `.env.development` or `.env.production` files.

### Docker Compose Configuration

**Local Development** (`docker-compose.local.yml`):

**API Service**:
- Port: `3001:3001`
- Environment: Development mode
- Volumes: Source code mounted for hot reload
- Depends on: InfluxDB

**Frontend Service**:
- Port: `3002:80` (Nginx)
- Build args: Environment variables for build
- Depends on: API service
- Health check: `/health` endpoint

### Port Configuration

| Service | Local Port | Production Port | Container Port |
|---------|------------|-----------------|----------------|
| API | 3001 | 40102 | 3001 |
| Frontend | 3002 | 40103 | 80 (Nginx) |
| InfluxDB | 8086 | 40101 | 8086 |

---

## Development Workflow

### Local Development Setup

1. **Start Infrastructure**:
   ```powershell
   docker-compose -f docker-compose.local.yml up -d mosquitto influxdb
   ```

2. **Start API** (Option A - Docker):
   ```powershell
   docker-compose -f docker-compose.local.yml up -d api
   ```

   **Option B - Local Node.js**:
   ```powershell
   cd api
   npm install
   npm run dev  # Uses nodemon for auto-reload
   ```

3. **Start Frontend** (Option A - Docker):
   ```powershell
   docker-compose -f docker-compose.local.yml up -d frontend
   ```

   **Option B - Local Vite**:
   ```powershell
   cd frontend
   npm install
   npm run dev  # Vite dev server on port 5173
   ```

4. **Access Applications**:
   - Frontend: http://localhost:3002 (Docker) or http://localhost:5173 (local)
   - API: http://localhost:3001
   - API Health: http://localhost:3001/health

### Development Scripts

**API**:
- `npm run dev`: Start with nodemon (auto-reload)
- `npm run build`: Start production server

**Frontend**:
- `npm run dev`: Start Vite dev server
- `npm run build`: Build for production
- `npm run preview`: Preview production build
- `npm run lint`: Run ESLint

### Hot Reload

**API** (with nodemon):
- Watches `src/` directory
- Restarts on file changes
- Preserves environment variables

**Frontend** (with Vite):
- Instant HMR (Hot Module Replacement)
- Fast refresh for React components
- Preserves component state

### Debugging

**API**:
- Console logs in route handlers
- Error messages in responses
- InfluxDB connection status logging

**Frontend**:
- React DevTools browser extension
- Console logging in components
- Network tab for API requests
- Vite dev server error overlay

---

## Deployment Architecture

### Docker Deployment

Both services use **multi-stage Docker builds** for optimized production images.

**API Container**:
- Base: `node:20-alpine`
- Non-root user: `nodejs` (UID 1001)
- Health check: `/health` endpoint
- Restart policy: `unless-stopped`

**Frontend Container**:
- Base: `nginx:alpine`
- Static files: Served by Nginx
- SPA routing: All routes → `index.html`
- Health check: `/health` endpoint

### Production Deployment

**VPS Deployment** (Mikrus):
- API: Port 40102
- Frontend: Port 40103
- InfluxDB: Port 40101
- Domain: `robert108.mikrus.xyz`

**Environment Variables**:
- Set in `docker-compose.prod.yml`
- Or via environment file
- API URL: `http://robert108.mikrus.xyz:40102`
- Frontend API URL: `http://robert108.mikrus.xyz:40102`

### Health Checks

**API Health Check**:
```bash
GET /health
Response: { "health": "ok1" }
```

**Frontend Health Check**:
```bash
GET /health
Response: "healthy\n"
```

**Docker Health Checks**:
- Interval: 30 seconds
- Timeout: 10 seconds
- Retries: 3
- Start period: 40s (API), 20s (Frontend)

---

## API Endpoints Reference

### Base URL

- **Local**: `http://localhost:3001`
- **Production**: `http://robert108.mikrus.xyz:40102`

### Endpoints

#### 1. Health Check

```http
GET /health
```

**Response**:
```json
{
  "health": "ok1"
}
```

#### 2. Service Information

```http
GET /
```

**Response**:
```json
{
  "service": "Renewable Energy IoT API",
  "version": "1.0.0",
  "status": "running",
  "endpoints": {
    "health": "/health",
    "api": "/api"
  }
}
```

#### 3. Machine Summary

```http
GET /api/summary/:machine?start=<timeRange>
```

**Parameters**:
- `machine`: Machine type (`big_turbine`, `charger`, `heat_boiler`, `biogas`, `storage`)
- `start` (query): Time range (default: `2m`)

**Example**:
```http
GET /api/summary/charger?start=5m
```

**Response**:
```json
{
  "wind_speed": {
    "_time": "2024-11-25T10:30:00Z",
    "_value": 12.5,
    "_field": "wind_speed",
    "_measurement": "wind_turbine_data"
  },
  "power_output": {
    "_time": "2024-11-25T10:30:00Z",
    "_value": 1500.0,
    "_field": "power_output",
    "_measurement": "wind_turbine_data"
  }
}
```

#### 4. Custom Flux Query

```http
POST /api/query
Content-Type: application/json

{
  "fluxQuery": "from(bucket: \"renewable_energy\") |> range(start: -1h) |> filter(fn: (r) => r[\"_measurement\"] == \"photovoltaic_data\")"
}
```

**Response**:
```json
{
  "field_name": {
    "_time": "2024-11-25T10:30:00Z",
    "_value": 123.45,
    "_field": "field_name",
    "_measurement": "photovoltaic_data"
  }
}
```

**Error Response**:
```json
{
  "error": "Error message here"
}
```

---

## Frontend Components Reference

### Pages

#### Home Page (`pages/Home.jsx`)

**Route**: `/`

**Features**:
- Interactive Leaflet map
- Real-time device data display
- Layer controls (rooms, electrical lines, markers)
- Device marker interactions
- Auto-refreshing data (1s interval)

**Data Sources**:
- Wind turbine data
- Photovoltaic data

#### Device Page (`pages/Device.jsx`)

**Route**: `/device/:deviceID`

**Features**:
- Device information display
- Device image
- SCADA interface placeholder

**Parameters**:
- `deviceID`: Device identifier from `MarkersData`

#### About Page (`pages/About.jsx`)

**Route**: `/about`

**Features**:
- Project information
- System description

### Components

#### Header (`components/Header.jsx`)

**Features**:
- Site name and branding
- Navigation tabs
- Dark mode toggle

#### Footer (`components/Footer.jsx`)

**Features**:
- Footer information
- Links and credits

#### MapSVG (`components/MapSVG.jsx`)

**Features**:
- SVG facility layout
- Base map layer

#### DarkModeToggle (`components/DarkModeToggle.jsx`)

**Features**:
- Theme switching
- Persistent theme preference

#### AutoFitText (`components/AutoFitText.jsx`)

**Features**:
- Auto-sizing text component
- Fits text within specified bounds

### Services

#### API Service (`services/apiService.js`)

**Methods**:
- `healthCheck()`: Check API health
- `getMachineSummary(machine, startTime)`: Get device summary
- `executeQuery(fluxQuery)`: Execute custom Flux query
- `getPhotovoltaicData(startTime)`: Get PV data
- `getWindTurbineData(startTime)`: Get wind turbine data
- `getHeatBoilerData(startTime)`: Get heat boiler data
- `getBiogasData(startTime)`: Get biogas data
- `getEnergyStorageData(startTime)`: Get storage data

### Hooks

#### useDeviceData (`hooks/useDeviceData.js`)

**Parameters**:
- `deviceType`: Device type string
- `timeRange`: Time range (default: `'2m'`)
- `refreshInterval`: Auto-refresh interval in ms (default: `30000`)

**Returns**:
- `data`: Device data object
- `loading`: Loading state boolean
- `error`: Error message string
- `lastUpdate`: Last update timestamp
- `refetch`: Manual refetch function

---

## Best Practices & Recommendations

### API Development

1. **Error Handling**: Always wrap async operations in try-catch
2. **Validation**: Validate input parameters
3. **Logging**: Log errors and important events
4. **Security**: Use environment variables for sensitive data
5. **CORS**: Configure CORS properly for production

### Frontend Development

1. **API Calls**: Use `apiService` instead of direct fetch calls
2. **State Management**: Use React hooks for component state
3. **Error Handling**: Display user-friendly error messages
4. **Loading States**: Show loading indicators during data fetching
5. **Performance**: Use React.memo and useMemo for optimization
6. **Environment Variables**: Remember they're embedded at build time

### Code Organization

1. **Separation of Concerns**: Keep API logic in services, UI in components
2. **Reusability**: Create reusable components and hooks
3. **Type Safety**: Consider migrating to TypeScript
4. **Documentation**: Add JSDoc comments to functions
5. **Testing**: Add unit tests for critical functions

### Future Enhancements

1. **TypeScript Migration**: Add type safety to both frontend and API
2. **WebSocket Support**: Real-time updates instead of polling
3. **Authentication**: Add user authentication and authorization
4. **Error Boundaries**: React error boundaries for better error handling
5. **Testing**: Unit tests, integration tests, E2E tests
6. **API Versioning**: Version API endpoints for backward compatibility
7. **Caching**: Implement response caching for frequently accessed data
8. **Rate Limiting**: Add rate limiting to API endpoints
9. **Monitoring**: Add logging and monitoring (e.g., Sentry)
10. **Documentation**: API documentation with Swagger/OpenAPI

---

## Troubleshooting

### Common Issues

#### API Not Connecting to InfluxDB

**Symptoms**: API returns 500 errors, connection timeouts

**Solutions**:
1. Check `INFLUXDB_URL` environment variable
2. Verify InfluxDB is running and accessible
3. Check `TEST_TOKEN` is valid
4. Verify network connectivity (Docker network)

#### Frontend Not Loading Data

**Symptoms**: Empty markers, "N/A" values

**Solutions**:
1. Check API is running and accessible
2. Verify `VITE_API_URL` is correct (rebuild if changed)
3. Check browser console for CORS errors
4. Verify API health endpoint responds

#### CORS Errors

**Symptoms**: Browser console shows CORS policy errors

**Solutions**:
1. Check `CORS_ORIGIN` includes frontend URL
2. Verify API CORS configuration
3. Check request headers

#### Environment Variables Not Working (Frontend)

**Symptoms**: API calls use wrong URL

**Solutions**:
1. Remember: Vite env vars are embedded at build time
2. Rebuild frontend after changing env vars
3. Check `.env` file is in correct location
4. Verify variable names start with `VITE_`

#### Docker Containers Not Starting

**Symptoms**: Containers exit immediately

**Solutions**:
1. Check Docker logs: `docker logs <container-name>`
2. Verify environment variables are set
3. Check port conflicts
4. Verify dependencies (InfluxDB) are running

---

## Conclusion

This document provides a comprehensive overview of the Frontend and API architecture for the Renewable Energy IoT Monitoring System. The system follows modern best practices with:

- **Separation of concerns** between frontend and backend
- **RESTful API** design
- **React-based** user interface
- **Docker containerization** for deployment
- **Real-time data** visualization
- **Scalable architecture** for future enhancements

For questions or issues, refer to the troubleshooting section or check the individual component documentation.

---

**Last Updated**: 2024-11-25  
**Version**: 1.0  
**Maintainer**: Development Team

