#!/bin/bash

# Verify the first argument is "docker", "kubernetes", or "local"
if [ "$1" != "docker" ] && [ "$1" != "kubernetes" ] && [ "$1" != "local" ]; then
    echo "Invalid first argument: start.sh docker|kubernetes|local"
    exit 1
fi

if [ "$2" != "start" ] && [ "$2" != "stop" ]; then
    echo "Invalid second argument: start.sh docker|kubernetes|local start|cleanup"
    exit 1
fi

# Handle docker deployment
if [ "$1" == "docker" ]; then
    DOCKER_COMPOSE_FILE="./deployment/docker/docker-compose.yml"
    if [ "$2" == "start" ]; then
        docker-compose -f $DOCKER_COMPOSE_FILE up
    elif [ "$2" == "stop" ]; then
        docker-compose -f $DOCKER_COMPOSE_FILE down
        exit 0
    fi
elif [ "$1" == "kubernetes" ]; then
    KIND_CLUSTER_NAME="backstage"
    K8_MANIFESTS="./deployment/kubernetes"
    reg_name='kind-registry'

    if [ "$2" == "start" ]; then
        kind create cluster --name $KIND_CLUSTER_NAME
        docker image build ./backstage -f ./backstage/packages/backend/Dockerfile --tag backstage:1.0
        # docker push backstage:1.0
        kind load docker-image backstage:1.0 --name $KIND_CLUSTER_NAME
        # kind create cluster backstage
        # kubectl create namespace backstage
        kubectl apply -f $K8_MANIFESTS/namespace.yaml
        kubectl apply -f $K8_MANIFESTS/postgres.yaml
        kubectl apply -f $K8_MANIFESTS/backstage.yaml

        sleep 5
        kubectl port-forward --namespace=backstage svc/backstage 7007:80
    elif [ "$2" == "stop" ]; then
        # Delete kind cluster and all associated resources
        kind delete cluster -n $KIND_CLUSTER_NAME
        exit 0
    fi
fi
