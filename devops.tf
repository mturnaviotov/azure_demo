resource "azuredevops_project" "blog" {
  name               = var.appname
  version_control    = "Git"
  work_item_template = "Agile"
}

#terraform import azuredevops_git_repository.blog blog/blog-app
resource "azuredevops_git_repository" "blog" {
  name           = "${var.appname}-app"
  project_id     = azuredevops_project.blog.id
  default_branch = "refs/heads/main"
  initialization {
    init_type = "Clean"
  }

  lifecycle {
    ignore_changes = [initialization]
  }
}

resource "azuredevops_git_repository_file" "readme-zero" {
  repository_id       = azuredevops_git_repository.blog.id
  file                = "README.md"
  content             = ""
  branch              = "refs/heads/main"
  commit_message      = "README zeroed"
  overwrite_on_create = true

  # add content, to prevent update it after changes via UI or humans
  lifecycle {
    ignore_changes = [
      file,
      commit_message
    ]
  }
}

resource "azuredevops_git_repository_file" "default_pipeline" {
  repository_id = azuredevops_git_repository.blog.id
  file          = "azure-pipelines.yml"

  content = templatefile("./azure-pipelines.tftpl", {
    registry_uri = azurerm_container_registry.blog.login_server,
    agent_pool   = var.agent_pool,
    cr_id        = azuredevops_serviceendpoint_azurecr.blog.service_endpoint_name,
    subscription = azuredevops_serviceendpoint_azurerm.blog.service_endpoint_name,
    name         = "${var.appname}${random_id.app.hex}"
  })

  branch              = "refs/heads/main"
  commit_message      = "Add azure-pipelines.yml"
  overwrite_on_create = true

  # Add 'content,' to prevent update it after changes via UI or humans
  lifecycle {
    ignore_changes = [
      file,
      commit_message
    ]
  }
}

data "azuredevops_agent_pool" "azure" {
  name = var.agent_pool
}

data "azuredevops_agent_queue" "azure" {
  project_id = azuredevops_project.blog.id
  name       = var.agent_pool_queue
}

resource "azuredevops_build_definition" "blog" {
  project_id = azuredevops_project.blog.id
  name       = "Blog Build Pipeline"

  repository {
    repo_type   = "TfsGit"
    repo_id     = azuredevops_git_repository.blog.id
    yml_path    = "azure-pipelines.yml"
    branch_name = "main"
  }

  lifecycle {
    ignore_changes = [repository["branch_name"]]
  }
}

resource "azuredevops_pipeline_authorization" "blog" {
  project_id  = azuredevops_project.blog.id
  resource_id = data.azuredevops_agent_queue.azure.id
  type        = "queue"
  pipeline_id = azuredevops_build_definition.blog.id

  lifecycle {
    ignore_changes = [resource_id]
  }
}

resource "azuredevops_serviceendpoint_azurerm" "blog" {
  project_id                             = azuredevops_project.blog.id
  service_endpoint_name                  = "${var.subscription_name}(${var.subscription_id})"
  service_endpoint_authentication_scheme = "ServicePrincipal"
  azurerm_spn_tenantid                   = var.tenant_id
  azurerm_subscription_id                = var.subscription_id
  azurerm_subscription_name              = var.subscription_name
  resource_group                         = azurerm_resource_group.blog.name
}
