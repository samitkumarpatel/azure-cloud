variable "resource_group_name" { 
    type = string
}
variable "location" {
    type = string
}

variable "vnet_name" {
    type = string
    default = "vnet01"
}

variable "vnet_address_space" {
    type = list
    default = ["10.0.0.0/16"]
}

variable "subnets" {
    type = map
  
}

variable "tags" {
  default  = {}
}
