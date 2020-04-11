variable "name" {
  default   = "ag01"
}

variable "location" { 

}

variable "resource_group" { 

}

variable "gateway_config" {
  type      =   list
  default   =   [
    { 
      gwFrontendHttpPortName    = "nginx_fe_80"
      gwBackendPoolName         = "nginx_be_pool"
      gwBackendPoolIps          = ["10.0.0.1","10.0.0.1"]
      gwBackendHttpPortName     = "nginx_be_http_80"
      port                      = 80
      gatewayListnerName        = "nginx_listner"
      gatewayRuleName           = "nginx_rule"
    },
    {
      gwFrontendHttpPortName    = "jenkins_fe_8080"
      gwBackendPoolName         = "jenkins_be_pool"
      gwBackendPoolIps          = ["10.0.0.3","10.0.0.4"]
      gwBackendHttpPortName     = "jenkins_be_http_8080"
      port                      = 8080
      gatewayListnerName        = "jenkins_listner"
      gatewayRuleName           = "jenkins_rule"
    }
  ]
}

variable "gateway_public_ip_name" {
  default   = "gw_pub_ip"
}

variable "gateway_fe_ip_name" {
  default   = "gw_fe_ip"
}
