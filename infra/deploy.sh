#!/bin/bash

# Variables
LOCATION="japaneast"
DEPLOYMENT_NAME="apim-deployment-$(date +%Y%m%d-%H%M%S)"

# Login to Azure (if not already logged in)
echo "Checking Azure login status..."
az account show > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "Please login to Azure..."
    az login
fi

# Deploy using subscription-level deployment
echo "Deploying Bicep template at subscription level..."
az deployment sub create \
    --location $LOCATION \
    --template-file main.bicep \
    --parameters @main.parameters.json \
    --name $DEPLOYMENT_NAME \
    --verbose

# Show deployment outputs
echo "Deployment completed. Outputs:"
az deployment sub show \
    --name $DEPLOYMENT_NAME \
    --query properties.outputs
