resource "kind_cluster" "default" {
    name            = "project-cluster"
    node_image      = "kindest/node:v1.32.0"
    kubeconfig_path = pathexpand("./config/config")
    wait_for_ready  = true

    kind_config {
      kind        = "Cluster"
      api_version = "kind.x-k8s.io/v1alpha4"

      node {
          role = "control-plane"
          extra_port_mappings {
              container_port = 80
              host_port      = 80
              protocol       = "TCP"
          }
          extra_port_mappings {
              container_port = 443
              host_port      = 443
              protocol       = "TCP"
          }
      }
  }
}
