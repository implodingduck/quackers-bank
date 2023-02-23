#!/bin/bash

#source ./.env

#az keyvault secret set --vault-name "replace-with-vault-name" --name "replace-with-secret-name" --file "key.pem"
#!/bin/bash
kubectl delete secret -n quackersbank frontend-application-properties
kubectl delete secret -n quackersbank accounts-application-properties
kubectl delete secret -n quackersbank transactions-application-properties

kubectl create secret generic -n quackersbank frontend-application-properties --from-file=application.properties=frontend-application.properties --from-file=applicationinsights.json=frontend-applicationinsights.json
kubectl create secret generic -n quackersbank accounts-application-properties --from-file=application.properties=accounts-application.properties --from-file=applicationinsights.json=accounts-applicationinsights.json
kubectl create secret generic -n quackersbank transactions-application-properties --from-file=application.properties=transactions-application.properties --from-file=applicationinsights.json=transactions-applicationinsights.json