/**
 * Script to update all MQTT test files with comprehensive logging
 */

const fs = require('fs');
const path = require('path');

// Function to add logging to a test file
function addLoggingToTestFile(filePath, testName) {
  let content = fs.readFileSync(filePath, 'utf8');
  
  // Add TestLogger import
  if (!content.includes('const TestLogger = require')) {
    content = content.replace(
      'const { loadConfig } = require(\'../utils/test-helpers\');',
      'const { loadConfig } = require(\'../utils/test-helpers\');\nconst TestLogger = require(\'../utils/test-logger\');'
    );
  }
  
  // Add logger variable to describe block
  if (!content.includes('let logger;')) {
    content = content.replace(
      'describe(\'MQTT ' + testName + ' Tests\', () => {',
      'describe(\'MQTT ' + testName + ' Tests\', () => {\n  let logger;'
    );
  }
  
  // Add beforeEach for logger initialization
  if (!content.includes('beforeEach(() => {')) {
    content = content.replace(
      'beforeAll(async () => {',
      'beforeAll(async () => {\n  });\n\n  beforeEach(() => {\n    logger = new TestLogger(\'MQTT ' + testName + ' Tests\');\n  });\n\n  afterEach(async () => {'
    );
  }
  
  // Add logger.saveToFile() to afterEach
  if (!content.includes('logger.saveToFile();')) {
    content = content.replace(
      'afterEach(async () => {',
      'afterEach(async () => {\n    // Save logs after each test\n    logger.saveToFile();'
    );
  }
  
  fs.writeFileSync(filePath, content);
  console.log(`Updated ${filePath} with logging`);
}

// Update all test files
const testFiles = [
  { path: 'tests/javascript/mqtt/topics.test.js', name: 'Topic Structure' },
  { path: 'tests/javascript/mqtt/qos.test.js', name: 'QoS' },
  { path: 'tests/javascript/mqtt/resilience.test.js', name: 'Resilience' }
];

testFiles.forEach(file => {
  if (fs.existsSync(file.path)) {
    addLoggingToTestFile(file.path, file.name);
  }
});

console.log('Logging updates completed!'); 