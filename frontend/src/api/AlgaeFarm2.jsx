import API_SERVER_URL from "./Server";

async function AlgaeFarm2() {
    const res = await fetch(API_SERVER_URL+"/api/summary/algae_farm?device_id=big_algy", {
        method: "GET",
        headers: { "Content-Type": "application/json" },
    });
    const data = await res.json();
    return data;
}

export default AlgaeFarm2;

