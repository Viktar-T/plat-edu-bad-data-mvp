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
app.use(cors())
app.use(express.json());

const INFLUXDB_BASE_URL_PROD = 'http://robert108.mikrus.xyz:40101'
const token = process.env.TEST_TOKEN;
const org = "renewable_energy_org";
const timeout = 10 * 1000
const influx = new InfluxDB({ url: INFLUXDB_BASE_URL_PROD, token, timeout });
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
    } catch {
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
        from(bucket: "renewable_energy")
        |> range(start: -${time || "2m"})
        |> filter(fn: (r) => r["_measurement"] == "${machines[machine]}")
        |> last()
    `;
    try {
        const rows = await Query(fluxQuery);
        res.json(rows)
    } catch {
        res.status(500).json({ error: err.message });
    }
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
    console.log("🔄 Starting server.")
    app.listen(3001, () => console.log("✅ API running on :3001"));
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
