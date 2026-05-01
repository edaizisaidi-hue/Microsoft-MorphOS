# =================================================================
# PROJECT MORPHOS: SOVEREIGN CLOUD INFRASTRUCTURE (FINAL BLUEPRINT)
# =================================================================

resource "azurerm_resource_group" "morphos_rg" {
  name     = "RG-MORPHOS-SOVEREIGN"
  location = "East US"
}

resource "azurerm_virtual_network" "morphos_vnet" {
  name                = "VNET-MORPHOS-CORE"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.morphos_rg.location
  resource_group_name = azurerm_resource_group.morphos_rg.name
}

resource "azurerm_subnet" "morphos_subnet" {
  name                 = "SNET-MORPHOS-INTERNAL"
  resource_group_name  = azurerm_resource_group.morphos_rg.name
  virtual_network_name = azurerm_virtual_network.morphos_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Confidential VM Infrastructure
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

resource "azurerm_linux_virtual_machine" "morphos_conf_vm" {
  name                = "VM-MORPHOS-DNA-SYNTH"
  resource_group_name = azurerm_resource_group.morphos_rg.name
  location            = azurerm_resource_group.morphos_rg.location
  size                = "Standard_DC2s_v3"
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
    public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDNIQ1DpXw9TC5hJ4N55VaqViyY1MM2q7R5YzpwjS8z/zAFrPuO3rOtHF5TWxI+yuqglpnN+i6nBhdYsMpJIKvtt+eEJQue9yawHNkUT8sK6iGZF9VGx/R3fEesCNF607VbTNMU5qa4/WsNvqnIFcHkpTrUlaCc7SkBg6/IReFuv+dGqu2KiHCEeGYNUtXuQG02bNpwMO1lAFPUfI51m3DoKy1uJYPWBUK7p4yah5Mc/QxtUbgZWljuwMILDO9MjGgL7DFesWM3/XIySh2JpFNJDLtk/zMCGDQn3yHdoG6IpBjiFMxxNSWmGwgXznuYGk29DFiwvkMaqeG26VxpSiDRbhk/Hr/VpaufSx4R07f12Y4AAevRSSanxni4e9EVjy6XG/9uTWqISsrBt3Gw19BwKENZYl/XMxVHU4zY5y6F/MQKnHDiBxAplo1JqOrKx1cTRj/PnT+nh74A3/35tprWTQGcGr602fBLEmzzg7hc9BJNRHlOLA1kSeXUZeVcNcwDHzWLKCUy+UhKZKdgZwKOB+YeaH+dOwa7iGyLNJVIuQdL3fi3cHICPxfBYJSAbLIsTBwxlGg836cuGKHRGn3jHw5ljA3ZLAAWnZjJkVop7HEdXTJTXuKKyHSO0DXAjHEsDY/nu0MOgZM6rrzM1Kp3fm98m7Irh+4Yk1TMM8I4hw== edaizisaidi-hue"
  }
}

# Gateway Infrastructure
resource "azurerm_public_ip" "gateway_ip" {
  name                = "PIP-MORPHOS-GATEWAY"
  location            = azurerm_resource_group.morphos_rg.location
  resource_group_name = azurerm_resource_group.morphos_rg.name
  allocation_method   = "Static"
}

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
    public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDNIQ1DpXw9TC5hJ4N55VaqViyY1MM2q7R5YzpwjS8z/zAFrPuO3rOtHF5TWxI+yuqglpnN+i6nBhdYsMpJIKvtt+eEJQue9yawHNkUT8sK6iGZF9VGx/R3fEesCNF607VbTNMU5qa4/WsNvqnIFcHkpTrUlaCc7SkBg6/IReFuv+dGqu2KiHCEeGYNUtXuQG02bNpwMO1lAFPUfI51m3DoKy1uJYPWBUK7p4yah5Mc/QxtUbgZWljuwMILDO9MjGgL7DFesWM3/XIySh2JpFNJDLtk/zMCGDQn3yHdoG6IpBjiFMxxNSWmGwgXznuYGk29DFiwvkMaqeG26VxpSiDRbhk/Hr/VpaufSx4R07f12Y4AAevRSSanxni4e9EVjy6XG/9uTWqISsrBt3Gw19BwKENZYl/XMxVHU4zY5y6F/MQKnHDiBxAplo1JqOrKx1cTRj/PnT+nh74A3/35tprWTQGcGr602fBLEmzzg7hc9BJNRHlOLA1kSeXUZeVcNcwDHzWLKCUy+UhKZKdgZwKOB+YeaH+dOwa7iGyLNJVIuQdL3fi3cHICPxfBYJSAbLIsTBwxlGg836cuGKHRGn3jHw5ljA3ZLAAWnZjJkVop7HEdXTJTXuKKyHSO0DXAjHEsDY/nu0MOgZM6rrzM1Kp3fm98m7Irh+4Yk1TMM8I4hw== edaizisaidi-hue"
  }
}

output "gateway_public_ip" {
  value = azurerm_public_ip.gateway_ip.ip_address
}

output "confidential_vm_private_ip" {
  value = azurerm_network_interface.conf_nic.private_ip_address
}
