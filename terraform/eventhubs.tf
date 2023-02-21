resource "azurerm_eventhub_namespace" "ehn" {
  name                = "ehn${local.cluster_name}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Basic"
  capacity            = 1

  tags = local.tags
}

resource "azurerm_eventhub" "eh" {
  name                = "eh${local.cluster_name}"
  namespace_name      = azurerm_eventhub_namespace.ehn.name
  resource_group_name = azurerm_resource_group.rg.name
  partition_count     = 2
  message_retention   = 1
}

# resource "azurerm_eventhub_consumer_group" "ehcg" {
#   name                = "cg${local.func_name}"
#   namespace_name      = azurerm_eventhub_namespace.ehn.name
#   eventhub_name       = azurerm_eventhub.eh.name
#   resource_group_name = azurerm_resource_group.rg.name
# }