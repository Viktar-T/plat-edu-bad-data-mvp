import { NavLink } from "react-router-dom"
import "../styles/Header.scss"
import { DarkModeToggle } from "./DarkModeToggle"

function Header({tabs}) {
    return (
        <div className="header">
            <div className="header-left">
                <div className="logos">
                    <a href="https://oze.zut.edu.pl/" target="_blank" className="logo-link" rel="noopener noreferrer">
                        <img src={`${import.meta.env.BASE_URL}kioze-logo.png`} alt="Katedra Inżynierii Odnawialnych Źródeł Energii" className="header-logo" />
                    </a>
                </div>
                <div className="name">
                    <div className="siteName">IoT Platforma Edu-Badawcza</div>
                    <div className="school">Katedra Inżynierii Odnawialnych Źródeł Energii</div>
                    <div className="school">Technikum Łączności i Multimediów Cyfrowych w Szczecinie</div>
                </div>
            </div>
            <nav>
                {tabs.map((tab, key) => (<NavLink key={key} className={({ isActive }) => (isActive ? "active-link" : "")} to={tab.path}>{tab.label}</NavLink>))}
            </nav>
            <div className="header-right">
                <div className="pge-funding">
                    <h2 className="funding-text">Projekt dofinansowany przez Fundację PGE</h2>
                    <a href="https://fundacjapge.pl/" target="_blank" className="logo-link" rel="noopener noreferrer">
                        <img src={`${import.meta.env.BASE_URL}pge-fundacja.png`} alt="PGE Fundacja" className="header-logo" />
                    </a>
                </div>
                <div className="toggle">
                    <DarkModeToggle />
                </div>
            </div>
        </div>
    )
}

export default Header