# Shared Jenkins (CI/CD) — Configuration-as-Code

A single, self-contained Jenkins service that runs the CI/CD pipelines for **multiple
projects** from one host. Everything is declarative: the server image, its plugins, its
credentials, and its pipeline jobs are all defined in this repository via **Jenkins
Configuration-as-Code (JCasC)** and **Job DSL**, and the host itself is provisioned with
**Terraform**.

Jenkins runs on a dedicated AWS EC2 instance (region `ap-northeast-1`, Tokyo) with a static
Elastic IP, so it is independent of any developer laptop.

- **URL:** http://18.181.56.52:8080
- **Instance:** `t3.large`, provisioned by [`terraform/`](terraform/)
- **Build trigger:** manual only (no SCM polling)

## Projects served

| Job(s) | Source repo | What it does |
|---|---|---|
| `telephony-ec2`, `telephony-missed-call`, `telephony-ivr` | `Telephony-Service` (by branch) | Build & deploy the telephony FreeSWITCH variants. |
| `agri-catalogue-service` | `Open-Agri-Stack/OAS-Infra` (drives the build) | Build the app image, push to ECR (`service-catalogue`), deploy to the K8s node via Helm over SSH. Requires the `EC2_HOST` build parameter. |

The pipeline logic lives in each project's own `Jenkinsfile` (checked out via "Pipeline
script from SCM"); this repo only defines the jobs and credentials that point at them.

## Repository layout

- `Dockerfile` — the custom Jenkins image (JDK17 + Maven, Docker CLI, AWS CLI, `kubectl`, `openssh-client`).
- `casc.yaml` — JCasC: security realm, credentials, and the Job DSL that provisions all pipeline jobs.
- `docker-compose.yml` — runs the container (host Docker socket mounted, JVM/Maven memory caps, env from `.env`).
- `plugins.txt` — plugins baked into the image.
- `.env.example` — every environment variable the stack needs (copy to `.env` on the host).
- `terraform/` — the EC2 instance, security group, Elastic IP association, and userdata bootstrap.

## Credentials (provisioned by JCasC from `.env`)

| ID | Type | Used by |
|---|---|---|
| `aws-credentials` | AWS key | ECR (all projects) |
| `github-credentials` | username/token | SCM checkout (all projects) |
| `ssh-private-key` | SSH key (ubuntu) | Telephony deploy targets |
| `kubeconfig` | secret file | Telephony Kubernetes deploy |
| `DB_CREDENTIALS` | username/password | agri-catalogue Postgres (`oas_user`) |
| `ES_CREDENTIALS` | username/password | agri-catalogue Elasticsearch |
| `ec2-deploy-key` | SSH key (ubuntu) | agri-catalogue K8s node deploy |

## Running / updating the server

```bash
# On the Jenkins host: fill in secrets, then build + start.
cp .env.example .env      # edit .env with real values
docker compose up -d --build
```

Reload JCasC after editing `casc.yaml` **without** rebuilding (config-only changes):

```bash
curl -X POST -u "admin:<password>" "http://18.181.56.52:8080/configuration-as-code/reload"
```

A rebuild (`docker compose up -d --build`) is required when the `Dockerfile`, `plugins.txt`,
or the container environment changes.

### Provision / change the host (Terraform)

```bash
cd terraform
terraform init
terraform plan     # should report no changes against the running instance
terraform apply
```

The Elastic IP (`18.181.56.52`, `eipalloc-0d46f9e87aebd2da1`) is associated to the instance,
so the URL is stable across rebuilds.

## Onboarding a new project

1. Add a `pipelineJob('<name>') { ... }` block to the `jobs:` list in `casc.yaml`, pointing
   `cpsScm` at the project's repo and its `Jenkinsfile` (`scriptPath`). Add build parameters
   if the pipeline needs them.
2. Add any new credentials the project needs under `credentials.system.domainCredentials` in
   `casc.yaml`, using `${ENV}` placeholders.
3. Wire the matching env vars into `docker-compose.yml` and document them in `.env.example`.
4. Update the host `.env`, then `docker compose up -d --build` (or reload JCasC if only
   `casc.yaml` changed).
