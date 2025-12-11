  # Build INI-style inventory text. For each group build a section and its hosts.
locals {
  # Flatten vm_groups (group -> list(object{name,type,ansible_user?})) into a list of host maps
  vm_list = flatten([
    for group, hosts in var.vm_groups : [
      for h in hosts : {
        group       = group
        name        = h.name
        type        = h.type
      }
    ]
  ])

  # map name -> host map (convenience)
  vm_map = { for v in local.vm_list : v.name => v }
}
