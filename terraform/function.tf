resource "azurerm_storage_account" "sa" {
  name                     = "sa${local.func_name}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
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
    "SCM_DO_BUILD_DURING_DEPLOYMENT" = "1"
    "ENABLE_ORYX_BUILD"              = "true"
    "CLUSTER_ID"                     = azurerm_kubernetes_cluster.aks.id    
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
    index = "${timestamp()}"
  }
  provisioner "local-exec" {
    working_dir = "../func"
    command     = "timeout 10m func azure functionapp publish ${azurerm_linux_function_app.func.name} --remote-build"
    
  }
}

resource "azurerm_role_assignment" "system" {
  scope                = azurerm_kubernetes_cluster.aks.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_linux_function_app.func.identity.0.principal_id  
}