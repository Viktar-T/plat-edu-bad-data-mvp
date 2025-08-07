# 📊 Visualization Options for Custom React Web App

> **Comprehensive guide for integrating Grafana dashboards and custom React visualizations in your renewable energy IoT monitoring system.**

[![React](https://img.shields.io/badge/React-18+-blue?logo=react)](https://reactjs.org/)
[![Grafana](https://img.shields.io/badge/Grafana-10.2-purple?logo=grafana)](https://grafana.com/)
[![InfluxDB](https://img.shields.io/badge/InfluxDB-2.7-green?logo=influxdb)](https://influxdata.com/)
[![Express](https://img.shields.io/badge/Express-4.18+-green?logo=express)](https://expressjs.com/)

---

## 📋 Table of Contents

- [📊 Visualization Options for Custom React Web App](#-visualization-options-for-custom-react-web-app)
  - [📋 Table of Contents](#-table-of-contents)
  - [🎯 Overview](#-overview)
  - [🏗️ Architecture Comparison](#️-architecture-comparison)
    - [**Current System Architecture**](#current-system-architecture)
    - [**Visualization Options**](#visualization-options)
  - [📊 Option 1: Grafana Embedding](#-option-1-grafana-embedding)
    - [**What It Is**](#what-it-is)
    - [**How It Works**](#how-it-works)
    - [**Implementation Guide**](#implementation-guide)
      - [**1. Basic Iframe Embedding**](#1-basic-iframe-embedding)
      - [**2. Advanced Embedding with API**](#2-advanced-embedding-with-api)
      - [**3. Dashboard Layout with Grafana**](#3-dashboard-layout-with-grafana)
    - [**Pros \& Cons**](#pros--cons)
      - [**✅ Advantages**](#-advantages)
      - [**❌ Disadvantages**](#-disadvantages)
    - [**Use Cases**](#use-cases)
  - [🔄 Option 2: Hybrid Approach](#-option-2-hybrid-approach)
    - [**What It Is**](#what-it-is-1)
    - [**How It Works**](#how-it-works-1)
    - [**Implementation Guide**](#implementation-guide-1)
      - [**1. Express Backend API**](#1-express-backend-api)
      - [**2. React Frontend with Hybrid Components**](#2-react-frontend-with-hybrid-components)
      - [**3. Custom React Chart Components**](#3-custom-react-chart-components)
    - [**Pros \& Cons**](#pros--cons-1)
      - [**✅ Advantages**](#-advantages-1)
      - [**❌ Disadvantages**](#-disadvantages-1)
    - [**Use Cases**](#use-cases-1)
  - [🎨 Option 3: Pure React Solution](#-option-3-pure-react-solution)
    - [**What It Is**](#what-it-is-2)
    - [**How It Works**](#how-it-works-2)
    - [**Implementation Guide**](#implementation-guide-2)
      - [**1. Express Backend with Advanced Queries**](#1-express-backend-with-advanced-queries)
      - [**2. Advanced React Chart Components**](#2-advanced-react-chart-components)
      - [**3. Complete Dashboard with Custom Components**](#3-complete-dashboard-with-custom-components)
    - [**Pros \& Cons**](#pros--cons-2)
      - [**✅ Advantages**](#-advantages-2)
      - [**❌ Disadvantages**](#-disadvantages-2)
    - [**Use Cases**](#use-cases-2)
  - [📈 Comparison Matrix](#-comparison-matrix)
  - [🚀 Implementation Recommendations](#-implementation-recommendations)
    - [**For MVP Development**](#for-mvp-development)
    - [**For Production Systems**](#for-production-systems)
    - [**For Enterprise Applications**](#for-enterprise-applications)
    - [**Migration Strategy**](#migration-strategy)
  - [💡 Best Practices](#-best-practices)
    - [**Performance Optimization**](#performance-optimization)
    - [**User Experience**](#user-experience)
    - [**Data Management**](#data-management)
  - [🔧 Troubleshooting](#-troubleshooting)
    - [**Common Issues**](#common-issues)
    - [**Debug Commands**](#debug-commands)

---

## 🎯 Overview

Your renewable energy IoT monitoring system has two data flows:
1. **Flow 1**: MQTT → Node-RED → InfluxDB → Grafana (existing)
2. **Flow 2**: MQTT → Node-RED → InfluxDB → Express Backend → React Frontend (new)

This guide explores three different approaches for implementing visualizations in your custom React web app, each with its own advantages and trade-offs.

---

## 🏗️ Architecture Comparison

### **Current System Architecture**

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

### **Visualization Options**

| Option | Approach | Complexity | Customization | Performance | Development Time |
|--------|----------|------------|---------------|-------------|------------------|
| **Option 1** | Grafana Embedding | Low | Limited | Medium | Fast |
| **Option 2** | Hybrid Approach | Medium | High | High | Medium |
| **Option 3** | Pure React | High | Complete | High | Slow |

---

## 📊 Option 1: Grafana Embedding

### **What It Is**

Embed Grafana dashboards directly into your React app using iframes or Grafana's embedding API. This approach leverages your existing Grafana setup with minimal development effort.

### **How It Works**

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   React App     │───▶│   Grafana       │───▶│   InfluxDB      │
│   (Frontend)    │    │   (Embedded)    │    │   (Data Source) │
│   Port 3000     │    │   Port 3000     │    │   Port 8086     │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Custom UI     │    │   Dashboard     │    │   Time-Series   │
│   Components    │    │   Panels        │    │   Data          │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

### **Implementation Guide**

#### **1. Basic Iframe Embedding**

```typescript
// React component for embedding Grafana dashboard
import React from 'react'

interface GrafanaPanelProps {
  dashboardId: string
  panelId?: string
  width?: string
  height?: string
  theme?: 'light' | 'dark'
}

export const GrafanaPanel: React.FC<GrafanaPanelProps> = ({
  dashboardId,
  panelId,
  width = '100%',
  height = '400px',
  theme = 'light'
}) => {
  const grafanaUrl = process.env.REACT_APP_GRAFANA_URL || 'http://localhost:3000'
  
  const iframeSrc = panelId 
    ? `${grafanaUrl}/d-solo/${dashboardId}?orgId=1&panelId=${panelId}&theme=${theme}`
    : `${grafanaUrl}/d/${dashboardId}?orgId=1&theme=${theme}`

  return (
    <div className="grafana-panel">
      <iframe
        src={iframeSrc}
        width={width}
        height={height}
        frameBorder="0"
        title="Grafana Dashboard"
        style={{ border: 'none' }}
      />
    </div>
  )
}
```

#### **2. Advanced Embedding with API**

```typescript
// Using Grafana's embedding API for more control
import React, { useState, useEffect } from 'react'

interface GrafanaEmbedProps {
  dashboardId: string
  panelId: string
  timeRange?: {
    from: string
    to: string
  }
}

export const GrafanaEmbed: React.FC<GrafanaEmbedProps> = ({
  dashboardId,
  panelId,
  timeRange
}) => {
  const [embedUrl, setEmbedUrl] = useState<string>('')
  const grafanaUrl = process.env.REACT_APP_GRAFANA_URL || 'http://localhost:3000'

  useEffect(() => {
    // Generate embedding URL with parameters
    const params = new URLSearchParams({
      orgId: '1',
      panelId,
      theme: 'light',
      ...(timeRange && {
        from: timeRange.from,
        to: timeRange.to
      })
    })

    setEmbedUrl(`${grafanaUrl}/d-solo/${dashboardId}?${params}`)
  }, [dashboardId, panelId, timeRange])

  return (
    <div className="grafana-embed">
      {embedUrl && (
        <iframe
          src={embedUrl}
          width="100%"
          height="400"
          frameBorder="0"
          title="Grafana Panel"
        />
      )}
    </div>
  )
}
```

#### **3. Dashboard Layout with Grafana**

```typescript
// Complete dashboard layout combining Grafana and custom components
import React from 'react'
import { GrafanaPanel } from './GrafanaPanel'
import { CustomControls } from './CustomControls'

export const EnergyDashboard: React.FC = () => {
  return (
    <div className="energy-dashboard">
      <header className="dashboard-header">
        <h1>Renewable Energy Monitoring</h1>
        <CustomControls />
      </header>
      
      <div className="dashboard-grid">
        {/* Grafana panels for complex visualizations */}
        <div className="panel-section">
          <h3>System Overview</h3>
          <GrafanaPanel 
            dashboardId="renewable-energy-overview"
            height="300px"
          />
        </div>
        
        <div className="panel-section">
          <h3>Power Generation</h3>
          <GrafanaPanel 
            dashboardId="power-generation"
            panelId="power-chart"
            height="300px"
          />
        </div>
        
        {/* Custom React components for user-specific features */}
        <div className="custom-section">
          <h3>User Preferences</h3>
          <UserPreferences />
        </div>
      </div>
    </div>
  )
}
```

### **Pros & Cons**

#### **✅ Advantages**
- **Leverage existing** Grafana dashboards
- **Rich visualizations** already built
- **Minimal development** required
- **Professional charts** and graphs
- **Built-in alerting** integration
- **Consistent UI** with existing dashboards
- **Advanced visualization options**

#### **❌ Disadvantages**
- Limited customization options
- Dependent on Grafana's UI/UX
- Potential iframe limitations
- Less control over data flow
- Security considerations with iframes
- Performance overhead from iframes

### **Use Cases**

- **Quick implementation** and prototyping
- **Leveraging existing** dashboards
- **When you want to focus** on app features rather than data visualization
- **Consistent dashboard** experience across platforms
- **System monitoring** dashboards

---

## 🔄 Option 2: Hybrid Approach

### **What It Is**

Combine Grafana for complex visualizations with custom React components for user-specific features. This approach gives you the best of both worlds - professional charts from Grafana and custom user experience from React.

### **How It Works**

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   React App     │───▶│   Express       │───▶│   InfluxDB      │
│   (Frontend)    │    │   Backend       │    │   (Data Source) │
│   Port 3000     │    │   Port 3001     │    │   Port 8086     │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Custom UI     │    │   API Endpoints │    │   Time-Series   │
│   Components    │    │   & Business    │    │   Data          │
│   + Grafana     │    │   Logic         │    │                 │
│   Embedding     │    │                 │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

### **Implementation Guide**

#### **1. Express Backend API**

```typescript
// Express backend serving both Grafana and custom data
import express from 'express'
import { InfluxDB } from '@influxdata/influxdb-client'

const app = express()
app.use(cors())
app.use(express.json())

// InfluxDB configuration
const influxDB = new InfluxDB({
  url: process.env.INFLUXDB_URL || 'http://localhost:8086',
  token: process.env.INFLUXDB_TOKEN || 'your_token'
})

const queryApi = influxDB.getQueryApi(process.env.INFLUXDB_ORG || 'your_org')

// API endpoint for custom data
app.get('/api/energy-data', async (req, res) => {
  try {
    const { measurement, timeRange, deviceId } = req.query
    
    const fluxQuery = `
      from(bucket: "${process.env.INFLUXDB_BUCKET}")
        |> range(start: ${timeRange || '-1h'})
        |> filter(fn: (r) => r._measurement == "${measurement}")
        ${deviceId ? `|> filter(fn: (r) => r.device_id == "${deviceId}")` : ''}
        |> sort(columns: ["_time"])
    `
    
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
      complete: () => {
        res.json({ success: true, data: results })
      }
    })
  } catch (error) {
    res.status(500).json({ success: false, error: error.message })
  }
})

app.listen(3001, () => {
  console.log('Express server running on port 3001')
})
```

#### **2. React Frontend with Hybrid Components**

```typescript
// Hybrid dashboard combining Grafana and custom components
import React, { useState, useEffect } from 'react'
import { GrafanaPanel } from './GrafanaPanel'
import { CustomChart } from './CustomChart'
import { UserControls } from './UserControls'

interface DashboardData {
  systemOverview: any[]
  userMetrics: any[]
  alerts: any[]
}

export const HybridDashboard: React.FC = () => {
  const [data, setData] = useState<DashboardData>({
    systemOverview: [],
    userMetrics: [],
    alerts: []
  })
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    fetchDashboardData()
  }, [])

  const fetchDashboardData = async () => {
    try {
      setLoading(true)
      
      // Fetch custom data from Express backend
      const [systemData, userData, alertsData] = await Promise.all([
        fetch('/api/energy-data?measurement=system_overview'),
        fetch('/api/energy-data?measurement=user_metrics'),
        fetch('/api/alerts')
      ])

      const [system, user, alerts] = await Promise.all([
        systemData.json(),
        userData.json(),
        alertsData.json()
      ])

      setData({
        systemOverview: system.data || [],
        userMetrics: user.data || [],
        alerts: alerts.data || []
      })
    } catch (error) {
      console.error('Error fetching dashboard data:', error)
    } finally {
      setLoading(false)
    }
  }

  if (loading) return <div>Loading dashboard...</div>

  return (
    <div className="hybrid-dashboard">
      <header className="dashboard-header">
        <h1>Renewable Energy Monitoring</h1>
        <UserControls onRefresh={fetchDashboardData} />
      </header>
      
      <div className="dashboard-grid">
        {/* Grafana for complex system visualizations */}
        <div className="grafana-section">
          <h3>System Overview (Grafana)</h3>
          <GrafanaPanel 
            dashboardId="system-overview"
            height="400px"
          />
        </div>
        
        {/* Custom React components for user-specific features */}
        <div className="custom-section">
          <h3>User Metrics (Custom)</h3>
          <CustomChart 
            data={data.userMetrics}
            type="line"
            title="User Activity"
          />
        </div>
        
        <div className="alerts-section">
          <h3>Alerts (Custom)</h3>
          <AlertsList alerts={data.alerts} />
        </div>
      </div>
    </div>
  )
}
```

#### **3. Custom React Chart Components**

```typescript
// Custom React chart component using Recharts
import React from 'react'
import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, Legend } from 'recharts'

interface CustomChartProps {
  data: any[]
  type: 'line' | 'bar' | 'area'
  title: string
  height?: number
}

export const CustomChart: React.FC<CustomChartProps> = ({
  data,
  type,
  title,
  height = 300
}) => {
  const chartData = data.map(item => ({
    time: new Date(item._time).toLocaleTimeString(),
    value: parseFloat(item._value) || 0,
    device: item.device_id
  }))

  return (
    <div className="custom-chart">
      <h4>{title}</h4>
      <LineChart width="100%" height={height} data={chartData}>
        <CartesianGrid strokeDasharray="3 3" />
        <XAxis dataKey="time" />
        <YAxis />
        <Tooltip />
        <Legend />
        <Line 
          type="monotone" 
          dataKey="value" 
          stroke="#8884d8" 
          strokeWidth={2}
        />
      </LineChart>
    </div>
  )
}
```

### **Pros & Cons**

#### **✅ Advantages**
- **Best of both worlds** - Grafana for complex charts, React for custom features
- **Flexible architecture** - choose the right tool for each feature
- **Reuse existing** Grafana dashboards
- **Custom user experience** where needed
- **Scalable approach**
- **Gradual migration** path

#### **❌ Disadvantages**
- More complex state management
- Need to maintain two different interfaces
- Potential user experience inconsistencies
- Higher development complexity
- Need to coordinate between Grafana and custom components

### **Use Cases**

- **Live monitoring dashboards** where you need both immediate updates and historical context
- **Real-time alert systems** with historical analysis
- **Live device status monitoring**
- **Performance tracking** with real-time updates
- **User-specific dashboards** with system-wide context

---

## 🎨 Option 3: Pure React Solution

### **What It Is**

Build all visualizations using React charting libraries (Recharts, Chart.js, D3.js) with Express backend querying InfluxDB directly. Complete control over UI/UX and user experience.

### **How It Works**

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   React App     │───▶│   Express       │───▶│   InfluxDB      │
│   (Frontend)    │    │   Backend       │    │   (Data Source) │
│   Port 3000     │    │   Port 3001     │    │   Port 8086     │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         ▼                       ▼                       ▼
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Custom UI     │    │   API Endpoints │    │   Time-Series   │
│   Components    │    │   & Business    │    │   Data          │
│   + Charts      │    │   Logic         │    │                 │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

### **Implementation Guide**

#### **1. Express Backend with Advanced Queries**

```typescript
// Advanced Express backend with specialized endpoints
import express from 'express'
import { InfluxDB } from '@influxdata/influxdb-client'

const app = express()
app.use(cors())
app.use(express.json())

const influxDB = new InfluxDB({
  url: process.env.INFLUXDB_URL || 'http://localhost:8086',
  token: process.env.INFLUXDB_TOKEN || 'your_token'
})

const queryApi = influxDB.getQueryApi(process.env.INFLUXDB_ORG || 'your_org')

// Real-time data endpoint
app.get('/api/realtime/:measurement', async (req, res) => {
  try {
    const { measurement } = req.params
    const { deviceId, timeRange = '-5m' } = req.query
    
    const fluxQuery = `
      from(bucket: "${process.env.INFLUXDB_BUCKET}")
        |> range(start: ${timeRange})
        |> filter(fn: (r) => r._measurement == "${measurement}")
        ${deviceId ? `|> filter(fn: (r) => r.device_id == "${deviceId}")` : ''}
        |> sort(columns: ["_time"])
    `
    
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
      complete: () => {
        res.json({ success: true, data: results })
      }
    })
  } catch (error) {
    res.status(500).json({ success: false, error: error.message })
  }
})

// Historical data with aggregation
app.get('/api/historical/:measurement', async (req, res) => {
  try {
    const { measurement } = req.params
    const { timeRange = '-24h', aggregation = '1h' } = req.query
    
    const fluxQuery = `
      from(bucket: "${process.env.INFLUXDB_BUCKET}")
        |> range(start: ${timeRange})
        |> filter(fn: (r) => r._measurement == "${measurement}")
        |> aggregateWindow(every: ${aggregation}, fn: mean)
        |> sort(columns: ["_time"])
    `
    
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
      complete: () => {
        res.json({ success: true, data: results })
      }
    })
  } catch (error) {
    res.status(500).json({ success: false, error: error.message })
  }
})

// Statistical data endpoint
app.get('/api/statistics/:measurement', async (req, res) => {
  try {
    const { measurement } = req.params
    const { timeRange = '-24h', field } = req.query
    
    const fluxQuery = `
      from(bucket: "${process.env.INFLUXDB_BUCKET}")
        |> range(start: ${timeRange})
        |> filter(fn: (r) => r._measurement == "${measurement}")
        ${field ? `|> filter(fn: (r) => r._field == "${field}")` : ''}
        |> mean()
        |> yield(name: "mean")
      
      from(bucket: "${process.env.INFLUXDB_BUCKET}")
        |> range(start: ${timeRange})
        |> filter(fn: (r) => r._measurement == "${measurement}")
        ${field ? `|> filter(fn: (r) => r._field == "${field}")` : ''}
        |> max()
        |> yield(name: "max")
      
      from(bucket: "${process.env.INFLUXDB_BUCKET}")
        |> range(start: ${timeRange})
        |> filter(fn: (r) => r._measurement == "${measurement}")
        ${field ? `|> filter(fn: (r) => r._field == "${field}")` : ''}
        |> min()
        |> yield(name: "min")
    `
    
    const results = { mean: 0, max: 0, min: 0 }
    await queryApi.queryRaw(fluxQuery, {
      next: (line) => {
        if (!line.startsWith('#')) {
          const data = JSON.parse(line)
          if (data.result === '_result') {
            if (data.result === 'mean') results.mean = data._value
            if (data.result === 'max') results.max = data._value
            if (data.result === 'min') results.min = data._value
          }
        }
      },
      complete: () => {
        res.json({ success: true, data: results })
      }
    })
  } catch (error) {
    res.status(500).json({ success: false, error: error.message })
  }
})

app.listen(3001, () => {
  console.log('Express server running on port 3001')
})
```

#### **2. Advanced React Chart Components**

```typescript
// Comprehensive React charting system
import React, { useState, useEffect } from 'react'
import { LineChart, Line, BarChart, Bar, AreaChart, Area, PieChart, Pie } from 'recharts'
import { ResponsiveContainer, XAxis, YAxis, CartesianGrid, Tooltip, Legend } from 'recharts'

interface ChartData {
  time: string
  value: number
  device?: string
  category?: string
}

interface AdvancedChartProps {
  data: ChartData[]
  type: 'line' | 'bar' | 'area' | 'pie'
  title: string
  height?: number
  realTime?: boolean
  onDataUpdate?: (data: ChartData[]) => void
}

export const AdvancedChart: React.FC<AdvancedChartProps> = ({
  data,
  type,
  title,
  height = 400,
  realTime = false,
  onDataUpdate
}) => {
  const [chartData, setChartData] = useState<ChartData[]>(data)

  useEffect(() => {
    setChartData(data)
  }, [data])

  useEffect(() => {
    if (realTime) {
      const interval = setInterval(() => {
        // Fetch real-time data
        fetch('/api/realtime/energy_data')
          .then(res => res.json())
          .then(result => {
            if (result.success) {
              const newData = result.data.map((item: any) => ({
                time: new Date(item._time).toLocaleTimeString(),
                value: parseFloat(item._value) || 0,
                device: item.device_id
              }))
              setChartData(newData)
              onDataUpdate?.(newData)
            }
          })
      }, 5000) // Update every 5 seconds

      return () => clearInterval(interval)
    }
  }, [realTime, onDataUpdate])

  const renderChart = () => {
    const commonProps = {
      width: '100%',
      height,
      data: chartData,
      margin: { top: 5, right: 30, left: 20, bottom: 5 }
    }

    switch (type) {
      case 'line':
        return (
          <LineChart {...commonProps}>
            <CartesianGrid strokeDasharray="3 3" />
            <XAxis dataKey="time" />
            <YAxis />
            <Tooltip />
            <Legend />
            <Line type="monotone" dataKey="value" stroke="#8884d8" strokeWidth={2} />
          </LineChart>
        )
      
      case 'bar':
        return (
          <BarChart {...commonProps}>
            <CartesianGrid strokeDasharray="3 3" />
            <XAxis dataKey="time" />
            <YAxis />
            <Tooltip />
            <Legend />
            <Bar dataKey="value" fill="#8884d8" />
          </BarChart>
        )
      
      case 'area':
        return (
          <AreaChart {...commonProps}>
            <CartesianGrid strokeDasharray="3 3" />
            <XAxis dataKey="time" />
            <YAxis />
            <Tooltip />
            <Legend />
            <Area type="monotone" dataKey="value" stroke="#8884d8" fill="#8884d8" />
          </AreaChart>
        )
      
      case 'pie':
        return (
          <PieChart {...commonProps}>
            <Pie
              data={chartData}
              cx="50%"
              cy="50%"
              labelLine={false}
              label={({ name, percent }) => `${name} ${(percent * 100).toFixed(0)}%`}
              outerRadius={80}
              fill="#8884d8"
              dataKey="value"
            />
            <Tooltip />
          </PieChart>
        )
      
      default:
        return <div>Unsupported chart type</div>
    }
  }

  return (
    <div className="advanced-chart">
      <h4>{title}</h4>
      <ResponsiveContainer>
        {renderChart()}
      </ResponsiveContainer>
    </div>
  )
}
```

#### **3. Complete Dashboard with Custom Components**

```typescript
// Complete custom React dashboard
import React, { useState, useEffect } from 'react'
import { AdvancedChart } from './AdvancedChart'
import { StatisticsPanel } from './StatisticsPanel'
import { AlertsPanel } from './AlertsPanel'
import { DeviceStatus } from './DeviceStatus'

interface DashboardState {
  realTimeData: any[]
  historicalData: any[]
  statistics: any
  alerts: any[]
  devices: any[]
}

export const CustomDashboard: React.FC = () => {
  const [dashboardData, setDashboardData] = useState<DashboardState>({
    realTimeData: [],
    historicalData: [],
    statistics: {},
    alerts: [],
    devices: []
  })
  const [loading, setLoading] = useState(true)
  const [selectedTimeRange, setSelectedTimeRange] = useState('-1h')

  useEffect(() => {
    fetchDashboardData()
  }, [selectedTimeRange])

  const fetchDashboardData = async () => {
    try {
      setLoading(true)
      
      const [realTime, historical, stats, alerts, devices] = await Promise.all([
        fetch('/api/realtime/photovoltaic_data'),
        fetch(`/api/historical/photovoltaic_data?timeRange=${selectedTimeRange}`),
        fetch('/api/statistics/photovoltaic_data?field=power_output'),
        fetch('/api/alerts'),
        fetch('/api/devices/status')
      ])

      const [realTimeResult, historicalResult, statsResult, alertsResult, devicesResult] = 
        await Promise.all([
          realTime.json(),
          historical.json(),
          stats.json(),
          alerts.json(),
          devices.json()
        ])

      setDashboardData({
        realTimeData: realTimeResult.data || [],
        historicalData: historicalResult.data || [],
        statistics: statsResult.data || {},
        alerts: alertsResult.data || [],
        devices: devicesResult.data || []
      })
    } catch (error) {
      console.error('Error fetching dashboard data:', error)
    } finally {
      setLoading(false)
    }
  }

  if (loading) return <div>Loading dashboard...</div>

  return (
    <div className="custom-dashboard">
      <header className="dashboard-header">
        <h1>Renewable Energy Monitoring</h1>
        <div className="controls">
          <select 
            value={selectedTimeRange} 
            onChange={(e) => setSelectedTimeRange(e.target.value)}
          >
            <option value="-1h">Last Hour</option>
            <option value="-24h">Last 24 Hours</option>
            <option value="-7d">Last 7 Days</option>
            <option value="-30d">Last 30 Days</option>
          </select>
          <button onClick={fetchDashboardData}>Refresh</button>
        </div>
      </header>
      
      <div className="dashboard-grid">
        {/* Real-time power generation */}
        <div className="chart-section">
          <h3>Real-time Power Generation</h3>
          <AdvancedChart
            data={dashboardData.realTimeData}
            type="line"
            title="Power Output"
            realTime={true}
            height={300}
          />
        </div>
        
        {/* Historical data */}
        <div className="chart-section">
          <h3>Historical Performance</h3>
          <AdvancedChart
            data={dashboardData.historicalData}
            type="area"
            title="Energy Production"
            height={300}
          />
        </div>
        
        {/* Statistics panel */}
        <div className="stats-section">
          <h3>Statistics</h3>
          <StatisticsPanel data={dashboardData.statistics} />
        </div>
        
        {/* Device status */}
        <div className="devices-section">
          <h3>Device Status</h3>
          <DeviceStatus devices={dashboardData.devices} />
        </div>
        
        {/* Alerts */}
        <div className="alerts-section">
          <h3>System Alerts</h3>
          <AlertsPanel alerts={dashboardData.alerts} />
        </div>
      </div>
    </div>
  )
}
```

### **Pros & Cons**

#### **✅ Advantages**
- **Complete control** over user experience
- **Consistent design** throughout the application
- **Better performance** (no iframe overhead)
- **Custom features** and interactions
- **Mobile-responsive** design
- **Modern React patterns**
- **Full customization** capabilities

#### **❌ Disadvantages**
- More development time required
- Need to rebuild visualizations
- Less advanced charting features than Grafana
- Higher maintenance overhead
- Need to implement all features from scratch

### **Use Cases**

- **Custom user interfaces** with specific requirements
- **Mobile-first applications**
- **User-specific dashboards**
- **Applications requiring** deep customization
- **Modern web applications** with specific UX requirements

---

## 📈 Comparison Matrix

| Feature | Grafana Embedding | Hybrid Approach | Pure React |
|---------|------------------|-----------------|------------|
| **Development Speed** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐ |
| **Customization** | ⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| **Performance** | ⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| **User Experience** | ⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| **Maintenance** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐ |
| **Mobile Support** | ⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| **Real-time Updates** | ⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| **Integration Complexity** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐ |

---

## 🚀 Implementation Recommendations

### **For MVP Development**
1. **Start with Option 1** (Grafana Embedding)
   - Quick implementation using existing dashboards
   - Focus on user experience and custom features
   - Minimal development overhead

### **For Production Systems**
1. **Use Option 2** (Hybrid Approach)
   - Leverage Grafana for complex visualizations
   - Build custom React components for user-specific features
   - Gradual migration path

### **For Enterprise Applications**
1. **Consider Option 3** (Pure React)
   - Complete control over user experience
   - Custom branding and features
   - Mobile-first approach

### **Migration Strategy**
1. **Phase 1**: Implement Grafana embedding
2. **Phase 2**: Add custom React components for user features
3. **Phase 3**: Gradually replace Grafana panels with custom components
4. **Phase 4**: Full custom solution with optional Grafana integration

---

## 💡 Best Practices

### **Performance Optimization**
- **Use React.memo** for expensive chart components
- **Implement debouncing** for real-time updates
- **Use code splitting** for large chart libraries
- **Optimize API calls** with proper caching

### **User Experience**
- **Consistent design** across all components
- **Responsive layouts** for mobile devices
- **Loading states** for better UX
- **Error boundaries** for graceful failure handling

### **Data Management**
- **Efficient queries** for InfluxDB
- **Proper data caching** strategies
- **Real-time updates** with WebSocket or polling
- **Data validation** and error handling

---

## 🔧 Troubleshooting

### **Common Issues**

| Issue | Cause | Solution |
|-------|-------|----------|
| **Iframe not loading** | CORS policy | Configure Grafana CORS settings |
| **Chart not updating** | Missing dependencies | Check useEffect dependencies |
| **Performance issues** | Large datasets | Implement data pagination |
| **Mobile responsiveness** | Fixed dimensions | Use responsive containers |

### **Debug Commands**

```bash
# Check Grafana embedding
curl -f http://localhost:3000/api/health

# Test Express API
curl -f http://localhost:3001/api/energy-data

# Check InfluxDB connection
curl -f http://localhost:8086/health
```

---

<div align="center">

**🎯 Choose the right visualization approach for your needs!**

*Each option offers different trade-offs between development speed, customization, and performance.*

</div>
