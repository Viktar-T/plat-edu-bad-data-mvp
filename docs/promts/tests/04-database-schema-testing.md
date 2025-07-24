# Database Schema Testing (Phase 1 - JavaScript/SQL)

## Objective
Implement JavaScript and SQL-based database schema tests for InfluxDB 3.x in the renewable energy IoT monitoring system MVP, focusing on schema validation, data integrity, and query performance.

## Context
This is Phase 1 of our incremental testing approach. We're using JavaScript/Node.js with SQL for InfluxDB 3.x testing. Database tests are critical for data persistence and retrieval validation.

## Scope
- InfluxDB 3.x database and table creation
- Schema validation and compliance testing
- Data insertion and retrieval validation
- Query performance optimization
- Data retention policy enforcement
- Database connection and authentication

## Approach
**Primary Language**: JavaScript/Node.js (InfluxDB client)
**Secondary Language**: SQL (InfluxDB 3.x queries)
**Containerization**: Docker with InfluxDB 3.x instance
**Focus**: Database schema validation and data integrity testing

## Success Criteria
- Databases and tables are created with correct schemas
- Data insertion maintains referential integrity
- Queries return accurate results within acceptable timeframes
- Retention policies are enforced correctly
- Database connections are stable and authenticated
- Schema validation prevents invalid data insertion
- Tests run consistently in Docker environment

## Implementation Strategy

### Test Structure
```
tests/javascript/database/
├── schema.test.js              # Schema creation and validation
├── data-operations.test.js     # CRUD operations testing
├── queries.test.js            # Query performance testing
├── retention.test.js          # Retention policy testing
└── connection.test.js         # Database connectivity testing

tests/sql/
├── schema/
│   ├── table-creation.test.sql    # Table creation tests
│   └── constraints.test.sql       # Constraint validation
├── queries/
│   ├── performance.test.sql       # Query performance
│   └── data-integrity.test.sql    # Data integrity checks
└── utils/
    └── sample_data.sql            # Test data
```

### Core Test Components

#### 1. Schema Testing (`schema.test.js`)
```javascript
// Test database and table creation
describe('InfluxDB Schema', () => {
  test('should create renewable energy database', async () => {
    // Database creation test
  });
  
  test('should create photovoltaic table with correct schema', async () => {
    // Table creation test
  });
});
```

#### 2. Data Operations Testing (`data-operations.test.js`)
```javascript
// Test CRUD operations
describe('Data Operations', () => {
  test('should insert photovoltaic data successfully', async () => {
    // Data insertion test
  });
  
  test('should retrieve data with correct format', async () => {
    // Data retrieval test
  });
});
```

#### 3. Query Performance Testing (`queries.test.js`)
```javascript
// Test query performance
describe('Query Performance', () => {
  test('should execute photovoltaic query within time limit', async () => {
    // Performance test
  });
});
```

### Test Data Configuration

#### Database Test Data
```javascript
// Test data for database operations
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
// config/influxdb-test-config.json
{
  "influxdb": {
    "host": "influxdb",
    "port": 8086,
    "database": "renewable_energy_test",
    "adminToken": "test-admin-token",
    "applicationToken": "test-app-token"
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
-- Test table creation
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

-- Verify table exists
SHOW TABLES FROM renewable_energy_test;
```

#### Query Performance (`performance.test.sql`)
```sql
-- Test query performance for photovoltaic data
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
  // Setup InfluxDB test environment
  await setupTestDatabase();
});

afterAll(async () => {
  // Cleanup test database
  await cleanupTestDatabase();
});
```

## Test Scenarios

### 1. Schema Creation
- Create renewable energy database
- Create device-specific tables
- Validate table schemas and constraints

### 2. Data Operations
- Insert photovoltaic and wind turbine data
- Retrieve data with correct format
- Update and delete operations

### 3. Query Performance
- Test query execution times
- Validate query results accuracy
- Test complex aggregations

### 4. Data Integrity
- Validate data types and constraints
- Test data consistency
- Check referential integrity

### 5. Retention Policies
- Test data retention enforcement
- Validate cleanup operations
- Test policy compliance

### 6. Connection Management
- Test database connectivity
- Validate authentication
- Test connection resilience

## MVP Considerations
- Focus on core renewable energy tables first
- Use simple schema designs for MVP phase
- Test with manageable data volumes
- Prioritize data accuracy over complex optimizations
- Ensure basic CRUD operations work reliably
- Keep retention policies simple (7-30 days for MVP)
- Use Docker for consistent test environment

## Implementation Notes
- Use InfluxDB 3.x client libraries
- Test with realistic renewable energy device data
- Validate data types and constraints
- Test query performance with different data volumes
- Verify retention policy enforcement
- Focus on critical tables for MVP (photovoltaic, wind_turbine, energy_storage)
- Use environment variables for configuration
- Implement proper cleanup in test teardown
- Test both successful and failure scenarios 