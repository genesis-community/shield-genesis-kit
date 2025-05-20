# Cloud Provider Deployment

SHIELD Genesis Kit supports deployment on multiple cloud platforms. This guide provides specific configurations and best practices for each supported cloud provider.

## Common Configuration

Regardless of the cloud provider, all SHIELD deployments need:

- A static IP address
- A network with appropriate security rules
- VM and disk types suitable for SHIELD (see general recommendations in the manual)

## AWS

### Network Configuration

When deploying to AWS, ensure that your VPC and security groups allow:

- Inbound connection on port 443 (HTTPS) for the SHIELD API and UI
- Outbound connections to your backup targets and storage destinations
- Connections from SHIELD agents to the SHIELD API

### Example AWS Configuration

```yaml
kit:
  name: shield
  version: 1.9.0

genesis:
  env: aws-us-east-1-prod

params:
  shield_static_ip: 10.0.0.7
  shield_network: shield-net
  shield_vm_type: t3.small   # AWS instance type defined in cloud-config
  shield_disk_pool: shield-disk
  external_domain: shield.example.com
```

## vSphere

### Resource Allocation

For vSphere deployments, ensure you allocate adequate resources:

- At least 1 CPU and 2GB RAM for small deployments
- Consider using resource pools to manage SHIELD's resources

### Example vSphere Configuration

```yaml
kit:
  name: shield
  version: 1.9.0

genesis:
  env: vsphere-datacenter-prod

params:
  shield_static_ip: 192.168.1.10
  shield_network: internal
  shield_vm_type: medium   # vSphere VM type defined in cloud-config
  shield_disk_pool: shield-disk
```

## GCP

### Network Configuration

When deploying to GCP, consider:

- Using a dedicated subnet for SHIELD
- Configuring appropriate firewall rules
- Using a static external IP if SHIELD needs to be accessed outside GCP

### Example GCP Configuration

```yaml
kit:
  name: shield
  version: 1.9.0

genesis:
  env: gcp-us-central1-prod

params:
  shield_static_ip: 10.0.1.5
  shield_network: shield-net
  shield_vm_type: n1-standard-1   # GCP machine type defined in cloud-config
  shield_disk_pool: shield-disk
  external_domain: shield.example.com
```

## STACKIT

The SHIELD Genesis Kit now fully supports STACKIT with OpenStack parity. STACKIT is a European cloud provider based on OpenStack technology.

### Network Requirements

- Ensure the network allows communication between SHIELD and target systems
- Configure a floating IP if SHIELD needs to be accessed from outside STACKIT

### Example STACKIT Configuration

```yaml
kit:
  name: shield
  version: 1.9.0

genesis:
  env: stackit-eu-prod

params:
  shield_static_ip: 10.10.10.5
  shield_network: stackit-network
  shield_vm_type: stackit-vm-type   # VM type defined in cloud-config
  shield_disk_pool: stackit-disk
```

## Cloud-Config Requirements

Your BOSH cloud-config must define appropriate resources for SHIELD. Here's what you should include:

1. **Networks**: A network where SHIELD will be deployed
2. **VM Types**: VM types with adequate resources for SHIELD
3. **Disk Types**: Persistent disk types for SHIELD's database
4. **Availability Zones**: Where SHIELD will be deployed

Example cloud-config snippet (format will vary by provider):

```yaml
networks:
- name: shield
  subnets:
  - az: z1
    range: 10.0.0.0/24
    reserved: [10.0.0.1-10.0.0.5]
    static: [10.0.0.7]
    gateway: 10.0.0.1

vm_types:
- name: small
  cloud_properties:
    instance_type: t3.small  # AWS example
    
disk_types:
- name: shield
  disk_size: 5120  # 5GB

azs:
- name: z1
  cloud_properties:
    availability_zone: us-east-1a  # AWS example
```

## Best Practices

Regardless of the cloud provider, follow these best practices:

1. **Use a dedicated network** for SHIELD when possible
2. **Implement proper security groups/firewall rules** to restrict access
3. **Use TLS with a valid certificate** (provide via `external_domain`)
4. **Enable the `secure` feature** to auto-generate secure admin credentials
5. **Consider using PostgreSQL** (`postgres-addon` feature) for larger deployments
6. **Back up SHIELD's own configuration** regularly