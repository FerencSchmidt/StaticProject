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
  - This section will contain Kubernetes resources and manifests. (Content to be added)

## Components Description

- **Grafana**: Provides powerful and beautiful visualizations of metrics collected from various data sources like Loki.
- **Loki**: Designed for optimal horizontal scalability, Loki handles logs collection and aggregation.
- **Promtail**: Responsible for tracking and forwarding logs to Loki.
- **NGINX Static Website**: Serves static content, efficiently handling web traffic and page rendering.
- **NGINX Proxy Manager**: Manages proxy settings for web applications including SSL configuration and redirect rules.


## Kind cluster

- **Proxy to access kind cluster in wsl from Windows**:  
```
kubectl proxy --port 8001 --reject-paths "^/api/./pods/./attach"
```

- **For OpenLENS**:
```
apiVersion: v1
kind: Config
clusters:
  - name: "WSL Cluster"
    cluster:
      server: http://localhost:8001
users:
  - name: nouser
contexts:
  - name: "WSL Cluster"
    context:
      cluster: "WSL Cluster"
      user: nouser
current-context: "WSL Cluster"
preferences: {}
```