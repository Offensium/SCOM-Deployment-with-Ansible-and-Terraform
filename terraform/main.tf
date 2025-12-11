# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0.2"
    }
  }

  required_version = ">= 1.1.0"
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "main" {
  name     = var.resourceGroup
  location = var.region
}

resource "azurerm_virtual_network" "main" {
  name                = "vnet-${var.prefix}"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_subnet" "main" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "pip" {
  for_each = { for k, v in local.vm_map : k => v if var.vm_specs[v.group].public_ip }
  name = "pip-${each.value.name}-${var.prefix}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_network_interface" "nic" {
  for_each = local.vm_map
  name = "nic-${each.value.name}-${var.prefix}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.main.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = try(azurerm_public_ip.pip[each.key].id, null)
  }
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "nic" {
  for_each = local.vm_map
  name = "nsg-${each.value.name}-${var.prefix}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  security_rule {
    name                       = "RDP"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = var.allowed_ip
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "WinRM"
    priority                   = 1002
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "5985"
    source_address_prefix      = var.allowed_ip
    destination_address_prefix = "*"
  }

}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "nic" {
  for_each = local.vm_map
  network_interface_id      = azurerm_network_interface.nic[each.key].id
  network_security_group_id = azurerm_network_security_group.nic[each.key].id
}

resource "azurerm_virtual_machine_extension" "vm" {
  for_each = local.vm_map
  name                 = "disableFw"
  virtual_machine_id   = azurerm_windows_virtual_machine.vm[each.key].id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"

  settings = <<SETTINGS
    {
      "commandToExecute": "powershell -ExecutionPolicy Unrestricted -Command \"Set-NetFirewallProfile -Profile Domain,Public,Private -Enabled False\""
    }
  SETTINGS
}


resource "azurerm_windows_virtual_machine" "vm" {
  for_each = local.vm_map
  name = "${each.value.name}"
  resource_group_name = var.resourceGroup
  location = var.region
  size = var.vm_specs[each.value.group].size
  admin_username = var.vm_specs[each.value.group].admin_user
  admin_password = var.admin_password
  network_interface_ids = [
    azurerm_network_interface.nic[each.key].id,
  ]

  source_image_reference {
    publisher = var.vm_specs[each.value.group].image.publisher
    offer     = var.vm_specs[each.value.group].image.offer
    sku       = var.vm_specs[each.value.group].image.sku
    version   = var.vm_specs[each.value.group].image.version
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching = "ReadWrite"
  }

}