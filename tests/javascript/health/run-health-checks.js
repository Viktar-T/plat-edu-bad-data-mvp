/**
 * Service Health Check Runner
 * 
 * Standalone script to run health checks before MQTT tests.
 * Can be run independently or as part of the test suite.
 */

const { execSync } = require('child_process');
const path = require('path');

console.log('🔍 Starting Service Health Checks...\n');

// Run health check tests
try {
  console.log('Running health check tests...');
  
  // Run the health check tests
  const result = execSync('npm test health/service-health.test.js -- --silent --verbose', {
    cwd: path.join(__dirname, '..'),
    encoding: 'utf8',
    stdio: 'pipe'
  });

  console.log('✅ Health checks completed successfully!');
  console.log('\n📊 Health Check Results:');
  console.log(result);

  // Extract summary from test output
  const lines = result.split('\n');
  const testSummary = lines.filter(line => 
    line.includes('PASS') || 
    line.includes('FAIL') || 
    line.includes('Tests:') ||
    line.includes('Snapshots:') ||
    line.includes('Time:')
  );

  console.log('\n📋 Test Summary:');
  testSummary.forEach(line => console.log(line));

  // Check if all tests passed
  if (result.includes('FAIL') || result.includes('✗')) {
    console.log('\n❌ Some health checks failed!');
    console.log('Please ensure all services are running before proceeding with MQTT tests.');
    process.exit(1);
  } else {
    console.log('\n✅ All services are healthy and ready for MQTT testing!');
    process.exit(0);
  }

} catch (error) {
  console.error('❌ Health check execution failed:', error.message);
  
  if (error.stdout) {
    console.log('\n📊 Test Output:');
    console.log(error.stdout);
  }
  
  if (error.stderr) {
    console.log('\n❌ Error Output:');
    console.log(error.stderr);
  }
  
  console.log('\n🔧 Troubleshooting Steps:');
  console.log('1. Ensure all main services are running: docker-compose up -d');
  console.log('2. Wait for services to fully initialize (30-60 seconds)');
  console.log('3. Check service logs: docker-compose logs [service-name]');
  console.log('4. Verify network connectivity between containers');
  console.log('5. Check authentication credentials in .env file');
  
  process.exit(1);
} 