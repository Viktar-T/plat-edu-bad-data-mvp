import { SVGOverlay } from "react-leaflet";

const lines2 = [
    {pos:[[-129.5, 900.1421788338348], [162.5, 720.2490125048607]], reverse:true},
    {pos:[[1103, 1310.092026360492], [1021.5, 1147.6884734246128]], reverse:false, rotate:true},
    {pos:[[1125.2659937972535, 1113.7820653680074], [1021.5, 1147.6884734246128]], reverse:false, rotate:false},
    {pos:[[420, -51.271167188555296], [559.5, 429.58193651378406]], reverse:true, rotate:true},
]

export function GetEletricLinesOverlay() {
    return Object.entries(lines2).map(info => {
        const key = info[0]
        const data = info[1]

        const left_bottom = [Math.min(data.pos[0][0], data.pos[1][0]), Math.min(data.pos[0][1], data.pos[1][1])]
        const top_right = [Math.max(data.pos[0][0], data.pos[1][0]), Math.max(data.pos[0][1], data.pos[1][1])]

        const size = [(top_right[0] - left_bottom[0]), (top_right[1] - left_bottom[1])]

        let linepos = [] 

        if (data.rotate){
            linepos = data.reverse ? [[size[0], 0], [0,size[1]]] : [[0,size[1]], [size[0], 0]]
        } else {
            linepos = data.reverse ? [[size[0], size[1]], [0,0]] : [[0,0], [size[0], size[1]]]
        }

        return (
            <SVGOverlay
                attributes={{
                    viewBox: `0 0 ${size[0]} ${size[1]}`,
                    pointerEvents: "all"
                }}
                bounds={[
                    [left_bottom[1], left_bottom[0]],
                    [top_right[1], top_right[0]],
                ]}
                key={key}
                className="eletricLineMarker">
                <line className="eletricLineBg" x1={linepos[0][0]} y1={linepos[0][1]} x2={linepos[1][0]} y2={linepos[1][1]} />
                <line className="eletricLineCurrent" x1={linepos[0][0]} y1={linepos[0][1]} x2={linepos[1][0]} y2={linepos[1][1]} />
            </SVGOverlay>)
    })
}
