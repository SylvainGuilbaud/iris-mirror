#!/bin/bash

# Async Mirror Member Setup Script

# Set security parameters
echo "Setting up async mirror member configuration..."

# Start IRIS first
/iris-main &
IRIS_PID=$!

# Wait for IRIS to start
sleep 30

# Wait for primary to be ready
sleep 60

# Configure async member
iris session IRIS -U%SYS << 'EOF'
// Set as async member
Set ^%SYS("MIRRORASYNC") = 1

// Join the mirror set
Do ##class(SYS.MirrorConfiguration).JoinAsAsyncMember("DEMO-MIRROR","iris-primary",2188,"IRIS-ASYNC","iris-async",2189)

H
EOF

# Keep container running
wait $IRIS_PID