# Full-Stack Application with Terraform and Google Cloud

This repository contains a full-stack application with a React-based UI and a backend infrastructure managed by Terraform. The development environment is defined declaratively using Nix in the `.idx/dev.nix` file, ensuring a consistent and reproducible setup for all developers.

## Development Environment

The development environment is managed by the `.idx/dev.nix` file, which installs all the necessary tools and configures the workspace. When you open this project in IDX, the environment is automatically configured for you.

## Authentication

This project uses Google Cloud services, and authentication is handled in a secure manner, without committing credentials to the repository.

### Local Development

For local development, you need to authenticate using your own Google Cloud account. To do this, run the following command in the terminal:

```bash
gcloud auth application-default login
```

This will open a browser window and prompt you to log in. Your credentials will be stored securely on your local machine, and any tools that need to access Google Cloud (like `gcloud` or `terraform`) will automatically use them.

### Automated Deployments (CI/CD)

Automated deployments are handled by Google Cloud Build. The `cloudbuild.yaml` file is configured to use a service account for authentication, so you do not need to manage any service account keys.

## Running the Application

### UI Service

To run the UI service, navigate to the `ui` directory and start the development server:

```bash
cd ui
npm install
npm run dev
```

## Infrastructure Management

The backend infrastructure is defined in the `infra` directory using Terraform. The `deploy.sh` and `destroy.sh` scripts are provided to simplify the process of creating and destroying the infrastructure from your local development environment.

### Creating the Infrastructure

The `deploy.sh` script will provision all the necessary Google Cloud resources using Terraform.

```bash
./deploy.sh
```

This script reads configuration from `config.sh`, initializes Terraform, and applies the infrastructure plan.

### Destroying the Infrastructure

The `destroy.sh` script will tear down all the infrastructure created by Terraform. This is useful for cleaning up resources and avoiding unnecessary costs.

```bash
./destroy.sh
```

**Warning:** This command will permanently delete your deployed resources.

## Automated Deployment

In addition to manual deployment scripts, this project is configured for automated deployments using Google Cloud Build. Pushing to the main branch can be configured to trigger a build that deploys the latest version of the application.
