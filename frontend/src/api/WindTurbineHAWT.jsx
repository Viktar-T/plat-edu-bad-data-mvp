import API_SERVER_URL from "./Server";

async function WindTurbineHAWT() {
    const res = await fetch(API_SERVER_URL+"/api/summary/wind_turbine?device_id=wind_turbine", {
        method: "GET",
        headers: { "Content-Type": "application/json" },
    });
    const data = await res.json();
    return data;
}

export default WindTurbineHAWT;

