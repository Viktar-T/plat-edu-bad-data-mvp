import API_SERVER_URL from "./Server";

async function Biogas() {
    const res = await fetch(API_SERVER_URL+"/api/summary/biogas", {
        method: "GET",
        headers: { "Content-Type": "application/json" },
    });
    const data = await res.json();
    return data;
}

export default Biogas;

