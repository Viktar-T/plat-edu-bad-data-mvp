# Test Suite for Renewable Energy IoT Monitoring System MVP

This directory contains the incremental, Docker-based test suite for the MVP. Tests are organized by language and type, with sequential execution and unified reporting. See 01-test-directory-structure.md for full details.

## Structure
- **JavaScript**: Core tests (Phase 1)
- **Python**: Data analysis and simulation (Phase 2)
- **SQL**: Schema and query validation (Phase 3)
- **Shell**: System and container checks (Phase 4)

## Running Tests
Use the provided Docker setup and `run-tests.sh` script to execute all tests in sequence. Results are reported in the `reports/` directory.

## Phases
1. JavaScript (MVP foundation)
2. Python (data/business logic)
3. SQL (schema/query)
4. Shell (system/container)

---

For detailed structure and instructions, see `../docs/promts/tests/01-test-directory-structure.md`. 