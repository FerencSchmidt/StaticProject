#!/bin/bash

# Environment Variables
CLUSTER_NAME="project-cluster"
IMAGE_NAME="jenkins-kubectl-agent"  

# Check for an existing Docker image in the local registry
check_image_exists() {
  if [[ $(docker images -q $IMAGE_NAME 2> /dev/null) == "" ]]; then
    echo "Docker image '$IMAGE_NAME' does not exist."
    return 1
  else
    echo "Docker image '$IMAGE_NAME' exists."
    return 0
  fi
}

# Build the Docker image
build_image() {
  echo "Building Docker image '$IMAGE_NAME'..."
  docker build -t $IMAGE_NAME .
  echo "Build complete."
}

# Load the Docker image into KinD
load_image_into_kind() {
  echo "Loading '$IMAGE_NAME' into KinD..."
  kind load docker-image $IMAGE_NAME --name $CLUSTER_NAME
  echo "Image loaded into KinD."
}

# Check if the image exists
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

# List loaded images to verify
echo "----------------------------------------------------------------------------------------------------------------------"
docker exec -it ${CLUSTER_NAME}-control-plane crictl images
echo "----------------------------------------------------------------------------------------------------------------------"