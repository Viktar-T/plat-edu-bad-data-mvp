#!/bin/bash

# MQTT Connectivity Testing Script
# IoT Renewable Energy Monitoring System
# Tests authentication, topic publishing/subscribing, and system health

set -e

# =============================================================================
# CONFIGURATION
# =============================================================================

# MQTT Broker Configuration
MQTT_HOST=${MQTT_HOST:-"localhost"}
MQTT_PORT=${MQTT_PORT:-"1883"}
MQTT_WS_PORT=${MQTT_WS_PORT:-"9001"}

# Test Credentials (replace with actual credentials)
TEST_USER=${TEST_USER:-"admin"}
TEST_PASSWORD=${TEST_PASSWORD:-"admin_password_456"}

# Test Device Credentials
PV_USER=${PV_USER:-"pv_001"}
PV_PASSWORD=${PV_PASSWORD:-"device_password_123"}

# Test Topics
TEST_TOPIC="test/connectivity"
DEVICE_TOPIC="devices/photovoltaic/pv_001/data"
STATUS_TOPIC="devices/photovoltaic/pv_001/status"
COMMAND_TOPIC="devices/photovoltaic/pv_001/commands"
HEALTH_TOPIC="system/health/mosquitto"
ALERT_TOPIC="system/alerts/info"

# Test Message
TEST_MESSAGE='{"device_id":"pv_001","device_type":"photovoltaic","timestamp":"2024-01-15T10:30:00Z","data":{"irradiance":850.5,"temperature":45.2,"voltage":48.3,"current":12.1,"power_output":584.43},"status":"operational","location":"site_a"}'

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# =============================================================================
# UTILITY FUNCTIONS
# =============================================================================

print_header() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

# =============================================================================
# DEPENDENCY CHECKS
# =============================================================================

check_dependencies() {
    print_header "Checking Dependencies"
    
    # Check if mosquitto_pub is available
    if command -v mosquitto_pub >/dev/null 2>&1; then
        print_success "mosquitto_pub found"
    else
        print_error "mosquitto_pub not found. Please install mosquitto-clients"
        exit 1
    fi
    
    # Check if mosquitto_sub is available
    if command -v mosquitto_sub >/dev/null 2>&1; then
        print_success "mosquitto_sub found"
    else
        print_error "mosquitto_sub not found. Please install mosquitto-clients"
        exit 1
    fi
    
    # Check if curl is available
    if command -v curl >/dev/null 2>&1; then
        print_success "curl found"
    else
        print_error "curl not found. Please install curl"
        exit 1
    fi
}

# =============================================================================
# BROKER CONNECTIVITY TESTS
# =============================================================================

test_broker_connectivity() {
    print_header "Testing MQTT Broker Connectivity"
    
    # Test basic connectivity
    print_info "Testing basic connectivity to $MQTT_HOST:$MQTT_PORT"
    
    if timeout 5 mosquitto_pub -h "$MQTT_HOST" -p "$MQTT_PORT" -t "$TEST_TOPIC" -m "ping" --quiet; then
        print_success "Basic connectivity successful"
    else
        print_error "Basic connectivity failed"
        return 1
    fi
}

test_authentication() {
    print_header "Testing Authentication"
    
    # Test authentication with credentials
    print_info "Testing authentication with user: $TEST_USER"
    
    if timeout 5 mosquitto_pub -h "$MQTT_HOST" -p "$MQTT_PORT" -u "$TEST_USER" -P "$TEST_PASSWORD" -t "$TEST_TOPIC" -m "auth_test" --quiet; then
        print_success "Authentication successful"
    else
        print_error "Authentication failed"
        return 1
    fi
}

test_device_authentication() {
    print_header "Testing Device Authentication"
    
    # Test device authentication
    print_info "Testing device authentication with user: $PV_USER"
    
    if timeout 5 mosquitto_pub -h "$MQTT_HOST" -p "$MQTT_PORT" -u "$PV_USER" -P "$PV_PASSWORD" -t "$DEVICE_TOPIC" -m "$TEST_MESSAGE" --quiet; then
        print_success "Device authentication successful"
    else
        print_error "Device authentication failed"
        return 1
    fi
}

# =============================================================================
# TOPIC PUBLISHING TESTS
# =============================================================================

test_topic_publishing() {
    print_header "Testing Topic Publishing"
    
    # Test publishing to device data topic
    print_info "Testing publishing to device data topic"
    
    if timeout 5 mosquitto_pub -h "$MQTT_HOST" -p "$MQTT_PORT" -u "$PV_USER" -P "$PV_PASSWORD" -t "$DEVICE_TOPIC" -m "$TEST_MESSAGE" --quiet; then
        print_success "Device data publishing successful"
    else
        print_error "Device data publishing failed"
        return 1
    fi
    
    # Test publishing to device status topic
    print_info "Testing publishing to device status topic"
    
    STATUS_MESSAGE='{"device_id":"pv_001","status":"operational","timestamp":"2024-01-15T10:30:00Z"}'
    
    if timeout 5 mosquitto_pub -h "$MQTT_HOST" -p "$MQTT_PORT" -u "$PV_USER" -P "$PV_PASSWORD" -t "$STATUS_TOPIC" -m "$STATUS_MESSAGE" --quiet; then
        print_success "Device status publishing successful"
    else
        print_error "Device status publishing failed"
        return 1
    fi
    
    # Test publishing to system health topic
    print_info "Testing publishing to system health topic"
    
    HEALTH_MESSAGE='{"service":"mosquitto","status":"healthy","timestamp":"2024-01-15T10:30:00Z"}'
    
    if timeout 5 mosquitto_pub -h "$MQTT_HOST" -p "$MQTT_PORT" -u "$TEST_USER" -P "$TEST_PASSWORD" -t "$HEALTH_TOPIC" -m "$HEALTH_MESSAGE" --quiet; then
        print_success "System health publishing successful"
    else
        print_error "System health publishing failed"
        return 1
    fi
}

# =============================================================================
# TOPIC SUBSCRIPTION TESTS
# =============================================================================

test_topic_subscription() {
    print_header "Testing Topic Subscription"
    
    # Test subscribing to device commands
    print_info "Testing subscription to device commands"
    
    # Start subscription in background
    mosquitto_sub -h "$MQTT_HOST" -p "$MQTT_PORT" -u "$PV_USER" -P "$PV_PASSWORD" -t "$COMMAND_TOPIC" -C 1 --quiet &
    SUB_PID=$!
    
    # Wait a moment for subscription to establish
    sleep 2
    
    # Publish a command
    COMMAND_MESSAGE='{"command":"restart","timestamp":"2024-01-15T10:30:00Z"}'
    
    if timeout 5 mosquitto_pub -h "$MQTT_HOST" -p "$MQTT_PORT" -u "$TEST_USER" -P "$TEST_PASSWORD" -t "$COMMAND_TOPIC" -m "$COMMAND_MESSAGE" --quiet; then
        print_success "Command publishing successful"
    else
        print_error "Command publishing failed"
        kill $SUB_PID 2>/dev/null || true
        return 1
    fi
    
    # Wait for subscription to receive message
    sleep 2
    
    # Kill subscription
    kill $SUB_PID 2>/dev/null || true
    
    print_success "Topic subscription test completed"
}

# =============================================================================
# WEBSOCKET TESTS
# =============================================================================

test_websocket_connectivity() {
    print_header "Testing WebSocket Connectivity"
    
    print_info "Testing WebSocket connection on port $MQTT_WS_PORT"
    
    # Test WebSocket connection using curl
    if timeout 5 curl -f -s "http://$MQTT_HOST:$MQTT_WS_PORT" >/dev/null 2>&1; then
        print_success "WebSocket port is accessible"
    else
        print_warning "WebSocket port test failed (this is normal if WebSocket is not configured)"
    fi
}

# =============================================================================
# PERFORMANCE TESTS
# =============================================================================

test_performance() {
    print_header "Testing Performance"
    
    print_info "Testing message throughput"
    
    # Test publishing multiple messages
    for i in {1..10}; do
        MESSAGE="{\"test_id\":$i,\"timestamp\":\"$(date -u +%Y-%m-%dT%H:%M:%SZ)\"}"
        
        if timeout 5 mosquitto_pub -h "$MQTT_HOST" -p "$MQTT_PORT" -u "$TEST_USER" -P "$TEST_PASSWORD" -t "$TEST_TOPIC" -m "$MESSAGE" --quiet; then
            print_success "Message $i published successfully"
        else
            print_error "Message $i failed"
            return 1
        fi
        
        sleep 0.1
    done
    
    print_success "Performance test completed"
}

# =============================================================================
# SECURITY TESTS
# =============================================================================

test_security() {
    print_header "Testing Security"
    
    # Test anonymous access (should fail)
    print_info "Testing anonymous access (should fail)"
    
    if timeout 5 mosquitto_pub -h "$MQTT_HOST" -p "$MQTT_PORT" -t "$TEST_TOPIC" -m "anonymous_test" --quiet 2>/dev/null; then
        print_error "Anonymous access allowed (security issue)"
        return 1
    else
        print_success "Anonymous access properly denied"
    fi
    
    # Test invalid credentials (should fail)
    print_info "Testing invalid credentials (should fail)"
    
    if timeout 5 mosquitto_pub -h "$MQTT_HOST" -p "$MQTT_PORT" -u "invalid_user" -P "invalid_password" -t "$TEST_TOPIC" -m "invalid_auth_test" --quiet 2>/dev/null; then
        print_error "Invalid credentials accepted (security issue)"
        return 1
    else
        print_success "Invalid credentials properly denied"
    fi
}

# =============================================================================
# TOPIC STRUCTURE TESTS
# =============================================================================

test_topic_structure() {
    print_header "Testing Topic Structure"
    
    # Test all device types
    DEVICE_TYPES=("photovoltaic" "wind_turbine" "biogas_plant" "heat_boiler" "energy_storage")
    
    for device_type in "${DEVICE_TYPES[@]}"; do
        print_info "Testing topic structure for $device_type"
        
        TOPIC="devices/$device_type/test_device/data"
        MESSAGE="{\"device_type\":\"$device_type\",\"test\":true}"
        
        if timeout 5 mosquitto_pub -h "$MQTT_HOST" -p "$MQTT_PORT" -u "$TEST_USER" -P "$TEST_PASSWORD" -t "$TOPIC" -m "$MESSAGE" --quiet; then
            print_success "$device_type topic structure working"
        else
            print_error "$device_type topic structure failed"
            return 1
        fi
    done
}

# =============================================================================
# MAIN EXECUTION
# =============================================================================

main() {
    print_header "MQTT Connectivity Test Suite"
    print_info "Testing MQTT broker at $MQTT_HOST:$MQTT_PORT"
    print_info "Test user: $TEST_USER"
    print_info "Device user: $PV_USER"
    echo
    
    # Run all tests
    local exit_code=0
    
    check_dependencies || exit_code=1
    echo
    
    test_broker_connectivity || exit_code=1
    echo
    
    test_authentication || exit_code=1
    echo
    
    test_device_authentication || exit_code=1
    echo
    
    test_topic_publishing || exit_code=1
    echo
    
    test_topic_subscription || exit_code=1
    echo
    
    test_websocket_connectivity || exit_code=1
    echo
    
    test_performance || exit_code=1
    echo
    
    test_security || exit_code=1
    echo
    
    test_topic_structure || exit_code=1
    echo
    
    # Summary
    print_header "Test Summary"
    if [ $exit_code -eq 0 ]; then
        print_success "All tests passed! MQTT broker is working correctly."
    else
        print_error "Some tests failed. Please check the configuration."
    fi
    
    exit $exit_code
}

# =============================================================================
# USAGE AND HELP
# =============================================================================

show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo
    echo "Options:"
    echo "  -h, --host HOST        MQTT broker host (default: localhost)"
    echo "  -p, --port PORT        MQTT broker port (default: 1883)"
    echo "  -w, --ws-port PORT     WebSocket port (default: 9001)"
    echo "  -u, --user USER        Test user (default: admin)"
    echo "  -P, --password PASS    Test password"
    echo "  --pv-user USER         PV device user (default: pv_001)"
    echo "  --pv-password PASS     PV device password"
    echo "  --help                 Show this help message"
    echo
    echo "Environment Variables:"
    echo "  MQTT_HOST              MQTT broker host"
    echo "  MQTT_PORT              MQTT broker port"
    echo "  MQTT_WS_PORT           WebSocket port"
    echo "  TEST_USER              Test user"
    echo "  TEST_PASSWORD          Test password"
    echo "  PV_USER                PV device user"
    echo "  PV_PASSWORD            PV device password"
    echo
    echo "Examples:"
    echo "  $0"
    echo "  $0 -h 192.168.1.100 -p 1883"
    echo "  $0 -u admin -P mypassword"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--host)
            MQTT_HOST="$2"
            shift 2
            ;;
        -p|--port)
            MQTT_PORT="$2"
            shift 2
            ;;
        -w|--ws-port)
            MQTT_WS_PORT="$2"
            shift 2
            ;;
        -u|--user)
            TEST_USER="$2"
            shift 2
            ;;
        -P|--password)
            TEST_PASSWORD="$2"
            shift 2
            ;;
        --pv-user)
            PV_USER="$2"
            shift 2
            ;;
        --pv-password)
            PV_PASSWORD="$2"
            shift 2
            ;;
        --help)
            show_usage
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
done

# Run main function
main "$@" 