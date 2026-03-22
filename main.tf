#provider block
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.58.0"
    }
  }
}
  #resources block
provider "azurerm" {
  features {}
  subscription_id = "eb5151a5-d2cf-4671-87ba-6e301316f94f"
  tenant_id       = "24971b8e-00be-4985-8132-9b0fa633f6b8"
  client_id       = "08829ce0-f35b-465d-88d3-c2cbda485d57"
  client_secret   = "811d2621-2232-48fd-b1f3-e840802fe9d3"
}
resource "azurerm_resource_group" "rg"{
  name = var.resource_rg
  location = var.location
}
resource  "azurerm_virtual_network" "vn-1" {
  name = var.vartual_vn
  address_space = var.ipaddress
  resource_group_name = azurerm_resource_group.rg.name
  location =  azurerm_resource_group.rg.location 
}
resource "azurerm_subnet" "subnet"{
  name = var.subnet
  address_prefixes = var.ip_name
  resource_group_name = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vn-1.name
}
 resource "azurerm_public_ip" "pip_id" {
  name                = var.public_ip
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  allocation_method   = "Static"
  sku                 = "Standard"

  tags = {
    environment = "Production"
  }
}

resource "azurerm_application_gateway" "apl_gat" {
  name                = var.application_gateway 
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  sku {
    name     = "Standard_v2"
    tier     = "Standard_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "appgw-ip-config"
    subnet_id = azurerm_subnet.subnet.id
  }

  frontend_port {
    name = "frontend-port"
    port = 80
  }

  frontend_ip_configuration {
  name                 = "frontend-ip"
  public_ip_address_id = azurerm_public_ip.pip_id.id
}

  backend_address_pool {
    name = "backend-pool"
  }

  backend_http_settings {
    name                  = "http-settings"
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
  }

  http_listener {
    name                           = "http-listener"
    frontend_ip_configuration_name  = "frontend-ip"
    frontend_port_name              = "frontend-port"
    protocol                        = "Http"
  }

  request_routing_rule {
    name                       = "rule1"
    rule_type                  = "Basic"
    http_listener_name         = "http-listener"
    backend_address_pool_name  = "backend-pool"
    backend_http_settings_name = "http-settings"
    priority                   = 100
  }
}
