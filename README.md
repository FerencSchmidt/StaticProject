# Test Project

This repository features a setup for Grafana, Loki, Promtail, an NGINX static website, and an NGINX Proxy Manager. This setup is bundled using Docker Compose for ease of deployment.

## Directory Structure

- **`Compose/`**
  - **`Grafana/`**: Contains the Docker configurations and related files to set up Grafana for visualizing data from Loki.
  - **`Loki/`**: Contains configurations for the Loki logging backend, which collects logs sent by Promtail.
  - **`Promtail/`**: Configurations for Promtail, responsible for gathering logs and forwarding them to Loki.
  - **`Proxy/`**: Configured NGINX Proxy Manager to handle request routing and SSL/TLS termination.
    - **Note**: Check the Proxy directory for a screenshot of the proxy settings.
  - **`Web/`**: Holds the static website content served through NGINX.
  
- **`Kubernetes/`**
  - **`Kind/`**: Scripts and resources for setting up and managing local Kubernetes environments using Kind; includes setup for an NGINX proxy to route requests into the Kind cluster.
  - **`Grafana/`**: Kubernetes deployments for Grafana, including service and ingress configuration.
  - **`Loki/`**: Kubernetes manifests for deploying Loki, configured to align with cluster logging needs.
  - **`Promtail/`**: Kubernetes constructs like deployments and ConfigMaps, tailored to gather logs from cluster nodes and pods and feed them into Loki.
    - **Note**: There is a test script to push a hello label to promtail, it should be visible in grafana if you add a query.
  - **`Web/`**: Static site TODO
    - **Note**: The image for the nginx static website should be built from the Docker directory in here, and then it can be loaded to KinD: 
    
        ```kind load docker-image webapp:latest```


## Components Description

- **Grafana**: Provides powerful and beautiful visualizations of metrics collected from various data sources like Loki.
- **Loki**: Designed for optimal horizontal scalability, Loki handles logs collection and aggregation.
- **Promtail**: Responsible for tracking and forwarding logs to Loki.
- **NGINX Static Website**: Serves static content, efficiently handling web traffic and page rendering.
- **NGINX Proxy Manager**: Manages proxy settings for web applications including SSL configuration and redirect rules.
