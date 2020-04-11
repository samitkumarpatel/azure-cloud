### Virtual Machine

- Virtual Machine consist of `network interface` and `linux based virtual machine`

- Example 01 - To create 2 vm

```hcl
module "vm" {
  source                    = "../modules/vm"
  rg                        = "MyResourceGroupOne"
  location                  = "West Europe"
  instance_count            = 2
  subnetid                  = element(module.modulename.subnets,subnetIndex).id
  
  tags = {
      environment = "demo",
      delete      = "always"
  }
}
```

- Example 02 - Just one VM

```hcl
module "vm" {
  source                    = "../modules/vm"
  rg                        = "MyResourceGroupOne"
  location                  = "West Europe"
  subnetid                  = element(module.modulename.subnets,subnetIndex).id
  
  tags = {
      environment = "demo",
      delete      = "always"
  }
}
```