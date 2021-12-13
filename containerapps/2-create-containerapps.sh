#!/bin/bash
az login

RESOURCE_GROUP="rg-aca-quackersbank"
LOCATION="East US"
LOG_ANALYTICS_WORKSPACE="law-aca-quackersbank"
CONTAINERAPPS_ENVIRONMENT="quackersbank"
ACR_NAME=""
IMAGE_VERSION=""
APPLICATIONINSIGHTS_CONNECTION_STRING=""

az containerapp delete \
  --name frontend \
  --resource-group $RESOURCE_GROUP \
  #--environment $CONTAINERAPPS_ENVIRONMENT \

az containerapp delete \
  --name accountsapi \
  --resource-group $RESOURCE_GROUP \
  #--environment $CONTAINERAPPS_ENVIRONMENT \

az containerapp delete \
  --name transactionsapi \
  --resource-group $RESOURCE_GROUP \
  #--environment $CONTAINERAPPS_ENVIRONMENT \

echo "Your ACR Password: "
read -r ACR_PASSWORD

az containerapp create \
  --name frontend \
  --resource-group $RESOURCE_GROUP \
  --environment $CONTAINERAPPS_ENVIRONMENT \
  --image $ACR_NAME.azurecr.io/quackersbank:$IMAGE_VERSION \
  --registry-login-server $ACR_NAME.azurecr.io \
  --registry-username $ACR_NAME \
  --registry-password $ACR_PASSWORD \
  --target-port 8080 \
  --ingress 'external' \
  --min-replicas 1 \
  --max-replicas 1 \
  --secrets "app-insights=$APPLICATIONINSIGHTS_CONNECTION_STRING" \
  --environment-variables "SPRING_PROFILES_ACTIVE=aca,APPLICATIONINSIGHTS_CONNECTION_STRING=secretref:app-insights"\

az containerapp create \
  --name accountsapi \
  --resource-group $RESOURCE_GROUP \
  --environment $CONTAINERAPPS_ENVIRONMENT \
  --image $ACR_NAME.azurecr.io/accounts-api:$IMAGE_VERSION \
  --registry-login-server $ACR_NAME.azurecr.io \
  --registry-username $ACR_NAME \
  --registry-password $ACR_PASSWORD \
  --target-port 8080 \
  --ingress 'external' \
  --min-replicas 1 \
  --max-replicas 1 \
  --secrets "app-insights=$APPLICATIONINSIGHTS_CONNECTION_STRING" \
  --environment-variables "SPRING_PROFILES_ACTIVE=aca,APPLICATIONINSIGHTS_CONNECTION_STRING=secretref:app-insights"\

az containerapp create \
  --name transactionsapi \
  --resource-group $RESOURCE_GROUP \
  --environment $CONTAINERAPPS_ENVIRONMENT \
  --image $ACR_NAME.azurecr.io/transactions-api:$IMAGE_VERSION \
  --registry-login-server $ACR_NAME.azurecr.io \
  --registry-username $ACR_NAME \
  --registry-password $ACR_PASSWORD \
  --target-port 8080 \
  --ingress 'external' \
  --min-replicas 1 \
  --max-replicas 1 \
  --secrets "app-insights=$APPLICATIONINSIGHTS_CONNECTION_STRING" \
  --environment-variables "SPRING_PROFILES_ACTIVE=aca,APPLICATIONINSIGHTS_CONNECTION_STRING=secretref:app-insights"\