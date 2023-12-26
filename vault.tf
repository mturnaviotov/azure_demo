resource "azurerm_key_vault" "blog" {
  name                            = "${var.appname}${random_id.app.hex}"
  location                        = azurerm_resource_group.blog.location
  resource_group_name             = azurerm_resource_group.blog.name
  enabled_for_disk_encryption     = true
  tenant_id                       = data.azurerm_client_config.current.tenant_id
  soft_delete_retention_days      = 7
  purge_protection_enabled        = false
  enabled_for_deployment          = true
  enabled_for_template_deployment = true

  sku_name                  = "standard"
  enable_rbac_authorization = true

  network_acls {
    default_action = "Allow"
    bypass         = "AzureServices"
  }

  # Azure level RBAC implemented 

  depends_on = [azurerm_resource_group.blog]

  timeouts {
    create = "3m"
    delete = "1m"
  }
}

# one line password generation
resource "azurerm_key_vault_secret" "blog" {
  key_vault_id = azurerm_key_vault.blog.id
  name         = "secret-key-base"
  value        = random_password.password.result

  lifecycle {
    ignore_changes = [
      # Ignore changes to tags, e.g. because a management agent
      # updates these based on some ruleset managed elsewhere.
      value
    ]
  }
}

# certificate generation
# resource "azurerm_key_vault_key" "blog" {
#   name         = "secret-key-base"
#   key_vault_id = azurerm_key_vault.blog.id
#   key_type     = "RSA"
#   key_size     = 2048

#   key_opts = [
#     "decrypt",
#     "encrypt",
#     "sign",
#     "unwrapKey",
#     "verify",
#     "wrapKey",
#   ]

#   rotation_policy {
#     automatic {
#       time_before_expiry = "P30D"
#     }

#     expire_after         = "P90D"
#     notify_before_expiry = "P29D"
#   }

#   depends_on = [azurerm_key_vault.blog]
# }
