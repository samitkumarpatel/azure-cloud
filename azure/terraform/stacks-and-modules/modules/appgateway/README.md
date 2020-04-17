### Application gateway

| module properties   | Expt. Value   |
|---------------------|:-------------:|
| -                   |  -            |


#### How to Use ?

Below is an example

```yml
module "appgateway" {
  source                        =   "../modules/appgateway"
  resource_group_name           =   azurerm_resource_group.main.name
  location                      =   azurerm_resource_group.main.location
  subnet_id                     =   element(module.virtualnet.subnetsIds,2).id
  gateway_config                =   [
    {
      gwFrontendHttpPortName    = "NginxFe80"
      gwBackendPoolName         = "NginxBePool"
      gwBackendPoolIps          = module.vm01.vmips
      gwBackendHttpPortName     = "NginxBeHttp80"
      port                      = 80
      gatewayListnerName        = "NginxListner"
      gatewayRuleName           = "NginxRule"
      probe                     = { name: "nginx",path:"/" }
      cookie                    =  "Disabled"
    },
    {
      gwFrontendHttpPortName    = "JenkinsFe8080"
      gwBackendPoolName         = "JenkinsBePool"
      gwBackendPoolIps          = module.vm02.vmips
      gwBackendHttpPortName     = "JenkinsBeHttp8080"
      port                      = 8080
      gatewayListnerName        = "JenkinsListner"
      gatewayRuleName           = "JenkinsRule"
      probe                     = { name: "nginx", url:"/"}
      cookie                    =  "Disabled"
    }
  ]
  tags      =   azurerm_resource_group.main.tags
}
```

```
application_gateway_public_ip       =   ""
```