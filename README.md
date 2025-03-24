# Test Project

This repository features a setup for Grafana, Loki, Promtail, an NGINX static website, and an NGINX Proxy Manager with Docker Compose, and another similar stack specially designed for Kubernetes, extended with Jenkins for automation.

## Prerequisites

- **KinD (Kubernetes in Docker):** version 0.26.0
  - [Kind Quick Start](https://kind.sigs.k8s.io/docs/user/quick-start/)
  
- **Windows Subsystem for Linux (WSL):** Ubuntu-22.04 (Default)

- **Docker Desktop:** WSL 2 based engine, Docker Engine v20.10.8

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
      - **Note**: https://kind.sigs.k8s.io/docs/user/ingress
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
          - **Note**: Please change the cluster name var to your actual cluster's name.
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

- **`Kubernetes/Kind/Kind_Terraform/`**:
  - Terraform scripts and resources for automating the creation of a KinD Kubernetes cluster.
  - Includes:
    - **Main Configuration (`main.tf`)**: Sets the cluster name, node image version, port mappings (`80` and `443` for HTTP/HTTPS), and generates a kubeconfig.
    - **Variables (`variables.tf`)**: Allows customization of variables such as cluster name, node version, and more.
    - **Outputs (`outputs.tf`)**: Provides useful information on the generated cluster, such as kubeconfig paths or cluster details.
    - **Apply Script (`kind-install-tf.sh`)**: A Bash script to initialize, plan, and apply Terraform configuration to create the KinD cluster and set up the kubeconfig.
    - **Prerequisites**:
      - Terraform must be installed and available in your environment. Additionally, KinD is required to run the Kubernetes cluster on a local machine.
      - The Bash script uses the `~/config/` directory for temporary kubeconfig files but also supports copying credentials to `~/.kube/config`.
  - **Notes on Usage**:
    - Run the `kind-install-tf.sh` script from the same directory to ensure that all relative paths are resolved correctly.
    - The `outputs.tf` file provides details such as the expected kubeconfig location for ease of debugging.
    - Logs for the created cluster are accessible through the Docker logs of the KinD control-plane container.

---

## KinD cluster creation

1. Navigate to the `Kubernetes/Kind/kind_terraform` directory.
2. Run the `kind-install-tf.sh` script. Please check the kubeconfig afterwards, you may have to export KUBECONFIG=~/.kube/config
3. Check the namespaces, it should create web, jenkins and monitoring.

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

1. In the Jenkins `secrets` directory, run the `generate_ssh_keys.sh` script. This will create a `keys` directory then generate a known hosts file and public and private keys in that directory. It will add them as Kubernetes secrets to the Jenkins namespace as well.
2. Run the `create_configmap_for_jobs.sh` in the jobs directory to create the necessary configmaps for jenkins to mount.
3. Apply the Kubernetes yaml files including the token in the secrets directory. 
4. Run the `generate_kube_jenkins_sa_token_secret.sh`, which generates a plain text type of secret token that will be used to authenticate to the Kubernetes cluster from Jenkins, labels and adds the secret
5. The master password should be visible in the jenkins pod logs.
6. For the custom agent, please run the `build.sh` in `Jenkins/agent`. It will build the custom image and loads it into KinD
    - **Note**: Mind the cluster name in the script file.
> [!IMPORTANT]
> In your git repo, add your key as a deploy key so Jenkins can access it.

## Components Description

- **Grafana**: Provides powerful visualizations of metrics collected from various data sources including Loki.
- **Loki**: Designed for optimal horizontal scalability, Loki handles logs collection and aggregation.
- **Promtail**: Responsible for tracking and forwarding logs to Loki.
- **NGINX Static Website**: Efficiently serves static content, handling web traffic and page rendering.
- **NGINX Proxy Manager**: Manages proxy settings for web applications including SSL configuration and redirect rules.
- **Jenkins**: Orchestrates continuous integration and deployment pipelines within Kubernetes, managing the automation of building, testing, and deploying applications.

> [!IMPORTANT]
> Please run the scripts from the actual directory where they reside in to ensure the relative paths are working correctly.