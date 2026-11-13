# DevOps Application Deployment Capstone

End-to-end DevOps capstone: a React "OnlineShop" application is containerized with Docker (Nginx), versioned with a `dev` / `master` Git branching model, built and deployed through a **Jenkins multibranch pipeline**, run on **AWS EC2**, and monitored with **Prometheus**.

> Step-by-step proof of every stage is in [screenshot.md](./screenshot.md).

---

## Table of Contents
1. [Project Overview](#project-overview)
2. [Architecture](#architecture)
3. [Tech Stack](#tech-stack)
4. [Repository Structure](#repository-structure)
5. [Branching Strategy](#branching-strategy)
6. [Containerization](#containerization)
7. [Run Locally](#run-locally)
8. [Deploy to AWS EC2](#deploy-to-aws-ec2)
9. [CI/CD with Jenkins](#cicd-with-jenkins)
10. [Monitoring with Prometheus](#monitoring-with-prometheus)
11. [Security Practices](#security-practices)
12. [Screenshots](#screenshots)

---

## Project Overview

| Item | Detail |
|---|---|
| Application | React storefront ("OnlineShop") served as static build files |
| Source | Cloned from `sriram-R-krishnan/devops-build` (kept as the `upstream` remote) |
| Container image | Nginx (alpine) serving the React `build/` folder |
| Registry | Docker Hub (`dockervijay1998/prod`) |
| CI/CD | Jenkins multibranch pipeline (`devops-build`) with `dev` and `master` branches |
| Hosting | AWS EC2 (Ubuntu 24.04) running Docker |
| Monitoring | Prometheus scraping the app server (port 9100 metrics) |

## Architecture

```
 Developer (VS Code / PowerShell)
        |  git push (dev, master)
        v
 GitHub: DevOps-Application-Deployment-Capstone
        |  branch scan / webhook
        v
 Jenkins (EC2, :8080)  -- multibranch pipeline "devops-build"
        |  docker build -> docker push
        v
 Docker Hub  (dockervijay1998/prod)
        |  docker pull
        v
 App Server (EC2, Ubuntu 24.04, Docker)  -->  http://<app-server-ip>
        ^
        |  scrape :9100/metrics
 Prometheus (:9090)
```

## Tech Stack

- **Application:** React (pre-built static assets in `build/`)
- **Web server:** Nginx (alpine) with custom `nginx.conf` and a `/healthz` endpoint
- **Containers:** Docker, Docker Compose
- **Version control:** Git, GitHub
- **CI/CD:** Jenkins 2.580.2 (Pipeline as code via `Jenkinsfile`)
- **Cloud:** AWS EC2, Security Groups
- **Registry:** Docker Hub
- **Monitoring:** Prometheus
- **Tools:** VS Code, PowerShell, MobaXterm (SSH)

## Repository Structure

```
.
├── build/              # React production build (static files)
├── Dockerfile          # Nginx image serving ./build
├── nginx.conf          # Nginx site config (includes /healthz)
├── compose.yaml        # Local run with Docker Compose
├── build.sh            # Build script (executable)
├── deploy.sh           # Deploy script (executable)
├── Jenkinsfile         # Jenkins pipeline definition
├── .dockerignore
├── .gitignore          # Ignores .env, *.pem, *.key
├── .gitattributes      # Forces LF endings for *.sh
├── README.md
├── screenshot.md       # Evidence for each stage
└── screenshots/        # Image files used by screenshot.md
```

## Branching Strategy

| Branch | Purpose |
|---|---|
| `dev` | Development work. Containerization and the Jenkinsfile were committed here first |
| `master` | Stable branch, pushed after `dev` was verified |

The original remote was renamed to `upstream`, and this repository was added as `origin`:

```bash
git remote rename origin upstream
git remote add origin https://github.com/Vijayalingamgithub/DevOps-Application-Deployment-Capstone.git
git push -u origin dev
git branch master main      # local branch alias as shown in the screenshots
git push -u origin master
```

## Containerization

The app is packaged as an Nginx (alpine) image that copies `nginx.conf` into `/etc/nginx/conf.d/default.conf` and the React `build/` folder into `/usr/share/nginx/html/`.

Files added in the commit **"Containerize the React app and add build and deploy scripts"**:
`Dockerfile`, `nginx.conf`, `compose.yaml`, `.dockerignore`, `.gitignore`, `.gitattributes`, `build.sh`, `deploy.sh`.

`.gitattributes` enforces `*.sh text eol=lf` so shell scripts keep Linux line endings when edited on Windows, and `build.sh` / `deploy.sh` are committed with the executable bit (`100755`).

## Run Locally

```bash
git clone https://github.com/Vijayalingamgithub/DevOps-Application-Deployment-Capstone.git
cd DevOps-Application-Deployment-Capstone
git switch dev

docker compose -f compose.yaml up -d --build
docker compose -f compose.yaml ps
curl http://localhost/healthz      # expected output: ok
```

The app is then available at `http://localhost`.

## Deploy to AWS EC2

1. Launch an Ubuntu 24.04 EC2 instance and open the required ports in its Security Group (80 for the app, 22 for SSH).
2. Connect over SSH and install Docker:
   ```bash
   sudo apt-get update && sudo apt-get install -y docker.io
   sudo systemctl enable --now docker
   sudo docker --version
   sudo systemctl is-active docker
   ```
3. Log in to Docker Hub and pull the image:
   ```bash
   sudo docker login --username dockervijay1998
   sudo docker pull dockervijay1998/prod:latest
   sudo docker images
   ```
4. Run the container on port 80 and open `http://<ec2-public-ip>` in a browser.

## CI/CD with Jenkins

- Jenkins runs on its own EC2 instance on port **8080**.
- A **multibranch pipeline** named `devops-build` scans the GitHub repository and creates one job per branch (`dev`, `master`).
- The pipeline is defined in the `Jenkinsfile` committed to the repository ("Add Jenkins pipeline").
- Each run builds the Docker image, cleans up with `docker image prune -f`, and ends with `Pipeline succeeded for branch <branch>.`

Result: both the `dev` and `master` branch jobs finish with **SUCCESS**. Earlier failed runs (#5, #6 on `dev`) were fixed before the green builds, as shown in the build history.

## Monitoring with Prometheus

Prometheus runs on the app server (port **9090**) and scrapes two targets, both reporting **UP**:

| Job | Endpoint |
|---|---|
| `app-server` | `<app-server-ip>:9100/metrics` |
| `prometheus` | `localhost:9090/metrics` |

## Security Practices

- `.gitignore` excludes `.env` files, `*.pem` and `*.key` so secrets and SSH keys are never committed (`.env.example` is allowed).
- Docker Hub login uses a password/PAT entered at the prompt, not stored in the repository.
- Security Groups only expose the ports the project needs.

## Screenshots

All 16 stages, from cloning the app to Prometheus targets, are documented in **[screenshot.md](./screenshot.md)**.

## Author

**Vijayalingam**, DevOps / Cloud Engineering learner, Guvi Institute
GitHub: [Vijayalingamgithub](https://github.com/Vijayalingamgithub)
