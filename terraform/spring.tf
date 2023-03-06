resource "azurerm_spring_cloud_service" "this" {
  name                = "quackersbank"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku_name            = "B0"
}

resource "azurerm_spring_cloud_app" "frontend" {
  name                = "frontend"
  resource_group_name = azurerm_spring_cloud_service.this.resource_group_name
  service_name        = azurerm_spring_cloud_service.this.name
}

resource "azurerm_spring_cloud_container_deployment" "frontend" {
  name                = "sample"
  spring_cloud_app_id = azurerm_spring_cloud_app.frontend.id
  instance_count      = 1
  
  server             = "ghcr.io"
  image              = "implodingduck/gs-spring-boot-azurespringapps:azurespringapps"
  language_framework = "springboot"
}