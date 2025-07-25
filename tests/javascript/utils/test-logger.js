/**
 * Test Logger Utility for MQTT Tests
 * 
 * Provides comprehensive logging functionality for MQTT test execution.
 * Creates only one log file per test run with datetime prefix.
 * Uses file-based locking to prevent multiple processes from creating files.
 */

const fs = require('fs');
const path = require('path');

// Shared logger instance for the entire test run
let sharedLogger = null;
let hasSavedLogs = false;
let lockFile = null;

class TestLogger {
  constructor(testName) {
    this.testName = testName;
    this.startTime = new Date();
    this.logs = [];
    this.errors = [];
    this.warnings = [];
    this.metrics = {
      messagesSent: 0,
      messagesReceived: 0,
      connections: 0,
      disconnections: 0,
      errors: 0,
      warnings: 0
    };
    
    // Create test-results directory if it doesn't exist
    this.resultsDir = path.join(__dirname, '..', 'mqtt', 'test-results');
    if (!fs.existsSync(this.resultsDir)) {
      fs.mkdirSync(this.resultsDir, { recursive: true });
    }
    
    // Initialize shared logger if this is the first instance
    if (!sharedLogger) {
      sharedLogger = {
        startTime: new Date(),
        allLogs: [],
        allErrors: [],
        allWarnings: [],
        testResults: [],
        fileName: this.generateFileName()
      };
      
      // Create lock file to prevent multiple processes from saving
      lockFile = path.join(this.resultsDir, 'test-lock.json');
      
      // Set up process exit handlers to ensure cleanup
      process.on('exit', () => {
        TestLogger.cleanup();
      });
      
      process.on('SIGINT', () => {
        TestLogger.cleanup();
        process.exit(0);
      });
      
      process.on('SIGTERM', () => {
        TestLogger.cleanup();
        process.exit(0);
      });
    }
  }

  /**
   * Generate filename with datetime prefix
   */
  generateFileName() {
    const now = new Date();
    const dateStr = now.toISOString().split('T')[0]; // YYYY-MM-DD
    const timeStr = now.toTimeString().split(' ')[0].replace(/:/g, '-'); // HH-MM-SS
    return `${dateStr}_${timeStr}_MQTT_Tests.md`;
  }

  /**
   * Check if we can acquire the lock to save logs
   */
  canAcquireLock() {
    try {
      if (!fs.existsSync(lockFile)) {
        return true;
      }
      
      const lockData = JSON.parse(fs.readFileSync(lockFile, 'utf8'));
      const lockTime = new Date(lockData.timestamp);
      const now = new Date();
      
      // If lock is older than 5 minutes, consider it stale
      if (now - lockTime > 5 * 60 * 1000) {
        return true;
      }
      
      return false;
    } catch (error) {
      // If we can't read the lock file, assume we can acquire it
      return true;
    }
  }

  /**
   * Acquire lock for saving logs
   */
  acquireLock() {
    try {
      const lockData = {
        timestamp: new Date().toISOString(),
        processId: process.pid,
        fileName: sharedLogger.fileName
      };
      fs.writeFileSync(lockFile, JSON.stringify(lockData, null, 2));
      return true;
    } catch (error) {
      console.error('Failed to acquire lock:', error.message);
      return false;
    }
  }

  /**
   * Release lock after saving logs
   */
  releaseLock() {
    try {
      if (fs.existsSync(lockFile)) {
        fs.unlinkSync(lockFile);
      }
    } catch (error) {
      console.error('Failed to release lock:', error.message);
    }
  }

  /**
   * Cleanup function to ensure lock file is removed
   */
  static cleanup() {
    if (lockFile && fs.existsSync(lockFile)) {
      try {
        fs.unlinkSync(lockFile);
        console.log('🧹 Cleaned up lock file');
      } catch (error) {
        console.error('Failed to cleanup lock file:', error.message);
      }
    }
  }

  /**
   * Log an info message
   */
  info(message, data = null) {
    const logEntry = {
      timestamp: new Date().toISOString(),
      level: 'INFO',
      message,
      data,
      testName: this.testName
    };
    this.logs.push(logEntry);
    sharedLogger.allLogs.push(logEntry);
    console.log(`[INFO] ${message}`, data ? JSON.stringify(data, null, 2) : '');
  }

  /**
   * Log a warning message
   */
  warn(message, data = null) {
    const logEntry = {
      timestamp: new Date().toISOString(),
      level: 'WARN',
      message,
      data,
      testName: this.testName
    };
    this.warnings.push(logEntry);
    this.logs.push(logEntry);
    sharedLogger.allWarnings.push(logEntry);
    this.metrics.warnings++;
    console.warn(`[WARN] ${message}`, data ? JSON.stringify(data, null, 2) : '');
  }

  /**
   * Log an error message
   */
  error(message, error = null) {
    const logEntry = {
      timestamp: new Date().toISOString(),
      level: 'ERROR',
      message,
      error: error ? {
        name: error.name,
        message: error.message,
        stack: error.stack
      } : null,
      testName: this.testName
    };
    this.errors.push(logEntry);
    this.logs.push(logEntry);
    sharedLogger.allErrors.push(logEntry);
    this.metrics.errors++;
    console.error(`[ERROR] ${message}`, error ? error.stack : '');
  }

  /**
   * Log MQTT connection event
   */
  logConnection(clientId, host, port, success = true) {
    this.metrics.connections++;
    this.info(`MQTT Connection ${success ? 'established' : 'failed'}`, {
      clientId,
      host,
      port,
      success,
      timestamp: new Date().toISOString()
    });
  }

  /**
   * Log MQTT disconnection event
   */
  logDisconnection(clientId, reason = null) {
    this.metrics.disconnections++;
    this.info(`MQTT Disconnection`, {
      clientId,
      reason,
      timestamp: new Date().toISOString()
    });
  }

  /**
   * Log message publish event
   */
  logMessagePublish(topic, payload, qos = 1, success = true) {
    this.metrics.messagesSent++;
    this.info(`Message Published`, {
      topic,
      payload: typeof payload === 'string' ? payload : JSON.stringify(payload),
      qos,
      success,
      timestamp: new Date().toISOString()
    });
  }

  /**
   * Log message receive event
   */
  logMessageReceive(topic, payload, qos = 1) {
    this.metrics.messagesReceived++;
    this.info(`Message Received`, {
      topic,
      payload: typeof payload === 'string' ? payload : JSON.stringify(payload),
      qos,
      timestamp: new Date().toISOString()
    });
  }

  /**
   * Log subscription event
   */
  logSubscription(topic, qos = 1, success = true) {
    this.info(`Topic Subscription ${success ? 'successful' : 'failed'}`, {
      topic,
      qos,
      success,
      timestamp: new Date().toISOString()
    });
  }

  /**
   * Log authentication event
   */
  logAuthentication(username, success = true, error = null) {
    this.info(`Authentication ${success ? 'successful' : 'failed'}`, {
      username,
      success,
      error: error ? error.message : null,
      timestamp: new Date().toISOString()
    });
  }

  /**
   * Log test step
   */
  logStep(step, details = null) {
    this.info(`Test Step: ${step}`, details);
  }

  /**
   * Log test assertion
   */
  logAssertion(description, passed, expected = null, actual = null) {
    const level = passed ? 'INFO' : 'ERROR';
    const logEntry = {
      timestamp: new Date().toISOString(),
      level,
      message: `Assertion: ${description}`,
      data: {
        passed,
        expected,
        actual
      },
      testName: this.testName
    };
    
    if (passed) {
      this.logs.push(logEntry);
      sharedLogger.allLogs.push(logEntry);
    } else {
      this.errors.push(logEntry);
      this.logs.push(logEntry);
      sharedLogger.allErrors.push(logEntry);
      this.metrics.errors++;
    }
    
    const prefix = passed ? '[PASS]' : '[FAIL]';
    console.log(`${prefix} ${description}`);
  }

  /**
   * Log performance metric
   */
  logPerformance(metric, value, unit = 'ms') {
    this.info(`Performance: ${metric}`, {
      value,
      unit,
      timestamp: new Date().toISOString()
    });
  }

  /**
   * Generate test summary
   */
  generateSummary() {
    const endTime = new Date();
    const duration = endTime - this.startTime;
    
    return {
      testName: this.testName,
      startTime: this.startTime.toISOString(),
      endTime: endTime.toISOString(),
      duration: `${duration}ms`,
      totalLogs: this.logs.length,
      errors: this.errors.length,
      warnings: this.warnings.length,
      metrics: this.metrics,
      success: this.errors.length === 0
    };
  }

  /**
   * Save logs to markdown file (shared across all test instances)
   * This method is now passive - it only collects data, doesn't save files
   */
  saveToFile() {
    // Add this test's results to shared logger
    const summary = this.generateSummary();
    sharedLogger.testResults.push(summary);
    
    // DO NOT save files here - only the static saveAllLogs() method should create files
    // This prevents multiple files from being created during test execution
  }

  /**
   * Save shared logs to a single file
   */
  saveSharedLogs() {
    console.log('🔍 Attempting to save shared logs...');
    console.log('📊 Shared logger state:', {
      hasSavedLogs,
      testResultsCount: sharedLogger ? sharedLogger.testResults.length : 0,
      allLogsCount: sharedLogger ? sharedLogger.allLogs.length : 0
    });
    
    if (hasSavedLogs) {
      console.log('⚠️ Logs already saved, skipping...');
      return;
    }
    
    // Check if we can acquire the lock
    if (!this.canAcquireLock()) {
      console.log('🔒 Another process is saving logs, skipping...');
      return;
    }
    
    // Try to acquire the lock
    if (!this.acquireLock()) {
      console.log('❌ Failed to acquire lock, skipping...');
      return;
    }
    
    console.log('🔓 Lock acquired, proceeding to save logs...');
    
    const endTime = new Date();
    const totalDuration = endTime - sharedLogger.startTime;
    
    let markdown = `# MQTT Test Suite Results\n\n`;
    
    // Overall Summary
    markdown += `## Overall Summary\n\n`;
    markdown += `- **Test Run Start**: ${sharedLogger.startTime.toISOString()}\n`;
    markdown += `- **Test Run End**: ${endTime.toISOString()}\n`;
    markdown += `- **Total Duration**: ${totalDuration}ms\n`;
    markdown += `- **Total Tests**: ${sharedLogger.testResults.length}\n`;
    markdown += `- **Total Logs**: ${sharedLogger.allLogs.length}\n`;
    markdown += `- **Total Errors**: ${sharedLogger.allErrors.length}\n`;
    markdown += `- **Total Warnings**: ${sharedLogger.allWarnings.length}\n\n`;
    
    // Test Results Summary
    markdown += `## Test Results Summary\n\n`;
    markdown += `| Test Name | Status | Duration | Logs | Errors | Warnings |\n`;
    markdown += `|-----------|--------|----------|------|--------|----------|\n`;
    
    sharedLogger.testResults.forEach(result => {
      const status = result.success ? '✅ PASS' : '❌ FAIL';
      markdown += `| ${result.testName} | ${status} | ${result.duration} | ${result.totalLogs} | ${result.errors} | ${result.warnings} |\n`;
    });
    
    markdown += `\n`;
    
    // Overall Metrics
    const totalMetrics = {
      connections: 0,
      disconnections: 0,
      messagesSent: 0,
      messagesReceived: 0,
      errors: 0,
      warnings: 0
    };
    
    sharedLogger.testResults.forEach(result => {
      Object.keys(totalMetrics).forEach(key => {
        totalMetrics[key] += result.metrics[key] || 0;
      });
    });
    
    markdown += `## Overall Metrics\n\n`;
    markdown += `- **Total Connections**: ${totalMetrics.connections}\n`;
    markdown += `- **Total Disconnections**: ${totalMetrics.disconnections}\n`;
    markdown += `- **Total Messages Sent**: ${totalMetrics.messagesSent}\n`;
    markdown += `- **Total Messages Received**: ${totalMetrics.messagesReceived}\n`;
    markdown += `- **Total Errors**: ${totalMetrics.errors}\n`;
    markdown += `- **Total Warnings**: ${totalMetrics.warnings}\n\n`;
    
    // Errors
    if (sharedLogger.allErrors.length > 0) {
      markdown += `## All Errors\n\n`;
      sharedLogger.allErrors.forEach((error, index) => {
        markdown += `### Error ${index + 1} (${error.testName})\n\n`;
        markdown += `- **Time**: ${error.timestamp}\n`;
        markdown += `- **Test**: ${error.testName}\n`;
        markdown += `- **Message**: ${error.message}\n`;
        if (error.error) {
          markdown += `- **Error Name**: ${error.error.name}\n`;
          markdown += `- **Error Message**: ${error.error.message}\n`;
          markdown += `- **Stack Trace**: \n\`\`\`\n${error.error.stack}\n\`\`\`\n`;
        }
        markdown += `\n`;
      });
    }
    
    // Warnings
    if (sharedLogger.allWarnings.length > 0) {
      markdown += `## All Warnings\n\n`;
      sharedLogger.allWarnings.forEach((warning, index) => {
        markdown += `### Warning ${index + 1} (${warning.testName})\n\n`;
        markdown += `- **Time**: ${warning.timestamp}\n`;
        markdown += `- **Test**: ${warning.testName}\n`;
        markdown += `- **Message**: ${warning.message}\n`;
        if (warning.data) {
          markdown += `- **Data**: \n\`\`\`json\n${JSON.stringify(warning.data, null, 2)}\n\`\`\`\n`;
        }
        markdown += `\n`;
      });
    }
    
    // Detailed Logs
    markdown += `## Detailed Logs\n\n`;
    markdown += `| Time | Test | Level | Message | Data |\n`;
    markdown += `|------|------|-------|---------|------|\n`;
    
    sharedLogger.allLogs.forEach(log => {
      const time = log.timestamp.split('T')[1].split('.')[0]; // HH:MM:SS
      const testName = log.testName || 'Unknown';
      const level = log.level;
      const message = log.message.replace(/\|/g, '\\|').replace(/\n/g, '<br>');
      const data = log.data ? JSON.stringify(log.data).replace(/\|/g, '\\|').replace(/\n/g, '<br>') : '';
      
      markdown += `| ${time} | ${testName} | ${level} | ${message} | ${data} |\n`;
    });
    
    const filePath = path.join(this.resultsDir, sharedLogger.fileName);
    
    try {
      console.log('💾 Saving log file to:', filePath);
      fs.writeFileSync(filePath, markdown);
      console.log(`✅ Test logs saved to: ${filePath}`);
      hasSavedLogs = true;
      
      // Release the lock
      this.releaseLock();
      console.log('🔓 Lock released');
      
      return filePath;
    } catch (error) {
      console.error(`❌ Failed to save test logs: ${error.message}`);
      
      // Release the lock even if saving failed
      this.releaseLock();
      
      return null;
    }
  }

  /**
   * Static method to save all logs (call this at the end of all tests)
   */
  static saveAllLogs() {
    if (sharedLogger && !hasSavedLogs) {
      const logger = new TestLogger('Final');
      logger.saveSharedLogs();
      hasSavedLogs = true;
    }
  }

  /**
   * Global teardown function for Jest
   */
  static globalTeardown() {
    console.log('📄 Saving all test logs...');
    TestLogger.saveAllLogs();
    TestLogger.cleanup(); // Call cleanup on global teardown
  }

  /**
   * Get all log entries
   */
  getLogs() {
    return this.logs;
  }

  /**
   * Get error entries
   */
  getErrors() {
    return this.errors;
  }

  /**
   * Get warning entries
   */
  getWarnings() {
    return this.warnings;
  }

  /**
   * Get metrics
   */
  getMetrics() {
    return this.metrics;
  }
}

module.exports = TestLogger; 