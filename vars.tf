# terraform plan|apply -var-file=env.tfvars

variable "client_id" {
  sensitive = true
  type      = string
}

variable "client_secret" {
  sensitive = true
  type      = string
}

variable "tenant_id" {
  sensitive = true
  type      = string
}

variable "ORG_SERVICE_URL" {
  sensitive = true
  type      = string
}

variable "PERSONAL_ACCESS_TOKEN" {
  sensitive = true
  type      = string
}

variable "appname" {
  type        = string
  default     = "blog"
  description = "app name"
}

# F1 - free, B1 minumum Recommended.
# List to all available https://azure.microsoft.com/en-us/pricing/details/app-service/windows/#pricing
variable "app_service_plan" {
  type        = string
  default     = "F1"
  description = "app name"
}

variable "subscription_id" {
  type        = string
  description = "subscription_id"
}

variable "subscription_name" {
  type        = string
  description = "subscription_name"
}

variable "agent_pool" {
  type        = string
  description = "Agent Pool Name"
  default     = "default"
  # 'Azure Pipelines' for paid account
}

variable "agent_pool_queue" {
  type        = string
  description = "Agent Pool Queue Name"
  default     = "default"
  # 'Azure Pipelines' for paid account
}

################################################

resource "random_id" "app" {
  keepers = {
    # Generate a new id each time we switch to a new AMI id
    id = var.appname
  }

  byte_length = 8
}

resource "random_password" "password" {
  length  = 16
  special = false
  #  override_special = "!#$%&*()-_=+[]{}<>:?"
}

data "azurerm_client_config" "current" {}
