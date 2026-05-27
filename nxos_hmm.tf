locals {
  hmm_interfaces_map = { for device in local.devices : device.name =>
    { for int in try(local.device_config[device.name].interfaces.vlans, []) : "vlan${int.id}" => {
      admin_state = null
      mode        = try(local.hmm_mode_map[try(int.fabric_forwarding_mode)], null)
    } if try(int.fabric_forwarding_mode, null) != null }
  }
  hmm_mode_map = {
    "standard"   = "standard"
    "anycast-gw" = "anycastGW"
    "proxy-gw"   = "proxyGW"
  }
}

resource "nxos_hmm" "hmm" {
  for_each = { for device in local.devices : device.name => device
    if try(local.device_config[device.name].fabric_forwarding, null) != null ||
  length([for int in try(local.device_config[device.name].interfaces.vlans, []) : int if try(int.fabric_forwarding_mode, null) != null]) > 0 }
  device                  = each.key
  admin_state             = null
  instance_admin_state    = null
  anycast_mac             = try(local.device_config[each.key].fabric_forwarding.anycast_gateway_mac, null)
  administrative_distance = try(local.device_config[each.key].fabric_forwarding.distance, null)
  limit_vlan_mac          = try(local.device_config[each.key].fabric_forwarding.limit_vlan_mac, null)
  selective_host_probe    = try(local.device_config[each.key].fabric_forwarding.selective_host_probe, null) == null ? null : (try(local.device_config[each.key].fabric_forwarding.selective_host_probe) ? "yes" : "no")
  interfaces              = length(local.hmm_interfaces_map[each.key]) > 0 ? local.hmm_interfaces_map[each.key] : null

  depends_on = [
    nxos_feature.feature,
    nxos_svi_interface.svi_interface
  ]
}
