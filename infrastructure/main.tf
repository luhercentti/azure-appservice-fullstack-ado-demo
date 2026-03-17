terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Terraform state storage resources
resource "azurerm_resource_group" "terraform_state" {
  name     = "rg-terraform-state"
  location = var.location
}

resource "azurerm_storage_account" "terraform_state" {
  name                     = "stterraformstate${var.environment}"
  resource_group_name      = azurerm_resource_group.terraform_state.name
  location                 = azurerm_resource_group.terraform_state.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "terraform_state" {
  name                  = "tfstate"
  storage_account_id    = azurerm_storage_account.terraform_state.id
  container_access_type = "private"
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
  sku_name            = "B1"
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

