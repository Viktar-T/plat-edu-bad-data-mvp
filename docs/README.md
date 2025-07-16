# Renewable Energy IoT Monitoring System - Documentation

## Quick Start
- [Architecture](architecture.md) - System overview and data flow
- [Development Workflow](development-workflow.md) - Setup and processes
- [Design Index](design/index.md) - All feature designs and status
- [Meeting Notes](meetings/) - Project discussions
- [Decisions](decisions/) - Major design decisions

## Documentation Structure

### Design Documents (`/design/`)
Each feature has its own folder with:
- `design.md` - Clean design document (PR-ready)
- `tasks.md` - Task breakdown with status
- `history.md` - Development decisions and reasoning
- `archive/` - Raw chat logs and intermediate docs

### Supporting Docs
- **Meetings** (`/meetings/`) - Meeting notes and summaries
- **Decisions** (`/decisions/`) - Major architectural decisions

## Tech Stack
- **Data Flow**: MQTT → Node-RED → InfluxDB → Grafana
- **Containerization**: Docker & Docker Compose
- **MQTT Broker**: Eclipse Mosquitto
- **Database**: InfluxDB 2.x
- **Visualization**: Grafana
- **Processing**: Node-RED flows

## How to Use
1. **New Feature**: Create folder in `/design/` with the 4 core files
2. **Continue Work**: Check design index and history files
3. **Document Decisions**: Update history and decision records
4. **Archive Chats**: Save important sessions to archive folders

## Project Status
- **Current**: Initial setup and documentation
- **Next**: MQTT communication system implementation
- **Active Tasks**: See [design index](design/index.md) 