"use client";
import "leaflet/dist/leaflet.css";
import "../styles/Home.scss"

import { CRS} from "leaflet";
import { LayerGroup, LayersControl, MapContainer, Rectangle, SVGOverlay } from "react-leaflet";
import { useEffect, useState } from "react";
import MapSVG from "../components/MapSVG";
import WindTurbine from "../api/WindTurbine";
import Photovoltaic from "../api/Photovoltaic";
import Biogas from "../api/Biogas";
import PVPanels from "../api/PVPanels";
import WindTurbineHAWT from "../api/WindTurbineHAWT";
import AlgaeFarm1 from "../api/AlgaeFarm1";
import AlgaeFarm2 from "../api/AlgaeFarm2";
import { MarkersData, GetMarkersOverlay } from "../api/MarkersData"
import { GetRoomsOverlay } from "../api/RoomsData";
import { GetEletricLinesOverlay } from "../api/EletricLinesData";
const { Overlay } = LayersControl;

const blueColor = { color: 'blue' }
const redColor = { color: 'red' }

function Home() {
    const focusBounds = [
        [-200, -1000],
        [1600, 1900],
    ]
    const debugFocusBounds = false;
    const maxBounds = [
        [-600, -1400],
        [2000, 2300],
    ]
    const debugMaxBounds = false;
    let lastclick = null
    const MapReady = (e) => {
        try {
            const map = e.target;
            if (!map || !map.getContainer()) {
                return;
            }

            // Wait for map to be fully initialized and all panes to be ready
            const initMap = () => {
                try {
                    // Check if map panes are initialized
                    if (map.getPane && map.getPane('tilePane')) {
                        map.fitBounds(focusBounds);
                        map.setZoom(1);
                    } else {
                        // Retry after a short delay if panes aren't ready
                        setTimeout(initMap, 50);
                    }
                } catch (err) {
                    // Silently handle initialization errors - map will still work
                    console.debug("Map initialization:", err.message);
                }
            };

            // Start initialization after a short delay
            setTimeout(initMap, 150);

            map.on("click", (e) => {
                console.log("lat lng [" + e.latlng.lng + ", " + e.latlng.lat + "]")
                if (lastclick != null) {
                    console.log("size:")
                    console.log("[" + Math.abs(e.latlng.lng - lastclick.lng) + ", " + Math.abs(e.latlng.lat - lastclick.lat) + "]")
                }
                lastclick = e.latlng
            })
        } catch (err) {
            console.error("Map ready error:", err);
        }
    }

    const [markersInfo, setMarkersInfo] = useState(Object.fromEntries(
        Object.keys(MarkersData).map(key => [key, []])
    ))


    useEffect(() => {
        let cancelled = false;

        async function fetchLoop() {
            if (cancelled) return;

            try {
                const [
                    _windTurbine_Data,
                    _photovoltaic_Data,
                    _biogas_Data,
                    _pvPanels_Data,
                    _windTurbineHAWT_Data,
                    _algaeFarm1_Data,
                    _algaeFarm2_Data,
                ] = await Promise.all([
                    await WindTurbine(),
                    await Photovoltaic(),
                    await Biogas(),
                    await PVPanels(),
                    await WindTurbineHAWT(),
                    await AlgaeFarm1(),
                    await AlgaeFarm2(),
                ])
                
                // Debug logging
                console.log("API Response - Wind Turbine:", _windTurbine_Data);
                console.log("API Response - Photovoltaic:", _photovoltaic_Data);
                console.log("API Response - Biogas:", _biogas_Data);
                
                try {
                    // Helper function to safely get value
                    const getValue = (data, field) => {
                        if (!data || typeof data !== 'object' || Object.keys(data).length === 0) {
                            return "N/A";
                        }
                        // Check if the field exists and has _value property
                        if (data[field] && typeof data[field] === 'object' && '_value' in data[field]) {
                            return data[field]._value;
                        }
                        // Fallback: check if field exists directly
                        if (field in data) {
                            return data[field];
                        }
                        return "N/A";
                    };

                    setMarkersInfo(prev => ({
                        ...prev,
                        "wind-vawt-simulation": [
                            ["Prędkość wiatru", getValue(_windTurbine_Data, "wind_speed"), "m\\s"],
                            ["Prędkość obracania", getValue(_windTurbine_Data, "rotor_speed"), "m\\s"],
                            ["Moc wyjściowa ", getValue(_windTurbine_Data, "power_output"), "kw"],
                            ["Temperatura generatora", getValue(_windTurbine_Data, "generator_temperature"), "℃"],
                            ["Kąt natarcia", getValue(_windTurbine_Data, "blade_pitch"), "°"],
                            ["Efektywność", getValue(_windTurbine_Data, "efficiency"), ""],
                        ],
                        "pv-hulajnogi-simulation": [
                            ["Promieniowanie", getValue(_photovoltaic_Data, "irradiance"), "W/m²"],
                            ["Napięcie", getValue(_photovoltaic_Data, "voltage"), "V"],
                            ["Moc wyjściowa ", getValue(_photovoltaic_Data, "power_output"), "W"],
                            ["Temperatura", getValue(_photovoltaic_Data, "temperature"), "℃"],
                            ["Nw co to current", getValue(_photovoltaic_Data, "current"), ":)"],
                            ["Efektywność", getValue(_photovoltaic_Data, "efficiency"), ""],
                        ],
                        "biogas-plant-simulation": [
                            ["Temperatura", getValue(_biogas_Data, "temperature"), "℃"],
                            ["pH", getValue(_biogas_Data, "ph"), ""],
                            ["Przepływ gazu", getValue(_biogas_Data, "gas_flow_rate"), "m³/h"],
                            ["Stężenie metanu", getValue(_biogas_Data, "methane_concentration"), "%"],
                            ["Ciśnienie", getValue(_biogas_Data, "pressure"), "bar"],
                            ["Zawartość energii", getValue(_biogas_Data, "energy_content"), "kWh/m³"],
                        ],
                        "pv-hybrid-simulation": [
                            ["Promieniowanie", getValue(_pvPanels_Data, "irradiance"), "W/m²"],
                            ["Napięcie", getValue(_pvPanels_Data, "voltage"), "V"],
                            ["Moc wyjściowa ", getValue(_pvPanels_Data, "power_output"), "W"],
                            ["Temperatura", getValue(_pvPanels_Data, "temperature"), "℃"],
                            ["Prąd", getValue(_pvPanels_Data, "current"), "A"],
                            ["Efektywność", getValue(_pvPanels_Data, "efficiency"), ""],
                        ],
                        "wind-hawt-hybrid-simulation": [
                            ["Prędkość wiatru", getValue(_windTurbineHAWT_Data, "wind_speed"), "m\\s"],
                            ["Prędkość obracania", getValue(_windTurbineHAWT_Data, "rotor_speed"), "m\\s"],
                            ["Moc wyjściowa ", getValue(_windTurbineHAWT_Data, "power_output"), "kw"],
                            ["Temperatura generatora", getValue(_windTurbineHAWT_Data, "generator_temperature"), "℃"],
                            ["Kąt natarcia", getValue(_windTurbineHAWT_Data, "blade_pitch"), "°"],
                            ["Efektywność", getValue(_windTurbineHAWT_Data, "efficiency"), ""],
                        ],
                        "algae-farm-1-simulation": [
                            ["Temperatura", getValue(_algaeFarm1_Data, "temperature"), "℃"],
                            ["pH", getValue(_algaeFarm1_Data, "ph"), ""],
                            ["Azot", getValue(_algaeFarm1_Data, "nitrogen"), "mg/L"],
                            ["Fosfor", getValue(_algaeFarm1_Data, "phosphorus"), "mg/L"],
                        ],
                        "algae-farm-2-simulation": [
                            ["Temperatura", getValue(_algaeFarm2_Data, "temperature"), "℃"],
                            ["pH", getValue(_algaeFarm2_Data, "ph"), ""],
                            ["Azot", getValue(_algaeFarm2_Data, "nitrogen"), "mg/L"],
                            ["Fosfor", getValue(_algaeFarm2_Data, "phosphorus"), "mg/L"],
                        ],
                        "engine-test-bench-simulation": [
                            ["Prędkość obrotowa silnika", "0", "RPM"],
                            ["Moment obrotowy", "0", "Nm"],
                            ["Temperatura oleju", "0", "℃"],
                        ],
                    }));
                } catch (err) {
                    console.log("Idk why but data is empty")
                    console.log(err)
                }

            } catch (err) {
                console.error('Error fetching:', err);
            }

            // Schedule the next run only after this one finishes
            if (!cancelled) {
                setTimeout(fetchLoop, 1000);
            }
        }

        fetchLoop();

        return () => {
            cancelled = true;
        };
    }, []);


    return (
        <>
            <MapContainer
                crs={CRS.Simple}
                center={[0, 0]}
                minZoom={-2}
                maxZoom={1}
                zoom={2}
                zoomSnap={0.1}

                className="leaflet-map"
                whenReady={MapReady}

                maxBounds={maxBounds}

            >
                {/* <ImageOverlay
                    url={P0}
                    bounds={[
                        [0, 0],
                        [914*1.6, 910*1.6],
                    ]}

                >

                </ImageOverlay> */}
                <SVGOverlay
                    attributes={{
                        viewBox: `0 0 990.57 904.5`,
                    }}
                    bounds={[
                        [0, 0],
                        [990.57 * 1.6, 904.5 * 1.6],
                    ]}
                    pane="tilePane"
                >
                    <MapSVG />
                </SVGOverlay>
                <LayersControl position="topright">
                    <Overlay name="pokoje" checked>
                        <LayerGroup>
                            <GetRoomsOverlay />
                        </LayerGroup>
                    </Overlay>
                    <Overlay name="przepływ prądu" checked>
                        <LayerGroup>
                            {GetEletricLinesOverlay()}
                        </LayerGroup>
                    </Overlay>
                    <Overlay name="znaczniki" checked>
                        <LayerGroup>
                            <GetMarkersOverlay markersInfo={markersInfo} /> 
                        </LayerGroup>
                    </Overlay>
                </LayersControl>

                {debugFocusBounds ? <Rectangle bounds={focusBounds} pathOptions={blueColor} /> : null}
                {debugMaxBounds ? <Rectangle bounds={maxBounds} pathOptions={redColor} /> : null}
            </MapContainer>
        </>
    )
}

export default Home;