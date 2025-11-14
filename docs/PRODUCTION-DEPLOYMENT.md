# Production Deployment Guide

This guide covers deploying the Renewable Energy IoT Monitoring System to production (Mikrus VPS).

## Prerequisites

- Docker and Docker Compose installed on VPS
- SSH access to the VPS
- Production environment file (`.env.production`) configured

## Production Ports

- **MQTT (Mosquitto)**: 40098
- **Grafana**: 40099
- **Node-RED**: 40100
- **InfluxDB**: 40101
- **API**: 40102
- **Frontend**: 40103

## Initial Setup

### 1. Prepare Environment File

Copy and configure the production environment file:

```powershell
# Copy example to production
cp env.example .env.production

# Edit .env.production and update:
# - All passwords (use strong passwords)
# - All tokens (use strong tokens)
# - Verify all URLs and ports
```

**Important**: Replace all `<STRONG_PASSWORD_HERE>` and `<STRONG_TOKEN_HERE>` placeholders with actual secure values.

### 2. Build Production Images

```powershell
.\scripts\deploy-production-apps.ps1 -Build
```

This will:
- Build API service with production optimizations
- Build Frontend service with production environment variables
- Use `docker-compose.prod.yml` for production-specific settings

### 3. Deploy Services

```powershell
.\scripts\deploy-production-apps.ps1 -Deploy
```

This will:
- Stop existing services
- Remove old containers
- Start new services with production configuration
- Show service status

### 4. Verify Deployment

```powershell
# Check service status
.\scripts\deploy-production-apps.ps1 -Status

# View logs
.\scripts\deploy-production-apps.ps1 -Logs
```

## Accessing Production Services

Once deployed, access services at:

- **Frontend Dashboard**: http://robert108.mikrus.xyz:40103
- **API Endpoints**: http://robert108.mikrus.xyz:40102
  - Health: http://robert108.mikrus.xyz:40102/health
  - Summary: http://robert108.mikrus.xyz:40102/api/summary/{device}
- **Grafana**: http://robert108.mikrus.xyz:40099
- **Node-RED**: http://robert108.mikrus.xyz:40100
- **InfluxDB**: http://robert108.mikrus.xyz:40101

## Maintenance Operations

### Restart Services

```powershell
.\scripts\deploy-production-apps.ps1 -Restart
```

### Monitor Services

```powershell
.\scripts\monitor-apps.ps1
```

This provides a live monitoring dashboard showing:
- API health status
- Frontend health status
- Container status
- Resource usage (CPU, Memory)

### Create Backup

```powershell
.\scripts\backup-apps.ps1
```

This creates a backup of:
- API source code and configuration
- Frontend source code and configuration
- Docker compose files
- Environment configuration

Backups are saved to `backups/apps-{timestamp}.zip`

## Updating Services

### Full Update (Rebuild and Deploy)

```powershell
# 1. Build new images
.\scripts\deploy-production-apps.ps1 -Build

# 2. Deploy new services
.\scripts\deploy-production-apps.ps1 -Deploy

# 3. Verify deployment
.\scripts\deploy-production-apps.ps1 -Status
```

### Quick Restart (No Rebuild)

```powershell
.\scripts\deploy-production-apps.ps1 -Restart
```

## Production Configuration

### Resource Limits

Production services have resource limits configured in `docker-compose.prod.yml`:

**API Service:**
- CPU Limit: 0.5 cores
- Memory Limit: 512MB
- CPU Reservation: 0.25 cores
- Memory Reservation: 256MB

**Frontend Service:**
- CPU Limit: 0.25 cores
- Memory Limit: 256MB
- CPU Reservation: 0.1 cores
- Memory Reservation: 128MB

### Logging

Production services use JSON file logging with rotation:
- Max log file size: 10MB
- Max log files: 3
- Logs are automatically rotated

### Health Checks

All services have health checks configured:
- **API**: Checks `/health` endpoint every 30 seconds
- **Frontend**: Checks `/health` endpoint every 30 seconds
- Services automatically restart if health checks fail

## Security Considerations

1. **Change Default Passwords**: Update all passwords in `.env.production`
2. **Use Strong Tokens**: Generate secure tokens for InfluxDB
3. **Enable HTTPS**: Consider setting up SSL/TLS certificates
4. **Rate Limiting**: API should implement rate limiting (future enhancement)
5. **Regular Backups**: Run backup script regularly
6. **Monitor Logs**: Check logs for suspicious activity
7. **Keep Updated**: Regularly update Docker images and dependencies

## Troubleshooting

### Services Not Starting

```powershell
# Check logs
.\scripts\deploy-production-apps.ps1 -Logs

# Check Docker status
docker-compose --env-file .env.production ps

# Check individual service logs
docker-compose --env-file .env.production logs api
docker-compose --env-file .env.production logs frontend
```

### API Not Connecting to InfluxDB

```powershell
# Check API environment variables
docker exec iot-api env | Select-String "INFLUX"

# Check network connectivity
docker exec iot-api ping influxdb -c 3

# Check InfluxDB health
curl http://localhost:40101/health
```

### Frontend Not Loading

```powershell
# Rebuild frontend with correct env vars
.\scripts\deploy-production-apps.ps1 -Build
.\scripts\deploy-production-apps.ps1 -Deploy

# Check frontend logs
docker-compose --env-file .env.production logs frontend

# Verify environment variables were set during build
docker exec iot-frontend env | Select-String "VITE"
```

### Port Conflicts

```powershell
# Check what's using the ports
netstat -ano | Select-String "40102"
netstat -ano | Select-String "40103"

# Stop conflicting services or change ports in .env.production
```

## Performance Optimization

### Enable Docker BuildKit

```powershell
$env:DOCKER_BUILDKIT=1
$env:COMPOSE_DOCKER_CLI_BUILD=1
```

### Monitor Resource Usage

```powershell
# Use monitoring script
.\scripts\monitor-apps.ps1

# Or check manually
docker stats iot-api iot-frontend
```

## Backup and Recovery

### Create Backup

```powershell
.\scripts\backup-apps.ps1
```

### Restore from Backup

1. Extract backup archive
2. Copy files back to their locations
3. Rebuild and deploy services

## Next Steps

- Set up automated backups (cron job)
- Configure SSL/TLS certificates
- Implement rate limiting in API
- Set up monitoring alerts
- Configure firewall rules on VPS
- Set up log aggregation

## Support

For issues or questions:
1. Check logs: `.\scripts\deploy-production-apps.ps1 -Logs`
2. Review troubleshooting section above
3. Check service health: `.\scripts\deploy-production-apps.ps1 -Status`
4. Monitor resources: `.\scripts\monitor-apps.ps1`

