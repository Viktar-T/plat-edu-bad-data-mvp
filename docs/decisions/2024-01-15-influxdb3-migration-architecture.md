# 2024-01-15 - InfluxDB 3.x Migration Architecture

## Status
**Accepted**

## Context
The renewable energy monitoring system was using InfluxDB 2.x with a bucket-based approach. We needed to evaluate whether to migrate to InfluxDB 3.x, which introduces significant architectural changes including databases/tables instead of buckets, SQL queries instead of Flux, and new features like unlimited cardinality and object storage.

## Decision
Migrate from InfluxDB 2.x to InfluxDB 3.x with the following architectural changes:

1. **Database Structure**: Replace buckets with databases and tables
2. **Query Language**: Use SQL instead of Flux for data queries
3. **Schema Design**: Implement comprehensive tagging strategy for unlimited cardinality
4. **Authentication**: Use new token-based system with granular permissions
5. **Storage**: Implement object storage with Parquet format for cost-effective retention
6. **Performance**: Configure query caching, write buffering, and compression

## Consequences

### Positive
- **Better Performance**: SQL queries are faster and more familiar than Flux
- **Unlimited Cardinality**: No limits on tag combinations for device metadata
- **Improved Organization**: Database/table structure is more intuitive than buckets
- **Cost-Effective Storage**: Object storage with Parquet format reduces storage costs
- **Enhanced Security**: Token-based authentication with granular permissions
- **Future-Proof**: InfluxDB 3.x is the current and future direction of the platform
- **Research Support**: Better support for complex analytics required by university research

### Negative
- **Migration Effort**: Requires updating all application code and configurations
- **Learning Curve**: Team needs to learn new SQL syntax and API endpoints
- **Breaking Changes**: Incompatible with existing InfluxDB 2.x configurations
- **Testing Overhead**: Comprehensive testing required to ensure migration success
- **Documentation Updates**: All documentation needs updating for new architecture

## Alternatives Considered

### Stay with InfluxDB 2.x
- **Why Rejected**: Missing new features, limited cardinality, Flux query language limitations
- **Impact**: Would miss performance improvements and new capabilities

### Use Different Time-Series Database
- **Why Rejected**: InfluxDB 3.x best fits our renewable energy monitoring requirements
- **Impact**: Would require complete system redesign and lose InfluxDB ecosystem benefits

### Hybrid Approach (2.x + 3.x)
- **Why Rejected**: Increased complexity, maintenance overhead, data synchronization issues
- **Impact**: Would create operational complexity without clear benefits

## Implementation Notes

### Migration Strategy
1. **Phase 1**: Core configuration and setup
2. **Phase 2**: Data operations and validation
3. **Phase 3**: Integration with Node-RED and Grafana
4. **Phase 4**: Testing and production deployment

### Key Configuration Changes
- Update Docker Compose to use `influxdb:3-core` image
- Replace bucket configuration with database/table setup
- Implement new token-based authentication
- Configure object storage for long-term retention
- Update environment variables with `INFLUXDB3_` prefix

### Schema Migration
- Convert measurements to tables with defined schemas
- Implement proper tagging strategy (device_id, location, device_type)
- Use fields for actual measurements (power, temperature, etc.)
- Configure time-based partitioning for efficient queries

### Application Updates Required
- Node-RED flows: Update to use new API endpoints
- Grafana data sources: Configure for SQL queries
- Data validation: Implement JSON schema validation
- Connection management: Update with retry logic and error handling

## Related Documents
- `docs/design/influxdb3-configuration/design.md` - Detailed design specification
- `docs/design/influxdb3-configuration/tasks.md` - Implementation tasks
- `docs/design/influxdb3-configuration/history.md` - Development history
- `influxdb/README.md` - Technical documentation and setup guide

## Success Criteria
- All data successfully migrated from InfluxDB 2.x to 3.x
- Query performance improved (response time < 1 second)
- Write throughput maintained or improved (> 1000 writes/second)
- All applications (Node-RED, Grafana) successfully integrated
- Security and access controls properly implemented
- Backup and recovery procedures tested and working

## Timeline
- **Configuration**: 1 day (completed)
- **Integration**: 2-3 days
- **Testing**: 2-3 days
- **Production Deployment**: 1 day

## Risk Mitigation
- **Data Loss**: Comprehensive backup before migration
- **Downtime**: Staged migration with rollback capability
- **Performance Issues**: Performance testing before production deployment
- **Integration Problems**: Thorough testing of all application integrations 