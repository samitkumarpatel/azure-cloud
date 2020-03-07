provider "azurerm" {
  version = "=2.0.0"
  features {}
}

resource "azurerm_resource_group" "example" {
  name                =   "p03"
  location            =   "Wes tEurope"
  tags                =  {
      env   =   "development"
  }
}

variable "subnets_list" {
  type  = list
  default = [
    {
      name  = "AppgatewaySubnet",
      address = "10.0.1.0/24"
    }
  ]
}

resource "azurerm_virtual_network" "example" {
  name                = "vnet02"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  address_space       = ["10.0.0.0/16"]
  
  dynamic "subnet" {
    for_each = [for s in var.subnets_list: {
      name   = s.name
      prefix = s.address
    }]

    content {
      name           = subnet.value.name
      address_prefix = subnet.value.prefix
    }
  }

  tags = azurerm_resource_group.example.tags
}

resource "azurerm_public_ip" "network" {
  name                = "pip01"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  allocation_method   = "Dynamic"
}

output "application_gateway_public_ip" {
  value = azurerm_public_ip.network.ip_address
}

variable "gateway_config" {
  type = list
  default = [
    {
      gwPublicIpName            = "gatewayPublicIP"
      gwFrontendIpName          = "gatewayFEIP"
      gwFrontendHttpPortName    = "nginxFEPort80"
      gwBackendPoolName         = "nginxBEPool"
      gwBackendHttpPortName     = "nginxBEhttpPort80"
      gatewayListnerName        = "nginxListner"
      gatewayRuleName           = "nginxRule"
    },
    {
      gwPublicIpName            = "gatewayPublicIP"
      gwFrontendIpName          = "gatewayFEIP"
      gwFrontendHttpPortName    = "jenkinsFEPort8080"
      gwBackendPoolName         = "jenkinsBEPool"
      gwBackendHttpPortName     = "jenkinsBEhttpPort8080"
      gatewayListnerName        = "jenkinsListner"
      gatewayRuleName           = "jenkinsRule"
    }
  ]
}

resource "azurerm_application_gateway" "example" {
  name                = "ag01"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location

  sku {
    name     = "Standard_Small"
    tier     = "Standard"
    capacity = 2
  }
  
  gateway_ip_configuration {
    name      = var.gateway_config[0].gwPublicIpName
    subnet_id = element(tolist(azurerm_virtual_network.example.subnet),0).id
  }
  
  frontend_ip_configuration {
    name                 = var.gateway_config[0].gwFrontendIpName
    public_ip_address_id = azurerm_public_ip.network.id
  }

  frontend_port {
    name = var.gateway_config[0].gwFrontendHttpPortName
    port = 80
  }
  frontend_port {
    name = var.gateway_config[1].gwFrontendHttpPortName
    port = 8080
  }
  
  backend_address_pool {
    name          = var.gateway_config[0].gwBackendPoolName
    ip_addresses = [azurerm_linux_virtual_machine.example[0].]
  }
  backend_address_pool {
    name          = var.gateway_config[1].gwBackendPoolName
    #ip_addresses = []
  }

  backend_http_settings {
    name                  = var.gateway_config[0].gwBackendHttpPortName
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 1
  }
  backend_http_settings {
    name                  = var.gateway_config[1].gwBackendHttpPortName
    cookie_based_affinity = "Disabled"
    port                  = 8080
    protocol              = "Http"
    request_timeout       = 1
  }

  http_listener {
    name                           = var.gateway_config[0].gatewayListnerName
    frontend_ip_configuration_name = var.gateway_config[0].gwFrontendIpName
    frontend_port_name             = var.gateway_config[0].gwFrontendHttpPortName
    protocol                       = "Http"
  }
  http_listener {
    name                           = var.gateway_config[1].gatewayListnerName
    frontend_ip_configuration_name = var.gateway_config[0].gwFrontendIpName
    frontend_port_name             = var.gateway_config[1].gwFrontendHttpPortName
    protocol                       = "Http"
  }
  
  request_routing_rule {
    name                       = var.gateway_config[0].gatewayRuleName
    rule_type                  = "Basic"
    http_listener_name         = var.gateway_config[0].gatewayListnerName
    backend_address_pool_name  = var.gateway_config[0].gwBackendPoolName
    backend_http_settings_name = var.gateway_config[0].gwBackendHttpPortName
  }
  request_routing_rule {
    name                       = var.gateway_config[1].gatewayRuleName
    rule_type                  = "Basic"
    http_listener_name         = var.gateway_config[1].gatewayListnerName
    backend_address_pool_name  = var.gateway_config[1].gwBackendPoolName
    backend_http_settings_name = var.gateway_config[1].gwBackendHttpPortName
  }
  tags  =   azurerm_resource_group.example.tags
}


# resource "azurerm_application_gateway" "example" {
#   name                = "ag01"
#   resource_group_name = azurerm_resource_group.example.name
#   location            = azurerm_resource_group.example.location

#   sku {
#     name     = "Standard_Small"
#     tier     = "Standard"
#     capacity = 2
#   }
  
#   dynamic "gateway_ip_configuration" {
#     for_each = [for s in var.gateway_config: {
#         name      = s.gwPublicIpName
#         subnet_id = element(tolist(azurerm_virtual_network.example.subnet),0).id
#     }]

#     content {
#       name          = gateway_ip_configuration.value.name
#       subnet_id     = gateway_ip_configuration.value.subnet_id
#     }
#   }

#   dynamic "frontend_ip_configuration" {
#       for_each  =  [ for s in var.gateway_config: {
#         name                 = s.gwFrontendIpName
#         public_ip_address_id = azurerm_public_ip.network.id
#       }]
#       content {
#         name                 = frontend_ip_configuration.value.name
#         public_ip_address_id = frontend_ip_configuration.value.public_ip_address_id
#       }
#   }

#   dynamic "frontend_port" {
#       for_each  =  [ for s in var.gateway_config: {
#         name = s.gwFrontendHttpPortName
#         port = 80
#       }]
#       content {
#         name = frontend_port.value.name
#         port = frontend_port.value.port
#       }
#   }
  
#   dynamic "backend_address_pool" {
#       for_each  =  [ for s in var.gateway_config: {
#         name          = s.gwBackendPoolName
#         #ip_addresses = []
#       }]
#       content {
#         name          = backend_address_pool.value.name
#         #ip_addresses = backend_address_pool.value.ip_addresses
#       }
#   }

#   dynamic "backend_http_settings" {
#       for_each  =  [ for s in var.gateway_config: {
#         name                  = s.gwBackendHttpPortName
#         cookie_based_affinity = "Disabled"
#         port                  = 80
#         protocol              = "Http"
#         request_timeout       = 1
#       }]
#       content {
#         name                  = backend_http_settings.value.name
#         cookie_based_affinity = backend_http_settings.value.cookie_based_affinity
#         port                  = backend_http_settings.value.port
#         protocol              = backend_http_settings.value.protocol
#         request_timeout       = backend_http_settings.value.request_timeout
#       }
#   }

#   dynamic "http_listener" {
#       for_each  =  [ for s in var.gateway_config: {
#         name                           = s.gatewayListnerName
#         frontend_ip_configuration_name = s.gwFrontendIpName
#         frontend_port_name             = s.gwFrontendHttpPortName
#         protocol                       = "Http"
#       }]
#       content {
#         name                           = http_listener.value.name
#         frontend_ip_configuration_name = http_listener.value.frontend_ip_configuration_name
#         frontend_port_name             = http_listener.value.frontend_port_name
#         protocol                       = http_listener.value.protocol
#       }
#   }

#   dynamic "request_routing_rule" {
#       for_each  =  [ for s in var.gateway_config: {
#         name                       = s.gatewayRuleName
#         rule_type                  = "Basic"
#         http_listener_name         = s.gatewayListnerName
#         backend_address_pool_name  = s.gwBackendPoolName
#         backend_http_settings_name = s.gwBackendHttpPortName
#       }]
#       content {
#         name                       = request_routing_rule.value.name
#         rule_type                  = request_routing_rule.value.rule_type
#         http_listener_name         = request_routing_rule.value.http_listener_name
#         backend_address_pool_name  = request_routing_rule.value.backend_address_pool_name
#         backend_http_settings_name = request_routing_rule.value.backend_http_settings_name
#       }
#   }
  
#   tags  =   azurerm_resource_group.example.tags
# }

