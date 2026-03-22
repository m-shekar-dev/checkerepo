provider "azurerm" {
features{}  
}
resource "azurerm_resource_group" "example" {
  name     = "rg6378"
  location = "westus"
}
