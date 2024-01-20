######## Default repo is unusable by terraform due to api realization
##############################################
# resource "azuredevops_project" "blog" {
#   name               = var.appname
#   version_control    = "Git"
#   work_item_template = "Agile"
# }
# data "azuredevops_git_repository" "blog-default" {
#   project_id = azuredevops_project.blog.id
#   name       = "blog"
# }
# resource "azuredevops_git_repository_branch" "blog-default" {
#   repository_id = data.azuredevops_git_repository.blog-default-repo.id
#   name          = "main"
#   ref_branch    = "main" #data.azuredevops_git_repository.blog.default_branch
# }
