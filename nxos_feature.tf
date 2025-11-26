resource "nxos_feature_bfd" "bfd" {
  for_each    = { for device in local.devices : device.name => device if try(local.device_config[device.name].system.feature.bfd, local.defaults.nxos.devices.configuration.system.feature.bfd, null) != null }
  device      = each.key
  admin_state = try(local.device_config[each.key].system.feature.bfd, local.defaults.nxos.devices.configuration.system.feature.bfd) ? "enabled" : "disabled"
}

resource "nxos_feature_bgp" "bgp" {
  for_each    = { for device in local.devices : device.name => device if try(local.device_config[device.name].system.feature.bgp, local.defaults.nxos.devices.configuration.system.feature.bgp, null) != null }
  device      = each.key
  admin_state = try(local.device_config[each.key].system.feature.bgp, local.defaults.nxos.devices.configuration.system.feature.bgp) ? "enabled" : "disabled"
}

resource "nxos_feature_dhcp" "dhcp" {
  for_each    = { for device in local.devices : device.name => device if try(local.device_config[device.name].system.feature.dhcp, local.defaults.nxos.devices.configuration.system.feature.dhcp, null) != null }
  device      = each.key
  admin_state = try(local.device_config[each.key].system.feature.dhcp, local.defaults.nxos.devices.configuration.system.feature.dhcp) ? "enabled" : "disabled"
}

resource "nxos_feature_evpn" "evpn" {
  for_each    = { for device in local.devices : device.name => device if try(local.device_config[device.name].system.feature.evpn, local.defaults.nxos.devices.configuration.system.feature.evpn, null) != null }
  device      = each.key
  admin_state = try(local.device_config[each.key].system.feature.evpn, local.defaults.nxos.devices.configuration.system.feature.evpn) ? "enabled" : "disabled"
}

resource "nxos_feature_hmm" "fabric_forwarding" {
  for_each    = { for device in local.devices : device.name => device if try(local.device_config[device.name].system.feature.fabric_forwarding, local.defaults.nxos.devices.configuration.system.feature.fabric_forwarding, null) != null }
  device      = each.key
  admin_state = try(local.device_config[each.key].system.feature.fabric_forwarding, local.defaults.nxos.devices.configuration.system.feature.fabric_forwarding) ? "enabled" : "disabled"
}

resource "nxos_feature_hsrp" "hsrp" {
  for_each    = { for device in local.devices : device.name => device if try(local.device_config[device.name].system.feature.hsrp, local.defaults.nxos.devices.configuration.system.feature.hsrp, null) != null }
  device      = each.key
  admin_state = try(local.device_config[each.key].system.feature.hsrp, local.defaults.nxos.devices.configuration.system.feature.hsrp) ? "enabled" : "disabled"
}

resource "nxos_feature_interface_vlan" "interface_vlan" {
  for_each    = { for device in local.devices : device.name => device if try(local.device_config[device.name].system.feature.interface_vlan, local.defaults.nxos.devices.configuration.system.feature.interface_vlan, null) != null }
  device      = each.key
  admin_state = try(local.device_config[each.key].system.feature.interface_vlan, local.defaults.nxos.devices.configuration.system.feature.interface_vlan) ? "enabled" : "disabled"
}

resource "nxos_feature_isis" "isis" {
  for_each    = { for device in local.devices : device.name => device if try(local.device_config[device.name].system.feature.isis, local.defaults.nxos.devices.configuration.system.feature.isis, null) != null }
  device      = each.key
  admin_state = try(local.device_config[each.key].system.feature.isis, local.defaults.nxos.devices.configuration.system.feature.isis) ? "enabled" : "disabled"
}

resource "nxos_feature_lacp" "lacp" {
  for_each    = { for device in local.devices : device.name => device if try(local.device_config[device.name].system.feature.lacp, local.defaults.nxos.devices.configuration.system.feature.lacp, null) != null }
  device      = each.key
  admin_state = try(local.device_config[each.key].system.feature.lacp, local.defaults.nxos.devices.configuration.system.feature.lacp) ? "enabled" : "disabled"
}

resource "nxos_feature_lldp" "lldp" {
  for_each    = { for device in local.devices : device.name => device if try(local.device_config[device.name].system.feature.lldp, local.defaults.nxos.devices.configuration.system.feature.lldp, null) != null }
  device      = each.key
  admin_state = try(local.device_config[each.key].system.feature.lldp, local.defaults.nxos.devices.configuration.system.feature.lldp) ? "enabled" : "disabled"
}

resource "nxos_feature_macsec" "macsec" {
  for_each    = { for device in local.devices : device.name => device if try(local.device_config[device.name].system.feature.macsec, local.defaults.nxos.devices.configuration.system.feature.macsec, null) != null }
  device      = each.key
  admin_state = try(local.device_config[each.key].system.feature.macsec, local.defaults.nxos.devices.configuration.system.feature.macsec) ? "enabled" : "disabled"
}

resource "nxos_feature_netflow" "netflow" {
  for_each    = { for device in local.devices : device.name => device if try(local.device_config[device.name].system.feature.netflow, local.defaults.nxos.devices.configuration.system.feature.netflow, null) != null }
  device      = each.key
  admin_state = try(local.device_config[each.key].system.feature.netflow, local.defaults.nxos.devices.configuration.system.feature.netflow) ? "enabled" : "disabled"
}

resource "nxos_feature_nv_overlay" "nv_overlay" {
  for_each    = { for device in local.devices : device.name => device if try(local.device_config[device.name].system.feature.nv_overlay, local.defaults.nxos.devices.configuration.system.feature.nv_overlay, null) != null }
  device      = each.key
  admin_state = try(local.device_config[each.key].system.feature.nv_overlay, local.defaults.nxos.devices.configuration.system.feature.nv_overlay) ? "enabled" : "disabled"

  depends_on = [
    nxos_feature_vn_segment.vn_segment
  ]
}

resource "nxos_feature_ospf" "ospf" {
  for_each    = { for device in local.devices : device.name => device if try(local.device_config[device.name].system.feature.ospf, local.defaults.nxos.devices.configuration.system.feature.ospf, null) != null }
  device      = each.key
  admin_state = try(local.device_config[each.key].system.feature.ospf, local.defaults.nxos.devices.configuration.system.feature.ospf) ? "enabled" : "disabled"
}

resource "nxos_feature_ospfv3" "ospfv3" {
  for_each    = { for device in local.devices : device.name => device if try(local.device_config[device.name].system.feature.ospfv3, local.defaults.nxos.devices.configuration.system.feature.ospfv3, null) != null }
  device      = each.key
  admin_state = try(local.device_config[each.key].system.feature.ospfv3, local.defaults.nxos.devices.configuration.system.feature.ospfv3) ? "enabled" : "disabled"
}

resource "nxos_feature_pim" "pim" {
  for_each    = { for device in local.devices : device.name => device if try(local.device_config[device.name].system.feature.pim, local.defaults.nxos.devices.configuration.system.feature.pim, null) != null }
  device      = each.key
  admin_state = try(local.device_config[each.key].system.feature.pim, local.defaults.nxos.devices.configuration.system.feature.pim) ? "enabled" : "disabled"
}

resource "nxos_feature_ptp" "ptp" {
  for_each    = { for device in local.devices : device.name => device if try(local.device_config[device.name].system.feature.ptp, local.defaults.nxos.devices.configuration.system.feature.ptp, null) != null }
  device      = each.key
  admin_state = try(local.device_config[each.key].system.feature.ptp, local.defaults.nxos.devices.configuration.system.feature.ptp) ? "enabled" : "disabled"
}

resource "nxos_feature_pvlan" "pvlan" {
  for_each    = { for device in local.devices : device.name => device if try(local.device_config[device.name].system.feature.pvlan, local.defaults.nxos.devices.configuration.system.feature.pvlan, null) != null }
  device      = each.key
  admin_state = try(local.device_config[each.key].system.feature.pvlan, local.defaults.nxos.devices.configuration.system.feature.pvlan) ? "enabled" : "disabled"
}

resource "nxos_feature_ssh" "ssh" {
  for_each    = { for device in local.devices : device.name => device if try(local.device_config[device.name].system.feature.ssh, local.defaults.nxos.devices.configuration.system.feature.ssh, null) != null }
  device      = each.key
  admin_state = try(local.device_config[each.key].system.feature.ssh, local.defaults.nxos.devices.configuration.system.feature.ssh) ? "enabled" : "disabled"
}

resource "nxos_feature_tacacs" "tacacs" {
  for_each    = { for device in local.devices : device.name => device if try(local.device_config[device.name].system.feature.tacacs, local.defaults.nxos.devices.configuration.system.feature.tacacs, null) != null }
  device      = each.key
  admin_state = try(local.device_config[each.key].system.feature.tacacs, local.defaults.nxos.devices.configuration.system.feature.tacacs) ? "enabled" : "disabled"
}

resource "nxos_feature_telnet" "telnet" {
  for_each    = { for device in local.devices : device.name => device if try(local.device_config[device.name].system.feature.telnet, local.defaults.nxos.devices.configuration.system.feature.telnet, null) != null }
  device      = each.key
  admin_state = try(local.device_config[each.key].system.feature.telnet, local.defaults.nxos.devices.configuration.system.feature.telnet) ? "enabled" : "disabled"
}

resource "nxos_feature_udld" "udld" {
  for_each    = { for device in local.devices : device.name => device if try(local.device_config[device.name].system.feature.udld, local.defaults.nxos.devices.configuration.system.feature.udld, null) != null }
  device      = each.key
  admin_state = try(local.device_config[each.key].system.feature.udld, local.defaults.nxos.devices.configuration.system.feature.udld) ? "enabled" : "disabled"
}

resource "nxos_feature_vn_segment" "vn_segment" {
  for_each    = { for device in local.devices : device.name => device if try(local.device_config[device.name].system.feature.vn_segment, local.defaults.nxos.devices.configuration.system.feature.vn_segment, null) != null }
  device      = each.key
  admin_state = try(local.device_config[each.key].system.feature.vn_segment, local.defaults.nxos.devices.configuration.system.feature.vn_segment) ? "enabled" : "disabled"
}

resource "nxos_feature_vpc" "vpc" {
  for_each    = { for device in local.devices : device.name => device if try(local.device_config[device.name].system.feature.vpc, local.defaults.nxos.devices.configuration.system.feature.vpc, null) != null }
  device      = each.key
  admin_state = try(local.device_config[each.key].system.feature.vpc, local.defaults.nxos.devices.configuration.system.feature.vpc) ? "enabled" : "disabled"
}
