resource "azuredevops_project" "blog" {
  name               = var.appname
  version_control    = "Git"
  work_item_template = "Agile"
}

# default repo is unusable by terraform
# data "azuredevops_git_repository" "blog-default-repo" {
#   project_id = azuredevops_project.blog.id
#   name       = "blog"
# }

# resource "azuredevops_git_repository_branch" "blog-default" {
#   repository_id = data.azuredevops_git_repository.blog-default-repo.id
#   name          = "main"
#   ref_branch    = "main" #data.azuredevops_git_repository.blog.default_branch
# }

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

# main branch already created by Azure (auto branch creation policy on organization level)
# resource "azuredevops_git_repository_branch" "blog-main" {
#   repository_id = azuredevops_git_repository.blog.id
#   name          = "main"
#   ref_branch    = "refs/heads/main" #data.azuredevops_git_repository.blog.default_branch
# }

resource "azuredevops_git_repository_file" "default_pipeline" {
  repository_id = azuredevops_git_repository.blog.id
  file          = "azure-pipelines.yml"
  content = templatefile("./azure-pipelines.tftpl", { appname = var.appname, registry_uri = azurerm_container_registry.blog.login_server, endpoint_id = azuredevops_serviceendpoint_dockerregistry.blog.id,
  subscription = "${var.subscription_name}(${var.subscription_id})", name = "${var.appname}${random_id.app.hex}" })

  branch              = "refs/heads/main"
  commit_message      = "Add azure-pipelines.yml"
  overwrite_on_create = true

  # add content, to prevent update it after changes via UI or humans
  lifecycle {
    ignore_changes = [
      file,
      content,
      commit_message
    ]
  }
}

data "azuredevops_agent_pool" "azure" {
  name = "Azure Pipelines"
}

data "azuredevops_agent_queue" "azure" {
  project_id = azuredevops_project.blog.id
  name       = "Azure Pipelines"
}

resource "azuredevops_build_definition" "blog" {
  project_id = azuredevops_project.blog.id
  name       = "Blog Build Pipeline"

  repository {
    repo_type = "TfsGit"
    repo_id   = azuredevops_git_repository.blog.id
    yml_path  = "azure-pipelines.yml"
  }

  lifecycle {
    ignore_changes = [repository["branch_name"]]
  }
}

resource "azuredevops_pipeline_authorization" "blog-auth" {
  project_id  = azuredevops_project.blog.id
  resource_id = data.azuredevops_agent_queue.azure.id
  type        = "queue"
  pipeline_id = azuredevops_build_definition.blog.id
}
