### Bastion

| module properties   |      Expt. Value                 |
|---------------------|:-------------:|
| -                   |  -            |


#### How to Use ?

Below is an example

```yml
module "bastion" {
  source                =   "../module/bastion"
  resource_group_name   =   azurerm_resource_group.main.name
  location              =   azurerm_resource_group.main.location
  #name                 =   "bastion01"
  #public_ip_name       =   "bastionpip01" 
  subnet_id             =   element(module.virtualnet.subnetsIds,0).id
  tags                  =   azurerm_resource_group.main.tags
}
```

Output

```
- 
```