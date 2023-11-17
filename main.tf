resource "azurerm_availability_set" "this" {
  for_each = var.availability_set == true ? { "availability_set" = "true" } : {}

  name                = var.availability_set_name
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
}

resource "azurerm_network_interface" "this" {
  name                = var.network_adapter_name
  resource_group_name = var.resource_group_name
  location            = var.location
  ip_configuration {
    name                          = format("%s%s", var.network_adapter_name, "-nic-ipconfig")
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = var.private_ip_address_allocation == "Dynamic" ? var.private_ip_address_allocation : "Static"
    private_ip_address            = var.private_ip_address != "Dyanmic" ? var.private_ip_address : null
    public_ip_address_id          = var.public_ip_address_id != null ? var.public_ip_address_id : null
  }
  tags = merge(
    var.tags,
    {
      "Used by" = var.name
    }
  )

}

resource "azurerm_windows_virtual_machine" "this" {
  for_each = var.operating_system == "Windows" ? { "windows_vm" = "true" } : {}

  # Mandatory
  admin_password      = var.admin_password
  admin_username      = var.admin_username
  location            = var.location
  name                = var.name
  resource_group_name = var.resource_group_name
  size                = var.size

  network_interface_ids = [
    azurerm_network_interface.this.id
  ]

  os_disk {
    name                 = var.os_disk.name
    storage_account_type = var.os_disk.storage_account_type
    caching              = var.os_disk.caching
  }

  # Optional
  availability_set_id = var.availability_set != false ? azurerm_availability_set.this["availability_set"].id : null
  computer_name       = var.computer_name
  license_type        = var.license_type
  tags = merge(
    each.value.tags,
    {
      "computer name" = var.computer_name
    }
  )

  source_image_reference {
    publisher = var.source_image_reference.publisher
    offer     = var.source_image_reference.offer
    sku       = var.source_image_reference.sku
    version   = var.source_image_reference.version
  }
}

resource "azurerm_linux_virtual_machine" "this" {
  for_each = var.operating_system == "Linux" ? { "linux_vm" = "true" } : {}

  # Mandatory
  admin_username      = var.admin_username
  location            = var.location
  name                = var.name
  resource_group_name = var.resource_group_name
  size                = var.size

  network_interface_ids = [
    azurerm_network_interface.this.id
  ]

  os_disk {
    name                 = var.os_disk.name
    storage_account_type = var.os_disk.storage_account_type
    caching              = var.os_disk.caching
  }

  # Optional
  admin_password      = var.admin_password
  availability_set_id = var.availability_set != false ? azurerm_availability_set.this["availability_set"].id : null
  computer_name       = var.computer_name
  tags = merge(
    var.tags,
    {
      "computer name" = var.computer_name
    }
  )

  dynamic "admin_ssh_key" {
    for_each = var.admin_ssh_key

    content {
      username   = admin_ssh_key.value.username
      public_key = admin_ssh_key.value.public_key  
    }
  }

  source_image_reference {
    publisher = var.source_image_reference.publisher
    offer     = var.source_image_reference.offer
    sku       = var.source_image_reference.sku
    version   = var.source_image_reference.version
  }
}
