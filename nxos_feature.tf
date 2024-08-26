resource "nxos_feature_bfd" "feature_bfd" {
  for_each = { for device in local.devices : device.name => device }
  device   = each.key
  admin_state = try(
    contains(local.device_config[each.key].system.features, "bfd"),
    contains(local.defaults.nxos.devices.configuration.system.features, "bfd"),
    false
  ) ? "enabled" : "disabled"
}

resource "nxos_feature_bgp" "bgp" {
  for_each = { for device in local.devices : device.name => device }
  device   = each.key
  admin_state = try(
    contains(local.device_config[each.key].system.features, "bgp"),
    contains(local.defaults.nxos.devices.configuration.system.features, "bgp"),
    false
  ) ? "enabled" : "disabled"
}

resource "nxos_feature_dhcp" "dhcp" {
  for_each = { for device in local.devices : device.name => device }
  device   = each.key
  admin_state = try(
    contains(local.device_config[each.key].system.features, "dhcp"),
    contains(local.defaults.nxos.devices.configuration.system.features, "dhcp"),
    false
  ) ? "enabled" : "disabled"
}

resource "nxos_feature_evpn" "evpn" {
  for_each = { for device in local.devices : device.name => device }
  device   = each.key
  admin_state = try(
    contains(local.device_config[each.key].system.features, "evpn"),
    contains(local.defaults.nxos.devices.configuration.system.features, "evpn"),
    false
  ) ? "enabled" : "disabled"
}

resource "nxos_feature_hmm" "fabric_forwarding" {
  for_each = { for device in local.devices : device.name => device }
  device   = each.key
  admin_state = try(
    contains(local.device_config[each.key].system.features, "fabric_forwarding"),
    contains(local.defaults.nxos.devices.configuration.system.features, "fabric_forwarding"),
    false
  ) ? "enabled" : "disabled"
}

resource "nxos_feature_hsrp" "hsrp" {
  for_each = { for device in local.devices : device.name => device }
  device   = each.key
  admin_state = try(
    contains(local.device_config[each.key].system.features, "hsrp"),
    contains(local.defaults.nxos.devices.configuration.system.features, "hsrp"),
    false
  ) ? "enabled" : "disabled"
}

resource "nxos_feature_interface_vlan" "interface_vlan" {
  for_each = { for device in local.devices : device.name => device }
  device   = each.key
  admin_state = try(
    contains(local.device_config[each.key].system.features, "interface_vlan"),
    contains(local.defaults.nxos.devices.configuration.system.features, "interface_vlan"),
    false
  ) ? "enabled" : "disabled"
}

resource "nxos_feature_isis" "isis" {
  for_each = { for device in local.devices : device.name => device }
  device   = each.key
  admin_state = try(
    contains(local.device_config[each.key].system.features, "isis"),
    contains(local.defaults.nxos.devices.configuration.system.features, "isis"),
    false
  ) ? "enabled" : "disabled"
}

resource "nxos_feature_lacp" "lacp" {
  for_each = { for device in local.devices : device.name => device }
  device   = each.key
  admin_state = try(
    contains(local.device_config[each.key].system.features, "lacp"),
    contains(local.defaults.nxos.devices.configuration.system.features, "lacp"),
    false
  ) ? "enabled" : "disabled"
}

resource "nxos_feature_lldp" "lldp" {
  for_each = { for device in local.devices : device.name => device }
  device   = each.key
  admin_state = try(
    contains(local.device_config[each.key].system.features, "lldp"),
    contains(local.defaults.nxos.devices.configuration.system.features, "lldp"),
    false
  ) ? "enabled" : "disabled"
}

resource "nxos_feature_macsec" "macsec" {
  for_each = { for device in local.devices : device.name => device }
  device   = each.key
  admin_state = try(
    contains(local.device_config[each.key].system.features, "macsec"),
    contains(local.defaults.nxos.devices.configuration.system.features, "macsec"),
    false
  ) ? "enabled" : "disabled"
}

resource "nxos_feature_netflow" "netflow" {
  for_each = { for device in local.devices : device.name => device if try(
    contains(local.device_config[device.name].system.features, "netflow"),
    contains(local.defaults.nxos.devices.configuration.system.features, "netflow"),
    false
  ) }
  device = each.key
  admin_state = try(
    contains(local.device_config[each.key].system.features, "netflow"),
    contains(local.defaults.nxos.devices.configuration.system.features, "netflow"),
    false
  ) ? "enabled" : "disabled"
}

resource "nxos_feature_nv_overlay" "nv_overlay" {
  for_each = { for device in local.devices : device.name => device }
  device   = each.key
  admin_state = try(
    contains(local.device_config[each.key].system.features, "nv_overlay"),
    contains(local.defaults.nxos.devices.configuration.system.features, "nv_overlay"),
    false
  ) ? "enabled" : "disabled"

  depends_on = [
    nxos_feature_vn_segment.vn_segment
  ]
}

resource "nxos_feature_ospf" "ospf" {
  for_each = { for device in local.devices : device.name => device }
  device   = each.key
  admin_state = try(
    contains(local.device_config[each.key].system.features, "ospf"),
    contains(local.defaults.nxos.devices.configuration.system.features, "ospf"),
    false
  ) ? "enabled" : "disabled"
}

resource "nxos_feature_ospfv3" "ospfv3" {
  for_each = { for device in local.devices : device.name => device }
  device   = each.key
  admin_state = try(
    contains(local.device_config[each.key].system.features, "ospfv3"),
    contains(local.defaults.nxos.devices.configuration.system.features, "ospfv3"),
    false
  ) ? "enabled" : "disabled"
}

resource "nxos_feature_pim" "pim" {
  for_each = { for device in local.devices : device.name => device }
  device   = each.key
  admin_state = try(
    contains(local.device_config[each.key].system.features, "pim"),
    contains(local.defaults.nxos.devices.configuration.system.features, "pim"),
    false
  ) ? "enabled" : "disabled"
}

resource "nxos_feature_ptp" "ptp" {
  for_each = { for device in local.devices : device.name => device }
  device   = each.key
  admin_state = try(
    contains(local.device_config[each.key].system.features, "ptp"),
    contains(local.defaults.nxos.devices.configuration.system.features, "ptp"),
    false
  ) ? "enabled" : "disabled"
}

resource "nxos_feature_pvlan" "pvlan" {
  for_each = { for device in local.devices : device.name => device }
  device   = each.key
  admin_state = try(
    contains(local.device_config[each.key].system.features, "pvlan"),
    contains(local.defaults.nxos.devices.configuration.system.features, "pvlan"),
    false
  ) ? "enabled" : "disabled"
}

resource "nxos_feature_ssh" "ssh" {
  for_each = { for device in local.devices : device.name => device }
  device   = each.key
  admin_state = try(
    contains(local.device_config[each.key].system.features, "ssh"),
    contains(local.defaults.nxos.devices.configuration.system.features, "ssh"),
    false
  ) ? "enabled" : "disabled"
}

resource "nxos_feature_tacacs" "tacacs" {
  for_each = { for device in local.devices : device.name => device }
  device   = each.key
  admin_state = try(
    contains(local.device_config[each.key].system.features, "tacacs"),
    contains(local.defaults.nxos.devices.configuration.system.features, "tacacs"),
    false
  ) ? "enabled" : "disabled"
}

resource "nxos_feature_telnet" "telnet" {
  for_each = { for device in local.devices : device.name => device }
  device   = each.key
  admin_state = try(
    contains(local.device_config[each.key].system.features, "telnet"),
    contains(local.defaults.nxos.devices.configuration.system.features, "telnet"),
    false
  ) ? "enabled" : "disabled"
}

resource "nxos_feature_udld" "udld" {
  for_each = { for device in local.devices : device.name => device }
  device   = each.key
  admin_state = try(
    contains(local.device_config[each.key].system.features, "udld"),
    contains(local.defaults.nxos.devices.configuration.system.features, "udld"),
    false
  ) ? "enabled" : "disabled"
}

resource "nxos_feature_vn_segment" "vn_segment" {
  for_each = { for device in local.devices : device.name => device }
  device   = each.key
  admin_state = try(
    contains(local.device_config[each.key].system.features, "vn_segment"),
    contains(local.defaults.nxos.devices.configuration.system.features, "vn_segment"),
    false
  ) ? "enabled" : "disabled"
}

resource "nxos_feature_vpc" "vpc" {
  for_each = { for device in local.devices : device.name => device }
  device   = each.key
  admin_state = try(
    contains(local.device_config[each.key].system.features, "vpc"),
    contains(local.defaults.nxos.devices.configuration.system.features, "vpc"),
    false
  ) ? "enabled" : "disabled"
}
