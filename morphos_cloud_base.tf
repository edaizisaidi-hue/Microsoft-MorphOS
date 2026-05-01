# =================================================================
# PROJECT MORPHOS: SOVEREIGN CLOUD INFRASTRUCTURE
# =================================================================

# 1. Resource Group
resource "azurerm_resource_group" "morphos_rg" {
  name     = "RG-MORPHOS-SOVEREIGN"
  location = "East US" # Lokasi terbaik untuk Intel SGX
}

# 2. Virtual Network
resource "azurerm_virtual_network" "morphos_vnet" {
  name                = "VNET-MORPHOS-CORE"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.morphos_rg.location
  resource_group_name = azurerm_resource_group.morphos_rg.name
}

# 3. Subnet
resource "azurerm_subnet" "morphos_subnet" {
  name                 = "SNET-MORPHOS-INTERNAL"
  resource_group_name  = azurerm_resource_group.morphos_rg.name
  virtual_network_name = azurerm_virtual_network.morphos_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# 4. Confidential VM Network Interface
resource "azurerm_network_interface" "conf_nic" {
  name                = "NIC-MORPHOS-CONFIDENTIAL"
  location            = azurerm_resource_group.morphos_rg.location
  resource_group_name = azurerm_resource_group.morphos_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.morphos_subnet.id
    private_ip_address_allocation = "Dynamic"
  }
}

# 5. Confidential VM (Evolution Engine - Intel SGX)
resource "azurerm_linux_virtual_machine" "morphos_conf_vm" {
  name                = "VM-MORPHOS-DNA-SYNTH"
  resource_group_name = azurerm_resource_group.morphos_rg.name
  location            = azurerm_resource_group.morphos_rg.location
  size                = "Standard_DC2s_v3" # Intel SGX Enabled
  admin_username      = "tsa_architect"

  network_interface_ids = [azurerm_network_interface.conf_nic.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }

  admin_ssh_key {
    username   = "tsa_architect"
    public_key = file("~/.ssh/id_rsa.pub")
  }
}

# 6. Public IP untuk Gateway
resource "azurerm_public_ip" "gateway_ip" {
  name                = "PIP-MORPHOS-GATEWAY"
  location            = azurerm_resource_group.morphos_rg.location
  resource_group_name = azurerm_resource_group.morphos_rg.name
  allocation_method   = "Static"
}

# 7. Network Interface untuk Gateway
resource "azurerm_network_interface" "gateway_nic" {
  name                = "NIC-MORPHOS-GATEWAY"
  location            = azurerm_resource_group.morphos_rg.location
  resource_group_name = azurerm_resource_group.morphos_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.morphos_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.gateway_ip.id
  }
}

# 8. Gateway VM (The Entry Point)
resource "azurerm_linux_virtual_machine" "morphos_gateway" {
  name                = "VM-MORPHOS-GATEWAY"
  resource_group_name = azurerm_resource_group.morphos_rg.name
  location            = azurerm_resource_group.morphos_rg.location
  size                = "Standard_B1s"
  admin_username      = "tsa_architect"

  network_interface_ids = [azurerm_network_interface.gateway_nic.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
  }

  admin_ssh_key {
    username   = "tsa_architect"
    public_key = file("~/.ssh/id_rsa.pub")
  }
}

output "gateway_public_ip" {
  value = azurerm_public_ip.gateway_ip.ip_address
}

output "confidential_vm_private_ip" {
  value = azurerm_network_interface.conf_nic.private_ip_address
}
