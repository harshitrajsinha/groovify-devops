#!/bin/bash

# IMAGE_TAG="v1"                       # "v2"
# SERVICE="frontend"                   # "backend"
# NETWORK="traefik-net"
# EXPOSED_PORT="80"                    # "8000"
# PRIORITY="1"                         # "10"
# ROUTE_PATH="/"                       # "/api"                     

IMAGE_TAG="$1"
SERVICE="$2"
EXPOSED_PORT="$3"
PRIORITY="$4"
ROUTE_PATH="$5"

echo "Pulling latest image..."
docker pull "harshitrajsinha/groovify-${SERVICE}:${IMAGE_TAG}"

OLD_CONTAINERS=$(docker ps \
    --filter "label=com.docker.compose.service=$SERVICE" \
    --format "{{.Names}}")

for OLD in $OLD_CONTAINERS
do
    NEW="${OLD}-new"

    echo "Starting replacement for $OLD"

    docker run -d \
        --name $NEW \
        --network "traefik-net" \
        --expose $EXPOSED_PORT \
        -v ./frontend/config.js:/usr/share/nginx/html/config.js:ro \
        --label "traefik.enable=true" \
        --label "traefik.http.routers.${SERVICE}.rule=PathPrefix(\"${ROUTE_PATH}\")" \
        --label "traefik.http.services.${SERVICE}.loadbalancer.server.port=${EXPOSED_PORT}" \
        --label "traefik.http.routers.${SERVICE}.priority=${PRIORITY}" \
        --label "com.docker.compose.service=${SERVICE}" \
        "harshitrajsinha/groovify-${SERVICE}:${IMAGE_TAG}"

    echo "Waiting for health..."

    until [ "$(docker inspect \
        --format='{{.State.Health.Status}}' \
        $NEW)" = "healthy" ]
    do
        sleep 2
    done

    echo "Stopping old container"

    docker stop "$OLD"
    docker rm "$OLD"

done