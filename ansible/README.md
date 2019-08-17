# azure automation with ansible
* setup guide:  (https://docs.ansible.com/ansible/latest/scenario_guides/guide_azure.html)
* ansible azure module: (https://docs.ansible.com/ansible/latest/modules/list_of_all_modules.html)

## initial setup for ansible to achieve automation on azure
### Create service principle
* open https://portal.azure.com
* click on `Azure Active Directory` --> `App Registration`
* click `+ New registration`
* fill Name, support Account Type, Redirect URI(optional).
* click on Register. 
* Go to Subscription
* Click on the active subscription - if you have multi subscription.
* `Access Control (IAM)` --> `+Add` --> `Add role assignment`
* fill `select a role` from the list choose `contributor`
* keep `assign access to ` - from the list choose - `Azure DA User, group or service principle`
* search for the name , which you created as part of `Azure Active Directory` --> `App Registration` flow
* once all done from the `Azure Active Directory` --> `App Registration` flow , you can get Client Id, tenent Id, client Secreat can also be generate by clicking `Certificates & Secrets` menu on the side menu bar
* create an credential file on `~/.azure/credentials` location. 
* example of `~/.azure/credentials` file
```
[default]
subscription_id=
client_id=XXXXXXXX
secret=XXXXXX
tenant=XXXXXX
```

### working with `azure_rm_deployment`
* Create some resources by using https://portal.azure.com
* Than navigate https://resources.azure.com --> expand resourceGroup
* convert JSON to YML and put that under `template` 
```
azure_rm_deployment:
    state: "{{state}}"
    resource_group_name: "lab001"
    template:
        $schema: "https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#"
        -
        -
```
* like wise you can create a custom template and make a use in your automation.