
resource "azurerm_subnet" "aca" {
  name                 = "aca-subnet-eastus"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.default.name
  address_prefixes     = ["10.7.8.0/21"]

}

resource "azurerm_application_insights" "aca" {
  name                = "aca${local.cluster_name}-insights"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  application_type    = "other"
  workspace_id        = data.azurerm_log_analytics_workspace.default.id
}


resource "azurerm_container_app_environment" "aca" {
  name                       = "ace-${local.cluster_name}"
  location                   = azurerm_resource_group.rg.location
  resource_group_name        = azurerm_resource_group.rg.name
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.default.id
  infrastructure_subnet_id   = azurerm_subnet.aca.id
  tags = local.tags
}

resource "azurerm_storage_share" "accountsapi" {
  name                 = "accountsapi"
  storage_account_name = azurerm_storage_account.sa.name
  quota                = 1
}

resource "azurerm_storage_share_file" "accountsapiappjson" {
  name             = "applicationinsights.json"
  storage_share_id = azurerm_storage_share.accountsapi.id
  source           = "../containerapps/accounts-applicationinsights.json"
}

resource "azurerm_container_app_environment_storage" "accountsapi" {
  name                         = "accountsapishare"
  container_app_environment_id = azurerm_container_app_environment.aca.id
  account_name                 = azurerm_storage_account.sa.name
  share_name                   = azurerm_storage_share.accountsapi.name
  access_key                   = azurerm_storage_account.sa.primary_access_key
  access_mode                  = "ReadOnly"
}

resource "azurerm_container_app" "accountsapi" {
  name                         = "aca-accounts-api"
  container_app_environment_id = azurerm_container_app_environment.aca.id
  resource_group_name          = azurerm_resource_group.rg.name
  revision_mode                = "Single"

  template {
    min_replicas = 1
    max_replicas = 1
    container {
      name   = "aca-accounts-api"
      image  = "ghcr.io/implodingduck/quackers-bank-accounts-api:main"
      cpu    = 0.25
      memory = "0.5Gi"
      volume_mounts {
        name = azurerm_container_app_environment_storage.accountsapi.name
        path = "/opt/target/config"
      }
      env {
        name = "APPLICATIONINSIGHTS_CONFIGURATION_FILE"
        value = "/opt/target/config/applicationinsights.json"
      }
      env {
        name = "ACCOUNTSAPI_BASEURL"
        value = "http://localhost:7777/v1.0/bindings/accounts-api"
      }
      env {
        name = "TRANSACTIONSAPI_BASEURL"
        value = "http://localhost:7777/v1.0/bindings/transactions-api"
      }
      env {
        name = "ACCOUNTS_SCOPES"
        secret_name = "accounts-scopes"
      }
      env {
        name = "APPLICATIONINSIGHTS_CONNECTION_STRING"
        secret_name = "applicationinsights-connection-string"
      }
      env {
        name = "B2C_BASE_URI"
        secret_name = "b2c-base-uri"
      }
      env {
        name = "B2C_CLIENT_ID"
        secret_name = "b2c-client-id-accounts"
      }
      env {
        name = "B2C_CLIENT_SECRET"
        secret_name = "b2c-client-secret"
      }
      env {
        name = "B2C_TENANT_ID"
        secret_name = "b2c-tenant-id"
      }
      env {
        name = "DB_PASSWORD"
        secret_name = "db-password"
      }
      env {
        name = "DB_URL"
        secret_name = "db-url"
      }
      env {
        name = "DB_USERNAME"
        secret_name = "db-username"
      }
      env {
        name = "TRANSACTIONS_SCOPES"
        secret_name = "transactions-scopes"
      }
      
    }
    
    volume {
      name         = azurerm_container_app_environment_storage.accountsapi.name
      storage_type = "AzureFile"
      storage_name = azurerm_container_app_environment_storage.accountsapi.name
    }
  }
  ingress {
    allow_insecure_connections = true
    external_enabled           = true
    target_port                = 8080
    transport                  = "http"
    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }
  dapr {
    app_id       = "accounts-api"
    app_port     = 8080
    app_protocol = "http"
  }

  tags = local.tags

  lifecycle {
    ignore_changes = [
      secret
    ]
  }
}

resource "azurerm_storage_share" "frontend" {
  name                 = "frontend"
  storage_account_name = azurerm_storage_account.sa.name
  quota                = 1
}

resource "azurerm_storage_share_file" "frontendappjson" {
  name             = "applicationinsights.json"
  storage_share_id = azurerm_storage_share.frontend.id
  source           = "../containerapps/frontend-applicationinsights.json"
}

resource "azurerm_container_app_environment_storage" "frontend" {
  name                         = "frontendshare"
  container_app_environment_id = azurerm_container_app_environment.aca.id
  account_name                 = azurerm_storage_account.sa.name
  share_name                   = azurerm_storage_share.frontend.name
  access_key                   = azurerm_storage_account.sa.primary_access_key
  access_mode                  = "ReadOnly"
}

resource "azurerm_container_app" "frontend" {
  name                         = "aca-frontend"
  container_app_environment_id = azurerm_container_app_environment.aca.id
  resource_group_name          = azurerm_resource_group.rg.name
  revision_mode                = "Single"

  template {
    min_replicas = 1
    max_replicas = 1
    container {
      name   = "aca-frontend"
      image  = "ghcr.io/implodingduck/quackers-bank-frontend:main"
      cpu    = 0.25
      memory = "0.5Gi"
      
      volume_mounts {
        name = azurerm_container_app_environment_storage.frontend.name
        path = "/opt/target/config"
      }
      env {
        name = "APPLICATIONINSIGHTS_CONFIGURATION_FILE"
        value = "/opt/target/config/applicationinsights.json"
      }
      env {
        name = "ACCOUNTSAPI_BASEURL"
        value = "http://localhost:7777/v1.0/bindings/accounts-api"
      }
      env {
        name = "TRANSACTIONSAPI_BASEURL"
        value = "http://localhost:7777/v1.0/bindings/transactions-api"
      }
      env {
        name = "ACCOUNTS_SCOPES"
        secret_name = "accounts-scopes"
      }
      env {
        name = "APPLICATIONINSIGHTS_CONNECTION_STRING"
        secret_name = "applicationinsights-connection-string"
      }
      env {
        name = "B2C_BASE_URI"
        secret_name = "b2c-base-uri"
      }
      env {
        name = "B2C_CLIENT_ID"
        secret_name = "b2c-client-id"
      }
      env {
        name = "B2C_CLIENT_SECRET"
        secret_name = "b2c-client-secret"
      }
      env {
        name = "B2C_TENANT_ID"
        secret_name = "b2c-tenant-id"
      }
      env {
        name = "DB_PASSWORD"
        secret_name = "db-password"
      }
      env {
        name = "DB_URL"
        secret_name = "db-url"
      }
      env {
        name = "DB_USERNAME"
        secret_name = "db-username"
      }
      env {
        name = "TRANSACTIONS_SCOPES"
        secret_name = "transactions-scopes"
      }
    }
    
    volume {
      name         = azurerm_container_app_environment_storage.frontend.name
      storage_type = "AzureFile"
      storage_name = azurerm_container_app_environment_storage.frontend.name
    }
  }
  ingress {
    allow_insecure_connections = true
    external_enabled           = true
    target_port                = 8080
    transport                  = "http"
    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }

  tags = local.tags
  lifecycle {
    ignore_changes = [
      secret
    ]
  }
}

resource "azurerm_storage_share" "transactionsapi" {
  name                 = "transactionsapi"
  storage_account_name = azurerm_storage_account.sa.name
  quota                = 1
}

resource "azurerm_storage_share_file" "transactionsappjson" {
  name             = "applicationinsights.json"
  storage_share_id = azurerm_storage_share.transactionsapi.id
  source           = "../containerapps/transactions-applicationinsights.json"
}

resource "azurerm_container_app_environment_storage" "transactionsapi" {
  name                         = "transactionsapishare"
  container_app_environment_id = azurerm_container_app_environment.aca.id
  account_name                 = azurerm_storage_account.sa.name
  share_name                   = azurerm_storage_share.transactionsapi.name
  access_key                   = azurerm_storage_account.sa.primary_access_key
  access_mode                  = "ReadOnly"
}

resource "azurerm_container_app" "transactionsapi" {
  name                         = "aca-transactions-api"
  container_app_environment_id = azurerm_container_app_environment.aca.id
  resource_group_name          = azurerm_resource_group.rg.name
  revision_mode                = "Single"

  template {
    min_replicas = 1
    max_replicas = 1
    container {
      name   = "aca-transactions-api"
      image  = "ghcr.io/implodingduck/quackers-bank-transactions-api:main"
      cpu    = 0.25
      memory = "0.5Gi"

      volume_mounts {
        name = azurerm_container_app_environment_storage.transactionsapi.name
        path = "/opt/target/config"
      }
      env {
        name = "APPLICATIONINSIGHTS_CONFIGURATION_FILE"
        value = "/opt/target/config/applicationinsights.json"
      }
      env {
        name = "ACCOUNTSAPI_BASEURL"
        value = "http://localhost:7777/v1.0/bindings/accounts-api"
      }
      env {
        name = "TRANSACTIONSAPI_BASEURL"
        value = "http://localhost:7777/v1.0/bindings/transactions-api"
      }
      env {
        name = "ACCOUNTS_SCOPES"
        secret_name = "accounts-scopes"
      }
      env {
        name = "APPLICATIONINSIGHTS_CONNECTION_STRING"
        secret_name = "applicationinsights-connection-string"
      }
      env {
        name = "B2C_BASE_URI"
        secret_name = "b2c-base-uri"
      }
      env {
        name = "B2C_CLIENT_ID"
        secret_name = "b2c-client-id-transactions"
      }
      env {
        name = "B2C_CLIENT_SECRET"
        secret_name = "b2c-client-secret-transactions"
      }
      env {
        name = "B2C_TENANT_ID"
        secret_name = "b2c-tenant-id"
      }
      env {
        name = "DB_PASSWORD"
        secret_name = "db-password"
      }
      env {
        name = "DB_URL"
        secret_name = "db-url"
      }
      env {
        name = "DB_USERNAME"
        secret_name = "db-username"
      }
      env {
        name = "TRANSACTIONS_SCOPES"
        secret_name = "transactions-scopes"
      }
    }
    
    volume {
      name         = azurerm_container_app_environment_storage.transactionsapi.name
      storage_type = "AzureFile"
      storage_name = azurerm_container_app_environment_storage.transactionsapi.name
    }
  }
  ingress {
    allow_insecure_connections = true
    external_enabled           = true
    target_port                = 8080
    transport                  = "http"
    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }

  dapr {
    app_id       = "transactions-api"
    app_port     = 8080
    app_protocol = "http"
  }

  tags = local.tags
  lifecycle {
    ignore_changes = [
      secret
    ]
  }
}