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
  name                = "acr${local.func_name}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Standard"
  
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