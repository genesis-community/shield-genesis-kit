# PostgreSQL Integration

By default, SHIELD uses an embedded SQLite database for storing its metadata. While this is sufficient for small deployments, larger environments may benefit from using PostgreSQL as the backend database.

## Enabling PostgreSQL

To use PostgreSQL as SHIELD's database backend, enable the `postgres-addon` feature in your deployment manifest:

```yaml
kit:
  features:
    - postgres-addon
    
params:
  postgres-addon-version: 11  # Specify PostgreSQL version to use
```

## Supported PostgreSQL Versions

The SHIELD Genesis Kit supports the following PostgreSQL versions:

- PostgreSQL 9.0
- PostgreSQL 9.1
- PostgreSQL 9.2
- PostgreSQL 9.3
- PostgreSQL 9.4
- PostgreSQL 9.5
- PostgreSQL 9.6
- PostgreSQL 10
- PostgreSQL 11

You must specify which version to use via the `postgres-addon-version` parameter.

## Benefits of PostgreSQL

Using PostgreSQL instead of SQLite provides several advantages:

1. **Improved Performance**: Better handling of concurrent operations
2. **Enhanced Reliability**: Robust transaction handling and crash recovery
3. **Easier Backup**: Standard PostgreSQL backup tools can be used
4. **Scalability**: Better suited for environments with many targets and jobs

## Resource Requirements

When using the PostgreSQL addon, additional resources will be required for the SHIELD VM:

- Extra memory for PostgreSQL (recommend at least 2GB total RAM)
- Additional disk space for the database (recommend at least 5GB disk)

Consider using a larger VM type:

```yaml
params:
  shield_vm_type: medium  # Use a VM type with adequate resources
  shield_disk_pool: large # Use a disk pool with adequate space
```

## Backup Considerations

Even though SHIELD is a backup system, its own database should also be backed up. When using the PostgreSQL addon, you can:

1. Configure a SHIELD agent on the SHIELD VM itself
2. Create a backup job targeting the PostgreSQL database
3. Store the backup in a remote storage location

This ensures that if you need to redeploy SHIELD, you can restore its configuration and metadata.

## Limitations

The PostgreSQL addon deploys PostgreSQL co-located on the same VM as SHIELD. This is not a highly-available configuration. For production environments with strict availability requirements, consider:

1. Using an external, highly-available PostgreSQL service
2. Regularly backing up the SHIELD database
3. Having a disaster recovery plan in place