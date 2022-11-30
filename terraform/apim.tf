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

resource "azurerm_api_management_api_version_set" "vs" {
  name                = "revision-api-1_0_0"
  resource_group_name = azurerm_resource_group.rg.name
  api_management_name = azurerm_api_management.apim.name
  display_name        = "Revision-API-Version-Set"
  versioning_scheme   = "Segment"
}

resource "azurerm_api_management_api" "revisionv1" {
  name                 = "revision-api;rev=1"
  resource_group_name  = azurerm_resource_group.rg.name
  api_management_name  = azurerm_api_management.apim.name
  revision             = "1"
  display_name         = "Revision Api"
  revision_description = "This is version 1"
  path                 = "revision"
  protocols            = ["https"]
  version              = ""
  version_set_id       = azurerm_api_management_api_version_set.vs.id
  
  import {
    content_format = "openapi"
    content_value = <<YAML
openapi: 3.0.1
info:
  title: 'Revision API'
  description: 'basic description'
  version: ''
paths:
  /health:
    get:
      summary: health
      description: get the health of the underlying api
      operationId: health
      responses:
        '200':
          description: ''
components:
  securitySchemes:
    apiKeyHeader:
      type: apiKey
      name: Ocp-Apim-Subscription-Key
      in: header
    apiKeyQuery:
      type: apiKey
      name: subscription-key
      in: query
security:
  - apiKeyHeader: [ ]
  - apiKeyQuery: [ ]
YAML
  }
  
  lifecycle {
    ignore_changes = [
      name,
      service_url
    ]
  }


}


# resource "azapi_resource_action" "symbolicname" {
#   type = "Microsoft.ApiManagement/service/apis@2021-08-01"
#   resource_id = "${azurerm_api_management.apim.id}/apis/${azurerm_api_management_api.revisionv1.name}"
#   method = "PUT"
#   body = jsonencode({
#     properties = {
#       apiRevision = "2"
#       apiRevisionDescription = "This is version 2"
#       sourceApiId = azurerm_api_management_api.revisionv1.id
#     }
#   })
# }


# resource "azurerm_api_management_api" "revisionv2" {
#   name                 = "revision-api;rev=2"
#   resource_group_name  = azurerm_resource_group.rg.name
#   api_management_name  = azurerm_api_management.apim.name
#   revision             = "2"
#   revision_description = "This is version 2"
#   path                 = "revision"
#   protocols            = ["https"]
#   version              = ""
#   source_api_id        = "${azurerm_api_management_api.revisionv1.id}"

#   lifecycle {
#     ignore_changes = [
#       name,
#       service_url
#     ]
#   }
  
# }

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

# resource "azurerm_api_management_api_operation" "hello" {
#   operation_id        = "health"
#   api_name            = azurerm_api_management_api.revisionv1.name
#   api_management_name = azurerm_api_management_api.revisionv1.api_management_name
#   resource_group_name = azurerm_api_management_api.revisionv1.resource_group_name
#   display_name        = "health"
#   method              = "GET"
#   url_template        = "/health"
#   description         = "get the health of the underlying api"
#   response {
#     status_code = 200
#   }
# }

# resource "azurerm_api_management_api_release" "current" {
#   name   = "Revision-API-Release"
#   api_id = azurerm_api_management_api.revisionv1.id
# }


