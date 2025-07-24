# Device Simulation Testing (Phase 2 - Python)

## Objective
Implement Python-based device simulation tests for renewable energy devices (photovoltaic panels, wind turbines, biogas plants, heat boilers, energy storage systems) in the IoT monitoring system MVP.

## Context
This is Phase 2 of our incremental testing approach. We're using Python for complex mathematical modeling and device simulation validation, building on the JavaScript foundation from Phase 1.

## Scope
- Device simulation mathematical models validation
- Data generation patterns and realism testing
- Time-based variations (daily, seasonal cycles)
- Fault scenario simulation and testing
- Data range validation and constraints
- Simulation performance and scalability

## Approach
**Language**: Python
**Framework**: Mathematical modeling libraries, statistical validation
**Containerization**: Docker with Python environment
**Focus**: Simulation accuracy and realistic data generation

## Success Criteria
- Generated data follows realistic renewable energy patterns
- Mathematical models accurately represent device behavior
- Time-based variations are properly implemented
- Fault scenarios are realistically simulated
- Data ranges are within expected bounds
- Simulation performance meets real-time requirements
- Generated data passes validation checks

## Implementation Strategy

### Test Structure
```
tests/python/device-simulation/
├── photovoltaic.test.py       # Solar panel simulation tests
├── wind_turbine.test.py       # Wind turbine simulation tests
├── energy_storage.test.py     # Energy storage simulation tests
├── mathematical_models.test.py # Mathematical model validation
├── data_patterns.test.py      # Data pattern validation
└── utils/
    ├── simulation_helpers.py  # Simulation utilities
    └── data_validators.py     # Data validation utilities
```

### Core Test Components

#### 1. Photovoltaic Simulation (`photovoltaic.test.py`)
```python
# Test solar panel simulation
class TestPhotovoltaicSimulation:
    def test_power_output_calculation(self):
        """Test photovoltaic power output calculation"""
        # Power output = Irradiance * Area * Efficiency * Temperature_factor
        pass
    
    def test_daily_cycle_pattern(self):
        """Test daily solar cycle patterns"""
        # Sunrise, peak, sunset patterns
        pass
    
    def test_seasonal_variations(self):
        """Test seasonal variations in solar output"""
        # Summer vs winter patterns
        pass
```

#### 2. Wind Turbine Simulation (`wind_turbine.test.py`)
```python
# Test wind turbine simulation
class TestWindTurbineSimulation:
    def test_power_curve_validation(self):
        """Test wind turbine power curve"""
        # Power curve based on wind speed
        pass
    
    def test_wind_speed_distribution(self):
        """Test realistic wind speed patterns"""
        # Weibull distribution validation
        pass
    
    def test_turbine_efficiency(self):
        """Test turbine efficiency calculations"""
        # Betz limit and real-world efficiency
        pass
```

#### 3. Mathematical Models (`mathematical_models.test.py`)
```python
# Test mathematical model accuracy
class TestMathematicalModels:
    def test_photovoltaic_model(self):
        """Test PV mathematical model accuracy"""
        # Validate against known formulas
        pass
    
    def test_wind_turbine_model(self):
        """Test wind turbine mathematical model"""
        # Power curve validation
        pass
    
    def test_energy_storage_model(self):
        """Test battery storage model"""
        # State of charge calculations
        pass
```

### Test Data Configuration

#### Simulation Parameters
```python
# Realistic simulation parameters
SIMULATION_CONFIG = {
    "photovoltaic": {
        "panel_area": 1.6,  # m²
        "efficiency": 0.18,  # 18%
        "temperature_coefficient": -0.004,  # per °C
        "nominal_power": 300,  # W
        "location": {
            "latitude": 52.3676,
            "longitude": 4.9041,
            "timezone": "Europe/Amsterdam"
        }
    },
    "wind_turbine": {
        "rated_power": 2000,  # kW
        "rotor_diameter": 90,  # m
        "hub_height": 80,  # m
        "cut_in_speed": 3,  # m/s
        "rated_speed": 12,  # m/s
        "cut_out_speed": 25  # m/s
    },
    "energy_storage": {
        "capacity": 100,  # kWh
        "max_power": 50,  # kW
        "efficiency": 0.95,  # 95%
        "depth_of_discharge": 0.9  # 90%
    }
}
```

### Docker Integration

#### Python Test Configuration
```python
# config/simulation-test-config.json
{
  "simulation": {
    "timeframe": {
      "start": "2024-01-01T00:00:00Z",
      "end": "2024-01-31T23:59:59Z",
      "interval": "5m"
    },
    "devices": {
      "photovoltaic": ["pv_001", "pv_002", "pv_003"],
      "wind_turbine": ["wt_001", "wt_002"],
      "energy_storage": ["es_001"]
    },
    "weather_data": {
      "source": "synthetic",
      "location": "test_site"
    }
  },
  "validation": {
    "data_ranges": {
      "photovoltaic": {
        "power_output": [0, 300],
        "efficiency": [0.15, 0.22],
        "temperature": [-10, 80]
      },
      "wind_turbine": {
        "power_output": [0, 2000],
        "wind_speed": [0, 30],
        "efficiency": [0.3, 0.5]
      }
    }
  }
}
```

### Test Execution

#### Pytest Configuration
```python
# pytest.ini
[tool:pytest]
testpaths = tests/python/device-simulation
python_files = test_*.py
python_classes = Test*
python_functions = test_*
addopts = 
    -v
    --tb=short
    --strict-markers
    --disable-warnings
markers =
    slow: marks tests as slow (deselect with '-m "not slow"')
    integration: marks tests as integration tests
```

#### Test Setup
```python
# tests/python/utils/simulation_setup.py
import pytest
import numpy as np

@pytest.fixture
def simulation_environment():
    """Setup simulation test environment"""
    # Setup simulation environment
    yield
    # Cleanup simulation environment

@pytest.fixture
def test_data_generator():
    """Generate test data for simulations"""
    return TestDataGenerator()
```

## Test Scenarios

### 1. Mathematical Model Validation
- Test photovoltaic power calculation accuracy
- Validate wind turbine power curve
- Test energy storage state of charge
- Verify efficiency calculations

### 2. Data Pattern Validation
- Daily solar cycle patterns
- Wind speed distribution patterns
- Seasonal variations
- Realistic noise and fluctuations

### 3. Time-based Variations
- Daily cycles (sunrise, peak, sunset)
- Seasonal variations (summer/winter)
- Weather pattern integration
- Time zone handling

### 4. Fault Scenario Testing
- Panel degradation over time
- Wind turbine maintenance scenarios
- Battery aging effects
- Sensor failure simulation

### 5. Data Range Validation
- Power output within realistic bounds
- Efficiency within expected ranges
- Temperature and environmental limits
- Physical constraint validation

### 6. Performance Testing
- Simulation speed and scalability
- Memory usage optimization
- Real-time generation capability
- Concurrent device simulation

## MVP Considerations
- Focus on photovoltaic and wind turbine simulation first
- Use simplified but realistic mathematical models
- Test with manageable data volumes
- Prioritize data realism over complex optimizations
- Ensure simulation performance meets real-time requirements
- Keep fault scenarios simple for MVP phase
- Use Docker for consistent test environment

## Implementation Notes
- Use Python for complex mathematical calculations
- Implement realistic power curves and efficiency models
- Include environmental factors (irradiance, wind speed, temperature)
- Test with historical data patterns where available
- Validate data ranges against device specifications
- Focus on photovoltaic and wind turbine models for MVP
- Use environment variables for configuration
- Implement proper cleanup in test teardown
- Test both successful and failure scenarios 