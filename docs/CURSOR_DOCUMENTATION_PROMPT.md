# Cursor IDE Documentation Prompt

## Usage Instructions

**To document a conversation, simply reference this file:**
```
@CURSOR_DOCUMENTATION_PROMPT.md
```

**Cursor IDE will automatically:**
1. Analyze the current conversation
2. Identify the main topic/feature discussed
3. Create or update appropriate documentation files
4. Extract key decisions, tasks, and requirements
5. Update the design index

---

## Documentation Task

**DOCUMENTATION TASK**: Based on our conversation, please document this session by:

### 1. Identify the Main Topic/Feature
- **Analyze the conversation** to determine which feature or component we discussed
- **Examples**: MQTT Communication, Device Simulation, Node-RED Flows, Docker Configuration, Security Setup, etc.
- **If it's a new feature**: Create the complete folder structure and documentation
- **If it's an existing feature**: Update the relevant files with new information
- **If it's a general discussion**: Create appropriate documentation based on the main themes

### 2. Update or Create Design Documents

#### For New Features:
**Create folder**: `docs/design/{feature-name}/` with these files:

**`design.md`** - Clean, PR-ready design document:
```markdown
# [Feature Name] - Design

## Overview
[Brief description from our discussion]

## Requirements
- [Functional requirements we identified]
- [Non-functional requirements we discussed]
- [Constraints and limitations mentioned]

## Design Decisions
- [Key decisions we made with rationale]
- [Technology choices and why]
- [Architectural decisions]

## Implementation Plan
- [High-level steps we discussed]
- [Dependencies we identified]
- [Timeline estimates if mentioned]

## Testing Strategy
- [How to test this feature]
- [Success criteria we defined]
```

**`tasks.md`** - Task breakdown and tracking:
```markdown
# [Feature Name] - Tasks

## Status
- 🔄 **IN PROGRESS** - Currently working
- ✅ **COMPLETED** - Finished and tested
- �� **TODO** - Planned but not started
- 🚧 **BLOCKED** - Waiting on dependencies

## Tasks
- [ ] **TODO** [Task we identified]
  - **Description**: [Details from our discussion]
  - **Dependencies**: [What needs to be done first]
  - **Time**: [Estimate if mentioned]
```

**`history.md`** - Development history and decision tracking:
```markdown
# [Feature Name] - History

## [Date] - [Session Topic]
**Context**: [What we were discussing]

**Key Decisions Made**:
1. **[Decision]** - [Brief description]
   - **Reasoning**: [Why we chose this]
   - **Alternatives Considered**: [Other options we discussed]
   - **Impact**: [What this means]

**Questions Explored**:
- [Questions we asked and answered]

**Next Steps Identified**:
1. [Next action item]
2. [Next action item]

**Chat Session Notes**:
- [Key insights from our discussion]
```

#### For Existing Features:
**Update the relevant files** in `docs/design/{feature-name}/`:
- **Add new decisions** to `history.md` with context and rationale
- **Update task status** in `tasks.md` (mark completed, add new tasks)
- **Refine `design.md`** if we made significant changes or discoveries
- **Add implementation notes** if we discussed specific technical details

### 3. Create Decision Records (if applicable)

**If we made major architectural or design decisions**, create:
`docs/decisions/YYYY-MM-DD-decision-topic.md`:

```markdown
# YYYY-MM-DD - [Decision Topic]

## Status
**Accepted** | **Proposed** | **Rejected**

## Context
[What problem we were solving]

## Decision
[What we decided]

## Consequences
- **Positive**: [Benefits of this choice]
- **Negative**: [Drawbacks or trade-offs]

## Alternatives Considered
- [Alternative 1] - [Why we rejected it]
- [Alternative 2] - [Why we rejected it]

## Implementation Notes
[How to implement this decision]

## Related Documents
- [Links to related design docs]
```

### 4. Archive Raw Chat (if significant)

**If this was a substantial design session**, create:
`docs/design/{feature-name}/archive/YYYY-MM-DD-session-topic.md`:

```markdown
# YYYY-MM-DD - [Session Topic] - Raw Chat

## Session Overview
**Date**: [Date]
**Duration**: [Estimated time]
**Topic**: [What we discussed]

## Key Points from Chat
- [Main discussion points]
- [Decisions made]
- [Questions resolved]
- [Next steps identified]

## Raw Chat Summary
[Brief summary of the conversation flow and key exchanges]
```

### 5. Update Design Index

**Update `docs/design/index.md`**:
- **Add new features** to the list with brief descriptions
- **Update status** of existing features (progress, completion)
- **Update progress information** and next steps
- **Link related documents** and dependencies

### 6. Analysis and Documentation Instructions

**Please analyze our conversation and extract:**

#### **Key Information to Capture:**
1. **Architecture Decisions** - Technology choices, design patterns, system structure
2. **Implementation Details** - Code structure, configurations, setup procedures
3. **Requirements** - Functional and non-functional requirements we clarified
4. **Constraints** - Limitations, dependencies, or technical constraints discussed
5. **Tasks and Actions** - Work items identified, completed, or planned
6. **Problems Solved** - Issues we resolved or approaches we developed
7. **Next Steps** - Future actions, improvements, or follow-up items

#### **Documentation Focus:**
- **What problems we solved** and how
- **What decisions we made** and the rationale behind them
- **What tasks we identified** and their priorities
- **What next steps we planned** and dependencies
- **Any constraints or limitations** we discussed
- **Technical details** and implementation approaches

#### **Documentation Standards:**
- **Use clear, concise language** suitable for team collaboration
- **Include context** for all decisions and choices
- **Link related documents** and cross-references
- **Update task status** appropriately (TODO, IN PROGRESS, COMPLETED, BLOCKED)
- **Preserve the reasoning** behind important choices
- **Maintain consistency** with existing documentation structure

#### **Quality Guidelines:**
- **Keep design docs clean and PR-ready** for code review
- **Put detailed reasoning** in history files for future reference
- **Archive raw chat logs** for deep context when needed
- **Update the index** to reflect current project status
- **Use consistent formatting** and structure across all documents

---

## **EXECUTION INSTRUCTIONS**

**Based on our conversation, please:**

1. **Analyze the discussion** to identify the main topic/feature
2. **Create or update** the appropriate documentation structure
3. **Extract and document** all key decisions, tasks, and requirements
4. **Update status** of existing work and add new items
5. **Ensure completeness** by covering all aspects we discussed
6. **Maintain consistency** with the existing documentation system

**Proceed with comprehensive documentation following these guidelines.**

---

## How to Use This Documentation System

### **Simple Usage:**
1. **Reference this file** in your Cursor IDE chat:
   ```
   @CURSOR_DOCUMENTATION_PROMPT.md
   ```
2. **Cursor will automatically** analyze the conversation and create comprehensive documentation

### **When to Use:**
- **After design discussions** - Architecture, technology choices, system design
- **After implementation sessions** - Code structure, configurations, setup procedures
- **After problem-solving** - Issues resolved, approaches developed, solutions implemented
- **After planning sessions** - Requirements clarification, task identification, roadmap planning
- **After review sessions** - Code reviews, architecture reviews, design reviews

### **What Gets Documented:**
- **Design decisions** with rationale and alternatives considered
- **Implementation details** and technical approaches
- **Task breakdown** with status tracking and dependencies
- **Requirements** and constraints identified
- **Next steps** and action items
- **Problems solved** and solutions developed

## Benefits

- **🚀 Zero Manual Work** - Automatic documentation generation
- **📋 Consistent Structure** - Follows established documentation format
- **🔍 Complete Coverage** - Captures decisions, tasks, and rationale
- **📚 Knowledge Preservation** - Archives conversations for future reference
- **👥 Team Collaboration** - Creates clean, PR-ready documentation
- **🔄 Version Control** - Tracks decision history and evolution

## Example Results

**After discussing MQTT topic structure:**
- ✅ Updated `docs/design/mqtt-communication/history.md` with new decisions
- ✅ New decision record in `docs/decisions/2024-01-15-mqtt-topic-structure.md`
- ✅ Updated task status in `docs/design/mqtt-communication/tasks.md`
- ✅ Archived raw chat in `docs/design/mqtt-communication/archive/`
- ✅ Updated design index with progress information

**After implementing device simulation:**
- ✅ Created `docs/design/device-simulation/` folder structure
- ✅ Generated `design.md` with technical specifications
- ✅ Created `tasks.md` with implementation breakdown
- ✅ Documented decisions in `history.md`
- ✅ Updated project documentation index

## Documentation Structure Created

```
docs/
├── design/
│   ├── index.md                    # Master index of all features
│   ├── {feature-name}/
│   │   ├── design.md               # Clean, PR-ready design document
│   │   ├── tasks.md                # Task breakdown and tracking
│   │   ├── history.md              # Development history and decisions
│   │   └── archive/                # Raw chat logs for deep context
│   │       └── YYYY-MM-DD-session.md
│   └── ...
├── decisions/
│   ├── YYYY-MM-DD-decision-topic.md
│   └── ...
└── CURSOR_DOCUMENTATION_PROMPT.md  # This file
```

This system ensures **every important conversation gets properly documented and preserved** in your structured documentation system! 