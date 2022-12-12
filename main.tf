
# create resource group
resource "azurerm_resource_group" "example" {
  name     = "ter_rg_ays"
  location = var.resource_group_location
}

# create virtual network
resource "azurerm_virtual_network" "example" {
  name                = "ays_vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

# create subnet
resource "azurerm_subnet" "example" {
  name                 = "ays_internal"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.2.0/24"]
}

# create network interface
resource "azurerm_network_interface" "example" {
  name                = "ays_vm-nic"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

# create ip configuration
  ip_configuration {
    name                          = "ays_internal"
    subnet_id                     = azurerm_subnet.example.id
    private_ip_address_allocation = "Dynamic"
  }
}

# create storage account
resource "azurerm_storage_account" "example" {
  name                     = "aysstorage121222"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "GRS"

  tags = {
    environment = "production"
  }
}

# create virtual machine
resource "azurerm_windows_virtual_machine" "ays-vm1" {
  name                = "ays-vm"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  size                = "Standard_F2"
  admin_username      = "adminuser"
  admin_password      = "P@$$w0rd1234!"
  network_interface_ids = [
    azurerm_network_interface.example.id,
  ]

  tags = {
    environment = "production"
  }

# create os_disk
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

# configuration of os_disk
  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}
