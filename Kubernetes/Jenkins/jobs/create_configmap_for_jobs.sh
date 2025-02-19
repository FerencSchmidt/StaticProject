#!/bin/bash

# Variables
NAMESPACE=jenkins
CONFIGMAP_NAME=jenkins-jobs
DIRECTORY=./library/

# Check if the ConfigMap exists
if kubectl get configmap $CONFIGMAP_NAME -n $NAMESPACE; then
    echo "ConfigMap $CONFIGMAP_NAME exists. Updating..."
    # Deleting the old ConfigMap first (to be replaced with new data)
    kubectl delete configmap $CONFIGMAP_NAME -n $NAMESPACE
    # Create a new ConfigMap with the updated data
    kubectl create configmap $CONFIGMAP_NAME --from-file=$DIRECTORY -n $NAMESPACE
else
    echo "ConfigMap $CONFIGMAP_NAME does not exist. Creating..."
    # Create a new ConfigMap
    kubectl create configmap $CONFIGMAP_NAME --from-file=$DIRECTORY -n $NAMESPACE
fi