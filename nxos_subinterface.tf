resource "nxos_subinterface" "subinterface" {
  for_each = { for device in local.devices : device.name => device
    if length(try(flatten([for int in try(local.device_config[device.name].interfaces.ethernets, []) : try(int.subinterfaces, [])]), [])) > 0 ||
  length(try(flatten([for int in try(local.device_config[device.name].interfaces.port_channels, []) : try(int.subinterfaces, [])]), [])) > 0 }
  device = each.key
  subinterfaces = merge(
    { for sub in flatten([for int in try(local.device_config[each.key].interfaces.ethernets, []) : [
      for s in try(int.subinterfaces, []) : merge(s, { parent_id = "eth${int.id}" })
      ]]) : "${sub.parent_id}.${sub.id}" => {
      admin_state             = try(sub.shutdown, null) != null ? (try(sub.shutdown) ? "down" : "up") : null
      bandwidth               = try(sub.bandwidth, null)
      delay                   = try(sub.delay, null)
      description             = try(sub.description, null)
      encap                   = try(sub.encapsulation, null)
      link_logging            = try(sub.logging_event_port_link_status, null) != null ? (try(sub.logging_event_port_link_status) ? "enable" : "disable") : null
      medium                  = try(sub.medium, null)
      mtu                     = try(sub.mtu, null)
      mtu_inherit             = try(sub.mtu_inherit, null)
      router_mac              = try(sub.mac_address, null)
      router_mac_ipv6_extract = try(sub.mac_ipv6_extract, null) != null ? (try(sub.mac_ipv6_extract) ? "enable" : "disable") : null
      snmp_trap               = try(sub.snmp_trap_link_status, null) != null ? (try(sub.snmp_trap_link_status) ? "enable" : "disable") : null
      vrf_dn                  = try(sub.vrf, null) != null ? "sys/inst-${try(sub.vrf)}" : null
      } }, { for sub in flatten([for int in try(local.device_config[each.key].interfaces.port_channels, []) : [
        for s in try(int.subinterfaces, []) : merge(s, { parent_id = "po${int.id}" })
      ]]) : "${sub.parent_id}.${sub.id}" => {
      admin_state             = try(sub.shutdown, null) != null ? (try(sub.shutdown) ? "down" : "up") : null
      bandwidth               = try(sub.bandwidth, null)
      delay                   = try(sub.delay, null)
      description             = try(sub.description, null)
      encap                   = try(sub.encapsulation, null)
      link_logging            = try(sub.logging_event_port_link_status, null) != null ? (try(sub.logging_event_port_link_status) ? "enable" : "disable") : null
      medium                  = try(sub.medium, null)
      mtu                     = try(sub.mtu, null)
      mtu_inherit             = try(sub.mtu_inherit, null)
      router_mac              = try(sub.mac_address, null)
      router_mac_ipv6_extract = try(sub.mac_ipv6_extract, null) != null ? (try(sub.mac_ipv6_extract) ? "enable" : "disable") : null
      snmp_trap               = try(sub.snmp_trap_link_status, null) != null ? (try(sub.snmp_trap_link_status) ? "enable" : "disable") : null
      vrf_dn                  = try(sub.vrf, null) != null ? "sys/inst-${try(sub.vrf)}" : null
  } }, )

  depends_on = [
    nxos_physical_interface.physical_interface,
    nxos_port_channel_interface.port_channel_interface,
    nxos_vrf.vrf,
  ]
}
