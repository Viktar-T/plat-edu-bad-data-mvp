import API_SERVER_URL from "./Server";

async function WindTurbine() {
    const res = await fetch(API_SERVER_URL+"/api/summary/big_turbine?device_id=turbine_vertical", {
        method: "GET",
        headers: { "Content-Type": "application/json" },
    });
    const data = await res.json();
    return data;
}

export default WindTurbine;
