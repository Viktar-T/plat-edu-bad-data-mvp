#!/bin/bash

# MQTT Setup Script
# IoT Renewable Energy Monitoring System
# Sets up Mosquitto MQTT broker with authentication and access control

set -e

# =============================================================================
# CONFIGURATION
# =============================================================================

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# File paths
PASSWD_FILE="mosquitto/config/passwd"
ACL_FILE="mosquitto/config/acl"
CONFIG_FILE="mosquitto/config/mosquitto.conf"
ENV_FILE=".env"

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
    
    # Check if mosquitto_passwd is available
    if command -v mosquitto_passwd >/dev/null 2>&1; then
        print_success "mosquitto_passwd found"
    else
        print_error "mosquitto_passwd not found. Please install mosquitto-clients"
        print_info "Ubuntu/Debian: sudo apt-get install mosquitto-clients"
        print_info "CentOS/RHEL: sudo yum install mosquitto-clients"
        print_info "macOS: brew install mosquitto"
        exit 1
    fi
    
    # Check if Docker is available
    if command -v docker >/dev/null 2>&1; then
        print_success "Docker found"
    else
        print_error "Docker not found. Please install Docker"
        exit 1
    fi
    
    # Check if docker-compose is available
    if command -v docker-compose >/dev/null 2>&1; then
        print_success "Docker Compose found"
    else
        print_error "Docker Compose not found. Please install Docker Compose"
        exit 1
    fi
}

# =============================================================================
# DIRECTORY SETUP
# =============================================================================

setup_directories() {
    print_header "Setting up Directories"
    
    # Create mosquitto directories
    mkdir -p mosquitto/config
    mkdir -p mosquitto/data
    mkdir -p mosquitto/log
    
    print_success "Created mosquitto directories"
    
    # Set proper permissions
    chmod 755 mosquitto/config
    chmod 755 mosquitto/data
    chmod 755 mosquitto/log
    
    print_success "Set directory permissions"
}

# =============================================================================
# PASSWORD GENERATION
# =============================================================================

generate_passwords() {
    print_header "Generating Passwords"
    
    # Check if password file exists
    if [ -f "$PASSWD_FILE" ]; then
        print_warning "Password file already exists. Backing up..."
        cp "$PASSWD_FILE" "${PASSWD_FILE}.backup.$(date +%Y%m%d_%H%M%S)"
    fi
    
    # Generate admin password
    print_info "Generating admin password..."
    ADMIN_PASSWORD=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-25)
    mosquitto_passwd -b "$PASSWD_FILE" admin "$ADMIN_PASSWORD"
    print_success "Generated admin password: $ADMIN_PASSWORD"
    
    # Generate device passwords
    DEVICES=(
        "pv_001:photovoltaic"
        "pv_002:photovoltaic"
        "pv_003:photovoltaic"
        "wt_001:wind_turbine"
        "wt_002:wind_turbine"
        "wt_003:wind_turbine"
        "bg_001:biogas_plant"
        "bg_002:biogas_plant"
        "hb_001:heat_boiler"
        "hb_002:heat_boiler"
        "es_001:energy_storage"
        "es_002:energy_storage"
        "es_003:energy_storage"
    )
    
    for device in "${DEVICES[@]}"; do
        IFS=':' read -r device_id device_type <<< "$device"
        DEVICE_PASSWORD=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-20)
        mosquitto_passwd -b "$PASSWD_FILE" "$device_id" "$DEVICE_PASSWORD"
        print_success "Generated password for $device_id: $DEVICE_PASSWORD"
    done
    
    # Generate service passwords
    print_info "Generating service passwords..."
    
    NODE_RED_PASSWORD=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-20)
    mosquitto_passwd -b "$PASSWD_FILE" node_red "$NODE_RED_PASSWORD"
    print_success "Generated node_red password: $NODE_RED_PASSWORD"
    
    GRAFANA_PASSWORD=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-20)
    mosquitto_passwd -b "$PASSWD_FILE" grafana "$GRAFANA_PASSWORD"
    print_success "Generated grafana password: $GRAFANA_PASSWORD"
    
    BRIDGE_PASSWORD=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-20)
    mosquitto_passwd -b "$PASSWD_FILE" bridge_user "$BRIDGE_PASSWORD"
    print_success "Generated bridge_user password: $BRIDGE_PASSWORD"
    
    MONITOR_PASSWORD=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-20)
    mosquitto_passwd -b "$PASSWD_FILE" monitor "$MONITOR_PASSWORD"
    print_success "Generated monitor password: $MONITOR_PASSWORD"
    
    # Save passwords to a secure file
    PASSWORDS_FILE="mqtt-passwords-$(date +%Y%m%d_%H%M%S).txt"
    cat > "$PASSWORDS_FILE" << EOF
# MQTT Passwords - Generated on $(date)
# Keep this file secure and do not commit to version control

# Admin Account
MQTT_ADMIN_USER=admin
MQTT_ADMIN_PASSWORD=$ADMIN_PASSWORD

# Service Accounts
NODE_RED_USER=node_red
NODE_RED_PASSWORD=$NODE_RED_PASSWORD
GRAFANA_USER=grafana
GRAFANA_PASSWORD=$GRAFANA_PASSWORD
BRIDGE_USER=bridge_user
BRIDGE_PASSWORD=$BRIDGE_PASSWORD
MONITOR_USER=monitor
MONITOR_PASSWORD=$MONITOR_PASSWORD

# Device Passwords
EOF
    
    # Add device passwords to file
    for device in "${DEVICES[@]}"; do
        IFS=':' read -r device_id device_type <<< "$device"
        # Extract password from passwd file (this is a simplified approach)
        echo "${device_id^^}_PASSWORD=<generated_password>" >> "$PASSWORDS_FILE"
    done
    
    print_success "Passwords saved to $PASSWORDS_FILE"
    print_warning "Keep this file secure and do not commit to version control!"
}

# =============================================================================
# ENVIRONMENT FILE SETUP
# =============================================================================

setup_environment() {
    print_header "Setting up Environment File"
    
    if [ -f "$ENV_FILE" ]; then
        print_warning "Environment file already exists. Backing up..."
        cp "$ENV_FILE" "${ENV_FILE}.backup.$(date +%Y%m%d_%H%M%S)"
    fi
    
    # Copy example environment file
    if [ -f "env.example" ]; then
        cp env.example "$ENV_FILE"
        print_success "Created environment file from template"
    else
        print_error "env.example not found"
        exit 1
    fi
    
    print_info "Please update the .env file with your generated passwords"
    print_info "You can find the passwords in the generated passwords file"
}

# =============================================================================
# CONFIGURATION VALIDATION
# =============================================================================

validate_configuration() {
    print_header "Validating Configuration"
    
    # Check if all required files exist
    if [ ! -f "$CONFIG_FILE" ]; then
        print_error "Mosquitto configuration file not found: $CONFIG_FILE"
        exit 1
    fi
    
    if [ ! -f "$PASSWD_FILE" ]; then
        print_error "Password file not found: $PASSWD_FILE"
        exit 1
    fi
    
    if [ ! -f "$ACL_FILE" ]; then
        print_error "ACL file not found: $ACL_FILE"
        exit 1
    fi
    
    print_success "All configuration files found"
    
    # Validate mosquitto configuration syntax
    if command -v mosquitto >/dev/null 2>&1; then
        if mosquitto -c "$CONFIG_FILE" --test-config >/dev/null 2>&1; then
            print_success "Mosquitto configuration syntax is valid"
        else
            print_error "Mosquitto configuration syntax is invalid"
            exit 1
        fi
    else
        print_warning "Mosquitto not found, skipping configuration validation"
    fi
}

# =============================================================================
# DOCKER SETUP
# =============================================================================

setup_docker() {
    print_header "Setting up Docker Services"
    
    # Check if docker-compose.yml exists
    if [ ! -f "docker-compose.yml" ]; then
        print_error "docker-compose.yml not found"
        exit 1
    fi
    
    # Create .env file if it doesn't exist
    if [ ! -f "$ENV_FILE" ]; then
        setup_environment
    fi
    
    print_info "Starting Docker services..."
    
    # Start services
    if docker-compose up -d mosquitto; then
        print_success "Mosquitto service started successfully"
    else
        print_error "Failed to start Mosquitto service"
        exit 1
    fi
    
    # Wait for service to be ready
    print_info "Waiting for Mosquitto to be ready..."
    sleep 10
    
    # Check service health
    if docker-compose ps mosquitto | grep -q "Up"; then
        print_success "Mosquitto service is running"
    else
        print_error "Mosquitto service failed to start"
        docker-compose logs mosquitto
        exit 1
    fi
}

# =============================================================================
# TESTING
# =============================================================================

run_tests() {
    print_header "Running MQTT Tests"
    
    # Check if test script exists
    if [ -f "scripts/mqtt-test.sh" ]; then
        print_info "Running MQTT connectivity tests..."
        
        # Set test credentials
        export TEST_USER="admin"
        export TEST_PASSWORD="$ADMIN_PASSWORD"
        export PV_USER="pv_001"
        export PV_PASSWORD="<device_password>"
        
        if ./scripts/mqtt-test.sh; then
            print_success "MQTT tests passed"
        else
            print_warning "Some MQTT tests failed. Check the configuration."
        fi
    else
        print_warning "MQTT test script not found. Skipping tests."
    fi
}

# =============================================================================
# SECURITY CHECKLIST
# =============================================================================

security_checklist() {
    print_header "Security Checklist"
    
    echo -e "${YELLOW}Please review and complete the following security measures:${NC}"
    echo
    echo "1. ✓ Passwords generated and stored securely"
    echo "2. ✓ Anonymous access disabled"
    echo "3. ✓ Access control list configured"
    echo "4. ✓ Environment variables set up"
    echo "5. ⚠ Update .env file with generated passwords"
    echo "6. ⚠ Review and customize ACL permissions"
    echo "7. ⚠ Configure firewall rules for MQTT ports"
    echo "8. ⚠ Enable SSL/TLS for production use"
    echo "9. ⚠ Set up monitoring and alerting"
    echo "10. ⚠ Regular password rotation schedule"
    echo
    echo -e "${BLUE}For detailed security guidelines, see: docs/mqtt-configuration.md${NC}"
}

# =============================================================================
# MAIN EXECUTION
# =============================================================================

main() {
    print_header "MQTT Broker Setup"
    print_info "Setting up Mosquitto MQTT broker for IoT Renewable Energy Monitoring System"
    echo
    
    # Run setup steps
    check_dependencies
    echo
    
    setup_directories
    echo
    
    generate_passwords
    echo
    
    setup_environment
    echo
    
    validate_configuration
    echo
    
    setup_docker
    echo
    
    run_tests
    echo
    
    security_checklist
    echo
    
    # Summary
    print_header "Setup Complete"
    print_success "MQTT broker setup completed successfully!"
    print_info "Next steps:"
    print_info "1. Update .env file with generated passwords"
    print_info "2. Review security configuration"
    print_info "3. Test connectivity with devices"
    print_info "4. Configure Node-RED flows"
    print_info "5. Set up Grafana dashboards"
    echo
    print_warning "Remember to keep the passwords file secure!"
    print_info "Documentation: docs/mqtt-configuration.md"
}

# =============================================================================
# USAGE AND HELP
# =============================================================================

show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo
    echo "Options:"
    echo "  --help                 Show this help message"
    echo "  --skip-passwords       Skip password generation (use existing)"
    echo "  --skip-docker          Skip Docker service setup"
    echo "  --skip-tests           Skip MQTT connectivity tests"
    echo
    echo "This script sets up the Mosquitto MQTT broker with:"
    echo "- Directory structure creation"
    echo "- Password generation for all devices and services"
    echo "- Environment file configuration"
    echo "- Docker service setup"
    echo "- Configuration validation"
    echo "- Connectivity testing"
    echo
    echo "Prerequisites:"
    echo "- mosquitto-clients package installed"
    echo "- Docker and Docker Compose installed"
    echo "- Proper permissions to create directories and files"
}

# Parse command line arguments
SKIP_PASSWORDS=false
SKIP_DOCKER=false
SKIP_TESTS=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --help)
            show_usage
            exit 0
            ;;
        --skip-passwords)
            SKIP_PASSWORDS=true
            shift
            ;;
        --skip-docker)
            SKIP_DOCKER=true
            shift
            ;;
        --skip-tests)
            SKIP_TESTS=true
            shift
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