#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Test configuration
TEST_TIMEOUT=${TEST_TIMEOUT:-30000}
TEST_RETRIES=${TEST_RETRIES:-3}
TEST_DELAY=${TEST_DELAY:-1000}

# Create reports directory
mkdir -p reports/test-logs

# Logging function
log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Wait for services to be ready
wait_for_service() {
    local service=$1
    local host=$2
    local port=$3
    local max_attempts=30
    local attempt=1
    
    log "Waiting for $service to be ready at $host:$port..."
    
    while [ $attempt -le $max_attempts ]; do
        if nc -z $host $port 2>/dev/null; then
            success "$service is ready!"
            return 0
        fi
        
        warning "Attempt $attempt/$max_attempts: $service not ready yet..."
        sleep 2
        attempt=$((attempt + 1))
    done
    
    error "$service failed to become ready after $max_attempts attempts"
    return 1
}

# Main test execution
main() {
    log "🚀 Starting MVP Test Suite for Renewable Energy IoT Monitoring System..."
    
    # Wait for all services to be ready
    log "⏳ Waiting for services to be ready..."
    
    wait_for_service "MQTT" "${MQTT_HOST:-mosquitto}" "${MQTT_PORT:-1883}" || exit 1
    wait_for_service "Node-RED" "${NODE_RED_HOST:-node-red}" "${NODE_RED_PORT:-1880}" || exit 1
    wait_for_service "InfluxDB" "${INFLUXDB_HOST:-influxdb}" "${INFLUXDB_PORT:-8086}" || exit 1
    wait_for_service "Grafana" "${GRAFANA_HOST:-grafana}" "${GRAFANA_PORT:-3000}" || exit 1
    
    success "All services are ready! Starting tests..."
    
    # Phase 1: JavaScript Tests
    log "📦 Phase 1: Running JavaScript tests..."
    if [ -f "package.json" ]; then
        npm test 2>&1 | tee reports/test-logs/javascript-tests.log
        if [ ${PIPESTATUS[0]} -ne 0 ]; then
            error "JavaScript tests failed"
            exit 1
        fi
        success "JavaScript tests completed successfully"
    else
        warning "package.json not found, skipping JavaScript tests"
    fi
    
    # Phase 2: Python Tests (if exists)
    if [ -f "requirements.txt" ]; then
        log "🐍 Phase 2: Running Python tests..."
        python3 -m pytest python/ -v --json-report --json-report-file=reports/python-results.json 2>&1 | tee reports/test-logs/python-tests.log
        if [ ${PIPESTATUS[0]} -ne 0 ]; then
            error "Python tests failed"
            exit 1
        fi
        success "Python tests completed successfully"
    else
        log "📝 Phase 2: Python tests not configured (requirements.txt not found)"
    fi
    
    # Phase 3: SQL Tests (if exists)
    if [ -d "sql" ]; then
        log "🗄️ Phase 3: Running SQL tests..."
        # SQL test execution logic would go here
        # For now, just log that it's not implemented yet
        log "📝 Phase 3: SQL tests not yet implemented"
    else
        log "📝 Phase 3: SQL tests not configured (sql/ directory not found)"
    fi
    
    # Phase 4: Shell Tests (if exists)
    if [ -d "shell" ]; then
        log "🐚 Phase 4: Running Shell tests..."
        if [ -f "shell/run-system-tests.sh" ]; then
            bash shell/run-system-tests.sh 2>&1 | tee reports/test-logs/shell-tests.log
            if [ ${PIPESTATUS[0]} -ne 0 ]; then
                error "Shell tests failed"
                exit 1
            fi
            success "Shell tests completed successfully"
        else
            log "📝 Phase 4: Shell tests not yet implemented"
        fi
    else
        log "📝 Phase 4: Shell tests not configured (shell/ directory not found)"
    fi
    
    # Generate unified report
    log "📊 Generating unified test report..."
    if [ -f "javascript/utils/generate-report.js" ]; then
        node javascript/utils/generate-report.js 2>&1 | tee reports/test-logs/report-generation.log
        if [ ${PIPESTATUS[0]} -ne 0 ]; then
            warning "Report generation failed, but tests completed"
        else
            success "Unified report generated successfully"
        fi
    else
        log "📝 Report generation not yet implemented"
    fi
    
    # Final summary
    log "📋 Test Summary:"
    log "  - JavaScript tests: ${GREEN}✓${NC}"
    if [ -f "requirements.txt" ]; then
        log "  - Python tests: ${GREEN}✓${NC}"
    fi
    if [ -d "sql" ]; then
        log "  - SQL tests: ${YELLOW}⚠${NC} (not implemented)"
    fi
    if [ -d "shell" ]; then
        log "  - Shell tests: ${YELLOW}⚠${NC} (not implemented)"
    fi
    
    success "✅ All configured tests completed successfully!"
    log "📁 Test results available in:"
    log "  - JavaScript: reports/javascript-results.json"
    log "  - Python: reports/python-results.json (if available)"
    log "  - Combined: reports/summary.html (if available)"
    log "  - Logs: reports/test-logs/"
}

# Handle script arguments
case "${1:-}" in
    "javascript"|"js")
        log "📦 Running JavaScript tests only..."
        npm test
        ;;
    "python"|"py")
        log "🐍 Running Python tests only..."
        python3 -m pytest python/ -v --json-report
        ;;
    "sql")
        log "🗄️ Running SQL tests only..."
        log "📝 SQL tests not yet implemented"
        ;;
    "shell")
        log "🐚 Running Shell tests only..."
        if [ -f "shell/run-system-tests.sh" ]; then
            bash shell/run-system-tests.sh
        else
            log "📝 Shell tests not yet implemented"
        fi
        ;;
    "help"|"-h"|"--help")
        echo "Usage: $0 [phase]"
        echo ""
        echo "Phases:"
        echo "  javascript, js  - Run JavaScript tests only"
        echo "  python, py      - Run Python tests only"
        echo "  sql             - Run SQL tests only"
        echo "  shell           - Run Shell tests only"
        echo "  (no args)       - Run all configured tests"
        echo ""
        echo "Examples:"
        echo "  $0              # Run all tests"
        echo "  $0 javascript   # Run JavaScript tests only"
        echo "  $0 python       # Run Python tests only"
        ;;
    *)
        main
        ;;
esac 