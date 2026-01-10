# 🚀 CI/CD Pipeline - Jenkins + Docker + Kubernetes

A complete end-to-end CI/CD pipeline demonstrating modern DevOps practices.

![Pipeline Status](https://img.shields.io/badge/build-passing-brightgreen)
![Docker](https://img.shields.io/badge/docker-integrated-blue)
![Kubernetes](https://img.shields.io/badge/kubernetes-deployed-326CE5)

## 📋 Table of Contents
- [Overview](#overview)
- [Architecture](#architecture)
- [Features](#features)
- [Tech Stack](#tech-stack)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Pipeline Stages](#pipeline-stages)
- [Project Structure](#project-structure)
- [Screenshots](#screenshots)
- [Lessons Learned](#lessons-learned)
- [Future Enhancements](#future-enhancements)
- [Contributing](#contributing)
- [License](#license)

## 🎯 Overview

This project implements a fully automated CI/CD pipeline that takes code from GitHub and deploys it to a Kubernetes cluster running on AWS EC2. Every push to the main branch triggers an automated build, test, and deployment process.

**Live Demo:** [Your Application URL if deployed]

## 🏗️ Architecture
```
GitHub Repository
       ↓
   Jenkins (CI/CD)
       ↓
   Docker Build
       ↓
   Docker Hub Registry
       ↓
   Kubernetes (K3s)
       ↓
   Running Application
```

## ✨ Features

- **Automated Builds:** Every Git push triggers automatic Docker image creation
- **Continuous Testing:** Health checks and container validation
- **Container Registry:** Automated push to Docker Hub
- **Kubernetes Deployment:** Zero-downtime rolling updates
- **Resource Optimized:** Runs on AWS t2.micro (free tier)
- **Complete Automation:** No manual intervention required

## 🛠️ Tech Stack

| Component | Technology |
|-----------|-----------|
| CI/CD | Jenkins (containerized) |
| Containerization | Docker |
| Orchestration | Kubernetes (K3s) |
| Cloud Platform | AWS EC2 |
| Container Registry | Docker Hub |
| Version Control | GitHub |
| Application | Node.js + Express |

## 📦 Prerequisites

- AWS Account (free tier eligible)
- Docker Hub account
- GitHub account
- Basic knowledge of:
  - Linux command line
  - Git
  - Docker
  - Kubernetes basics

## 🚀 Installation

### 1. Launch EC2 Instance
```bash
# Instance: t2.micro (1GB RAM, 30GB storage)
# OS: Ubuntu 22.04 LTS
# Security Groups: Ports 22, 8080, 30100
```

### 2. Install Docker
```bash
sudo apt update
sudo apt install -y docker.io
sudo usermod -aG docker $USER
```

### 3. Install K3s
```bash
curl -sfL https://get.k3s.io | sh -
```

### 4. Setup Jenkins
```bash
docker run -d \
  --name jenkins \
  -p 8080:8080 \
  -v jenkins_home:/var/jenkins_home \
  -v /var/run/docker.sock:/var/run/docker.sock \
  jenkins/jenkins:lts
```

### 5. Configure Pipeline
- Add Docker Hub credentials in Jenkins
- Create pipeline job pointing to this repository
- Trigger first build

## 📊 Pipeline Stages

| Stage | Description | Duration |
|-------|-------------|----------|
| Checkout | Clone repository from GitHub | ~5s |
| Build Info | Display build metadata | ~2s |
| Build Docker Image | Create container image | ~30s |
| Test Docker Image | Validate container health | ~15s |
| Login to Docker Hub | Authenticate with registry | ~2s |
| Push to Docker Hub | Upload image | ~20s |
| Update K8s Manifests | Update deployment configs | ~2s |
| Deploy to Kubernetes | Apply to cluster | ~30s |
| Verify Deployment | Check pod status | ~10s |
| Cleanup | Remove old images | ~5s |

**Total Pipeline Time:** ~2-3 minutes

## 📁 Project Structure
```
jenkins-cicd/
├── app.js                 # Node.js application
├── package.json           # Dependencies
├── Dockerfile            # Container definition
├── Jenkinsfile           # Pipeline configuration
├── k8s/
│   ├── deployment.yml    # Kubernetes deployment
│   └── service.yml       # Kubernetes service
└── README.md            # This file
```

## 📸 Screenshots

*Add screenshots of:*
- Jenkins pipeline success
- Docker Hub repository
- Kubernetes deployment
- Running application

## 💡 Lessons Learned

1. **Resource Management:** Successfully ran Jenkins + K3s on 1GB RAM using swap space
2. **Docker-in-Docker:** Learned to handle Docker socket permissions in containers
3. **Git Security:** Resolved Git ownership issues in containerized environments
4. **YAML Validation:** Importance of proper Kubernetes manifest structure
5. **Debugging:** Systematic approach to troubleshooting CI/CD pipelines

## 🔮 Future Enhancements

- [ ] Add automated unit tests
- [ ] Implement multi-stage Docker builds
- [ ] Add Prometheus monitoring
- [ ] Configure Grafana dashboards
- [ ] Implement blue-green deployments
- [ ] Add Slack/email notifications
- [ ] Create staging environment
- [ ] Add infrastructure as code (Terraform)

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📝 License

This project is open source and available under the MIT License.

## 👤 Author

**Hassan Zubair**
- GitHub: [@hzdevops52](https://github.com/hzdevops52)
- LinkedIn: [Your LinkedIn Profile]

## ⭐ Show Your Support

Give a ⭐️ if this project helped you learn about CI/CD pipelines!

---

**Built with ❤️ for learning DevOps**
```

---

## Quick LinkedIn Post (Short Version)
```
✅ Just deployed my first CI/CD pipeline!

Built an automated deployment system using:
- Jenkins for CI/CD
- Docker for containers
- Kubernetes for orchestration
- AWS EC2 for infrastructure

Every code push now automatically builds, tests, and deploys to production.

Learning DevOps one pipeline at a time! 🚀

GitHub: https://github.com/hzdevops52/jenkins-cicd

#DevOps #CICD #Jenkins #Docker #Kubernetes
