#!/bin/bash
echo "======================== START SECTION: BUILD ========================"
pwd
ls -lah
kubectl get pods -n jenkins

# Define path to version file
VERSION_FILE="$WORKSPACE/Kubernetes/Web/Docker/version.txt"
DEPLOYMENT_TEMPLATE_PATH="$WORKSPACE/Kubernetes/Web/web-deployment.yaml"
MODIFIED_DEPLOYMENT_PATH="$WORKSPACE/Kubernetes/Web/modified_web-deployment.yaml"

ls -lah $WORKSPACE/Kubernetes/Web/Docker

# Check if the version file exists and read from it
if [ -f "$VERSION_FILE" ]; then
    read -r version_tag < $VERSION_FILE
    echo "Version read from file: $version_tag"
else
    echo "version.txt file not found. Failing the build."
    exit 1
fi

# Substitute the version tag in the deployment template using envsubst
VERSION_TAG=$version_tag envsubst '${VERSION_TAG}' < $DEPLOYMENT_TEMPLATE_PATH > $MODIFIED_DEPLOYMENT_PATH
echo "Deployment file has been updated with new tag: $version_tag"
ls -lah $WORKSPACE/Kubernetes/Web/

# Apply the deployment
kubectl apply -f $MODIFIED_DEPLOYMENT_PATH
echo "Kubernetes Deployment has been applied successfully."

echo "======================== END SECTION: BUILD ========================"