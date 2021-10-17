

resource "azurerm_network_security_group" "NSG_VM" {
  name                = var.NetworkSecurityGroup_VM
  location            = var.ResourceGroup_location
  resource_group_name = var.ResourceGroup_name
  security_rule {
    name                       = "port_8080"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}



resource "azurerm_network_security_group" "NSG_SQL" {
  name                = var.NetworkSecurityGroup_SQL
  location            = var.ResourceGroup_location
  resource_group_name = azurerm_resource_group.rg.name
  security_rule {
    name                       = "port_22"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}