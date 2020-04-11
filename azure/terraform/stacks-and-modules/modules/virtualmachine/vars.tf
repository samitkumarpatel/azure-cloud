variable "instance_count" {
  default   = 1
}
variable "location" { 

}

variable "resource_group_name" { 

}

variable "subnet_id" { 
    
}

variable "name" {
  default  =  "0" 
}

variable "vm_username" {
  default   =   "adminuser"
}

variable "vm_password" {
  default   =   "Password123!"
}

variable "tags" {
  default  = {}
}
