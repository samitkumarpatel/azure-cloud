### Bastion

- How to use example

```hcl
module "bastion" {
  source                    = "../modules/bastion"
  rg                        = "MyResourceGroupOne"
  location                  = "West Europe"
  name                      = "bastion01"
  subnetid                  = element(module.moduleName.outputVariableName,index).id
  
  tags = {
      environment = "demo",
      delete      = "always"
  }
}
```