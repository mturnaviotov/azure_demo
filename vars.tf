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

variable "appname" {
  type        = string
  default     = "blog"
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
