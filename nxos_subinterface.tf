resource "nxos_subinterface" "subinterface" {
  for_each = { for device in local.devices : device.name => device
    if length(try(flatten([for int in try(local.device_config[device.name].interfaces.ethernets, []) : try(int.subinterfaces, [])]), [])) > 0 ||
  length(try(flatten([for int in try(local.device_config[device.name].interfaces.port_channels, []) : try(int.subinterfaces, [])]), [])) > 0 }
  device = each.key
  subinterfaces = merge(
    { for sub in flatten([for int in try(local.device_config[each.key].interfaces.ethernets, []) : [
      for s in try(int.subinterfaces, []) : merge(s, { parent_id = "eth${int.id}" })
      ]]) : "${sub.parent_id}.${sub.id}" => {
      admin_state                    = try(sub.admin_state, local.defaults.nxos.devices.configuration.interfaces.ethernets.subinterfaces.admin_state, null) != null ? (try(sub.admin_state, local.defaults.nxos.devices.configuration.interfaces.ethernets.subinterfaces.admin_state) ? "up" : "down") : null
      bandwidth                      = try(sub.bandwidth, local.defaults.nxos.devices.configuration.interfaces.ethernets.subinterfaces.bandwidth, null)
      delay                          = try(sub.delay, local.defaults.nxos.devices.configuration.interfaces.ethernets.subinterfaces.delay, null)
      description                    = try(sub.description, local.defaults.nxos.devices.configuration.interfaces.ethernets.subinterfaces.description, null)
      encap                          = try(sub.encapsulation, local.defaults.nxos.devices.configuration.interfaces.ethernets.subinterfaces.encapsulation, null)
      logging_event_port_link_status = try(sub.logging_event_port_link_status, local.defaults.nxos.devices.configuration.interfaces.ethernets.subinterfaces.logging_event_port_link_status, null) != null ? (try(sub.logging_event_port_link_status, local.defaults.nxos.devices.configuration.interfaces.ethernets.subinterfaces.logging_event_port_link_status) ? "enable" : "disable") : null
      medium                         = try(sub.medium, local.defaults.nxos.devices.configuration.interfaces.ethernets.subinterfaces.medium, null)
      mtu                            = try(sub.mtu, local.defaults.nxos.devices.configuration.interfaces.ethernets.subinterfaces.mtu, null)
      mtu_inherit                    = try(sub.mtu_inherit, local.defaults.nxos.devices.configuration.interfaces.ethernets.subinterfaces.mtu_inherit, null)
      router_mac                     = try(sub.mac, local.defaults.nxos.devices.configuration.interfaces.ethernets.subinterfaces.mac, null)
      router_mac_ipv6_extract        = try(sub.mac_ipv6_extract, local.defaults.nxos.devices.configuration.interfaces.ethernets.subinterfaces.mac_ipv6_extract, null) != null ? (try(sub.mac_ipv6_extract, local.defaults.nxos.devices.configuration.interfaces.ethernets.subinterfaces.mac_ipv6_extract) ? "enable" : "disable") : null
      snmp_trap                      = try(sub.snmp_trap, local.defaults.nxos.devices.configuration.interfaces.ethernets.subinterfaces.snmp_trap, null) != null ? (try(sub.snmp_trap, local.defaults.nxos.devices.configuration.interfaces.ethernets.subinterfaces.snmp_trap) ? "enable" : "disable") : null
      vrf_dn                         = try(sub.vrf, local.defaults.nxos.devices.configuration.interfaces.ethernets.subinterfaces.vrf, null) != null ? "sys/inst-${try(sub.vrf, local.defaults.nxos.devices.configuration.interfaces.ethernets.subinterfaces.vrf)}" : null    } },
    { for sub in flatten([for int in try(local.device_config[each.key].interfaces.port_channels, []) : [
      for s in try(int.subinterfaces, []) : merge(s, { parent_id = "po${int.id}" })
      ]]) : "${sub.parent_id}.${sub.id}" => {
      admin_state                    = try(sub.admin_state, local.defaults.nxos.devices.configuration.interfaces.port_channels.subinterfaces.admin_state, null) != null ? (try(sub.admin_state, local.defaults.nxos.devices.configuration.interfaces.port_channels.subinterfaces.admin_state) ? "up" : "down") : null
      bandwidth                      = try(sub.bandwidth, local.defaults.nxos.devices.configuration.interfaces.port_channels.subinterfaces.bandwidth, null)
      delay                          = try(sub.delay, local.defaults.nxos.devices.configuration.interfaces.port_channels.subinterfaces.delay, null)
      description                    = try(sub.description, local.defaults.nxos.devices.configuration.interfaces.port_channels.subinterfaces.description, null)
      encap                          = try(sub.encapsulation, local.defaults.nxos.devices.configuration.interfaces.port_channels.subinterfaces.encapsulation, null)
      logging_event_port_link_status = try(sub.logging_event_port_link_status, local.defaults.nxos.devices.configuration.interfaces.port_channels.subinterfaces.logging_event_port_link_status, null) != null ? (try(sub.logging_event_port_link_status, local.defaults.nxos.devices.configuration.interfaces.port_channels.subinterfaces.logging_event_port_link_status) ? "enable" : "disable") : null
      medium                         = try(sub.medium, local.defaults.nxos.devices.configuration.interfaces.port_channels.subinterfaces.medium, null)
      mtu                            = try(sub.mtu, local.defaults.nxos.devices.configuration.interfaces.port_channels.subinterfaces.mtu, null)
      mtu_inherit                    = try(sub.mtu_inherit, local.defaults.nxos.devices.configuration.interfaces.port_channels.subinterfaces.mtu_inherit, null)
      router_mac                     = try(sub.mac, local.defaults.nxos.devices.configuration.interfaces.port_channels.subinterfaces.mac, null)
      router_mac_ipv6_extract        = try(sub.mac_ipv6_extract, local.defaults.nxos.devices.configuration.interfaces.port_channels.subinterfaces.mac_ipv6_extract, null) != null ? (try(sub.mac_ipv6_extract, local.defaults.nxos.devices.configuration.interfaces.port_channels.subinterfaces.mac_ipv6_extract) ? "enable" : "disable") : null
      snmp_trap                      = try(sub.snmp_trap, local.defaults.nxos.devices.configuration.interfaces.port_channels.subinterfaces.snmp_trap, null) != null ? (try(sub.snmp_trap, local.defaults.nxos.devices.configuration.interfaces.port_channels.subinterfaces.snmp_trap) ? "enable" : "disable") : null
      vrf_dn                         = try(sub.vrf, local.defaults.nxos.devices.configuration.interfaces.port_channels.subinterfaces.vrf, null) != null ? "sys/inst-${try(sub.vrf, local.defaults.nxos.devices.configuration.interfaces.port_channels.subinterfaces.vrf)}" : null    } },
  )

  depends_on = [
    nxos_physical_interface.physical_interface,
    nxos_port_channel_interface.port_channel_interface,
    nxos_vrf.vrf,
  ]
}
