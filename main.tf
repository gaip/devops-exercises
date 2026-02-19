terraform {            
  required_providers {  
    azurerm = {        
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {   
  features {}
  subscription_id = "52b0d7b2-83b1-4835-b34c-abb5f610eaed"
}

# Resource Group
resource "azurerm_resource_group" "app_grp" {
  name     = "app-grp"
  location = "East US"  # Keep East US - matches existing resources
}

# Storage Account
resource "azurerm_storage_account" "storage" {
  name                     = "appgrpstorage2026"  # Must be globally unique
  resource_group_name      = azurerm_resource_group.app_grp.name
  location                 = azurerm_resource_group.app_grp.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# azure virtual network
resource "azurerm_virtual_network" "vnet" {
  name                = "app-grp-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.app_grp.location
  resource_group_name = azurerm_resource_group.app_grp.name
}

# azure virtual network subnet
resource "azurerm_subnet" "subnet" {
  name                 = "app-grp-subnet"
  resource_group_name  = azurerm_resource_group.app_grp.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# azure  public ip
resource "azurerm_public_ip" "public_ip" {
  name                = "app-grp-public-ip"
  location            = azurerm_resource_group.app_grp.location
  resource_group_name = azurerm_resource_group.app_grp.name 
   allocation_method   = "Static"
}

# azure network interface
resource "azurerm_network_interface" "nic" {
  name                = "app-grp-nic"
  location            = azurerm_resource_group.app_grp.location   
  resource_group_name = azurerm_resource_group.app_grp.name
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip.id
  }
}

# Get current Azure client info
data "azurerm_client_config" "current" {}

# Key Vault
resource "azurerm_key_vault" "vault" {
  name                = "appgrpvault2026"  # Must be globally unique
  location            = azurerm_resource_group.app_grp.location
  resource_group_name = azurerm_resource_group.app_grp.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"

  access_policy {
    tenant_id = data.azurerm_client_config.current.tenant_id
    object_id = data.azurerm_client_config.current.object_id

    secret_permissions = ["Get", "List", "Set", "Delete", "Purge"]
  }
}

# Store VM password in vault
resource "azurerm_key_vault_secret" "vm_password" {
  name         = "vm-admin-password"
  value        = "P@ssw0rd1234!"  # Set once, then remove from code
  key_vault_id = azurerm_key_vault.vault.id
}

# Linux Virtual Machine
resource "azurerm_linux_virtual_machine" "vm" {
  name                            = "app-grp-vm"
  location                        = azurerm_resource_group.app_grp.location
  resource_group_name             = azurerm_resource_group.app_grp.name
  size                            = "Standard_D2s_v3"  # Better availability than B-series
  network_interface_ids           = [azurerm_network_interface.nic.id]

  disable_password_authentication = false
  admin_username                  = "azureuser"
  admin_password                  = azurerm_key_vault_secret.vm_password.value

  admin_ssh_key {
    username   = "azureuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}