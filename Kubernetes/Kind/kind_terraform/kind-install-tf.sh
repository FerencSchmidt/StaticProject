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

# Check if Terraform is installed
if ! command -v terraform &> /dev/null; then
  echo -e "${RED}Error: Terraform not installed. Please install Terraform before proceeding.${RESET}"
  exit 1
fi

# Ensure the config directory exists
if [[ ! -d "$CONFIG_DIR" ]]; then
  echo -e "${RED}Error: Config directory '$CONFIG_DIR' not found. Please check your setup.${RESET}"
  exit 1
fi

# Print a section header to easily distinguish parts
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

  # Only export the KUBECONFIG after a successful Terraform apply
  if [[ $? -eq 0 ]]; then
    print_section "Setting KUBECONFIG"
    export KUBECONFIG="$KUBECONFIG_FILE"
    echo -e "${GREEN}KUBECONFIG has been set to $KUBECONFIG_FILE for accessing the cluster.${RESET}"
  else
    echo -e "${RED}Terraform apply failed. Exiting.${RESET}"
    exit 3
  fi
else
  echo -e "${RED}Aborted 'terraform apply'. Exiting.${RESET}"
  exit 2
fi