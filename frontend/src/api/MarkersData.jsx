import { LayerGroup, LayersControl, MapContainer, Rectangle, SVGOverlay } from "react-leaflet";
import AutoFitText from "../components/AutoFitText";
import { useNavigate } from "react-router-dom";

export const CloudSize = [600, 300]
const url = "/device/"

// Mapping of marker keys to lab images
export const MarkerImageMap = {
    "algae-farm-1-simulation": "/labs/5.1. Algae-inside-farm-R121/5.1. Algae-inside.jpg",
    "huljanogi_converter": "/labs/1.1. PV-Hulajnogi-Outside-R06/1.1.2 Inverter.jpg",
    "pv-hulajnogi-simulation": "/labs/1.1. PV-Hulajnogi-Outside-R06/1.1.1 PV-Hulajnogi.jpg",
    "wind-vawt-simulation": "/labs/2.1. Wind-Big-Vertical-Storage/2.1.1. Wind-Big-Vertical.jpg",
    "energy-storage-simulation": "/labs/2.1. Wind-Big-Vertical-Storage/2.1.3. Wind-Big-Vertical-inverter-storage.jpg",
    "engine-test-bench-simulation": "/labs/6.1. Engine_bench-R121/6.1. Engine_bench.jpg",
    "biogas-plant-simulation": "/labs/3.1. Biogaz-KIOZE-small_plan/3.1. Biogaz-KIOZE.jpg",
    "wind-hawt-hybrid-simulation": "/labs/2.2. Solar-Wind Hybrid Station/2.2.1-Wind-Small-Horizontal.jpg",
    "pv-hybrid-simulation": "/labs/2.2. Solar-Wind Hybrid Station/2.2.5-PV-roof.jpg",
    "algae-farm-2-simulation": "/labs/5.3. Algae-outside/5.3. Algae-outside.jpg",
    "hybride_is": "/labs/2.2. Solar-Wind Hybrid Station/2.2.4-Controler.jpg",
    "heat-boiler-simulation": "/labs/4.1. Heat-Sterling-Storage/4.1. Heat-Sterling-Storage.jpg",
}

export const MarkersData = {
    "algae-farm-1-simulation": {
        name: "Farma do produkcji Alg 1",
        pos: [-140, 420],
        align: "right-top",
        svgSize: [800, 800],
        circlePos: [800 - 20, 20],
        cloudPos: [150, 400],
        imgSize: [150, 300],
        img: "icon_algae.png"
    },
    "huljanogi_converter": {
        name: "Inverter",
        pos: [350, -130],
        align: "right-center",
        svgSize: [600, 350],
        circlePos: [600 - 20, 350 - 20],
        cloudPos: [0, 0],
        cloudSize: [400, 120],
        imgSize: [250, 300],
        text: [
            "SOFAR 1.1K-3.3KTL-G3",
        ]
    },
    "pv-hulajnogi-simulation": {
        name: "Ładowarka słoneczna",
        pos: [120, 90],
        align: "right-top",
        svgSize: [1000, 800],
        circlePos: [800 - 20, 20],
        cloudPos: [0, 200],
        cloudSize: [800, 300],
        imgSize: [350, 300],
        interactive:true,
        img: "hulajnogi.png"
    },
    "wind-vawt-simulation": {
        name: "Turbina wiatrowa VAWT",
        pos: [-350, 400],
        align: "left-center",
        svgSize: [800, 300],
        circlePos: [20, 150],
        cloudPos: [200, 0],
        imgSize: [122, 280],
        interactive:true,
        img: "wiatrak.png"
    },
    "energy-storage-simulation": {
        name: "Converter & Storage",
        pos: [310, 540],
        align: "left-center",
        svgSize: [950, 170],
        circlePos: [20, 150],
        cloudPos: [100, 0],
        cloudSize: [400, 60],
    },
    "engine-test-bench-simulation": {
        name: "Stanowisko do badań silnika",
        pos: [80, -70],
        align: "right-center",
        svgSize: [1000, 800],
        circlePos: [1000 - 20, 800 - 20],
        cloudPos: [0, 180],
        imgSize: [280, 280],
        img: "icon_engine_bench_white_bg.png",
        text: [
            "Silnik Benzynowy: 4.5 kW przy 3600 obr/min",
            "Silnik Diesla: 3.1 kW przy 3000 obr/min",
        ]
    },
    "biogas-plant-simulation": {
        name: "Biogazownia",
        pos: [450, 470],
        align: "left-center",
        svgSize: [800, 300],
        circlePos: [20, 300 / 2],
        cloudPos: [100, 0],
        imgSize: [280, 280],
        img: "icon-biogaz.png"
    },
    "wind-hawt-hybrid-simulation": {
        name: "Turbina wiatrowa HAWT",
        pos: [1130, 1080],
        align: "left-center",
        svgSize: [750, 300],
        circlePos: [20, 280],
        cloudPos: [150, 0],
        imgSize: [164, 280],
        img: "icon-wind-hawt-hybride.jpg"
    },
    "pv-hybrid-simulation": {
        name: "Panele fotowoltaiczne",
        pos: [800, 1120],
        align: "left-center",
        svgSize: [750, 300],
        circlePos: [20, 300 / 2 - 10],
        cloudPos: [150, 0],
        imgSize: [181, 280],
        img: "icon-pv-hybride.jpg"
    },
    "algae-farm-2-simulation": {
        name: "Farma do produkcji Alg 2",
        pos: [0, 600],
        align: "left-center",
        svgSize: [900, 300],
        circlePos: [20, 250],
        cloudPos: [300, 0],
        imgSize: [150, 300],
        img: "icon_algae.png"
    },
    "hybride_is": {
        name: "Wind/Solar Controler",
        pos: [900, 1000],
        align: "center-top",
        svgSize: [400, 270],
        circlePos: [400 / 2 + 20, 20],
        cloudPos: [0, 170],
        cloudSize: [600, 70],
        text: [
            "Wind/Solar Hybrid Controler & Storage",
        ]
    },
    "heat-boiler-simulation": {
        name: "Stirling-Ogniwo-Magazyn",
        pos: [900, 750],
        align: "center-bottom",
        svgSize: [400, 200],
        circlePos: [400 / 2 - 10, 200 - 20],
        cloudPos: [0, 0],
        cloudSize: [550, 90],
        text: [
            "Silnik Stirlinga, Ogniwo paliwowe",
            "Magazyn ciepła"
        ]
    },
}

export function GetPosOfMarker(key) {
    switch (MarkersData[key].align) {
        case "left-top":
            return MarkersData[key].pos;
        case "left-bottom":
            return [MarkersData[key].pos[0] + MarkersData[key].svgSize[1], MarkersData[key].pos[1]]
        case "left-center":
            return [MarkersData[key].pos[0] + MarkersData[key].svgSize[1] / 2, MarkersData[key].pos[1]]

        case "center-bottom":
            return [MarkersData[key].pos[0] + MarkersData[key].svgSize[1], MarkersData[key].pos[1] - MarkersData[key].svgSize[0] / 2]
        case "center-top":
            return [MarkersData[key].pos[0], MarkersData[key].pos[1] - MarkersData[key].svgSize[0] / 2]

        case "right-top":
            return [MarkersData[key].pos[0], MarkersData[key].pos[1] - MarkersData[key].svgSize[0]]
        case "right-bottom":
            return [MarkersData[key].pos[0] + MarkersData[key].svgSize[1], MarkersData[key].pos[1] - MarkersData[key].svgSize[0]]
        case "right-center":
            return [MarkersData[key].pos[0] + MarkersData[key].svgSize[1], MarkersData[key].pos[1] - MarkersData[key].svgSize[0] / 2]
    }
}

export function GetPosOfLines(key, cloudSize = null) {
    const data = MarkersData[key];
    const _cloudSize = cloudSize || GetCloudSize(key);
    switch (MarkersData[key].align) {
        case "left-top":
        case "right-top":
        case "center-top":
            return [[data.cloudPos[0], data.cloudPos[1]], [data.cloudPos[0] + _cloudSize[0], data.cloudPos[1]]]

        case "left-bottom":
        case "right-bottom":
        case "center-bottom":
            return [[data.cloudPos[0], data.cloudPos[1] + _cloudSize[1]], [data.cloudPos[0] + _cloudSize[0], data.cloudPos[1] + _cloudSize[1]]]

        case "left-center":
            return [[data.cloudPos[0], data.cloudPos[1]], [data.cloudPos[0], data.cloudPos[1] + _cloudSize[1]]]

        case "right-center":
            return [[data.cloudPos[0] + _cloudSize[0], data.cloudPos[1]], [data.cloudPos[0] + _cloudSize[0], data.cloudPos[1] + _cloudSize[1]]]
    }
}

export function GetCloudSize(key) {
    return MarkersData[key].cloudSize != null ? MarkersData[key].cloudSize : CloudSize
}

const markerDescFontSize = 25;
const lineHeight = 30;
const markerDescMargin = 10;

const valueBoxWidth = 130;
const textCharWidth = 8; // Approximate width per character for fontSize 25
const imageDataMargin = 10; // Margin between image and data section
const nameTopMargin = 30; // Top margin for name text
const dataTopMargin = 40; // Top margin for data section

// Helper function to estimate text width
function estimateTextWidth(text, fontSize = markerDescFontSize) {
    if (!text) return 0;
    // Rough estimate: ~0.6 * fontSize per character for most fonts
    return text.length * (fontSize * 0.6);
}

// Calculate required cloud width based on content
function calculateRequiredWidth(data, markersInfo, key, imgSize) {
    const hasImage = data.img != null;
    const imageWidth = hasImage ? imgSize[0] : 0;
    
    // Calculate width needed for name text
    const nameWidth = estimateTextWidth(data.name, 30);
    
    // Calculate width needed for data section
    let maxDataWidth = 0;
    
    if (markersInfo[key] != null && markersInfo[key].length > 0) {
        markersInfo[key].forEach((mensurent_data) => {
            const labelWidth = estimateTextWidth(mensurent_data[0], markerDescFontSize);
            const dataRowWidth = valueBoxWidth + imageDataMargin + labelWidth;
            maxDataWidth = Math.max(maxDataWidth, dataRowWidth);
        });
    }
    
    if (data.text != null && data.text.length > 0) {
        data.text.forEach((text) => {
            const textWidth = estimateTextWidth(text, markerDescFontSize);
            maxDataWidth = Math.max(maxDataWidth, textWidth + imageDataMargin);
        });
    }
    
    // Total width needed: image + margin + data section, or name width (whichever is larger)
    const dataSectionWidth = imageWidth + imageDataMargin + maxDataWidth;
    const minWidth = Math.max(nameWidth, dataSectionWidth);
    
    // Add padding on both sides
    return Math.max(minWidth + 20, data.cloudSize?.[0] || CloudSize[0]);
}

export function GetMarkersOverlay({markersInfo}) {
    const navigate = useNavigate();

    return Object.entries(MarkersData).map(info => {
        const key = info[0]
        const data = info[1]
        const _pos = GetPosOfMarker(key);
        const baseCloudSize = GetCloudSize(key)
        
        // Calculate image size - ensure it doesn't exceed 80% of the green area height
        const maxImageHeight = baseCloudSize[1] * 0.8;
        let _imgSize;
        if (data.imgSize != null) {
            _imgSize = data.imgSize;
        } else {
            // Default: make image fit nicely in the green area
            const defaultHeight = Math.min(baseCloudSize[1], maxImageHeight);
            const defaultWidth = defaultHeight / 1.2; // Aspect ratio
            _imgSize = [defaultWidth, defaultHeight];
        }
        
        // Calculate dynamic cloud width
        const calculatedWidth = calculateRequiredWidth(data, markersInfo, key, _imgSize);
        const _cloudSize = [calculatedWidth, baseCloudSize[1]];
        
        // Calculate line positions using dynamic cloud size
        const _posOfLine = GetPosOfLines(key, _cloudSize);
        
        // Calculate image Y position to center it vertically in the green area
        const imageY = data.cloudPos[1] + (_cloudSize[1] - _imgSize[1]) / 2;
        
        return (
            <SVGOverlay
                attributes={{
                    viewBox: `0 0 ${data.svgSize[0]} ${data.svgSize[1]}`,
                    pointerEvents: "auto"
                }}
                bounds={[
                    [_pos[0], _pos[1]],
                    [_pos[0] + data.svgSize[1], _pos[1] + data.svgSize[0]],
                ]}
                key={key}
                interactive={true}
                eventHandlers={{
                    click: (e) => {
                        // Navigate to device page when clicking anywhere on the marker
                        navigate(url + key)
                    }
                }}
                className="marker">
                <path d={"M " + data.cloudPos[0] + " " + data.cloudPos[1] + " H " + (data.cloudPos[0] + _cloudSize[0]) + " V " + (data.cloudPos[1] + _cloudSize[1]) + " H " + data.cloudPos[0] + " Z"} className="bg" />
                {
                    data.img != null ?
                        <image href={data.img} width={_imgSize[0]} height={_imgSize[1]} x={data.cloudPos[0]} y={imageY} />
                        : null
                }
                <text x={((_cloudSize[0] + (data.img != null ? _imgSize[0] : 0)) / 2) + data.cloudPos[0]} y={data.cloudPos[1] + nameTopMargin} className="name" color="white" textAnchor="middle">{data.name}</text>
                <g transform={"translate(" + (data.cloudPos[0] + (data.img != null ? _imgSize[0] : 0) + imageDataMargin) + " " + (data.cloudPos[1] + dataTopMargin) + ")"}>
                    {markersInfo[key] != null ? markersInfo[key].map((mensurent_data, index) => {
                        // Safely format the value - handle both numbers and strings
                        const value = mensurent_data[1];
                        const formattedValue = typeof value === 'number' && !isNaN(value) 
                            ? value.toFixed(2) 
                            : String(value || 'N/A');
                        const unit = mensurent_data[2] || '';
                        
                        return (
                            <g key={index} transform={"translate(0 " + ((lineHeight + markerDescMargin) * (index)) + ")"}>
                                <rect width={valueBoxWidth} height={lineHeight} x="0" y="0" rx="10" ry="10" fill="white" stroke="black" strokeWidth={2} />
                                <AutoFitText x={valueBoxWidth / 2} y={24} className="desc" maxWidth={valueBoxWidth - 4} maxFontSize={markerDescFontSize} anchor="middle" text={formattedValue + unit} />
                                <text x={valueBoxWidth + 1} y={24} className="desc" color="white" fontSize={markerDescFontSize}>{mensurent_data[0]}</text>
                            </g>
                        );
                    }) : null}
                    {
                        data.text != null ? data.text.map((text, textIndex) =>
                            <g key={textIndex} transform={"translate(0 " + ((lineHeight + markerDescMargin) * (textIndex + (markersInfo[key] != null ? markersInfo[key].length : 0))) + ")"}>
                                <text x={1} y={24} className="desc" color="white" fontSize={markerDescFontSize}>{text}</text>
                            </g>
                        ) : null}

                </g>

                <path d={"M " + data.circlePos[0] + " " + data.circlePos[1] + " L" + _posOfLine[0][0] + " " + _posOfLine[0][1]} strokeWidth="5" className="line" />
                <path d={"M " + data.circlePos[0] + " " + data.circlePos[1] + " L" + _posOfLine[1][0] + " " + _posOfLine[1][1]} strokeWidth="5" className="line" />
                <path d={"M " + data.cloudPos[0] + " " + data.cloudPos[1] + " H " + (data.cloudPos[0] + _cloudSize[0]) + " V " + (data.cloudPos[1] + _cloudSize[1]) + " H " + data.cloudPos[0] + " Z"} fill="transparent" className="clickable" style={{ cursor: 'pointer' }} />
                {/* <image href={data.img} width={markerMiniImageSize[0]} height={markerMiniImageSize[1]} x={data.circlePos[0]-markerMiniImageSize[0]/2} y={data.circlePos[1]-markerMiniImageSize[1]/2} /> */}
                <circle cx={data.circlePos[0]} cy={data.circlePos[1]} r={20} className="bg2" />
            </SVGOverlay>)
    })
}