provider "azurerm" {
  version = "=2.0.0"
  features {}
}

data "azurerm_app_service" "example" {
  name                  =  "asazwe001rg01"
  resource_group_name   =  "rg01"
}

locals {
  outbound_ips          =  split(",", data.azurerm_app_service.example.outbound_ip_addresses)
}

resource "azurerm_redis_firewall_rule" "example" {
  count                 =  length(local.outbound_ips)
  name                  =  "rule_${count.index}"
  redis_cache_name      =  "rcazwe001rg01"
  resource_group_name   =  "rg01"
  start_ip              =  element(local.outbound_ips,count.index)
  end_ip                =  element(local.outbound_ips,count.index)
}