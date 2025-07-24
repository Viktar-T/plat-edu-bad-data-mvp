# Test Directory Structure Setup for MVP

## Objective
Create a Docker-based, incremental test directory structure for the renewable energy IoT monitoring system MVP, starting with JavaScript tests and gradually adding Python, SQL, and Shell tests. **Focus on testing the actual programs running in your main containers (Node-RED flows, real MQTT communication, InfluxDB operations, Grafana dashboards).**

## Context
This is Phase 1 of our incremental testing approach. We're using JavaScript/Node.js with Docker containerization. **The main docker-compose.yml should be carefully analyzed to understand the actual services, ports, volumes, and configurations that need to be tested.**

## Scope
- Docker-based test environment setup that integrates with main containers
- Incremental test directory organization (JavaScript first, then Python, SQL, Shell)
- Test configuration management with environment variables
- Sequential test execution orchestration
- Basic reporting and error handling for MVP
- **Integration with actual running services from main docker-compose.yml**

## Approach
**Primary Language**: JavaScript/Node.js (Phase 1)
**Secondary Languages**: Python, SQL, Shell (Phases 2-4)
**Containerization**: Docker with multi-stage builds
**Execution**: Sequential with unified reporting
**Integration**: **Test against actual running services from main docker-compose.yml**

## Success Criteria
- Docker container runs all test types consistently
- JavaScript tests work immediately (Phase 1)
- Easy addition of Python, SQL, Shell tests (Phases 2-4)
- Single command runs entire test suite
- Clear test results and error reporting
- MVP-appropriate complexity and scope
- **Tests successfully connect to and validate actual running services**

## Implementation Strategy

### Phase 1: JavaScript Foundation (Week 1-2)
```
tests/
├── README.md                           # Test strategy overview
├── package.json                        # JavaScript dependencies
├── docker-compose.test.yml            # Test environment setup
├── run-tests.sh                       # Sequential test runner
├── config/
│   ├── test-env.json                  # Environment variables
│   └── mqtt-test-config.json          # MQTT test config
├── data/
│   ├── mqtt-messages/                 # MQTT test data
│   └── expected-results/              # Expected outcomes
├── javascript/                        # JavaScript tests (Phase 1)
│   ├── mqtt/
│   │   ├── connection.test.js         # MQTT connectivity
│   │   ├── messaging.test.js          # Message validation
│   │   └── authentication.test.js     # Auth testing
│   ├── node-red/
│   │   ├── flow-execution.test.js     # Flow logic
│   │   └── data-transformation.test.js # Data processing
│   ├── grafana/
│   │   ├── dashboard.test.js          # Dashboard functionality
│   │   └── data-source.test.js        # Data source connectivity
│   └── utils/
│       ├── test-helpers.js            # Common functions
│       └── mocks.js                   # Mock data
└── reports/
    ├── javascript-results.json        # JavaScript test results
    └── summary.html                   # Basic HTML report
```

### Phase 2: Python Addition (Week 3-4)
```
tests/
├── requirements.txt                    # Python dependencies
├── python/                            # Python tests (Phase 2)
│   ├── data-analysis/
│   │   ├── data-quality.test.py       # Data validation
│   │   └── business-logic.test.py     # Business rules
│   ├── device-simulation/
│   │   ├── photovoltaic.test.py       # Solar simulation
│   │   └── wind-turbine.test.py       # Wind simulation
│   └── utils/
│       ├── test_helpers.py            # Python utilities
│       └── data_generators.py         # Test data generation
└── reports/
    ├── python-results.json            # Python test results
    └── combined-results.json          # Combined results
```

### Phase 3: SQL Integration (Week 5-6)
```
tests/
├── sql/                               # SQL tests (Phase 3)
│   ├── schema/
│   │   ├── table-creation.test.sql    # Schema validation
│   │   └── data-insertion.test.sql    # Data insertion
│   ├── queries/
│   │   ├── performance.test.sql       # Query performance
│   │   └── data-integrity.test.sql    # Data integrity
│   └── utils/
│       └── sample_data.sql            # Test data
└── reports/
    ├── sql-results.json               # SQL test results
    └── full-results.json              # All results
```

### Phase 4: Shell Completion (Week 7-8)
```
tests/
├── shell/                             # Shell tests (Phase 4)
│   ├── system/
│   │   ├── health-checks.test.sh      # System health
│   │   └── service-status.test.sh     # Service status
│   ├── docker/
│   │   ├── container-health.test.sh   # Container health
│   │   └── networking.test.sh         # Network connectivity
│   └── utils/
│       └── test_functions.sh          # Shell utilities
└── reports/
    ├── shell-results.json             # Shell test results
    └── final-report.html              # Complete report
```

## Docker Configuration

### Dockerfile.test
```dockerfile
# Multi-stage test environment
FROM node:18-alpine AS base
RUN apk add --no-cache python3 py3-pip bash curl

# Install JavaScript dependencies
COPY package*.json ./
RUN npm install

# Install Python dependencies (Phase 2+)
COPY requirements.txt ./
RUN pip install -r requirements.txt

# Copy test files
COPY tests/ /app/tests/
WORKDIR /app/tests/

# Test execution
CMD ["./run-tests.sh"]
```

### docker-compose.test.yml
```yaml
version: '3.8'
services:
  test-runner:
    build:
      context: .
      dockerfile: Dockerfile.test
    environment:
      - NODE_ENV=test
      - PYTHONPATH=/app
      # Connect to actual services from main docker-compose.yml
      - MQTT_HOST=mosquitto
      - MQTT_PORT=1883
      - NODE_RED_HOST=node-red
      - NODE_RED_PORT=1880
      - INFLUXDB_HOST=influxdb
      - INFLUXDB_PORT=8086
      - GRAFANA_HOST=grafana
      - GRAFANA_PORT=3000
    volumes:
      - ./tests:/app/tests
      - ./reports:/app/reports
    depends_on:
      - mosquitto
      - node-red
      - influxdb
      - grafana
    networks:
      - iot-network
```

## Test Execution Script

### run-tests.sh
```bash
#!/bin/bash
set -e

echo "🚀 Starting MVP Test Suite..."

# Phase 1: JavaScript Tests
echo "📦 Phase 1: Running JavaScript tests..."
npm test
if [ $? -ne 0 ]; then
    echo "❌ JavaScript tests failed"
    exit 1
fi

# Phase 2: Python Tests (if exists)
if [ -f "requirements.txt" ]; then
    echo "🐍 Phase 2: Running Python tests..."
    python -m pytest python/ -v --json-report
    if [ $? -ne 0 ]; then
        echo "❌ Python tests failed"
        exit 1
    fi
fi

# Phase 3: SQL Tests (if exists)
if [ -d "sql" ]; then
    echo "🗄️ Phase 3: Running SQL tests..."
    # SQL test execution logic
fi

# Phase 4: Shell Tests (if exists)
if [ -d "shell" ]; then
    echo "🐚 Phase 4: Running Shell tests..."
    ./shell/run-system-tests.sh
fi

# Generate unified report
echo "📊 Generating unified test report..."
node utils/generate-report.js

echo "✅ All tests completed successfully!"
```

## MVP Considerations
- Start with JavaScript tests only (Phase 1)
- Add other languages incrementally
- Keep Docker setup simple but complete
- Use sequential execution to avoid complexity
- Focus on reliability over speed
- Implement basic but effective reporting
- Use environment variables for configuration
- Keep error handling simple but functional
- **Ensure tests connect to actual running services from main docker-compose.yml**

## Implementation Notes
- Create directories incrementally as you add test types
- Use consistent naming conventions across all languages
- Implement unified reporting format (JSON) for all test types
- Keep test data realistic but manageable for MVP
- Focus on critical path testing rather than comprehensive coverage
- Use Docker health checks for service dependencies
- Implement basic logging for debugging and monitoring
- **Carefully analyze main docker-compose.yml for service configurations, ports, and network settings**
- **Test against actual Node-RED flows, MQTT communication, InfluxDB operations, and Grafana dashboards** 