import { LayerGroup, LayersControl, MapContainer, Rectangle, SVGOverlay } from "react-leaflet";
import AutoFitText from "../components/AutoFitText";
import { useNavigate } from "react-router-dom";

export const CloudSize = [600, 300]
const url = "/device/"
export const MarkersData = {
    "algy": {
        name: "Algy",
        pos: [-140, 420],
        align: "right-top",
        svgSize: [800, 800],
        circlePos: [800 - 20, 20],
        cloudPos: [150, 400],
        imgSize: [175, 300],
        img: "wiatrakStorage.png"
    },
    "huljanogi_converter": {
        name: "PV Hulajnogi Converter",
        pos: [350, -130],
        align: "right-center",
        svgSize: [600, 350],
        circlePos: [600 - 20, 350 - 20],
        cloudPos: [0, 0],
        cloudSize: [400, 120],
        imgSize: [250, 300],
        text: [
            "Ale fajny tekst",
            "AAAAAAA",
        ]
    },
    "ladowarka_sloneczna": {
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
    "turbine_vertical": {
        name: "Wind Big Vertical Turbine",
        pos: [-350, 400],
        align: "left-center",
        svgSize: [800, 300],
        circlePos: [20, 150],
        cloudPos: [200, 0],
        imgSize: [130, 300],
        interactive:true,
        img: "wiatrak.png"
    },
    "turbine_is": {
        name: "Inverter & Storage",
        pos: [310, 540],
        align: "left-center",
        svgSize: [950, 170],
        circlePos: [20, 150],
        cloudPos: [100, 0],
        cloudSize: [400, 60],
    },
    "engine_bench": {
        name: "Engine test bench",
        pos: [80, -70],
        align: "right-center",
        svgSize: [1000, 800],
        circlePos: [1000 - 20, 800 - 20],
        cloudPos: [0, 180],
        imgSize: [175, 300],
        img: "wiatrakStorage.png"
    },
    "biogas": {
        name: "Small Biogas station",
        pos: [450, 470],
        align: "left-center",
        svgSize: [800, 300],
        circlePos: [20, 300 / 2],
        cloudPos: [100, 0],
        imgSize: [175, 300],
        img: "wiatrakStorage.png"
    },
    "wind_turbine": {
        name: "Small wind turbine",
        pos: [1130, 1080],
        align: "left-center",
        svgSize: [750, 300],
        circlePos: [20, 280],
        cloudPos: [150, 0],
        imgSize: [175, 300],
        img: "wiatrakStorage.png"
    },
    "pv_panels": {
        name: "PV panels",
        pos: [800, 1120],
        align: "left-center",
        svgSize: [750, 300],
        circlePos: [20, 300 / 2 - 10],
        cloudPos: [150, 0],
        imgSize: [175, 300],
        img: "wiatrakStorage.png"
    },
    "big_algy": {
        name: "Big algy",
        pos: [0, 600],
        align: "left-center",
        svgSize: [900, 300],
        circlePos: [20, 250],
        cloudPos: [300, 0],
        imgSize: [130, 300],
        img: "wiatrak.png"
    },
    "hybride_is": {
        name: "Inverter & Storage",
        pos: [900, 1000],
        align: "center-top",
        svgSize: [400, 270],
        circlePos: [400 / 2 + 20, 20],
        cloudPos: [0, 170],
        cloudSize: [400, 70],
        text: [
            "for hybride Wind/PV",
        ]
    },
    "heat_system": {
        name: "Heat system",
        pos: [900, 750],
        align: "center-bottom",
        svgSize: [400, 200],
        circlePos: [400 / 2 - 10, 200 - 20],
        cloudPos: [0, 0],
        cloudSize: [400, 70],
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

export function GetPosOfLines(key) {
    const data = MarkersData[key];
    const _cloudSize = GetCloudSize(key);
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

export function GetMarkersOverlay({markersInfo}) {
    const navigate = useNavigate();

    return Object.entries(MarkersData).map(info => {
        const key = info[0]
        const data = info[1]
        const _pos = GetPosOfMarker(key);
        const _posOfLine = GetPosOfLines(key)
        const _cloudSize = GetCloudSize(key)
        const _imgSize = data.imgSize != null ? data.imgSize : [_cloudSize[1] / 1.3, _cloudSize[1]]
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
                interactive={data.interactive || false}
                eventHandlers={{
                    click: (e) => {
                        /**
                         * @type {HTMLDivElement}
                         */
                        const target = e.originalEvent.target
                        const device_id = target.getAttribute("data-device")
                        if (device_id != null) {
                            navigate(url + device_id)
                        }
                    }
                }}
                className="marker">
                <path d={"M " + data.cloudPos[0] + " " + data.cloudPos[1] + " H " + (data.cloudPos[0] + _cloudSize[0]) + " V " + (data.cloudPos[1] + _cloudSize[1]) + " H " + data.cloudPos[0] + " Z"} className="bg" />
                {
                    data.img != null ?
                        <image href={data.img} width={_imgSize[0]} height={_imgSize[1]} x={data.cloudPos[0]} y={data.cloudPos[1]} />
                        : null
                }
                <text x={((_cloudSize[0] + (data.img != null ? _imgSize[0] : 0)) / 2) + data.cloudPos[0]} y={data.cloudPos[1] + 30} className="name" color="white" textAnchor="middle">{data.name}</text>
                <g transform={"translate(" + (data.cloudPos[0] + (data.img != null ? _imgSize[0] : 0) + 10) + " " + (data.cloudPos[1] + 40) + ")"}>
                    {markersInfo[key] != null ? markersInfo[key].map((mensurent_data, key) =>
                        <g key={key} transform={"translate(0 " + ((lineHeight + markerDescMargin) * (key)) + ")"}>
                            <rect width={valueBoxWidth} height={lineHeight} x="0" y="0" rx="10" ry="10" fill="white" stroke="black" strokeWidth={2} />
                            <AutoFitText x={valueBoxWidth / 2} y={24} className="desc" maxWidth={valueBoxWidth - 4} maxFontSize={markerDescFontSize} anchor="middle" text={mensurent_data[1].toFixed(2) + mensurent_data[2]} />
                            <text x={valueBoxWidth + 1} y={24} className="desc" color="white" fontSize={markerDescFontSize}>{mensurent_data[0]}</text>
                        </g>
                    ) : null}
                    {
                        data.text != null ? data.text.map((text, key) =>
                            <g key={key} transform={"translate(0 " + ((lineHeight + markerDescMargin) * (key + (markersInfo[key] != null ? markersInfo[key].length : 0))) + ")"}>
                                <text x={1} y={24} className="desc" color="white" fontSize={markerDescFontSize}>{text}</text>
                            </g>
                        ) : null}

                </g>

                <path d={"M " + data.circlePos[0] + " " + data.circlePos[1] + " L" + _posOfLine[0][0] + " " + _posOfLine[0][1]} strokeWidth="5" className="line" />
                <path d={"M " + data.circlePos[0] + " " + data.circlePos[1] + " L" + _posOfLine[1][0] + " " + _posOfLine[1][1]} strokeWidth="5" className="line" />
                <path d={"M " + data.cloudPos[0] + " " + data.cloudPos[1] + " H " + (data.cloudPos[0] + _cloudSize[0]) + " V " + (data.cloudPos[1] + _cloudSize[1]) + " H " + data.cloudPos[0] + " Z"} fill="transparent" data-device={key} className="clickable" />
                {/* <image href={data.img} width={markerMiniImageSize[0]} height={markerMiniImageSize[1]} x={data.circlePos[0]-markerMiniImageSize[0]/2} y={data.circlePos[1]-markerMiniImageSize[1]/2} /> */}
                <circle cx={data.circlePos[0]} cy={data.circlePos[1]} r={20} className="bg2" />
            </SVGOverlay>)
    })
}