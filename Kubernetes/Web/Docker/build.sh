#!/bin/bash
CLUSTER_NAME="kind"

# Path to version file
VERSION_FILE="version.txt"

# List loaded images from the KinD cluster
docker exec -it ${CLUSTER_NAME}-control-plane crictl images

echo "----------------------------------------------------------------------------------------------------------------------"
read -p "Do you want to build the Docker image? (y/n): " build_decision

if [[ "$build_decision" =~ ^[Yy]$ ]]
then
    # Check if version file exists, and read from it
    if [ -f "$VERSION_FILE" ]; then
        read -r current_version < $VERSION_FILE
        echo "Current version read from file: $current_version"
    else
        # Default version if file does not exist
        current_version="0.0.1"
        echo "No version file found. Defaulting to version $current_version"
    fi

    # Increment version number
    IFS='.' read -ra ADDR <<< "$current_version"
    major=${ADDR[0]}
    minor=${ADDR[1]}
    patch=${ADDR[2]}

    read -p "Increment (1) major, (2) minor, or (3) patch? " inc_choice

    case $inc_choice in
      1) major=$((major+1)); minor=0; patch=0;;
      2) minor=$((minor+1)); patch=0;;
      3) patch=$((patch+1));;
      *) echo "Invalid choice, incrementing patch by default"; patch=$((patch+1));;
    esac
    
    # Assembling new version
    new_version="${major}.${minor}.${patch}"

    # Update version file
    echo $new_version > $VERSION_FILE
    echo "New version updated in version file: $new_version"

    # Build the Docker image with the specific tag
    echo "Building Docker image with version: $new_version"
    docker build -t webapp:$new_version .
    echo "Build complete."

    # Ask user if they want to load the image into KinD
    read -p "Do you want to load the image into KinD? (y/n): " load_decision

    if [[ "$load_decision" =~ ^[Yy]$ ]]; then
        # Load the Docker image into the KinD cluster
        kind load docker-image webapp:$new_version --name $CLUSTER_NAME
        echo "Image loaded into KinD."
    else
        echo "Skipping image load into KinD."
    fi
else
    echo "Skipping Docker build."
fi