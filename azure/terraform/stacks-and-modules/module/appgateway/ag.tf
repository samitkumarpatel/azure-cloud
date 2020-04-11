resource "azurerm_public_ip" "network" {
  name                = "gw-pip01"
  resource_group_name = var.resource_group
  location            = var.location
  allocation_method   = "Dynamic"
}

resource "azurerm_application_gateway" "example" {
  name                = "ag01"
  resource_group_name = var.resource_group
  location            = var.location

  sku {
    name     = "Standard_Small"
    tier     = "Standard"
    capacity = 2
  }
  
  gateway_ip_configuration {
    name      = var.gateway_public_ip_name
    subnet_id = element(tolist(azurerm_virtual_network.example.subnet),0).id
  }
  
  frontend_ip_configuration {
    name                 = var.gateway_fe_ip_name
    public_ip_address_id = azurerm_public_ip.network.id
  }

  dynamic "frontend_port" {
      for_each  =  [ for s in var.gateway_config: {
        name = s.gwFrontendHttpPortName
        port = s.port
      }]
      content {
        name = frontend_port.value.name
        port = frontend_port.value.port
      }
  }
  
  dynamic "backend_address_pool" {
      for_each  =  [ for s in var.gateway_config: {
        name          = s.gwBackendPoolName
        ip_addresses = s.gwBackendPoolIps
      }]
      content {
        name          = backend_address_pool.value.name
        ip_addresses = backend_address_pool.value.ip_addresses
      }
  }

  dynamic "backend_http_settings" {
      for_each  =  [ for s in var.gateway_config: {
        name                  = s.gwBackendHttpPortName
        cookie_based_affinity = "Disabled"
        port                  = s.port
        protocol              = "Http"
        request_timeout       = 1
      }]
      content {
        name                  = backend_http_settings.value.name
        cookie_based_affinity = backend_http_settings.value.cookie_based_affinity
        port                  = backend_http_settings.value.port
        protocol              = backend_http_settings.value.protocol
        request_timeout       = backend_http_settings.value.request_timeout
      }
  }

  dynamic "http_listener" {
      for_each  =  [ for s in var.gateway_config: {
        name                           = s.gatewayListnerName
        frontend_ip_configuration_name = var.gateway_fe_ip_name
        frontend_port_name             = s.gwFrontendHttpPortName
        protocol                       = "Http"
      }]
      content {
        name                           = http_listener.value.name
        frontend_ip_configuration_name = http_listener.value.frontend_ip_configuration_name
        frontend_port_name             = http_listener.value.frontend_port_name
        protocol                       = http_listener.value.protocol
      }
  }

  dynamic "request_routing_rule" {
      for_each  =  [ for s in var.gateway_config: {
        name                       = s.gatewayRuleName
        rule_type                  = "Basic"
        http_listener_name         = s.gatewayListnerName
        backend_address_pool_name  = s.gwBackendPoolName
        backend_http_settings_name = s.gwBackendHttpPortName
      }]
      content {
        name                       = request_routing_rule.value.name
        rule_type                  = request_routing_rule.value.rule_type
        http_listener_name         = request_routing_rule.value.http_listener_name
        backend_address_pool_name  = request_routing_rule.value.backend_address_pool_name
        backend_http_settings_name = request_routing_rule.value.backend_http_settings_name
      }
  }
  
  tags  =   azurerm_resource_group.example.tags
}