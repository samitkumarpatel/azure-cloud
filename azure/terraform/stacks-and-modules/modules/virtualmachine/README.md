### Virtual Machine

| module properties   |      Expt. Value                 |
|---------------------|:-------------:|
| -                   |  -            |


#### How to Use ?

Below is an example

```yml
module "vm" {
  source                =   "../modules/virtualmachine"
  resource_group_name   =   azurerm_resource_group.main.name
  location              =   azurerm_resource_group.main.location
  instance_count        =   2
  #name                 =   "dev"
  subnet_id             =   element(module.virtualnet.subnetsIds,1).id
  tags                  =   azurerm_resource_group.main.tags
}
```

```
vmips_with_name     =       []
vmips               =       []
```