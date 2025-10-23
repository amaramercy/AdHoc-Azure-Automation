# Resource Group
resource "azurerm_resource_group" "main" {
  name     = "${var.prefix}-rg"
  location = var.location
}

# Virtual Network
resource "azurerm_virtual_network" "main" {
  name                = "${var.prefix}-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

# Subnet
resource "azurerm_subnet" "main" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Security Group (allow SSH + HTTP)
resource "azurerm_network_security_group" "main" {
  name                = "${var.prefix}-nsg"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  security_rule {
    name                       = "allow_ssh"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "allow_http"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Create 3 Public IPs
resource "azurerm_public_ip" "vm_pip" {
  count               = 3
  name                = "${var.prefix}-pip-${count.index}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Create 3 Network Interfaces
resource "azurerm_network_interface" "vm_nic" {
  count               = 3
  name                = "${var.prefix}-nic-${count.index}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.main.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.vm_pip[count.index].id
  }
}

# Associate NSG
resource "azurerm_network_interface_security_group_association" "nsg_assoc" {
  count                     = 3
  network_interface_id      = azurerm_network_interface.vm_nic[count.index].id
  network_security_group_id = azurerm_network_security_group.main.id
}

# Create 3 Linux VMs
resource "azurerm_linux_virtual_machine" "vm" {
  count                           = 3
  name                            = "${var.prefix}-vm-${count.index}"
  resource_group_name             = azurerm_resource_group.main.name
  location                        = azurerm_resource_group.main.location
  size                            = "Standard_B1s"
  admin_username                  = "azureuser"
  disable_password_authentication = false
  admin_password                  = "Demo@12345678"
  network_interface_ids           = [azurerm_network_interface.vm_nic[count.index].id]

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


# provider "azurerm" {
#   features {}
# }

# resource "azurerm_resource_group" "main" {
#   name     = "${var.prefix}-resources"
#   location = var.location
# }

# resource "azurerm_virtual_network" "main" {
#   name                = "${var.prefix}-network"
#   address_space       = ["10.0.0.0/16"]
#   location            = azurerm_resource_group.main.location
#   resource_group_name = azurerm_resource_group.main.name
# }

# resource "azurerm_subnet" "internal" {
#   name                 = "internal"
#   resource_group_name  = azurerm_resource_group.main.name
#   virtual_network_name = azurerm_virtual_network.main.name
#   address_prefixes     = ["10.0.2.0/24"]
# }

# resource "azurerm_public_ip" "pip" {
#   name                = "${var.prefix}-pip"
#   resource_group_name = azurerm_resource_group.main.name
#   location            = azurerm_resource_group.main.location
#   allocation_method   = "Static"
#   sku                 = "Standard"
# }

# resource "azurerm_network_interface" "main" {
#   name                = "${var.prefix}-nic1"
#   resource_group_name = azurerm_resource_group.main.name
#   location            = azurerm_resource_group.main.location

#   ip_configuration {
#     name                          = "primary"
#     subnet_id                     = azurerm_subnet.internal.id
#     private_ip_address_allocation = "Dynamic"
#     public_ip_address_id          = azurerm_public_ip.pip.id
#   }
# }

# resource "azurerm_network_interface" "internal" {
#   name                = "${var.prefix}-nic2"
#   resource_group_name = azurerm_resource_group.main.name
#   location            = azurerm_resource_group.main.location

#   ip_configuration {
#     name                          = "internal"
#     subnet_id                     = azurerm_subnet.internal.id
#     private_ip_address_allocation = "Dynamic"
#   }
# }

# resource "azurerm_network_security_group" "webserver" {
#   name                = "tls_webserver"
#   location            = azurerm_resource_group.main.location
#   resource_group_name = azurerm_resource_group.main.name

#   security_rule {
#     access                     = "Allow"
#     direction                  = "Inbound"
#     name                       = "allow_https"
#     priority                   = 100
#     protocol                   = "Tcp"
#     source_port_range          = "*"
#     source_address_prefix      = "*"
#     destination_port_range     = "80"
#     destination_address_prefix = "*"
#   }

#   security_rule {
#     access                     = "Allow"
#     direction                  = "Inbound"
#     name                       = "allow_ssh"
#     priority                   = 110
#     protocol                   = "Tcp"
#     source_port_range          = "*"
#     source_address_prefix      = "*"
#     destination_port_range     = "22"
#     destination_address_prefix = "*"
#   }
# }

# resource "azurerm_network_interface_security_group_association" "main" {
#   network_interface_id      = azurerm_network_interface.main.id
#   network_security_group_id = azurerm_network_security_group.webserver.id
# }

# resource "azurerm_linux_virtual_machine" "main" {
#   name                            = "${var.prefix}-vm"
#   resource_group_name             = azurerm_resource_group.main.name
#   location                        = azurerm_resource_group.main.location
#   size                            = "Standard_B1s"
#   admin_username                  = "adminuser"
#   admin_password                  = "Demo@12345678"
#   disable_password_authentication = false
#   network_interface_ids = [
#     azurerm_network_interface.main.id,
#     azurerm_network_interface.internal.id,
#   ]

#   source_image_reference {
#     publisher = "Canonical"
#     offer     = "0001-com-ubuntu-server-jammy"
#     sku       = "22_04-lts"
#     version   = "latest"
#   }

#   os_disk {
#     storage_account_type = "Standard_LRS"
#     caching              = "ReadWrite"
#   }
# }
