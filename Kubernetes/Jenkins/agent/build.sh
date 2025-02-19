#!/bin/bash

CLUSTER_NAME="kind"

# Function to check for an existing Docker image in the local registry
check_image_exists() {
  if [[ $(docker images -q jenkins-kubectl-agent 2> /dev/null) == "" ]]; then
    echo "Docker image 'jenkins-kubectl-agent' does not exist."
    return 1
  else
    echo "Docker image 'jenkins-kubectl-agent' exists."
    return 0
  fi
}

# Function to build the Docker image
build_image() {
  echo "Building Docker image 'jenkins-kubectl-agent'..."
  docker build -t jenkins-kubectl-agent .
  echo "Build complete."
}

# Function to load the Docker image into KinD
load_image_into_kind() {
  echo "Loading 'jenkins-kubectl-agent' into KinD..."
  kind load docker-image jenkins-kubectl-agent --name $CLUSTER_NAME
  echo "Image loaded into KinD."
}

# Check if the image exists and decide on the next steps
if ! check_image_exists; then
  build_image
  load_image_into_kind
else
  read -p "The image exists. Would you like to rebuild it? (y/n): " rebuild_decision
  if [[ "$rebuild_decision" =~ ^[Yy]$ ]]; then
    build_image
  fi
  read -p "Would you like to load/reload the image into KinD? (y/n): " load_decision
  if [[ "$load_decision" =~ ^[Yy]$ ]]; then
    load_image_into_kind
  else
    echo "Skipping image load into KinD."
  fi
fi

# Optionally, list loaded images to verify
docker exec -it ${CLUSTER_NAME}-control-plane crictl images

echo "----------------------------------------------------------------------------------------------------------------------"