#!/bin/bash

# Define where to store generated SSH keys
SSH_KEYS_DIR="./keys"
mkdir -p ${SSH_KEYS_DIR}

# File path for the known hosts
KNOWN_HOSTS_FILE="${SSH_KEYS_DIR}/known_hosts"

# Generate SSH keys if they do not already exist
if [ ! -f "${SSH_KEYS_DIR}/id_rsa" ]; then
    echo "Generating new SSH keys..."
    ssh-keygen -t rsa -b 4096 -m PEM -f "${SSH_KEYS_DIR}/id_rsa" -N ""
else
    echo "SSH keys already exist. Skipping generation."
fi

# Scan and save GitHub's SSH host key if it hasn't been saved yet
if ! grep -q github.com "$KNOWN_HOSTS_FILE"; then
    echo "Scanning and saving GitHub's SSH host key..."
    ssh-keyscan -t rsa github.com >> "$KNOWN_HOSTS_FILE"
else
    echo "GitHub's SSH host key is already saved."
fi

# Pull current secret to see if update is needed
if kubectl get secret jenkins-ssh-keys -n jenkins &> /dev/null; then
    echo "Kubernetes secret exists. Checking contents..."
    # Create a temporary directory for secret data
    mkdir -p temp-secret
    kubectl get secret jenkins-ssh-keys -n jenkins -o json | jq -r '.data | keys[] as $k | "\($k):" | . + $k' | \
    while IFS= read -r line; do
        # Extract key name and encoded value
        KEY_NAME=$(echo "$line" | cut -d: -f1)
        # Decode and store them into temporary files
        echo "$line" | cut -d: -f2
    done
else
    echo "Creating new Kubernetes secret with SSH keys and known hosts..."
    kubectl create secret generic jenkins-ssh-keys \
        --from-file=id_rsa="${SSH_KEYS_DIR}/id_rsa" \
        --from-file=id_rsa.pub="${SSH_KEYS_DIR}/id_rsa.pub" \
        --from-file=known_hosts="$KNOWN_HOSTS_FILE" \
        --namespace=jenkins
fi