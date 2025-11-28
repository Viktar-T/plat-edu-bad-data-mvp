import { useParams } from "react-router-dom";
import "../styles/Device.scss"
import { MarkersData, MarkerImageMap } from "../api/MarkersData";

function Device() {
    const { deviceID } = useParams();
    if (!deviceID) return (<>NO GIVEN DEVICE</>)
    
    const device = MarkersData[deviceID];
    if (!device) return (<>DEVICE NOT FOUND</>)
    
    const BASE_URL = import.meta.env.BASE_URL || '/';
    const imagePath = MarkerImageMap[deviceID] || `${BASE_URL}labs/5.1. Algae-inside-farm-R121/5.1. Algae-inside.jpg`;
    
    return (
            <div className="device">
                <h1>{device.name}</h1>
                <picture>
                    <img src={imagePath} alt={"Picture of " + device.name}></img>
                </picture>
                <div className="scada"></div>
            </div>
    )
}

export default Device;