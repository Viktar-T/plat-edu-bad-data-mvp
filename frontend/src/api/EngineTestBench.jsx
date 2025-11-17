import API_SERVER_URL from "./Server";

async function EngineTestBench() {
    const res = await fetch(API_SERVER_URL+"/api/summary/engine_test_bench?device_id=engine_bench", {
        method: "GET",
        headers: { "Content-Type": "application/json" },
    });
    const data = await res.json();
    return data;
}

export default EngineTestBench;

