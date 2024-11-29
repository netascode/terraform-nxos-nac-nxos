
resource "nxos_pim" "pim" {
  for_each    = { for device in local.devices : device.name => device if(try(length(local.device_config[device.name].routing.pim.vrfs), 0) > 0) }
  device      = each.key
  admin_state = "enabled"
}

resource "nxos_pim_instance" "pim_instance" {
  for_each    = { for device in local.devices : device.name => device if(try(length(local.device_config[device.name].routing.pim.vrfs), 0) > 0) }
  device      = each.key
  admin_state = nxos_pim.pim[each.key].admin_state
}

locals {
  routing_pim_vrfs = flatten([
    for device in local.devices : [
      for vrf in try(local.device_config[device.name].routing.pim.vrfs, []) : {
        key                         = format("%s/%s", device.name, vrf.vrf)
        device                      = device.name
        name                        = vrf.vrf
        admin_state                 = try(vrf.admin_state, local.defaults.nxos.devices.configuration.routing.pim.vrfs.admin_state, false) ? "enabled" : "disabled"
        bfd                         = try(vrf.bfd, local.defaults.nxos.devices.configuration.routing.pim.vrfs.bfd, false)
        anycast_rp_local_interface  = try(vrf.anycast_rp_local_interface, local.defaults.nxos.devices.configuration.routing.pim.vrfs.anycast_rp_local_interface, "unspecified")
        anycast_rp_source_interface = try(vrf.anycast_rp_source_interface, local.defaults.nxos.devices.configuration.routing.pim.vrfs.anycast_rp_source_interface, "unspecified")
        rp                          = try(length(vrf.rps), 0) > 0
      }
    ]
  ])
}

resource "nxos_pim_vrf" "pim_vrf" {
  for_each    = { for v in local.routing_pim_vrfs : v.key => v }
  device      = each.value.device
  name        = each.value.name
  admin_state = each.value.admin_state
  bfd         = each.value.bfd

  depends_on = [
    nxos_pim_instance.pim_instance
  ]
}

resource "nxos_pim_static_rp_policy" "pim_static_rp_policy" {
  for_each = { for v in local.routing_pim_vrfs : v.key => v if v.rp }
  device   = each.value.device
  vrf_name = nxos_pim_vrf.pim_vrf[each.key].name
  name     = "RP"
}

locals {
  routing_pim_vrfs_rps = flatten([
    for device in local.devices : [
      for vrf in try(local.device_config[device.name].routing.pim.vrfs, []) : [
        for rp in try(vrf.rps, []) : {
          key         = format("%s/%s/%s", device.name, vrf.vrf, rp.address)
          device      = device.name
          vrf_key     = format("%s/%s", device.name, vrf.vrf)
          address     = rp.address
          group_range = try(rp.group_range, local.defaults.nxos.devices.configuration.routing.pim.vrfs.rps.group_range, "224.0.0.0/4")
          bidir       = try(rp.bidir, local.defaults.nxos.devices.configuration.routing.pim.vrfs.rps.bidir, false)
          override    = try(rp.override, local.defaults.nxos.devices.configuration.routing.pim.vrfs.rps.override, false)
        }
      ]
    ]
  ])
}

resource "nxos_pim_static_rp" "pim_static_rp" {
  for_each = { for v in local.routing_pim_vrfs_rps : v.key => v }
  device   = each.value.device
  vrf_name = nxos_pim_static_rp_policy.pim_static_rp_policy[each.value.vrf_key].vrf_name
  address  = each.value.address
}

resource "nxos_pim_static_rp_group_list" "pim_static_rp_group_list" {
  for_each   = { for v in local.routing_pim_vrfs_rps : v.key => v }
  device     = each.value.device
  vrf_name   = nxos_pim_static_rp.pim_static_rp[each.key].vrf_name
  rp_address = nxos_pim_static_rp.pim_static_rp[each.key].address
  address    = each.value.group_range
  bidir      = each.value.bidir
  override   = each.value.override
}

resource "nxos_pim_anycast_rp" "pim_anycast_rp" {
  for_each         = { for v in local.routing_pim_vrfs : v.key => v }
  device           = each.value.device
  vrf_name         = nxos_pim_vrf.pim_vrf[each.key].name
  local_interface  = each.value.anycast_rp_local_interface
  source_interface = each.value.anycast_rp_source_interface
}

locals {
  routing_pim_vrfs_anycast_rps = flatten([
    for device in local.devices : [
      for vrf in try(local.device_config[device.name].routing.pim.vrfs, []) : [
        for rp in try(vrf.anycast_rps, []) : {
          key         = format("%s/%s/%s/%s", device.name, vrf.vrf, rp.address, rp.set_address)
          device      = device.name
          vrf_key     = format("%s/%s", device.name, vrf.vrf)
          address     = rp.address
          set_address = rp.set_address
        }
      ]
    ]
  ])
}

resource "nxos_pim_anycast_rp_peer" "pim_anycast_rp_peer" {
  for_each       = { for v in local.routing_pim_vrfs_anycast_rps : v.key => v }
  device         = each.value.device
  vrf_name       = nxos_pim_anycast_rp.pim_anycast_rp[each.value.vrf_key].vrf_name
  address        = "${each.value.address}/32"
  rp_set_address = "${each.value.set_address}/32"
}

locals {
  pim_interfaces = concat(local.interfaces_ethernets, local.interfaces_loopbacks, local.interfaces_vlans)
}

resource "nxos_pim_interface" "pim_interface" {
  for_each     = { for v in local.pim_interfaces : v.key => v if try(v.pim_admin_state, null) != null }
  device       = each.value.device
  vrf_name     = nxos_pim_vrf.pim_vrf["${each.value.device}/${each.value.vrf}"].name
  interface_id = "${each.value.type}${each.value.id}"
  admin_state  = each.value.pim_admin_state ? "enabled" : "disabled"
  bfd          = each.value.pim_bfd == "unspecified" ? "none" : each.value.pim_bfd
  dr_priority  = each.value.pim_dr_priority
  passive      = each.value.pim_passive
  sparse_mode  = each.value.pim_sparse_mode
}
