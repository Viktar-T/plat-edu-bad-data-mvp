const express = require('express');
const { createProxyMiddleware } = require('http-proxy-middleware');
const path = require('path');

const app = express();
const PORT = 5000;

// Serve static files from the web interface directory
app.use(express.static(path.join(__dirname, '../influxdb-web-interface')));

// Proxy API requests to InfluxDB
app.use('/api', createProxyMiddleware({
  target: 'http://localhost:8086',
  changeOrigin: true,
  logLevel: 'debug',
  onProxyRes: function (proxyRes, req, res) {
    // Add CORS headers
    proxyRes.headers['access-control-allow-origin'] = '*';
    proxyRes.headers['access-control-allow-methods'] = 'GET,PUT,POST,DELETE,OPTIONS';
    proxyRes.headers['access-control-allow-headers'] = 'Content-Type, Authorization, Content-Length, X-Requested-With';
  }
}));

// Proxy health endpoint
app.use('/health', createProxyMiddleware({
  target: 'http://localhost:8086',
  changeOrigin: true,
  onProxyRes: function (proxyRes, req, res) {
    proxyRes.headers['access-control-allow-origin'] = '*';
  }
}));

// Handle preflight requests
app.options('*', (req, res) => {
  res.header('Access-Control-Allow-Origin', '*');
  res.header('Access-Control-Allow-Methods', 'GET,PUT,POST,DELETE,OPTIONS');
  res.header('Access-Control-Allow-Headers', 'Content-Type, Authorization, Content-Length, X-Requested-With');
  res.sendStatus(204);
});

app.listen(PORT, () => {
  console.log(`🚀 Development server running on http://localhost:${PORT}`);
  console.log(`📊 InfluxDB Admin Interface: http://localhost:${PORT}`);
  console.log(`🔄 Proxying API requests to InfluxDB on localhost:8086`);
}); 