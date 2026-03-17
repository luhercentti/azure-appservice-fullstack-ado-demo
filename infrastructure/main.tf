terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }
  
  backend "azurerm" {
    # Backend configuration is provided via pipeline parameters
  }
}

provider "azurerm" {
  features {}
}

# Application resources
resource "azurerm_resource_group" "main" {
  name     = "rg-simpleapp-${var.environment}"
  location = var.location
}

resource "azurerm_service_plan" "main" {
  name                = "sp-simpleapp-${var.environment}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  os_type             = "Linux"
  sku_name            = "F1"
}

resource "azurerm_linux_web_app" "api" {
  name                = "app-simpleapp-api-${var.environment}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_service_plan.main.location
  service_plan_id     = azurerm_service_plan.main.id

  site_config {
    application_stack {
      dotnet_version = "8.0"
    }
  }
}

resource "azurerm_static_web_app" "frontend" {
  name                = "stapp-simpleapp-${var.environment}"
  resource_group_name = azurerm_resource_group.main.name
  location            = "East US2"
}

