# Backstage Kubernetes Deployment

## Local

### Prerequisites

- [Docker](https://docs.docker.com/get-docker/)
- [Kind](https://kind.sigs.k8s.io/docs/user/quick-start/)
- [Kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)

### Getting Started

Run these commands from the root of the project.

#### Setup

```bash
./backstage.sh kubernetes start
kubectl port-forward --namespace=backstage svc/backstage 7007:80
# Open http://localhost:8080 in your browser
```

This script and command will create the following resources:

- Kind cluster (Local kubernetes cluster)
- Docker image for backstage
- Backstage pod, deployment, service, and secret
- Postgres database pod, deployment, service, and secret

#### Cleanup

```bash
./backstage.sh kubernetes stop
```
