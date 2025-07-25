/**
 * Complete Test Suite Runner
 * 
 * Orchestrates the full test suite execution including health checks and MQTT tests.
 * Ensures proper logging and cleanup.
 */

const { execSync } = require('child_process');
const path = require('path');
const TestLogger = require('./utils/test-logger');

async function runHealthChecks() {
  console.log('🔍 Running Health Checks...');
  try {
    execSync('npm test health/service-health.test.js -- --silent --verbose', {
      cwd: path.join(__dirname, '..'),
      encoding: 'utf8',
      stdio: 'pipe'
    });
    console.log('✅ Health checks passed!');
    return true;
  } catch (error) {
    console.error('❌ Health checks failed:', error.message);
    return false;
  }
}

async function runMqttTests() {
  console.log('🚀 Running MQTT Tests...');
  try {
    execSync('npm test mqtt/ -- --silent --verbose', {
      cwd: path.join(__dirname, '..'),
      encoding: 'utf8',
      stdio: 'pipe'
    });
    console.log('✅ MQTT tests completed!');
    return true;
  } catch (error) {
    console.error('❌ MQTT tests failed:', error.message);
    return false;
  }
}

async function main() {
  console.log('🎯 Starting Complete Test Suite...\n');
  
  try {
    // Run health checks first
    const healthPassed = await runHealthChecks();
    
    if (healthPassed) {
      // Run MQTT tests if health checks pass
      await runMqttTests();
    } else {
      console.log('❌ Health checks failed! MQTT tests will not run.');
    }
    
    // Always save all logs at the end
    console.log('📄 Saving all test logs...');
    TestLogger.saveAllLogs();
    
    console.log('\n🎉 Test suite execution completed!');
    console.log('📁 Check test results in: tests/javascript/mqtt/test-results/');
    
  } catch (error) {
    console.error('💥 Test suite execution failed:', error.message);
    
    // Still save logs even if tests fail
    console.log('📄 Saving logs despite test failures...');
    TestLogger.saveAllLogs();
    
    process.exit(1);
  }
}

// Run the main function
main(); 