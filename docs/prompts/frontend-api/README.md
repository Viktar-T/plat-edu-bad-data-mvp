# Frontend & API Integration Guide

## Overview

This directory contains a comprehensive, step-by-step guide for integrating the **frontend** (React/Vite) and **api** (Express.js) services into your Docker-based renewable energy IoT monitoring monorepo.

Each prompt is designed to be used sequentially, either manually or with an LLM assistant (like Cursor AI), to ensure a smooth integration process.

## Integration Steps

Follow these prompts in order:

### 📋 Step 1: General Overview
**File**: `01-general-view.md`
- Understand the current project structure
- Review integration goals
- Plan the integration approach

### 🔧 Step 2: Create API Dockerfile
**File**: `02-create-api-dockerfile.md`
- Create production-ready Dockerfile for Express.js API
- Set up multi-stage build
- Configure health checks and security
- Create .dockerignore file

**Estimated Time**: 15-30 minutes

### 🎨 Step 3: Create Frontend Dockerfile
**File**: `03-create-frontend-dockerfile.md`
- Create production-ready Dockerfile for React/Vite frontend
- Set up multi-stage build with nginx
- Configure SPA routing
- Create .dockerignore file

**Estimated Time**: 20-30 minutes

### 🐳 Step 4: Update Docker Compose
**File**: `04-update-docker-compose.md`
- Add API and Frontend services to docker-compose.yml
- Configure service dependencies
- Set up environment variables
- Update networking configuration
- Modify API code for Docker networking

**Estimated Time**: 30-45 minutes

### 🔌 Step 5: Configure Frontend-API Communication
**File**: `05-configure-frontend-api-communication.md`
- Create environment configuration files
- Set up API service layer in frontend
- Configure CORS in API
- Create React hooks for data fetching
- Update existing components

**Estimated Time**: 45-60 minutes

### 🧪 Step 6: End-to-End Testing
**File**: `06-end-to-end-testing.md`
- Verify service health
- Test API-InfluxDB connection
- Test Frontend-API connection
- Create automated test scripts
- Validate complete data flow
- Performance testing

**Estimated Time**: 30-45 minutes

### 🚀 Step 7: Production Deployment
**File**: `07-production-deployment.md`
- Create production environment configuration
- Set up production Docker Compose overrides
- Create deployment scripts
- Configure backup procedures
- Set up monitoring
- Security hardening

**Estimated Time**: 45-60 minutes

### 📚 Step 8: Summary & Next Steps
**File**: `08-summary-and-next-steps.md`
- Review completed work
- Architecture overview
- Quick reference commands
- Troubleshooting guide
- Future recommendations
- Long-term roadmap

**Estimated Time**: 15 minutes (reading)

## Total Estimated Time
**3.5 to 5.5 hours** for complete integration (depending on experience level)

## Prerequisites

Before starting, ensure you have:

- ✅ Docker and Docker Compose installed
- ✅ PowerShell (Windows) or Bash (Linux/Mac)
- ✅ Node.js 20+ (for local development)
- ✅ Access to your monorepo
- ✅ Basic understanding of Docker, React, and Express.js

## Usage Methods

### Method 1: Manual Implementation
Read each prompt file sequentially and implement the steps manually:

```powershell
# Read the prompt
cat docs/prompts/frontend-api/02-create-api-dockerfile.md

# Implement the steps
# ... follow the instructions in the prompt

# Verify
# ... run the verification steps provided

# Move to next prompt
cat docs/prompts/frontend-api/03-create-frontend-dockerfile.md
```

### Method 2: With LLM Assistant (Cursor AI)
If using Cursor AI or similar:

1. Open the first prompt file
2. Select all content (Ctrl+A)
3. Copy to clipboard (Ctrl+C)
4. Paste into Cursor chat
5. Let the AI implement the steps
6. Review and verify the implementation
7. Move to the next prompt

### Method 3: Automated Script (Advanced)
Create a script to execute all steps (for experienced users):

```powershell
# Execute all integration steps
foreach ($step in 2..7) {
    Write-Host "Executing Step $step..."
    # Parse and execute commands from markdown
    # (Implementation depends on your automation setup)
}
```

## File Structure After Integration

```
your-monorepo/
├── api/
│   ├── Dockerfile           ← NEW
│   ├── .dockerignore        ← NEW
│   └── src/index.js         ← MODIFIED
│
├── frontend/
│   ├── Dockerfile           ← NEW
│   ├── nginx.conf           ← NEW
│   ├── .dockerignore        ← NEW
│   ├── .env.development     ← NEW
│   ├── .env.production      ← NEW
│   └── src/
│       ├── config/          ← NEW
│       ├── services/        ← NEW
│       └── hooks/           ← NEW
│
├── docker-compose.yml       ← MODIFIED
├── docker-compose.prod.yml  ← NEW
├── .env.production          ← NEW
│
├── scripts/
│   ├── deploy-production-apps.ps1  ← NEW
│   ├── backup-apps.ps1             ← NEW
│   └── monitor-apps.ps1            ← NEW
│
└── tests/
    ├── test-api-influxdb.ps1       ← NEW
    ├── test-complete-flow.ps1      ← NEW
    ├── test-realtime-updates.ps1   ← NEW
    └── test-performance.ps1        ← NEW
```

## Quick Start (Fast Track)

If you're experienced with Docker and want to move quickly:

1. **Read** `01-general-view.md` and `08-summary-and-next-steps.md`
2. **Create** Dockerfiles from prompts 2 & 3
3. **Update** docker-compose.yml from prompt 4
4. **Configure** communication from prompt 5
5. **Test** using scripts from prompt 6
6. **Deploy** using guide from prompt 7

## Verification Checklist

After completing all steps, verify:

- [ ] API Dockerfile exists and builds successfully
- [ ] Frontend Dockerfile exists and builds successfully
- [ ] docker-compose.yml includes both services
- [ ] API can connect to InfluxDB
- [ ] Frontend can connect to API
- [ ] All services are healthy
- [ ] Data flows correctly (MQTT → Node-RED → InfluxDB → API → Frontend)
- [ ] Test scripts execute successfully
- [ ] Production deployment scripts work
- [ ] Monitoring and backup scripts are in place

## Troubleshooting

If you encounter issues:

1. **Check the specific prompt file** for troubleshooting sections
2. **Review logs**: `docker-compose logs api frontend`
3. **Verify environment variables**: `docker exec iot-api env`
4. **Test connectivity**: Use the test scripts provided in Step 6
5. **Consult Step 8** for common issues and solutions

## Additional Resources

- **Main Project README**: `../../README.md`
- **VPS Deployment Docs**: `../../deployment-vps/`
- **InfluxDB API Docs**: `../../influxdb/01-influxdb-api.md`
- **Testing Guides**: `../../../tests/manual-tests/`

## Support

For questions or issues:
1. Review the relevant prompt file thoroughly
2. Check the troubleshooting section in Step 8
3. Review Docker logs
4. Ensure all prerequisites are met
5. Verify your environment matches the expected configuration

## Contributing

If you find improvements or corrections:
1. Document the issue
2. Propose a solution
3. Update the relevant prompt file
4. Test the changes
5. Update this README if necessary

## Version History

- **v1.0** (November 2025): Initial integration guide
  - Complete Docker integration for frontend and api
  - Production deployment configuration
  - Testing and monitoring setup

---

**Ready to start?** Begin with `01-general-view.md` and work through each step sequentially.

**Questions?** Each prompt file includes detailed explanations, verification steps, and troubleshooting guidance.

**Good luck with your integration! 🚀**

