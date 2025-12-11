output "vm_endpoints" {
  value = {
    for k, vm in azurerm_windows_virtual_machine.vm : k => {
      vm_name    = vm.name
      type      = local.vm_map[k].type
      private_ip = azurerm_network_interface.nic[k].ip_configuration[0].private_ip_address
      public_ip  = try(azurerm_public_ip.pip[k].ip_address, null)
    }
  }
}