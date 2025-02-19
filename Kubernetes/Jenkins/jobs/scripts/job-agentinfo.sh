#!/bin/bash
echo "======================== START SECTION: AGENT INFO ========================"
echo "Build node: $NODE_NAME"
echo "Labels: $NODE_LABELS"

# Check if kubectl is available
if command -v kubectl &> /dev/null; then
    echo "kubectl is already installed."
    # Optionally, displaying kubectl version
    kubectl version --client
else
    echo "kubectl is not installed."
fi
echo "======================== END SECTION: AGENT INFO ========================"