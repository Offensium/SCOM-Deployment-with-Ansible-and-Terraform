variable "prefix" {
  description = "The prefix which should be used for all resources in this example"
  type = string
  default = "lab"
}

variable "region" {
  description = "The Azure Region in which all resources by defaultshould be created."
  type = string
  default = "northeurope"
}

variable "resourceGroup" {
  description = "The Azure Resource group in which all resources by defaultshould be created."
  type = string
  default = "rg-SCOMLab"
}

variable "domain_name" {
  description = "The domain name to be used for the VMs."
  type = string
  default = "offensium.local"
}

variable "allowed_ip" {
  description = "IP address allowed to access the VMs."
  type = string
  default = "<Your_Public_IP>"
}

variable "admin_password" {
  description = "The admin password to be used for all VMs."
  type = string
  default = "P@ssw0rd1234!"
}

# groups: map -> list of instance names
variable "vm_groups" {
  type = map(list(object({
    name = string
    type = string
  })))
  default = {
    servers = [
      { name = "dc01", type = "domain_controller"},
      { name = "scom-dw", type = "database_server"},
      { name = "scom-db", type = "database_server"},
      { name = "scom-om1", type = "operations_manager_server_primary"},
      { name = "scom-om2", type = "operations_manager_server_additional"},
      { name = "scom-reporting", type = "reporting_server"}
    ]

  }
}
# per-group specs (size, whether public ip, etc.)
variable "vm_specs" {
  type = map(object({
    size        = string
    image       = object({ publisher = string, offer = string, sku = string, version = string })
    public_ip   = bool
    admin_user  = string
  }))

  default = {
    servers = {
      description = "Windows Server 2025 VM"
      size       = "Standard_D2ls_v5"
      image = { publisher = "MicrosoftWindowsServer", offer = "WindowsServer", sku = "2025-datacenter", version = "latest" }
      public_ip  = true
      admin_user = "azureuser"
    }
  }
}
