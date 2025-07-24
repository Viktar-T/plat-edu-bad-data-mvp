# Database Schema Testing (Phase 1 - JavaScript/SQL)

## Objective
Implement JavaScript and SQL-based database schema tests for InfluxDB 3.x in the renewable energy IoT monitoring system MVP, focusing on schema validation, data integrity, and query performance. **Test against the actual running InfluxDB 3.x instance from your main docker-compose.yml.**

## Context
This is Phase 1 of our incremental testing approach. We're using JavaScript/Node.js with SQL for InfluxDB 3.x testing. Database tests are critical for data persistence and retrieval validation. **The main docker-compose.yml should be carefully analyzed to understand the actual InfluxDB 3.x configuration, ports, authentication, volumes, and database setup.**

## Pre-Implementation Analysis
**Before writing tests, thoroughly analyze the `influxdb/` folder in your project to understand:**
- **Configuration files** (`influxdb/config/`) - InfluxDB 3.x configuration settings and parameters
- **Schema definitions** (`influxdb/config/schemas/`) - JSON schema files for photovoltaic, wind turbine, energy storage data
- **Scripts directory** (`influxdb/scripts/`) - Database initialization and setup scripts
- **Data directory** (`influxdb/data/`) - Database storage and persistence configuration
- **Backup configuration** (`influxdb/backups/`) - Backup and restore procedures
- **README documentation** (`influxdb/README.md`) - Database setup and usage instructions
- **InfluxDB 3.x configs** (`influxdb/config/influx3-configs/`) - Version-specific configurations
- **Database structure** - How tables and measurements are organized
- **Retention policies** - Data lifecycle and cleanup rules

## Scope
- InfluxDB 3.x database and table creation with actual running instance
- Schema validation and compliance testing with real database
- Data insertion and retrieval validation using actual InfluxDB
- Query performance optimization with real data
- Data retention policy enforcement with actual database
- Database connection and authentication with real InfluxDB
- **Integration with actual InfluxDB 3.x service from main docker-compose.yml**

## Approach
**Primary Language**: JavaScript/Node.js (InfluxDB client)
**Secondary Language**: SQL (InfluxDB 3.x queries)
**Containerization**: Docker with InfluxDB 3.x instance
**Focus**: Database schema validation and data integrity testing
**Integration**: **Test against actual running InfluxDB 3.x service**

## Success Criteria
- Databases and tables are created with correct schemas in actual InfluxDB
- Data insertion maintains referential integrity with real database
- Queries return accurate results within acceptable timeframes from actual InfluxDB
- Retention policies are enforced correctly with real database
- Database connections are stable and authenticated with actual InfluxDB
- Schema validation prevents invalid data insertion in real database
- Tests run consistently in Docker environment
- **Successfully connects to and operates on actual InfluxDB 3.x instance**

## Implementation Strategy

### Test Structure
```
tests/javascript/database/
├── schema.test.js              # Schema creation and validation with actual InfluxDB
├── data-operations.test.js     # CRUD operations testing with real database
├── queries.test.js            # Query performance testing with actual InfluxDB
├── retention.test.js          # Retention policy testing with real database
└── connection.test.js         # Database connectivity testing with actual InfluxDB

tests/sql/
├── schema/
│   ├── table-creation.test.sql    # Table creation tests with actual InfluxDB
│   └── constraints.test.sql       # Constraint validation with real database
├── queries/
│   ├── performance.test.sql       # Query performance with actual InfluxDB
│   └── data-integrity.test.sql    # Data integrity checks with real database
└── utils/
    └── sample_data.sql            # Test data for actual InfluxDB
```

### Core Test Components

#### 1. Schema Testing (`schema.test.js`)
```javascript
// Test database and table creation with actual InfluxDB
describe('InfluxDB Schema', () => {
  test('should create renewable energy database in actual InfluxDB', async () => {
    // Database creation test using actual InfluxDB instance
  });
  
  test('should create photovoltaic table with correct schema in actual InfluxDB', async () => {
    // Table creation test using real InfluxDB
  });
});
```

#### 2. Data Operations Testing (`data-operations.test.js`)
```javascript
// Test CRUD operations with actual InfluxDB
describe('Data Operations', () => {
  test('should insert photovoltaic data successfully in actual InfluxDB', async () => {
    // Data insertion test using real InfluxDB
  });
  
  test('should retrieve data with correct format from actual InfluxDB', async () => {
    // Data retrieval test using real InfluxDB
  });
});
```

#### 3. Query Performance Testing (`queries.test.js`)
```javascript
// Test query performance with actual InfluxDB
describe('Query Performance', () => {
  test('should execute photovoltaic query within time limit in actual InfluxDB', async () => {
    // Performance test using real InfluxDB
  });
});
```

### Test Data Configuration

#### Database Test Data
```javascript
// Test data for database operations with actual InfluxDB
const photovoltaicTestData = {
  measurement: "photovoltaic_data",
  tags: {
    device_id: "pv_001",
    location: "site_a",
    device_type: "photovoltaic",
    status: "operational"
  },
  fields: {
    power_output: 584.43,
    voltage: 48.3,
    current: 12.1,
    temperature: 45.2,
    irradiance: 850.5,
    efficiency: 18.5
  },
  timestamp: "2024-01-15T10:30:00Z"
};

const windTurbineTestData = {
  measurement: "wind_turbine_data",
  tags: {
    device_id: "wt_001",
    location: "site_b",
    device_type: "wind_turbine",
    status: "operational"
  },
  fields: {
    power_output: 1250.75,
    wind_speed: 12.5,
    wind_direction: 180,
    rotor_speed: 15.2,
    efficiency: 85.3
  },
  timestamp: "2024-01-15T10:30:00Z"
};
```

### Docker Integration

#### InfluxDB Test Configuration
```javascript
// config/influxdb-test-config.json - Based on actual docker-compose.yml
{
  "influxdb": {
    "host": "influxdb",  // Actual service name from docker-compose.yml
    "port": 8086,        // Actual port from docker-compose.yml
    "database": "renewable_energy_test",
    "adminToken": "test-admin-token",  // From docker-compose.yml configuration
    "applicationToken": "test-app-token"  // From docker-compose.yml
  },
  "schemas": {
    "photovoltaic": "schemas/photovoltaic_data.json",
    "wind_turbine": "schemas/wind_turbine_data.json",
    "energy_storage": "schemas/energy_storage_data.json"
  },
  "retention": {
    "default": "10d",
    "short_term": "7d",
    "long_term": "30d"
  }
}
```

### SQL Test Examples

#### Schema Validation (`table-creation.test.sql`)
```sql
-- Test table creation with actual InfluxDB
CREATE TABLE IF NOT EXISTS renewable_energy_test.photovoltaic_data (
  timestamp TIMESTAMP,
  device_id STRING,
  location STRING,
  power_output DOUBLE,
  voltage DOUBLE,
  current DOUBLE,
  temperature DOUBLE,
  irradiance DOUBLE,
  efficiency DOUBLE
);

-- Verify table exists in actual InfluxDB
SHOW TABLES FROM renewable_energy_test;
```

#### Query Performance (`performance.test.sql`)
```sql
-- Test query performance for photovoltaic data with actual InfluxDB
SELECT 
  timestamp,
  device_id,
  power_output,
  efficiency
FROM renewable_energy_test.photovoltaic_data
WHERE timestamp >= NOW() - INTERVAL '24 hours'
  AND device_id = 'pv_001'
ORDER BY timestamp DESC;
```

### Test Execution

#### Jest Configuration for Database
```javascript
// jest.config.js
module.exports = {
  testEnvironment: 'node',
  setupFilesAfterEnv: ['<rootDir>/tests/javascript/utils/db-setup.js'],
  testTimeout: 20000,
  collectCoverageFrom: [
    'tests/javascript/database/**/*.js'
  ]
};
```

#### Database Test Setup
```javascript
// tests/javascript/utils/db-setup.js
const { InfluxDB } = require('@influxdata/influxdb-client');

beforeAll(async () => {
  // Setup InfluxDB test environment with actual running instance
  // Use configuration from docker-compose.yml
  await setupTestDatabase();
});

afterAll(async () => {
  // Cleanup test database with actual InfluxDB
  await cleanupTestDatabase();
});
```

## Test Scenarios

### 1. Schema Creation
- Create renewable energy database in actual InfluxDB
- Create device-specific tables in actual InfluxDB
- Validate table schemas and constraints with real database

### 2. Data Operations
- Insert photovoltaic and wind turbine data in actual InfluxDB
- Retrieve data with correct format from actual InfluxDB
- Update and delete operations with real database

### 3. Query Performance
- Test query execution times with actual InfluxDB
- Validate query results accuracy with real database
- Test complex aggregations with actual InfluxDB

### 4. Data Integrity
- Validate data types and constraints with actual InfluxDB
- Test data consistency with real database
- Check referential integrity with actual InfluxDB

### 5. Retention Policies
- Test data retention enforcement with actual InfluxDB
- Validate cleanup operations with real database
- Test policy compliance with actual InfluxDB

### 6. Connection Management
- Test database connectivity with actual InfluxDB
- Validate authentication with real database
- Test connection resilience with actual InfluxDB

## MVP Considerations
- Focus on core renewable energy tables first
- Use simple schema designs for MVP phase
- Test with manageable data volumes
- Prioritize data accuracy over complex optimizations
- Ensure basic CRUD operations work reliably
- Keep retention policies simple (7-30 days for MVP)
- Use Docker for consistent test environment
- **Test against actual running InfluxDB 3.x instance from main docker-compose.yml**

## Implementation Notes
- Use InfluxDB 3.x client libraries for actual database testing
- Test with realistic renewable energy device data
- Validate data types and constraints with real InfluxDB
- Test query performance with different data volumes
- Verify retention policy enforcement with actual database
- Focus on critical tables for MVP (photovoltaic, wind_turbine, energy_storage)
- Use environment variables for configuration
- Implement proper cleanup in test teardown
- Test both successful and failure scenarios
- **Carefully analyze main docker-compose.yml for InfluxDB 3.x configuration**
- **Use actual service names, ports, authentication, and volumes from docker-compose.yml**
- **Test real InfluxDB 3.x operations, not mocked services**
- **Analyze influxdb/ folder structure and schema definitions before implementing tests** 