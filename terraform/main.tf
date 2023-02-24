terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.43.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "=3.1.0"
    }
    azapi = {
      source = "azure/azapi"
      version = "=1.3.0"
    }
  }
  backend "azurerm" {

  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }

  subscription_id = var.subscription_id
}

locals {
  cluster_name = "quackbank${random_string.unique.result}"
  func_name = "${local.cluster_name}func"
  loc_for_naming = lower(replace(var.location, " ", ""))
  gh_repo = replace(var.gh_repo, "implodingduck/", "")
  tags = {
    "managed_by" = "terraform"
    "repo"       = local.gh_repo
  }
}

resource "random_string" "unique" {
  length  = 8
  special = false
  upper   = false
}


data "azurerm_client_config" "current" {}

data "azurerm_log_analytics_workspace" "default" {
  name                = "DefaultWorkspace-${data.azurerm_client_config.current.subscription_id}-EUS"
  resource_group_name = "DefaultResourceGroup-EUS"
} 

resource "azurerm_resource_group" "rg" {
  name     = "rg-${local.gh_repo}-${random_string.unique.result}-${local.loc_for_naming}"
  location = var.location
  tags = local.tags
}



resource "azurerm_virtual_network" "default" {
  name                = "${local.cluster_name}-vnet-eastus"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = ["10.7.0.0/16"]

  tags = local.tags
}


resource "azurerm_subnet" "default" {
  name                 = "default-subnet-eastus"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.default.name
  address_prefixes     = ["10.7.0.0/24"]
}

resource "azurerm_subnet" "cluster" {
  name                 = "${local.cluster_name}-subnet-eastus"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.default.name
  address_prefixes     = ["10.7.2.0/23"]

}

data "azurerm_kubernetes_service_versions" "current" {
  location = azurerm_resource_group.rg.location
  include_preview = false
}


resource "azurerm_kubernetes_cluster" "aks" {
  name                    = "${local.cluster_name}"
  location                = azurerm_resource_group.rg.location
  resource_group_name     = azurerm_resource_group.rg.name
  dns_prefix              = "${local.cluster_name}"
  kubernetes_version      = data.azurerm_kubernetes_service_versions.current.latest_version
  private_cluster_enabled = false
  default_node_pool {
    name            = "default"
    node_count      = 1
    vm_size         = "Standard_B4ms"
    os_disk_size_gb = "128"
    vnet_subnet_id  = azurerm_subnet.cluster.id
    max_pods        = 60

  }
  network_profile {
    network_plugin      = "azure"
    network_plugin_mode = "Overlay"
    pod_cidr            = "192.168.0.0/16"
    service_cidr       = "10.255.252.0/22"
    dns_service_ip     = "10.255.252.10"
    docker_bridge_cidr = "172.17.0.1/16"
  }

  key_vault_secrets_provider {
    secret_rotation_enabled = true
    secret_rotation_interval = "5m"
  }

  role_based_access_control_enabled = false

  identity {
    type = "SystemAssigned"
  }
  
  oidc_issuer_enabled = true
  workload_identity_enabled = true
  microsoft_defender {
    log_analytics_workspace_id = data.azurerm_log_analytics_workspace.default.id
  }
  oms_agent {
    log_analytics_workspace_id = data.azurerm_log_analytics_workspace.default.id
  }

  open_service_mesh_enabled = false
  tags = local.tags

}

resource "azurerm_container_registry" "acr" {
  name                = "acr${local.cluster_name}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Standard"
  admin_enabled       = false
}


resource "azurerm_role_assignment" "acrpull_role" {
  scope                            = azurerm_container_registry.acr.id
  role_definition_name             = "AcrPull"
  principal_id                     = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
}

resource "azurerm_application_insights" "app" {
  name                = "${local.cluster_name}-insights"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  application_type    = "other"
  workspace_id        = data.azurerm_log_analytics_workspace.default.id
}

resource "azurerm_key_vault" "kv" {
  name                       = "kv-${local.cluster_name}"
  location                   = azurerm_resource_group.rg.location
  resource_group_name        = azurerm_resource_group.rg.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  soft_delete_retention_days = 7
  purge_protection_enabled   = false

}

resource "azurerm_key_vault_access_policy" "sp" {
  key_vault_id = azurerm_key_vault.kv.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  key_permissions = [
    "Create",
    "Get",
    "Purge",
    "Recover",
    "Delete"
  ]

  secret_permissions = [
    "Set",
    "Purge",
    "Get",
    "List",
    "Delete"
  ]

  certificate_permissions = [
    "Purge"
  ]

  storage_permissions = [
    "Purge"
  ]

}

resource "azurerm_key_vault_secret" "appinsights" {
  name = "APPLICATIONINSIGHTS-CONNECTION-STRING"
  key_vault_id = azurerm_key_vault.kv.id
  value = azurerm_application_insights.app.connection_string
}

resource "azurerm_key_vault_access_policy" "csidriver" {
  key_vault_id = azurerm_key_vault.kv.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_user_assigned_identity.kvcsidriver.principal_id

  key_permissions = [
    "Get"
  ]

  secret_permissions = [
    "Get",
    "List",
  ]

}


resource "azurerm_user_assigned_identity" "kvcsidriver" {
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  name = "uai-kvcsidriver-${local.cluster_name}"
}

resource "azurerm_federated_identity_credential" "fic-kvcsidriver" {
  name                = "fic-kvcsidriver"
  resource_group_name = azurerm_resource_group.rg.name
  audience            = ["api://AzureADTokenExchange"]
  issuer              = azurerm_kubernetes_cluster.aks.oidc_issuer_url
  parent_id           = azurerm_user_assigned_identity.kvcsidriver.id
  subject             = "system:serviceaccount:quackersbank:${azurerm_user_assigned_identity.kvcsidriver.name}"
}

