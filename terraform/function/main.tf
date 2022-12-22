
module "azure_region" {
  source  = "claranet/regions/azurerm"
  version = "6.1.0"

  azure_region = var.azure_region
}

module "rg" {
  source  = "claranet/rg/azurerm"
  version = "6.1.0"

  location    = module.azure_region.location
  client_name = var.client_name
  environment = var.environment
  stack       = var.stack
}

module "logs" {
  source  = "claranet/run-common/azurerm//modules/logs"
  version = "7.3.0"

  client_name         = var.client_name
  environment         = var.environment
  stack               = var.stack
  location            = module.azure_region.location
  location_short      = module.azure_region.location_short
  resource_group_name = module.rg.resource_group_name
}

module "acr" {
  source  = "claranet/acr/azurerm"
  version = "6.2.0"

  client_name         = var.client_name
  environment         = var.environment
  stack               = var.stack
  location            = module.azure_region.location
  location_short      = module.azure_region.location_short
  resource_group_name = module.rg.resource_group_name
  sku                 = var.acr_sku

  logs_destinations_ids = [
    module.logs.logs_storage_account_id,
    module.logs.log_analytics_workspace_id
  ]
}

module "function_app_linux" {
  source  = "claranet/function-app/azurerm"
  version = "7.2.0"

  client_name         = var.client_name
  environment         = var.environment
  stack               = var.stack
  location            = module.azure_region.location
  location_short      = module.azure_region.location_short
  resource_group_name = module.rg.resource_group_name

  storage_account_network_rules_enabled = false # need vnet for this feature

  os_type              = "Linux"
  function_app_version = 4
  function_app_site_config = {
    application_stack = {
       docker = {
         registry_url = module.acr.acr_fqdn
         image_name   = var.image_name
         image_tag    = var.image_tag
       }

    }

    container_registry_use_managed_identity = true
  }

  storage_account_identity_type = "SystemAssigned"

  logs_destinations_ids = [
    module.logs.logs_storage_account_id,
    module.logs.log_analytics_workspace_id
  ]
}
