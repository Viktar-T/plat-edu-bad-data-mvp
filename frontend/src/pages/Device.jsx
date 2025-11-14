import { useParams } from "react-router-dom";
import "../styles/Device.scss"
import { MarkersData } from "../api/MarkersData";

function Device() {
    const { deviceID } = useParams();
    if (!deviceID) return (<>NO GIVEN DEVICE</>)
    let devices = {}
    for (const key in MarkersData) {
        if (Object.prototype.hasOwnProperty.call(MarkersData, key)) {
            const value = MarkersData[key].name;
            const path = "/"+key+".png";
            
            devices[key] = [value, path];
        }
    }
    
    console.log(devices);
    if (!devices[deviceID]) return (<>DEVICE NOT FOUND</>)
    return (
            <div className="device">
                <picture>
                    <img src={devices[deviceID][1]} alt={"Picture of " + devices[deviceID][0]}></img>
                </picture>
                <div className="scada"></div>
            </div>
    )
}

export default Device;