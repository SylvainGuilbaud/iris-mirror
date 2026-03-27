#!/bin/bash

# IRIS Mirror Test Script
# This script tests the mirror configuration by creating test data

echo "IRIS Mirror Configuration Test"
echo "=============================="

# Check if containers are running
if ! docker ps | grep -q "iris-primary"; then
    echo "❌ Primary container not running. Please run: ./manage.sh deploy"
    exit 1
fi

if ! docker ps | grep -q "iris-async"; then
    echo "❌ Async container not running. Please run: ./manage.sh deploy"
    exit 1
fi

if ! docker ps | grep -q "iris-arbiter"; then
    echo "❌ Arbiter container not running. Please run: ./manage.sh deploy"
    exit 1
fi

if ! docker ps | grep -q "iris-webgateway"; then
    echo "❌ WebGateway container not running. Please run: ./manage.sh deploy"
    exit 1
fi

echo "✅ All containers are running"

# Test 1: Create test data on primary
echo ""
echo "Test 1: Creating test data on primary..."
docker exec iris-primary iris session IRIS -U%SYS << 'EOF'
ZN "USER"
Set ^TestData("timestamp") = $HOROLOG
Set ^TestData("message") = "Hello from primary node"
Set ^TestData("counter") = $INCREMENT(^TestData("counter"))
Write "Created test data on primary: counter = ", ^TestData("counter"), !
H
EOF

# Test 2: Verify data replication on async  
echo ""
echo "Test 2: Checking data replication on async member..."
sleep 5  # Wait for replication
docker exec iris-async iris session IRIS -U%SYS << 'EOF'
ZN "USER"
If $DATA(^TestData) {
    Write "✅ Data replicated successfully!", !
    Write "Counter value: ", ^TestData("counter"), !
    Write "Message: ", ^TestData("message"), !
    Write "Timestamp: ", ^TestData("timestamp"), !
} Else {
    Write "❌ Data not found on async member", !
}
H
EOF

# Test 3: Check mirror status
echo ""
echo "Test 3: Checking mirror status..."
echo "Primary status:"
docker exec iris-primary iris session IRIS -U%SYS 'Write ##class(SYS.Mirror).GetMemberStatus()'

echo ""
echo "Async status:"
docker exec iris-async iris session IRIS -U%SYS 'Write ##class(SYS.Mirror).GetMemberStatus()'

echo ""
echo "Arbiter status:"
docker exec iris-arbiter iris session IRIS -U%SYS 'Write ##class(SYS.Mirror).GetMemberStatus()'

echo ""
echo "WebGateway status:"
if curl -s -o /dev/null -w "%{http_code}" http://localhost:50080 | grep -q "200\|302\|401"; then
    echo "✅ WebGateway is responding"
else
    echo "❌ WebGateway is not responding"
fi

echo ""
echo "Test completed! Check the output above for any issues."
echo "For ongoing monitoring, use: ./manage.sh status"