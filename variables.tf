variable "name" {
  description = "Virtual machine name"
  type        = string
}

variable "resource_group_name" {
  description = "The resource group where the virtual machine will reside"
  type        = string
}

variable "location" {
  description = "The location where the virtual machine will reside"
  type        = string
}

variable "admin_password" {
  description = "The administrator password for the virtual machine - for Linux VMs disable_password_authentication must be false"
  default     = null
  type        = string
}

variable "admin_ssh_key" {
  description = "One or more SSH keys to use for authentication - if set admin_password must not be"
  default     = {}
  type = map(object(
    {
      public_key = string
      username   = string
    }
  ))
}

variable "admin_username" {
  description = "The administrator username"
  type        = string
}

variable "availability_set" {
  description = "Should the virtual machine be part of an availability set?"
  default     = false
  type        = bool
}

variable "availability_set_name" {
  description = "Should the virtual machine be part of an availability set?"
  default     = null
  type        = string
}

variable "computer_name" {
  description = "The computer name of the virtual machine"
  type        = string
}


variable "disable_password_authentication" {
  description = "Must be false if using Linux with an admin password set"
  default     = true
  type        = bool
}

variable "license_type" {
  description = "The type of licence...Windows_client or Windows_Server for Windows or RHEL_BYOS or SLES_BYOS - alternatively use null for Linux and None for Windows"
  default     = null
  type        = string
}

variable "network_adapter_name" {
  description = "The name of the network adapter to assign to this virtual machine"
  type        = string
}

variable "operating_system" {
  description = "Windows or Linux virtual machine?"
  default = "Linux"
  type = string
  validation {
    condition = contains(
      [
        "Windows",
        "Linux"
      ],
      var.operating_system
    )
    error_message = "The Operating System must be either Windows or Linux - Linux is the default"
  }
}

variable "tags" {
  description = "A map of tags to assign to the resources in this module"
  default     = {}
  type        = map(any)
}

variable "os_disk" {
  description = "An object of OS disk configuration"
  default = {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }
  type = object(
    {
      caching              = string
      storage_account_type = string
      name                 = optional(string)
    }
  )
}

variable "private_ip_address_allocation" {
  description = "Should the virtual machines private IP address be statically or dynamically defined?"
  default     = "Dynamic"
  type        = string
  validation {
    condition = contains(
      [
        "Dynamic",
        "Static"
      ],
      var.private_ip_address_allocation
    )
    error_message = "IP allocation method must be either Dynamic or Static"
  }
}

variable "private_ip_address" {
  description = "The IP Address if the allocation is static"
  default     = null
  type        = string
}

variable "public_ip_address_id" {
  description = "The resource ID of the public IP address the virtual machine should use"
  default     = null
  type        = string
}

variable "size" {
  description = "The hardware SKU of the virtual machine"
  default     = "Standard_B2ms"
  type        = string
}

variable "source_image_reference" {
  description = "An object of the image to build the virtual machine from"
  default = {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "Latest"
  }
  type = object(
    {
      publisher = string
      offer     = string
      sku       = string
      version   = string
    }
  )
}

variable "subnet_id" {
  description = "The subnet resource ID the virtual machine should connect to"
  type        = string
}