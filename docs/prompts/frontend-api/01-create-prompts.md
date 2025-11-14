You are a senior full-stack engineer helping me in a Docker-based monorepo in Cursor.
I have an existing project with folders: docs, grafana, influxdb, mosquitto, nginx, node-red, scripts, tests, web-app-for-testing, docker-compose.yml, etc.
I have just added two new apps into this repo:

frontend/ – a Vite React app (previously called platformaEdu), running on http://localhost:5173

api/ – an Express.js API (previously deployed on Vercel), running on http://localhost:3001
 and connecting to InfluxDB
My goal is to work in ONE repo where each app runs in its own Docker container and all containers will later be deployed on one VPS.
Please help me integrate frontend and api step by step into this monorepo. for each step write prompt in separate md file into docs\prompts\frontend-api. Prompts should be adapted to LLM use one by one.

