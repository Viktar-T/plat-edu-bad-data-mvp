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
        e.target.fitBounds(focusBounds)
        e.target.setZoom(1)

        e.target.on("click", (e) => {
            console.log("lat lng [" + e.latlng.lng + ", " + e.latlng.lat + "]")
            if (lastclick != null) {
                console.log("size:")
                console.log("[" + Math.abs(e.latlng.lng - lastclick.lng) + ", " + Math.abs(e.latlng.lat - lastclick.lat) + "]")
            }
            lastclick = e.latlng
        })
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
                    setMarkersInfo(prev => ({
                        ...prev,
                        turbine_vertical: [
                            ["Prędkość wiatru", _windTurbine_Data.wind_speed._value, "m\\s"],
                            ["Prędkość obracania", _windTurbine_Data.rotor_speed._value, "m\\s"],
                            ["Moc wyjściowa ", _windTurbine_Data.power_output._value, "kw"],
                            ["Temperatura generatora", _windTurbine_Data.generator_temperature._value, "℃"],
                            ["Kąt natarcia", _windTurbine_Data.blade_pitch._value, "°"],
                            ["Efektywność", _windTurbine_Data.efficiency._value, ""],
                        ],
                        ladowarka_sloneczna: [
                            ["Promieniowanie", _photovoltaic_Data.irradiance._value, "W/m²"],
                            ["Napięcie", _photovoltaic_Data.voltage._value, "V"],
                            ["Moc wyjściowa ", _photovoltaic_Data.power_output._value, "W"],
                            ["Temperatura", _photovoltaic_Data.temperature._value, "℃"],
                            ["Nw co to current", _photovoltaic_Data.current._value, ":)"],
                            ["Efektywność", _photovoltaic_Data.efficiency._value, ""],
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