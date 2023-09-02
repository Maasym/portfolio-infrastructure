resource "azurerm_resource_group" "infra" {
  location = "West Europe"
  name     = "infra"
}

resource "azurerm_virtual_network" "infra-vnet" {
  address_space       = ["10.10.0.0/16"]
  location            = "West Europe"
  name                = "infra-vnet"
  resource_group_name = azurerm_resource_group.infra.name
}

resource "azurerm_subnet" "aks-subnet" {
  address_prefixes     = ["10.10.2.0/24"]
  name                 = "aks-subnet"
  resource_group_name  = azurerm_resource_group.infra.name
  virtual_network_name = azurerm_virtual_network.infra-vnet.name

  depends_on = [
  azurerm_virtual_network.infra-vnet
  ]
}