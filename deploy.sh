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
#         # Create local docker registry for kind
#         # https://kind.sigs.k8s.io/docs/user/local-registry/
#         set -o errexit

#         reg_port='5001'
#         if [ "$(docker inspect -f '{{.State.Running}}' "${reg_name}" 2>/dev/null || true)" != 'true' ]; then
#           docker run \
#             -d --restart=always -p "127.0.0.1:${reg_port}:5000" --name "${reg_name}" \
#             registry:2
#         fi

#         # 2. Create kind cluster with containerd registry config dir enabled
#         cat <<EOF | kind create cluster --config=-
#           kind: Cluster
#           apiVersion: kind.x-k8s.io/v1alpha4
#           name: $KIND_CLUSTER_NAME
#           containerdConfigPatches:
#           - |-
#             [plugins."io.containerd.grpc.v1.cri".registry]
#               config_path = "/etc/containerd/certs.d"
# EOF
#         # 3. Add the registry config to the nodes
#         # alias localhost:${reg_port} to the registry container when pulling images
#         REGISTRY_DIR="/etc/containerd/certs.d/localhost:${reg_port}"
#         for node in $(kind get nodes); do
#           docker exec "${node}" mkdir -p "${REGISTRY_DIR}"
#           cat <<EOF | docker exec -i "${node}" cp /dev/stdin "${REGISTRY_DIR}/hosts.toml"
#         [host."http://${reg_name}:5000"]
# EOF
#         done

#         # 4. Connect the registry to the cluster network if not already connected
#         # This allows kind to bootstrap the network but ensures they're on the same network
#         if [ "$(docker inspect -f='{{json .NetworkSettings.Networks.kind}}' "${reg_name}")" = 'null' ]; then
#           docker network connect "kind" "${reg_name}"
#         fi

#         # 5. Document the local registry
#         cat <<EOF | kubectl apply -f -
#         apiVersion: v1
#         kind: ConfigMap
#         metadata:
#           name: local-registry-hosting
#           namespace: kube-public
#         data:
#           localRegistryHosting.v1: |
#             host: "localhost:${reg_port}"
#             help: "https://kind.sigs.k8s.io/docs/user/local-registry/"
# EOF
        kind create cluster --name $KIND_CLUSTER_NAME
        docker image build ./backstage -f ./backstage/packages/backend/Dockerfile --tag backstage:1.0
        # docker push backstage:1.0
        kind load docker-image backstage:1.0 --name $KIND_CLUSTER_NAME
        # kind create cluster backstage
        # kubectl create namespace backstage
        kubectl apply -f $K8_MANIFESTS/namespace.yaml
        kubectl apply -f $K8_MANIFESTS/postgres.yaml
        kubectl apply -f $K8_MANIFESTS/backstage.yaml

        # Expose the backstage service to localhost:80
        echo "Run the following command to access the backstage service:"
        kubectl port-forward --namespace=backstage svc/backstage 7007:80
    elif [ "$2" == "stop" ]; then
        # Stop local docker registry container
        docker stop $reg_name
        docker rm $reg_name
        # Delete kind cluster and all associated resources
        kind delete cluster -n $KIND_CLUSTER_NAME
        exit 0
    fi
fi
