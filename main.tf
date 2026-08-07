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
# Network Security Group
##############################

resource "azurerm_network_security_group" "nsg" {
  name                = "nsg-windowsvm"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name      = "Allow-RDP"
    priority  = 1000
    direction = "Inbound"
    access    = "Allow"
    protocol  = "Tcp"

    source_port_range      = "*"
    destination_port_range = "3389"

    source_address_prefix      = "197.211.59.79"
    destination_address_prefix = "*"
  }
}

##############################
# Associate NSG with Subnet
##############################

resource "azurerm_subnet_network_security_group_association" "nsg_association" {
  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

##############################
# Network Interface
##############################

resource "azurerm_network_interface" "nic" {
  name                = "vm-nic"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

depends_on = [
    azurerm_subnet_network_security_group_association.nsg_association

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
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
# Azure Bastion Subnet
##############################

resource "azurerm_subnet" "bastion" {

    name = "AzureBastionSubnet"

    resource_group_name = azurerm_resource_group.rg.name

    virtual_network_name = azurerm_virtual_network.vnet.name

    address_prefixes = [
        "10.0.2.0/26"
    ]
}

##############################
# Public IP for Azure Bastion 
##############################

resource "azurerm_public_ip" "bastion_pip" {

    name = "bastion-pip"

    location = azurerm_resource_group.rg.location

    resource_group_name = azurerm_resource_group.rg.name

    allocation_method = "Static"

    sku = "Standard"
}

##############################
# Azure Bastion
##############################

resource "azurerm_bastion_host" "bastion" {

    name = "bastion-host"

    location = azurerm_resource_group.rg.location

    resource_group_name = azurerm_resource_group.rg.name

    sku = "Basic"

    ip_configuration {

        name = "configuration"

        subnet_id = azurerm_subnet.bastion.id

        public_ip_address_id = azurerm_public_ip.bastion_pip.id

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

output "bastion_public_ip" {
  value = azurerm_public_ip.bastion_pip.ip_address
}

