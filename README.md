# Jenkins CI/CD Configuration-as-Code

This repository provides a fully Dockerized, pre-configured Jenkins server running **Jenkins Configuration-as-Code (JCasC)**. It automatically registers necessary AWS ECR credentials and provisions your two branch-specific build pipelines:
1. `telephony-missed-call` (missed call flow)
2. `telephony-ivr` (multilingual IVR flow)

## Getting Started

### 1. Configure Secrets
Create a `.env` file in the root of this repository. This file is ignored by Git and will store your secure credentials:

```ini
# Administrator Dashboard Login
JENKINS_ADMIN_USER=admin
JENKINS_ADMIN_PASSWORD=your_secure_password_here

# AWS Access Credentials (required to push Docker images to ECR)
AWS_ACCESS_KEY_ID=AKIAXXXXXXXXXXXXXXXX
AWS_SECRET_ACCESS_KEY=wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY
AWS_DEFAULT_REGION=ap-northeast-1

# GitHub Credentials (required to clone the Telephony repo)
GITHUB_USER=your_github_username
GITHUB_TOKEN=ghp_yourPersonalAccessTokenHere
```

---

### 2. Build and Launch Jenkins
Build the custom image (pre-loading the plugins) and run the container in the background:

```bash
# Build custom image & launch services
docker-compose up -d --build
```

Jenkins will be available at: **`http://localhost:8080`** (or your server's public IP).

---

### 3. Automatic Resource Configuration
Once initialized:
* **Admin Login:** Log in using the `JENKINS_ADMIN_USER` and `JENKINS_ADMIN_PASSWORD` you defined.
* **Credentials:** JCasC automatically provisions `aws-credentials` and `github-credentials` in the credentials manager.
* **Pipelines:** The two build pipeline jobs `telephony-missed-call` and `telephony-ivr` are auto-generated and configured to poll GitHub for commits every 5 minutes.
* **Storage Persistence:** Jenkins configuration changes and logs are persisted locally in the `jenkins_data` Docker volume.
