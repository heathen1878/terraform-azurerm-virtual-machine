resource "azurerm_availability_set" "availability_set" {
  for_each = {
    for key, value in var.virtual_machines : key => value
    if value.availability_set != "false"
  }

  name                = each.value.availability_set
  resource_group_name = each.value.resource_group_name
  location            = each.value.location
  tags                = each.value.tags
}

resource "azurerm_network_interface" "network_adapter" {
  for_each = var.virtual_machines

  name                = each.value.network_adapter
  resource_group_name = each.value.resource_group_name
  location            = each.value.location
  ip_configuration {
    name                          = format("%s-%s%s", each.value.network_adapter, substr(each.key, 2, -1), "-nic-ipconfig")
    subnet_id                     = each.value.subnet
    private_ip_address_allocation = each.value.private_ip_address == "Dynamic" ? "Dynamic" : "Static"
    private_ip_address            = each.value.private_ip_address == "Static" ? null : null #cidrhost(data.terraform_remote_state.networking.outputs.subnets[each.value.subnet].address_prefix, each.value.private_ip_address) Look at logic to implement static 
    public_ip_address_id          = each.value.public_ip_address != "" ? each.value.public_ip_address : null
  }
  tags = merge(each.value.tags, {
    "Used by" = each.value.name
  })

}

resource "azurerm_windows_virtual_machine" "virtual_machine" {
  for_each = {
    for key, value in var.virtual_machines : key => value
    if value.operating_system == "windows"
  }

  # Mandatory
  admin_password = each.value.admin_password
  admin_username = each.value.admin_username
  location       = each.value.location
  name           = each.value.name
  network_interface_ids = [
    azurerm_network_interface.network_adapter[each.key].id
  ]
  os_disk {
    name                 = each.value.os_disk.name
    storage_account_type = each.value.os_disk.storage_account_type
    caching              = each.value.os_disk.caching
  }
  resource_group_name = each.value.resource_group_name
  size                = each.value.size

  # Optional
  additional_capabilities {
    ultra_ssd_enabled = each.value.additional_capabilities.ultra_ssd_enabled
  }

  dynamic "additional_unattend_content" {
    for_each = each.value.additional_unattend_content.content == "" ? {} : { "Unattend" = each.key }

    content {
      content = each.value.additional_unattend_content.content
      setting = each.value.additional_unattend_content.setting
    }
  }

  allow_extension_operations = each.value.allow_extension_operations
  availability_set_id        = each.value.availability_set != "false" ? azurerm_availability_set.availability_set[each.key].id : null

  boot_diagnostics {
    storage_account_uri = each.value.boot_diagnostics.storage_account_uri
  }

  capacity_reservation_group_id = each.value.capacity_reservation_group_id
  computer_name                 = each.value.computer_name
  custom_data                   = each.value.custom_data
  dedicated_host_id             = each.value.dedicated_host_id
  dedicated_host_group_id       = each.value.dedicated_host_group_id
  edge_zone                     = each.value.edge_zone
  enable_automatic_updates      = each.value.enable_automatic_updates
  encryption_at_host_enabled    = each.value.encryption_at_host_enabled
  eviction_policy               = each.value.eviction_policy
  extensions_time_budget        = each.value.extensions_time_budget

  dynamic "gallery_application" {
    for_each = each.value.gallery_application.version_id == null ? {} : { "gallery_application" = each.key }

    content {
      version_id             = each.value.gallery_application.version_id
      configuration_blob_uri = each.value.gallery_application.configuration_blob_uri
      order                  = each.value.gallery_application.order
      tag                    = each.value.gallery_application.tag
    }
  }

  hotpatching_enabled = each.value.hotpatching_enabled

  identity {
    type         = each.value.identity.type
    identity_ids = each.value.identity.identity_ids
  }

  license_type          = each.value.license_type
  max_bid_price         = each.value.max_bid_price
  patch_assessment_mode = each.value.patch_assessment_mode
  patch_mode            = each.value.patch_mode

  dynamic "plan" {
    for_each = each.value.plan.name == null ? {} : { "plan" = each.key }

    content {
      name      = each.value.plan.name
      product   = each.value.plan.product
      publisher = each.value.plan.publisher
    }
  }

  platform_fault_domain        = each.value.platform_fault_domain
  priority                     = each.value.priority
  provision_vm_agent           = each.value.provision_vm_agent
  proximity_placement_group_id = each.value.proximity_placement_group_id

  dynamic "secret" {
    for_each = each.value.secret.key_vault_id == null ? {} : { "secret" = each.key }

    content {
      certificate {
        store = each.value.secret.store
        url   = each.value.secret.certificate.url
      }
      key_vault_id = each.value.secret.key_vault_id
    }
  }

  secure_boot_enabled = each.value.secure_boot_enabled

  source_image_id = each.value.source_image_id

  source_image_reference {
    publisher = each.value.source_image_reference.publisher
    offer     = each.value.source_image_reference.offer
    sku       = each.value.source_image_reference.sku
    version   = each.value.source_image_reference.version
  }

  tags = merge(each.value.tags, {
    "computer name" = each.value.computer_name
    }
  )

  termination_notification {
    enabled = each.value.termination_notification.enabled
    timeout = each.value.termination_notification.timeout
  }

  timezone                     = each.value.timezone
  user_data                    = each.value.user_data
  vtpm_enabled                 = each.value.vtpm_enabled
  virtual_machine_scale_set_id = each.value.virtual_machine_scale_set_id
  zone                         = each.value.zone
}

resource "azurerm_linux_virtual_machine" "virtual_machine" {
  for_each = {
    for key, value in var.virtual_machines : key => value
    if value.operating_system == "linux"
  }

  # Mandatory
  admin_username = each.value.admin_username
  location       = each.value.location
  name           = each.value.name
  network_interface_ids = [
    azurerm_network_interface.network_adapter[each.key].id
  ]

  os_disk {
    name                 = each.value.os_disk.name
    storage_account_type = each.value.os_disk.storage_account_type
    caching              = each.value.os_disk.caching
  }

  resource_group_name = each.value.resource_group_name
  size                = each.value.size


  # Optional
  additional_capabilities {
    ultra_ssd_enabled = each.value.additional_capabilities.ultra_ssd_enabled
  }

  admin_password = each.value.admin_password

  admin_ssh_key {
    username   = each.value.admin_ssh_key.username
    public_key = each.value.admin_ssh_key.public_key
  }

  allow_extension_operations = each.value.allow_extension_operations
  availability_set_id        = each.value.availability_set != "false" ? azurerm_availability_set.availability_set[each.key].id : null

  boot_diagnostics {
    storage_account_uri = each.value.boot_diagnostics.storage_account_uri
  }

  capacity_reservation_group_id   = each.value.capacity_reservation_group_id
  computer_name                   = each.value.computer_name
  custom_data                     = each.value.custom_data
  dedicated_host_id               = each.value.dedicated_host_id
  dedicated_host_group_id         = each.value.dedicated_host_group_id
  disable_password_authentication = each.value.disable_password_authentication
  edge_zone                       = each.value.edge_zone
  encryption_at_host_enabled      = each.value.encryption_at_host_enabled
  eviction_policy                 = each.value.eviction_policy
  extensions_time_budget          = each.value.extensions_time_budget

  dynamic "gallery_application" {
    for_each = each.value.gallery_application.version_id == null ? {} : { "gallery_application" = each.key }

    content {
      version_id             = each.value.gallery_application.version_id
      configuration_blob_uri = each.value.gallery_application.configuration_blob_uri
      order                  = each.value.gallery_application.order
      tag                    = each.value.gallery_application.tag
    }
  }

  identity {
    type         = each.value.identity.type
    identity_ids = each.value.identity.identity_ids
  }

  max_bid_price = each.value.max_bid_price

  patch_assessment_mode = each.value.patch_assessment_mode
  patch_mode            = each.value.patch_mode

  dynamic "plan" {
    for_each = each.value.plan.name == null ? {} : { "plan" = each.key }

    content {
      name      = each.value.plan.name
      product   = each.value.plan.product
      publisher = each.value.plan.publisher
    }
  }

  platform_fault_domain        = each.value.platform_fault_domain
  priority                     = each.value.priority
  provision_vm_agent           = each.value.provision_vm_agent
  proximity_placement_group_id = each.value.proximity_placement_group_id

  dynamic "secret" {
    for_each = each.value.secret.key_vault_id == null ? {} : { "secret" = each.key }

    content {
      certificate {
        url = each.value.secret.certificate.url
      }
      key_vault_id = each.value.secret.key_vault_id
    }
  }

  secure_boot_enabled = each.value.secure_boot_enabled

  source_image_id = each.value.source_image_id

  source_image_reference {
    publisher = each.value.source_image_reference.publisher
    offer     = each.value.source_image_reference.offer
    sku       = each.value.source_image_reference.sku
    version   = each.value.source_image_reference.version
  }

  tags = merge(each.value.tags, {
    "computer name" = each.value.computer_name
    }
  )

  termination_notification {
    enabled = each.value.termination_notification.enabled
    timeout = each.value.termination_notification.timeout
  }

  user_data                    = each.value.user_data
  vtpm_enabled                 = each.value.vtpm_enabled
  virtual_machine_scale_set_id = each.value.virtual_machine_scale_set_id
  zone                         = each.value.zone

}
