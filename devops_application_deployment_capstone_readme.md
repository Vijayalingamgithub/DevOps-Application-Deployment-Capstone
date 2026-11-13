# DevOps Application Deployment Capstone

## 🚀 Project Overview
This project demonstrates an end-to-end CI/CD pipeline and containerized deployment workflow for a React-based e-commerce application using **Docker**, **Jenkins**, **AWS EC2**, and **Prometheus** monitoring.

---

## 🛠️ Architecture & Tech Stack
* **Version Control:** Git & GitHub (`dev` and `master` branches)
* **Containerization:** Docker & Docker Compose
* **CI/CD Automation:** Jenkins Multibranch Pipeline
* **Cloud Infrastructure:** AWS EC2 Instance (Ubuntu)
* **Container Registry:** Docker Hub (`dockervijay1998/dev` & `dockervijay1998/prod`)
* **Monitoring:** Prometheus (Node Exporter system metrics scraping)

---

## 📋 Step-by-Step Implementation & Execution

### 1. Clone Application & Create Branch
Cloned the base application repository, created a dedicated `dev` branch, and validated the build structure.
```bash
git clone https://github.com/sriram-R-krishnan/devops-build.git
cd devops-build
git switch -c dev
```

### 2. Containerization Configuration
Created the necessary configuration files for containerizing the application (`Dockerfile`, `nginx.conf`, `compose.yaml`, `.dockerignore`, and `.gitignore`).
* **`Dockerfile`**: Builds the React application and serves it via Nginx on port 80.
* **`nginx.conf`**: Configures routing and static file handling.
* **`compose.yaml`**: Orchestrates container services.

### 3. Build & Deployment Scripts
Wrote shell scripts for building and deploying Docker images:
* `build.sh`: Handles building container images with proper tags.
* `deploy.sh`: Handles pulling and running images on the server.

### 4. Jenkins CI/CD Pipeline Setup
Configured a **Multibranch Pipeline** in Jenkins pointing to the GitHub repository. The pipeline automates building, testing, tagging, and pushing images to Docker Hub (`dockervijay1998/dev` for the `dev` branch and `dockervijay1998/prod` for the `master` branch).

### 5. Prometheus Monitoring Setup
Deployed Prometheus via Docker Compose with Node Exporter running on port `9100` to scrape system and application health metrics.

---

## 📸 Project Verification Screenshots & Evidence

Below is the required collection of screenshots documenting the entire pipeline execution:

1. **Repository Cloning & Branch Setup:**
   ![Clone and Branch Setup](screenshots/clone_branch.png)

2. **Docker Files & Configuration Structure:**
   ![Docker Files Structure](screenshots/docker_files.png)

3. **Local Docker Build & Verification:**
   ![Docker Build and Run](screenshots/docker_build.png)

4. **Git Commit & Push to GitHub (`dev` & `master` branches):**
   ![Git Commit and Push](screenshots/git_push.png)

5. **AWS EC2 Instance Setup & Docker Installation:**
   ![AWS EC2 Docker Install](screenshots/aws_docker.png)

6. **Docker Hub Login & Image Pull Verification (`prod` repo):**
   ![Docker Hub Pull](screenshots/docker_hub_pull.png)

7. **Docker Images List on Server:**
   ![Docker Images](screenshots/docker_images.png)

8. **Deployed React Application Frontend (Port 80):**
   ![Deployed Site Page](screenshots/deployed_site.png)

9. **Jenkins Pipeline Configuration & Execution History:**
   ![Jenkins Pipeline View](screenshots/jenkins_pipeline.png)

10. **Jenkins Successful Build Console Output:**
    ![Jenkins Console Output](screenshots/jenkins_console.png)

11. **Prometheus Target Health & Metrics Status (UP):**
    ![Prometheus Target Health](screenshots/prometheus_targets.png)

---

## 🔗 Submission Links
* **GitHub Repository:** [DevOps-Application-Deployment-Capstone](https://github.com/Vijayalingamgithub/DevOps-Application-Deployment-Capstone)
* **Deployed Application URL:** `http://52.66.241.26`
* **Docker Hub Repositories:** 
  * Public Dev: `dockervijay1998/dev`
  * Private Prod: `dockervijay1998/prod`