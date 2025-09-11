resource "nxos_hmm" "hmm" {
  for_each = { for device in local.devices : device.name => device if try(local.device_config[device.name].system.fabric_forwarding, local.defaults.nxos.devices.configuration.system.fabric_forwarding, null) != null }
  device   = each.value.name

  depends_on = [
    nxos_feature_hmm.fabric_forwarding
  ]
}

resource "nxos_hmm_instance" "hmm_instance" {
  for_each    = { for device in local.devices : device.name => device if try(local.device_config[device.name].system.fabric_forwarding.anycast_gateway_mac, local.defaults.nxos.devices.configuration.system.fabric_forwarding, null) != null }
  device      = each.value.name
  anycast_mac = try(local.device_config[each.value.name].system.fabric_forwarding.anycast_gateway_mac, local.defaults.nxos.devices.configuration.system.fabric_forwarding.anycast_gateway_mac)

  depends_on = [
    nxos_hmm.hmm
  ]
}

resource "nxos_hmm_interface" "hmm_interface" {
  for_each     = { for v in local.interfaces_vlans : v.key => v if v.fabric_forwarding_mode != null }
  device       = each.value.device
  interface_id = "vlan${each.value.id}"
  mode         = each.value.fabric_forwarding_mode

  depends_on = [
    nxos_hmm_instance.hmm_instance,
    nxos_svi_interface_vrf.svi_interface_vrf
  ]
}
