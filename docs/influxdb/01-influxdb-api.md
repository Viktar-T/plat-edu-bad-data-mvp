# 📊 InfluxDB 2.7 RESTful API Guide for React Web App Developers

> **Comprehensive guide for integrating InfluxDB 2.7 RESTful API with React applications for renewable energy IoT monitoring.**

[![InfluxDB](https://img.shields.io/badge/InfluxDB-2.7-green?logo=influxdb)](https://influxdata.com/)
[![React](https://img.shields.io/badge/React-18+-blue?logo=react)](https://reactjs.org/)
[![TypeScript](https://img.shields.io/badge/TypeScript-5.0+-blue?logo=typescript)](https://www.typescriptlang.org/)
[![Docker](https://img.shields.io/badge/Docker-Enabled-blue?logo=docker)](https://www.docker.com/)
[![Production](https://img.shields.io/badge/Production-Deployed-green?logo=server)](https://robert108.mikrus.xyz)

---

## 📋 Table of Contents

- [🎯 Overview](#-overview)
- [🔧 System Configuration](#-system-configuration)
- [🌐 Mikrus VPS Production Deployment](#-mikrus-vps-production-deployment)
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

This guide provides comprehensive documentation for integrating InfluxDB 2.7 RESTful API with **React frontend and Express backend** applications for renewable energy IoT monitoring. Your system is **successfully deployed on Mikrus VPS** with the following configuration:

**Architecture**: React Frontend ↔ Express Backend ↔ InfluxDB 2.7

### 🚀 Integration Benefits

- **Streaming Analytics**: InfluxDB integrates easily with streaming analytics tools of choice
- **Client Libraries**: Query data directly via API or use client libraries for popular programming languages
- **Full-Stack Architecture**: Express backend handles data processing, React frontend provides UI
- **Scalable Design**: Separation of concerns between frontend, backend, and database layers
- **Production Ready**: Successfully deployed on Mikrus VPS with direct port access

### 🔧 Current Production Setup

- **InfluxDB Version**: 2.7
- **Production URL**: `http://robert108.mikrus.xyz:40101`
- **Local Development URL**: `http://localhost:8086`
- **Organization**: `renewable_energy_org`
- **Bucket**: `renewable_energy`
- **Retention Policy**: 30 days
- **Authentication**: Token-based (disabled for development, enabled for production)

### 📊 Data Flow Architecture

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   IoT Devices   │───▶│   MQTT Broker   │───▶│   Node-RED      │───▶│   InfluxDB      │
│   (Simulated)   │    │   (Mosquitto)   │    │   (Processing)  │    │   (Time-Series) │
│   Port 40098    │    │   Port 40098    │    │   Port 40100    │    │   Port 40101    │
└─────────────────┘    └─────────────────┘    └─────────────────┘    └─────────────────┘
                                                                              │
                                                                              ▼
                                                                     ┌─────────────────┐
                                                                     │   Express       │
                                                                     │   Backend API   │
                                                                     │   (Under Dev)   │
                                                                     └─────────────────┘
                                                                              │
                                                                              ▼
                                                                     ┌─────────────────┐
                                                                     │   React App     │
                                                                     │   (Under Dev)   │
                                                                     └─────────────────┘
```

### 🎯 Current Project Status

- **✅ Production Deployment**: Successfully running on Mikrus VPS
- **✅ Core Services**: MQTT, InfluxDB, Node-RED, Grafana operational
- **✅ Data Flow**: End-to-end data pipeline working
- **🚧 Web App Development**: Basic Express/React setup, needs development
- **📊 Visualization**: Grafana dashboards operational
- **🔒 Security**: Basic authentication implemented

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

### 🌐 API Base URLs

```typescript
// Production (Mikrus VPS)
const INFLUXDB_BASE_URL_PROD = 'http://robert108.mikrus.xyz:40101'
const INFLUXDB_API_VERSION = 'v2'
const INFLUXDB_API_URL_PROD = `${INFLUXDB_BASE_URL_PROD}/api/${INFLUXDB_API_VERSION}`

// Local Development
const INFLUXDB_BASE_URL_DEV = 'http://localhost:8086'
const INFLUXDB_API_URL_DEV = `${INFLUXDB_BASE_URL_DEV}/api/${INFLUXDB_API_VERSION}`

// Environment-based configuration
const INFLUXDB_BASE_URL = process.env.NODE_ENV === 'production' 
  ? INFLUXDB_BASE_URL_PROD 
  : INFLUXDB_BASE_URL_DEV

const INFLUXDB_API_URL = `${INFLUXDB_BASE_URL}/api/${INFLUXDB_API_VERSION}`
```

---

## 🌐 Mikrus VPS Production Deployment

### 🚀 Production Access Information

Your InfluxDB is **successfully deployed and running** on Mikrus VPS with the following access details:

#### **Direct Service Access**
```bash
# Production URLs (Mikrus VPS)
Grafana Dashboard:    http://robert108.mikrus.xyz:40099
Node-RED Editor:      http://robert108.mikrus.xyz:40100
InfluxDB Admin:       http://robert108.mikrus.xyz:40101
MQTT Broker:          robert108.mikrus.xyz:40098
```

#### **Production Credentials**
```bash
# InfluxDB Access
URL: http://robert108.mikrus.xyz:40101
Username: admin
Password: admin_password_123
Token: renewable_energy_admin_token_123
Organization: renewable_energy_org
Bucket: renewable_energy
```

### 🔧 Production Configuration

#### **Docker Container Details**
```bash
# Container Information
Container Name: iot-influxdb2
Image: influxdb:2.7
Port Mapping: 40101 (external) → 8086 (internal)
Status: ✅ Running and healthy
```

#### **Production Environment Variables**
```bash
# Production-specific settings
INFLUXDB_PORT=40101
INFLUXDB_HTTP_AUTH_ENABLED=false  # Disabled for development
INFLUXDB_LOGGING_LEVEL=info
INFLUXDB_METRICS_DISABLED=true
INFLUXDB_REPORTING_DISABLED=true
```

### 🔌 API Integration for Production

#### **Production API Client Configuration**
```typescript
// Production-ready InfluxDB client configuration
const INFLUXDB_CONFIG_PROD = {
  url: 'http://robert108.mikrus.xyz:40101',
  token: 'renewable_energy_admin_token_123',
  org: 'renewable_energy_org',
  bucket: 'renewable_energy',
  timeout: 30000, // 30 seconds
  retries: 3
}

// Environment-aware configuration
const getInfluxDBConfig = () => {
  const isProduction = process.env.NODE_ENV === 'production'
  
  return {
    url: isProduction 
      ? 'http://robert108.mikrus.xyz:40101'
      : 'http://localhost:8086',
    token: 'renewable_energy_admin_token_123',
    org: 'renewable_energy_org',
    bucket: 'renewable_energy',
    timeout: isProduction ? 30000 : 10000,
    retries: isProduction ? 3 : 1
  }
}
```

#### **Production API Endpoints**
```typescript
// Production API endpoints
const PRODUCTION_ENDPOINTS = {
  // Query API
  query: 'http://robert108.mikrus.xyz:40101/api/v2/query',
  
  // Write API
  write: 'http://robert108.mikrus.xyz:40101/api/v2/write',
  
  // Organizations API
  organizations: 'http://robert108.mikrus.xyz:40101/api/v2/orgs',
  
  // Buckets API
  buckets: 'http://robert108.mikrus.xyz:40101/api/v2/buckets',
  
  // Health Check
  health: 'http://robert108.mikrus.xyz:40101/health',
  
  // Admin Interface
  admin: 'http://robert108.mikrus.xyz:40101'
}
```

### 🛡️ Production Security Considerations

#### **Current Security Status**
```bash
# Security Configuration
✅ Authentication: Token-based (renewable_energy_admin_token_123)
✅ Network: Isolated Docker network (172.20.0.0/16)
✅ Health Checks: Enabled for all services
✅ Restart Policy: unless-stopped
⚠️  HTTP Auth: Disabled (development mode)
⚠️  SSL/TLS: Not configured (HTTP only)
```

#### **Recommended Production Security Enhancements**
```typescript
// Security improvements for production
const PRODUCTION_SECURITY_CONFIG = {
  // Enable authentication
  INFLUXDB_HTTP_AUTH_ENABLED: true,
  
  // Use HTTPS
  SSL_ENABLED: true,
  SSL_CERT_PATH: '/path/to/cert.pem',
  SSL_KEY_PATH: '/path/to/key.pem',
  
  // Rate limiting
  API_RATE_LIMIT: 1000,
  API_RATE_LIMIT_WINDOW: '1m',
  
  // Connection limits
  MAX_CONNECTIONS: 1000,
  READ_TIMEOUT: '60s'
}
```

### 🔍 Production Monitoring

#### **Health Check Endpoints**
```bash
# Health check URLs
InfluxDB Health: http://robert108.mikrus.xyz:40101/health
Grafana Health:  http://robert108.mikrus.xyz:40099/api/health
Node-RED Health: http://robert108.mikrus.xyz:40100
```

#### **Container Status Commands**
```bash
# SSH to VPS and check status
ssh root@robert108.mikrus.xyz -p10108
cd /root/renewable-energy-iot

# Check service status
docker-compose ps

# View logs
docker-compose logs influxdb

# Health check
curl -f http://localhost:8086/health
```

### 📊 Production Data Access

#### **Direct API Access Examples**
```bash
# Test InfluxDB connection
curl -H "Authorization: Token renewable_energy_admin_token_123" \
     "http://robert108.mikrus.xyz:40101/api/v2/buckets?org=renewable_energy_org"

# Test query endpoint
curl -X POST \
     -H "Authorization: Token renewable_energy_admin_token_123" \
     -H "Content-Type: application/vnd.flux" \
     -d 'from(bucket:"renewable_energy") |> range(start: -1h) |> limit(n:5)' \
     "http://robert108.mikrus.xyz:40101/api/v2/query?org=renewable_energy_org"
```

#### **Production Data Flow**
```typescript
// Production data flow example
const productionDataFlow = {
  // 1. MQTT data collection
  mqtt: 'robert108.mikrus.xyz:40098',
  
  // 2. Node-RED processing
  nodeRed: 'http://robert108.mikrus.xyz:40100',
  
  // 3. InfluxDB storage
  influxdb: 'http://robert108.mikrus.xyz:40101',
  
  // 4. Grafana visualization
  grafana: 'http://robert108.mikrus.xyz:40099',
  
  // 5. Custom web app (under development)
  webApp: 'http://robert108.mikrus.xyz:3000' // Future
}
```

### 🛠️ Working with Mikrus VPS Deployment

#### **Quick Start Guide for Production**

1. **Access Your Production InfluxDB**
```bash
# Direct web interface
http://robert108.mikrus.xyz:40101

# API endpoint
http://robert108.mikrus.xyz:40101/api/v2/
```

2. **Test API Connectivity**

**For Linux/macOS (bash):**
```bash
# Health check
curl http://robert108.mikrus.xyz:40101/health

# List buckets
curl -H "Authorization: Token renewable_energy_admin_token_123" \
     "http://robert108.mikrus.xyz:40101/api/v2/buckets?org=renewable_energy_org"
```

**For Windows PowerShell:**
```powershell
# Health check
Invoke-WebRequest -Uri "http://robert108.mikrus.xyz:40101/health"

# List buckets
Invoke-WebRequest -Uri "http://robert108.mikrus.xyz:40101/api/v2/buckets?org=renewable_energy_org" `
                 -Headers @{"Authorization" = "Token renewable_energy_admin_token_123"}

# Alternative PowerShell syntax
$headers = @{
    "Authorization" = "Token renewable_energy_admin_token_123"
}
Invoke-WebRequest -Uri "http://robert108.mikrus.xyz:40101/api/v2/buckets?org=renewable_energy_org" -Headers $headers
```

3. **Query Production Data**

**For Linux/macOS (bash):**
```bash
# Get recent photovoltaic data
curl -X POST \
     -H "Authorization: Token renewable_energy_admin_token_123" \
     -H "Content-Type: application/vnd.flux" \
     -d 'from(bucket:"renewable_energy") |> range(start: -1h) |> filter(fn: (r) => r._measurement == "photovoltaic_data") |> limit(n:10)' \
     "http://robert108.mikrus.xyz:40101/api/v2/query?org=renewable_energy_org"
```

**For Windows PowerShell:**
```powershell
# Get recent photovoltaic data
$headers = @{
    "Authorization" = "Token renewable_energy_admin_token_123"
    "Content-Type" = "application/vnd.flux"
}

$body = 'from(bucket:"renewable_energy") |> range(start: -1h) |> filter(fn: (r) => r._measurement == "photovoltaic_data") |> limit(n:10)'

Invoke-WebRequest -Uri "http://robert108.mikrus.xyz:40101/api/v2/query?org=renewable_energy_org" `
                 -Method POST `
                 -Headers $headers `
                 -Body $body
```

#### **PowerShell Testing Scripts**

**📁 Complete Test Script**: [`tests/deploy-vps-mikrus/test-unfluxdb-api.ps1`](../tests/deploy-vps-mikrus/test-unfluxdb-api.ps1)

This comprehensive test script provides detailed output and tests all major InfluxDB API endpoints.

**Quick Test Commands:**
```powershell
# Run the complete test script
.\tests\deploy-vps-mikrus\test-unfluxdb-api.ps1

# Or run individual tests
# Test health endpoint
Invoke-WebRequest -Uri "http://robert108.mikrus.xyz:40101/health"

# Test buckets endpoint
$headers = @{"Authorization" = "Token renewable_energy_admin_token_123"}
Invoke-WebRequest -Uri "http://robert108.mikrus.xyz:40101/api/v2/buckets?org=renewable_energy_org" -Headers $headers
```

**Test Coverage:**
- ✅ Health endpoint verification
- ✅ Authentication and bucket listing
- ✅ Flux query execution
- ✅ Organization access
- ✅ Detailed response analysis
- ✅ Error handling and troubleshooting
- ✅ Summary report with success rate

#### **PowerShell Data Retrieval Functions**

```powershell
# PowerShell functions for working with InfluxDB data
function Get-InfluxDBData {
    param(
        [string]$Measurement = "photovoltaic_data",
        [string]$TimeRange = "-1h",
        [string]$DeviceId = "",
        [string]$Field = "",
        [string]$BaseUrl = "http://robert108.mikrus.xyz:40101",
        [string]$Token = "renewable_energy_admin_token_123",
        [string]$Org = "renewable_energy_org",
        [string]$Bucket = "renewable_energy"
    )
    
    $headers = @{
        "Authorization" = "Token $Token"
        "Content-Type" = "application/vnd.flux"
    }
    
    # Build Flux query
    $fluxQuery = "from(bucket: `"$Bucket`") |> range(start: $TimeRange) |> filter(fn: (r) => r._measurement == `"$Measurement`")"
    
    if ($DeviceId) {
        $fluxQuery += " |> filter(fn: (r) => r.device_id == `"$DeviceId`")"
    }
    
    if ($Field) {
        $fluxQuery += " |> filter(fn: (r) => r._field == `"$Field`")"
    }
    
    $fluxQuery += " |> sort(columns: [\"_time\"])"
    
    try {
        $response = Invoke-WebRequest -Uri "$BaseUrl/api/v2/query?org=$Org" -Method POST -Headers $headers -Body $fluxQuery
        return $response.Content
    }
    catch {
        Write-Host "Error retrieving data: $($_.Exception.Message)" -ForegroundColor Red
        return $null
    }
}

# Example usage
Write-Host "Getting photovoltaic data..." -ForegroundColor Green
$data = Get-InfluxDBData -Measurement "photovoltaic_data" -TimeRange "-1h"
if ($data) {
    Write-Host "Data retrieved successfully!" -ForegroundColor Green
    Write-Host "Data length: $($data.Length) characters" -ForegroundColor Yellow
}

# Get specific device data
Write-Host "Getting device data..." -ForegroundColor Green
$deviceData = Get-InfluxDBData -Measurement "photovoltaic_data" -DeviceId "pv_001" -Field "power_output"
if ($deviceData) {
    Write-Host "Device data retrieved!" -ForegroundColor Green
}
```

#### **Production API Client Setup**

```typescript
// Production-ready InfluxDB client
class ProductionInfluxDBClient {
  private baseUrl: string
  private token: string
  private org: string
  private bucket: string

  constructor() {
    this.baseUrl = 'http://robert108.mikrus.xyz:40101'
    this.token = 'renewable_energy_admin_token_123'
    this.org = 'renewable_energy_org'
    this.bucket = 'renewable_energy'
  }

  private getHeaders(contentType: string = 'application/json') {
    return {
      'Authorization': `Token ${this.token}`,
      'Content-Type': contentType
    }
  }

  // Query data from production
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
    return this.parseCSVResult(csvData)
  }

  // Get device data from production
  async getDeviceData(deviceId: string, measurement: string, timeRange: string = '-1h') {
    const fluxQuery = `
      from(bucket: "${this.bucket}")
        |> range(start: ${timeRange})
        |> filter(fn: (r) => r._measurement == "${measurement}")
        |> filter(fn: (r) => r.device_id == "${deviceId}")
        |> sort(columns: ["_time"])
    `
    return this.query(fluxQuery)
  }

  // Get system health
  async health(): Promise<boolean> {
    try {
      const response = await fetch(`${this.baseUrl}/health`)
      return response.ok
    } catch {
      return false
    }
  }

  private parseCSVResult(csvData: string): any[] {
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
}

// Usage example
const productionClient = new ProductionInfluxDBClient()

// Get photovoltaic data
productionClient.getDeviceData('pv_001', 'photovoltaic_data', '-24h')
  .then(data => console.log('Production data:', data))
  .catch(error => console.error('Error:', error))
```

#### **Production Monitoring Dashboard**

```typescript
// React component for production monitoring
import React, { useState, useEffect } from 'react'

interface ProductionDashboardProps {
  deviceId?: string
}

export function ProductionDashboard({ deviceId }: ProductionDashboardProps) {
  const [data, setData] = useState<any[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    const fetchProductionData = async () => {
      try {
        setLoading(true)
        
        const response = await fetch('http://robert108.mikrus.xyz:40101/api/v2/query', {
          method: 'POST',
          headers: {
            'Authorization': 'Token renewable_energy_admin_token_123',
            'Content-Type': 'application/vnd.flux',
            'Accept': 'application/csv'
          },
          body: `
            from(bucket: "renewable_energy")
              |> range(start: -1h)
              |> filter(fn: (r) => r._measurement == "photovoltaic_data")
              ${deviceId ? `|> filter(fn: (r) => r.device_id == "${deviceId}")` : ''}
              |> sort(columns: ["_time"])
          `
        })

        if (!response.ok) {
          throw new Error(`Production API error: ${response.statusText}`)
        }

        const csvData = await response.text()
        const parsedData = parseCSVResult(csvData)
        setData(parsedData)
      } catch (err) {
        setError(err instanceof Error ? err.message : 'Unknown error')
      } finally {
        setLoading(false)
      }
    }

    fetchProductionData()
  }, [deviceId])

  if (loading) return <div>Loading production data...</div>
  if (error) return <div>Error: {error}</div>

  return (
    <div className="production-dashboard">
      <h2>Production Data from Mikrus VPS</h2>
      <div className="data-summary">
        <p>Data Points: {data.length}</p>
        <p>Latest: {data[data.length - 1]?._time}</p>
      </div>
      <div className="data-table">
        {data.slice(-5).map((row, index) => (
          <div key={index} className="data-row">
            <span>{row._time}</span>
            <span>{row.device_id}</span>
            <span>{row._field}</span>
            <span>{row._value}</span>
          </div>
        ))}
      </div>
    </div>
  )
}

function parseCSVResult(csvData: string): any[] {
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
```

#### **Production Troubleshooting**

```bash
# 1. Check if services are running
ssh root@robert108.mikrus.xyz -p10108
cd /root/renewable-energy-iot
docker-compose ps

# 2. Check InfluxDB logs
docker-compose logs influxdb

# 3. Test InfluxDB connectivity
curl -f http://localhost:8086/health

# 4. Check data in InfluxDB
docker-compose exec influxdb influx query \
  --org renewable_energy_org \
  --token renewable_energy_admin_token_123 \
  'from(bucket:"renewable_energy") |> range(start: -1h) |> limit(n:5)'

# 5. Restart services if needed
docker-compose restart influxdb
```

#### **Production Data Backup**

```bash
# Create backup of InfluxDB data
ssh root@robert108.mikrus.xyz -p10108
cd /root/renewable-energy-iot

# Backup data directory
tar -czf influxdb-backup-$(date +%Y%m%d).tar.gz influxdb/data/

# Export data using InfluxDB CLI
docker-compose exec influxdb influx query \
  --org renewable_energy_org \
  --token renewable_energy_admin_token_123 \
  --file-format csv \
  'from(bucket:"renewable_energy") |> range(start: -30d)' \
  > backup-data-$(date +%Y%m%d).csv
```

---

## 🔐 Authentication & Security

### 🔑 Token-Based Authentication

InfluxDB 2.7 uses token-based authentication. For your Express backend:

```typescript
// Configuration
const INFLUXDB_CONFIG = {
  url: process.env.NODE_ENV === 'production' 
    ? 'http://robert108.mikrus.xyz:40101'
    : 'http://localhost:8086',
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
      ? 'http://robert108.mikrus.xyz:40101'
      : 'http://localhost:8086',
    token: process.env.REACT_APP_INFLUXDB_TOKEN || 'renewable_energy_admin_token_123',
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

### 🔌 Current Web App Development Status

**Status**: 🚧 **Under Development** - Basic setup exists, needs significant development

#### **Current Implementation**
```typescript
// Current basic Express backend (web-app-for-testing/backend/server.js)
const express = require('express');
const cors = require('cors');

const app = express();
const port = process.env.PORT || 3001;

app.use(cors());
app.use(express.json());

app.get('/health', (req, res) => {
  res.json({ status: 'ok' });
});

app.get('/', (req, res) => {
  res.json({ message: 'Express backend running' });
});

app.listen(port, () => {
  console.log(`Express backend listening on port ${port}`);
});
```

#### **Planned Express Backend API Endpoints**

```typescript
import { useState, useEffect, useCallback } from 'react'

interface UseInfluxDataOptions {
  measurement: string
  timeRange: string
  deviceId?: string
  field?: string
  interval?: number
}

// Planned Express.js endpoint for fetching InfluxDB data
app.get('/api/energy-data', async (req, res) => {
  try {
    const { measurement, timeRange, deviceId, field } = req.query
    
    // Production vs Development configuration
    const influxConfig = process.env.NODE_ENV === 'production' 
      ? {
          url: 'http://robert108.mikrus.xyz:40101',
          token: 'renewable_energy_admin_token_123',
          org: 'renewable_energy_org',
          bucket: 'renewable_energy'
        }
      : {
          url: 'http://localhost:8086',
          token: 'renewable_energy_admin_token_123',
          org: 'renewable_energy_org',
          bucket: 'renewable_energy'
        }
    
    let fluxQuery = `
      from(bucket: "${influxConfig.bucket}")
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
    
    const result = await executeQuery(fluxQuery, influxConfig)
    const parsedData = parseCSVResult(result)
    
    res.json({
      success: true,
      data: parsedData,
      timestamp: new Date().toISOString(),
      source: process.env.NODE_ENV === 'production' ? 'production' : 'development'
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

## 📊 Current Project Status Summary

### 🎯 **Production Deployment Status**
- **✅ Successfully Deployed**: All core services running on Mikrus VPS
- **✅ Data Flow**: End-to-end pipeline operational (MQTT → Node-RED → InfluxDB → Grafana)
- **✅ Monitoring**: Grafana dashboards providing real-time visualization
- **✅ API Access**: InfluxDB RESTful API accessible at `http://robert108.mikrus.xyz:40101`

### 🚧 **Web App Development Status**
- **🚧 Express Backend**: Basic setup exists, needs InfluxDB API integration
- **🚧 React Frontend**: Basic setup exists, needs development
- **📋 Next Steps**: Implement full API integration and React components

### 🔧 **Available Resources**
- **Production InfluxDB**: `http://robert108.mikrus.xyz:40101`
- **Grafana Dashboards**: `http://robert108.mikrus.xyz:40099`
- **Node-RED Editor**: `http://robert108.mikrus.xyz:40100`
- **MQTT Broker**: `robert108.mikrus.xyz:40098`

### 🛠️ **Immediate Development Tasks**
1. **Express Backend Enhancement**: Add InfluxDB API integration
2. **React Frontend Development**: Create monitoring components
3. **Production Integration**: Connect web app to production InfluxDB
4. **Security Enhancement**: Implement proper authentication
5. **Testing**: Add comprehensive API testing

### 📚 **Documentation Status**
- **✅ InfluxDB API Guide**: This comprehensive guide
- **✅ Production Deployment**: Fully documented
- **✅ System Architecture**: Well documented
- **📋 Web App Development**: Needs documentation as development progresses

---

<div align="center">

**🌐 Ready to integrate InfluxDB with your React app?**

*Your production InfluxDB is running and ready for integration!*

**Production URL**: `