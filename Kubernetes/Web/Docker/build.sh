#!/bin/bash
CLUSTER_NAME="kind"

# List loaded images from the KinD cluster
docker exec -it ${CLUSTER_NAME}-control-plane crictl images

# To delete a loaded image use this:
# docker exec -it $(kind get clusters | head -1)-control-plane crictl rmi IMAGENAME

echo "----------------------------------------------------------------------------------------------------------------------"

# Ask user if they want to build the Docker image
read -p "Do you want to build the Docker image? (y/n): " build_decision

if [[ "$build_decision" =~ ^[Yy]$ ]]; then
    # Ask for the version number
    read -p "Enter the version number for the Docker image (e.g., 1.0.0): " version

    # Build the Docker image with the specific tag
    echo "Building Docker image with version: $version"
    docker build -t webapp:$version .
    echo "Build complete."

    # Ask user if they want to load the image into KinD
    read -p "Do you want to load the image into KinD? (y/n): " load_decision

    if [[ "$load_decision" =~ ^[Yy]$ ]]; then
        # Load the Docker image into the KinD cluster
        kind load docker-image webapp:$version --name $CLUSTER_NAME
        echo "Image loaded into KinD."
    else
        echo "Skipping image load into KinD."
    fi
else
    echo "Skipping Docker build."
fi