output "git_remote_show" {
  value = "git remote add origin ${azuredevops_git_repository.blog.ssh_url}"
}
