resource "azurerm_container_registry" "blog" {
  location            = azurerm_resource_group.blog.location
  name                = "${var.appname}${random_id.app.hex}"
  resource_group_name = azurerm_resource_group.blog.name
  sku                 = "Basic"
  admin_enabled       = true
  depends_on          = [azurerm_resource_group.blog]
}

### Build step id from here
resource "azuredevops_serviceendpoint_azurecr" "blog" {
  azurecr_name              = "${var.appname}${random_id.app.hex}"
  azurecr_spn_tenantid      = var.tenant_id
  azurecr_subscription_id   = var.subscription_id
  azurecr_subscription_name = var.subscription_name
  project_id                = azuredevops_project.blog.id
  resource_group            = azurerm_resource_group.blog.name
  service_endpoint_name     = "blog-azurecr-${var.appname}${random_id.app.hex}"
}
