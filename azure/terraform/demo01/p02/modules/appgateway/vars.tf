variable "rg" {
    type = string
}

variable "location" {
    type = string
}

variable "name" {
  type    = string
  default = "ag01"
}

variable "gateway_config" {
  type = list
  value = [
    {
      gwPublicIp            = "nginxPublicIp"
      gwFrontendHttpPort    = "nginxFEPort80"
      gwFrontendIp          = "nginxFEIpip"
      gwBackendPool         = "nginxBEPool"
      gwBackendHttpPort     = "nginxBEhttpPort80"
      gatewayListner        = "nginxListner"
      gatewayRule           = "nginxRule"
    }
  ]
}


variable "subnetid" {

}

variable "vmips" {
  default = []
}

variable "tags" {
  type = map
}
