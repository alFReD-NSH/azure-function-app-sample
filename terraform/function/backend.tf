terraform {
  backend "azurerm" {
    resource_group_name  = "VisualStudioOnline-930CF119528C42148C9CEA6527144D2D"
    storage_account_name = "faridterraformstate"
    container_name       = "tfstate"
    key                  = "prod.terraform.tfstate"
  }
}