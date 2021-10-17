#Provider Credentials
provider "azurerm" {
  features {}
}
#Resource group
resource "azurerm_resource_group" "rg" {
  name     = var.ResourceGroup_name
  location = "West Europe"
}



#Virtual Network
resource "azurerm_virtual_network" "vn" {
  name                = var.VirtualNetwork_name
  address_space       = ["10.0.0.0/16"]
  location            = var.ResourceGroup_location
  resource_group_name = var.ResourceGroup_name
}

#Sub net VM
resource "azurerm_subnet" "subnetVM" {
  name                 = var.SubNet_VM
  resource_group_name  = var.ResourceGroup_name
  virtual_network_name = azurerm_virtual_network.vn.name
  address_prefixes     = ["10.0.0.0/22"]
}

#Sub net SQL
resource "azurerm_subnet" "subnetSQL" {
  name                 = var.SubNet_SQL
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vn.name
  address_prefixes     = ["10.0.4.0/22"]

}

#Public ip
resource "azurerm_public_ip" "public_ip" {
  name                = "Public_IP"
  resource_group_name = var.ResourceGroup_name
  location            = var.ResourceGroup_location
  allocation_method   = "Static"

  tags = {
    environment = "Production"
  }
}



#                     VM's

resource "azurerm_linux_virtual_machine" "App1VM" {
  count                           = length(var.name_count)
  name                            = "App1VM-${count.index+1}"
  resource_group_name             = var.ResourceGroup_name
  location                        = var.ResourceGroup_location
  size                            = "Standard_F2"
  admin_username                  = "vova"
  admin_password                  = "Vladimir1234"
  disable_password_authentication = false
  depends_on = [
    azurerm_network_interface.NIC_VM
  ]
  network_interface_ids = [element(azurerm_network_interface.NIC_VM.*.id, count.index)]


  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}

resource "azurerm_linux_virtual_machine" "sqlvm" {
  name                            = "sqlvm"
  resource_group_name             = var.ResourceGroup_name
  location                        = var.ResourceGroup_location
  size                            = "Standard_F2"
  admin_username                  = "****"
  admin_password                  = "****"
  disable_password_authentication = false
  depends_on = [
    azurerm_network_interface.NIC_SQL
  ]
  network_interface_ids = [
    azurerm_network_interface.NIC_SQL.id
  ]


  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}

#NICVM! Network interface for WEBVM
resource "azurerm_network_interface" "NIC_VM" {
  count               = length(var.name_count)
  name                = "NIC_VM-${count.index+1}"
  location            = var.ResourceGroup_location
  resource_group_name = var.ResourceGroup_name
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnetVM.id
    private_ip_address_allocation = "Dynamic"
#    public_ip_address_id          = azurerm_public_ip.public_ip.id
  }
}

resource "azurerm_network_interface" "NIC_SQL" {
  name                = "NIC_SQL"
  location            = var.ResourceGroup_location
  resource_group_name = var.ResourceGroup_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnetSQL.id
    private_ip_address_allocation = "Dynamic"
  }
}


resource "azurerm_subnet_network_security_group_association" "subnetVM_assoc" {
  subnet_id                 = azurerm_subnet.subnetVM.id
  network_security_group_id = azurerm_network_security_group.NSG_VM.id
}


resource "azurerm_subnet_network_security_group_association" "subnetSQL_assoc" {
  subnet_id                 = azurerm_subnet.subnetSQL.id
  network_security_group_id = azurerm_network_security_group.NSG_SQL.id
}

resource "azurerm_network_interface_security_group_association" "NIC_to_NSG2" {
  network_interface_id      = azurerm_network_interface.NIC_SQL.id
  network_security_group_id = azurerm_network_security_group.NSG_SQL.id
}

