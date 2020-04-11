resource "azurerm_public_ip" "network" {
  name                = "pip0${var.name}"
  resource_group_name = var.rg
  location            = var.location
  allocation_method   = "Dynamic"
}

locals {
  gateway_public_ip_name    = "${var.name}-gateway-pip01"
  frontend_port_name        = "${var.name}-fe-port80"
  frontend_ip_name          = "${var.name}-fe-ip01"
  backend_pool_name         = "${var.name}-be-pool01"
  backend_http_name         = "${var.name}-be-http80"
  listner_name              = "${var.name}-listner01"
  rule_name                 = "${var.name}-rule01"
}

resource "azurerm_application_gateway" "example" {
  name                = var.name
  resource_group_name = var.rg
  location            = var.location

  sku {
    name     = "Standard_Small"
    tier     = "Standard"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = local.gateway_public_ip_name
    subnet_id = var.subnetid
  }

  frontend_port {
    name = local.frontend_port_name
    port = 80
  }
  
  frontend_ip_configuration {
    name                 = local.frontend_ip_name
    public_ip_address_id = azurerm_public_ip.network.id
  }
  
  backend_address_pool {
    name = local.backend_pool_name
    ip_addresses = var.vmips
  }

  backend_http_settings {
    name                  = local.backend_http_name
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 1
  }

  http_listener {
    name                           = local.listner_name
    frontend_ip_configuration_name = local.frontend_ip_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = local.rule_name
    rule_type                  = "Basic"
    http_listener_name         = local.listner_name
    backend_address_pool_name  = local.backend_pool_name
    backend_http_settings_name = local.backend_http_name
  }
}