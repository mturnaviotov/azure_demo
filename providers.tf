terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.42.0"
    }
    azuredevops = {
      source  = "microsoft/azuredevops"
      version = "1.11.2"
    }
  }
}

#export AZDO_PERSONAL_ACCESS_TOKEN="{token secret here}"
#export AZDO_ORG_SERVICE_URL=https://dev.azure.com/${your_cool_company_name}
provider "azuredevops" {
  org_service_url       = var.ORG_SERVICE_URL
  personal_access_token = var.PERSONAL_ACCESS_TOKEN
}

provider "azurerm" {
  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
  features {}
}
