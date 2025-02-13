provider "azurerm" {
  resource_provider_registrations = "none"
  features {}
  subscription_id = var.subscription_id
}

# Referencing my pre-existing SSH public key in Azure
data "azurerm_ssh_public_key" "tech501-farah-az-key" {
  name                = "tech501-farah-az-key"
  resource_group_name = "tech501"
}

# Referencing my existing private subnet
data "azurerm_subnet" "private_subnet" {
  name                 = "private-subnet"
  resource_group_name  = "tech501"
  virtual_network_name = "tech501-farah-2-subnet-vnet"
}

# Referencing my DB image
data "azurerm_image" "tech501_farah_db_image" {
  name                = "tech501-farah-sparta-app-db-vm-image-20250129124146"
  resource_group_name = "tech501"
}

resource "azurerm_network_interface" "tech501-farah-tf-db-vm-NIC" {
  name                = "tech501-farah-tf-db-vm-NIC"
  location            = "UK South"
  resource_group_name = "tech501"

  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.azurerm_subnet.private_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_virtual_machine" "tech501-farah-tf-db-vm" {
  name                  = "tech501-farah-tf-db-vm"
  location              = "UK South"
  resource_group_name   = "tech501"
  network_interface_ids = [azurerm_network_interface.tech501-farah-tf-db-vm-NIC.id]
  vm_size               = "Standard_B1s"
  storage_os_disk {
    name          = "farah-db-tf-os-disk"
    caching       = "ReadWrite"
    create_option = "FromImage"
    disk_size_gb  = 30
  }

  os_profile {
    computer_name  = "tech501-farah-tf-db-vm"
    admin_username = "adminuser"
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      path     = "/home/adminuser/.ssh/authorized_keys"
      key_data = data.azurerm_ssh_public_key.tech501-farah-az-key.public_key
    }
  }

  storage_image_reference {
    id = data.azurerm_image.tech501_farah_db_image.id
  }
}
