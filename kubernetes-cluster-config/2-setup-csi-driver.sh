#!/bin/bash
source ./.env

# export CLUSTER=
# export RESOURCE_GROUP=
# export USER_ASSIGNED_CLIENT_ID=
# export SERVICE_ACCOUNT_NAME=
# export KEYVAULT_NAME=
# export IDENTITY_TENANT=

az aks get-credentials -n $CLUSTER -g $RESOURCE_GROUP

cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  annotations:
    azure.workload.identity/client-id: ${USER_ASSIGNED_CLIENT_ID}
  labels:
    azure.workload.identity/use: "true"
  name: ${SERVICE_ACCOUNT_NAME}
  namespace: quackersbank
EOF

cat <<EOF | kubectl apply -f -
# This is a SecretProviderClass example using workload identity to access your key vault
apiVersion: secrets-store.csi.x-k8s.io/v1
kind: SecretProviderClass
metadata:
  name: azure-kvname-workload-identity # needs to be unique per namespace
spec:
  provider: azure
  parameters:
    usePodIdentity: "false"
    useVMManagedIdentity: "false"          
    clientID: "${USER_ASSIGNED_CLIENT_ID}" # Setting this to use workload identity
    keyvaultName: ${KEYVAULT_NAME}       # Set to the name of your key vault
    objects:  |
      array:
        - |
          objectName: DB-PASSWORD
          objectType: secret              # object types: secret, key, or cert
        - |
          objectName: APPLICATIONINSIGHTS-CONNECTION-STRING
          objectType: secret

    tenantId: "${IDENTITY_TENANT}"        # The tenant ID of the key vault
EOF