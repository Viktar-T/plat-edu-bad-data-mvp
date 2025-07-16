# Documentation Guide

## Quick Start

### New Features
1. Create folder: `docs/design/{feature-name}/`
2. Add files: `design.md`, `tasks.md`, `history.md`, `archive/`
3. Update index: Add to `docs/design/index.md`
4. Start documenting

### Chat Sessions
1. Check `docs/design/index.md` for status
2. Read relevant `history.md` files
3. Document decisions in `history.md`
4. Archive important chats to `archive/`

## File Types

### Design Documents (`design.md`)
- **Purpose**: Clean, PR-ready documentation
- **Content**: Requirements, decisions, implementation plan
- **Style**: Professional, concise

### Task Lists (`tasks.md`)
- **Purpose**: Track implementation progress
- **Content**: Task breakdown, status, time estimates
- **Style**: Actionable, status-focused

### History Documents (`history.md`)
- **Purpose**: Preserve development reasoning
- **Content**: Timeline, decisions, lessons learned
- **Style**: Narrative, detailed

### Archive Files (`archive/`)
- **Purpose**: Raw chat logs and intermediate thinking
- **Content**: Chat sessions, brainstorming, alternatives
- **Style**: Raw, unedited

## Best Practices

### Starting New Chats
1. Check design index for current status
2. Read relevant history files
3. Continue from task lists
4. Document new decisions

### Making Decisions
1. Document context and alternatives
2. Explain rationale
3. Note consequences
4. Update history files

### Before PRs
1. Clean up design docs
2. Update task status
3. Archive raw files
4. Ensure PR-ready

## Templates

### Design Document
```markdown
# [Feature] - Design

## Overview
Brief description and purpose.

## Requirements
- Functional and non-functional requirements
- Constraints

## Design Decisions
- Key choices and rationale

## Implementation Plan
- Steps, dependencies, timeline

## Testing Strategy
- How to test, success criteria
```

### Task List
```markdown
# [Feature] - Tasks

## Status
- 🔄 **IN PROGRESS** - Currently working
- ✅ **COMPLETED** - Finished and tested
- 📋 **TODO** - Planned but not started
- 🚧 **BLOCKED** - Waiting on dependencies

## Tasks
- [ ] **TODO** [Task description]
  - **Description**: [Details]
  - **Dependencies**: [What needs to be done first]
  - **Time**: [Estimate]
```

## Maintenance
- **Weekly**: Update task status
- **Monthly**: Review and clean docs
- **Before PRs**: Archive raw files, clean up docs 