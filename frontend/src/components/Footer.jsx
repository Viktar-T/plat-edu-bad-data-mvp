import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import "../styles/Footer.scss"
import { faArrowUpRightFromSquare } from "@fortawesome/free-solid-svg-icons";

function Footer(){
    return (
        <div className="footer">
            <div className="container institutions">
                <div className="name">Instytucje</div>
                <ul className="list">
                    <li><a href="https://wksir.zut.edu.pl/struktura-wydzialu/katedra-inzynierii-odnawialnych-zrodel-energii.html" target="_blank">Katedra Inżynierii Odnawialnych Źródeł Energii <FontAwesomeIcon icon={faArrowUpRightFromSquare} /></a></li>
                    <li><a href="https://tlimc.szczecin.pl" target="_blank">Technikum Łączności i Multimediów Cyfrowych w Szczecinie <FontAwesomeIcon icon={faArrowUpRightFromSquare} /></a></li>
                </ul>
            </div>

            <div className="container location">
                <div className="name">Lokalizacja</div>
                <a href="https://www.google.com/maps/dir/?api=1&destination=53.44842,14.52913&fbclid=IwY2xjawNXK4pleHRuA2FlbQIxMABicmlkETE2Z2NtbEZmVnRGaVVwSXo0AR4OUa8S6qlpSPfNRyFudl5gyz4QGdWaSGIv1LlO_34WlIbKEID9cs8HAkxIXA_aem_95pXxw2HEgaivltooYN3Zg" target="_blank">Ul. Pawła VI 1, 71-459 Szczecin <FontAwesomeIcon icon={faArrowUpRightFromSquare} /></a>
            </div>
        </div>
    )
}

export default Footer;