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

variable "subnetid" {

}

variable "vmips" {
  default = []
}

variable "tags" {
  type = map
}
