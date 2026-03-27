
# InterSystems IRIS Mirroring

## Overview
InterSystems IRIS Mirroring is a high-availability solution that provides real-time data synchronization across multiple IRIS instances.

## Key Features
- **Active-Passive Architecture**: Primary instance handles all operations while secondary instances remain synchronized
- **Automatic Failover**: Seamless transition to secondary in case of primary failure
- **Data Consistency**: Guaranteed synchronization of all committed transactions
- **Low Latency**: Network-efficient replication protocol

## Components
- **Primary Member**: Receives and processes all client requests
- **Secondary Members**: Maintain synchronized copies of the database
- **Arbiter**: Facilitates failover decisions in multi-node setups

## Getting Started
1. Configure IRIS instances with identical database structure
2. Establish mirror connection between primary and secondary
3. Monitor replication status in System Management Portal
4. Test failover scenarios in non-production environments

## Monitoring
Use the System Management Portal to:
- View mirror status and member health
- Monitor replication lag
- Check transaction logs
