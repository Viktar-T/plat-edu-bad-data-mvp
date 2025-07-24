/**
 * Test helper utilities for renewable energy IoT monitoring system
 */

const fs = require('fs');
const path = require('path');

/**
 * Load configuration from JSON files
 * @param {string} configPath - Path to configuration file
 * @returns {Object} Configuration object
 */
function loadConfig(configPath) {
  try {
    const fullPath = path.join(__dirname, '..', '..', configPath);
    const configData = fs.readFileSync(fullPath, 'utf8');
    return JSON.parse(configData);
  } catch (error) {
    throw new Error(`Failed to load config from ${configPath}: ${error.message}`);
  }
}

/**
 * Load test data from JSON files
 * @param {string} dataPath - Path to test data file
 * @returns {Object} Test data object
 */
function loadTestData(dataPath) {
  try {
    const fullPath = path.join(__dirname, '..', '..', 'data', dataPath);
    const data = fs.readFileSync(fullPath, 'utf8');
    return JSON.parse(data);
  } catch (error) {
    throw new Error(`Failed to load test data from ${dataPath}: ${error.message}`);
  }
}

/**
 * Load expected results from JSON files
 * @param {string} resultsPath - Path to expected results file
 * @returns {Object} Expected results object
 */
function loadExpectedResults(resultsPath) {
  try {
    const fullPath = path.join(__dirname, '..', '..', 'data', 'expected-results', resultsPath);
    const results = fs.readFileSync(fullPath, 'utf8');
    return JSON.parse(results);
  } catch (error) {
    throw new Error(`Failed to load expected results from ${resultsPath}: ${error.message}`);
  }
}

/**
 * Validate message format against schema
 * @param {Object} message - Message to validate
 * @param {Object} schema - Schema definition
 * @returns {Object} Validation result
 */
function validateMessageFormat(message, schema) {
  const result = {
    valid: true,
    errors: []
  };

  // Check required fields
  if (schema.requiredFields) {
    for (const field of schema.requiredFields) {
      if (!(field in message)) {
        result.valid = false;
        result.errors.push(`Missing required field: ${field}`);
      }
    }
  }

  // Check numeric ranges
  if (schema.numericRanges) {
    for (const [field, range] of Object.entries(schema.numericRanges)) {
      if (field in message) {
        const value = message[field];
        if (typeof value !== 'number' || value < range[0] || value > range[1]) {
          result.valid = false;
          result.errors.push(`Field ${field} value ${value} is outside valid range [${range[0]}, ${range[1]}]`);
        }
      }
    }
  }

  // Check device types
  if (schema.deviceTypes && message.device_type) {
    if (!schema.deviceTypes.includes(message.device_type)) {
      result.valid = false;
      result.errors.push(`Invalid device type: ${message.device_type}`);
    }
  }

  // Check timestamp format
  if (schema.timestampFormat === 'ISO 8601' && message.timestamp) {
    const timestampRegex = /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(\.\d{3})?Z$/;
    if (!timestampRegex.test(message.timestamp)) {
      result.valid = false;
      result.errors.push('Invalid timestamp format. Expected ISO 8601 format.');
    }
  }

  return result;
}

/**
 * Generate test report
 * @param {string} testName - Name of the test
 * @param {Object} results - Test results
 * @param {Object} expected - Expected results
 * @returns {Object} Test report
 */
function generateTestReport(testName, results, expected) {
  const report = {
    testName,
    timestamp: new Date().toISOString(),
    passed: true,
    results,
    expected,
    duration: results.duration || 0,
    errors: []
  };

  // Compare results with expected
  if (expected) {
    for (const [key, expectedValue] of Object.entries(expected)) {
      if (key in results) {
        const actualValue = results[key];
        
        if (typeof expectedValue === 'string' && expectedValue.includes('<')) {
          // Handle threshold comparisons like "< 5000ms"
          const threshold = parseInt(expectedValue.match(/\d+/)[0]);
          if (actualValue >= threshold) {
            report.passed = false;
            report.errors.push(`${key}: ${actualValue} >= ${threshold} (threshold exceeded)`);
          }
        } else if (actualValue !== expectedValue) {
          report.passed = false;
          report.errors.push(`${key}: expected ${expectedValue}, got ${actualValue}`);
        }
      } else {
        report.passed = false;
        report.errors.push(`Missing result field: ${key}`);
      }
    }
  }

  return report;
}

/**
 * Wait for a specified amount of time
 * @param {number} ms - Milliseconds to wait
 * @returns {Promise} Promise that resolves after the specified time
 */
function wait(ms) {
  return new Promise(resolve => setTimeout(resolve, ms));
}

/**
 * Retry a function with exponential backoff
 * @param {Function} fn - Function to retry
 * @param {number} maxRetries - Maximum number of retries
 * @param {number} baseDelay - Base delay in milliseconds
 * @returns {Promise} Promise that resolves with the function result
 */
async function retry(fn, maxRetries = 3, baseDelay = 1000) {
  let lastError;
  
  for (let attempt = 0; attempt <= maxRetries; attempt++) {
    try {
      return await fn();
    } catch (error) {
      lastError = error;
      
      if (attempt === maxRetries) {
        throw error;
      }
      
      const delay = baseDelay * Math.pow(2, attempt);
      await wait(delay);
    }
  }
}

/**
 * Measure execution time of a function
 * @param {Function} fn - Function to measure
 * @returns {Promise<Object>} Promise that resolves with {result, duration}
 */
async function measureExecutionTime(fn) {
  const start = Date.now();
  const result = await fn();
  const duration = Date.now() - start;
  
  return { result, duration };
}

/**
 * Create a mock MQTT message
 * @param {string} deviceType - Type of device
 * @param {string} deviceId - Device ID
 * @param {Object} overrides - Values to override defaults
 * @returns {Object} Mock MQTT message
 */
function createMockMessage(deviceType, deviceId, overrides = {}) {
  const baseMessage = {
    timestamp: new Date().toISOString(),
    device_id: deviceId,
    device_type: deviceType,
    ...overrides
  };

  return baseMessage;
}

/**
 * Validate topic structure
 * @param {string} topic - MQTT topic to validate
 * @param {Array} validPatterns - Array of valid topic patterns
 * @returns {boolean} True if topic matches any valid pattern
 */
function validateTopicStructure(topic, validPatterns) {
  return validPatterns.some(pattern => {
    const regexPattern = pattern
      .replace(/\//g, '\\/')
      .replace(/\+/g, '[^/]+')
      .replace(/#/g, '.*');
    const regex = new RegExp(`^${regexPattern}$`);
    return regex.test(topic);
  });
}

module.exports = {
  loadConfig,
  loadTestData,
  loadExpectedResults,
  validateMessageFormat,
  generateTestReport,
  wait,
  retry,
  measureExecutionTime,
  createMockMessage,
  validateTopicStructure
}; 