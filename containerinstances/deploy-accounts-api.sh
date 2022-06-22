#!/bin/bash
source .env
az deployment group create --name accountsapiaci -g $RG \
    --template-file accounts-api-aci.json \
    --parameters storageAccountName=$SANAME subnetId=$SNETID location=$LOC containerImage=$ACR.azurecr.io/accounts-api:$IMAGE_VERSION userAssignedIdentity=$UAID containerRegistryServer=$ACR.azurecr.io