resource "azurerm_storage_account" "sa" {
  name                     = "sa${local.func_name}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  allow_nested_items_to_be_public = false
}

resource "azurerm_service_plan" "asp" {
  name                = "asp-${local.func_name}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  os_type             = "Linux"
  sku_name            = "Y1"
}

resource "azurerm_linux_function_app" "func" {

  name                       = local.func_name
  resource_group_name        = azurerm_resource_group.rg.name
  location                   = azurerm_resource_group.rg.location
  service_plan_id            = azurerm_service_plan.asp.id
  storage_account_name       = azurerm_storage_account.sa.name
  storage_account_access_key = azurerm_storage_account.sa.primary_access_key

  site_config {
    application_insights_key = azurerm_application_insights.app.instrumentation_key
    application_stack {
      node_version = "16"
    }
    
  }
  identity {
    type         = "SystemAssigned"
  }
  app_settings = {
    "CLUSTER_ID"                     = azurerm_kubernetes_cluster.aks.id  
    "ENABLE_ORYX_BUILD"              = "true"
    "SCM_DO_BUILD_DURING_DEPLOYMENT" = "1"
    "WEBSITE_MOUNT_ENABLED"          = "1"
    "EHCONN__fullyQualifiedNamespace" = "${azurerm_eventhub_namespace.ehn.name}.servicebus.windows.net" 
    "APPLICATIONINSIGHTS_CONNECTION_STRING" = azurerm_application_insights.app.connection_string
  }
  lifecycle {
    ignore_changes = [
      tags
    ]
  }

}

resource "local_file" "localsettings" {
    content     = <<-EOT
{
  "IsEncrypted": false,
  "Values": {
    "FUNCTIONS_WORKER_RUNTIME": "node",
    "AzureWebJobsStorage": ""
  }
}
EOT
    filename = "../func/local.settings.json"
}

resource "null_resource" "publish_func" {
  depends_on = [
    azurerm_linux_function_app.func,
    local_file.localsettings
  ]
  triggers = {
    index = "${timestamp()}" #"2022-12-06T15:30:55Z" #"${timestamp()}"
  }
  provisioner "local-exec" {
    working_dir = "../func"
    command     = "npm install && timeout 10m func azure functionapp publish ${azurerm_linux_function_app.func.name}"
    
  }
}

# resource "azurerm_role_assignment" "system" {
#   scope                = azurerm_kubernetes_cluster.aks.id
#   role_definition_name = "Contributor"
#   principal_id         = azurerm_linux_function_app.func.identity.0.principal_id  
# }

resource "azurerm_role_assignment" "eh" {
  scope                = azurerm_resource_group.rg.id
  role_definition_name = "Azure Event Hubs Data Receiver"
  principal_id         = azurerm_linux_function_app.func.identity.0.principal_id  
}