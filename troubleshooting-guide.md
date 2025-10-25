# Troubleshooting Guide: Permission Denied Errors

## The Problem

We are facing a classic "chicken-and-egg" problem. The `deploy.sh` script runs as the `infra-deployer` service account, but this service account lacks the permissions needed to perform its tasks (like accessing the Cloud Build bucket). The script cannot grant these permissions to itself.

## The Solution: One-Time Manual Bootstrap

A user with **Project Owner** permissions (you) must perform a one-time manual setup to grant the necessary roles to the service account. This will break the permission deadlock.

### Instructions

1.  **Log in to Google Cloud with your own user account.** Ensure you are authenticated as `the-great-adambro@hotmail.com`.

2.  **Run the following command in your terminal:**

    ```bash
    gcloud projects add-iam-policy-binding tf-test-476002 --member="serviceAccount:infra-deployer@tf-test-476002.iam.gserviceaccount.com" --role="roles/owner"
    ```

    *This command grants the `infra-deployer` service account the **Owner** role, giving it all the permissions it needs to run the deployment.* 

3.  **Re-run the deployment script:**

    ```bash
    ./deploy.sh
    ```

After completing these steps, the `deploy.sh` script will have the necessary permissions and will execute successfully.
