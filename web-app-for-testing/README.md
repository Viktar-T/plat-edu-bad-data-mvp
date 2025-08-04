# 🌐 React Web App for Real-Time MQTT Data Visualization

> **Build a React web application to display real-time data from your IoT monitoring system using MQTT WebSocket connections.**

[![React](https://img.shields.io/badge/React-18+-blue?logo=react)](https://reactjs.org/)
[![MQTT](https://img.shields.io/badge/MQTT-WebSocket-green?logo=mqtt)](https://mqtt.org/)
[![WebSocket](https://img.shields.io/badge/WebSocket-Enabled-orange?logo=websocket)](https://developer.mozilla.org/en-US/docs/Web/API/WebSocket)

---

## 📋 Table of Contents

- [🎯 Overview](#-overview)
- [📋 Prerequisites](#-prerequisites)
- [🚀 Quick Start](#-quick-start)
- [🔧 Implementation](#-implementation)
- [📊 Advanced Features](#-advanced-features)
- [🛡️ Security Considerations](#️-security-considerations)
- [💡 Tips & Best Practices](#-tips--best-practices)
- [🔍 Troubleshooting](#-troubleshooting)

---

## 🎯 Overview

This guide shows you how to create a **React web application** that connects to your IoT monitoring system's MQTT broker via WebSocket to display real-time data. Perfect for creating dashboards, monitoring interfaces, and live data visualization.

### 🔄 How It Works

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   MQTT Broker   │───▶│   WebSocket     │───▶│   React App     │
│   (Mosquitto)   │    │   Connection    │    │   (Dashboard)   │
│   Port 9001     │    │   ws://localhost│    │   Real-time UI  │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

---

## 📋 Prerequisites

Before you begin, ensure you have the following:

### ✅ System Requirements

- **MQTT Broker**: Your Mosquitto broker is running with WebSocket enabled
- **WebSocket Port**: Port 9001 is accessible (default WebSocket port)
- **React Environment**: Basic React app setup (create-react-app or similar)
- **Node.js**: Version 14+ for modern React features

### 🔧 MQTT Broker Configuration

Make sure your MQTT broker has WebSocket support enabled:

```bash
# In your mosquitto.conf
listener 1883
protocol mqtt

listener 9001
protocol websockets
```

---

## 🚀 Quick Start

### 1. **Install MQTT.js Library**

The `mqtt.js` library is the standard for browser MQTT/WebSocket connections:

```bash
npm install mqtt
```

### 2. **Create Your MQTT Dashboard Component**

Create a new file: `src/components/MqttDashboard.js`

```jsx
import React, { useEffect, useState } from "react";
import mqtt from "mqtt";

const MQTT_BROKER = "ws://localhost:9001"; // WebSocket URL (change if needed)
const MQTT_TOPIC = "test/topic";           // Your topic

export default function MqttDashboard() {
  const [messages, setMessages] = useState([]);

  useEffect(() => {
    // 1. Connect to broker
    const client = mqtt.connect(MQTT_BROKER);

    // 2. On connection, subscribe to topic
    client.on("connect", () => {
      console.log("Connected to MQTT broker!");
      client.subscribe(MQTT_TOPIC);
    });

    // 3. Listen for messages
    client.on("message", (topic, message) => {
      setMessages((msgs) => [
        ...msgs,
        { topic, message: message.toString(), timestamp: new Date().toLocaleTimeString() }
      ]);
    });

    // 4. Cleanup on unmount
    return () => client.end();
  }, []);

  return (
    <div>
      <h2>Real-Time MQTT Dashboard</h2>
      <ul>
        {messages.map((msg, i) => (
          <li key={i}>
            [{msg.timestamp}] <b>{msg.topic}:</b> {msg.message}
          </li>
        ))}
      </ul>
    </div>
  );
}
```

### 3. **Add Component to Your App**

Update your `src/App.js`:

```jsx
import React from "react";
import MqttDashboard from "./components/MqttDashboard";

function App() {
  return (
    <div className="App">
      <MqttDashboard />
    </div>
  );
}

export default App;
```

### 4. **Start Your Application**

```bash
npm start
```

Open `http://localhost:3000` (or whatever port your React app runs on).

---

## 🔧 Implementation

### 🔌 Connection Configuration

| Parameter | Description | Example |
|-----------|-------------|---------|
| **MQTT_BROKER** | WebSocket URL to your MQTT broker | `ws://localhost:9001` |
| **MQTT_TOPIC** | Topic to subscribe to | `devices/photovoltaic/pv_001/data` |
| **Connection Options** | Additional MQTT connection settings | `{ username, password, clientId }` |

### 📡 Multiple Topic Subscription

```jsx
// Subscribe to multiple topics
const topics = [
  "devices/photovoltaic/+/data",
  "devices/wind_turbine/+/status",
  "system/health/+"
];

topics.forEach(topic => {
  client.subscribe(topic);
});
```

### 🔄 Real-Time Data Handling

```jsx
client.on("message", (topic, message) => {
  try {
    const data = JSON.parse(message.toString());
    
    // Update different state based on topic
    if (topic.includes("photovoltaic")) {
      setSolarData(data);
    } else if (topic.includes("wind_turbine")) {
      setWindData(data);
    }
  } catch (error) {
    console.error("Error parsing message:", error);
  }
});
```

---

## 📊 Advanced Features

### 📈 Data Visualization

For production dashboards, consider these libraries:

| Library | Purpose | Use Case |
|---------|---------|----------|
| **Recharts** | Charts and graphs | Time series data, performance metrics |
| **React-Gauge** | Gauge displays | Real-time values, status indicators |
| **React-Table** | Data tables | Device lists, historical data |
| **React-Grid-Layout** | Dashboard layout | Customizable dashboard arrangements |

### 🎨 Enhanced Dashboard Example

```jsx
import React, { useEffect, useState } from "react";
import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip } from "recharts";
import mqtt from "mqtt";

export default function EnhancedDashboard() {
  const [solarData, setSolarData] = useState([]);
  const [connectionStatus, setConnectionStatus] = useState("disconnected");

  useEffect(() => {
    const client = mqtt.connect("ws://localhost:9001", {
      username: "your_username",
      password: "your_password"
    });

    client.on("connect", () => {
      setConnectionStatus("connected");
      client.subscribe("devices/photovoltaic/+/data");
    });

    client.on("message", (topic, message) => {
      const data = JSON.parse(message.toString());
      setSolarData(prev => [...prev, {
        time: new Date().toLocaleTimeString(),
        power: data.data.power_output,
        temperature: data.data.temperature
      }].slice(-50)); // Keep last 50 readings
    });

    return () => client.end();
  }, []);

  return (
    <div className="dashboard">
      <div className="status-bar">
        <span className={`status ${connectionStatus}`}>
          {connectionStatus.toUpperCase()}
        </span>
      </div>
      
      <div className="charts">
        <LineChart width={600} height={300} data={solarData}>
          <CartesianGrid strokeDasharray="3 3" />
          <XAxis dataKey="time" />
          <YAxis />
          <Tooltip />
          <Line type="monotone" dataKey="power" stroke="#8884d8" />
        </LineChart>
      </div>
    </div>
  );
}
```

---

## 🛡️ Security Considerations

### 🔐 Authentication

For production applications, always implement proper authentication:

```jsx
const client = mqtt.connect("ws://localhost:9001", {
  username: "your_username",
  password: "your_password",
  clientId: `webapp_${Math.random().toString(16).slice(3)}`
});
```

### 🌐 SSL/TLS Encryption

Use secure WebSocket connections in production:

```jsx
// Secure connection
const client = mqtt.connect("wss://your-broker.com:9001", {
  username: "your_username",
  password: "your_password"
});
```

### 🚪 Access Control

Ensure your MQTT broker has proper ACL (Access Control List) configured:

```bash
# In mosquitto ACL file
topic read devices/+/+/data
topic read system/health/+
```

---

## 💡 Tips & Best Practices

### 🎯 Best Practices

| Practice | Description | Benefit |
|----------|-------------|---------|
| **Error Handling** | Always handle connection errors and message parsing | Prevents app crashes |
| **Connection Management** | Proper cleanup on component unmount | Prevents memory leaks |
| **State Management** | Use appropriate state management for complex data | Better performance |
| **Topic Structure** | Follow consistent topic naming conventions | Easier maintenance |

### 🔧 Performance Optimization

```jsx
// Limit message history to prevent memory issues
const [messages, setMessages] = useState([]);

client.on("message", (topic, message) => {
  setMessages(prev => {
    const newMessages = [...prev, { topic, message: message.toString(), timestamp: new Date() }];
    return newMessages.slice(-100); // Keep only last 100 messages
  });
});
```

### 📱 Responsive Design

```css
/* CSS for responsive dashboard */
.dashboard {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 1rem;
  padding: 1rem;
}

.chart-container {
  min-height: 300px;
  border: 1px solid #ddd;
  border-radius: 8px;
  padding: 1rem;
}
```

---

## 🔍 Troubleshooting

### ❌ Common Issues

| Issue | Cause | Solution |
|-------|-------|----------|
| **Connection Failed** | WebSocket port not enabled | Enable WebSocket in mosquitto.conf |
| **No Messages Received** | Wrong topic subscription | Verify topic name and permissions |
| **Authentication Error** | Invalid credentials | Check username/password |
| **Memory Leaks** | No cleanup on unmount | Always call `client.end()` |

### 🔧 Debug Commands

```bash
# Check if WebSocket port is open
netstat -an | grep 9001

# Test MQTT WebSocket connection
wscat -c ws://localhost:9001

# Check mosquitto logs
docker-compose logs mosquitto
```

### 📊 Connection Status Monitoring

```jsx
const [connectionStatus, setConnectionStatus] = useState("disconnected");

client.on("connect", () => {
  setConnectionStatus("connected");
  console.log("✅ Connected to MQTT broker");
});

client.on("error", (error) => {
  setConnectionStatus("error");
  console.error("❌ MQTT connection error:", error);
});

client.on("close", () => {
  setConnectionStatus("disconnected");
  console.log("🔌 MQTT connection closed");
});
```

---

## 🎯 What's Happening Here?

### 🔄 Data Flow Process

1. **🔌 Connect**: Your React app connects to the MQTT broker using WebSocket (`ws://localhost:9001`)
2. **📡 Subscribe**: It subscribes to specific topics (e.g., `devices/photovoltaic/+/data`)
3. **📊 Display**: Every new message is immediately shown in the React UI—real-time updates!
4. **🔄 Update**: The UI automatically re-renders when new data arrives

### 🎨 Use Cases

- **📊 Real-time dashboards** for IoT device monitoring
- **📈 Live charts** showing sensor data trends
- **🔔 Alert displays** for system notifications
- **📱 Mobile-responsive** monitoring interfaces
- **🎛️ Control panels** for device management

---

<div align="center">

**🌐 Ready to build your real-time IoT dashboard?**

*Connect your React app to the MQTT broker and start visualizing live data!*

</div>