locals {

  # global
  location = "uksouth"

  tags = {
    IaC   = "Terraform"
    Usage = "Windows VM Example"
  }

  virtual_network_address_range = [
    "192.168.0.0/24"
  ]

}

module "resource_group_naming" {
  source  = "heathen1878/naming/azurecaf"
  version = "1.0.1"

  resource_name = "windows-vm-example"
  resource_type = "azurerm_resource_group"
}

module "network_watcher_naming" {
  source  = "heathen1878/naming/azurecaf"
  version = "1.0.1"

  resource_name = "windows-vm-example"
  resource_type = "azurerm_network_watcher"
}

module "virtual_network_naming" {
  source  = "heathen1878/naming/azurecaf"
  version = "1.0.1"

  resource_name = "windows-vm-example"
  resource_type = "azurerm_virtual_network"
}

module "network_interface_naming" {
  source  = "heathen1878/naming/azurecaf"
  version = "1.0.1"

  resource_name = "windows-vm-example"
  resource_type = "azurerm_network_interface"
}

module "virtual_machine_naming" {
  source  = "heathen1878/naming/azurecaf"
  version = "1.0.1"

  resource_name = "windows-vm-example"
  resource_type = "azurerm_virtual_machine"
  random_byte_length = 6
}

module "resource-groups" {
  source  = "heathen1878/resource-groups/azurerm"
  version = "3.0.0"

  resource_group_name     = module.resource_group_naming.resource_name
  resource_group_location = local.location
  resource_group_tags     = local.tags
}

resource "azurerm_network_watcher" "this" {
  name                = module.network_watcher_naming.resource_name
  resource_group_name = module.resource-groups.resource_group_name
  location            = local.location
}

resource "azurerm_virtual_network" "this" {
  name                = module.virtual_network_naming.resource_name
  resource_group_name = module.resource-groups.resource_group_name
  location            = local.location
  address_space       = local.virtual_network_address_range

  depends_on = [
    azurerm_network_watcher.this
  ]
}

resource "azurerm_subnet" "virtual_machines" {
  name                 = "virtualmachines"
  resource_group_name  = module.resource-groups.resource_group_name
  virtual_network_name = azurerm_virtual_network.this.name
  address_prefixes = [
    cidrsubnet(azurerm_virtual_network.this.address_space[0], 2, 0)
  ]
}

module "windows_vm" {

  source = "../../"

  name                 = module.virtual_machine_naming.resource_name
  location             = local.location
  resource_group_name  = module.resource-groups.resource_group_name
  computer_name        = module.virtual_machine_naming.resource_name
  subnet_id            = azurerm_subnet.virtual_machines.id
  admin_username       = "local_admin"
  network_adapter_name = module.network_interface_naming.resource_name
  admin_password = random_string.password.result
}