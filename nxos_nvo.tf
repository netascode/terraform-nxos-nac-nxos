resource "nxos_nvo" "nvo" {
  for_each = { for device in local.devices : device.name => device
    if try(local.device_config[device.name].system.nv_overlay_vxlan_udp_port, null) != null ||
    try(local.device_config[device.name].system.nv_overlay_vxlan_udp_source_port_mode, null) != null ||
  try(local.device_config[device.name].interfaces.nve, null) != null }
  device                     = each.key
  vxlan_udp_port             = try(local.device_config[each.key].system.nv_overlay_vxlan_udp_port, null)
  vxlan_udp_source_port_mode = try(local.device_config[each.key].system.nv_overlay_vxlan_udp_source_port_mode, null)

  nve_interfaces = { for nve_id in try(local.device_config[each.key].interfaces.nve, null) != null ? ["1"] : [] : nve_id => {
    admin_state                        = try(local.device_config[each.key].interfaces.nve.shutdown, false) ? "disabled" : "enabled"
    advertise_virtual_mac              = try(local.device_config[each.key].interfaces.nve.advertise_virtual_rmac, null)
    anycast_source_interface           = try(local.device_config[each.key].interfaces.nve.anycast_bundled_interface_type, null) != null ? "${local.intf_prefix_map[try(local.device_config[each.key].interfaces.nve.anycast_bundled_interface_type)]}${try(local.device_config[each.key].interfaces.nve.anycast_bundled_interface_id, "")}" : null
    configuration_source               = try(local.device_config[each.key].interfaces.nve.configuration_source, null)
    controller_id                      = try(local.device_config[each.key].interfaces.nve.controller_id, null)
    description                        = try(local.device_config[each.key].interfaces.nve.description, null)
    encapsulation_type                 = try(local.device_config[each.key].interfaces.nve.encapsulation_type, null)
    fabric_ready_time                  = try(local.device_config[each.key].interfaces.nve.fabric_convergence_delay, null)
    hold_down_time                     = try(local.device_config[each.key].interfaces.nve.source_interface_hold_down_time, null)
    host_reachability_protocol         = try(local.device_config[each.key].interfaces.nve.host_reachability_protocol, null)
    ingress_replication_protocol_bgp   = try(local.device_config[each.key].interfaces.nve.global_ingress_replication_protocol_bgp, null)
    multicast_group_l2                 = try(local.device_config[each.key].interfaces.nve.global_mcast_group_l2, null)
    multicast_group_l3                 = try(local.device_config[each.key].interfaces.nve.global_mcast_group_l3, null)
    multicast_routing_source_interface = try(local.device_config[each.key].interfaces.nve.multicast_routing_source_interface_type, null) != null ? "${local.intf_prefix_map[try(local.device_config[each.key].interfaces.nve.multicast_routing_source_interface_type)]}${try(local.device_config[each.key].interfaces.nve.multicast_routing_source_interface_id, "")}" : null
    multisite_source_interface         = try(local.device_config[each.key].interfaces.nve.multisite_border_gateway_interface_type, null) != null ? "${local.intf_prefix_map[try(local.device_config[each.key].interfaces.nve.multisite_border_gateway_interface_type)]}${try(local.device_config[each.key].interfaces.nve.multisite_border_gateway_interface_id, "")}" : null
    multisite_virtual_mac              = try(local.device_config[each.key].interfaces.nve.multisite_virtual_rmac, null)
    source_interface                   = try(local.device_config[each.key].interfaces.nve.source_interface_type, null) != null ? "${local.intf_prefix_map[try(local.device_config[each.key].interfaces.nve.source_interface_type)]}${try(local.device_config[each.key].interfaces.nve.source_interface_id, "")}" : null
    suppress_arp                       = try(local.device_config[each.key].interfaces.nve.global_suppress_arp, null)
    suppress_mac_route                 = try(local.device_config[each.key].interfaces.nve.suppress_mac_route, null)
    suppress_nd                        = try(local.device_config[each.key].interfaces.nve.suppress_nd, null)
    virtual_mac                        = try(local.device_config[each.key].interfaces.nve.virtual_rmac, null)

    vnis = { for vni in try(local.device_config[each.key].interfaces.nve.vnis, []) : vni.vni => {
      associate_vrf                 = try(vni.associate_vrf, null)
      multicast_group               = try(vni.mcast_group, null)
      multisite_ingress_replication = try(vni.multisite_ingress_replication, null)
      multisite_multicast_group     = try(vni.multisite_mcast_group, null)
      spine_anycast_gateway         = try(vni.spine_anycast_gateway, null)
      suppress_arp                  = try(vni.suppress_arp, null) == null ? null : (try(vni.suppress_arp) ? "enabled" : "disabled")

      ingress_replication_protocol = try(vni.ingress_replication_protocol, null)
    } }
  } }

  depends_on = [
    nxos_bridge_domain.bridge_domain,
    nxos_evpn.evpn,
    nxos_feature.feature,
    nxos_loopback_interface.loopback_interface,
  ]
}
