resource "azurerm_resource_group" "blog" {
  location = "Poland Central"
  name     = "${var.appname}${random_id.app.hex}"
}
