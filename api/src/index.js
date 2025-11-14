// server.js
import express from "express";
import cors from "cors";
import { InfluxDB } from "@influxdata/influxdb-client";
import { PingAPI } from '@influxdata/influxdb-client-apis'
import dotenv from 'dotenv'
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
  // Default origins
  return [
    'http://localhost:5173',
    'http://localhost:3000',
    'http://robert108.mikrus.xyz:40103'
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

const INFLUXDB_BASE_URL = process.env.INFLUXDB_URL || 'http://robert108.mikrus.xyz:40101'
const token = process.env.TEST_TOKEN;
const org = process.env.INFLUXDB_ORG || "renewable_energy_org";
const bucket = process.env.INFLUXDB_BUCKET || "renewable_energy";
const timeout = 10 * 1000
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
        "big_turbine": "wind_turbine_data",
        "charger": "photovoltaic_data",
        "heat_boiler": "heat_boiler_data",
        "biogas": "biogas_plant_data",
        "storage": "energy_storage_data"
    }
    const machine = req.params.machine;
    const time = req.query?.start;
    const fluxQuery = `
        from(bucket: "${bucket}")
        |> range(start: -${time || "2m"})
        |> filter(fn: (r) => r["_measurement"] == "${machines[machine]}")
        |> last()
    `;
    try {
        const rows = await Query(fluxQuery);
        res.json(rows)
    } catch (err) {
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
