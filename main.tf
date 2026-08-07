terraform {
  required_version = ">= 1.6.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>4.0"
    }
  }

backend "azurerm" {
    resource_group_name  = "rg-terraformstate"
    storage_account_name = "sacctterraformstate"
    container_name       = "contfstate"
    key                  = "AzureInfra.contfstate"
  }

  }


provider "azurerm" {
  features {}
}

###########################
# Variables
###########################

variable "admin_password" {
  description = "Windows VM Administrator Password"
  sensitive   = true
}

###########################
# Resource Group
###########################

resource "azurerm_resource_group" "rg" {
  name     = "rg-DevWorkloads"
  location = "East US"
}

##############################
# Virtual Network
##############################

resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-demo"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  address_space = [
    "10.0.0.0/16"
  ]
}

##############################
# Subnet
##############################

resource "azurerm_subnet" "subnet" {
  name                 = "subnet-demo"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name

  address_prefixes = [
    "10.0.1.0/24"
  ]
}


##############################
# Public IP
##############################

resource "azurerm_public_ip" "pip" {
  name                = "vm-public-ip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  allocation_method = "Static"
  sku               = "Standard"
}

##############################
# Network Interface
##############################

resource "azurerm_network_interface" "nic" {
  name                = "vm-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip.id
  }
}

##############################
# Windows Virtual Machine
##############################

resource "azurerm_windows_virtual_machine" "vm" {
  name                = "windowsvm01"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  size = "Standard_D2s_v3"

  admin_username = "azureadmin"
  admin_password = var.admin_password

  network_interface_ids = [
    azurerm_network_interface.nic.id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-azure-edition"
    version   = "latest"
  }
}

##############################
# Outputs
##############################

output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}

output "vm_name" {
  value = azurerm_windows_virtual_machine.vm.name
}

output "public_ip" {
  value = azurerm_public_ip.pip.ip_address
}

