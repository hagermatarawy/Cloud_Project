#!/bin/bash

# Set strict mode for better error handling
set -euo pipefail

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Validate environment argument
if [ -z "$1" ]; then
    echo -e "${RED}Error: Environment argument is required${NC}"
    echo "Usage: ./deploy.sh <environment>"
    echo "Environments: dev, staging, prod"
    exit 1
fi

ENV=$1
NAMESPACE="healthcare-$ENV"
OVERLAYS_DIR="./k8s/overlays/$ENV"

# Validate environment
if [[ ! "$ENV" =~ ^(dev|staging|prod)$ ]]; then
    echo -e "${RED}Error: Invalid environment '${ENV}'. Use: dev, staging, or prod${NC}"
    exit 1
fi

# Verify kustomize directory exists
if [ ! -d "$OVERLAYS_DIR" ]; then
    echo -e "${RED}Error: Kustomize overlay directory not found at ${OVERLAYS_DIR}${NC}"
    exit 1
fi

# Create namespace if it doesn't exist
echo -e "${YELLOW}Creating namespace ${NAMESPACE} if not exists...${NC}"
kubectl create namespace "$NAMESPACE" --dry-run=client -o yaml | kubectl apply -f -

# Apply configurations using kustomize
echo -e "${YELLOW}Applying configurations using kustomize...${NC}"
kubectl apply -k "$OVERLAYS_DIR"

# List of all deployments to check
deployments=(
    "healthcare-app"
    "healthcare-db" 
    "patient-management-api"
    "ehr-api"
    "appointment-scheduling-api"
)

# Wait for deployments to be ready
echo -e "${YELLOW}Waiting for deployments to be ready...${NC}"
for deployment in "${deployments[@]}"; do
    if ! kubectl get deployment "$deployment" -n "$NAMESPACE" &> /dev/null; then
        echo -e "${RED}Error: Deployment ${deployment} not found in namespace ${NAMESPACE}${NC}"
        continue
    fi
    
    echo -e "${YELLOW}Checking rollout status for ${deployment}...${NC}"
    if ! kubectl rollout status "deployment/${deployment}" -n "$NAMESPACE" --timeout=300s; then
        echo -e "${RED}Error: Deployment ${deployment} failed to rollout${NC}"
        echo -e "${YELLOW}Showing recent events for troubleshooting:${NC}"
        kubectl get events -n "$NAMESPACE" --field-selector involvedObject.name="${deployment}-*" --sort-by='.lastTimestamp'
        echo -e "${YELLOW}Showing pod logs for troubleshooting:${NC}"
        kubectl logs -n "$NAMESPACE" -l app="${deployment}" --tail=50 || true
        exit 1
    fi
done

# Verify all pods are running
echo -e "${YELLOW}Verifying all pods are running...${NC}"
if ! kubectl wait --for=condition=Ready pod --all -n "$NAMESPACE" --timeout=60s; then
    echo -e "${RED}Error: Not all pods are in Ready state${NC}"
    echo -e "${YELLOW}Current pod status:${NC}"
    kubectl get pods -n "$NAMESPACE"
    exit 1
fi

# Success message
echo -e "${GREEN}Deployment to ${ENV} environment completed successfully!${NC}"
echo -e "\n${YELLOW}Current status:${NC}"
echo "Pods:"
kubectl get pods -n "$NAMESPACE" --show-labels
echo -e "\nServices:"
kubectl get services -n "$NAMESPACE"

if [[ "$ENV" =~ ^(staging|prod)$ ]]; then
    echo -e "\nIngress:"
    kubectl get ingress -n "$NAMESPACE"
fi

# Print access information
echo -e "\n${GREEN}Access information:${NC}"
if [ "$ENV" == "dev" ]; then
    echo "To access the development environment:"
    echo "kubectl port-forward svc/healthcare-app 8080:80 -n $NAMESPACE"
    echo "Then open http://localhost:8080"
elif [ "$ENV" == "staging" ]; then
    echo "Staging URL: https://staging.healthcare.example.com"
elif [ "$ENV" == "prod" ]; then
    echo "Production URL: https://healthcare.example.com"
fi