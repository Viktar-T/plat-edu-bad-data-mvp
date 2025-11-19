import { useState } from 'react'
import Footer from './components/Footer.jsx'
import './styles/App.css'
import Header from './components/Header.jsx'
import { Route, Routes } from 'react-router-dom'
import Home from './pages/Home.jsx'
import About from './pages/About.jsx'
import Device from './pages/Device.jsx'
import FundacjaPGE from './pages/FundacjaPGE.jsx'

function App() {
  // Aby pokazała się zakładka w headerze, route musi zawierac label
  const routes = [
    {path:"/", element: <Home />, label: "Home"},
    {path:"/about", element: <About />, label: "O projekcie"},
    {path:"/fundacja-pge", element: <FundacjaPGE />, label: "Fundacja PGE"},
    {path:"/device/:deviceID", element: <Device />},
    {path:"/device", element: <Device />}
  ];
  return (
    <>
      <Header tabs={routes.filter(e => e.label)} />
      <main>
        <Routes>
          {routes.map(o => (
            <Route path={o.path} element={o.element}/>
          ))}
        </Routes>
      </main>
      <Footer />
    </>
  )
}

export default App
