#!/bin/bash
source .env

az group create -n $RG -l $LOC

az identity create \
  --resource-group $RG \
  --name $UAMID

spID=$(az identity show \
  --resource-group $RG \
  --name $UAMID \
  --query id --output tsv)

uaidObjectId=$(az identity show \
  --resource-group $RG \
  --name $UAMID \
  --query principalId --output tsv)  

echo "Created: $spID"

az role assignment create --assignee-object-id $uaidObjectId --role 'AcrPull' --scope /subscriptions/$SUBSCRIPTION/resourceGroups/rg-quackbank-demo/providers/Microsoft.ContainerRegistry/registries/$ACR