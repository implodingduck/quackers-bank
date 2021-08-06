terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.62.0"
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

resource "azurerm_resource_group" "rg" {
  name     = "rg-quackbank-demo"
  location = var.location
}

resource "random_string" "unique" {
  length  = 8
  special = false
  upper   = false
}

resource "azurerm_app_service_plan" "aspjar" {
  name                = "asp-jar-${local.func_name}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  kind                = "Linux"
  reserved = true
  sku {
    tier = "Dynamic"
    size = "Y1"
  }
}

resource "azurerm_container_registry" "test" {
  name                = "acr-${local.func_name}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Standard"
  admin_enabled       = true
}

resource "azurerm_app_service_plan" "aspdocker" {
  name                = "asp-docker-${local.func_name}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  kind                = "Linux"
  reserved = true
  sku {
    tier = "Dynamic"
    size = "Y1"
  }
}

resource "azurerm_app_service" "my_app_service_container" {
 name                    = "${local.func_name}container"
 resource_group_name = azurerm_resource_group.rg.name
 location            = azurerm_resource_group.rg.location
 app_service_plan_id     = azurerm_app_service_plan.aspdocker.id
 https_only              = true
 client_affinity_enabled = true
 site_config {
   always_on = "true"
   linux_fx_version  = "DOCKER|${azurerm_container_registry.test.login_server}/quackersbank:latest" #define the images to usecfor you application
   health_check_path = "/health" # health check required in order that internal app service plan loadbalancer do not loadbalance on instance down
 }

 identity {
   type         = "SystemAssigned"
   
 }

 app_settings = {
   DOCKER_REGISTRY_SERVER_USERNAME = azurerm_container_registry.test.admin_username
   DOCKER_REGISTRY_SERVER_URL = azurerm_container_registry.test.login_server
   DOCKER_REGISTRY_SERVER_PASSWORD = azurerm_container_registry.test.admin_password
 } 
}