# Common Issues and Troubleshooting

This guide addresses common issues that may arise when deploying and operating SHIELD.

## Deployment Issues

### Failed to Deploy SHIELD

**Symptom**: The `genesis deploy` command fails with BOSH errors.

**Possible Causes and Solutions**:

1. **Missing Cloud Config Resources**:
   - Ensure the required networks, VM types, and disk pools are defined in your cloud config
   - Check the error messages for specific missing resources

2. **Network Allocation Errors**:
   - Verify that the `shield_static_ip` is within the static IP range of your network
   - Check that the IP is not already allocated to another VM

3. **Stemcell Issues**:
   - Ensure the required stemcell is uploaded to your BOSH director
   - Try explicitly specifying a stemcell version that you know exists

### Certificate Generation Failures

**Symptom**: Deployment fails with certificate generation errors.

**Solution**:
- Check that the BOSH director has network access to its configured certificate authority
- Try using a shorter validity period for certificates
- Verify that your `external_domain` is properly formatted

## Access Issues

### Cannot Access SHIELD UI

**Symptom**: Unable to reach the SHIELD UI after deployment.

**Possible Causes and Solutions**:

1. **Network Connectivity**:
   - Ensure firewall rules allow traffic to SHIELD on port 443
   - Verify the `shield_static_ip` is correctly assigned with `bosh -d shield instances`
   - Check network routing between your client and the SHIELD VM

2. **Certificate Issues**:
   - If using a custom domain, ensure DNS resolves to the correct IP
   - Check that your browser trusts the certificate being presented
   - Try accessing via IP address directly to bypass certificate issues

3. **SHIELD Process Not Running**:
   - SSH to the SHIELD VM: `bosh -d shield ssh shield/0`
   - Check service status: `sudo monit summary`
   - Review logs: `sudo tail -f /var/vcap/sys/log/core/core.log`

### Authentication Problems

**Symptom**: Unable to log in to SHIELD or OAuth authentication failures.

**Possible Causes and Solutions**:

1. **Built-in Authentication Issues**:
   - If using the `secure` feature, retrieve the current password from Vault
   - Reset the admin password if necessary

2. **OAuth Configuration Problems**:
   - Verify client ID and secret are correct
   - Check that redirect URIs are properly configured in the OAuth provider
   - Review SHIELD logs for specific OAuth errors

3. **Okta Integration Issues**:
   - Verify that all required Okta parameters are correctly set in Vault
   - Ensure the Okta application is configured correctly with appropriate callback URLs

## Backup and Restore Issues

### Failed Backup Jobs

**Symptom**: Backup jobs fail to complete successfully.

**Possible Causes and Solutions**:

1. **Agent Connectivity Issues**:
   - Ensure the SHIELD agent can communicate with the SHIELD core
   - Check that there's no NAT or firewall blocking communication
   - Verify agent logs on the target system

2. **Target Backend Issues**:
   - Verify the target system is accessible and running
   - Check that target credentials and configurations are correct
   - Ensure adequate permissions for the backup operation

3. **Storage Issues**:
   - Verify the storage system is accessible
   - Check for adequate space on the storage backend
   - Ensure storage credentials are correct

### Restore Failures

**Symptom**: Unable to restore data from backups.

**Possible Causes and Solutions**:

1. **Archive Accessibility**:
   - Verify the archive exists and is accessible
   - Check the storage backend connection
   - Ensure no permission issues with the archive

2. **Target Restore Issues**:
   - Verify the target system is prepared for restore (e.g., empty database if required)
   - Check that the restore target has adequate resources (disk space, memory)
   - Ensure the target is the same type as the original backup

## PostgreSQL Addon Issues

### Database Connection Problems

**Symptom**: SHIELD fails to start with PostgreSQL connection errors.

**Possible Causes and Solutions**:

1. **PostgreSQL Process Issues**:
   - Check if PostgreSQL is running: `sudo monit summary`
   - Review PostgreSQL logs: `sudo tail -f /var/vcap/sys/log/postgres/postgresql.log`
   - Restart PostgreSQL if needed: `sudo monit restart postgres`

2. **Database Configuration Issues**:
   - Verify the correct PostgreSQL version is specified in the deployment manifest
   - Check database connection parameters in SHIELD configuration

## Performance Issues

### Slow UI or API Response

**Symptom**: SHIELD UI or API operations are very slow.

**Possible Causes and Solutions**:

1. **Resource Constraints**:
   - Check VM resource utilization (CPU, memory, disk)
   - Consider increasing the VM type if consistently under-resourced
   - Check if disk is near capacity

2. **Database Issues**:
   - If using SQLite, consider switching to PostgreSQL for better performance
   - Check for database locks or long-running queries
   - Consider tuning PostgreSQL if using the postgres-addon

3. **Many Archives or Jobs**:
   - Large numbers of archives can slow down SHIELD
   - Consider implementing retention policies to reduce archive count
   - Review and clean up unnecessary job configurations

## Getting Help

If you've tried the troubleshooting steps above but still have issues:

1. Collect diagnostic information:
   ```
   genesis do my-shield-env -- info
   bosh -d shield logs --job shield/0 --follow
   ```

2. Check the [SHIELD GitHub repository](https://github.com/starkandwayne/shield) for known issues

3. Reach out to the community for support