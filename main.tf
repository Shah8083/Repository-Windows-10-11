#Define the provider
provider   "azurerm"   {
 
features   {}
 }
# Define the resource group
resource "azurerm_resource_group" "Test-RG1" {
  name     = "Test-RG1"
  location = "eastus"
}
 
# Define the virtual network
resource "azurerm_virtual_network" "MYVNET" {
  name                = "MYVNET"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.Test-RG1.location
  resource_group_name = azurerm_resource_group.Test-RG1.name
}
 
# Define the subnets
resource "azurerm_subnet" "MYwindows10" {
  name                 = "MYwindows10-subnet"
  resource_group_name  = azurerm_resource_group.Test-RG1.name
  virtual_network_name = azurerm_virtual_network.MYVNET.name
  address_prefixes     = ["10.0.1.0/24"]
}
 
resource "azurerm_subnet" "MYwindows11" {
  name                 = "MYwindows11-subnet"
  resource_group_name  = azurerm_resource_group.Test-RG1.name
  virtual_network_name = azurerm_virtual_network.MYVNET.name
  address_prefixes     = ["10.0.2.0/24"]
}
 
# Define the public IP addresses
resource "azurerm_public_ip" "MYwindows10" {
  name                = "MYwindows10-public-ip"
  location            = azurerm_resource_group.Test-RG1.location
  resource_group_name = azurerm_resource_group.Test-RG1.name
  allocation_method   = "Dynamic"
}
 
resource "azurerm_public_ip" "MYwindows11" {
  name                = "MYwindows11-public-ip"
  location            = azurerm_resource_group.Test-RG1.location
  resource_group_name = azurerm_resource_group.Test-RG1.name
  allocation_method   = "Dynamic"
}
 
# Define the network interfaces
resource "azurerm_network_interface" "MYwindows10" {
  name                = "MYwindows10-nic"
  location            = azurerm_resource_group.Test-RG1.location
  resource_group_name = azurerm_resource_group.Test-RG1.name
 
  ip_configuration {
    name                          = "mywindows10-ip-config"
    subnet_id                     = azurerm_subnet.MYwindows10.id
    public_ip_address_id          = azurerm_public_ip.MYwindows10.id
    private_ip_address_allocation = "Dynamic"
  }
}
 
resource "azurerm_network_interface" "MYwindows11" {
  name                = "MYwindows11-nic"
  location            = azurerm_resource_group.Test-RG1.location
  resource_group_name = azurerm_resource_group.Test-RG1.name
 
  ip_configuration {
    name                          = "MYwindows11-ip-config"
    subnet_id                     = azurerm_subnet.MYwindows11.id
    public_ip_address_id          = azurerm_public_ip.MYwindows11.id
    private_ip_address_allocation = "Dynamic"
  }
}
 
# Define the virtual machines
resource "azurerm_windows_virtual_machine" "MYwindows10" {
  name                  = "MYwindows10-vm"
  location              = azurerm_resource_group.Test-RG1.location
  resource_group_name   = azurerm_resource_group.Test-RG1.name
  network_interface_ids = [azurerm_network_interface.MYwindows10.id]
  size                  = "Standard_DS1_v2"
  admin_username        = "Ismile-Training"
  admin_password        = "P@ssw0rd12345!"
  os_disk {
    name              = "windows10-os-disk"
    caching           = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "MicrosoftWindowsDesktop"
    offer     = "Windows-10"
    sku       = "20h2-pro"
    version   = "latest"
  }
}
 
resource "azurerm_windows_virtual_machine" "MYwindows11" {
  name                  = "MYwindows11-vm"
  location              = azurerm_resource_group.Test-RG1.location
  resource_group_name   = azurerm_resource_group.Test-RG1.name
  network_interface_ids = [azurerm_network_interface.MYwindows11.id]
  size                  = "Standard_DS1_v2"
  admin_username        = "Dev-training"
  admin_password        = "P@ssw0rd12345!"
  os_disk {
    name              = "windows11-os-disk"
    caching           = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
      publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-azure-edition"
    version   = "latest"
  }
 
}