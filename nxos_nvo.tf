resource "nxos_nvo" "nvo" {
  for_each = { for device in local.devices : device.name => device
    if try(local.device_config[device.name].system.nv_overlay_vxlan_udp_port, local.defaults.nxos.devices.configuration.system.nv_overlay_vxlan_udp_port, null) != null ||
    try(local.device_config[device.name].system.nv_overlay_vxlan_udp_source_port_mode, local.defaults.nxos.devices.configuration.system.nv_overlay_vxlan_udp_source_port_mode, null) != null ||
  try(local.device_config[device.name].interfaces.nve, null) != null }
  device                     = each.key
  vxlan_udp_port             = try(local.device_config[each.key].system.nv_overlay_vxlan_udp_port, local.defaults.nxos.devices.configuration.system.nv_overlay_vxlan_udp_port, null)
  vxlan_udp_source_port_mode = try(local.device_config[each.key].system.nv_overlay_vxlan_udp_source_port_mode, local.defaults.nxos.devices.configuration.system.nv_overlay_vxlan_udp_source_port_mode, null)

  nve_interfaces = { for nve_id in try(local.device_config[each.key].interfaces.nve, null) != null ? ["1"] : [] : nve_id => {
    admin_state                        = try(local.device_config[each.key].interfaces.nve.admin_state, local.defaults.nxos.devices.configuration.interfaces.nve.admin_state, false) ? "enabled" : "disabled"
    advertise_virtual_mac              = try(local.device_config[each.key].interfaces.nve.advertise_virtual_mac, local.defaults.nxos.devices.configuration.interfaces.nve.advertise_virtual_mac, null)
    anycast_source_interface           = try(local.device_config[each.key].interfaces.nve.anycast_source_interface, local.defaults.nxos.devices.configuration.interfaces.nve.anycast_source_interface, null)
    configuration_source               = try(local.device_config[each.key].interfaces.nve.configuration_source, local.defaults.nxos.devices.configuration.interfaces.nve.configuration_source, null)
    controller_id                      = try(local.device_config[each.key].interfaces.nve.controller_id, local.defaults.nxos.devices.configuration.interfaces.nve.controller_id, null)
    description                        = try(local.device_config[each.key].interfaces.nve.description, local.defaults.nxos.devices.configuration.interfaces.nve.description, null)
    encapsulation_type                 = try(local.device_config[each.key].interfaces.nve.encapsulation_type, local.defaults.nxos.devices.configuration.interfaces.nve.encapsulation_type, null)
    fabric_ready_time                  = try(local.device_config[each.key].interfaces.nve.fabric_ready_time, local.defaults.nxos.devices.configuration.interfaces.nve.fabric_ready_time, null)
    hold_down_time                     = try(local.device_config[each.key].interfaces.nve.hold_down_time, local.defaults.nxos.devices.configuration.interfaces.nve.hold_down_time, null)
    host_reachability_protocol         = try(local.device_config[each.key].interfaces.nve.host_reachability_protocol, local.defaults.nxos.devices.configuration.interfaces.nve.host_reachability_protocol, null)
    ingress_replication_protocol_bgp   = try(local.device_config[each.key].interfaces.nve.ingress_replication_protocol_bgp, local.defaults.nxos.devices.configuration.interfaces.nve.ingress_replication_protocol_bgp, null)
    multicast_group_l2                 = try(local.device_config[each.key].interfaces.nve.multicast_group_l2, local.defaults.nxos.devices.configuration.interfaces.nve.multicast_group_l2, null)
    multicast_group_l3                 = try(local.device_config[each.key].interfaces.nve.multicast_group_l3, local.defaults.nxos.devices.configuration.interfaces.nve.multicast_group_l3, null)
    multicast_routing_source_interface = try(local.device_config[each.key].interfaces.nve.multicast_routing_source_interface, local.defaults.nxos.devices.configuration.interfaces.nve.multicast_routing_source_interface, null)
    multisite_source_interface         = try(local.device_config[each.key].interfaces.nve.multisite_source_interface, local.defaults.nxos.devices.configuration.interfaces.nve.multisite_source_interface, null)
    multisite_virtual_mac              = try(local.device_config[each.key].interfaces.nve.multisite_virtual_mac, local.defaults.nxos.devices.configuration.interfaces.nve.multisite_virtual_mac, null)
    source_interface                   = try(local.device_config[each.key].interfaces.nve.source_interface, local.defaults.nxos.devices.configuration.interfaces.nve.source_interface, null)
    suppress_arp                       = try(local.device_config[each.key].interfaces.nve.suppress_arp, local.defaults.nxos.devices.configuration.interfaces.nve.suppress_arp, null)
    suppress_mac_route                 = try(local.device_config[each.key].interfaces.nve.suppress_mac_route, local.defaults.nxos.devices.configuration.interfaces.nve.suppress_mac_route, null)
    suppress_nd                        = try(local.device_config[each.key].interfaces.nve.suppress_nd, local.defaults.nxos.devices.configuration.interfaces.nve.suppress_nd, null)
    virtual_mac                        = try(local.device_config[each.key].interfaces.nve.virtual_mac, local.defaults.nxos.devices.configuration.interfaces.nve.virtual_mac, null)

    vnis = { for vni in try(local.device_config[each.key].interfaces.nve.vnis, []) : vni.vni => {
      associate_vrf                 = try(vni.associate_vrf, local.defaults.nxos.devices.configuration.interfaces.nve.vnis.associate_vrf, null)
      legacy_mode                   = try(vni.legacy_mode, local.defaults.nxos.devices.configuration.interfaces.nve.vnis.legacy_mode, null)
      multicast_group               = try(vni.multicast_group, local.defaults.nxos.devices.configuration.interfaces.nve.vnis.multicast_group, null)
      multisite_ingress_replication = try(vni.multisite_ingress_replication, local.defaults.nxos.devices.configuration.interfaces.nve.vnis.multisite_ingress_replication, null)
      multisite_multicast_group     = try(vni.multisite_multicast_group, local.defaults.nxos.devices.configuration.interfaces.nve.vnis.multisite_multicast_group, null)
      spine_anycast_gateway         = try(vni.spine_anycast_gateway, local.defaults.nxos.devices.configuration.interfaces.nve.vnis.spine_anycast_gateway, null)
      suppress_arp                  = try(vni.suppress_arp, local.defaults.nxos.devices.configuration.interfaces.nve.vnis.suppress_arp, null)

      ingress_replication_protocol = try(vni.ingress_replication_protocol, local.defaults.nxos.devices.configuration.interfaces.nve.vnis.ingress_replication_protocol, null)
    } }
  } }

  depends_on = [
    nxos_bridge_domain.bridge_domain,
    nxos_evpn.evpn,
    nxos_feature.feature,
    nxos_loopback_interface.loopback_interface,
  ]
}
