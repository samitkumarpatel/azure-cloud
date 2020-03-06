### vnet module

- This module will create a vnet with number of subnet you want. Subnet details can be pass as parameter.

- If you want a startnard way of just creating vnet , Please follow `example 02` which will by default take care of cidr block and will create three subnet for vm, bastion and application gateway.

- This module output a list of `subnets` Object. 

- `example 01`
```hcl
module "vnet" {
  source                    = "../modules/vnet"
  rg                        = "MyResourceGroupOne"
  location                  = "West Europe"
  name                      = "vnet01"
  vnet_address_space        = ["10.0.0.0/16"]
  subnets_list              = [
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
  tags = {
      environment = "demo",
      delete      = "always"
  }
}

```

- `example 02`
```hcl
module "vnet" {
  source                    = "../modules/vnet"
  rg                        = "MyResourceGroupOne"
  location                  = "West Europe"
  name                      = "vnet01"
  tags = {
      environment = "demo",
      delete      = "always"
  }
}
```
