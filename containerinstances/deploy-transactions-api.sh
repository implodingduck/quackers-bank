#!/bin/bash
source .env
az deployment group create --name transactionsapiaci -g $RG \
    --template-file transactions-api-aci.json \
    --parameters storageAccountName=$SANAME subnetId=$SNETID location=$LOC containerImage=$ACR.azurecr.io/transactions-api:$IMAGE_VERSION userAssignedIdentity=$UAID containerRegistryServer=$ACR.azurecr.io