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
apiVersion: secrets-store.csi.x-k8s.io/v1
kind: SecretProviderClass
metadata:
  name: azure-sync-workload-identity
  namespace: quackersbank
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
  secretObjects:                              # [OPTIONAL] SecretObjects defines the desired state of synced Kubernetes secret objects
  - data:
    - key: dbpassword                           # data field to populate
      objectName: DB-PASSWORD                        # name of the mounted content to sync; this could be the object name or the object alias
    - key: appinsightsconnectionstring
      objectName: APPLICATIONINSIGHTS-CONNECTION-STRING
    secretName: workidsyncsecret                     # name of the Kubernetes secret object
    type: Opaque    
EOF