resource "azurerm_spring_cloud_service" "this" {
  name                = "quackersbank"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku_name            = "B0"
}
