locals {
  log_event_map = {
    "link-status-default"  = "linkStatusDefault"
    "link-status-enable"   = "linkStatusEnable"
    "none"                 = "none"
    "trunk-status-default" = "trunkStatusDefault"
    "trunk-status-enable"  = "trunkStatusEnable"
  }

  nd_interfaces = flatten([
    for device in local.devices : concat(
      [for int in try(local.device_config[device.name].interfaces.vlans, []) : {
        device       = device.name
        vrf          = try(int.vrf, "default")
        interface_id = "vlan${int.id}"
        nd           = try(int.nd, {})
      } if try(int.nd, null) != null],
      [for int in try(local.device_config[device.name].interfaces.loopbacks, []) : {
        device       = device.name
        vrf          = try(int.vrf, "default")
        interface_id = "lo${int.id}"
        nd           = try(int.nd, {})
      } if try(int.nd, null) != null],
      [for int in try(local.device_config[device.name].interfaces.ethernets, []) : {
        device       = device.name
        vrf          = try(int.vrf, "default")
        interface_id = "eth${int.id}"
        nd           = try(int.nd, {})
      } if try(int.nd, null) != null],
      [for int in try(local.device_config[device.name].interfaces.port_channels, []) : {
        device       = device.name
        vrf          = try(int.vrf, "default")
        interface_id = "po${int.id}"
        nd           = try(int.nd, {})
      } if try(int.nd, null) != null],
    )
  ])

  nd_interfaces_by_device = { for entry in local.nd_interfaces : entry.device => entry... }

  nd_vrfs_by_device = { for device_name, entries in local.nd_interfaces_by_device : device_name => {
    for vrf in distinct([for e in entries : e.vrf]) : vrf => {
      interfaces = { for e in entries : e.interface_id => e.nd if e.vrf == vrf }
    }
  } }

  nd_control_values = {
    "redirects"       = "redirects"
    "managed_cfg"     = "managed-cfg"
    "other_cfg"       = "other-cfg"
    "suppress_ra"     = "suppress-ra"
    "suppress_ra_mtu" = "suppress-ra-mtu"
  }
}

resource "nxos_system" "system" {
  for_each = { for device in local.devices : device.name => device
    if try(local.device_config[device.name].system.hostname, local.defaults.nxos.devices.configuration.system.hostname, null) != null ||
    try(local.device_config[device.name].system.mtu, local.defaults.nxos.devices.configuration.system.mtu, null) != null ||
    try(local.device_config[device.name].system.ethernet, null) != null ||
    try(local.device_config[device.name].arp, null) != null ||
    try(local.device_config[device.name].system.ipv6_nd, null) != null ||
  length(try(local.nd_interfaces_by_device[device.name], [])) > 0 }
  device = each.key

  # topSystem attributes
  name = try(local.device_config[each.key].system.hostname, local.defaults.nxos.devices.configuration.system.hostname, null)

  # ethpmInst attributes (ethernet)
  ethernet_mtu                                  = try(local.device_config[each.key].system.mtu, local.defaults.nxos.devices.configuration.system.mtu, null)
  ethernet_default_admin_state                  = try(local.device_config[each.key].system.ethernet.default_switchport_shutdown, local.defaults.nxos.devices.configuration.system.ethernet.default_switchport_shutdown, null) != null ? (try(local.device_config[each.key].system.ethernet.default_switchport_shutdown, local.defaults.nxos.devices.configuration.system.ethernet.default_switchport_shutdown) ? "down" : "up") : null
  ethernet_admin_link_down_syslog_level         = try(local.device_config[each.key].system.ethernet.admin_link_down_syslog_level, local.defaults.nxos.devices.configuration.system.ethernet.admin_link_down_syslog_level, null)
  ethernet_admin_link_up_syslog_level           = try(local.device_config[each.key].system.ethernet.admin_link_up_syslog_level, local.defaults.nxos.devices.configuration.system.ethernet.admin_link_up_syslog_level, null)
  ethernet_allow_unsupported_sfp                = try(local.device_config[each.key].system.ethernet.service_unsupported_transceiver, local.defaults.nxos.devices.configuration.system.ethernet.service_unsupported_transceiver, null)
  ethernet_interface_syslog_info                = try(local.device_config[each.key].system.ethernet.interface_syslog_info, local.defaults.nxos.devices.configuration.system.ethernet.interface_syslog_info, null)
  ethernet_log_event                            = try(local.device_config[each.key].system.ethernet.logging_event_port, local.defaults.nxos.devices.configuration.system.ethernet.logging_event_port, null) != null ? try(local.log_event_map[try(local.device_config[each.key].system.ethernet.logging_event_port, local.defaults.nxos.devices.configuration.system.ethernet.logging_event_port)], null) : null
  ethernet_default_layer                        = try(local.device_config[each.key].system.ethernet.default_switchport, local.defaults.nxos.devices.configuration.system.ethernet.default_switchport, null)
  ethernet_system_interface_admin_state         = try(local.device_config[each.key].system.ethernet.default_interface_shutdown, local.defaults.nxos.devices.configuration.system.ethernet.default_interface_shutdown, null)
  ethernet_system_link_failure_laser_on         = try(local.device_config[each.key].system.ethernet.link_failure_laser_on, local.defaults.nxos.devices.configuration.system.ethernet.link_failure_laser_on, null)
  ethernet_system_storm_control_multi_threshold = try(local.device_config[each.key].system.ethernet.storm_control_multicast, local.defaults.nxos.devices.configuration.system.ethernet.storm_control_multicast, null)
  ethernet_vlan_tag_native                      = try(local.device_config[each.key].system.ethernet.dot1q_tag_native, local.defaults.nxos.devices.configuration.system.ethernet.dot1q_tag_native, null)

  # arpEntity / arpInst attributes
  arp_admin_state                         = "enabled"
  arp_instance_admin_state                = "enabled"
  arp_allow_static_arp_outside_subnet     = try(local.device_config[each.key].arp.allow_static_arp_outside_subnet, local.defaults.nxos.devices.configuration.arp.allow_static_arp_outside_subnet, null) != null ? (try(local.device_config[each.key].arp.allow_static_arp_outside_subnet, local.defaults.nxos.devices.configuration.arp.allow_static_arp_outside_subnet) ? "enabled" : "disabled") : null
  arp_unnumbered_svi_software_replication = try(local.device_config[each.key].arp.unnumbered_svi_software_replication, local.defaults.nxos.devices.configuration.arp.unnumbered_svi_software_replication, null) != null ? (try(local.device_config[each.key].arp.unnumbered_svi_software_replication, local.defaults.nxos.devices.configuration.arp.unnumbered_svi_software_replication) ? "enabled" : "disabled") : null
  arp_cache_limit                         = try(local.device_config[each.key].arp.cache_limit, local.defaults.nxos.devices.configuration.arp.cache_limit, null)
  arp_cache_syslog_rate                   = try(local.device_config[each.key].arp.cache_syslog_rate, local.defaults.nxos.devices.configuration.arp.cache_syslog_rate, null)
  arp_evpn_timeout                        = try(local.device_config[each.key].arp.evpn_timeout, local.defaults.nxos.devices.configuration.arp.evpn_timeout, null)
  arp_interface_cache_limit               = try(local.device_config[each.key].arp.cache_interface_limit, local.defaults.nxos.devices.configuration.arp.cache_interface_limit, null)
  arp_ip_adjacency_route_distance         = try(local.device_config[each.key].arp.adjacency_route_distance, local.defaults.nxos.devices.configuration.arp.adjacency_route_distance, null)
  arp_ip_arp_cos                          = try(local.device_config[each.key].arp.cos, local.defaults.nxos.devices.configuration.arp.cos, null)
  arp_off_list_timeout                    = try(local.device_config[each.key].arp.off_list_timeout, local.defaults.nxos.devices.configuration.arp.off_list_timeout, null)
  arp_rarp_fabric_forwarding              = try(local.device_config[each.key].arp.rarp_fabric_forwarding, local.defaults.nxos.devices.configuration.arp.rarp_fabric_forwarding, null) != null ? (try(local.device_config[each.key].arp.rarp_fabric_forwarding, local.defaults.nxos.devices.configuration.arp.rarp_fabric_forwarding) ? "enabled" : "disabled") : null
  arp_rarp_fabric_forwarding_rate         = try(local.device_config[each.key].arp.rarp_fabric_forwarding_rate, local.defaults.nxos.devices.configuration.arp.rarp_fabric_forwarding_rate, null)
  arp_resolve_outside_subnet              = try(local.device_config[each.key].arp.resolve_outside_subnet, local.defaults.nxos.devices.configuration.arp.resolve_outside_subnet, null) != null ? (try(local.device_config[each.key].arp.resolve_outside_subnet, local.defaults.nxos.devices.configuration.arp.resolve_outside_subnet) ? "enabled" : "disabled") : null
  arp_suppression_timeout                 = try(local.device_config[each.key].arp.suppression_timeout, local.defaults.nxos.devices.configuration.arp.suppression_timeout, null)
  arp_timeout                             = try(local.device_config[each.key].arp.timeout, local.defaults.nxos.devices.configuration.arp.timeout, null)

  # arpVpcDom nested map
  arp_vpc_domains = { for vpc in try(local.device_config[each.key].arp.vpc_domains, []) : vpc.domain_id => {
    arp_sync = try(vpc.arp_synchronize, local.defaults.nxos.devices.configuration.arp.vpc_domains.arp_synchronize, null) != null ? (try(vpc.arp_synchronize, local.defaults.nxos.devices.configuration.arp.vpc_domains.arp_synchronize) ? "enabled" : "disabled") : null
  } }

  # ndEntity / ndInst attributes
  nd_admin_state                         = "enabled"
  nd_instance_admin_state                = "enabled"
  nd_accept_solicit_neighbor_entry       = try(local.device_config[each.key].system.ipv6_nd.accept_solicit_neighbor_entry, local.defaults.nxos.devices.configuration.system.ipv6_nd.accept_solicit_neighbor_entry, null)
  nd_aging_interval                      = try(local.device_config[each.key].system.ipv6_nd.aging_interval, local.defaults.nxos.devices.configuration.system.ipv6_nd.aging_interval, null)
  nd_cache_limit                         = try(local.device_config[each.key].system.ipv6_nd.cache_limit, local.defaults.nxos.devices.configuration.system.ipv6_nd.cache_limit, null)
  nd_cache_syslog_rate                   = try(local.device_config[each.key].system.ipv6_nd.cache_syslog_rate, local.defaults.nxos.devices.configuration.system.ipv6_nd.cache_syslog_rate, null)
  nd_ipv6_adjacency_route_distance       = try(local.device_config[each.key].system.ipv6_nd.adjacency_route_distance, local.defaults.nxos.devices.configuration.system.ipv6_nd.adjacency_route_distance, null)
  nd_off_list_timeout                    = try(local.device_config[each.key].system.ipv6_nd.off_list_timeout, local.defaults.nxos.devices.configuration.system.ipv6_nd.off_list_timeout, null)
  nd_probe_interval_for_solicit_neighbor = try(local.device_config[each.key].system.ipv6_nd.probe_interval_for_solicit_neighbor, local.defaults.nxos.devices.configuration.system.ipv6_nd.probe_interval_for_solicit_neighbor, null)
  nd_solicit_neighbor_advertisement      = try(local.device_config[each.key].system.ipv6_nd.solicit_neighbor_advertisement, local.defaults.nxos.devices.configuration.system.ipv6_nd.solicit_neighbor_advertisement, null) != null ? (try(local.device_config[each.key].system.ipv6_nd.solicit_neighbor_advertisement, local.defaults.nxos.devices.configuration.system.ipv6_nd.solicit_neighbor_advertisement) ? "enabled" : "disabled") : null

  # ndDom -> ndIf nested maps (VRF -> interfaces)
  nd_vrfs = { for vrf_name, vrf_data in try(local.nd_vrfs_by_device[each.key], {}) : vrf_name => {
    interfaces = { for int_id, nd in vrf_data.interfaces : int_id => {
      boot_file_url                  = try(nd.ra_boot_file_url, null)
      control                        = length(compact([for flag, value in local.nd_control_values : value if try({ "redirects" = nd.redirects, "managed_cfg" = nd.managed_config_flag, "other_cfg" = nd.other_config_flag, "suppress_ra" = nd.suppress_ra, "suppress_ra_mtu" = nd.suppress_ra_mtu }[flag], false)])) > 0 ? join(",", compact([for flag, value in local.nd_control_values : value if try({ "redirects" = nd.redirects, "managed_cfg" = nd.managed_config_flag, "other_cfg" = nd.other_config_flag, "suppress_ra" = nd.suppress_ra, "suppress_ra_mtu" = nd.suppress_ra_mtu }[flag], false)])) : null
      dad_attempts                   = try(nd.dad_attempts, null)
      dadns_interval                 = try(nd.dad_interval, null)
      default_ra_lifetime            = try(nd.default_ra_lifetime, null) != null ? (nd.default_ra_lifetime ? "enabled" : "disabled") : null
      delete_adjacency_on_mac_delete = try(nd.delete_adjacency_on_mac_delete, null) != null ? (nd.delete_adjacency_on_mac_delete ? "enabled" : "disabled") : null
      dns_search_list_suppress       = try(nd.dns_search_list_suppress, null) != null ? (nd.dns_search_list_suppress ? "enabled" : "disabled") : null
      dns_suppress                   = try(nd.dns_suppress, null) != null ? (nd.dns_suppress ? "enabled" : "disabled") : null
      hop_limit                      = try(nd.hop_limit, null)
      mac_extract                    = try(nd.mac_extract, null)
      mtu                            = try(nd.mtu, null)
      neighbor_solicit_interval      = try(nd.ns_interval, null)
      ra_interval                    = try(nd.ra_interval, null)
      ra_interval_min                = try(nd.ra_interval_min, null)
      ra_lifetime                    = try(nd.ra_lifetime, null)
      reachable_time                 = try(nd.reachable_time, null)
      retransmit_timer               = try(nd.retransmit_timer, null)
      route_suppress                 = try(nd.suppress_ra_route, null) != null ? (nd.suppress_ra_route ? "enabled" : "disabled") : null
      router_preference              = try(nd.router_preference, null)
    } }
  } }

  depends_on = [
    nxos_loopback_interface.loopback_interface,
    nxos_physical_interface.physical_interface,
    nxos_port_channel_interface.port_channel_interface,
    nxos_svi_interface.svi_interface,
    nxos_vrf.vrf,
  ]
}
