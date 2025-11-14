import { NavLink } from "react-router-dom"
import "../styles/Header.scss"
import { DarkModeToggle } from "./DarkModeToggle"

function Header({tabs}) {
    return (
        <div className="header">
            <div className="name">
                <div className="siteName">IoT Platforma Edu-Badawcza</div>
                <div className="school">Katedra Inżynierii Odnawialnych Źródeł Energii</div>
                <div className="school">Technikum Łączności i Multimediów Cyfrowych w Szczecinie</div>
            </div>
            <nav>
                {tabs.map((tab, key) => (<NavLink key={key} className={({ isActive }) => (isActive ? "active-link" : "")} to={tab.path}>{tab.label}</NavLink>))}
            </nav>
            <div className="toggle">
                <DarkModeToggle />
            </div>
        </div>
    )
}

export default Header