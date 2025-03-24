#!/bin/bash

# Exit immediately if a command fails
set -e

# Colors for output
GREEN="\033[0;32m"
RED="\033[0;31m"
RESET="\033[0m"

# Config directory and KUBECONFIG file location
CONFIG_DIR="./config"
KUBECONFIG_FILE="$CONFIG_DIR/config"
DEFAULT_KUBECONFIG="$HOME/.kube/config"  # Expand ~ explicitly to $HOME

# Namespace list
NAMESPACES=("web" "monitoring" "jenkins")

# Check if Terraform is installed
if ! command -v terraform &> /dev/null; then
  echo -e "${RED}Error: Terraform not installed. Please install Terraform before proceeding.${RESET}"
  exit 1
fi

# Check if kubectl is installed
if ! command -v kubectl &> /dev/null; then
  echo -e "${RED}Error: kubectl not installed. Please install kubectl before proceeding.${RESET}"
  exit 1
fi

# Ensure the config directory exists
if [[ ! -d "$CONFIG_DIR" ]]; then
  echo -e "${RED}Error: Config directory '$CONFIG_DIR' not found. Please check your setup.${RESET}"
  exit 1
fi

# Ensure the ~/.kube directory exists
if [[ ! -d "$HOME/.kube" ]]; then
  echo -e "${GREEN}Creating ~/.kube directory.${RESET}"
  mkdir -p "$HOME/.kube"
fi

# Print a section header for readability
function print_section() {
  echo -e "${GREEN}\n===================================\n${1}\n===================================${RESET}"
}

# Run `terraform init`
print_section "Running 'terraform init'"
terraform init

# Run `terraform plan`
print_section "Running 'terraform plan'"
terraform plan -out=tfplan

# Confirm and run `terraform apply`
print_section "Applying the Terraform plan"
read -p "Do you want to proceed with the 'terraform apply'? (yes/no) " CONFIRM
if [[ "$CONFIRM" == "yes" ]]; then
  terraform apply tfplan

  # Only proceed to handle kubeconfig if Terraform apply was successful
  if [[ $? -eq 0 ]]; then
    print_section "Setting up kubeconfig"

    # Copy kubeconfig to the default location (~/.kube/config)
    if [[ -f "$KUBECONFIG_FILE" ]]; then
      echo -e "${GREEN}Copying kubeconfig from $KUBECONFIG_FILE to $DEFAULT_KUBECONFIG.${RESET}"
      
      # Ensure target file's directory exists
      if [[ ! -d "$(dirname "$DEFAULT_KUBECONFIG")" ]]; then
        echo -e "${GREEN}Creating directory for kubeconfig at $(dirname "$DEFAULT_KUBECONFIG").${RESET}"
        mkdir -p "$(dirname "$DEFAULT_KUBECONFIG")"
      fi

      # Backup existing kubeconfig, if exists
      if [[ -f "$DEFAULT_KUBECONFIG" ]]; then
        echo -e "${GREEN}Backing up existing kubeconfig to $DEFAULT_KUBECONFIG.bak.${RESET}"
        cp "$DEFAULT_KUBECONFIG" "$DEFAULT_KUBECONFIG.bak"
      fi

      # Merge the new kubeconfig with the existing one
      KUBECONFIG="$KUBECONFIG_FILE:$DEFAULT_KUBECONFIG" kubectl config view --flatten > "$DEFAULT_KUBECONFIG"
      echo -e "${GREEN}Kubeconfig successfully updated at $DEFAULT_KUBECONFIG.${RESET}"
      
      # Optionally set KUBECONFIG to point to the default location for the current session
      export KUBECONFIG="$DEFAULT_KUBECONFIG"
      echo -e "${GREEN}KUBECONFIG has been set to $DEFAULT_KUBECONFIG for this session.${RESET}"
    else
      echo -e "${RED}Error: Kubeconfig file not found at $KUBECONFIG_FILE.${RESET}"
      exit 4
    fi

    # Create specified namespaces
    print_section "Creating Kubernetes namespaces"
    for NAMESPACE in "${NAMESPACES[@]}"; do
      if kubectl get namespace "$NAMESPACE" &> /dev/null; then
        echo -e "${GREEN}Namespace '$NAMESPACE' already exists. Skipping creation.${RESET}"
      else
        kubectl create namespace "$NAMESPACE"
        echo -e "${GREEN}Namespace '$NAMESPACE' created successfully.${RESET}"
      fi
    done

  else
    echo -e "${RED}Terraform apply failed. Exiting.${RESET}"
    exit 3
  fi
else
  echo -e "${RED}Aborted 'terraform apply'. Exiting.${RESET}"
  exit 2
fi