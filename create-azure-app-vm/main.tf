provider "azurerm" {
  resource_provider_registrations = "none"
  features {}
  subscription_id = var.subscription_id
}

# Referencing my SSH public key, already added in Azure
data "azurerm_ssh_public_key" "tech501-farah-az-key" {
  name                = var.azurerm_ssh_public_key
  resource_group_name = var.resource_group_name
}
#Referencing my already existing public subnet
data "azurerm_subnet" "public_subnet" {
  name                 = "public-subnet"
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.vnet_name
}

#Referencing my app image
data "azurerm_image" "tech501_farah_image" {
  name                = var.azurerm_image
  resource_group_name = var.resource_group_name
}

resource "azurerm_public_ip" "tech501-farah-tf-app-vm-public-ip" {
  name                = var.public_ip_name
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  domain_name_label   = var.public_ip_name
}

resource "azurerm_network_interface" "tech501-farah-tf-app-vm-NIC" {
  name                = "tech501-farah-tf-app-vm-NIC"
  location            = var.location
  resource_group_name = var.resource_group_name

  # Public IP provided below
  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.azurerm_subnet.public_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.tech501-farah-tf-app-vm-public-ip.id
  }
}

# Settings for the machine itself
resource "azurerm_virtual_machine" "tech501-farah-tf-app-vm" {
  name                             = var.app_VM_name
  location                         = var.location
  resource_group_name              = var.resource_group_name
  network_interface_ids            = [azurerm_network_interface.tech501-farah-tf-app-vm-NIC.id]
  vm_size                          = "Standard_B1s"
  delete_data_disks_on_termination = true
  delete_os_disk_on_termination    = true
  storage_os_disk {
    name          = "farah-app-tf-os-disk"
    caching       = "ReadWrite"
    create_option = "FromImage"
    disk_size_gb  = 30
  }

  os_profile {
    computer_name  = var.app_VM_name
    admin_username = var.admin_username
    custom_data    = <<-EOF
      #!/bin/bash

      # navigating into app folder
      cd /repo/nodejs20-sparta-test-app/app

      #export DB_HOST= correct private IP
      export DB_HOST=mongodb://10.0.3.4:27017/posts

      #starting the app
      pm2 start app.js
    EOF
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      path     = "/home/adminuser/.ssh/authorized_keys"
      key_data = data.azurerm_ssh_public_key.tech501-farah-az-key.public_key
    }
  }

  storage_image_reference {
    id = data.azurerm_image.tech501_farah_image.id
  }
}
