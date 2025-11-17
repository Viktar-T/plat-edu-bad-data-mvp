import API_SERVER_URL from "./Server";

async function AlgaeFarm1() {
    const res = await fetch(API_SERVER_URL+"/api/summary/algae_farm?device_id=algy", {
        method: "GET",
        headers: { "Content-Type": "application/json" },
    });
    const data = await res.json();
    return data;
}

export default AlgaeFarm1;

