# Cloud Project

## Project Overview
Cloud Project is a modular healthcare management platform designed to streamline appointment scheduling, electronic health records (EHR), and patient management. The platform leverages microservices architecture, containerization, and Kubernetes for scalable, reliable deployment in both development and production environments.

## Features
- **Appointment Scheduling:** Manage and schedule patient appointments efficiently.
- **Electronic Health Records (EHR):** Securely store and access patient medical records.
- **Patient Management:** Comprehensive patient data management and tracking.
- **Microservices Architecture:** Decoupled services for scalability and maintainability.
- **Dockerized Services:** Each service is containerized for consistent deployment.
- **Kubernetes Orchestration:** Automated deployment, scaling, and management of services.
- **Environment Overlays:** Separate configurations for development, staging, and production.

## Project Structure
```
Cloud_Project-main/
├── cloud_project/
│   └── k8s/
│       ├── base/
│       ├── overlays/
│       ├── deploy.sh
│       └── README.md
├── AppointmentScheduling.API/
├── EHR.API/
├── PatientManagement.API/
├── HealthcareManagement.Shared/
├── HealthcareManagement.sln
├── base/
├── build-images.ps1
├── configmap.yaml
├── docker-compose.yml
├── docker-compose.dev.yml
├── docker-compose.staging.yml
├── docker-compose.prod.yml
└── README.md
```
- **AppointmentScheduling.API, EHR.API, PatientManagement.API:** Core microservices for healthcare operations.
- **HealthcareManagement.Shared:** Shared libraries and resources.
- **cloud_project/k8s:** Kubernetes manifests and deployment scripts.
- **docker-compose*.yml:** Docker Compose files for local and multi-environment orchestration.
- **build-images.ps1:** PowerShell script for building Docker images.

## Installation Instructions
1. **Clone the Repository:**
   ```bash
   git clone <repository-url>
   cd Cloud_Project-main
   ```
2. **Install Prerequisites:**
   - [.NET SDK](https://dotnet.microsoft.com/download)
   - [Docker](https://www.docker.com/get-started)
   - [kubectl](https://kubernetes.io/docs/tasks/tools/)
   - [Kubernetes Cluster](https://minikube.sigs.k8s.io/) (Minikube, Kind, or cloud provider)

3. **Build Docker Images:**
   ```powershell
   ./build-images.ps1
   ```

4. **Push Images to Registry:**
   Ensure your Docker images are available to your Kubernetes cluster (push to Docker Hub or private registry as needed).

## Usage Guide
### Local Development
- **Using Docker Compose:**
  ```bash
  docker-compose -f docker-compose.dev.yml up --build
  ```
- **Access Services:**
  - Appointment Scheduling API: http://localhost:<port>
  - EHR API: http://localhost:<port>
  - Patient Management API: http://localhost:<port>

### Kubernetes Deployment
- **Navigate to k8s directory:**
  ```bash
  cd cloud_project/k8s
  ```
- **Deploy to Development Environment:**
  ```bash
  ./deploy.sh dev
  kubectl get pods -n healthcare-dev
  kubectl get services -n healthcare-dev
  ```
- **Monitor Logs:**
  ```bash
  kubectl logs <pod-name> -n <namespace>
  kubectl logs -f <pod-name> -n <namespace>
  ```
- **Rolling Updates:**
  ```bash
  kubectl set image deployment/<deployment-name> <container-name>=<new-image> -n <namespace>
  kubectl rollout status deployment/<deployment-name> -n <namespace>
  kubectl rollout undo deployment/<deployment-name> -n <namespace>
  ```

## Deployment Instructions
1. **Configure Kubernetes Cluster:**
   - Ensure your cluster is running and `kubectl` is configured.
2. **Apply Base Manifests:**
   ```bash
   kubectl apply -k k8s/base
   ```
3. **Apply Environment Overlays:**
   ```bash
   kubectl apply -k k8s/overlays/dev
   # or staging/prod as needed
   ```
4. **Verify Deployments:**
   ```bash
   kubectl get all -n <namespace>
   ```

## License
This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.