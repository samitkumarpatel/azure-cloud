### Application Gateway
- This module will create a application gateway along with a public ip with just exposed 80 port

- Example

```hcl
module "appgateway" {
  source                    = "../modules/appgateway"
  rg                        = "MyResourceGroupOne"
  location                  = "West Europe"
  subnetid                  = element(module.modulename.subnets,subnetIndex).id
  vmips                     = module.vmModuleName.vmips
  
  tags = {
      environment = "demo",
      delete      = "always"
  }
}
```