import API_SERVER_URL from "./Server";

async function PVPanels() {
    const res = await fetch(API_SERVER_URL+"/api/summary/pv_panels?device_id=pv_panels", {
        method: "GET",
        headers: { "Content-Type": "application/json" },
    });
    const data = await res.json();
    return data;
}

export default PVPanels;

