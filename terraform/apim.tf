resource "azurerm_subnet" "apim" {
  name                 = "apim-subnet-eastus"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.default.name
  address_prefixes     = ["10.7.4.0/24"]
}

resource "azurerm_api_management" "apim" {
  name                 = "apim-quackersbank${random_string.unique.result}"
  location             = azurerm_resource_group.rg.location
  resource_group_name  = azurerm_resource_group.rg.name
  publisher_name       = "Implodingduck"
  publisher_email      = "something@nothing.com"
  virtual_network_type = "External"
  virtual_network_configuration {
    subnet_id = azurerm_subnet.apim.id
  }
  policy = [
    {
      xml_content = <<-EOT
    <policies>
      <inbound />
      <backend>
        <forward-request />
      </backend>
      <outbound>
        <set-header name="X-OperationName" exists-action="override">
            <value>@( context.Operation.Name )</value>
        </set-header>
        <set-header name="X-OperationMethod" exists-action="override">
            <value>@( context.Operation.Method )</value>
        </set-header>
        <set-header name="X-OperationUrl" exists-action="override">
            <value>@( context.Operation.UrlTemplate )</value>
        </set-header>
        <set-header name="X-ApiName" exists-action="override">
            <value>@( context.Api.Name )</value>
        </set-header>
        <set-header name="X-ApiPath" exists-action="override">
            <value>@( context.Api.Path )</value>
        </set-header>
      </outbound>
      <on-error>
        <set-header name="X-OperationName" exists-action="override">
            <value>@( context.Operation.Name )</value>
        </set-header>
        <set-header name="X-OperationMethod" exists-action="override">
            <value>@( context.Operation.Method )</value>
        </set-header>
        <set-header name="X-OperationUrl" exists-action="override">
            <value>@( context.Operation.UrlTemplate )</value>
        </set-header>
        <set-header name="X-ApiName" exists-action="override">
            <value>@( context.Api.Name )</value>
        </set-header>
        <set-header name="X-ApiPath" exists-action="override">
            <value>@( context.Api.Path )</value>
        </set-header>
        <set-header name="X-LastErrorMessage" exists-action="override">
            <value>@( context.LastError.Message )</value>
        </set-header>
      </on-error>
    </policies>
EOT
      xml_link    = null
    },
  ]
  zones    = []
  sku_name = "Developer_1"
  tags     = local.tags
}

resource "azurerm_api_management_api" "revisionv1" {
  name                 = "revision-api-v1"
  resource_group_name  = azurerm_resource_group.rg.name
  api_management_name  = azurerm_api_management.apim.name
  revision             = "1"
  display_name         = "Revision API"
  revision_description = "This is version 1"
  path                 = "revision"
  protocols            = ["https"]
  version              = ""
  version_set_id       = ""
  lifecycle {
    ignore_changes = [
      name,
      service_url
    ]
  }
}

resource "azurerm_api_management_api" "revisionv2" {
  name                 = "revision-api-v2"
  resource_group_name  = azurerm_resource_group.rg.name
  api_management_name  = azurerm_api_management.apim.name
  revision             = "2"
  display_name         = "Revision API"
  revision_description = "This is version 2"
  path                 = "revision"
  protocols            = ["https"]
  version              = ""
  version_set_id       = ""
  source_api_id        = "${azurerm_api_management_api.revisionv1.id}"

  lifecycle {
    ignore_changes = [
      name,
      service_url
    ]
  }
  
}

# resource "azurerm_api_management_api" "revisionv3" {
#   name                 = "revision-api-v3"
#   resource_group_name  = azurerm_resource_group.rg.name
#   api_management_name  = azurerm_api_management.apim.name
#   revision             = "3"
#   display_name         = "Revision API"
#   revision_description = "This is version 3"
#   path                 = "revision"
#   protocols            = ["https"]
#   version              = ""
#   version_set_id       = ""
#   source_api_id        = "${azurerm_api_management_api.revisionv2.id}"

#   lifecycle {
#     ignore_changes = [
#       name,
#       service_url
#     ]
#   }
  
# }



resource "azurerm_api_management_api_policy" "policy" {
  api_name            = azurerm_api_management_api.revisionv1.name
  api_management_name = azurerm_api_management_api.revisionv1.api_management_name
  resource_group_name = azurerm_api_management_api.revisionv1.resource_group_name

  xml_content = <<XML
<policies>
  <inbound>
    <base />
    <rewrite-uri template="/health" />
  </inbound>
</policies>
XML
}

resource "azurerm_api_management_api_operation" "hello" {
  operation_id        = "health"
  api_name            = azurerm_api_management_api.revisionv1.name
  api_management_name = azurerm_api_management_api.revisionv1.api_management_name
  resource_group_name = azurerm_api_management_api.revisionv1.resource_group_name
  display_name        = "health"
  method              = "GET"
  url_template        = "/health"
  description         = "get the health of the underlying api"
  response {
    status_code = 200
  }
}

# resource "azurerm_api_management_api_release" "current" {
#   name   = "Revision-API-Release"
#   api_id = azurerm_api_management_api.revisionv1.id
# }


