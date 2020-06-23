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

output "appservice_outbound_ip" {
    value   = azurerm_app_service.example.outbound_ip_addresses 
}

resource "azurerm_redis_firewall_rule" "example" {
  for_each            = toset(split(",",azurerm_app_service.example.outbound_ip_addresses))
  name                = "rule_${replace(each.key, ".", "_")}"
  redis_cache_name    = azurerm_redis_cache.example.name
  resource_group_name = azurerm_resource_group.example.name
  start_ip            = each.value
  end_ip              = each.value
}
