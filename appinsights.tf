resource "azurerm_log_analytics_workspace" "blog" {
  name                = "${var.appname}${random_id.app.hex}"
  location            = azurerm_resource_group.blog.location
  resource_group_name = azurerm_resource_group.blog.name
}

resource "azurerm_application_insights" "blog" {
  name                = "${var.appname}${random_id.app.hex}"
  resource_group_name = azurerm_resource_group.blog.name
  location            = azurerm_resource_group.blog.location
  application_type    = "web"
  workspace_id        = azurerm_log_analytics_workspace.blog.id
}

# strange requirement - static UUID as name value. can be replaced by random uuid and ignored at life cycle
resource "azurerm_application_insights_workbook" "blog" {
  name                = "358dceb9-ba72-75e5-5149-16ab4663cfc4"
  resource_group_name = azurerm_resource_group.blog.name
  location            = azurerm_resource_group.blog.location
  display_name        = "workbook-blog"
  data_json = jsonencode({
    "version" = "Notebook/1.0",
    "items" = [
      {
        "type" = 1,
        "content" = {
          "json" = "Test2022"
        },
        "name" = "text - 0"
      }
    ],
    "isLocked" = false,
    "fallbackResourceIds" = [
      "Azure Monitor"
    ]
  })
}

# terraform import azurerm_monitor_action_group.blog /subscriptions/${SUBSCRIPTIONID}/resourceGroups/${RESOURCEGROUP}/providers/Microsoft.Insights/actionGroups/"Application Insights Smart Detection"
resource "azurerm_monitor_action_group" "blog" {
  name                = "Application Insights Smart Detection"
  resource_group_name = azurerm_resource_group.blog.name
  short_name          = "SmartDetect"

  arm_role_receiver {
    name                    = "Monitoring Contributor"
    role_id                 = "749f88d5-cbae-40b8-bcfc-e573ddc772fa"
    use_common_alert_schema = true
  }

  arm_role_receiver {
    name                    = "Monitoring Reader"
    role_id                 = "43d0d8ad-25c7-4714-9337-8ba259a9fe05"
    use_common_alert_schema = true
  }
}

# terraform import /subscriptions/${SUBSCRIPTIONID}/resourceGroups/${RESOURCEGROUP}/providers/microsoft.alertsmanagement/smartDetectorAlertRules/Failure%20Anomalies%20-%20blog597c9cc8a137d676
resource "azurerm_monitor_smart_detector_alert_rule" "blog" {
  name                = "Failure Anomalies - ${var.appname}${random_id.app.hex}"
  resource_group_name = azurerm_resource_group.blog.name
  severity            = "Sev3"
  scope_resource_ids  = [azurerm_application_insights.blog.id]
  frequency           = "PT1M"
  detector_type       = "FailureAnomaliesDetector"
  description         = "Failure Anomalies notifies you of an unusual rise in the rate of failed HTTP requests or dependency calls."

  action_group {
    ids = [azurerm_monitor_action_group.blog.id]
  }
  depends_on = [azurerm_monitor_action_group.blog]
}
