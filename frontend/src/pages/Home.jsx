"use client";
import "leaflet/dist/leaflet.css";
import "../styles/Home.scss"

import { CRS} from "leaflet";
import { LayerGroup, LayersControl, MapContainer, Rectangle, SVGOverlay } from "react-leaflet";
import { useEffect, useState } from "react";
import MapSVG from "../components/MapSVG";
import WindTurbine from "../api/WindTurbine";
import Photovoltaic from "../api/Photovoltaic";
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
                ] = await Promise.all([
                    await WindTurbine(),
                    await Photovoltaic(),
                ])
                // console.log(_photovoltaic_Data)
                try {
                    // Helper function to safely get value
                    const getValue = (data, field) => {
                        return data?.[field]?._value ?? "N/A";
                    };

                    setMarkersInfo(prev => ({
                        ...prev,
                        turbine_vertical: [
                            ["Prędkość wiatru", getValue(_windTurbine_Data, "wind_speed"), "m\\s"],
                            ["Prędkość obracania", getValue(_windTurbine_Data, "rotor_speed"), "m\\s"],
                            ["Moc wyjściowa ", getValue(_windTurbine_Data, "power_output"), "kw"],
                            ["Temperatura generatora", getValue(_windTurbine_Data, "generator_temperature"), "℃"],
                            ["Kąt natarcia", getValue(_windTurbine_Data, "blade_pitch"), "°"],
                            ["Efektywność", getValue(_windTurbine_Data, "efficiency"), ""],
                        ],
                        ladowarka_sloneczna: [
                            ["Promieniowanie", getValue(_photovoltaic_Data, "irradiance"), "W/m²"],
                            ["Napięcie", getValue(_photovoltaic_Data, "voltage"), "V"],
                            ["Moc wyjściowa ", getValue(_photovoltaic_Data, "power_output"), "W"],
                            ["Temperatura", getValue(_photovoltaic_Data, "temperature"), "℃"],
                            ["Nw co to current", getValue(_photovoltaic_Data, "current"), ":)"],
                            ["Efektywność", getValue(_photovoltaic_Data, "efficiency"), ""],
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