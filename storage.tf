# Required for credentials storage mount
resource "azurerm_storage_account" "blog" {
  account_replication_type = "LRS"
  account_tier             = "Standard"
  location                 = azurerm_resource_group.blog.location
  name                     = "${var.appname}${random_id.app.hex}"
  resource_group_name      = azurerm_resource_group.blog.name
}
