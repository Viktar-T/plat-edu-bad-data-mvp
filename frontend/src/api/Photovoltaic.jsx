import API_SERVER_URL from "./Server";

async function Photovoltaic() {
    const res = await fetch( API_SERVER_URL+"/api/summary/charger", {
        method: "GET",
        headers: { "Content-Type": "application/json" },
    });
    const data = await res.json();
    return data;
}

export default Photovoltaic;
