#!/bin/bash
az login

RESOURCE_GROUP="rg-aca-quackersbank"
LOCATION="East US"
LOG_ANALYTICS_WORKSPACE="law-aca-quackersbank"
CONTAINERAPPS_ENVIRONMENT="quackersbank"
ACR_NAME="acrquackbankv4vqtcgq"
echo "Your ACR Password: "
read -s ACR_PASSWORD

az containerapp delete \
  --name frontend \
  --resource-group $RESOURCE_GROUP \
  --environment $CONTAINERAPPS_ENVIRONMENT \

az containerapp delete \
  --name accountsapi \
  --resource-group $RESOURCE_GROUP \
  --environment $CONTAINERAPPS_ENVIRONMENT \

az containerapp delete \
  --name transactionsapi \
  --resource-group $RESOURCE_GROUP \
  --environment $CONTAINERAPPS_ENVIRONMENT \

az containerapp create \
  --name frontend \
  --resource-group $RESOURCE_GROUP \
  --environment $CONTAINERAPPS_ENVIRONMENT \
  --image $ACR_NAME.azurecr.io/quackersbank:20211114.2 \
  --registry-login-server $ACR_NAME.azurecr.io \
  --registry-username $ACR_NAME \
  --registry-password $ACR_PASSWORD \
  --target-port 8080 \
  --ingress 'external' \
  --min-replicas 1 \
  --max-replicas 1 \
  --enable-dapr \
  --dapr-app-id frontend \
  --environment-variables "SPRING_PROFILES_ACTIVE=aca"\

az containerapp create \
  --name accountsapi \
  --resource-group $RESOURCE_GROUP \
  --environment $CONTAINERAPPS_ENVIRONMENT \
  --image $ACR_NAME.azurecr.io/accounts-api:20211114.2 \
  --registry-login-server $ACR_NAME.azurecr.io \
  --registry-username $ACR_NAME \
  --registry-password $ACR_PASSWORD \
  --target-port 8080 \
  --ingress 'external' \
  --min-replicas 1 \
  --max-replicas 1 \
  --enable-dapr \
  --dapr-app-port 8080 \
  --dapr-app-id accountsapi \
  --environment-variables "SPRING_PROFILES_ACTIVE=aca"\

az containerapp create \
  --name transactionsapi \
  --resource-group $RESOURCE_GROUP \
  --environment $CONTAINERAPPS_ENVIRONMENT \
  --image $ACR_NAME.azurecr.io/transactions-api:20211114.2 \
  --registry-login-server $ACR_NAME.azurecr.io \
  --registry-username $ACR_NAME \
  --registry-password $ACR_PASSWORD \
  --target-port 8080 \
  --ingress 'external' \
  --min-replicas 1 \
  --max-replicas 1 \
  --enable-dapr \
  --dapr-app-port 8081 \
  --dapr-app-id transactionsapi \
  --environment-variables "SPRING_PROFILES_ACTIVE=aca"\