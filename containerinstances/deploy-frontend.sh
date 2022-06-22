#!/bin/bash
source .env
az deployment group create --name frontendaci -g $RG \
    --template-file frontend-aci.json \
    --parameters storageAccountName=$SANAME subnetId=$SNETID location=$LOC containerImage=$ACR.azurecr.io/quackersbank:$IMAGE_VERSION userAssignedIdentity=$UAID containerRegistryServer=$ACR.azurecr.io