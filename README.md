# quackers-bank
```
./mvnw package spring-boot:run
```
```
./mvnw package azure-webapp:deploy
```

# DB Commands
```
SELECT name, database_id, create_date
FROM sys.databases ;
GO
```

# AKS
```
kubectl create secret generic qb-application-properties --from-file=application.properties=qb-application.properties
```