import { SVGOverlay } from "react-leaflet";
import { useNavigate } from "react-router-dom";

const RoomsData = [
    {
        pos:[325, 931],
        size:[193.5, 318.31096375432344],
        room:"112",

    }
]

const url = "/room/"

export function GetRoomsOverlay() {
    const navigate = useNavigate();

    return Object.entries(RoomsData).map(info => {
        const key = info[0]
        const data = info[1]
        return (
            <SVGOverlay
                attributes={{
                    viewBox: `0 0 ${data.size[0]} ${data.size[1]}`,
                    pointerEvents: "all"
                }}
                bounds={[
                    [data.pos[1], data.pos[0]],
                    [data.pos[1] - data.size[1], data.pos[0] + data.size[0]],
                ]}
                key={key}
                interactive={true}
                eventHandlers={{
                    click: ()=>{
                        navigate(url + data.room);
                    }
                }}
                className="roomMarker">
                    <rect width={data.size[0]} height={data.size[1]} x={0} y={0} className="bg" />
                    <text x={(data.size[0] / 2)} y={(data.size[1] / 2)} className="name" textAnchor="middle" alignment-baseline="central">{data.room}</text>
            </SVGOverlay>)
    })
}