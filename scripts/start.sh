#!/bin/bash

# IoT Renewable Energy Monitoring System - Startup Script
# This script starts all services and performs health checks

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if Docker is running
check_docker() {
    print_status "Checking Docker status..."
    if ! docker info > /dev/null 2>&1; then
        print_error "Docker is not running. Please start Docker Desktop first."
        exit 1
    fi
    print_success "Docker is running"
}

# Function to check if Docker Compose is available
check_docker_compose() {
    print_status "Checking Docker Compose..."
    if ! docker compose version > /dev/null 2>&1; then
        print_error "Docker Compose is not available. Please install Docker Compose."
        exit 1
    fi
    print_success "Docker Compose is available"
}

# Function to check environment file
check_env_file() {
    print_status "Checking environment configuration..."
    if [ ! -f ".env" ]; then
        print_warning "Environment file .env not found. Creating from template..."
        if [ -f "env.example" ]; then
            cp env.example .env
            print_success "Environment file created from template"
            print_warning "Please review and update .env file with your specific settings"
        else
            print_error "env.example template not found"
            exit 1
        fi
    else
        print_success "Environment file found"
    fi
}

# Function to create necessary directories
create_directories() {
    print_status "Creating necessary directories..."
    
    # Create service directories
    mkdir -p mosquitto/{config,data,log}
    mkdir -p influxdb/{data,config,scripts}
    mkdir -p node-red/{data,flows}
    mkdir -p grafana/{data,provisioning,dashboards,plugins}
    mkdir -p scripts/logs
    mkdir -p backups
    
    print_success "Directories created"
}

# Function to start services
start_services() {
    print_status "Starting IoT monitoring services..."
    
    # Pull latest images
    print_status "Pulling latest Docker images..."
    docker compose pull
    
    # Start services in background
    print_status "Starting services..."
    docker compose up -d
    
    print_success "Services started"
}

# Function to wait for services to be ready
wait_for_services() {
    print_status "Waiting for services to be ready..."
    
    # Wait for Mosquitto
    print_status "Waiting for MQTT broker (Mosquitto)..."
    timeout=60
    counter=0
    while ! docker compose exec mosquitto mosquitto_pub -h localhost -t "health/check" -m "ping" > /dev/null 2>&1; do
        sleep 2
        counter=$((counter + 2))
        if [ $counter -ge $timeout ]; then
            print_error "Timeout waiting for MQTT broker"
            exit 1
        fi
    done
    print_success "MQTT broker is ready"
    
    # Wait for InfluxDB
    print_status "Waiting for InfluxDB..."
    timeout=60
    counter=0
    while ! curl -f http://localhost:8086/health > /dev/null 2>&1; do
        sleep 2
        counter=$((counter + 2))
        if [ $counter -ge $timeout ]; then
            print_error "Timeout waiting for InfluxDB"
            exit 1
        fi
    done
    print_success "InfluxDB is ready"
    
    # Wait for Node-RED
    print_status "Waiting for Node-RED..."
    timeout=60
    counter=0
    while ! curl -f http://localhost:1880/health > /dev/null 2>&1; do
        sleep 2
        counter=$((counter + 2))
        if [ $counter -ge $timeout ]; then
            print_error "Timeout waiting for Node-RED"
            exit 1
        fi
    done
    print_success "Node-RED is ready"
    
    # Wait for Grafana
    print_status "Waiting for Grafana..."
    timeout=60
    counter=0
    while ! curl -f http://localhost:3000/api/health > /dev/null 2>&1; do
        sleep 2
        counter=$((counter + 2))
        if [ $counter -ge $timeout ]; then
            print_error "Timeout waiting for Grafana"
            exit 1
        fi
    done
    print_success "Grafana is ready"
}

# Function to display service status
show_status() {
    print_status "Service Status:"
    docker compose ps
    
    echo ""
    print_status "Service URLs:"
    echo "  MQTT Broker:     localhost:1883"
    echo "  MQTT WebSocket:  localhost:9001"
    echo "  InfluxDB:        http://localhost:8086"
    echo "  Node-RED:        http://localhost:1880"
    echo "  Grafana:         http://localhost:3000"
    echo ""
    print_status "Default Credentials:"
    echo "  Node-RED:        admin / adminpassword"
    echo "  Grafana:         admin / admin"
    echo "  InfluxDB:        admin / adminpassword"
}

# Function to run health checks
run_health_checks() {
    print_status "Running health checks..."
    
    # Check MQTT connectivity
    if docker compose exec mosquitto mosquitto_pub -h localhost -t "test/health" -m "test" > /dev/null 2>&1; then
        print_success "MQTT connectivity: OK"
    else
        print_error "MQTT connectivity: FAILED"
    fi
    
    # Check InfluxDB connectivity
    if curl -f http://localhost:8086/health > /dev/null 2>&1; then
        print_success "InfluxDB connectivity: OK"
    else
        print_error "InfluxDB connectivity: FAILED"
    fi
    
    # Check Node-RED connectivity
    if curl -f http://localhost:1880/health > /dev/null 2>&1; then
        print_success "Node-RED connectivity: OK"
    else
        print_error "Node-RED connectivity: FAILED"
    fi
    
    # Check Grafana connectivity
    if curl -f http://localhost:3000/api/health > /dev/null 2>&1; then
        print_success "Grafana connectivity: OK"
    else
        print_error "Grafana connectivity: FAILED"
    fi
}

# Function to setup initial data
setup_initial_data() {
    print_status "Setting up initial data..."
    
    # Create InfluxDB organization and bucket if they don't exist
    print_status "Setting up InfluxDB..."
    docker compose exec influxdb influx setup \
        --username admin \
        --password adminpassword \
        --org renewable_energy \
        --bucket iot_data \
        --retention 30d \
        --token your-super-secret-auth-token \
        --force
    
    print_success "Initial data setup completed"
}

# Main execution
main() {
    echo "=========================================="
    echo "IoT Renewable Energy Monitoring System"
    echo "Startup Script"
    echo "=========================================="
    echo ""
    
    # Check prerequisites
    check_docker
    check_docker_compose
    check_env_file
    
    # Create directories
    create_directories
    
    # Start services
    start_services
    
    # Wait for services
    wait_for_services
    
    # Setup initial data
    setup_initial_data
    
    # Run health checks
    run_health_checks
    
    # Show status
    show_status
    
    echo ""
    print_success "IoT monitoring system started successfully!"
    echo ""
    print_status "Next steps:"
    echo "  1. Access Node-RED at http://localhost:1880"
    echo "  2. Import flows from node-red/flows/"
    echo "  3. Access Grafana at http://localhost:3000"
    echo "  4. Configure data sources and dashboards"
    echo "  5. Start device simulation with: ./scripts/simulate-devices.sh"
    echo ""
}

# Run main function
main "$@" 