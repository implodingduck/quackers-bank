resource "random_uuid" "uuid" {
}

resource "azurerm_application_insights_workbook" "example" {
  name                = random_uuid.uuid.result
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  display_name        = "tf-based-workbook"
  data_json = jsonencode({
    "version" = "Notebook/1.0",
    "items" = [
      {
        "type" : 10,
        "content" : {
          "version" : "MetricsItem/2.0",
          "size" : 0,
          "chartType" : 2,
          "resourceType" : "microsoft.insights/components",
          "metricScope" : 0,
          "resourceIds" : [
            "${azurerm_application_insights.app.id}"
          ],
          "timeContext" : {
            "durationMs" : 86400000
          },
          "metrics" : [
            {
              "namespace" : "azure.applicationinsights",
              "metric" : "azure.applicationinsights--HttpTrigger Count",
              "aggregation" : 4,
              "splitBy" : null
            }
          ],
          "gridSettings" : {
            "rowLimit" : 10000
          }
        },
        "name" : "metric - 0"
      },
      {
        "type" : 10,
        "content" : {
          "version" : "MetricsItem/2.0",
          "size" : 0,
          "chartType" : 2,
          "color" : "red",
          "resourceType" : "microsoft.insights/components",
          "metricScope" : 0,
          "resourceIds" : [
            "${azurerm_application_insights.app.id}"
          ],
          "timeContext" : {
            "durationMs" : 86400000
          },
          "metrics" : [
            {
              "namespace" : "azure.applicationinsights",
              "metric" : "azure.applicationinsights--HttpTrigger Failures",
              "aggregation" : 7,
              "splitBy" : null
            }
          ],
          "gridSettings" : {
            "rowLimit" : 10000
          }
        },
        "name" : "metric - 1"
      },
      {
        "type" : 9,
        "content" : {
          "version" : "KqlParameterItem/1.0",
          "crossComponentResources" : [
            "${azurerm_application_insights.app.id}"
          ],
          "parameters" : [
            {
              "version" : "KqlParameterItem/1.0",
              "name" : "exception_operation_id",
              "type" : 2,
              "query" : "union *\r\n| where itemType == \"exception\"\r\n| distinct operation_Id",
              "crossComponentResources" : [
                "${azurerm_application_insights.app.id}"
              ],
              "typeSettings" : {
                "additionalResourceOptions" : [],
                "showDefault" : false
              },
              "timeContext" : {
                "durationMs" : 86400000
              },
              "queryType" : 0,
              "resourceType" : "microsoft.insights/components",
              "value" : null
            }
          ],
          "style" : "pills",
          "queryType" : 0,
          "resourceType" : "microsoft.insights/components"
        },
        "name" : "parameters - 3"
      },
      {
        "type" : 3,
        "content" : {
          "version" : "KqlItem/1.0",
          "query" : "union *\r\n| where operation_Id == \"{exception_operation_id}\"\r\n| order by timestamp desc",
          "size" : 0,
          "timeContext" : {
            "durationMs" : 86400000
          },
          "queryType" : 0,
          "resourceType" : "microsoft.insights/components",
          "crossComponentResources" : [
            "${azurerm_application_insights.app.id}"
          ]
        },
        "name" : "query - 2"
      }
    ],
    "isLocked" = false,
    "fallbackResourceIds" = [
      "Azure Monitor"
    ]
  })

  tags = local.tags

}