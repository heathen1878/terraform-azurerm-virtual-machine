variable "virtual_machines" {
  description = "A map of virtual machines to create"
  default     = {}
  type = map(object({
    additional_capabilities = object({
      ultra_ssd_enabled = bool
    })
    additional_unattend_content = object({
      content = string
      setting = string
    })
    admin_password = string
    admin_ssh_key = object({
      public_key = string
      username   = string
    })
    admin_username             = string
    allow_extension_operations = bool
    availability_set           = string
    boot_diagnostics = object({
      storage_account_uri = string
    })
    capacity_reservation_group_id   = string
    computer_name                   = string
    custom_data                     = string
    dedicated_host_id               = string
    dedicated_host_group_id         = string
    disable_password_authentication = bool
    edge_zone                       = string
    enable_automatic_updates        = bool
    encryption_at_host_enabled      = bool
    eviction_policy                 = string
    extensions_time_budget          = string
    gallery_application = object({
      version_id             = string
      configuration_blob_uri = string
      order                  = number
      tag                    = string
    })
    hotpatching_enabled = bool
    identity = object({
      type         = string
      identity_ids = list(string)
    })
    license_type     = string
    location         = string
    max_bid_price    = string
    name             = string
    network_adapter  = string
    operating_system = string
    os_disk = object({
      caching              = string
      storage_account_type = string
      diff_disk_settings = object({
        option    = string
        placement = string
      })
      disk_encryption_set_id           = string
      disk_size_gb                     = number
      name                             = string
      secure_vm_disk_encryption_set_id = string
      security_encryption_type         = string
      write_accelerator_enabled        = bool
    })
    patch_assessment_mode = string
    patch_mode            = string
    plan = object({
      name      = string
      product   = string
      publisher = string
    })
    platform_fault_domain        = string
    priority                     = string
    private_ip_address           = string
    provision_vm_agent           = bool
    proximity_placement_group_id = string
    public_ip_address            = string
    resource_group_name          = string
    secret = object({
      certificate = object({
        store = string
        url   = string
      })
      key_vault_id = string
    })
    secure_boot_enabled = bool
    size                = string
    source_image_id     = string
    source_image_reference = object({
      publisher = string
      offer     = string
      sku       = string
      version   = string
    })
    subnet = string
    tags   = map(any)
    termination_notification = object({
      enabled = bool
      timeout = string
    })
    timezone                     = string
    user_data                    = string
    virtual_machine_scale_set_id = string
    vtpm_enabled                 = bool
    winrm_listener = object({
      protocol        = string
      certificate_url = string
    })
    zone = string
  }))
}