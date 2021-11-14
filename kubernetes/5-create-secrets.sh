#!/bin/bash
kubectl delete secret frontend-application-properties
kubectl delete secret frontend-impersonation-application-properties
kubectl delete secret accounts-application-properties
kubectl delete secret transactions-application-properties

kubectl create secret generic frontend-application-properties --from-file=application.properties=frontend-application.properties --from-file=applicationinsights.json=frontend-applicationinsights.json
kubectl create secret generic frontend-impersonation-application-properties --from-file=application.properties=frontend-impersonation-application.properties --from-file=applicationinsights.json=frontend-applicationinsights.json
kubectl create secret generic accounts-application-properties --from-file=application.properties=accounts-application.properties --from-file=applicationinsights.json=accounts-applicationinsights.json
kubectl create secret generic transactions-application-properties --from-file=application.properties=transactions-application.properties --from-file=applicationinsights.json=transactions-applicationinsights.json