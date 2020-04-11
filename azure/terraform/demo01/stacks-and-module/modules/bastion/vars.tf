variable "rg" {
    type = string
}

variable "location" {
    type = string
}

variable "name" {
  type = string
  default = "bastion"
}

variable "subnetid" {
}

variable "tags" {
  type = map
}


