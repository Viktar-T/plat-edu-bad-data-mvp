import { FontAwesomeIcon } from "@fortawesome/react-fontawesome";
import "../styles/Footer.scss"
import { faArrowUpRightFromSquare } from "@fortawesome/free-solid-svg-icons";

function Footer(){
    return (
        <div className="footer">
            <div className="container institutions">
                <div className="name">Instytucje</div>
                <ul className="list">
                    <li>
                        Katedra Inżynierii Odnawialnych Źródeł Energii: 
                        <a href="https://wksir.zut.edu.pl/struktura-wydzialu/katedra-inzynierii-odnawialnych-zrodel-energii.html" target="_blank" rel="noopener noreferrer"> ZUT <FontAwesomeIcon icon={faArrowUpRightFromSquare} /></a>
                        {" | "}
                        <a href="https://oze.zut.edu.pl/" target="_blank" rel="noopener noreferrer"> OZE <FontAwesomeIcon icon={faArrowUpRightFromSquare} /></a>
                    </li>
                    <li><a href="https://tlimc.szczecin.pl" target="_blank">Technikum Łączności i Multimediów Cyfrowych w Szczecinie <FontAwesomeIcon icon={faArrowUpRightFromSquare} /></a></li>
                    <li><a href="https://fundacjapge.pl/" target="_blank">PGE Fundacja <FontAwesomeIcon icon={faArrowUpRightFromSquare} /></a></li>
                </ul>
            </div>

            <div className="container logo">
                <div className="name sponsor-label">Sponsorze:</div>
                <div className="logo-and-contact">
                    <a href="https://fundacjapge.pl/" target="_blank" className="logo-link">
                        <img src={`${import.meta.env.BASE_URL}pge-fundacja.png`} alt="PGE Fundacja" className="pge-logo" />
                    </a>
                    <div className="contact-info">
                        <div><a href="mailto:Fundacja.PGE@gkpge.pl">Fundacja.PGE@gkpge.pl</a></div>
                        <div><a href="tel:+48223401795">+48 (22) 340 17 95</a></div>
                    </div>
                </div>
            </div>

            <div className="container location">
                <div className="name">Lokalizacja projektu</div>
                <a href="https://www.google.com/maps/dir/?api=1&destination=53.44842,14.52913&fbclid=IwY2xjawNXK4pleHRuA2FlbQIxMABicmlkETE2Z2NtbEZmVnRGaVVwSXo0AR4OUa8S6qlpSPfNRyFudl5gyz4QGdWaSGIv1LlO_34WlIbKEID9cs8HAkxIXA_aem_95pXxw2HEgaivltooYN3Zg" target="_blank">Ul. Pawła VI 1, 71-459 Szczecin <FontAwesomeIcon icon={faArrowUpRightFromSquare} /></a>
            </div>
        </div>
    )
}

export default Footer;