influxdb works. I can manualy create bucket and send data Fields(power, voltage, current, temperature, efficiency). for example I can send it via restful API.  But node-red does not send Fields(power, voltage, current, temperature, efficiency). 

I have restarted the container.

[+] Running 2/2ustyka\ProjectsGitHub\plat-edu-bad-data-mvp> docker-compose down node-red

✔ Container iot-node-red                     Removed                                                                                                                                             1.2s

! Network plat-edu-bad-data-mvp_iot-network  Resource is still in use                                                                                                                            0.0s

PS C:\Users\vtaustyka\ProjectsGitHub\plat-edu-bad-data-mvp> Remove-Item -Path "node-red\data" -Recurse -Force -ErrorAction SilentlyContinue

PS C:\Users\vtaustyka\ProjectsGitHub\plat-edu-bad-data-mvp> docker-compose up -d node-red

[+] Running 3/3

✔ Container iot-influxdb2  Healthy                                                                                                                                                               0.7s

✔ Container iot-mosquitto  Healthy                                                                                                                                                               0.7s

✔ Container iot-node-red   Started                                                                                                                                                               1.2s

PS C:\Users\vtaustyka\ProjectsGitHub\plat-edu-bad-data-mvp>

==================

iot-node-red LOGS:

🚀 Starting Node-RED for IoT Monitoring...

🔧 Setting up Node-RED configuration files...

📦 node_modules missing, will install dependencies

🔧 Cleaning and installing Node-RED dependencies...

🧹 Cleaning npm environment...

npm warn using --force Recommended protections disabled.

📦 Installing Node-RED dependencies...

npm warn config production Use `--omit=dev` instead.

npm warn deprecated are-we-there-yet@2.0.0: This package is no longer supported.

npm warn deprecated inflight@1.0.6: This module is not supported, and leaks memory. Do not use it. Check out lru-cache if you want a good and tested way to coalesce async requests by a key value, which is much more comprehensive and powerful.

npm warn deprecated glob@7.2.3: Glob versions prior to v9 are no longer supported

npm warn deprecated npmlog@5.0.1: This package is no longer supported.

npm warn deprecated rimraf@3.0.2: Rimraf versions prior to v4 are no longer supported

npm warn deprecated multer@1.4.5-lts.1: Multer 1.x is impacted by a number of vulnerabilities, which have been patched in 2.x. You should upgrade to the latest 2.x version.

npm warn deprecated gauge@3.0.2: This package is no longer supported.

added 343 packages, and audited 344 packages in 4m

50 packages are looking for funding

run `npm fund` for details

6 vulnerabilities (3 low, 3 critical)

To address all issues (including breaking changes), run:

npm audit fix --force

Run `npm audit` for details.

✅ Dependencies installed successfully

🔧 Setting up Node-RED configuration...

✅ Settings file configured

🚀 Starting Node-RED...

> iot-renewable-energy-monitoring@1.0.0 start
> 

> node-red
> 

5 Aug 12:15:43 - [info]

Welcome to Node-RED

===================

from Node-red GUT.

8/5/2025, 2:19:29 PM[node: Success Log](http://localhost:1880/#)devices/photovoltaic/pv_010/telemetry : msg.influxdb_status : undefined

*undefined*

======================

then I imported node-red\flows\v2.0-pv-mqtt-loop-simulation.json and deployed.

================

Lets check whether all files inside node-red folder are correct.
Check whether all dependents were installed correctly 

Check whether deployed flow.

Analyse build folder structure node-red\data. Is it correct that node-red\data\flows is empty.