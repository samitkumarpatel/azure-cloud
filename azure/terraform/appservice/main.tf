provider "azurerm" {
  version = "=2.0.0"
  features {}
}

resource "azurerm_resource_group" "test" {
  name     = "tutorial01"
  location = "westeurope"
}

resource "azurerm_storage_account" "test" {
  name                     = "tutorial01poc01"
  resource_group_name      = azurerm_resource_group.test.name
  location                 = azurerm_resource_group.test.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "test" {
  name                  = "vhds"
  storage_account_name  = azurerm_storage_account.test.name
  container_access_type = "private"
}

resource "azurerm_app_service_plan" "test" {
  name                = "asp01"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  kind                = "Linux"
  reserved            = true

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_app_service" "test" {
  name                = "service0001"
  location            = azurerm_resource_group.test.location
  resource_group_name = azurerm_resource_group.test.name
  app_service_plan_id = azurerm_app_service_plan.test.id
  
  storage_account {
      name          = "volume01"
      type          = "AzureFiles"
      share_name    = azurerm_storage_container.test.name
      account_name  = azurerm_storage_account.test.name
      access_key    = azurerm_storage_account.test.primary_access_key
      mount_path    = "/apphome"
  }
  site_config {
    app_command_line = ""
    linux_fx_version = "COMPOSE|${filebase64("docker-compose.yml")}"
  }

  app_settings = {
    "WEBSITES_ENABLE_APP_SERVICE_STORAGE" = "true"
  }
}