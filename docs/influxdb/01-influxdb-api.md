# 📊 InfluxDB 2.7 RESTful API Guide for React Web App Developers

> **Comprehensive guide for integrating InfluxDB 2.7 RESTful API with React applications for renewable energy IoT monitoring.**

[![InfluxDB](https://img.shields.io/badge/InfluxDB-2.7-green?logo=influxdb)](https://influxdata.com/)
[![React](https://img.shields.io/badge/React-18+-blue?logo=react)](https://reactjs.org/)
[![TypeScript](https://img.shields.io/badge/TypeScript-5.0+-blue?logo=typescript)](https://www.typescriptlang.org/)
[![Docker](https://img.shields.io/badge/Docker-Enabled-blue?logo=docker)](https://www.docker.com/)

---

## 📋 Table of Contents

- [🎯 Overview](#-overview)
- [🔧 System Configuration](#-system-configuration)
- [🔐 Authentication & Security](#-authentication--security)
- [📊 Data Structure & Schema](#-data-structure--schema)
- [🔌 API Endpoints Reference](#-api-endpoints-reference)
- [📈 Querying Data with Flux](#-querying-data-with-flux)
- [⚡ React Integration Patterns](#-react-integration-patterns)
- [🎨 Practical Examples](#-practical-examples)
- [🛡️ Error Handling & Best Practices](#️-error-handling--best-practices)
- [🔍 Performance Optimization](#-performance-optimization)
- [📚 API Reference](#-api-reference)

---

## 🎯 Overview

This guide provides comprehensive documentation for integrating InfluxDB 2.7 RESTful API with **React frontend and Express backend** applications for renewable energy IoT monitoring. Your system uses InfluxDB 2.7 with the following configuration:

**Architecture**: React Frontend ↔ Express Backend ↔ InfluxDB 2.7

### 🚀 Integration Benefits

- **Streaming Analytics**: InfluxDB integrates easily with streaming analytics tools of choice
- **Client Libraries**: Query data directly via API or use client libraries for popular programming languages
- **Full-Stack Architecture**: Express backend handles data processing, React frontend provides UI
- **Scalable Design**: Separation of concerns between frontend, backend, and database layers

### 🔧 Current Setup

- **InfluxDB Version**: 2.7
- **Port**: 8086
- **Organization**: `renewable_energy_org`
- **Bucket**: `renewable_energy`
- **Retention Policy**: 30 days
- **Authentication**: Token-based (disabled for development)

### 📊 Data Flow Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   IoT Devices   │───▶│   MQTT Broker   │───▶│   Node-RED      │───▶│   InfluxDB      │
│   (Solar, Wind, │    │   (Mosquitto)   │    │   (Processing)  │    │   (Time-Series) │
│   Biogas, etc.) │    │   Port 1883     │    │   Port 1880     │    │   Port 8086     │
└─────────────────┘    └─────────────────┘    └─────────────────┘    └─────────────────┘
                                                                              │
                                                                              ▼
                                                                     ┌─────────────────┐
                                                                     │   Express       │
                                                                     │   Backend API   │
                                                                     │   Port 3001     │
                                                                     └─────────────────┘
                                                                              │
                                                                              ▼
                                                                     ┌─────────────────┐
                                                                     │   React App     │
                                                                     │   (Frontend)    │
                                                                     │   Port 3000     │
                                                                     └─────────────────┘
```

---

## 🔧 System Configuration

### 📋 Environment Variables

Your InfluxDB is configured with these environment variables:

```bash
# Authentication & Access
INFLUXDB_ADMIN_USER=admin
INFLUXDB_ADMIN_PASSWORD=admin_password_123
INFLUXDB_ADMIN_TOKEN=renewable_energy_admin_token_123
INFLUXDB_HTTP_AUTH_ENABLED=false

# Database Configuration
INFLUXDB_DB=renewable_energy
INFLUXDB_ORG=renewable_energy_org
INFLUXDB_BUCKET=renewable_energy
INFLUXDB_RETENTION=30d

# HTTP Configuration
INFLUXDB_HTTP_BIND_ADDRESS=:8086
INFLUXDB_HTTP_PORT=8086
INFLUXDB_HTTP_MAX_CONNECTION_LIMIT=0
INFLUXDB_HTTP_READ_TIMEOUT=30s
```

### 🌐 API Base URL

```typescript
const INFLUXDB_BASE_URL = 'http://localhost:8086'
const INFLUXDB_API_VERSION = 'v2'
const INFLUXDB_API_URL = `${INFLUXDB_BASE_URL}/api/${INFLUXDB_API_VERSION}`
```

---

## 🔐 Authentication & Security

### 🔑 Token-Based Authentication

InfluxDB 2.7 uses token-based authentication. For your Express backend:

```typescript
// Configuration
const INFLUXDB_CONFIG = {
  url: 'http://localhost:8086',
  token: 'renewable_energy_admin_token_123',
  org: 'renewable_energy_org',
  bucket: 'renewable_energy'
}

// Headers for API requests
const getAuthHeaders = () => ({
  'Authorization': `Token ${INFLUXDB_CONFIG.token}`,
  'Content-Type': 'application/json'
})
```

### 🛡️ Security Best Practices

```typescript
// Environment-based configuration
const getInfluxDBConfig = () => {
  const isProduction = process.env.NODE_ENV === 'production'
  
  return {
    url: isProduction 
      ? process.env.REACT_APP_INFLUXDB_URL 
      : 'http://localhost:8086',
    token: process.env.REACT_APP_INFLUXDB_TOKEN,
    org: process.env.REACT_APP_INFLUXDB_ORG || 'renewable_energy_org',
    bucket: process.env.REACT_APP_INFLUXDB_BUCKET || 'renewable_energy'
  }
}

// Secure token management
class InfluxDBAuth {
  private static instance: InfluxDBAuth
  private token: string | null = null

  static getInstance(): InfluxDBAuth {
    if (!InfluxDBAuth.instance) {
      InfluxDBAuth.instance = new InfluxDBAuth()
    }
    return InfluxDBAuth.instance
  }

  setToken(token: string): void {
    this.token = token
    localStorage.setItem('influxdb_token', token)
  }

  getToken(): string | null {
    if (!this.token) {
      this.token = localStorage.getItem('influxdb_token')
    }
    return this.token
  }

  clearToken(): void {
    this.token = null
    localStorage.removeItem('influxdb_token')
  }

  isAuthenticated(): boolean {
    return !!this.getToken()
  }
}
```

---

## 📊 Data Structure & Schema

### 🏗️ Measurement Structure

Your system stores data in the following measurements:

#### 1. **photovoltaic_data**
```typescript
interface PhotovoltaicData {
  timestamp: string
  device_id: string
  device_type: 'photovoltaic'
  location: string
  status: 'operational' | 'fault'
  data: {
    irradiance: number      // W/m²
    temperature: number     // °C
    voltage: number         // V
    current: number         // A
    power_output: number    // W
  }
  fault_type?: string[]
}
```

#### 2. **wind_turbine_data**
```typescript
interface WindTurbineData {
  timestamp: string
  device_id: string
  device_type: 'wind_turbine'
  location: string
  status: 'operational' | 'fault'
  data: {
    wind_speed: number      // m/s
    wind_direction: number  // degrees
    rotor_speed: number     // RPM
    power_output: number    // kW
    temperature: number     // °C
  }
  fault_type?: string[]
}
```

#### 3. **biogas_plant_data**
```typescript
interface BiogasPlantData {
  timestamp: string
  device_id: string
  device_type: 'biogas_plant'
  location: string
  status: 'operational' | 'fault'
  data: {
    gas_flow_rate: number   // m³/h
    methane_concentration: number // %
    temperature: number     // °C
    pressure: number        // bar
    power_output: number    // kW
  }
  fault_type?: string[]
}
```

#### 4. **heat_boiler_data**
```typescript
interface HeatBoilerData {
  timestamp: string
  device_id: string
  device_type: 'heat_boiler'
  location: string
  status: 'operational' | 'fault'
  data: {
    temperature: number     // °C
    pressure: number        // bar
    fuel_consumption: number // L/h
    efficiency: number      // %
    power_output: number    // kW
  }
  fault_type?: string[]
}
```

#### 5. **energy_storage_data**
```typescript
interface EnergyStorageData {
  timestamp: string
  device_id: string
  device_type: 'energy_storage'
  location: string
  status: 'operational' | 'fault'
  data: {
    state_of_charge: number // %
    voltage: number         // V
    current: number         // A
    temperature: number     // °C
    power_output: number    // kW
  }
  fault_type?: string[]
}
```

### 🏷️ Tags and Fields

```typescript
// Tags (indexed for fast queries)
const TAGS = {
  device_id: 'string',
  device_type: 'string',
  location: 'string',
  status: 'string'
}

// Fields (values stored as time-series data)
const FIELDS = {
  // Common fields
  temperature: 'float',
  power_output: 'float',
  
  // Device-specific fields
  irradiance: 'float',        // PV only
  voltage: 'float',           // PV, Storage
  current: 'float',           // PV, Storage
  wind_speed: 'float',        // Wind only
  wind_direction: 'float',    // Wind only
  rotor_speed: 'float',       // Wind only
  gas_flow_rate: 'float',     // Biogas only
  methane_concentration: 'float', // Biogas only
  pressure: 'float',          // Biogas, Heat
  fuel_consumption: 'float',  // Heat only
  efficiency: 'float',        // Heat only
  state_of_charge: 'float'    // Storage only
}
```

---

## 🔌 API Endpoints Reference

### 📊 Query API

#### **POST** `/api/v2/query`

Execute Flux queries to retrieve data.

```typescript
// Basic query structure
const queryEndpoint = `${INFLUXDB_BASE_URL}/api/v2/query`

// Query parameters
interface QueryParams {
  org: string
  bucket?: string
  query: string
}

// Example request
const executeQuery = async (fluxQuery: string) => {
  const response = await fetch(queryEndpoint, {
    method: 'POST',
    headers: {
      'Authorization': `Token ${INFLUXDB_CONFIG.token}`,
      'Content-Type': 'application/vnd.flux',
      'Accept': 'application/csv'
    },
    body: fluxQuery
  })
  
  if (!response.ok) {
    throw new Error(`Query failed: ${response.statusText}`)
  }
  
  return response.text()
}
```

### 📝 Write API

#### **POST** `/api/v2/write`

Write data points to InfluxDB.

```typescript
// Write endpoint
const writeEndpoint = `${INFLUXDB_BASE_URL}/api/v2/write`

// Write parameters
interface WriteParams {
  org: string
  bucket: string
  precision?: 'ns' | 'us' | 'ms' | 's'
}

// Example write request
const writeData = async (data: string) => {
  const params = new URLSearchParams({
    org: INFLUXDB_CONFIG.org,
    bucket: INFLUXDB_CONFIG.bucket,
    precision: 'ms'
  })
  
  const response = await fetch(`${writeEndpoint}?${params}`, {
    method: 'POST',
    headers: {
      'Authorization': `Token ${INFLUXDB_CONFIG.token}`,
      'Content-Type': 'text/plain; charset=utf-8'
    },
    body: data
  })
  
  if (!response.ok) {
    throw new Error(`Write failed: ${response.statusText}`)
  }
  
  return response
}
```

### 🏢 Organizations API

#### **GET** `/api/v2/orgs`

List organizations.

```typescript
const getOrganizations = async () => {
  const response = await fetch(`${INFLUXDB_BASE_URL}/api/v2/orgs`, {
    headers: getAuthHeaders()
  })
  
  return response.json()
}
```

### 🪣 Buckets API

#### **GET** `/api/v2/buckets`

List buckets in an organization.

```typescript
const getBuckets = async () => {
  const params = new URLSearchParams({ org: INFLUXDB_CONFIG.org })
  const response = await fetch(`${INFLUXDB_BASE_URL}/api/v2/buckets?${params}`, {
    headers: getAuthHeaders()
  })
  
  return response.json()
}
```

### 🔑 Tokens API

#### **GET** `/api/v2/authorizations`

List authorization tokens.

```typescript
const getTokens = async () => {
  const response = await fetch(`${INFLUXDB_BASE_URL}/api/v2/authorizations`, {
    headers: getAuthHeaders()
  })
  
  return response.json()
}
```

---

## 📈 Querying Data with Flux

### 🔍 Basic Flux Queries

#### 1. **Simple Data Retrieval**

```typescript
// Get all photovoltaic data from the last hour
const getPVData = () => {
  const fluxQuery = `
    from(bucket: "${INFLUXDB_CONFIG.bucket}")
      |> range(start: -1h)
      |> filter(fn: (r) => r._measurement == "photovoltaic_data")
      |> sort(columns: ["_time"])
  `
  return executeQuery(fluxQuery)
}
```

#### 2. **Filtered Queries**

```typescript
// Get data for specific device
const getDeviceData = (deviceId: string, timeRange: string = '-1h') => {
  const fluxQuery = `
    from(bucket: "${INFLUXDB_CONFIG.bucket}")
      |> range(start: ${timeRange})
      |> filter(fn: (r) => r._measurement == "photovoltaic_data")
      |> filter(fn: (r) => r.device_id == "${deviceId}")
      |> sort(columns: ["_time"])
  `
  return executeQuery(fluxQuery)
}
```

#### 3. **Aggregated Queries**

```typescript
// Get hourly averages for power output
const getHourlyPowerAverages = (timeRange: string = '-24h') => {
  const fluxQuery = `
    from(bucket: "${INFLUXDB_CONFIG.bucket}")
      |> range(start: ${timeRange})
      |> filter(fn: (r) => r._measurement == "photovoltaic_data")
      |> filter(fn: (r) => r._field == "power_output")
      |> aggregateWindow(every: 1h, fn: mean)
      |> sort(columns: ["_time"])
  `
  return executeQuery(fluxQuery)
}
```

#### 4. **Multi-Field Queries**

```typescript
// Get multiple fields for a device
const getDeviceMetrics = (deviceId: string) => {
  const fluxQuery = `
    from(bucket: "${INFLUXDB_CONFIG.bucket}")
      |> range(start: -1h)
      |> filter(fn: (r) => r._measurement == "photovoltaic_data")
      |> filter(fn: (r) => r.device_id == "${deviceId}")
      |> filter(fn: (r) => r._field == "power_output" or r._field == "temperature" or r._field == "efficiency")
      |> pivot(rowKey:["_time"], columnKey: ["_field"], valueColumn: "_value")
      |> sort(columns: ["_time"])
  `
  return executeQuery(fluxQuery)
}
```

### 📊 Advanced Flux Queries

#### 1. **Statistical Analysis**

```typescript
// Get statistical summary for power output
const getPowerStatistics = (timeRange: string = '-24h') => {
  const fluxQuery = `
    from(bucket: "${INFLUXDB_CONFIG.bucket}")
      |> range(start: ${timeRange})
      |> filter(fn: (r) => r._measurement == "photovoltaic_data")
      |> filter(fn: (r) => r._field == "power_output")
      |> mean()
      |> yield(name: "mean")
      
    from(bucket: "${INFLUXDB_CONFIG.bucket}")
      |> range(start: ${timeRange})
      |> filter(fn: (r) => r._measurement == "photovoltaic_data")
      |> filter(fn: (r) => r._field == "power_output")
      |> stddev()
      |> yield(name: "stddev")
      
    from(bucket: "${INFLUXDB_CONFIG.bucket}")
      |> range(start: ${timeRange})
      |> filter(fn: (r) => r._measurement == "photovoltaic_data")
      |> filter(fn: (r) => r._field == "power_output")
      |> max()
      |> yield(name: "max")
  `
  return executeQuery(fluxQuery)
}
```

#### 2. **Time-Based Grouping**

```typescript
// Get daily energy production
const getDailyEnergyProduction = (days: number = 7) => {
  const fluxQuery = `
    from(bucket: "${INFLUXDB_CONFIG.bucket}")
      |> range(start: -${days}d)
      |> filter(fn: (r) => r._measurement == "photovoltaic_data")
      |> filter(fn: (r) => r._field == "power_output")
      |> aggregateWindow(every: 1d, fn: sum)
      |> map(fn: (r) => ({ r with _value: r._value / 1000.0 })) // Convert to kWh
      |> sort(columns: ["_time"])
  `
  return executeQuery(fluxQuery)
}
```

#### 3. **Device Comparison**

```typescript
// Compare multiple devices
const compareDevices = (deviceIds: string[]) => {
  const deviceFilter = deviceIds.map(id => `r.device_id == "${id}"`).join(' or ')
  
  const fluxQuery = `
    from(bucket: "${INFLUXDB_CONFIG.bucket}")
      |> range(start: -1h)
      |> filter(fn: (r) => r._measurement == "photovoltaic_data")
      |> filter(fn: (r) => r._field == "power_output")
      |> filter(fn: (r) => ${deviceFilter})
      |> aggregateWindow(every: 5m, fn: mean)
      |> sort(columns: ["_time", "device_id"])
  `
  return executeQuery(fluxQuery)
}
```

---

## ⚡ Express Backend + React Frontend Integration Patterns

### 🔌 Express Backend API Endpoints

#### 1. **Basic Data Fetching Endpoint**

```typescript
import { useState, useEffect, useCallback } from 'react'

interface UseInfluxDataOptions {
  measurement: string
  timeRange: string
  deviceId?: string
  field?: string
  interval?: number
}

// Express.js endpoint for fetching InfluxDB data
app.get('/api/energy-data', async (req, res) => {
  try {
    const { measurement, timeRange, deviceId, field } = req.query
    
    let fluxQuery = `
      from(bucket: "${INFLUXDB_CONFIG.bucket}")
        |> range(start: ${timeRange || '-1h'})
        |> filter(fn: (r) => r._measurement == "${measurement}")
    `
    
    if (deviceId) {
      fluxQuery += `|> filter(fn: (r) => r.device_id == "${deviceId}")`
    }
    
    if (field) {
      fluxQuery += `|> filter(fn: (r) => r._field == "${field}")`
    }
    
    fluxQuery += `|> sort(columns: ["_time"])`
    
    const result = await executeQuery(fluxQuery)
    const parsedData = parseCSVResult(result)
    
    res.json({
      success: true,
      data: parsedData,
      timestamp: new Date().toISOString()
    })
  } catch (error) {
    res.status(500).json({
      success: false,
      error: error instanceof Error ? error.message : 'Unknown error'
    })
  }
})
```

#### 2. **Real-Time Data Endpoint**

```typescript
// Express.js endpoint for real-time data with WebSocket support
app.get('/api/energy-data/realtime', async (req, res) => {
  try {
    const { measurement, deviceId } = req.query
    
    const fluxQuery = `
      from(bucket: "${INFLUXDB_CONFIG.bucket}")
        |> range(start: -5m)
        |> filter(fn: (r) => r._measurement == "${measurement}")
        ${deviceId ? `|> filter(fn: (r) => r.device_id == "${deviceId}")` : ''}
        |> sort(columns: ["_time"])
    `
    
    const result = await executeQuery(fluxQuery)
    const parsedData = parseCSVResult(result)
    
    res.json({
      success: true,
      data: parsedData,
      timestamp: new Date().toISOString()
    })
  } catch (error) {
    res.status(500).json({
      success: false,
      error: error instanceof Error ? error.message : 'Unknown error'
    })
  }
})
```

#### 3. **Historical Data Endpoint**

```typescript
// Express.js endpoint for historical data
app.get('/api/energy-data/historical', async (req, res) => {
  try {
    const { measurement, timeRange, deviceId, aggregation } = req.query
    
    let fluxQuery = `
      from(bucket: "${INFLUXDB_CONFIG.bucket}")
        |> range(start: ${timeRange || '-24h'})
        |> filter(fn: (r) => r._measurement == "${measurement}")
    `
    
    if (deviceId) {
      fluxQuery += `|> filter(fn: (r) => r.device_id == "${deviceId}")`
    }
    
    if (aggregation) {
      fluxQuery += `|> aggregateWindow(every: ${aggregation}, fn: mean)`
    }
    
    fluxQuery += `|> sort(columns: ["_time"])`
    
    const result = await executeQuery(fluxQuery)
    const parsedData = parseCSVResult(result)
    
    res.json({
      success: true,
      data: parsedData,
      timestamp: new Date().toISOString()
    })
  } catch (error) {
    res.status(500).json({
      success: false,
      error: error instanceof Error ? error.message : 'Unknown error'
    })
  }
})
```

### 🎨 React Frontend Integration

#### React Hooks for API Consumption

```typescript
// React hook for consuming Express backend API
export function useEnergyData(measurement: string, timeRange: string = '-1h') {
  const [data, setData] = useState<any[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    const fetchData = async () => {
      try {
        setLoading(true)
        const response = await fetch(`/api/energy-data?measurement=${measurement}&timeRange=${timeRange}`)
        const result = await response.json()
        
        if (result.success) {
          setData(result.data)
        } else {
          setError(result.error)
        }
      } catch (err) {
        setError(err instanceof Error ? err.message : 'Unknown error')
      } finally {
        setLoading(false)
      }
    }

    fetchData()
  }, [measurement, timeRange])

  return { data, loading, error }
}
```

### 🎨 Data Parsing Utilities

```typescript
// Parse CSV result from InfluxDB
export function parseCSVResult(csvData: string): any[] {
  const lines = csvData.trim().split('\n')
  const headers = lines[0].split(',')
  const data: any[] = []
  
  for (let i = 1; i < lines.length; i++) {
    const values = lines[i].split(',')
    const row: any = {}
    
    headers.forEach((header, index) => {
      row[header.trim()] = values[index]?.trim() || ''
    })
    
    data.push(row)
  }
  
  return data
}

// Convert to chart-friendly format
export function convertToChartData(influxData: any[], valueField: string) {
  return influxData.map(row => ({
    time: new Date(row._time).toLocaleTimeString(),
    value: parseFloat(row._value) || 0,
    device: row.device_id
  }))
}
```

---

## 🎨 Practical Examples

### 📊 Dashboard Components

#### 1. **Power Output Chart**

```typescript
import React from 'react'
import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, Legend } from 'recharts'
import { useInfluxData } from '../hooks/useInfluxData'

interface PowerOutputChartProps {
  deviceId?: string
  timeRange?: string
}

export function PowerOutputChart({ 
  deviceId, 
  timeRange = '-1h' 
}: PowerOutputChartProps) {
  const { data, loading, error } = useInfluxData({
    measurement: 'photovoltaic_data',
    timeRange,
    deviceId,
    field: 'power_output',
    interval: 30000 // 30 seconds
  })

  if (loading) return <div>Loading power data...</div>
  if (error) return <div>Error: {error}</div>

  const chartData = convertToChartData(data, '_value')

  return (
    <div className="power-chart">
      <h3>Power Output</h3>
      <LineChart width={600} height={300} data={chartData}>
        <CartesianGrid strokeDasharray="3 3" />
        <XAxis dataKey="time" />
        <YAxis label={{ value: 'Power (W)', angle: -90, position: 'insideLeft' }} />
        <Tooltip />
        <Legend />
        <Line 
          type="monotone" 
          dataKey="value" 
          stroke="#8884d8" 
          strokeWidth={2}
          dot={false}
        />
      </LineChart>
    </div>
  )
}
```

#### 2. **Device Status Dashboard**

```typescript
import React from 'react'
import { useInfluxData } from '../hooks/useInfluxData'

interface DeviceStatusProps {
  deviceId: string
}

export function DeviceStatus({ deviceId }: DeviceStatusProps) {
  const { data, loading } = useInfluxData({
    measurement: 'photovoltaic_data',
    timeRange: '-5m',
    deviceId,
    interval: 10000
  })

  if (loading) return <div>Loading device status...</div>

  const latestData = data[data.length - 1]
  const status = latestData?.status || 'unknown'

  return (
    <div className={`device-status ${status}`}>
      <h4>Device: {deviceId}</h4>
      <div className="status-indicator">
        Status: <span className={status}>{status}</span>
      </div>
      {latestData && (
        <div className="metrics">
          <p>Power: {parseFloat(latestData._value || 0).toFixed(2)} W</p>
          <p>Temperature: {parseFloat(latestData.temperature || 0).toFixed(1)}°C</p>
        </div>
      )}
    </div>
  )
}
```

#### 3. **Energy Production Summary**

```typescript
import React from 'react'
import { useInfluxData } from '../hooks/useInfluxData'

export function EnergyProductionSummary() {
  const { data, loading } = useInfluxData({
    measurement: 'photovoltaic_data',
    timeRange: '-24h',
    field: 'power_output'
  })

  if (loading) return <div>Loading production data...</div>

  // Calculate total energy production (kWh)
  const totalEnergy = data.reduce((sum, row) => {
    return sum + (parseFloat(row._value) || 0)
  }, 0) / 1000 // Convert to kWh

  const averagePower = data.length > 0 
    ? data.reduce((sum, row) => sum + (parseFloat(row._value) || 0), 0) / data.length
    : 0

  return (
    <div className="energy-summary">
      <h3>24-Hour Energy Summary</h3>
      <div className="metrics">
        <div className="metric">
          <label>Total Energy:</label>
          <span>{totalEnergy.toFixed(2)} kWh</span>
        </div>
        <div className="metric">
          <label>Average Power:</label>
          <span>{averagePower.toFixed(2)} W</span>
        </div>
        <div className="metric">
          <label>Data Points:</label>
          <span>{data.length}</span>
        </div>
      </div>
    </div>
  )
}
```

---

## 🛡️ Error Handling & Best Practices

### 🔧 Error Handling Patterns

```typescript
// Comprehensive error handling
class InfluxDBError extends Error {
  constructor(
    message: string,
    public statusCode?: number,
    public endpoint?: string
  ) {
    super(message)
    this.name = 'InfluxDBError'
  }
}

// Enhanced query execution with error handling
const executeQueryWithRetry = async (
  fluxQuery: string, 
  maxRetries: number = 3
): Promise<string> => {
  let lastError: Error | null = null
  
  for (let attempt = 1; attempt <= maxRetries; attempt++) {
    try {
      const response = await fetch(queryEndpoint, {
        method: 'POST',
        headers: {
          'Authorization': `Token ${INFLUXDB_CONFIG.token}`,
          'Content-Type': 'application/vnd.flux',
          'Accept': 'application/csv'
        },
        body: fluxQuery
      })
      
      if (!response.ok) {
        throw new InfluxDBError(
          `Query failed: ${response.statusText}`,
          response.status,
          queryEndpoint
        )
      }
      
      return await response.text()
    } catch (error) {
      lastError = error instanceof Error ? error : new Error('Unknown error')
      
      if (attempt < maxRetries) {
        // Exponential backoff
        await new Promise(resolve => 
          setTimeout(resolve, Math.pow(2, attempt) * 1000)
        )
        continue
      }
    }
  }
  
  throw lastError
}
```

### 📊 Data Validation

```typescript
// Validate InfluxDB response
const validateInfluxResponse = (data: any[]): boolean => {
  if (!Array.isArray(data)) {
    throw new Error('Invalid response format: expected array')
  }
  
  if (data.length === 0) {
    console.warn('No data returned from query')
    return false
  }
  
  // Check for required fields
  const requiredFields = ['_time', '_value', '_field', '_measurement']
  const firstRow = data[0]
  
  for (const field of requiredFields) {
    if (!(field in firstRow)) {
      throw new Error(`Missing required field: ${field}`)
    }
  }
  
  return true
}

// Sanitize data values
const sanitizeData = (data: any[]): any[] => {
  return data.map(row => ({
    ...row,
    _value: parseFloat(row._value) || 0,
    _time: new Date(row._time).toISOString()
  }))
}
```

### 🔄 Connection Management

```typescript
// Connection health check
const checkInfluxHealth = async (): Promise<boolean> => {
  try {
    const response = await fetch(`${INFLUXDB_BASE_URL}/health`)
    return response.ok
  } catch (error) {
    console.error('InfluxDB health check failed:', error)
    return false
  }
}

// Connection status hook
export function useInfluxHealth() {
  const [isHealthy, setIsHealthy] = useState<boolean | null>(null)
  const [lastCheck, setLastCheck] = useState<Date | null>(null)

  const checkHealth = useCallback(async () => {
    const healthy = await checkInfluxHealth()
    setIsHealthy(healthy)
    setLastCheck(new Date())
  }, [])

  useEffect(() => {
    checkHealth()
    const interval = setInterval(checkHealth, 30000) // Check every 30 seconds
    return () => clearInterval(interval)
  }, [checkHealth])

  return { isHealthy, lastCheck, checkHealth }
}
```

---

## 🔍 Performance Optimization

### ⚡ Query Optimization

```typescript
// Optimized query patterns
const optimizedQueries = {
  // Use specific time ranges
  getRecentData: (minutes: number = 5) => `
    from(bucket: "${INFLUXDB_CONFIG.bucket}")
      |> range(start: -${minutes}m)
      |> filter(fn: (r) => r._measurement == "photovoltaic_data")
      |> filter(fn: (r) => r._field == "power_output")
      |> sort(columns: ["_time"])
  `,
  
  // Use aggregation for large datasets
  getAggregatedData: (timeRange: string, window: string) => `
    from(bucket: "${INFLUXDB_CONFIG.bucket}")
      |> range(start: ${timeRange})
      |> filter(fn: (r) => r._measurement == "photovoltaic_data")
      |> filter(fn: (r) => r._field == "power_output")
      |> aggregateWindow(every: ${window}, fn: mean)
      |> sort(columns: ["_time"])
  `,
  
  // Limit results for performance
  getLimitedData: (limit: number = 100) => `
    from(bucket: "${INFLUXDB_CONFIG.bucket}")
      |> range(start: -1h)
      |> filter(fn: (r) => r._measurement == "photovoltaic_data")
      |> limit(n: ${limit})
      |> sort(columns: ["_time"])
  `
}
```

### 🗄️ Caching Strategies

```typescript
// Simple in-memory cache
class InfluxCache {
  private cache = new Map<string, { data: any; timestamp: number }>()
  private ttl = 30000 // 30 seconds

  set(key: string, data: any): void {
    this.cache.set(key, { data, timestamp: Date.now() })
  }

  get(key: string): any | null {
    const item = this.cache.get(key)
    if (!item) return null
    
    if (Date.now() - item.timestamp > this.ttl) {
      this.cache.delete(key)
      return null
    }
    
    return item.data
  }

  clear(): void {
    this.cache.clear()
  }
}

const influxCache = new InfluxCache()

// Cached query execution
const executeQueryWithCache = async (
  fluxQuery: string, 
  cacheKey?: string
): Promise<any> => {
  if (cacheKey) {
    const cached = influxCache.get(cacheKey)
    if (cached) return cached
  }
  
  const result = await executeQuery(fluxQuery)
  const parsed = parseCSVResult(result)
  
  if (cacheKey) {
    influxCache.set(cacheKey, parsed)
  }
  
  return parsed
}
```

### 📈 Batch Operations

```typescript
// Batch multiple queries
const executeBatchQueries = async (queries: Array<{
  key: string
  query: string
}>): Promise<Record<string, any>> => {
  const results: Record<string, any> = {}
  
  // Execute queries in parallel
  const promises = queries.map(async ({ key, query }) => {
    try {
      const result = await executeQuery(query)
      results[key] = parseCSVResult(result)
    } catch (error) {
      console.error(`Query ${key} failed:`, error)
      results[key] = []
    }
  })
  
  await Promise.all(promises)
  return results
}

// Example usage
const getDashboardData = async (deviceId: string) => {
  const queries = [
    {
      key: 'power',
      query: `from(bucket: "${INFLUXDB_CONFIG.bucket}")
        |> range(start: -1h)
        |> filter(fn: (r) => r._measurement == "photovoltaic_data")
        |> filter(fn: (r) => r.device_id == "${deviceId}")
        |> filter(fn: (r) => r._field == "power_output")`
    },
    {
      key: 'temperature',
      query: `from(bucket: "${INFLUXDB_CONFIG.bucket}")
        |> range(start: -1h)
        |> filter(fn: (r) => r._measurement == "photovoltaic_data")
        |> filter(fn: (r) => r.device_id == "${deviceId}")
        |> filter(fn: (r) => r._field == "temperature")`
    }
  ]
  
  return executeBatchQueries(queries)
}
```

---

## 📚 API Reference

### 🔌 Complete API Client

```typescript
class InfluxDBClient {
  private baseUrl: string
  private token: string
  private org: string
  private bucket: string

  constructor(config: {
    url: string
    token: string
    org: string
    bucket: string
  }) {
    this.baseUrl = config.url
    this.token = config.token
    this.org = config.org
    this.bucket = config.bucket
  }

  private getHeaders(contentType: string = 'application/json') {
    return {
      'Authorization': `Token ${this.token}`,
      'Content-Type': contentType
    }
  }

  // Query data
  async query(fluxQuery: string): Promise<any[]> {
    const response = await fetch(`${this.baseUrl}/api/v2/query`, {
      method: 'POST',
      headers: {
        ...this.getHeaders('application/vnd.flux'),
        'Accept': 'application/csv'
      },
      body: fluxQuery
    })

    if (!response.ok) {
      throw new Error(`Query failed: ${response.statusText}`)
    }

    const csvData = await response.text()
    return parseCSVResult(csvData)
  }

  // Write data
  async write(data: string, precision: string = 'ms'): Promise<void> {
    const params = new URLSearchParams({
      org: this.org,
      bucket: this.bucket,
      precision
    })

    const response = await fetch(`${this.baseUrl}/api/v2/write?${params}`, {
      method: 'POST',
      headers: this.getHeaders('text/plain; charset=utf-8'),
      body: data
    })

    if (!response.ok) {
      throw new Error(`Write failed: ${response.statusText}`)
    }
  }

  // Get buckets
  async getBuckets(): Promise<any[]> {
    const params = new URLSearchParams({ org: this.org })
    const response = await fetch(`${this.baseUrl}/api/v2/buckets?${params}`, {
      headers: this.getHeaders()
    })

    if (!response.ok) {
      throw new Error(`Failed to get buckets: ${response.statusText}`)
    }

    const result = await response.json()
    return result.buckets || []
  }

  // Health check
  async health(): Promise<boolean> {
    try {
      const response = await fetch(`${this.baseUrl}/health`)
      return response.ok
    } catch {
      return false
    }
  }
}

// Usage
const influxClient = new InfluxDBClient({
  url: 'http://localhost:8086',
  token: 'renewable_energy_admin_token_123',
  org: 'renewable_energy_org',
  bucket: 'renewable_energy'
})
```

### 📊 Common Query Templates

```typescript
// Predefined query templates
export const QueryTemplates = {
  // Get latest data for a device
  getLatestDeviceData: (deviceId: string, measurement: string) => `
    from(bucket: "${INFLUXDB_CONFIG.bucket}")
      |> range(start: -5m)
      |> filter(fn: (r) => r._measurement == "${measurement}")
      |> filter(fn: (r) => r.device_id == "${deviceId}")
      |> last()
  `,

  // Get aggregated data for a time period
  getAggregatedData: (measurement: string, field: string, timeRange: string, window: string) => `
    from(bucket: "${INFLUXDB_CONFIG.bucket}")
      |> range(start: ${timeRange})
      |> filter(fn: (r) => r._measurement == "${measurement}")
      |> filter(fn: (r) => r._field == "${field}")
      |> aggregateWindow(every: ${window}, fn: mean)
      |> sort(columns: ["_time"])
  `,

  // Get device status
  getDeviceStatus: (deviceId: string) => `
    from(bucket: "${INFLUXDB_CONFIG.bucket}")
      |> range(start: -1m)
      |> filter(fn: (r) => r.device_id == "${deviceId}")
      |> last()
  `,

  // Get fault data
  getFaultData: (timeRange: string = '-24h') => `
    from(bucket: "${INFLUXDB_CONFIG.bucket}")
      |> range(start: ${timeRange})
      |> filter(fn: (r) => r.status == "fault")
      |> sort(columns: ["_time"])
  `
}
```

---

<div align="center">

**🌐 Ready to integrate InfluxDB with your React app?**

*Use this comprehensive guide to build powerful renewable energy monitoring dashboards!*

</div>
