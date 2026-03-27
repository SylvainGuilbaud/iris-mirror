# InterSystems IRIS Mirror Configuration

This project provides a Docker Compose setup for deploying a complete InterSystems IRIS mirror configuration using the **Enterprise Manager Edition** (supports mirroring):
- **Primary Node** (`iris-primary`): The main database instance that handles read/write operations
- **Async Member** (`iris-async`): A read-only backup that can be promoted to primary when needed  
- **Arbiter** (`iris-arbiter`): Provides voting for automatic failover decisions
- **WebGateway** (`iris-webgateway`): Web server for CSP applications and Management Portal access

> **Note**: This configuration uses `containers.intersystems.com/intersystems/iris:latest-em` which includes mirroring capabilities. The standard Community Edition does not support mirroring.

## Architecture

```
┌─────────────────┐         ┌─────────────────┐         ┌─────────────────┐
│  IRIS Primary   │◄────────┤  IRIS Async     │         │  IRIS Arbiter   │
│  Port: 51972    │         │  Port: 51973    │         │ (Internal Only) │
│  Mirror: 2188   │ Internal│  Mirror: 2189   │         │  Mirror: 2188   │
└─────────────────┘ Network └─────────────────┘         └─────────────────┘
         ▲                           ▲                           ▲
         │                           │                           │
         └───────────────────────────┼───────────────────────────┘
                                     │
                        ┌─────────────────┐
                        │   WebGateway    │
                        │ HTTP:  50080    │
                        │ HTTPS: 50443    │
                        └─────────────────┘
```

*Note: Mirror service ports (2188-2188) communicate over the internal Docker network and are not exposed externally.*

## Quick Start

### Deploy the Mirror

```bash
./manage.sh deploy
```

This will:
1. Start all four containers (primary, async, arbiter, webgateway)
2. Configure the mirror relationship with arbiter
3. Set up the primary and async member with automatic failover capability

### Check Mirror Status

```bash
./manage.sh status
```

### Access the Systems

**Primary Node:**
- IRIS Terminal: `./manage.sh shell primary`
- SuperServer: `localhost:51972`

**Async Member:**
- IRIS Terminal: `./manage.sh shell async`  
- SuperServer: `localhost:51973`

**WebGateway:**
- HTTP: http://localhost:50080
- HTTPS: https://localhost:50443
- Management Portal: http://localhost:50080/csp/sys/UtilHome.csp

**Default Credentials:**
- Username: `SuperUser`
- Password: `SYS`

## Management Commands

The `manage.sh` script provides several commands:

| Command | Description |
|---------|-------------|
| `deploy` | Deploy the complete mirror configuration |
| `status` | Check mirror status for both nodes |
| `promote` | Promote async member to primary |
| `stop` | Stop all containers |
| `logs` | View container logs |
| `shell` | Connect to IRIS terminal |

### Examples

```bash
# Deploy everything
./manage.sh deploy

# Check if mirroring is working
./manage.sh status

# View logs for specific node
./manage.sh logs primary
./manage.sh logs async

# Connect to IRIS terminal
./manage.sh shell primary

# Promote async to primary (failover scenario)
./manage.sh promote

# Stop all containers
./manage.sh stop
```

## Mirror Configuration Details

### Primary Node Configuration
- **Container**: `iris-primary`
- **Hostname**: `iris-primary`
- **Mirror Role**: Primary
- **Ports**: 51972 (SuperServer)

### Async Member Configuration  
- **Container**: `iris-async`
- **Hostname**: `iris-async`
- **Mirror Role**: Async Member (can be promoted)
- **Ports**: 51973 (SuperServer)

### Arbiter Configuration
- **Container**: `iris-arbiter`
- **Hostname**: `iris-arbiter`
- **Mirror Role**: Arbiter (voting member for failover decisions)
- **Access**: Internal network only (no external ports exposed)

### WebGateway Configuration
- **Container**: `iris-webgateway`
- **Hostname**: `iris-webgateway`
- **Role**: Web server for CSP applications and Management Portal
- **Ports**: 50080 (HTTP), 50443 (HTTPS)

### Mirrored Databases
- `USER` database is configured for mirroring
- Journal files are shared between nodes
- Automatic failover is supported

## Testing the Configuration

1. **Verify Mirror Status**:
   ```bash
   ./manage.sh status
   ```

2. **Test Data Replication**:
   - Connect to primary: `./manage.sh shell primary`
   - Create test data in USER namespace
   - Connect to async: `./manage.sh shell async`
   - Verify data is replicated (read-only)

3. **Test Promotion**:
   - Run `./manage.sh promote` to make async the new primary
   - Check status to verify the role change

## Troubleshooting

### Common Issues

1. **Containers not starting**: Check Docker logs
   ```bash
   ./manage.sh logs
   ```

2. **Mirror not connecting**: Ensure both containers can reach each other
   ```bash
   docker exec iris-primary ping iris-async
   ```

3. **Port conflicts**: Make sure ports 51972-51973, 50080, 50443 are available

### Useful Commands

```bash
# Check container status
docker ps

# View detailed logs for a specific timeframe
docker logs iris-primary --since="10m"

# Restart just one container
docker-compose restart iris-async

# Access container shell
docker exec -it iris-primary bash
```

## File Structure

```
├── docker-compose.yml          # Docker Compose configuration
├── manage.sh                  # Management script
├── test-mirror.sh            # Testing script
├── config/
│   ├── primary/
│   │   ├── iris.cpf          # Primary IRIS configuration
│   │   └── setup-mirror.sh   # Primary initialization script
│   ├── async/
│   │   ├── iris.cpf          # Async member IRIS configuration
│   │   └── setup-mirror.sh   # Async member initialization script
│   ├── arbiter/
│   │   ├── iris.cpf          # Arbiter IRIS configuration
│   │   └── setup-mirror.sh   # Arbiter initialization script
│   └── webgateway/
│       └── CSP.conf          # WebGateway configuration
└── README.md                 # This documentation
```

## Advanced Configuration

### Adding More Async Members

To add additional async members:

1. Add a new service in `docker-compose.yml`
2. Create configuration files in `config/async2/`
3. Update the mirror configuration scripts

### Enabling SSL for Mirror Communication

1. Generate SSL certificates
2. Update `iris.cpf` files with SSL configuration
3. Mount certificates in Docker containers

### Monitoring and Alerts

Consider implementing monitoring for:
- Mirror lag time
- Connection status between nodes
- Journal file accumulation
- System resource usage

## Production Considerations

⚠️ **Important**: This configuration uses the Enterprise Manager edition for development/testing. For production use:

- Ensure you have proper InterSystems IRIS licenses for production deployment
- The `latest-em` image includes mirroring capabilities but may have usage limitations
- Implement proper SSL/TLS encryption for mirror communication
- Set up monitoring and alerting for mirror status
- Configure backup strategies and disaster recovery procedures
- Use persistent volume storage with appropriate performance characteristics
- Implement network security policies and firewalls
- Set up proper authentication and authorization
- Consider geographic distribution for true disaster recovery

## License Requirements

This setup uses the Enterprise Manager edition (`latest-em`) which includes mirroring features. Please ensure you have appropriate licensing for your intended use case:
- Development/Testing: May be covered under developer licenses
- Production: Requires appropriate InterSystems IRIS production licenses
- Contact InterSystems for specific licensing requirements

## Support

For InterSystems IRIS documentation and support:
- [InterSystems Documentation](https://docs.intersystems.com/)
- [IRIS Mirroring Guide](https://docs.intersystems.com/irislatest/csp/docbook/DocBook.UI.Page.cls?KEY=GHA_mirror)
- [Community Forums](https://community.intersystems.com/)