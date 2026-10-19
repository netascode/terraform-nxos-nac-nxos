locals {
  multisite_ingress_replication_map = {
    "optimized" = "enableOptimized"
  }
  host_reachability_protocol_map = {
    "flood-and-learn" = "Flood-and-learn"
    "openflow-ir"     = "openflowIR"
  }
  evpn_multihoming_df_election_mode_map = {
    "per-flow" = "perFlow"
    "modulo"   = "modulo"
  }
  evpn_storm_control_name_map = {
    "broadcast_level" = "bcast"
    "multicast_level" = "mcast"
    "unicast_level"   = "ucast"
  }
}

resource "nxos_nvo" "nvo" {
  for_each = { for device in local.devices : device.name => device
    if try(local.device_config[device.name].system.nv_overlay_vxlan_udp_port, null) != null ||
    try(local.device_config[device.name].system.nv_overlay_vxlan_udp_source_port_mode, null) != null ||
    try(local.device_config[device.name].evpn.multisite_border_gateway, null) != null ||
    try(local.device_config[device.name].evpn.storm_control, null) != null ||
    try(local.device_config[device.name].evpn.multihoming, null) != null ||
    try(local.device_config[device.name].system.advertise_evpn_multicast, null) != null ||
  try(local.device_config[device.name].interfaces.nve, null) != null }
  device                     = each.key
  vxlan_udp_port             = try(local.device_config[each.key].system.nv_overlay_vxlan_udp_port, null)
  vxlan_udp_source_port_mode = try(local.device_config[each.key].system.nv_overlay_vxlan_udp_source_port_mode, null)

  advertise_evpn_multicast_state = try(local.device_config[each.key].system.advertise_evpn_multicast, null) == true ? "enabled" : null

  evpn_multisite_border_gateway_site_id                = try(local.device_config[each.key].evpn.multisite_border_gateway.site_id, null)
  evpn_multisite_border_gateway_state                  = try(local.device_config[each.key].evpn.multisite_border_gateway.site_id, null) != null ? "enabled" : null
  evpn_multisite_border_gateway_dci_advertise_pip      = try(local.device_config[each.key].evpn.multisite_border_gateway.dci_advertise_pip, null) == null ? null : (try(local.device_config[each.key].evpn.multisite_border_gateway.dci_advertise_pip) ? "enable" : "disable")
  evpn_multisite_border_gateway_delay_restore_time     = try(local.device_config[each.key].evpn.multisite_border_gateway.delay_restore_time, null)
  evpn_multisite_border_gateway_df_election_time       = try(local.device_config[each.key].evpn.multisite_border_gateway.df_election_time, null) == null ? null : format("%f", local.device_config[each.key].evpn.multisite_border_gateway.df_election_time)
  evpn_multisite_border_gateway_fabric_advertise_pip   = try(local.device_config[each.key].evpn.multisite_border_gateway.fabric_advertise_pip, null) == null ? null : (try(local.device_config[each.key].evpn.multisite_border_gateway.fabric_advertise_pip) ? "enableL3" : "disable")
  evpn_multisite_border_gateway_split_horizon_per_site = try(local.device_config[each.key].evpn.multisite_border_gateway.split_horizon_per_site, null) == null ? null : (try(local.device_config[each.key].evpn.multisite_border_gateway.split_horizon_per_site) ? "enable" : "disable")

  evpn_storm_controls = anytrue([for attr, name in local.evpn_storm_control_name_map : try(local.device_config[each.key].evpn.storm_control[attr], null) != null]) ? {
    for attr, name in local.evpn_storm_control_name_map : name => {
      level = format("%f", local.device_config[each.key].evpn.storm_control[attr])
    } if try(local.device_config[each.key].evpn.storm_control[attr], null) != null
  } : null

  nve_interfaces = try(local.device_config[each.key].interfaces.nve, null) != null ? { for nve_id in ["1"] : nve_id => {
    admin_state                        = try(local.device_config[each.key].interfaces.nve.shutdown, null) == null ? "enabled" : (try(local.device_config[each.key].interfaces.nve.shutdown) ? "disabled" : "enabled")
    advertise_virtual_mac              = try(local.device_config[each.key].interfaces.nve.advertise_virtual_rmac, null)
    anycast_source_interface           = try(local.device_config[each.key].interfaces.nve.anycast_source_interface_type, null) != null ? "${local.intf_prefix_map[try(local.device_config[each.key].interfaces.nve.anycast_source_interface_type)]}${try(local.device_config[each.key].interfaces.nve.anycast_source_interface_id, "")}" : null
    description                        = try(local.device_config[each.key].interfaces.nve.description, null)
    fabric_ready_time                  = try(local.device_config[each.key].interfaces.nve.fabric_ready_time, null)
    hold_down_time                     = try(local.device_config[each.key].interfaces.nve.source_interface_hold_down_time, null)
    host_reachability_protocol         = try(local.host_reachability_protocol_map[try(local.device_config[each.key].interfaces.nve.host_reachability_protocol)], try(local.device_config[each.key].interfaces.nve.host_reachability_protocol, null))
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

    vnis = length(try(local.device_config[each.key].interfaces.nve.vnis, [])) > 0 ? { for vni in try(local.device_config[each.key].interfaces.nve.vnis, []) : vni.vni => {
      associate_vrf                 = try(vni.associate_vrf, null)
      multicast_group               = try(vni.mcast_group, null)
      multisite_ingress_replication = try(local.multisite_ingress_replication_map[vni.multisite_ingress_replication], vni.multisite_ingress_replication, null)
      multisite_multicast_group     = try(vni.multisite_mcast_group, null)
      spine_anycast_gateway         = try(vni.spine_anycast_gateway, null)
      suppress_arp                  = try(vni.suppress_arp, null) == null ? null : (try(vni.suppress_arp) ? "enabled" : "disabled")

      ingress_replication_protocol = try(vni.ingress_replication_protocol, null)
    } } : null
  } } : null

  depends_on = [
    nxos_cli.cli_pre_9,
    nxos_bridge_domain.bridge_domain,
    nxos_evpn.evpn,
    nxos_feature.feature,
    nxos_loopback_interface.loopback_interface,
  ]
}

# EVPN multihoming must be enabled before interfaces use core tracking, while the main instance depends on the interfaces.
# The reset deletion policy keeps this instance from deleting the other sys/eps child objects on destroy.
resource "nxos_nvo" "evpn_multihoming" {
  for_each = { for device in local.devices : device.name => device
  if try(local.device_config[device.name].evpn.multihoming, null) != null }
  device          = each.key
  deletion_policy = "reset"

  evpn_multihoming_state                 = try(local.device_config[each.key].evpn.multihoming.enabled, null) == null ? null : (try(local.device_config[each.key].evpn.multihoming.enabled) ? "enabled" : "disabled")
  evpn_multihoming_system_mac            = try(local.device_config[each.key].evpn.multihoming.system_mac, null) == null ? null : upper(join(":", regexall("[0-9A-Fa-f]{2}", replace(local.device_config[each.key].evpn.multihoming.system_mac, "/[^0-9A-Fa-f]/", ""))))
  evpn_multihoming_df_election_mode      = try(local.evpn_multihoming_df_election_mode_map[local.device_config[each.key].evpn.multihoming.df_election_mode], null)
  evpn_multihoming_df_election_time      = try(local.device_config[each.key].evpn.multihoming.df_election_time, null) == null ? null : format("%f", local.device_config[each.key].evpn.multihoming.df_election_time)
  evpn_multihoming_ead_evi_route         = try(local.device_config[each.key].evpn.multihoming.ead_evi_route, null)
  evpn_multihoming_delay_restore_time    = try(local.device_config[each.key].evpn.multihoming.ethernet_segment_delay_restore_time, null)
  evpn_multihoming_frr_anycast_source_ip = try(local.device_config[each.key].evpn.multihoming.frr_anycast_source_ip, null)

  depends_on = [
    nxos_cli.cli_pre_9,
    nxos_feature.feature,
  ]
}
