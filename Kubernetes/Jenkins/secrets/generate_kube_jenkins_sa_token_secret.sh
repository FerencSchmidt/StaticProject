#!/bin/bash

NAMESPACE=jenkins
SERVICE_ACCOUNT=jenkins-sa

# Function to fetch all secrets linked to the service account and filter by type 'kubernetes.io/service-account-token'
get_token_secret() {
  kubectl get secrets -n $NAMESPACE -o json | jq -r '.items[] | select(.type == "kubernetes.io/service-account-token" and .metadata.annotations."kubernetes.io/service-account.name" == "'$SERVICE_ACCOUNT'") | .metadata.name'
}

# Attempt to find any existing token for the service account
TOKEN_SECRET=$(get_token_secret)

# Create new SECRET_TEXT_NAME for Jenkins
SECRET_TEXT_NAME=jenkins-sa-secret-text

# Check if required secret text already exists
if kubectl get secret $SECRET_TEXT_NAME -n $NAMESPACE &> /dev/null; then
  echo "Secret text already exists, updating..."
  kubectl delete secret $SECRET_TEXT_NAME -n $NAMESPACE
fi

# If not found, generate new token or reuse existing one
if [ -z "$TOKEN_SECRET" ]; then
  echo "No token found for the service account. Generating new one..."
  kubectl apply -f jenkins-sa-token.yaml
  echo "Waiting for token to be created..."
  sleep 10
  
  TOKEN_SECRET=$(get_token_secret)
  
  if [ -z "$TOKEN_SECRET" ]; then
    echo "Failed to create a token."
    exit 1
  fi
  
  echo "Token created and associated with the service account."
fi

# Retrieve and decode the token
TOKEN=$(kubectl get secret $TOKEN_SECRET -n $NAMESPACE -o jsonpath='{.data.token}' | base64 --decode)

# Create a new secret that Jenkins can manage as secretText type
kubectl create secret generic $SECRET_TEXT_NAME \
  --from-literal=text="$TOKEN" \
  --namespace $NAMESPACE \
  --dry-run=client -o yaml | kubectl apply -f -

# Adding annotations and labels specifically for Jenkins
kubectl annotate secret $SECRET_TEXT_NAME jenkins.io/credentials-type=secretText -n $NAMESPACE --overwrite
kubectl label secret $SECRET_TEXT_NAME jenkins.io/credentials-type=secretText -n $NAMESPACE --overwrite

echo "Secret created/updated successfully for Jenkins."

# Verify permission for Jenkins service account
echo "Testing permissions for Jenkins service account..."
PERMISSION_RESULT=$(kubectl auth can-i get secrets -n $NAMESPACE --as=system:serviceaccount:$NAMESPACE:$SERVICE_ACCOUNT)
echo "Permission check: $PERMISSION_RESULT"
if [[ "$PERMISSION_RESULT" == "yes" ]]; then
  echo "Service account has the required permission to access secrets."
else
  echo "WARNING: Service account does not have the required permissions."
fi