import API_SERVER_URL from "./Server";

async function WindTurbine() {
    try {
        const res = await fetch(API_SERVER_URL+"/api/summary/big_turbine?device_id=turbine_vertical", {
            method: "GET",
            headers: { "Content-Type": "application/json" },
        });
        if (!res.ok) {
            console.error("WindTurbine API error:", res.status, res.statusText);
            return {};
        }
        const data = await res.json();
        console.log("WindTurbine API response:", data);
        return data || {};
    } catch (error) {
        console.error("WindTurbine fetch error:", error);
        return {};
    }
}

export default WindTurbine;
