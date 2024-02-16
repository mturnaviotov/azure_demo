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

  agent_pool_name = data.azuredevops_agent_pool.azure.name

  repository {
    repo_type   = "TfsGit"
    repo_id     = azuredevops_git_repository.blog.id
    yml_path    = "azure-pipelines.yml"
    branch_name = "main"
  }

  ci_trigger {
    use_yaml = false
  }

  #  lifecycle {
  #    ignore_changes = [repository["branch_name"]]
  #  }
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

resource "azuredevops_pipeline_authorization" "blog-endpoint" {
  project_id  = azuredevops_project.blog.id
  resource_id = azuredevops_serviceendpoint_azurerm.blog.id
  type        = "endpoint"
  pipeline_id = azuredevops_build_definition.blog.id

  # lifecycle {
  #   ignore_changes = [resource_id]
  # }
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
