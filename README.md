# Test Project

This repository features a setup for Grafana, Loki, Promtail, an NGINX static website, and an NGINX Proxy Manager with Docker Compose, and another similar stack specially designed for Kubernetes, extended with Jenkins for automation.

## Directory Structure

- **`Compose/`**:
  - **`Grafana/`**: Contains the Docker configurations and related files to set up Grafana for visualizing data from Loki.
  - **`Loki/`**: Contains configurations for the Loki logging backend, which collects logs sent by Promtail.
  - **`Promtail/`**: Configurations for Promtail, responsible for gathering logs and forwarding them to Loki.
  - **`Proxy/`**: Configured NGINX Proxy Manager to handle request routing and SSL/TLS termination.
    - **Note**: Check the Proxy directory for a screenshot of the proxy settings.
  - **`Web/`**: Holds the static website content served through NGINX.

- **`Kubernetes/`**:
  - **`Kind/`**: Scripts and resources for setting up and managing local Kubernetes environments using Kind; includes setup for an NGINX proxy to route requests into the Kind cluster.
  - **`Grafana/`**: Kubernetes deployments for Grafana, including service and ingress configuration.
    - **`Dashboards/`**: Contains dashboard definitions in JSON format to be used within Grafana.
  - **`Loki/`**: Kubernetes manifests for deploying Loki, configured to align with cluster logging needs.
  - **`Promtail/`**: Kubernetes constructs like deployments and ConfigMaps, tailored to gather logs from cluster nodes and pods and feed them into Loki.
    - **Note**: There is a test script to push a hello label to Promtail; it should be visible in Grafana if you add a query.
  - **`Web/`**: Tooling and configurations for deploying and managing the NGINX static website inside the Kubernetes cluster.
    - **`Docker/`**:
      - **`content/`**: Contains `index.html` and other static files for the web.
      - **`Dockerfile`**: Dockerfile to build the NGINX server with the static content.
      - **`build.sh`**: Script to build the Docker image with the nginx configuration, perform the desired version bump, and write the build version to `version.txt`. This file will later be utilized by Jenkins for image deployment.
  - **`Jenkins/`**:
    - **`agent/`**:
      - **`Dockerfile`**: Dockerfile for building the custom Jenkins agent with Kubernetes tools installed.
      - **`build.sh`**: Script for compiling and setting up the Jenkins agent.
    - **`jobs/`**:
      - **`library/`**: XML files for predefined Jenkins job configurations.
      - **`configmap.sh`**: Script for creating a configmap in Kubernetes from the library's XML files.
      - **`scripts/`**: Collection of Bash scripts used within Jenkins jobs.
      - **`secrets/`**:
        - **Scripts for generating SSH keys, secret tokens, and adding them as secrets to Kubernetes.
        - **YAML definitions for service account tokens.
    - **`jenkins-deployment.yaml`**: YAML files for deploying Jenkins to the Kubernetes cluster, including necessary roles and configurations.

## Build Steps for Web

1. Navigate to the `Kubernetes/Web/Docker` directory.
2. Make your desired modifications to the static content or Docker configurations as needed.
3. Run the `build.sh` script to build the Docker image, choosing the type of version bump you want for the change. The script also loads the built image into Kind and records the version in `version.txt` for Jenkins to use.
4. Commit your changes and push them to the branch named "web".

## Deploy Steps for Web in Jenkins

1. Navigate to the Jenkins Dashboard to `job-deployment`.
2. Run the deployment job. This job automates the process of replacing the placeholder image tag in `web-deployment.yaml` with the actual version noted in the `version.txt` file, and applies the yaml.
3. Verify the deployment status through Jenkins' console output, and with kubectl to see the web pod.

## Steps for Jenkins Setup

1. Apply the Kubernetes yaml files including the token in the secrets directory.
2. In the Jenkins `secrets` directory, run the `generate_ssh_keys.sh` script. This will create a `keys` directory then generate a known hosts file and public and private keys in that directory. It will add them as Kubernetes secrets to the Jenkins namespace as well.
3. Run the `generate_kube_jenkins_sa_token_secret.sh`, which generates a plain text type of secret token that will be used to authenticate to the Kubernetes cluster from Jenkins, labels and adds the secret.

## Components Description

- **Grafana**: Provides powerful visualizations of metrics collected from various data sources including Loki.
- **Loki**: Designed for optimal horizontal scalability, Loki handles logs collection and aggregation.
- **Promtail**: Responsible for tracking and forwarding logs to Loki.
- **NGINX Static Website**: Efficiently serves static content, handling web traffic and page rendering.
- **NGINX Proxy Manager**: Manages proxy settings for web applications including SSL configuration and redirect rules.
- **Jenkins**: Orchestrates continuous integration and deployment pipelines within Kubernetes, managing the automation of building, testing, and deploying applications.

[!IMPORTANT] 
Please run the scripts from the actual directory where they reside in to ensure the relative paths are working correctly.