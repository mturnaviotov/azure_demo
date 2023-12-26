resource "azurerm_resource_group" "blog" {
  location = "Poland Central"
  name     = "${var.appname}${random_id.app.hex}"
}

resource "azuredevops_project" "blog" {
  name               = var.appname
  version_control    = "Git"
  work_item_template = "Agile"
}

#terraform import azuredevops_git_repository.blog blog/blog
resource "azuredevops_git_repository" "blog" {
  name       = var.appname
  project_id = azuredevops_project.blog.id
  initialization {
    init_type = "Uninitialized"
  }

  lifecycle {
    ignore_changes = [initialization]
  }

  depends_on = [azurerm_resource_group.blog]
}

resource "azuredevops_git_repository_file" "default_pipeline" {
  repository_id = azuredevops_git_repository.blog.id
  file          = "azure-pipelines.yml"
  content = templatefile("./azure-pipelines.tftpl",
    { appname = var.appname, registry_uri = azurerm_container_registry.blog.login_server, endpoint_id = azuredevops_serviceendpoint_dockerregistry.blog.id,
  subscription = "${var.subscription_name}(${var.subscription_id})", name = "${var.appname}${random_id.app.hex}" })

  branch              = "refs/heads/main"
  commit_message      = "Add azure-pipelines.yml"
  overwrite_on_create = true

  lifecycle {
    ignore_changes = [
      file,
      content,
      commit_message
    ]
  }
}
