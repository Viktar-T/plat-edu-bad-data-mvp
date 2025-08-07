# 🌐 React + Express Web App for Renewable Energy IoT Monitoring

> **Build a React frontend with Express backend that connects to InfluxDB for real-time and historical renewable energy data visualization.**

[![React](https://img.shields.io/badge/React-18+-blue?logo=react)](https://reactjs.org/)
[![Express](https://img.shields.io/badge/Express-4.18+-green?logo=express)](https://expressjs.com/)
[![InfluxDB](https://img.shields.io/badge/InfluxDB-2.7-green?logo=influxdb)](https://influxdata.com/)
[![TypeScript](https://img.shields.io/badge/TypeScript-5.0+-blue?logo=typescript)](https://www.typescriptlang.org/)
[![Docker](https://img.shields.io/badge/Docker-Enabled-blue?logo=docker)](https://www.docker.com/)

---

## 📋 Table of Contents

- [🎯 Overview](#-overview)
- [🔧 Prerequisites](#-prerequisites)
- [🚀 Quick Start](#-quick-start)
- [📊 Implementation Guide](#-implementation-guide)
- [🔌 InfluxDB Integration](#-influxdb-integration)
- [📈 Data Visualization](#-data-visualization)
- [⚡ Performance Optimization](#-performance-optimization)
- [🛡️ Security & Authentication](#️-security--authentication)
- [🔍 Advanced Features](#-advanced-features)
- [💡 Best Practices](#-best-practices)
- [🔧 Troubleshooting](#-troubleshooting)
- [📚 API Reference](#-api-reference)

---

## 🎯 Overview

This guide shows you how to create a **React frontend with Express backend** that connects to your InfluxDB time-series database to display real-time and historical renewable energy data. This approach provides separation of concerns with Express handling data logic and React providing the user interface.

**Architecture**: React Frontend ↔ Express Backend ↔ InfluxDB 2.7

### 🔄 How It Works

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

### ✨ Key Benefits

- ✅ **Separation of concerns** - Express handles data logic, React handles UI
- ✅ **Rich query capabilities** with Flux language
- ✅ **Historical data** with flexible time ranges
- ✅ **Real-time updates** via polling or Server-Sent Events
- ✅ **Streaming analytics integration** - InfluxDB integrates easily with streaming analytics tools
- ✅ **Client libraries** available for popular programming languages
- ✅ **Built-in aggregation** and data processing
- ✅ **Optimized for time-series data**

---

## 🔧 Prerequisites

Before you begin, ensure you have the following:

### ✅ System Requirements

- **InfluxDB 2.7**: Running and accessible on port 8086
- **Express Backend**: Node.js server for API endpoints
- **React Environment**: Basic React app setup (create-react-app or similar)
- **Node.js**: Version 16+ for modern React and Express features
- **Docker**: Your IoT system running via docker-compose

### 🔧 InfluxDB Configuration

Your InfluxDB should be configured with:

```bash
# Environment variables (from your docker-compose.yml)
INFLUXDB_ADMIN_USER=admin
INFLUXDB_ADMIN_PASSWORD=admin_password_123
INFLUXDB_ADMIN_TOKEN=renewable_energy_admin_token_123
INFLUXDB_ORG=renewable_energy_org
INFLUXDB_BUCKET=renewable_energy
```

### 📊 Data Structure

Your InfluxDB should contain measurements for:
- `photovoltaic_data` - Solar panel data
- `wind_turbine_data` - Wind turbine data
- `biogas_plant_data` - Biogas plant data
- `heat_boiler_data` - Heat boiler data
- `energy_storage_data` - Energy storage data

---

## 🚀 Quick Start

### 1. **Install Dependencies**

```bash
# Create new React app (if starting fresh)
npx create-react-app renewable-energy-dashboard --template typescript

# Navigate to project
cd renewable-energy-dashboard

# Install React frontend dependencies
npm install recharts
npm install @types/node
npm install axios
npm install react-query

# Create Express backend directory
mkdir backend
cd backend

# Install Express backend dependencies
npm init -y
npm install express
npm install @influxdata/influxdb-client
npm install cors
npm install dotenv
npm install @types/express
npm install @types/cors
```

### 2. **Set Up Environment Variables**

Create `.env` file in your Express backend directory:

```env
INFLUXDB_URL=http://localhost:8086
INFLUXDB_TOKEN=renewable_energy_admin_token_123
INFLUXDB_ORG=renewable_energy_org
INFLUXDB_BUCKET=renewable_energy
PORT=3001
```

Create `.env` file in your React app root:

```env
REACT_APP_API_URL=http://localhost:3001
```

### 3. **Create Express Backend Server**

Create `backend/server.js`:

```javascript
const express = require('express')
const cors = require('cors')
const { InfluxDB } = require('@influxdata/influxdb-client')
require('dotenv').config()

const app = express()
const PORT = process.env.PORT || 3001

// Middleware
app.use(cors())
app.use(express.json())

// InfluxDB Configuration
const url = process.env.INFLUXDB_URL || 'http://localhost:8086'
const token = process.env.INFLUXDB_TOKEN || 'renewable_energy_admin_token_123'
const org = process.env.INFLUXDB_ORG || 'renewable_energy_org'
const bucket = process.env.INFLUXDB_BUCKET || 'renewable_energy'

const influxDB = new InfluxDB({ url, token })
const queryApi = influxDB.getQueryApi(org)

// API Routes
app.get('/api/energy-data', async (req, res) => {
  try {
    const { measurement, timeRange, deviceId, field } = req.query
    
    let fluxQuery = `
      from(bucket: "${bucket}")
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
    
    const results = []
    await queryApi.queryRaw(fluxQuery, {
      next: (line) => {
        if (!line.startsWith('#')) {
          const data = JSON.parse(line)
          if (data.result === '_result') {
            results.push(data)
          }
        }
      },
      error: (error) => {
        console.error('Query error:', error)
        res.status(500).json({ error: 'Query failed' })
      },
      complete: () => {
        res.json({
          success: true,
          data: results,
          timestamp: new Date().toISOString()
        })
      }
    })
  } catch (error) {
    res.status(500).json({
      success: false,
      error: error.message
    })
  }
})

app.listen(PORT, () => {
  console.log(`Express server running on port ${PORT}`)
})
```

### 4. **Create React Frontend Component**

Create `src/components/EnergyDashboard.tsx`:

```typescript
import React, { useEffect, useState } from 'react'

interface EnergyData {
  timestamp: string
  device_id: string
  power_output: number
  temperature: number
  efficiency: number
}

export default function EnergyDashboard() {
  const [solarData, setSolarData] = useState<EnergyData[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    fetchSolarData()
  }, [])

  const fetchSolarData = async () => {
    try {
      setLoading(true)
      
      const response = await fetch(`${process.env.REACT_APP_API_URL}/api/energy-data?measurement=photovoltaic_data&timeRange=-1h`)
      const result = await response.json()
      
      if (result.success) {
        setSolarData(result.data)
      } else {
        setError(result.error)
      }
    } catch (err) {
      setError('Failed to connect to backend API')
    } finally {
      setLoading(false)
    }
  }

  if (loading) return <div>Loading energy data...</div>
  if (error) return <div>Error: {error}</div>

  return (
    <div className="energy-dashboard">
      <h2>Renewable Energy Dashboard</h2>
      <div className="data-grid">
        {solarData.map((data, index) => (
          <div key={index} className="data-card">
            <h3>Device: {data.device_id}</h3>
            <p>Power Output: {data.power_output.toFixed(2)} kW</p>
            <p>Temperature: {data.temperature.toFixed(1)}°C</p>
            <p>Efficiency: {(data.efficiency * 100).toFixed(1)}%</p>
            <small>{new Date(data.timestamp).toLocaleString()}</small>
          </div>
        ))}
      </div>
    </div>
  )
}
```

### 5. **Add Component to Your App**

Update `src/App.tsx`:

```typescript
import React from 'react'
import EnergyDashboard from './components/EnergyDashboard'
import './App.css'

function App() {
  return (
    <div className="App">
      <header className="App-header">
        <h1>Renewable Energy IoT Monitoring</h1>
      </header>
      <main>
        <EnergyDashboard />
      </main>
    </div>
  )
}

export default App
```

### 6. **Start Your Application**

```bash
# Start Express backend (in backend directory)
cd backend
npm start

# Start React frontend (in project root)
cd ..
npm start
```

Open `http://localhost:3000` to see your dashboard.

---

## 📊 Implementation Guide

### 🔌 InfluxDB Connection Setup

#### Basic Connection

```typescript
import { InfluxDB } from '@influxdata/influxdb-client'

const influxDB = new InfluxDB({
  url: 'http://localhost:8086',
  token: 'your_token_here'
})

const queryApi = influxDB.getQueryApi('your_org')
```

#### Connection with Error Handling

```typescript
import { InfluxDB } from '@influxdata/influxdb-client'

class InfluxDBService {
  private client: InfluxDB
  private queryApi: any
  private isConnected: boolean = false

  constructor() {
    this.client = new InfluxDB({
      url: process.env.REACT_APP_INFLUXDB_URL!,
      token: process.env.REACT_APP_INFLUXDB_TOKEN!
    })
    this.queryApi = this.client.getQueryApi(process.env.REACT_APP_INFLUXDB_ORG!)
  }

  async testConnection(): Promise<boolean> {
    try {
      const query = `from(bucket: "${process.env.REACT_APP_INFLUXDB_BUCKET}")
        |> range(start: -1m)
        |> limit(n: 1)`
      
      await this.queryApi.queryRaw(query)
      this.isConnected = true
      return true
    } catch (error) {
      console.error('InfluxDB connection failed:', error)
      this.isConnected = false
      return false
    }
  }

  getConnectionStatus(): boolean {
    return this.isConnected
  }
}

export const influxDBService = new InfluxDBService()
```

### 📈 Data Fetching Patterns

#### Real-Time Data with Polling

```typescript
import { useEffect, useState, useCallback } from 'react'
import { queryApi } from '../config/influxdb'

export function useRealTimeData(measurement: string, interval: number = 5000) {
  const [data, setData] = useState([])
  const [loading, setLoading] = useState(true)

  const fetchData = useCallback(async () => {
    try {
      const fluxQuery = `
        from(bucket: "${process.env.REACT_APP_INFLUXDB_BUCKET}")
          |> range(start: -5m)
          |> filter(fn: (r) => r._measurement == "${measurement}")
          |> sort(columns: ["_time"])
      `

      const results: any[] = []
      
      await queryApi.queryRaw(fluxQuery, {
        next: (line: string) => {
          if (!line.startsWith('#')) {
            const parsed = JSON.parse(line)
            if (parsed.result === '_result') {
              results.push(parsed)
            }
          }
        },
        complete: () => {
          setData(results)
          setLoading(false)
        }
      })
    } catch (error) {
      console.error('Error fetching data:', error)
      setLoading(false)
    }
  }, [measurement])

  useEffect(() => {
    fetchData()
    const intervalId = setInterval(fetchData, interval)
    return () => clearInterval(intervalId)
  }, [fetchData, interval])

  return { data, loading, refetch: fetchData }
}
```

#### Historical Data with Time Range

```typescript
export function useHistoricalData(
  measurement: string, 
  timeRange: { start: string, end: string }
) {
  const [data, setData] = useState([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    const fetchHistoricalData = async () => {
      try {
        const fluxQuery = `
          from(bucket: "${process.env.REACT_APP_INFLUXDB_BUCKET}")
            |> range(start: ${timeRange.start}, stop: ${timeRange.end})
            |> filter(fn: (r) => r._measurement == "${measurement}")
            |> aggregateWindow(every: 1h, fn: mean)
            |> sort(columns: ["_time"])
        `

        const results: any[] = []
        
        await queryApi.queryRaw(fluxQuery, {
          next: (line: string) => {
            if (!line.startsWith('#')) {
              const parsed = JSON.parse(line)
              if (parsed.result === '_result') {
                results.push(parsed)
              }
            }
          },
          complete: () => {
            setData(results)
            setLoading(false)
          }
        })
      } catch (error) {
        console.error('Error fetching historical data:', error)
        setLoading(false)
      }
    }

    fetchHistoricalData()
  }, [measurement, timeRange])

  return { data, loading }
}
```

### 🎨 Data Visualization Components

#### Line Chart Component

```typescript
import React from 'react'
import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, Legend, ResponsiveContainer } from 'recharts'

interface ChartData {
  timestamp: string
  value: number
  field: string
}

interface EnergyChartProps {
  data: ChartData[]
  title: string
  yAxisLabel: string
}

export function EnergyChart({ data, title, yAxisLabel }: EnergyChartProps) {
  const chartData = data.map(item => ({
    time: new Date(item.timestamp).toLocaleTimeString(),
    [item.field]: item.value
  }))

  return (
    <div className="chart-container">
      <h3>{title}</h3>
      <ResponsiveContainer width="100%" height={300}>
        <LineChart data={chartData}>
          <CartesianGrid strokeDasharray="3 3" />
          <XAxis dataKey="time" />
          <YAxis label={{ value: yAxisLabel, angle: -90, position: 'insideLeft' }} />
          <Tooltip />
          <Legend />
          <Line 
            type="monotone" 
            dataKey={data[0]?.field || 'value'} 
            stroke="#8884d8" 
            strokeWidth={2}
            dot={false}
          />
        </LineChart>
      </ResponsiveContainer>
    </div>
  )
}
```

#### Gauge Component

```typescript
import React from 'react'

interface GaugeProps {
  value: number
  min: number
  max: number
  title: string
  unit: string
  color?: string
}

export function Gauge({ value, min, max, title, unit, color = '#8884d8' }: GaugeProps) {
  const percentage = ((value - min) / (max - min)) * 100
  const angle = (percentage / 100) * 180

  return (
    <div className="gauge-container">
      <h4>{title}</h4>
      <div className="gauge">
        <div 
          className="gauge-fill"
          style={{
            transform: `rotate(${angle}deg)`,
            backgroundColor: color
          }}
        />
        <div className="gauge-value">
          {value.toFixed(1)} {unit}
        </div>
      </div>
    </div>
  )
}
```

---

## ⚡ Performance Optimization

### 🔄 Efficient Data Fetching

#### Debounced Queries

```typescript
import { useMemo, useCallback } from 'react'
import { debounce } from 'lodash'

export function useDebouncedQuery(query: string, delay: number = 300) {
  const debouncedQuery = useMemo(
    () => debounce(async (queryString: string) => {
      // Execute query logic here
    }, delay),
    [delay]
  )

  return debouncedQuery
}
```

#### Caching with React Query

```typescript
import { useQuery } from 'react-query'

export function useCachedEnergyData(measurement: string, timeRange: string) {
  return useQuery(
    ['energy-data', measurement, timeRange],
    async () => {
      // Fetch data from InfluxDB
      const fluxQuery = `
        from(bucket: "${process.env.REACT_APP_INFLUXDB_BUCKET}")
          |> range(start: ${timeRange})
          |> filter(fn: (r) => r._measurement == "${measurement}")
      `
      
      // Execute query and return data
      return executeQuery(fluxQuery)
    },
    {
      staleTime: 30000, // Data is fresh for 30 seconds
      cacheTime: 300000, // Cache for 5 minutes
      refetchInterval: 60000, // Refetch every minute
    }
  )
}
```

### 📊 Data Aggregation

#### Pre-aggregated Queries

```typescript
export function getAggregatedData(measurement: string, window: string) {
  const fluxQuery = `
    from(bucket: "${process.env.REACT_APP_INFLUXDB_BUCKET}")
      |> range(start: -24h)
      |> filter(fn: (r) => r._measurement == "${measurement}")
      |> aggregateWindow(every: ${window}, fn: mean)
      |> sort(columns: ["_time"])
  `
  
  return fluxQuery
}
```

---

## 🛡️ Security & Authentication

### 🔐 Token Management

```typescript
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

export const influxDBAuth = InfluxDBAuth.getInstance()
```

### 🌐 HTTPS Configuration

```typescript
// For production, use HTTPS
const getInfluxDBConfig = () => {
  const isProduction = process.env.NODE_ENV === 'production'
  
  return {
    url: isProduction 
      ? 'https://your-influxdb-domain.com:8086'
      : 'http://localhost:8086',
    token: process.env.REACT_APP_INFLUXDB_TOKEN,
    org: process.env.REACT_APP_INFLUXDB_ORG
  }
}
```

---

## 🔍 Advanced Features

### 📊 Multi-Device Dashboard

```typescript
import React from 'react'
import { useRealTimeData } from '../hooks/useRealTimeData'
import { EnergyChart } from './EnergyChart'
import { Gauge } from './Gauge'

export function MultiDeviceDashboard() {
  const { data: solarData, loading: solarLoading } = useRealTimeData('photovoltaic_data')
  const { data: windData, loading: windLoading } = useRealTimeData('wind_turbine_data')
  const { data: storageData, loading: storageLoading } = useRealTimeData('energy_storage_data')

  if (solarLoading || windLoading || storageLoading) {
    return <div>Loading dashboard...</div>
  }

  return (
    <div className="multi-device-dashboard">
      <div className="dashboard-grid">
        <div className="device-section">
          <h2>Solar Panels</h2>
          <EnergyChart 
            data={solarData} 
            title="Power Output" 
            yAxisLabel="Power (kW)" 
          />
          <div className="gauges">
            <Gauge 
              value={solarData[0]?.power_output || 0} 
              min={0} 
              max={100} 
              title="Current Power" 
              unit="kW" 
              color="#ffd700"
            />
            <Gauge 
              value={solarData[0]?.efficiency || 0} 
              min={0} 
              max={1} 
              title="Efficiency" 
              unit="%" 
              color="#32cd32"
            />
          </div>
        </div>

        <div className="device-section">
          <h2>Wind Turbines</h2>
          <EnergyChart 
            data={windData} 
            title="Wind Power" 
            yAxisLabel="Power (kW)" 
          />
        </div>

        <div className="device-section">
          <h2>Energy Storage</h2>
          <EnergyChart 
            data={storageData} 
            title="Battery Level" 
            yAxisLabel="Charge (%)" 
          />
        </div>
      </div>
    </div>
  )
}
```

### 🔔 Real-Time Alerts

```typescript
export function useEnergyAlerts() {
  const [alerts, setAlerts] = useState([])

  const checkAlerts = useCallback((data) => {
    const newAlerts = []
    
    data.forEach(device => {
      if (device.power_output < 10) {
        newAlerts.push({
          type: 'warning',
          message: `Low power output on device ${device.device_id}`,
          timestamp: new Date().toISOString()
        })
      }
      
      if (device.temperature > 80) {
        newAlerts.push({
          type: 'error',
          message: `High temperature on device ${device.device_id}`,
          timestamp: new Date().toISOString()
        })
      }
    })
    
    setAlerts(prev => [...prev, ...newAlerts])
  }, [])

  return { alerts, checkAlerts }
}
```

---

## 💡 Best Practices

### 📊 Data Management

- **Use appropriate time ranges** for queries to avoid performance issues
- **Implement data pagination** for large datasets
- **Cache frequently accessed data** using React Query or SWR
- **Use aggregation functions** for performance optimization

### 🎨 UI/UX Guidelines

- **Show loading states** for better user experience
- **Implement error boundaries** to handle connection failures
- **Use responsive design** for mobile compatibility
- **Provide data refresh options** for manual updates

### 🔧 Code Organization

- **Separate concerns** between data fetching and UI components
- **Use custom hooks** for reusable data logic
- **Implement proper TypeScript types** for type safety
- **Follow React best practices** for component structure

---

## 🔧 Troubleshooting

### ❌ Common Issues

| Issue | Cause | Solution |
|-------|-------|----------|
| **Connection Failed** | InfluxDB not running | Check docker-compose status |
| **Authentication Error** | Invalid token | Verify token in environment variables |
| **CORS Error** | Browser security policy | Configure InfluxDB CORS settings |
| **Query Timeout** | Large time range | Reduce query time range or add aggregation |

### 🔧 Debug Commands

```bash
# Check InfluxDB status
curl -f http://localhost:8086/health

# Test query via curl
curl -X POST http://localhost:8086/api/v2/query \
  -H "Authorization: Token your_token_here" \
  -H "Content-Type: application/vnd.flux" \
  -d 'from(bucket:"renewable_energy") |> range(start: -1h) |> limit(n: 1)'

# Check React app environment
echo $REACT_APP_INFLUXDB_URL
```

### 📊 Performance Monitoring

```typescript
// Add performance monitoring to queries
const measureQueryPerformance = async (queryFn: () => Promise<any>) => {
  const startTime = performance.now()
  try {
    const result = await queryFn()
    const endTime = performance.now()
    console.log(`Query completed in ${endTime - startTime}ms`)
    return result
  } catch (error) {
    console.error('Query failed:', error)
    throw error
  }
}
```

---

## 📚 API Reference

### 🔌 InfluxDB Client Methods

```typescript
// Query API
queryApi.queryRaw(fluxQuery, options)
queryApi.queryLines(fluxQuery, options)
queryApi.queryRows(fluxQuery, options)

// Write API (if needed)
writeApi.writePoint(point)
writeApi.writePoints(points)
writeApi.close()
```

### 📊 Flux Query Examples

```typescript
// Basic query
const basicQuery = `
  from(bucket: "renewable_energy")
    |> range(start: -1h)
    |> filter(fn: (r) => r._measurement == "photovoltaic_data")
`

// Aggregated query
const aggregatedQuery = `
  from(bucket: "renewable_energy")
    |> range(start: -24h)
    |> filter(fn: (r) => r._measurement == "photovoltaic_data")
    |> aggregateWindow(every: 1h, fn: mean)
    |> sort(columns: ["_time"])
`

// Multi-field query
const multiFieldQuery = `
  from(bucket: "renewable_energy")
    |> range(start: -1h)
    |> filter(fn: (r) => r._measurement == "photovoltaic_data")
    |> filter(fn: (r) => r._field == "power_output" or r._field == "temperature")
    |> pivot(rowKey:["_time"], columnKey: ["_field"], valueColumn: "_value")
`
```

---

## 📖 **Comprehensive Documentation**

For detailed implementation with React examples, TypeScript interfaces, and ready-to-use components, see:

### **[📊 InfluxDB 2.7 RESTful API Guide](../docs/influxdb/01-influxdb-api.md)**

This comprehensive guide includes:
- **Complete API reference** with all endpoints
- **TypeScript interfaces** for all data types
- **React hooks** for data fetching
- **Error handling** patterns
- **Performance optimization** techniques
- **Security best practices**
- **Real-world examples** and use cases

---

<div align="center">

**🌐 Ready to build your renewable energy dashboard?**

*Connect your React app directly to InfluxDB and start visualizing your IoT data!*

</div>