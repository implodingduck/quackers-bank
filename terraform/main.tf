terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.71.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "=3.1.0"
    }
  }
  backend "azurerm" {

  }
}

provider "azurerm" {
  features {}

  subscription_id = var.subscription_id
}

locals {
  func_name = "quackbank${random_string.unique.result}"
}

data "azurerm_client_config" "current" {}

data "azurerm_log_analytics_workspace" "default" {
  name                = "DefaultWorkspace-${data.azurerm_client_config.current.subscription_id}-EUS"
  resource_group_name = "DefaultResourceGroup-EUS"
} 

resource "azurerm_resource_group" "rg" {
  name     = "rg-quackbank-demo"
  location = var.location
}

resource "random_string" "unique" {
  length  = 8
  special = false
  upper   = false
}

module "frontend" {
  source = "github.com/implodingduck/tfmodules//appservice"
  appname                = "frontend"
  resource_group_name     = azurerm_resource_group.rg.name
  resource_group_location = azurerm_resource_group.rg.location
  workspace_id            = data.azurerm_log_analytics_workspace.default.id
  
  sc_always_on = "true"
  sc_linux_fx_version = "JAVA|11-java11"
  sc_health_check_path = "/health/" # health check required in order that internal app service plan loadbalancer do not loadbalance on instance down
  

}

resource "null_resource" "publish_jar"{
  depends_on = [
    module.frontend
  ]
  triggers = {
    index = "${timestamp()}"
  }
  provisioner "local-exec" {
    working_dir = "../frontend"
    command     = "./mvnw package azure-webapp:deploy -Darm.resourcegroup=${azurerm_resource_group.rg.name} -Darm.region=${azurerm_resource_group.rg.location} -Darm.appname=${module.frontend.app_service_name}"
  }
}

resource "azurerm_container_registry" "test" {
  name                = "acr${local.func_name}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Standard"
  admin_enabled       = true
}


resource "azurerm_key_vault" "kv" {
  name                       = "kv-${local.func_name}"
  location                   = azurerm_resource_group.rg.location
  resource_group_name        = azurerm_resource_group.rg.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  soft_delete_retention_days = 7
  purge_protection_enabled = false

  
}

resource "azurerm_key_vault_access_policy" "sp" {
  key_vault_id = azurerm_key_vault.kv.id
  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = data.azurerm_client_config.current.object_id
  
  key_permissions = [
    "create",
    "get",
    "purge",
    "recover",
    "delete"
  ]

  secret_permissions = [
    "set",
    "purge",
    "get",
    "list"
  ]

  certificate_permissions = [
    "purge"
  ]

  storage_permissions = [
    "purge"
  ]
  
}


resource "azurerm_key_vault_access_policy" "as" {
  for_each = toset([
    module.accounts-api.identity_principal_id,
    module.transactions-api.identity_principal_id,
    module.frontend.identity_principal_id,
  ])
  key_vault_id = azurerm_key_vault.kv.id
  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = each.key
  
  key_permissions = [
    "get",
  ]

  secret_permissions = [
    "get",
    "list"
  ]
  
}



resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "_%@"
}


resource "azurerm_key_vault_secret" "dbpassword" {
  depends_on = [
    azurerm_key_vault_access_policy.sp
  ]
  name         = "dbpassword"
  value        = random_password.password.result
  key_vault_id = azurerm_key_vault.kv.id
  tags         = {}
}

resource "azurerm_key_vault_secret" "acrpassword" {
  depends_on = [
    azurerm_key_vault_access_policy.sp
  ]
  name = "acrpassword"
  value = azurerm_container_registry.test.admin_password
  key_vault_id = azurerm_key_vault.kv.id
  tags         = {}
}

resource "azurerm_mssql_server" "db" {
  name                         = "${local.func_name}-server"
  resource_group_name          = azurerm_resource_group.rg.name
  location                     = azurerm_resource_group.rg.location
  version                      = "12.0"
  administrator_login          = "sqladmin"
  administrator_login_password = random_password.password.result
  minimum_tls_version          = "1.2"

  tags = {}
}

resource "azurerm_mssql_database" "db" {
  name                        = "${local.func_name}db"
  server_id                   = azurerm_mssql_server.db.id
  max_size_gb                 = 40
  auto_pause_delay_in_minutes = -1
  min_capacity                = 1
  sku_name                    = "GP_S_Gen5_1"
  tags = {}
  short_term_retention_policy {
    retention_days = 7
  }
}

resource "azurerm_mssql_firewall_rule" "azureservices" {
  name             = "azureservices"
  server_id        = azurerm_mssql_server.db.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "0.0.0.0"
}

resource "azurerm_mssql_firewall_rule" "editor" {
  name             = "editor"
  server_id        = azurerm_mssql_server.db.id
  start_ip_address = "167.220.149.227"
  end_ip_address   = "167.220.149.227"
}

resource "azurerm_storage_account" "sa" {
  name                     = "sa${local.func_name}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_kind             = "StorageV2"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}


resource "azurerm_storage_container" "accounts-api" {
  name                  = "accounts-api"
  storage_account_name  = azurerm_storage_account.sa.name
  container_access_type = "private"
}

module "accounts-api" {
  source = "github.com/implodingduck/tfmodules//appservice"
  appname                = "accountsapi"
  resource_group_name     = azurerm_resource_group.rg.name
  resource_group_location = azurerm_resource_group.rg.location
  workspace_id            = data.azurerm_log_analytics_workspace.default.id
  
  sc_always_on = "true"
  sc_linux_fx_version = "DOCKER|${azurerm_container_registry.test.login_server}/accounts-api:latest"
  sc_health_check_path = "/health/" 
  app_settings = {
    DOCKER_REGISTRY_SERVER_USERNAME = azurerm_container_registry.test.admin_username
    DOCKER_REGISTRY_SERVER_URL = "https://${azurerm_container_registry.test.login_server}"
    DOCKER_REGISTRY_SERVER_PASSWORD = "@Microsoft.KeyVault(VaultName=${azurerm_key_vault.kv.name};SecretName=${azurerm_key_vault_secret.acrpassword.name})"
  }

  storage_account = [
    {
      name = azurerm_storage_account.sa.name
      type = "AzureBlob"
      account_name = azurerm_storage_account.sa.name
      share_name = "accounts-api"
      access_key = azurerm_storage_account.sa.primary_access_key
      mount_path = "/opt/target/config"
    }
  ]
}

resource "azurerm_storage_container" "transactions-api" {
  name                  = "transactions-api"
  storage_account_name  = azurerm_storage_account.sa.name
  container_access_type = "private"
}

module "transactions-api" {
  source = "github.com/implodingduck/tfmodules//appservice"
  appname                = "transactionsapi"
  resource_group_name     = azurerm_resource_group.rg.name
  resource_group_location = azurerm_resource_group.rg.location
  workspace_id            = data.azurerm_log_analytics_workspace.default.id
  
  sc_always_on = "true"
  sc_linux_fx_version = "DOCKER|${azurerm_container_registry.test.login_server}/transactions-api:latest"
  sc_health_check_path = "/health/" 
  app_settings = {
    DOCKER_REGISTRY_SERVER_USERNAME = azurerm_container_registry.test.admin_username
    DOCKER_REGISTRY_SERVER_URL = "https://${azurerm_container_registry.test.login_server}"
    DOCKER_REGISTRY_SERVER_PASSWORD = "@Microsoft.KeyVault(VaultName=${azurerm_key_vault.kv.name};SecretName=${azurerm_key_vault_secret.acrpassword.name})"
  }

  storage_account = [
    {
      name = azurerm_storage_account.sa.name
      type = "AzureBlob"
      account_name = azurerm_storage_account.sa.name
      share_name = "transactions-api"
      access_key = azurerm_storage_account.sa.primary_access_key
      mount_path = "/opt/target/config"
    }
  ]
}
resource "azurerm_mssql_firewall_rule" "appservice" {
  for_each = setunion(module.accounts-api.possible_outbound_ip_address_list, module.transactions-api.possible_outbound_ip_address_list)
  name             = "as-${replace(each.key, ".", "_")}"
  server_id        = azurerm_mssql_server.db.id
  start_ip_address = each.key
  end_ip_address   = each.key
}
