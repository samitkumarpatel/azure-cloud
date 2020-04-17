# some point of time storage and subnet deligate will go to a different module
# storage
resource "azurerm_storage_account" "test" {
    name                     = "generalstg0001"
    location                 = var.location
    resource_group_name      = var.resource_group_name
    account_tier             = "Standard"
    account_replication_type = "LRS"
    tags    =   var.tags
}
resource "azurerm_storage_share" "test" {
    count                = 2
    name                 = "storage${count.index}"
    storage_account_name = azurerm_storage_account.test.name
    quota                = 50
}



# aci-vnet
resource "azurerm_subnet" "test" {
    name                 = "ContainerInstance"
    resource_group_name      = var.resource_group_name
    virtual_network_name = var.vnet_name
    address_prefix       = "10.0.3.0/28"
    delegation {
        name = "delegation"
        service_delegation {
        name    = "Microsoft.ContainerInstance/containerGroups"
        actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
        }
    }
}
resource "azurerm_network_profile" "test" {
    name                = "vnet01profile"
    location                 = var.location
    resource_group_name      = var.resource_group_name
    container_network_interface {
        name = "testcnic"
        ip_configuration {
        name      = "testipconfig"
        subnet_id = azurerm_subnet.test.id
        }
    }
}


# aci
resource "azurerm_container_group" "test" {
    #count               = 1
    name                = "contineous-integration"
    location            = var.location
    resource_group_name = var.resource_group_name
    ip_address_type     = "private"
    network_profile_id  = azurerm_network_profile.test.id
    os_type             = "Linux"
    
    image_registry_credential {
        server   = "docker.pkg.github.com"
        username = "XXXXXX"
        password = "XXXXXX"
    }
    container {
        name   = "jenkins-jcac"
        image  = "docker.pkg.github.com/samitkumarpatel/devops-tooling/jenkins-jcac:latest"
        cpu    = "2"
        memory = "4"
        ports {
            port     = 80
            protocol = "TCP"
        }
        volume {
            name          = "jcac"
            mount_path    = "/usr/share/nginx/html/alt"
            storage_account_name = azurerm_storage_account.test.name
            storage_account_key = azurerm_storage_account.test.primary_access_key
            share_name = azurerm_storage_share.test[0].name
        }
    }
    container {
        name   = "jenkins"
        image  = "docker.pkg.github.com/samitkumarpatel/devops-tooling/jenkins:latest"
        cpu    = "2"
        memory = "4"
        ports {
            port     = 8080
            protocol = "TCP"
        }
        ports {
            port     = 50000
            protocol = "TCP"
        }
        volume {
            name          = "jenkinshome"
            mount_path    = "/var/jenkins_home"
            storage_account_name = azurerm_storage_account.test.name
            storage_account_key = azurerm_storage_account.test.primary_access_key
            share_name = azurerm_storage_share.test[1].name
        }
        environment_variables = {"CASC_JENKINS_CONFIG" : "http://10.0.3.4/default/jenkins.yml"}
            
    }
    
    depends_on = [
        azurerm_storage_account.test,
        azurerm_storage_share.test
    ]

    tags    =   var.tags
    }