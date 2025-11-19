import "../styles/About.scss"

function About() {
    return (
        <div className="about-page">
            <h1>O projekcie</h1>
            
            <section className="project-description">
                <h2>Opis projektu</h2>
                <p>
                    Celem projektu jest opracowanie zaawansowanej, zintegrowanej platformy edukacyjno-badawczej funkcjonującej w Katedrze Inżynierii Odnawialnych Źródeł Energii. Adres katedry: <strong>ul. Papieża Pawła VI 1, 71-459 Szczecin</strong>. Platforma zostanie udostępniona w formie strony internetowej z otwartym dostępem dla wszystkich zainteresowanych.
                </p>
                <p>
                    Na terenie katedry zostanie zbudowana lokalna sieć przepływu danych, łącząca istniejące już różnorodne źródła energii odnawialnej, takie jak panele fotowoltaiczne, turbiny wiatrowe, biogazownia, kocioł grzewczy oraz magazyny energii elektrycznej, cieplnej i zbiornik biogazu. Dane z tych źródeł i magazynów energii będą przesyłane w czasie rzeczywistym do serwisów chmurowych.
                </p>
                <p>
                    Głównym celem projektu jest umożliwienie monitorowania, zarządzania oraz analizy danych w czasie rzeczywistym, co pozwoli na lepsze zrozumienie i optymalizację procesów związanych z produkcją energii odnawialnej.
                </p>
            </section>

            <section className="project-benefits">
                <h2>Korzyści z platformy</h2>
                <p>
                    Dzięki platformie studenci zdobędą praktyczne doświadczenie w analizie parametrów działania i optymalizacji systemów OZE. Pracownicy naukowi uzyskają dostęp do zaawansowanych narzędzi analitycznych oraz możliwość prowadzenia badań na rzeczywistych instalacjach OZE. Dane zebrane za pomocą platformy mogą posłużyć do tworzenia publikacji naukowych, optymalizacji procesów technologicznych oraz opracowywania nowych rozwiązań w dziedzinie energii odnawialnej.
                </p>
                <p>
                    Projekt ma na celu promowanie świadomości ekologicznej oraz zrównoważonego rozwoju wśród studentów, społeczności akademickiej i lokalnej. Realizacja projektu przyczyni się do podniesienia jakości kształcenia, innowacyjności oraz konkurencyjności katedry i uczelni na rynku edukacyjnym i badawczym.
                </p>
            </section>

            <section className="target-audience">
                <h2>Grupy odbiorców</h2>
                <p>Trzy główne grupy odbiorców, do których adresowany jest projekt:</p>
                <ol>
                    <li>
                        <strong>Studenci Wydziału Kształtowania Środowiska i Rolnictwa</strong>, kierunek Odnawialne Źródła Energii, 156 studentów.
                    </li>
                    <li>
                        <strong>Uczniowie szkół średnich</strong> o profilu kształcenia związanym z OZE i ochroną środowiska.
                    </li>
                    <li>
                        <strong>Naukowcy</strong> realizujący prace badawcze związane z tematyką OZE i ochroną środowiska.
                    </li>
                </ol>
            </section>
        </div>
    )
}

export default About
