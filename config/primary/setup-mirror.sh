#!/bin/bash

# Primary Mirror Setup Script

# Set security parameters
echo "Setting up primary mirror configuration..."

# Start IRIS first
/iris-main &
IRIS_PID=$!

# Wait for IRIS to start
sleep 30

# Configure mirroring
iris session IRIS -U%SYS << 'EOF'
// Set system parameters
Set ^%SYS("MIRRORPRIMARY") = 1

// Configure mirror service
Do ##class(SYS.MirrorConfiguration).CreateMirrorSet("DEMO-MIRROR","iris-primary",2188,"",0,1)

// Add the async member  
Do ##class(SYS.MirrorConfiguration).AddMember("DEMO-MIRROR","IRIS-ASYNC","iris-async",2188,1,"",0,"")

// Activate the mirror
Do ##class(SYS.MirrorConfiguration).ActivateMirror("DEMO-MIRROR")

// Add databases to mirror
Do ##class(SYS.MirrorConfiguration).AddDatabaseToMirror("DEMO-MIRROR","USER")

H
EOF

# Keep container running
wait $IRIS_PID