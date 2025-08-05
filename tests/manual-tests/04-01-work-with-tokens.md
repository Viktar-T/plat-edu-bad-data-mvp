# Manual Test: Working with InfluxDB 2.x Tokens

## Test Overview
This manual test covers various methods to obtain, manage, and verify InfluxDB 2.x tokens for the renewable energy monitoring system.

## Prerequisites
- Docker containers running: `iot-influxdb2`
- InfluxDB accessible at `http://localhost:8086`
- PowerShell or Command Prompt access

## Test Environment
- **Container Name**: `iot-influxdb2`
- **InfluxDB Version**: 2.7.12
- **Organization**: `renewable_energy_org`
- **Bucket**: `renewable_energy`
- **Admin User**: `admin`
- **Admin Password**: `admin_password_123`

## Test Cases

### Test Case 1: List Existing Tokens via CLI

#### Objective
Verify that we can list all existing authentication tokens using the InfluxDB CLI.

#### Steps
1. **Access the InfluxDB container**:
   ```bash
   docker exec -it iot-influxdb2 bash
   ```

2. **List all authentication tokens**:
   ```bash
   influx auth list
   ```

#### Expected Results
- Should display a table with token information including:
  - ID
  - Description
  - Token (masked)
  - User Name
  - User ID
  - Permissions

#### Actual Results
```
ID                      Description     Token                                   User Name       User ID                 Permissions
0f4a46678942b000        admin's Token   renewable_energy_admin_token_123        admin           0f4a46676942b000        [read:/authorizations write:/authorizations read:/buckets write:/buckets read:/dashboards write:/dashboards read:/orgs write:/orgs read:/sources write:/sources read:/tasks write:/tasks read:/telegrafs write:/telegrafs read:/users write:/users read:/variables write:/variables read:/scrapers write:/scrapers read:/secrets write:/secrets read:/labels write:/labels read:/views write:/views read:/documents write:/documents read:/notificationRules write:/notificationRules read:/notificationEndpoints write:/notificationEndpoints read:/checks write:/checks read:/dbrp write:/dbrp read:/notebooks write:/notebooks read:/annotations write:/annotations read:/remotes write:/remotes read:/replications write:/replications]
```

#### Status: ✅ PASSED

### Test Case 2: List Tokens by Organization

#### Objective
List tokens filtered by specific organization.

#### Steps
1. **Access the InfluxDB container**:
   ```bash
   docker exec -it iot-influxdb2 bash
   ```

2. **List tokens for specific organization**:
   ```bash
   influx auth list --org renewable_energy_org
   ```

#### Expected Results
- Should display tokens associated with the `renewable_energy_org` organization
- Should show the same admin token as in Test Case 1

#### Status: ⏳ PENDING

### Test Case 3: Create New Token via CLI

#### Objective
Create a new authentication token with specific permissions.

#### Steps
1. **Access the InfluxDB container**:
   ```bash
   docker exec -it iot-influxdb2 bash
   ```

2. **Create a new token with read/write permissions**:
   ```bash
   influx auth create \
     --org renewable_energy_org \
     --token-description "Node-RED Integration Token" \
     --read-bucket renewable_energy \
     --write-bucket renewable_energy
   ```

#### Expected Results
- Should create a new token with limited permissions
- Should display the new token ID and description
- Token should only have read/write access to the `renewable_energy` bucket

#### Status: ⏳ PENDING

### Test Case 4: Verify Token via PowerShell

#### Objective
Test token authentication using PowerShell's Invoke-WebRequest.

#### Steps
1. **Test with admin token**:
   ```powershell
   Invoke-WebRequest -Uri "http://localhost:8086/api/v2/buckets?org=renewable_energy_org" -Headers @{"Authorization"="Token renewable_energy_admin_token_123"}
   ```

#### Expected Results
- Should return HTTP 200 status
- Should return JSON response with bucket information
- Both tokens should work for API access


### Test Case 5: Get Organization Information

#### Objective
Obtain organization ID and details for token creation.

#### Steps
1. **Access the InfluxDB container**:
   ```bash
   docker exec -it iot-influxdb2 bash
   ```

2. **List organizations**:
   ```bash
   influx org list
   ```

#### Expected Results
- Should display organization information including:
  - ID
  - Name
  - Description

#### Status: ⏳ PENDING

### Test Case 6: Get Bucket Information

#### Objective
Obtain bucket ID and details for token creation.

#### Steps
1. **Access the InfluxDB container**:
   ```bash
   docker exec -it iot-influxdb2 bash
   ```

2. **List buckets for organization**:
   ```bash
   influx bucket list --org renewable_energy_org
   ```

#### Expected Results
- Should display bucket information including:
  - ID
  - Name
  - Retention Policy
  - Organization

#### Status: ⏳ PENDING

### Test Case 7: Web UI Token Management

#### Objective
Verify token management through the InfluxDB web interface.

#### Steps
1. **Access web interface**: Navigate to `http://localhost:8086`
2. **Login**: Use admin credentials (`admin` / `admin_password_123`)
3. **Navigate to Data > API Tokens**
4. **View existing tokens**
5. **Create new token** (optional)

#### Expected Results
- Should display all existing tokens
- Should allow creation of new tokens
- Should show token permissions and descriptions

#### Status: ⏳ PENDING

### Test Case 8: Token Permissions Verification

#### Objective
Verify that tokens have appropriate permissions for the renewable energy monitoring system.

#### Steps
1. **Check admin token permissions** (from Test Case 1 results)
2. **Verify Node-RED token permissions** (from configuration)
3. **Test bucket access with different tokens**

#### Expected Results
- Admin token should have full permissions
- Node-RED token should have read/write access to `renewable_energy` bucket
- Tokens should work for API operations

#### Status: ⏳ PENDING

## PowerShell Commands Reference

### Correct PowerShell Syntax for API Calls

```powershell
# List buckets
Invoke-WebRequest -Uri "http://localhost:8086/api/v2/buckets?org=renewable_energy_org" -Headers @{"Authorization"="Token renewable_energy_admin_token_123"}

# List organizations
Invoke-WebRequest -Uri "http://localhost:8086/api/v2/orgs" -Headers @{"Authorization"="Token renewable_energy_admin_token_123"}

# List authorizations (tokens)
Invoke-WebRequest -Uri "http://localhost:8086/api/v2/authorizations?org=renewable_energy_org" -Headers @{"Authorization"="Token renewable_energy_admin_token_123"}
```

### Alternative: Using curl.exe (if available)

```powershell
# Use actual curl instead of PowerShell alias
curl.exe -H "Authorization: Token renewable_energy_admin_token_123" "http://localhost:8086/api/v2/buckets?org=renewable_energy_org"
```

## Current Token Status

### Admin Token
- **Token**: `renewable_energy_admin_token_123`
- **User**: `admin`
- **Permissions**: Full access (all read/write permissions)
- **Status**: ✅ Active

### Node-RED Token
- **Token**: `wjTR5y9bbOqEos_YvIKkqHrKlsIsnsUvz-abGbSyk1VYkKGUBbyzcrPJ9r2ewgXZjWbqKwpygq8eTOOTGeUfcA==`
- **Configuration**: Used in Node-RED flows
- **Status**: ✅ Active

## Security Considerations

### Best Practices
1. **Use specific permissions**: Create tokens with only necessary permissions
2. **Regular rotation**: Rotate tokens periodically
3. **Environment variables**: Store tokens in environment variables
4. **Monitor usage**: Check token usage in InfluxDB UI
5. **Secure storage**: Never commit tokens to version control

### Token Types
1. **Admin Token**: Full access, use only for administration
2. **Application Token**: Limited permissions for specific applications
3. **Read-Only Token**: For monitoring and reporting

## Troubleshooting

### Common Issues
1. **PowerShell curl syntax**: Use `Invoke-WebRequest` instead of `curl` alias
2. **Token expiration**: Check token validity in InfluxDB UI
3. **Permission denied**: Verify token has appropriate permissions
4. **Connection issues**: Ensure InfluxDB container is running

### Debug Commands
```bash
# Check container status
docker ps | grep influxdb

# Check container logs
docker logs iot-influxdb2

# Test connectivity
docker exec -it iot-influxdb2 curl -f http://localhost:8086/health
```

## Test Completion Checklist

- [ ] Test Case 1: List Existing Tokens via CLI ✅
- [ ] Test Case 2: List Tokens by Organization
- [ ] Test Case 3: Create New Token via CLI
- [ ] Test Case 4: Verify Token via PowerShell ⚠️
- [ ] Test Case 5: Get Organization Information
- [ ] Test Case 6: Get Bucket Information
- [ ] Test Case 7: Web UI Token Management
- [ ] Test Case 8: Token Permissions Verification

## Notes
- PowerShell curl alias doesn't support bash curl syntax
- Use `Invoke-WebRequest` for PowerShell API calls
- Admin token has full permissions for all operations
- Node-RED token is configured and active in flows
