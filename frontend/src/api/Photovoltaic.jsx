import API_SERVER_URL from "./Server";

async function Photovoltaic() {
    const res = await fetch( API_SERVER_URL+"/api/summary/charger?device_id=ladowarka_sloneczna", {
        method: "GET",
        headers: { "Content-Type": "application/json" },
    });
    const data = await res.json();
    return data;
}

export default Photovoltaic;
