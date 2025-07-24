#!/bin/bash

# Quick Start Script for Renewable Energy IoT Test Suite
# This script provides easy commands to run the test suite

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}Renewable Energy IoT Monitoring System - Test Suite${NC}"
echo "=================================================="

# Check if main services are running
check_services() {
    echo -e "${YELLOW}Checking if main services are running...${NC}"
    
    # Check if docker-compose is running
    if ! docker-compose ps | grep -q "Up"; then
        echo -e "${YELLOW}Main services are not running. Starting them...${NC}"
        docker-compose up -d
        
        echo -e "${YELLOW}Waiting for services to be ready...${NC}"
        sleep 30
    else
        echo -e "${GREEN}Main services are already running.${NC}"
    fi
}

# Run tests with Docker
run_docker_tests() {
    echo -e "${BLUE}Running tests with Docker...${NC}"
    docker-compose -f docker-compose.test.yml up --build --abort-on-container-exit
}

# Run tests locally
run_local_tests() {
    echo -e "${BLUE}Running tests locally...${NC}"
    
    # Check if Node.js is installed
    if ! command -v node &> /dev/null; then
        echo -e "${YELLOW}Node.js is not installed. Please install Node.js 18+ to run tests locally.${NC}"
        exit 1
    fi
    
    # Install dependencies
    if [ ! -d "node_modules" ]; then
        echo -e "${YELLOW}Installing dependencies...${NC}"
        npm install
    fi
    
    # Run tests
    echo -e "${BLUE}Running JavaScript tests...${NC}"
    npm test
}

# Show help
show_help() {
    echo "Usage: $0 [option]"
    echo ""
    echo "Options:"
    echo "  docker    - Run tests using Docker (recommended)"
    echo "  local     - Run tests locally (requires Node.js)"
    echo "  check     - Check if main services are running"
    echo "  help      - Show this help message"
    echo ""
    echo "Examples:"
    echo "  $0 docker  # Run tests with Docker"
    echo "  $0 local   # Run tests locally"
    echo "  $0 check   # Check service status"
}

# Main script logic
case "${1:-}" in
    "docker")
        check_services
        run_docker_tests
        ;;
    "local")
        run_local_tests
        ;;
    "check")
        check_services
        ;;
    "help"|"-h"|"--help")
        show_help
        ;;
    *)
        echo -e "${YELLOW}No option specified. Running with Docker (recommended)...${NC}"
        check_services
        run_docker_tests
        ;;
esac 