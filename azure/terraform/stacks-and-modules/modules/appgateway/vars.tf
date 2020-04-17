variable "name" {
  default   = "ag01"
}

variable "location" { 

}

variable "resource_group_name" { 

}

variable "gateway_config" {
  type      =   list
  default   = [
    {
      gwFrontendHttpPortName    = "NginxFe80"
      gwBackendPoolName         = "NginxBePool"
      gwBackendPoolIps          = []
      gwBackendHttpPortName     = "NginxBeHttp80"
      port                      = 80
      gatewayListnerName        = "NginxListner"
      gatewayRuleName           = "NginxRule"
      probe                     = { name: "nginx",path:"/" }
      cookie                    =  "Disabled"
    }
  ]
}

variable "gateway_public_ip_name" {
  default  = "gw_pub_ip"
}

variable "gateway_fe_ip_name" {
  default  = "gw_fe_ip"
}

variable "tags" {
  default  = {}
}

variable "subnet_id" {
  
}
