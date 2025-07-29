const axios = require('axios');
const fs = require('fs');
const path = require('path');

// Load configuration
const config = JSON.parse(fs.readFileSync(path.join(__dirname, 'test-config.json'), 'utf8'));

class InfluxDBTester {
    constructor() {
        this.config = config.influxdb;
        this.results = {
            health: false,
            authentication: false,
            dataWriting: false,
            dataQuerying: false,
            performance: false
        };
    }

    async log(message, level = 'INFO') {
        const timestamp = new Date().toISOString();
        const logMessage = `[${timestamp}] [${level}] ${message}`;
        console.log(logMessage);
    }

    async testHealth() {
        try {
            this.log('Testing InfluxDB health...');
            const response = await axios.get(`${this.config.url}/health`, {
                timeout: config.timeouts.request
            });
            
            if (response.status === 200) {
                this.log('✓ InfluxDB health check passed', 'SUCCESS');
                this.results.health = true;
                return true;
            } else {
                this.log(`✗ InfluxDB health check failed: ${response.status}`, 'ERROR');
                return false;
            }
        } catch (error) {
            this.log(`✗ InfluxDB health check failed: ${error.message}`, 'ERROR');
            return false;
        }
    }

    async testAuthentication() {
        try {
            this.log('Testing InfluxDB authentication...');
            const headers = {
                'Authorization': `Token ${this.config.token}`,
                'Content-Type': 'application/json'
            };

            const response = await axios.get(`${this.config.url}/api/v2/orgs`, {
                headers,
                timeout: config.timeouts.request
            });

            if (response.status === 200) {
                this.log('✓ InfluxDB authentication successful', 'SUCCESS');
                this.results.authentication = true;
                return true;
            } else {
                this.log(`✗ InfluxDB authentication failed: ${response.status}`, 'ERROR');
                return false;
            }
        } catch (error) {
            this.log(`✗ InfluxDB authentication failed: ${error.message}`, 'ERROR');
            return false;
        }
    }

    async testDataWriting() {
        try {
            this.log('Testing InfluxDB data writing...');
            const headers = {
                'Authorization': `Token ${this.config.token}`,
                'Content-Type': 'application/json'
            };

            const testData = config.testData.photovoltaic;
            const timestamp = new Date().toISOString();
            
            const writeData = `${testData.device_type}_data,device_id=${testData.device_id},device_type=${testData.device_type},location=${testData.location},status=${testData.status} power_output=${testData.data.power_output},temperature=${testData.data.temperature},voltage=${testData.data.voltage},current=${testData.data.current},irradiance=${testData.data.irradiance},efficiency=${testData.data.efficiency} ${timestamp}`;

            const response = await axios.post(
                `${this.config.url}/api/v2/write?org=${this.config.organization}&bucket=${this.config.bucket}`,
                writeData,
                {
                    headers,
                    timeout: config.timeouts.request
                }
            );

            if (response.status === 204) {
                this.log('✓ InfluxDB data writing successful', 'SUCCESS');
                this.results.dataWriting = true;
                return true;
            } else {
                this.log(`✗ InfluxDB data writing failed: ${response.status}`, 'ERROR');
                return false;
            }
        } catch (error) {
            this.log(`✗ InfluxDB data writing failed: ${error.message}`, 'ERROR');
            return false;
        }
    }

    async testDataQuerying() {
        try {
            this.log('Testing InfluxDB data querying...');
            const headers = {
                'Authorization': `Token ${this.config.token}`,
                'Content-Type': 'application/json'
            };

            const fluxQuery = `
                from(bucket: "${this.config.bucket}")
                  |> range(start: -5m)
                  |> filter(fn: (r) => r._measurement == "photovoltaic_data")
                  |> filter(fn: (r) => r.device_id == "${config.testData.photovoltaic.device_id}")
                  |> limit(n: 1)
            `;

            const queryBody = {
                query: fluxQuery,
                type: 'flux'
            };

            const response = await axios.post(
                `${this.config.url}/api/v2/query?org=${this.config.organization}`,
                queryBody,
                {
                    headers,
                    timeout: config.timeouts.request
                }
            );

            if (response.status === 200 && response.data) {
                this.log('✓ InfluxDB data querying successful', 'SUCCESS');
                this.results.dataQuerying = true;
                return true;
            } else {
                this.log(`✗ InfluxDB data querying failed: ${response.status}`, 'ERROR');
                return false;
            }
        } catch (error) {
            this.log(`✗ InfluxDB data querying failed: ${error.message}`, 'ERROR');
            return false;
        }
    }

    async testPerformance() {
        try {
            this.log('Testing InfluxDB performance...');
            const headers = {
                'Authorization': `Token ${this.config.token}`,
                'Content-Type': 'application/json'
            };

            const fluxQuery = `
                from(bucket: "${this.config.bucket}")
                  |> range(start: -1h)
                  |> filter(fn: (r) => r._measurement == "photovoltaic_data")
                  |> filter(fn: (r) => r._field == "power_output")
                  |> sum()
            `;

            const queryBody = {
                query: fluxQuery,
                type: 'flux'
            };

            const startTime = Date.now();
            const response = await axios.post(
                `${this.config.url}/api/v2/query?org=${this.config.organization}`,
                queryBody,
                {
                    headers,
                    timeout: config.timeouts.request
                }
            );
            const endTime = Date.now();
            const responseTime = endTime - startTime;

            if (response.status === 200) {
                this.log(`✓ InfluxDB performance test passed (Response time: ${responseTime}ms)`, 'SUCCESS');
                this.results.performance = true;
                return true;
            } else {
                this.log(`✗ InfluxDB performance test failed: ${response.status}`, 'ERROR');
                return false;
            }
        } catch (error) {
            this.log(`✗ InfluxDB performance test failed: ${error.message}`, 'ERROR');
            return false;
        }
    }

    async runAllTests() {
        this.log('Starting InfluxDB API tests...');
        
        await this.testHealth();
        await this.testAuthentication();
        await this.testDataWriting();
        await this.testDataQuerying();
        await this.testPerformance();

        // Summary
        this.log('=== InfluxDB API Test Summary ===');
        const passedTests = Object.values(this.results).filter(result => result === true).length;
        const totalTests = Object.keys(this.results).length;

        Object.entries(this.results).forEach(([test, result]) => {
            const status = result ? 'PASS' : 'FAIL';
            this.log(`${test}: ${status}`);
        });

        this.log(`Overall Result: ${passedTests}/${totalTests} tests passed`);

        if (passedTests === totalTests) {
            this.log('✓ All InfluxDB API tests passed', 'SUCCESS');
            process.exit(0);
        } else {
            this.log('✗ Some InfluxDB API tests failed', 'ERROR');
            process.exit(1);
        }
    }
}

// Run tests if this file is executed directly
if (require.main === module) {
    const tester = new InfluxDBTester();
    tester.runAllTests().catch(error => {
        console.error('Test execution failed:', error);
        process.exit(1);
    });
}

module.exports = InfluxDBTester; 