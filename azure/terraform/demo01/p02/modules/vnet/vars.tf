variable "rg" {
    type = string
}

variable "location" {
    type = string
}

variable "name" {
    default = "vnet"
}

variable "vnet_address_space" {
  type = list
  default = ["10.0.0.0/16"]
}

variable "subnets_list" {
  type  = list
  default = [
    {
      name  = "AzureBastionSubnet",
      address = "10.0.1.0/24"
    },
    {
      name  = "snet01",
      address = "10.0.2.0/24"
    },
    {
      name  = "snet02",
      address = "10.0.3.0/24"
    }
  ]
}

variable "tags" {
  type = map
}