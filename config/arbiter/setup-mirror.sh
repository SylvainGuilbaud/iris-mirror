#!/bin/bash

# Arbiter Setup Script

# Set security parameters
echo "Setting up arbiter configuration..."

# Start IRIS first
/iris-main &
IRIS_PID=$!

# Wait for IRIS to start
sleep 30

# Wait for primary to set up mirror
sleep 90

# Configure arbiter
iris session IRIS -U%SYS << 'EOF'
// Set as arbiter
Set ^%SYS("MIRRORARBITER") = 1

// Join as arbiter
Do ##class(SYS.MirrorConfiguration).JoinAsArbiter("DEMO-MIRROR","iris-primary",2188,"IRIS-ARBITER","iris-arbiter",2188)

H
EOF

# Keep container running
wait $IRIS_PID