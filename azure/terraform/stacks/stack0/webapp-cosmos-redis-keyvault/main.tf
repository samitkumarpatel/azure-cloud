provider "azurerm" {
  version = "=2.0.0"
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "rg01"
  location = "West Europe"
}

resource "azurerm_redis_cache" "example" {
  name                = "rcazwe001${azurerm_resource_group.example.name}"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  capacity            = 1
  family              = "C"
  sku_name            = "Standard"
  enable_non_ssl_port = false
  minimum_tls_version = "1.2"

  redis_configuration {
  }
}

resource "azurerm_app_service_plan" "example" {
  name                = "aspazwe001${azurerm_resource_group.example.name}"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  kind                = "Linux"
  reserved            = true
  
  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_app_service" "example" {
  name                = "asazwe001${azurerm_resource_group.example.name}"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  app_service_plan_id = azurerm_app_service_plan.example.id

  app_settings = {
    "ENV"           = "DEV"
    "REDIS_URI"     = azurerm_redis_cache.example.hostname
    "REDIS_POST"    = azurerm_redis_cache.example.ssl_port
  }

  site_config  {
      linux_fx_version  =   "JAVA|8-jre8"
  }

  identity  {
      type  =  "SystemAssigned"
  }
  
}

resource "azurerm_app_service_slot" "example" {
  name                = "ass01azwe001${azurerm_resource_group.example.name}"
  app_service_name    = azurerm_app_service.example.name
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  app_service_plan_id = azurerm_app_service_plan.example.id

  site_config {
    linux_fx_version  =   "JAVA|8-jre8"
  }

  app_settings = {
    "ENV"           = "DEV"
    "REDIS_URI"     = azurerm_redis_cache.example.hostname
    "REDIS_POST"    = azurerm_redis_cache.example.ssl_port
  }
  
  identity  {
      type  =  "SystemAssigned"
  }

}


output "appservice_slot_identity" {
    value   = azurerm_app_service_slot.example.identity 
}

output "appservice_identity" {
    value   = azurerm_app_service.example.identity 
}


data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "example" {
  name                        = "kvazwe001${azurerm_resource_group.example.name}"
  location                    = azurerm_resource_group.example.location
  resource_group_name         = azurerm_resource_group.example.name
  enabled_for_disk_encryption = true
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  purge_protection_enabled    = false

  sku_name = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    key_permissions = [
      "get", "list"
    ]

    secret_permissions = [
      "get", "list"
    ]

    storage_permissions = [
      "get", "list"
    ]
  }
}

resource "azurerm_key_vault_access_policy" "example0" {
  key_vault_id = azurerm_key_vault.example.id

  tenant_id = azurerm_app_service.example.identity[0].tenant_id
  object_id = azurerm_app_service.example.identity[0].principal_id

  key_permissions = [
    "get", "list"
  ]

  secret_permissions = [
    "get", "list"
  ]
}

resource "azurerm_key_vault_access_policy" "example1" {
  key_vault_id = azurerm_key_vault.example.id

  tenant_id = azurerm_app_service_slot.example.identity[0].tenant_id
  object_id = azurerm_app_service_slot.example.identity[0].principal_id

  key_permissions = [
    "get", "list"
  ]

  secret_permissions = [
    "get", "list"
  ]
}

# resource "local_file" "deploy_stack" {
#   content = templatefile("${path.module}/terraform.tfvars.tmpl",
#     {
#       resource_group_name   = azurerm_resource_group.example.name
#       redis_cache_name      = azurerm_redis_cache.example.name
#       message               = "Hello World!"
#     }
#   )
#   filename = "${path.module}/dependent/terraform.tfvars"
# }

# data "azurerm_app_service" "exampled" {
#   name                  =  azurerm_app_service.example.name
#   resource_group_name   =  azurerm_resource_group.example.name
# }

# locals {
#   outbound_ips          =  split(",", data.azurerm_app_service.exampled.outbound_ip_addresses)
# }

# resource "azurerm_redis_firewall_rule" "exampled" {
#   count                 =  length(local.outbound_ips)
#   name                  =  "rule_${count.index}"
#   redis_cache_name      =  azurerm_redis_cache.example.name
#   resource_group_name   =  azurerm_resource_group.example.name
#   start_ip              =  element(local.outbound_ips,count.index)
#   end_ip                =  element(local.outbound_ips,count.index)
# }