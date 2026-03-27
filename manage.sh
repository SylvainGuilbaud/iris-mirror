#!/bin/bash

# IRIS Mirror Management Scripts

echo "IRIS Mirror Management"
echo "====================="

export VOLUME_PREFIX=$(basename "$PWD" | tr '[:upper:]' '[:lower:]')
        VOLUME_NAME="${VOLUME_PREFIX}_"

set_permissions() {
    local volume_name="${VOLUME_PREFIX}_$1"
    local mount_point="/$1"
    docker run --rm -v "${volume_name}:${mount_point}" alpine sh -c \
        "chown -R 51773:51773 ${mount_point} && chmod -R u+rwX,g+rwX ${mount_point}"
}

# Set permissions for the persistent volume 
set_permissions "iris_primary_data"
set_permissions "iris_primary_journal"
set_permissions "iris_primary_journal2"
set_permissions "iris_primary_WIJ"
set_permissions "iris_async_data"
set_permissions "iris_async_journal"
set_permissions "iris_async_journal2"
set_permissions "iris_async_WIJ"

case "$1" in
    "deploy")
        
        echo "Deploying IRIS Mirror Configuration..."
        docker-compose up -d
        echo "Containers started. Waiting for initialization..."
        for i in {1..30}; do
            if docker exec iris-primary iris session IRIS -U%SYS 'halt' &>/dev/null; then
            echo "IRIS Primary is ready"
            break
            fi
            echo "Waiting for IRIS to be ready... ($i/30)"
            sleep 2
        done

        echo "Checking mirror status..."
        docker exec iris-primary iris session IRIS -U%SYS '##class(SYS.Mirror).GetFailoverMemberStatus()'
        ;;
    "status")
        echo "Mirror Status:"
        echo "Primary:"
        docker exec iris-primary iris session IRIS -U%SYS '##class(SYS.Mirror).GetFailoverMemberStatus()'
        echo ""
        echo "Async Member:"
        docker exec iris-async iris session IRIS -U%SYS '##class(SYS.Mirror).GetFailoverMemberStatus()'
        echo ""
    
        ;;
    "promote")
        echo "Promoting async member to primary..."
        echo "WARNING: This will make the async member the new primary!"
        read -p "Are you sure? (yes/no): " confirm
        if [[ $confirm == "yes" ]]; then
            docker exec iris-async iris session IRIS -U%SYS '##class(SYS.Mirror).Promote()'
            echo "Promotion initiated. Check status with: $0 status"
        else
            echo "Promotion cancelled."
        fi
        ;;
    "stop")
        echo "Stopping IRIS Mirror..."
        docker-compose down
        ;;
    "logs")
        case "$2" in
            "primary")
                docker logs iris-primary
                ;;
            "async")
                docker logs iris-async
                ;;
            "arbiter")
                docker logs iris-arbiter
                ;;
            "webgateway")
                docker logs iris-webgateway
                ;;
            *)
                echo "Primary logs:"
                docker logs iris-primary | tail -20
                echo ""
                echo "Async logs:"
                docker logs iris-async | tail -20
                echo ""
                echo "Arbiter logs:"
                docker logs iris-arbiter | tail -20
                echo ""
                echo "WebGateway logs:"
                docker logs iris-webgateway | tail -20
                ;;
        esac
        ;;
    "shell")
        case "$2" in
            "primary")
                docker exec -it iris-primary iris session IRIS
                ;;
            "async")
                docker exec -it iris-async iris session IRIS
                ;;
            "arbiter")
                echo "Note: Arbiter has no external ports - accessing via internal network"
                docker exec -it iris-arbiter iris session IRIS
                ;;
            "webgateway")
                docker exec -it iris-webgateway bash
                ;;
            *)
                echo "Specify 'primary', 'async', 'arbiter', or 'webgateway': $0 shell primary"
                ;;
        esac
        ;;
    *)
        echo "Usage: $0 {deploy|status|promote|stop|logs|shell}"
        echo ""
        echo "Commands:"
        echo "  deploy  - Deploy the IRIS mirror configuration"
        echo "  status  - Check mirror status for all nodes"
        echo "  promote - Promote async member to primary"
        echo "  stop    - Stop all containers"
        echo "  logs    - Show logs (optionally specify primary|async|arbiter|webgateway)" 
        echo "  shell   - Connect to IRIS terminal or bash (specify primary|async|arbiter|webgateway)"
        echo ""
        echo "Examples:"
        echo "  $0 deploy"
        echo "  $0 status"
        echo "  $0 logs primary"
        echo "  $0 shell async"
        echo "  $0 shell webgateway"
        exit 1
        ;;
esac