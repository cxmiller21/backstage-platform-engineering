# Backstage Platform Engineering Project

This project is a demo of [Backstage](https://backstage.io/) for Platform Engineering. It includes the following,

- Configurations to run backstage locally with yarn dev, Docker, and Kubernetes
- Resources to deploy the project to an AWS account using Terraform
- A demo template that can be used to create a new Terraform IaC repository in a personal GitHub account (requires user to create a Personal Access Token).
- A demo Backstage API configuration

## Getting Started

Please note that this project is a demo and is not intended to be used in production. The project is intended to be used as a starting point for a new Backstage project.

The base project should work as expected. Although, there might need to be some levels of troubleshooting to get the project working in your environment. Please open an issue if you run into any problems.

### Prerequisites

- [Git](https://git-scm.com/downloads)
- [Node.js](https://nodejs.org/en/download/)
- [Yarn](https://classic.yarnpkg.com/en/docs/install/#mac-stable)
- [Backstage CLI](https://backstage.io/docs/getting-started/create-an-app)
- [Docker](https://docs.docker.com/get-docker/)
- [Kind](https://kind.sigs.k8s.io/docs/user/quick-start/)
- GitHub Account with Personal Access Token to create repositories (if you want to use the demo template to test creating a new repository)

### Running Locally

1. Clone the repository
   ```bash
   git clone https://github.com/cxmiller21/backstage-platform-engineering.git
   ```
2. Optional - Create a GitHub Access Token with write permissions
   1. Login to GitHub
   2. Go to Settings > Developer Settings > Personal Access Tokens
   3. Tokens (Classic) > Generate new token > Enter name + select "Repo" scope
3. Optional - Add GitHub Access Token to create new repository from a Backstage template in GitHub
   ```bash
   # Optional
   export GITHUB_TOKEN=personal-access-token
   # Optional if running Kubernetes (PLEASE DO NOT COMMIT THIS CHANGE)
   echo personal-access-token | base64
   # Update the `./local/kubernetes/backstage.yaml` file with the base64 encoded token
   ```
4. Start Backstage
   ```bash
   # Locally
   cd app
   yarn install
   yarn dev

   # Locally with Docker
   ./backstage.sh docker start
   # Open http://localhost:7007 in your browser

   # Locally with Kubernetes
   ./backstage.sh kubernetes start
   # Open http://localhost:7007 in your browser
   ```

### Cleanup

```bash
# Docker
./backstage.sh docker stop

# Kubernetes
./backstage.sh kubernetes stop
```

## Deploying to AWS

### Prerequisites

- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)
- [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)
- [AWS Account](https://aws.amazon.com/premiumsupport/knowledge-center/create-and-activate-aws-account/)

### Deploying

Script runs `terraform init` and `terraform apply` in the `.terraform/backstage` and `.terraform/ecr` directories. And runs the `./build_and_push_to_ecr.sh` script to push a Docker image to the projects ECR repository.

```bash
./backstage.sh terraform apply
```

### Cleanup

The backstage.sh script runs `terraform destroy` in the `.terraform/backstage` and `.terraform/ecr` directories.

```bash
./backstage.sh terraform destroy
```

## Project Goals

### Backstage

- [x] Create a Backstage application
- [x] Create a Backstage template that can be used to create a new IaC repository in my personal GitHub account
  - Template Entity: `./catalog/templates/template-terraform-s3.yaml`
  - Template Resources: `./catalog/templates/terraform-s3/`
  - Template included in: `./backstage/app-config.yaml`
- [x] Create a Backstage Group, User, System, and Docs for testing
  - [ ] Update S3 Bucket Template to set group, user, system, and doc info
  - Group: `./catalog/group-platform-engineering.yaml`
  - User: `./catalog/user-kevin.yaml`
  - System: `./catalog/system-backstage.yaml`
  - Docs: `./catalog/docs-backstage.yaml`

### Running Locally

- [x] Deploy Backstage to a local Kubernetes cluster with Kind
  - [x] Build a Docker image for Backstage
  - [x] `./local/kubernetes/README.md`: `./backstage.sh kubernetes start` && `./backstage.sh kubernetes stop`
- [x] Run Backstage with Docker and Docker Compose
  - [x] Build a Docker image for Backstage
  - [x] `./local/docker/README.md`: `./backstage.sh docker start` && `./backstage.sh docker stop`

## Backstage Customization

Backstage project created using `npx @backstage/create-app` with the following options:

- `./backstage/app-config.kubernetes.yaml`: Kubernetes backend with modified URLs for the proxy
- `yarn add --cwd packages/app @backstage/plugin-techdocs` to add the techdocs plugin - [docs](https://backstage.io/docs/features/techdocs/techdocs-overview)

## TODO

- [x] Fix: Docker and Kubernetes deployments to load the correct app-config.yaml (Template, users ets. Currently they are not working)
- [ ] Feat: Create a new API template that can be used to create a new API repository in my personal GitHub account
- [x] Fix: Docs - Re-add the techdoc configs and verify creating a new template generates a viewable docs page
- [ ] Feat: Add docs to build to AWS S3
  - [ ] Figure out how tech-docs are working behind the scenes to generate the docs
- [ ] Feat: Build tech-docs in the CI/CD pipeline - [tutorial](https://backstage.io/docs/features/techdocs/configuring-ci-cd)
