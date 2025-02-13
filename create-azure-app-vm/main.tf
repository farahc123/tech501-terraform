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
#Referencing my existing public subnet
data "azurerm_subnet" "public_subnet" {
  name                 = "public-subnet"
  resource_group_name  = "tech501"
  virtual_network_name = "tech501-farah-2-subnet-vnet"
}

#Referencing my app image
data "azurerm_image" "tech501_farah_image" {
  name                = "tech501-farah-fourth-app-demo-from-img-vm-image-20250130111944"
  resource_group_name = "tech501"
}

resource "azurerm_public_ip" "tech501-farah-tf-app-vm-public-ip" {
  name                = "tech501-farah-tf-app-vm-public-ip"
  location            = "UK South"
  resource_group_name = "tech501"
  allocation_method   = "Static"
  domain_name_label   = "tech501-farah-tf-app-vm-public-ip"
}

resource "azurerm_network_interface" "tech501-farah-tf-app-vm-NIC" {
  name                = "tech501-farah-tf-app-vm-NIC"
  location            = "UK South"
  resource_group_name = "tech501"

  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.azurerm_subnet.public_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.tech501-farah-tf-app-vm-public-ip.id
  }
}

resource "azurerm_virtual_machine" "tech501-farah-tf-app-vm" {
  name                  = "tech501-farah-tf-app-vm"
  location              = "UK South"
  resource_group_name   = "tech501"
  network_interface_ids = [azurerm_network_interface.tech501-farah-tf-app-vm-NIC.id]
  vm_size               = "Standard_B1s"
  storage_os_disk {
    name          = "farah-app-tf-os-disk"
    caching       = "ReadWrite"
    create_option = "FromImage"
    disk_size_gb  = 30
  }

  os_profile {
    computer_name  = "tech501-farah-tf-app-vm"
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
    id = data.azurerm_image.tech501_farah_image.id
  }
}
