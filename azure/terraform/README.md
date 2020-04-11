### Terraform

**Installation**

Please follow official documents.

**Useful links**

[Official Learning page from Terraform](https://learn.hashicorp.com/terraform/getting-started)

[Terraform 0.12 changes](https://www.terraform.io/docs/configuration/)

---
**Tutorial**

Terraform only recognise a file with extensation `.tf` `.tfvars`

as a initial start I have below structure 

```
.
├── main.tf
```

content of `main.tf` file 

```
provider "azurerm" {
  version = "=1.34.0"

  subscription_id =  "xxxxxx-xxxxx-xxxxx-xxxxxx"
  client_id       =  "xxxxxx-xxxxx-xxxxx-xxxxxx"
  client_secret   =  "xxxxxx-xxxxx-xxxxx-xxxxxx"
  tenant_id       =  "xxxxxx-xxxxx-xxxxx-xxxxxx"
}

variable "location" {
  default = "West Europe"
}

resource "azurerm_resource_group" "test" {
  name     = "tutorial-rg01"
  location = var.location
  tags = {
    environment = "test",
  }
}

```
The above will just create a resource group for us in west Europe zone.

Command to make that happen are:
```
terraform init
terraform plan
terraform apply
```
after running above , the folder structure will look like 
```
.
├── main.tf
├── terraform.tfstate
└── terraform.tfstate.backup
```
`.tfstate` and `.tfstate.backup` are terraform state file. Terraform state file are more crusial to terrform - will learn more around that

To override the variable define on `main.ts` we can use
```
terraform plan -var "location=West US"
terraform apply -var "location=West US"
```

>Storing provider related credential in source controll is not at all an option, make sure you are not storing that in version contol. There are several option you can follow for that:

*Option-1*

Create an env file and keep the details there. The below env variable are specific to azure provider and it will not workfor other module. other module related env variable name can be found in the official docs.

```
export ARM_SUBSCRIPTION_ID="xxxxx-xxxxx-xxxxx-xxxxx"
export ARM_CLIENT_ID="xxxxx-xxxxx-xxxxx-xxxxx"
export ARM_CLIENT_SECRET="xxxxx-xxxxx-xxxxx-xxxxx"
export ARM_TENANT_ID="xxxxx-xxxxx-xxxxx-xxxxx"
```

* Random logic
In many case of terraform resource , its necessary to generate random number and sequence .. to make that happen follow [Official Documentation](https://www.terraform.io/docs/providers/random/r/string.html)

* Env variable

Terraform will read environment variables in the form of TF_VAR_name to find the value for a variable. For example, the TF_VAR_region variable can be set to set the region variable.


* List Variable
```
# implicitly by using brackets [...]
variable "cidrs" { default = [] }

# explicitly
variable "cidrs" { type = list }
```

In `terraform.tfvars ` , the list value can be `cidrs = [ "10.0.0.0/16", "10.1.0.0/16" ]`

* Maps
```
variable "amis" {
  type = "map"
  default = {
    "us-east-1" = "ami-b374d5a5"
    "us-west-2" = "ami-4b32be2b"
  }
}
```
The map can be used like `var.amis[var.region]`
command line `terraform apply -var 'amis={ us-east-1 = "foo", us-west-2 = "bar" }'`


**Interpolation**

[click](https://www.terraform.io/docs/configuration-0-11/interpolation.html) for official documentation

* count example
```
resource "azurerm_virtual_network" "main" {
  count = length(var.vnet_ips)
  name                = "vnet0${count.index}"
  address_space       = [var.vnet_ips[count.index]]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}
```

**Terraform Function**

[click](https://www.terraform.io/docs/configuration/functions.html) for official docs

- element
- tolist
- lookup
