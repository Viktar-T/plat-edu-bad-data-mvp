#!/bin/bash

# IoT Renewable Energy Monitoring System - Device Simulation Script
# This script simulates realistic data from renewable energy devices

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

# Configuration
MQTT_BROKER="localhost"
MQTT_PORT="1883"
SIMULATION_INTERVAL=${SIMULATION_INTERVAL:-5000}  # milliseconds
DEVICE_COUNT=${DEVICE_COUNT:-10}

# Device configurations
PHOTOVOLTAIC_COUNT=${PHOTOVOLTAIC_COUNT:-3}
WIND_TURBINE_COUNT=${WIND_TURBINE_COUNT:-2}
BIOGAS_PLANT_COUNT=${BIOGAS_PLANT_COUNT:-2}
HEAT_BOILER_COUNT=${HEAT_BOILER_COUNT:-2}
ENERGY_STORAGE_COUNT=${ENERGY_STORAGE_COUNT:-1}

# Simulation parameters
NOISE_LEVEL=${NOISE_LEVEL:-0.05}
FAULT_PROBABILITY=${FAULT_PROBABILITY:-0.01}
SEASONAL_VARIATION=${SEASONAL_VARIATION:-true}

# Function to generate random number with noise
add_noise() {
    local value=$1
    local noise=$(echo "$RANDOM / 32767 * $NOISE_LEVEL * 2 - $NOISE_LEVEL" | bc -l)
    echo "$value + $noise" | bc -l
}

# Function to generate seasonal variation
get_seasonal_factor() {
    local hour=$(date +%H | sed 's/^0*//')
    local day_of_year=$(date +%j | sed 's/^0*//')
    
    # Solar seasonal variation (higher in summer, lower in winter)
    local solar_factor=$(echo "0.5 + 0.5 * s(($day_of_year - 172) * 2 * 3.14159 / 365)" | bc -l)
    
    # Daily variation (higher during day, lower at night)
    local daily_factor=0
    if [ $hour -ge 6 ] && [ $hour -le 18 ]; then
        daily_factor=$(echo "0.3 + 0.7 * s(($hour - 6) * 3.14159 / 12)" | bc -l)
    fi
    
    echo "$solar_factor * $daily_factor" | bc -l
}

# Function to simulate photovoltaic panel data
simulate_photovoltaic() {
    local device_id=$1
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    
    # Base irradiance (W/m²)
    local base_irradiance=1000
    local seasonal_factor=$(get_seasonal_factor)
    local irradiance=$(echo "$base_irradiance * $seasonal_factor" | bc -l)
    irradiance=$(add_noise $irradiance)
    
    # Temperature (°C) - varies with irradiance
    local base_temp=25
    local temp_factor=$(echo "$irradiance / 1000" | bc -l)
    local temperature=$(echo "$base_temp + $temp_factor * 20" | bc -l)
    temperature=$(add_noise $temperature)
    
    # Panel efficiency (15-22%)
    local efficiency=$(echo "0.15 + $RANDOM / 32767 * 0.07" | bc -l)
    
    # Voltage (V) - varies with temperature
    local voltage=$(echo "48 - ($temperature - 25) * 0.003" | bc -l)
    voltage=$(add_noise $voltage)
    
    # Current (A) - depends on irradiance and efficiency
    local current=$(echo "$irradiance * 0.1 * $efficiency" | bc -l)
    current=$(add_noise $current)
    
    # Power output (W)
    local power_output=$(echo "$voltage * $current" | bc -l)
    
    # Status
    local status="operational"
    if (( $(echo "$RANDOM / 32767 < $FAULT_PROBABILITY" | bc -l) )); then
        status="fault"
        power_output=$(echo "$power_output * 0.1" | bc -l)
    fi
    
    # Create JSON payload
    local payload=$(cat <<EOF
{
  "device_id": "pv_${device_id}",
  "device_type": "photovoltaic",
  "timestamp": "$timestamp",
  "data": {
    "irradiance": $(printf "%.2f" $irradiance),
    "temperature": $(printf "%.2f" $temperature),
    "voltage": $(printf "%.2f" $voltage),
    "current": $(printf "%.2f" $current),
    "power_output": $(printf "%.2f" $power_output),
    "efficiency": $(printf "%.3f" $efficiency)
  },
  "status": "$status",
  "location": "site_a"
}
EOF
)
    
    # Publish to MQTT
    mosquitto_pub -h $MQTT_BROKER -p $MQTT_PORT -t "devices/photovoltaic/pv_${device_id}/telemetry" -m "$payload"
    
    echo "Published photovoltaic data for pv_${device_id}: $(printf "%.2f" $power_output)W"
}

# Function to simulate wind turbine data
simulate_wind_turbine() {
    local device_id=$1
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    
    # Wind speed (m/s) - varies throughout the day
    local hour=$(date +%H | sed 's/^0*//')
    local base_wind_speed=8
    local wind_variation=$(echo "s($hour * 3.14159 / 12) * 3" | bc -l)
    local wind_speed=$(echo "$base_wind_speed + $wind_variation" | bc -l)
    wind_speed=$(add_noise $wind_speed)
    
    # Wind direction (degrees)
    local wind_direction=$(echo "$RANDOM / 32767 * 360" | bc -l)
    
    # Rotor speed (RPM) - depends on wind speed
    local rotor_speed=$(echo "$wind_speed * 15" | bc -l)
    rotor_speed=$(add_noise $rotor_speed)
    
    # Temperature (°C)
    local temperature=$(echo "20 + $RANDOM / 32767 * 20 - 10" | bc -l)
    
    # Power output (kW) - wind turbine power curve
    local power_output=0
    if (( $(echo "$wind_speed >= 3" | bc -l) )); then
        if (( $(echo "$wind_speed <= 12" | bc -l) )); then
            power_output=$(echo "($wind_speed - 3) * 100" | bc -l)
        else
            power_output=900  # Rated power
        fi
    fi
    power_output=$(add_noise $power_output)
    
    # Status
    local status="operational"
    if (( $(echo "$RANDOM / 32767 < $FAULT_PROBABILITY" | bc -l) )); then
        status="fault"
        power_output=$(echo "$power_output * 0.1" | bc -l)
    fi
    
    # Create JSON payload
    local payload=$(cat <<EOF
{
  "device_id": "wt_${device_id}",
  "device_type": "wind_turbine",
  "timestamp": "$timestamp",
  "data": {
    "wind_speed": $(printf "%.2f" $wind_speed),
    "wind_direction": $(printf "%.2f" $wind_direction),
    "rotor_speed": $(printf "%.2f" $rotor_speed),
    "power_output": $(printf "%.2f" $power_output),
    "temperature": $(printf "%.2f" $temperature)
  },
  "status": "$status",
  "location": "site_b"
}
EOF
)
    
    # Publish to MQTT
    mosquitto_pub -h $MQTT_BROKER -p $MQTT_PORT -t "devices/wind_turbine/wt_${device_id}/telemetry" -m "$payload"
    
    echo "Published wind turbine data for wt_${device_id}: $(printf "%.2f" $power_output)kW"
}

# Function to simulate biogas plant data
simulate_biogas_plant() {
    local device_id=$1
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    
    # Gas flow rate (m³/h)
    local base_flow_rate=50
    local flow_variation=$(echo "$RANDOM / 32767 * 20 - 10" | bc -l)
    local gas_flow_rate=$(echo "$base_flow_rate + $flow_variation" | bc -l)
    gas_flow_rate=$(add_noise $gas_flow_rate)
    
    # Methane concentration (%)
    local methane_concentration=$(echo "55 + $RANDOM / 32767 * 15" | bc -l)
    methane_concentration=$(add_noise $methane_concentration)
    
    # Temperature (°C)
    local temperature=$(echo "35 + $RANDOM / 32767 * 10" | bc -l)
    
    # Pressure (bar)
    local pressure=$(echo "1.2 + $RANDOM / 32767 * 0.3" | bc -l)
    pressure=$(add_noise $pressure)
    
    # Power output (kW) - depends on gas flow and methane content
    local power_output=$(echo "$gas_flow_rate * $methane_concentration * 0.01" | bc -l)
    power_output=$(add_noise $power_output)
    
    # Status
    local status="operational"
    if (( $(echo "$RANDOM / 32767 < $FAULT_PROBABILITY" | bc -l) )); then
        status="fault"
        power_output=$(echo "$power_output * 0.1" | bc -l)
    fi
    
    # Create JSON payload
    local payload=$(cat <<EOF
{
  "device_id": "bg_${device_id}",
  "device_type": "biogas_plant",
  "timestamp": "$timestamp",
  "data": {
    "gas_flow_rate": $(printf "%.2f" $gas_flow_rate),
    "methane_concentration": $(printf "%.2f" $methane_concentration),
    "temperature": $(printf "%.2f" $temperature),
    "pressure": $(printf "%.2f" $pressure),
    "power_output": $(printf "%.2f" $power_output)
  },
  "status": "$status",
  "location": "site_c"
}
EOF
)
    
    # Publish to MQTT
    mosquitto_pub -h $MQTT_BROKER -p $MQTT_PORT -t "devices/biogas_plant/bg_${device_id}/telemetry" -m "$payload"
    
    echo "Published biogas plant data for bg_${device_id}: $(printf "%.2f" $power_output)kW"
}

# Function to simulate heat boiler data
simulate_heat_boiler() {
    local device_id=$1
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    
    # Temperature (°C)
    local temperature=$(echo "80 + $RANDOM / 32767 * 20" | bc -l)
    temperature=$(add_noise $temperature)
    
    # Pressure (bar)
    local pressure=$(echo "2.5 + $RANDOM / 32767 * 0.5" | bc -l)
    pressure=$(add_noise $pressure)
    
    # Fuel consumption (kg/h)
    local fuel_consumption=$(echo "100 + $RANDOM / 32767 * 50" | bc -l)
    fuel_consumption=$(add_noise $fuel_consumption)
    
    # Efficiency (%)
    local efficiency=$(echo "85 + $RANDOM / 32767 * 10" | bc -l)
    efficiency=$(add_noise $efficiency)
    
    # Heat output (kW)
    local heat_output=$(echo "$fuel_consumption * $efficiency * 0.01" | bc -l)
    heat_output=$(add_noise $heat_output)
    
    # Status
    local status="operational"
    if (( $(echo "$RANDOM / 32767 < $FAULT_PROBABILITY" | bc -l) )); then
        status="fault"
        heat_output=$(echo "$heat_output * 0.1" | bc -l)
    fi
    
    # Create JSON payload
    local payload=$(cat <<EOF
{
  "device_id": "hb_${device_id}",
  "device_type": "heat_boiler",
  "timestamp": "$timestamp",
  "data": {
    "temperature": $(printf "%.2f" $temperature),
    "pressure": $(printf "%.2f" $pressure),
    "fuel_consumption": $(printf "%.2f" $fuel_consumption),
    "efficiency": $(printf "%.2f" $efficiency),
    "heat_output": $(printf "%.2f" $heat_output)
  },
  "status": "$status",
  "location": "site_d"
}
EOF
)
    
    # Publish to MQTT
    mosquitto_pub -h $MQTT_BROKER -p $MQTT_PORT -t "devices/heat_boiler/hb_${device_id}/telemetry" -m "$payload"
    
    echo "Published heat boiler data for hb_${device_id}: $(printf "%.2f" $heat_output)kW"
}

# Function to simulate energy storage data
simulate_energy_storage() {
    local device_id=$1
    local timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
    
    # State of charge (%)
    local base_soc=60
    local soc_variation=$(echo "$RANDOM / 32767 * 20 - 10" | bc -l)
    local state_of_charge=$(echo "$base_soc + $soc_variation" | bc -l)
    state_of_charge=$(add_noise $state_of_charge)
    
    # Voltage (V)
    local voltage=$(echo "400 + $state_of_charge * 2" | bc -l)
    voltage=$(add_noise $voltage)
    
    # Current (A) - positive for charging, negative for discharging
    local current=$(echo "$RANDOM / 32767 * 100 - 50" | bc -l)
    current=$(add_noise $current)
    
    # Temperature (°C)
    local temperature=$(echo "25 + $RANDOM / 32767 * 10" | bc -l)
    
    # Cycle count
    local cycle_count=$(echo "$RANDOM / 32767 * 1000" | bc -l | cut -d. -f1)
    
    # Power (kW) - positive for charging, negative for discharging
    local power=$(echo "$voltage * $current / 1000" | bc -l)
    
    # Status
    local status="operational"
    if (( $(echo "$RANDOM / 32767 < $FAULT_PROBABILITY" | bc -l) )); then
        status="fault"
        power=$(echo "$power * 0.1" | bc -l)
    fi
    
    # Create JSON payload
    local payload=$(cat <<EOF
{
  "device_id": "es_${device_id}",
  "device_type": "energy_storage",
  "timestamp": "$timestamp",
  "data": {
    "state_of_charge": $(printf "%.2f" $state_of_charge),
    "voltage": $(printf "%.2f" $voltage),
    "current": $(printf "%.2f" $current),
    "temperature": $(printf "%.2f" $temperature),
    "cycle_count": $cycle_count,
    "power": $(printf "%.2f" $power)
  },
  "status": "$status",
  "location": "site_e"
}
EOF
)
    
    # Publish to MQTT
    mosquitto_pub -h $MQTT_BROKER -p $MQTT_PORT -t "devices/energy_storage/es_${device_id}/telemetry" -m "$payload"
    
    echo "Published energy storage data for es_${device_id}: $(printf "%.2f" $power)kW, SOC: $(printf "%.1f" $state_of_charge)%"
}

# Function to check MQTT connectivity
check_mqtt() {
    print_status "Checking MQTT connectivity..."
    if ! mosquitto_pub -h $MQTT_BROKER -p $MQTT_PORT -t "test/connectivity" -m "test" > /dev/null 2>&1; then
        print_error "Cannot connect to MQTT broker at $MQTT_BROKER:$MQTT_PORT"
        print_error "Please ensure the MQTT broker is running"
        exit 1
    fi
    print_success "MQTT connectivity OK"
}

# Function to simulate all devices
simulate_all_devices() {
    print_status "Starting device simulation..."
    print_status "Simulation interval: ${SIMULATION_INTERVAL}ms"
    print_status "Device count: $DEVICE_COUNT"
    print_status "Press Ctrl+C to stop simulation"
    echo ""
    
    while true; do
        # Simulate photovoltaic panels
        for i in $(seq 1 $PHOTOVOLTAIC_COUNT); do
            simulate_photovoltaic $i &
        done
        
        # Simulate wind turbines
        for i in $(seq 1 $WIND_TURBINE_COUNT); do
            simulate_wind_turbine $i &
        done
        
        # Simulate biogas plants
        for i in $(seq 1 $BIOGAS_PLANT_COUNT); do
            simulate_biogas_plant $i &
        done
        
        # Simulate heat boilers
        for i in $(seq 1 $HEAT_BOILER_COUNT); do
            simulate_heat_boiler $i &
        done
        
        # Simulate energy storage
        for i in $(seq 1 $ENERGY_STORAGE_COUNT); do
            simulate_energy_storage $i &
        done
        
        # Wait for all background processes
        wait
        
        # Wait for next simulation cycle
        sleep $(echo "$SIMULATION_INTERVAL / 1000" | bc -l)
    done
}

# Function to show help
show_help() {
    echo "IoT Renewable Energy Monitoring System - Device Simulation"
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -h, --help              Show this help message"
    echo "  -i, --interval MS       Set simulation interval in milliseconds (default: 5000)"
    echo "  -c, --count NUM         Set total device count (default: 10)"
    echo "  -p, --photovoltaic NUM  Set photovoltaic panel count (default: 3)"
    echo "  -w, --wind NUM          Set wind turbine count (default: 2)"
    echo "  -b, --biogas NUM        Set biogas plant count (default: 2)"
    echo "  -t, --heat NUM          Set heat boiler count (default: 2)"
    echo "  -e, --storage NUM       Set energy storage count (default: 1)"
    echo "  -n, --noise LEVEL       Set noise level (default: 0.05)"
    echo "  -f, --fault PROB        Set fault probability (default: 0.01)"
    echo "  --no-seasonal           Disable seasonal variation"
    echo ""
    echo "Environment variables:"
    echo "  MQTT_BROKER             MQTT broker hostname (default: localhost)"
    echo "  MQTT_PORT               MQTT broker port (default: 1883)"
    echo ""
    echo "Examples:"
    echo "  $0                      # Start with default settings"
    echo "  $0 -i 2000 -c 20        # Fast simulation with 20 devices"
    echo "  $0 -p 5 -w 3 -b 2       # Custom device mix"
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -i|--interval)
            SIMULATION_INTERVAL="$2"
            shift 2
            ;;
        -c|--count)
            DEVICE_COUNT="$2"
            shift 2
            ;;
        -p|--photovoltaic)
            PHOTOVOLTAIC_COUNT="$2"
            shift 2
            ;;
        -w|--wind)
            WIND_TURBINE_COUNT="$2"
            shift 2
            ;;
        -b|--biogas)
            BIOGAS_PLANT_COUNT="$2"
            shift 2
            ;;
        -t|--heat)
            HEAT_BOILER_COUNT="$2"
            shift 2
            ;;
        -e|--storage)
            ENERGY_STORAGE_COUNT="$2"
            shift 2
            ;;
        -n|--noise)
            NOISE_LEVEL="$2"
            shift 2
            ;;
        -f|--fault)
            FAULT_PROBABILITY="$2"
            shift 2
            ;;
        --no-seasonal)
            SEASONAL_VARIATION=false
            shift
            ;;
        *)
            print_error "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
done

# Main execution
main() {
    echo "=========================================="
    echo "IoT Renewable Energy Monitoring System"
    echo "Device Simulation Script"
    echo "=========================================="
    echo ""
    
    # Check prerequisites
    if ! command -v mosquitto_pub &> /dev/null; then
        print_error "mosquitto_pub is not installed. Please install mosquitto-clients."
        exit 1
    fi
    
    if ! command -v bc &> /dev/null; then
        print_error "bc is not installed. Please install bc."
        exit 1
    fi
    
    # Check MQTT connectivity
    check_mqtt
    
    # Show configuration
    print_status "Configuration:"
    echo "  MQTT Broker:     $MQTT_BROKER:$MQTT_PORT"
    echo "  Simulation interval: ${SIMULATION_INTERVAL}ms"
    echo "  Photovoltaic panels: $PHOTOVOLTAIC_COUNT"
    echo "  Wind turbines:       $WIND_TURBINE_COUNT"
    echo "  Biogas plants:       $BIOGAS_PLANT_COUNT"
    echo "  Heat boilers:        $HEAT_BOILER_COUNT"
    echo "  Energy storage:      $ENERGY_STORAGE_COUNT"
    echo "  Noise level:         $NOISE_LEVEL"
    echo "  Fault probability:   $FAULT_PROBABILITY"
    echo "  Seasonal variation:  $SEASONAL_VARIATION"
    echo ""
    
    # Start simulation
    simulate_all_devices
}

# Run main function
main "$@" 