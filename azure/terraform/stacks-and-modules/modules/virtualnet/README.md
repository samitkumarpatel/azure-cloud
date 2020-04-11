### virtualnet

| module properties   |      Expt. Value                 |
|---------------------|:-------------:|
| -                   |  -            |


#### How to Use ?

Below is an example

```yml
module "virtualnet" {
  source                    = "../module/virtualnet"
  resource_group_name       = azurerm_resource_group.main.name
  location                  = azurerm_resource_group.main.location
  vnet_name                 = "vnet01"
  vnet_address_space        = ["10.0.0.0/16"]
  subnets                   = {
    "AzureBastionSubnet" = "10.0.0.0/24",
    "VMSubnet" = "10.0.1.0/24",
    "AppGatewaySubnet" = "10.0.2.0/24"
  }
}
```

Output

```
subnetsIds  =   []
vnetid      =   ""
```