# Test Project

This repository features a setup for Grafana, Loki, Promtail, an NGINX static website, and an NGINX Proxy Manager with Docker Compose, and another similar stack for Kubernetes, extended with Jenkins.

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
      - **`build.sh`**: Script to build the Docker image with the nginx configuration and write the version to a version.txt file, which is then used by Jenkins to identify the correct image.
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

## Components Description

- **Grafana**: Provides powerful visualizations of metrics collected from various data sources like Loki.
- **Loki**: Designed for optimal horizontal scalability, Loki handles logs collection and aggregation.
- **Promtail**: Responsible for tracking and forwarding logs to Loki.
- **NGINX Static Website**: Efficiently serves static content, handling web traffic and page rendering.
- **NGINX Proxy Manager**: Manages proxy settings for web applications including SSL configuration and redirect rules.


Please find the respective directories for more detailed instructions on setup and configurations.