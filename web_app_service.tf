resource "azurerm_service_plan" "sp-blog-linux" {
  location            = azurerm_resource_group.blog.location
  name                = azurerm_resource_group.blog.name
  os_type             = "Linux"
  resource_group_name = azurerm_resource_group.blog.name
  sku_name            = "F1"

  depends_on = [azurerm_resource_group.blog]
}

resource "azurerm_linux_web_app" "blog-linux" {
  enabled             = true
  https_only          = true
  location            = azurerm_resource_group.blog.location
  name                = "${var.appname}${random_id.app.hex}"
  resource_group_name = azurerm_resource_group.blog.name
  service_plan_id     = azurerm_service_plan.sp-blog-linux.id
  tags                = {}

  identity {
    type = "SystemAssigned"
  }

  app_settings = {
    "VaultURL"                                   = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault.blog.vault_uri}secrets/secret-key-base/)"
    "APPLICATIONINSIGHTS_CONNECTION_STRING"      = azurerm_application_insights.blog.connection_string
    "WEBSITES_ENABLE_APP_SERVICE_STORAGE"        = "true"
    "XDT_MicrosoftApplicationInsights_Mode"      = "Recommended"
    "ApplicationInsightsAgent_EXTENSION_VERSION" = "~3"
    "WEBSITE_ENABLE_SYNC_UPDATE_SITE"            = "true"
    # Rails env secret key, will be replaced via Vault. demo example
    "SECRET_KEY_BASE" = "1234567"
  }

  site_config {
    always_on                               = false
    container_registry_use_managed_identity = true
    default_documents = [
      "index.html"
    ]
    ftps_state          = "Disabled"
    load_balancing_mode = "LeastRequests"
    application_stack {
      docker_image_name        = var.appname
      docker_registry_url      = "https://${azurerm_container_registry.blog.login_server}"
      docker_registry_username = azurerm_container_registry.blog.admin_username
      docker_registry_password = azurerm_container_registry.blog.admin_password
    }
  }

  storage_account {
    access_key   = "@AppSettingRef(VaultURL)"
    account_name = azurerm_storage_account.blog.name
    mount_path   = "/mnt/secrets"
    name         = "secret-key-base"
    share_name   = "secrets"
    type         = "AzureFiles"
  }

  lifecycle {
    ignore_changes = [
      app_settings["DOCKER_CUSTOM_IMAGE_NAME"], site_config["application_stack"], identity
    ]
  }

  depends_on = [azurerm_key_vault_secret.blog]
}

resource "azurerm_role_assignment" "blog-pull" {
  scope                = azurerm_resource_group.blog.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_linux_web_app.blog-linux.identity[0].principal_id
}
