resource "azurerm_service_plan" "sp-blog-linux" {
  location            = azurerm_resource_group.blog.location
  name                = "blog"
  os_type             = "Linux"
  resource_group_name = azurerm_resource_group.blog.name
  sku_name            = "F1"

  depends_on = [azurerm_resource_group.blog]
}

resource "azurerm_container_registry" "blog" {
  location            = azurerm_resource_group.blog.location
  name                = "${var.appname}${random_id.app.hex}"
  resource_group_name = azurerm_resource_group.blog.name
  sku                 = "Basic"
  admin_enabled       = true
  depends_on          = [azurerm_resource_group.blog]
}

resource "azuredevops_serviceendpoint_dockerregistry" "blog" {
  project_id            = azuredevops_project.blog.id
  service_endpoint_name = "registry connection"
  docker_username       = azurerm_container_registry.blog.admin_username
  docker_password       = azurerm_container_registry.blog.admin_password
  registry_type         = "DockerHub"

  lifecycle {
    ignore_changes = [registry_type, description, docker_email, docker_registry, docker_username]
  }
  depends_on = [azurerm_container_registry.blog]
}
