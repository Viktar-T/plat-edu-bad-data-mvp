// server.js
import express from "express";
import cors from "cors";
import { InfluxDB } from "@influxdata/influxdb-client";
import { PingAPI } from '@influxdata/influxdb-client-apis'
import dotenv from 'dotenv'
import fs from 'fs';
// import { RegisterPhoto } from "./photovoltaic";
dotenv.config()

const isVercel = process.env.VERCEL === '1' || process.env.VERCEL === 'true';
const app = express();

// CORS Configuration
const getCorsOrigin = () => {
  if (process.env.CORS_ORIGIN) {
    // If CORS_ORIGIN is set, use it (can be a single origin or comma-separated list)
    const origins = process.env.CORS_ORIGIN.split(',').map(origin => origin.trim());
    return origins.length === 1 ? origins[0] : origins;
  }
  // Default origins for local development
  return [
    'http://localhost:5173',
    'http://localhost:3000',
    'http://localhost:3002'
  ];
};

const corsOptions = {
  origin: getCorsOrigin(),
  methods: ['GET', 'POST', 'PUT', 'DELETE', 'OPTIONS'],
  allowedHeaders: ['Content-Type', 'Authorization'],
  credentials: true,
  optionsSuccessStatus: 200
};

app.use(cors(corsOptions));
app.use(express.json());

// InfluxDB Configuration
// In Docker: use service name 'influxdb' for internal communication
// Outside Docker: use localhost or external URL
const runningInsideDocker = () => {
  try {
    return fs.existsSync("/.dockerenv");
  } catch {
    return false;
  }
};

const getInfluxDBUrl = () => {
  if (process.env.INFLUXDB_URL) {
    return process.env.INFLUXDB_URL;
  }

  if (runningInsideDocker()) {
    return 'http://influxdb:8086';
  }

  const devPort = process.env.DEV_INFLUXDB_PORT || process.env.INFLUXDB_PORT || '8086';
  return `http://localhost:${devPort}`;
};

const resolveInfluxToken = () => {
  const candidates = [
    process.env.TEST_TOKEN,
    process.env.INFLUXDB_TOKEN,
    process.env.INFLUXDB_ADMIN_TOKEN,
    process.env.NODE_RED_INFLUXDB_TOKEN,
  ];

  return candidates.find(Boolean);
};

const INFLUXDB_BASE_URL = getInfluxDBUrl();
const token = resolveInfluxToken();
const org = process.env.INFLUXDB_ORG || "renewable_energy_org";
const bucket = process.env.INFLUXDB_BUCKET || "renewable_energy";
const timeout = 10 * 1000

if (!token) {
  throw new Error(
    'Missing InfluxDB token. Please set TEST_TOKEN or INFLUXDB_TOKEN in your environment.'
  );
}

const influx = new InfluxDB({ url: INFLUXDB_BASE_URL, token, timeout });
const pingAPI = new PingAPI(influx)
const queryApi = influx.getQueryApi(org);

async function Query(fluxQuery) {
    return new Promise((resolve, reject) => {
        const rows = {};

        queryApi.queryRows(fluxQuery, {
            next(row, tableMeta) {
                const _rowObject = tableMeta.toObject(row)
                rows[_rowObject._field] = _rowObject
            },
            error(error) {
                reject(error);
            },
            complete() {
                resolve(rows);
            },
        });
    });
}

// RegisterPhoto(app);

app.post("/api/query", async (req, res) => {
    const { fluxQuery } = req.body;
    try {
        const rows = await Query(fluxQuery);
        res.json(rows)
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

app.get("/api/summary/:machine", async (req, res) => {
    // parameter to provide when calling api : name of the table in database for given machine
    const machines = {
        "big_turbine": "wind-vawt",
        "charger": "pv-hulajnogi",
        "heat_boiler": "heat-boiler",
        "biogas": "biogas-plant",
        "storage": "energy-storage",
        "pv_panels": "pv-hybrid",
        "wind_turbine": "wind-hawt-hybrid",
        "algae_farm": null, // Will be determined by device_id
        "engine_test_bench": "engine-test-bench"
    }
    
    // Map device_id to measurement for algae farms
    const deviceIdToMeasurement = {
        "algy": "algae-farm-1",
        "big_algy": "algae-farm-2"
    }
    
    const machine = req.params.machine;
    const deviceId = req.query?.device_id;
    const time = req.query?.start;
    
    // Determine measurement name
    let measurement = machines[machine];
    
    // Special handling for algae_farm - use device_id to determine measurement
    if (machine === "algae_farm" && deviceId && deviceIdToMeasurement[deviceId]) {
        measurement = deviceIdToMeasurement[deviceId];
    }
    
    if (!measurement) {
        return res.status(400).json({ error: `Unknown machine type: ${machine} or missing device_id for algae_farm` });
    }
    
    let fluxQuery = `
        from(bucket: "${bucket}")
        |> range(start: -${time || "2m"})
        |> filter(fn: (r) => r["_measurement"] == "${measurement}")
        |> last()
    `;
    
    console.log(`Query for ${machine} (${measurement}):`);
    console.log(fluxQuery);
    
    try {
        const rows = await Query(fluxQuery);
        const fieldCount = Object.keys(rows).length;
        console.log(`Query for ${machine} (${measurement}): ${fieldCount} fields found`);
        if (fieldCount === 0) {
            console.log('⚠️ No data returned from InfluxDB');
        }
        res.json(rows)
    } catch (err) {
        console.error(`❌ Query error for ${machine}:`, err.message);
        res.status(500).json({ error: err.message });
    }
})

// Root route
app.get("/", async (req, res) => {
    res.json({ 
        service: "Renewable Energy IoT API",
        version: "1.0.0",
        status: "running",
        endpoints: {
            health: "/health",
            api: "/api"
        }
    })
})

app.get("/health", async (req, res) => {
    res.json({ health: "ok1" })
})

app.get("/health2", async (req, res) => {
    res.json({ health: "ok1" })
})

function TestAccess() {
    queryApi.queryRows('buckets()', {
        next(row, tableMeta) {
            const data = tableMeta.toObject(row)
            console.log('Bucket:', data.name)
        },
        error(error) {
            console.error("Token " + token)
            console.error('❌ Access denied or query failed:', error)
        },
        complete() {
            console.log('✅ Access confirmed!')
            console.log('Server running on vercel ' + (isVercel ? "✔️":"❌"))
            if (!isVercel) {
                StartWeb()
            }
        },
    })
}

function StartWeb() {
    const port = process.env.PORT || 3001;
    console.log("🔄 Starting server.")
    app.listen(port, () => console.log(`✅ API running on :${port}`));
}



pingAPI.getPing()
    .then(() => {
        console.log('\nPing ✔️  SUCCESS ✔️')
        TestAccess()
    })
    .catch((error) => {
        console.error(error)
        console.log('\nFinished ❌ERROR❌')
    })

export default app
