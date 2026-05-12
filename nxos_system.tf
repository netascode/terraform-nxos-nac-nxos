locals {
  log_event_map = {
    "link-status-default"  = "linkStatusDefault"
    "link-status-enable"   = "linkStatusEnable"
    "none"                 = "none"
    "trunk-status-default" = "trunkStatusDefault"
    "trunk-status-enable"  = "trunkStatusEnable"
  }
  layer_map = {
    "layer2" = "Layer2"
    "layer3" = "Layer3"
  }
  smart_licensing_transport_map = {
    "callhome" = "transportCallhome"
    "cslu"     = "transportCslu"
    "off"      = "transportOff"
    "smart"    = "transportSmart"
  }
  cdp_format_device_id_map = {
    "none"          = "none"
    "mac"           = "mac"
    "serial-number" = "serialNum"
    "system-name"   = "sysName"
  }
  platform_pc_lb_algo_map = {
    "dlb"             = "PC_LB_ALGO_DLB"
    "rtag7"           = "PC_LB_ALGO_RTAG7"
    "rtag7-murmur"    = "PC_LB_ALGO_RTAG7_MURMUR"
    "rtag7-local-crc" = "PC_LB_ALGO_RTAG7_LOCAL_CRC"
    "dynamic-pin"     = "PC_LB_ALGO_DYNAMIC_PIN"
  }
  platform_switching_mode_map = {
    "store-forward" = "STORE_FORWARD"
    "cut-through"   = "CUT_THROUGH"
  }
  platform_routing_map = {
    "non-hierarchical-routing"                    = "NON_HIER_DEFAULT"
    "non-hierarchical-routing max-l3-mode"        = "NON_HIER_MAX_L3"
    "max-mode host"                               = "MAX_HOST"
    "max-mode-tor l3"                             = "TOR_MAX_L3"
    "mode hierarchical 64b-alpm"                  = "DEFAULT_64B"
    "non-hierarchical max-mode l3-nh 64b-alpm-nh" = "NON_HIER_MAX_L3_64B"
    "hierarchical def-max-mode l3 64b-alpm"       = "TOR_MAX_L3_64B"
    "max-mode-tor l2"                             = "TOR_MAX_L2"
    "max-mode-tor l2-l3"                          = "TOR_MAX_L2L3"
    "template-overlay-host-scale"                 = "TOR_TEMPLATE_OVL_HOST_SCALE"
    "template-lpm-heavy"                          = "TEMPLATE_LPM_HEAVY"
    "template-lpm-scale-v6-64"                    = "TOR_TEMPLATE_LPM_SCALE_V6_64"
    "template-dual-stack-host-scale"              = "TOR_TEMPLATE_DUAL_STACK_HOST_SCALE"
    "template-service-provider"                   = "TEMPLATE_SERVICE_PROVIDER"
    "template-multicast-heavy"                    = "TEMPLATE_MULTICAST_HEAVY"
    "template-vxlan-scale"                        = "TEMPLATE_VXLAN_SCALE"
    "template-mpls-heavy"                         = "TEMPLATE_MPLS_SCALE"
    "template-internet-peering"                   = "TEMPLATE_INTERNET_PEERING"
    "template-multicast-ext-heavy"                = "TEMPLATE_MULTICAST_EXT_HEAVY"
    "template-l3-heavy"                           = "TEMPLATE_L3_HEAVY"
    "template-dual-stack-mcast"                   = "TEMPLATE_MULTICAST_DUAL_STACK"
    "template-l2-heavy"                           = "TEMPLATE_L2_HEAVY"
    "template-l2-scale"                           = "TEMPLATE_L2_SCALE"
    "template-security-groups"                    = "TEMPLATE_SECURITY_GROUPS"
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
      # Subinterfaces (ethernets)
      flatten([for eth in try(local.device_config[device.name].interfaces.ethernets, []) :
        [for sub in try(eth.subinterfaces, []) : {
          device       = device.name
          vrf          = try(sub.vrf, "default")
          interface_id = "eth${eth.id}.${sub.id}"
          nd           = try(sub.nd, {})
        } if try(sub.nd, null) != null]
      ]),
      # Subinterfaces (port channels)
      flatten([for pc in try(local.device_config[device.name].interfaces.port_channels, []) :
        [for sub in try(pc.subinterfaces, []) : {
          device       = device.name
          vrf          = try(sub.vrf, "default")
          interface_id = "po${pc.id}.${sub.id}"
          nd           = try(sub.nd, {})
        } if try(sub.nd, null) != null]
      ]),
    )
  ])

  cdp_interfaces = flatten([
    for device in local.devices : concat(
      [for int in try(local.device_config[device.name].interfaces.ethernets, []) : {
        device       = device.name
        interface_id = "eth${int.id}"
        cdp          = try(int.cdp, null)
      } if try(int.cdp, null) != null],
      [for int in try(local.device_config[device.name].interfaces.port_channels, []) : {
        device       = device.name
        interface_id = "po${int.id}"
        cdp          = try(int.cdp, null)
      } if try(int.cdp, null) != null],
      [for int in try(local.device_config[device.name].interfaces.management, []) : {
        device       = device.name
        interface_id = int.id
        cdp          = try(int.cdp, null)
      } if try(int.cdp, null) != null],
    )
  ])

  cdp_interfaces_by_device = { for entry in local.cdp_interfaces : entry.device => entry... }

  lldp_interfaces = flatten([
    for device in local.devices : concat(
      [for int in try(local.device_config[device.name].interfaces.ethernets, []) : {
        device                             = device.name
        interface_id                       = "eth${int.id}"
        lldp_receive                       = try(int.lldp_receive, null)
        lldp_transmit                      = try(int.lldp_transmit, null)
        lldp_tlv_set_management_address_v4 = try(int.lldp_tlv_set_management_address_v4, null)
        lldp_tlv_set_management_address_v6 = try(int.lldp_tlv_set_management_address_v6, null)
        lldp_tlv_set_vlan                  = try(int.lldp_tlv_set_vlan, null)
        lldp_dcbx_version                  = try(int.lldp_dcbx_version, null)
        } if try(int.lldp_receive, null) != null ||
        try(int.lldp_transmit, null) != null ||
        try(int.lldp_tlv_set_management_address_v4, null) != null ||
        try(int.lldp_tlv_set_management_address_v6, null) != null ||
        try(int.lldp_tlv_set_vlan, null) != null ||
      try(int.lldp_dcbx_version, null) != null],
      [for int in try(local.device_config[device.name].interfaces.port_channels, []) : {
        device                             = device.name
        interface_id                       = "po${int.id}"
        lldp_receive                       = try(int.lldp_receive, null)
        lldp_transmit                      = try(int.lldp_transmit, null)
        lldp_tlv_set_management_address_v4 = try(int.lldp_tlv_set_management_address_v4, null)
        lldp_tlv_set_management_address_v6 = try(int.lldp_tlv_set_management_address_v6, null)
        lldp_tlv_set_vlan                  = try(int.lldp_tlv_set_vlan, null)
        lldp_dcbx_version                  = try(int.lldp_dcbx_version, null)
        } if try(int.lldp_receive, null) != null ||
        try(int.lldp_transmit, null) != null ||
        try(int.lldp_tlv_set_management_address_v4, null) != null ||
        try(int.lldp_tlv_set_management_address_v6, null) != null ||
        try(int.lldp_tlv_set_vlan, null) != null ||
      try(int.lldp_dcbx_version, null) != null],
      [for int in try(local.device_config[device.name].interfaces.management, []) : {
        device                             = device.name
        interface_id                       = int.id
        lldp_receive                       = try(int.lldp_receive, null)
        lldp_transmit                      = try(int.lldp_transmit, null)
        lldp_tlv_set_management_address_v4 = try(int.lldp_tlv_set_management_address_v4, null)
        lldp_tlv_set_management_address_v6 = try(int.lldp_tlv_set_management_address_v6, null)
        lldp_tlv_set_vlan                  = try(int.lldp_tlv_set_vlan, null)
        lldp_dcbx_version                  = try(int.lldp_dcbx_version, null)
        } if try(int.lldp_receive, null) != null ||
        try(int.lldp_transmit, null) != null ||
        try(int.lldp_tlv_set_management_address_v4, null) != null ||
        try(int.lldp_tlv_set_management_address_v6, null) != null ||
        try(int.lldp_tlv_set_vlan, null) != null ||
      try(int.lldp_dcbx_version, null) != null],
    )
  ])

  lldp_interfaces_by_device = { for entry in local.lldp_interfaces : entry.device => entry... }

  udld_interfaces = flatten([
    for device in local.devices : [
      for int in try(local.device_config[device.name].interfaces.ethernets, []) : {
        device          = device.name
        interface_id    = "eth${int.id}"
        udld            = try(int.udld, null)
        udld_aggressive = try(int.udld_aggressive, null)
      } if try(int.udld, null) != null ||
      try(int.udld_aggressive, null) != null
    ]
  ])

  udld_interfaces_by_device = { for entry in local.udld_interfaces : entry.device => entry... }

  ttag_interfaces = flatten([
    for device in local.devices : concat(
      [for int in try(local.device_config[device.name].interfaces.ethernets, []) : {
        device       = device.name
        interface_id = "eth${int.id}"
        ttag         = try(int.ttag, null)
        ttag_inner   = try(int.ttag_inner, null)
        ttag_marker  = try(int.ttag_marker, null)
        ttag_strip   = try(int.ttag_strip, null)
        } if try(int.ttag, null) != null ||
        try(int.ttag_inner, null) != null ||
        try(int.ttag_marker, null) != null ||
      try(int.ttag_strip, null) != null],
      [for int in try(local.device_config[device.name].interfaces.port_channels, []) : {
        device       = device.name
        interface_id = "po${int.id}"
        ttag         = try(int.ttag, null)
        ttag_inner   = try(int.ttag_inner, null)
        ttag_marker  = try(int.ttag_marker, null)
        ttag_strip   = try(int.ttag_strip, null)
        } if try(int.ttag, null) != null ||
        try(int.ttag_inner, null) != null ||
        try(int.ttag_marker, null) != null ||
      try(int.ttag_strip, null) != null],
    )
  ])

  ttag_interfaces_by_device = { for entry in local.ttag_interfaces : entry.device => entry... }

  nd_interfaces_by_device = { for entry in local.nd_interfaces : entry.device => entry... }

  nd_vrfs_by_device = { for device_name, entries in local.nd_interfaces_by_device : device_name => {
    for vrf in distinct([for e in entries : e.vrf]) : vrf => {
      interfaces = { for e in entries : e.interface_id => e.nd if e.vrf == vrf }
    }
  } }

  hypershield_source_interface_type_map = {
    "ethernet"     = "eth"
    "loopback"     = "lo"
    "mgmt"         = "mgmt"
    "port-channel" = "po"
    "vlan"         = "vlan"
    "vni"          = "vni"
  }

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
    if try(local.device_config[device.name].system.hostname, null) != null ||
    try(local.device_config[device.name].system.mtu, null) != null ||
    try(local.device_config[device.name].system.ethernet, null) != null ||
    try(local.device_config[device.name].system.boot, null) != null ||
    try(local.device_config[device.name].system.cfs_distribute, null) != null ||
    try(local.device_config[device.name].system.cfs_eth_distribute, null) != null ||
    try(local.device_config[device.name].system.cfs_ipv4_distribute, null) != null ||
    try(local.device_config[device.name].system.cfs_ipv4_mcast_address, null) != null ||
    try(local.device_config[device.name].system.cfs_ipv6_distribute, null) != null ||
    try(local.device_config[device.name].system.cfs_ipv6_mcast_address, null) != null ||
    length(try(local.device_config[device.name].system.interface_breakout_modules, [])) > 0 ||
    length(try(local.device_config[device.name].system.cli_aliases, [])) > 0 ||
    try(local.device_config[device.name].system.copp_profile, null) != null ||
    try(local.device_config[device.name].system.copp_rate_limit, null) != null ||
    try(local.device_config[device.name].system.clock, null) != null ||
    try(local.device_config[device.name].system.icam_monitor_interval, null) != null ||
    try(local.device_config[device.name].system.icam_monitor_intervals, null) != null ||
    try(local.device_config[device.name].system.icam_monitor_scale, null) != null ||
    try(local.device_config[device.name].system.nve_ipmc_index_size, null) != null ||
    try(local.device_config[device.name].system.nve_overlay_vlans, null) != null ||
    length(try(local.device_config[device.name].system.nve_infra_vlans, [])) > 0 ||
    try(local.device_config[device.name].system.platform, null) != null ||
    try(local.device_config[device.name].system.hardware, null) != null ||
    try(local.device_config[device.name].system.smart_licensing_transport, null) != null ||
    try(local.device_config[device.name].system.smart_licensing_url_cslu, null) != null ||
    try(local.device_config[device.name].system.terminal_console_exec_timeout, null) != null ||
    try(local.device_config[device.name].system.line_vty_exec_timeout, null) != null ||
    try(local.device_config[device.name].system.line_vty_session_limit, null) != null ||
    length(try(local.device_config[device.name].system.vdcs, [])) > 0 ||
    try(local.device_config[device.name].arp, null) != null ||
    try(local.device_config[device.name].nd, null) != null ||
    try(local.device_config[device.name].cdp, null) != null ||
    try(local.device_config[device.name].dns, null) != null ||
    try(local.device_config[device.name].lldp, null) != null ||
    try(local.device_config[device.name].udld, null) != null ||
    try(local.device_config[device.name].vpc.ip_arp_synchronize, null) != null ||
    try(local.device_config[device.name].vpc.ipv6_nd_synchronize, null) != null ||
    try(local.device_config[device.name].system.nxapi, null) != null ||
    try(local.device_config[device.name].system.hypershield, null) != null ||
    try(local.device_config[device.name].system.ssh, null) != null ||
    length(try(local.nd_interfaces_by_device[device.name], [])) > 0 ||
    length(try(local.cdp_interfaces_by_device[device.name], [])) > 0 ||
    length(try(local.lldp_interfaces_by_device[device.name], [])) > 0 ||
    length(try(local.udld_interfaces_by_device[device.name], [])) > 0 ||
    try(local.device_config[device.name].system.erspan_origin_ip_address, null) != null ||
    try(local.device_config[device.name].system.erspan_origin_ipv6_address, null) != null ||
    try(local.device_config[device.name].system.ttag_marker_interval, null) != null ||
    length(try(local.ttag_interfaces_by_device[device.name], [])) > 0 ||
    length(try(local.device_config[device.name].interfaces.management, [])) > 0 ||
  try(local.device_config[device.name].system.hardware_access_list_tcam_region, null) != null }
  device = each.key

  # topSystem attributes
  name = try(local.device_config[each.key].system.hostname, null)

  # ethpmInst attributes (ethernet)
  ethernet_mtu                                  = try(local.device_config[each.key].system.mtu, null)
  ethernet_default_admin_state                  = try(local.device_config[each.key].system.ethernet.default_switchport_shutdown, null) != null ? (try(local.device_config[each.key].system.ethernet.default_switchport_shutdown) ? "down" : "up") : null
  ethernet_admin_link_down_syslog_level         = try(local.device_config[each.key].system.ethernet.admin_link_down_syslog_level, null)
  ethernet_admin_link_up_syslog_level           = try(local.device_config[each.key].system.ethernet.admin_link_up_syslog_level, null)
  ethernet_allow_unsupported_sfp                = try(local.device_config[each.key].system.ethernet.service_unsupported_transceiver, null)
  ethernet_interface_syslog_info                = try(local.device_config[each.key].system.ethernet.interface_syslog_info, null)
  ethernet_log_event                            = try(local.device_config[each.key].system.ethernet.logging_event_port, null) != null ? try(local.log_event_map[try(local.device_config[each.key].system.ethernet.logging_event_port)], null) : null
  ethernet_default_layer                        = try(local.layer_map[try(local.device_config[each.key].system.ethernet.default_switchport)], null)
  ethernet_system_interface_admin_state         = try(local.device_config[each.key].system.ethernet.default_interface_shutdown, null)
  ethernet_system_link_failure_laser_on         = try(local.device_config[each.key].system.ethernet.link_failure_laser_on, null)
  ethernet_system_storm_control_multi_threshold = try(local.device_config[each.key].system.ethernet.storm_control_multicast, null)
  ethernet_vlan_tag_native                      = try(local.device_config[each.key].system.ethernet.dot1q_tag_native, null)

  # arpEntity / arpInst attributes
  arp_admin_state                         = "enabled"
  arp_instance_admin_state                = "enabled"
  arp_allow_static_arp_outside_subnet     = try(local.device_config[each.key].arp.allow_static_arp_outside_subnet, null) != null ? (try(local.device_config[each.key].arp.allow_static_arp_outside_subnet) ? "enabled" : "disabled") : null
  arp_unnumbered_svi_software_replication = try(local.device_config[each.key].arp.unnumbered_svi_software_replication, null) != null ? (try(local.device_config[each.key].arp.unnumbered_svi_software_replication) ? "enabled" : "disabled") : null
  arp_cache_limit                         = try(local.device_config[each.key].arp.cache_limit, null)
  arp_cache_syslog_rate                   = try(local.device_config[each.key].arp.cache_syslog_rate, null)
  arp_evpn_timeout                        = try(local.device_config[each.key].arp.evpn_timeout, null)
  arp_interface_cache_limit               = try(local.device_config[each.key].arp.cache_interface_limit, null)
  arp_ip_adjacency_route_distance         = try(local.device_config[each.key].arp.adjacency_route_distance, null)
  arp_ip_arp_cos                          = try(local.device_config[each.key].arp.cos, null)
  arp_off_list_timeout                    = try(local.device_config[each.key].arp.off_list_timeout, null)
  arp_rarp_fabric_forwarding              = try(local.device_config[each.key].arp.rarp_fabric_forwarding, null) != null ? (try(local.device_config[each.key].arp.rarp_fabric_forwarding) ? "enabled" : "disabled") : null
  arp_rarp_fabric_forwarding_rate         = try(local.device_config[each.key].arp.rarp_fabric_forwarding_rate, null)
  arp_resolve_outside_subnet              = try(local.device_config[each.key].arp.resolve_outside_subnet, null) != null ? (try(local.device_config[each.key].arp.resolve_outside_subnet) ? "enabled" : "disabled") : null
  arp_suppression_timeout                 = try(local.device_config[each.key].arp.suppression_timeout, null)
  arp_timeout                             = try(local.device_config[each.key].arp.timeout, null)

  # arpVpcDom nested map
  arp_vpc_domains = try(local.device_config[each.key].vpc.ip_arp_synchronize, null) != null ? { tostring(try(local.device_config[each.key].vpc.domain_id)) = {
    arp_sync = try(local.device_config[each.key].vpc.ip_arp_synchronize) ? "enabled" : "disabled"
  } } : null

  # ndEntity / ndInst attributes
  nd_admin_state                         = "enabled"
  nd_instance_admin_state                = "enabled"
  nd_accept_solicit_neighbor_entry       = try(local.device_config[each.key].nd.accept_solicit_neighbor_entry, null)
  nd_aging_interval                      = try(local.device_config[each.key].nd.aging_interval, null)
  nd_cache_limit                         = try(local.device_config[each.key].nd.cache_limit, null)
  nd_cache_syslog_rate                   = try(local.device_config[each.key].nd.cache_syslog_rate, null)
  nd_ipv6_adjacency_route_distance       = try(local.device_config[each.key].nd.adjacency_route_distance, null)
  nd_off_list_timeout                    = try(local.device_config[each.key].nd.off_list_timeout, null)
  nd_probe_interval_for_solicit_neighbor = try(local.device_config[each.key].nd.probe_interval_for_solicit_neighbor, null)
  nd_solicit_neighbor_advertisement      = try(local.device_config[each.key].nd.solicit_neighbor_advertisement, null) != null ? (try(local.device_config[each.key].nd.solicit_neighbor_advertisement) ? "enabled" : "disabled") : null

  # ndVpcDom nested map
  nd_vpc_domains = try(local.device_config[each.key].vpc.ipv6_nd_synchronize, null) != null ? { tostring(try(local.device_config[each.key].vpc.domain_id)) = {
    nd_sync = try(local.device_config[each.key].vpc.ipv6_nd_synchronize) ? "enabled" : "disabled"
  } } : null

  # ndDom -> ndIf nested maps (VRF -> interfaces)
  nd_vrfs = length(try(local.nd_vrfs_by_device[each.key], {})) > 0 ? { for vrf_name, vrf_data in try(local.nd_vrfs_by_device[each.key], {}) : vrf_name => {
    interfaces = { for int_id, nd in vrf_data.interfaces : int_id => {
      boot_file_url                  = try(nd.ra_boot_file_url, null)
      control                        = length(compact([for flag, value in local.nd_control_values : value if try({ "redirects" = nd.redirects, "managed_cfg" = nd.managed_config_flag, "other_cfg" = nd.other_config_flag, "suppress_ra" = nd.suppress_ra, "suppress_ra_mtu" = nd.suppress_ra_mtu }[flag], false)])) > 0 ? join(",", compact([for flag, value in local.nd_control_values : value if try({ "redirects" = nd.redirects, "managed_cfg" = nd.managed_config_flag, "other_cfg" = nd.other_config_flag, "suppress_ra" = nd.suppress_ra, "suppress_ra_mtu" = nd.suppress_ra_mtu }[flag], false)])) : null
      dad_attempts                   = try(nd.dad_attempts, null)
      dadns_interval                 = try(nd.dad_ns_interval, null)
      default_ra_lifetime            = try(nd.default_ra_lifetime, null) != null ? (nd.default_ra_lifetime ? "enabled" : "disabled") : null
      delete_adjacency_on_mac_delete = try(nd.delete_adjacency_on_mac_delete, null) != null ? (nd.delete_adjacency_on_mac_delete ? "enabled" : "disabled") : null
      dns_search_list_suppress       = try(nd.dns_search_list_suppress, null) != null ? (nd.dns_search_list_suppress ? "enabled" : "disabled") : null
      dns_suppress                   = try(nd.dns_suppress, null) != null ? (nd.dns_suppress ? "enabled" : "disabled") : null
      hop_limit                      = try(nd.hop_limit, null)
      mac_extract                    = try(nd.mac_extract, null)
      mtu                            = try(nd.mtu, null)
      neighbor_solicit_interval      = try(nd.ns_interval, null)
      ra_interval                    = try(nd.ra_interval, null)
      ra_interval_min                = try(nd.ra_interval_minimum, null)
      ra_lifetime                    = try(nd.ra_lifetime, null)
      reachable_time                 = try(nd.reachable_time, null)
      retransmit_timer               = try(nd.retrans_timer, null)
      route_suppress                 = try(nd.suppress_ra_route, null) != null ? (nd.suppress_ra_route ? "enabled" : "disabled") : null
      router_preference              = try(nd.router_preference, null)
    } }
  } } : null

  # datetimeClock attributes
  clock_format        = try(local.device_config[each.key].system.clock.format, null)
  clock_format_debug  = try(local.device_config[each.key].system.clock.format_show_timezone_debug, null)
  clock_format_syslog = try(local.device_config[each.key].system.clock.format_show_timezone_syslog, null)
  clock_protocol      = try(local.device_config[each.key].system.clock.protocol, null)

  # datetimeTimezone attributes
  clock_timezone_name    = try(local.device_config[each.key].system.clock.timezone_name, null)
  clock_timezone_hours   = try(local.device_config[each.key].system.clock.timezone_hours, null)
  clock_timezone_minutes = try(local.device_config[each.key].system.clock.timezone_minutes, null)

  # datetimeSummerT attributes
  clock_summer_time_name           = try(local.device_config[each.key].system.clock.summer_time.name, null)
  clock_summer_time_offset_minutes = try(local.device_config[each.key].system.clock.summer_time.offset_minutes, null)
  clock_summer_time_start_week     = try(local.device_config[each.key].system.clock.summer_time.start_week, null)
  clock_summer_time_start_day      = try(local.device_config[each.key].system.clock.summer_time.start_day, null)
  clock_summer_time_start_month    = try(local.device_config[each.key].system.clock.summer_time.start_month, null)
  clock_summer_time_start_time     = try(local.device_config[each.key].system.clock.summer_time.start_time, null)
  clock_summer_time_end_week       = try(local.device_config[each.key].system.clock.summer_time.end_week, null)
  clock_summer_time_end_day        = try(local.device_config[each.key].system.clock.summer_time.end_day, null)
  clock_summer_time_end_month      = try(local.device_config[each.key].system.clock.summer_time.end_month, null)
  clock_summer_time_end_time       = try(local.device_config[each.key].system.clock.summer_time.end_time, null)

  # bootBoot / bootImage attributes
  boot_auto_copy             = try(local.device_config[each.key].system.boot.auto_copy, null) == null ? null : (try(local.device_config[each.key].system.boot.auto_copy) ? "enable" : "disable")
  boot_dhcp                  = try(local.device_config[each.key].system.boot.dhcp, null)
  boot_exclude_configuration = try(local.device_config[each.key].system.boot.exclude_configuration, null) == null ? null : (try(local.device_config[each.key].system.boot.exclude_configuration) ? "enable" : "disable")
  boot_mode                  = try(local.device_config[each.key].system.boot.mode, null)
  boot_order                 = try(local.device_config[each.key].system.boot.order, null)
  boot_poap                  = try(local.device_config[each.key].system.boot.poap, null) == null ? null : (try(local.device_config[each.key].system.boot.poap) ? "enable" : "disable")
  boot_aci                   = try(local.device_config[each.key].system.boot.aci, null)
  boot_image_verification    = try(local.device_config[each.key].system.boot.image_verify, null) == null ? null : (try(local.device_config[each.key].system.boot.image_verify) ? "enable" : "disable")
  boot_image_supervisor_1    = try(local.device_config[each.key].system.boot.nxos_image_sup_1, null)
  boot_image_supervisor_2    = try(local.device_config[each.key].system.boot.nxos_image_sup_2, null)

  # imBreakout / imMod / imFpP nested maps
  breakout_modules = length(try(local.device_config[each.key].system.interface_breakout_modules, [])) > 0 ? { for mod in try(local.device_config[each.key].system.interface_breakout_modules, []) : mod.id => {
    front_panel_ports = length(try(mod.ports, [])) > 0 ? { for port in try(mod.ports, []) : port.id => {
      breakout_map = try(port.map, null)
    } } : null
  } } : null

  # cfsEntity / cfsInst attributes
  cfs_distribute             = try(local.device_config[each.key].system.cfs_distribute, null) == null ? null : (try(local.device_config[each.key].system.cfs_distribute) ? "enabled" : "disabled")
  cfs_ethernet_distribution  = try(local.device_config[each.key].system.cfs_eth_distribute, null) == null ? null : (try(local.device_config[each.key].system.cfs_eth_distribute) ? "enabled" : "disabled")
  cfs_ipv4_distribution      = try(local.device_config[each.key].system.cfs_ipv4_distribute, null) == null ? null : (try(local.device_config[each.key].system.cfs_ipv4_distribute) ? "enabled" : "disabled")
  cfs_ipv4_multicast_address = try(local.device_config[each.key].system.cfs_ipv4_mcast_address, null)
  cfs_ipv6_distribution      = try(local.device_config[each.key].system.cfs_ipv6_distribute, null) == null ? null : (try(local.device_config[each.key].system.cfs_ipv6_distribute) ? "enabled" : "disabled")
  cfs_ipv6_multicast_address = try(local.device_config[each.key].system.cfs_ipv6_mcast_address, null)

  # coppEntity / coppProfile attributes
  copp_rate_limiter = try(local.device_config[each.key].system.copp_rate_limit, null)
  copp_profile_type = try(local.device_config[each.key].system.copp_profile, null)

  # vshdCliAlias nested map
  cli_aliases = length(try(local.device_config[each.key].system.cli_aliases, [])) > 0 ? { for alias in try(local.device_config[each.key].system.cli_aliases, []) : alias.name => {
    command = try(alias.command, null)
  } } : null

  # licensemanagerSmartLicensing attributes
  smart_licensing_transport_mode     = try(local.smart_licensing_transport_map[try(local.device_config[each.key].system.smart_licensing_transport)], null)
  smart_licensing_transport_cslu_url = try(local.device_config[each.key].system.smart_licensing_url_cslu, null)

  # terminalTerminal attributes
  console_exec_timeout = try(local.device_config[each.key].system.terminal_console_exec_timeout, null)
  vty_exec_timeout     = try(local.device_config[each.key].system.line_vty_exec_timeout, null)
  vty_session_limit    = try(local.device_config[each.key].system.line_vty_session_limit, null)

  # icamEntity / icamInst / icamScale attributes
  icam_monitor_interval         = try(local.device_config[each.key].system.icam_monitor_interval, null)
  icam_number_of_intervals      = try(local.device_config[each.key].system.icam_monitor_intervals, null)
  icam_scale_configuration      = try(local.device_config[each.key].system.icam_monitor_scale, null)
  icam_scale_critical_threshold = try(local.device_config[each.key].system.icam_monitor_threshold_critical, null)
  icam_scale_info_threshold     = try(local.device_config[each.key].system.icam_monitor_threshold_info, null)
  icam_scale_warning_threshold  = try(local.device_config[each.key].system.icam_monitor_threshold_warning, null)

  # platformEntity attributes
  platform_access_list_match_inner_header            = try(local.device_config[each.key].system.platform.access_list_match_inner_header, null) == null ? null : (try(local.device_config[each.key].system.platform.access_list_match_inner_header) ? "enable" : "disable")
  platform_acl_tap_aggregation                       = try(local.device_config[each.key].system.platform.acl_tap_aggregation, null) == null ? null : (try(local.device_config[each.key].system.platform.acl_tap_aggregation) ? "enable" : "disable")
  platform_disable_parse_error                       = try(local.device_config[each.key].system.platform.disable_parse_error, null) == null ? null : (try(local.device_config[each.key].system.platform.disable_parse_error) ? "enable" : "disable")
  platform_global_tx_span                            = try(local.device_config[each.key].system.platform.global_tx_span, null) == null ? null : (try(local.device_config[each.key].system.platform.global_tx_span) ? "enable" : "disable")
  platform_high_multicast_priority                   = try(local.device_config[each.key].system.platform.high_multicast_priority, null) == null ? null : (try(local.device_config[each.key].system.platform.high_multicast_priority) ? "enabled" : "disabled")
  platform_hardware_lou_resource_threshold           = try(local.device_config[each.key].system.platform.hardware_lou_resource_threshold, null)
  platform_ingress_bd_ifacl_label_optimization       = try(local.device_config[each.key].system.platform.ingress_bd_ifacl_label_optimization, null) == null ? null : (try(local.device_config[each.key].system.platform.ingress_bd_ifacl_label_optimization) ? "enable" : "disable")
  platform_ingress_racl_size                         = try(local.device_config[each.key].system.platform.ingress_racl_size, null) == null ? null : (try(local.device_config[each.key].system.platform.ingress_racl_size) ? "enable" : "disable")
  platform_ingress_replication_round_robin           = try(local.device_config[each.key].system.platform.ingress_replication_round_robin, null)
  platform_ip_statistics                             = try(local.device_config[each.key].system.platform.ip_statistics, null) == null ? null : (try(local.device_config[each.key].system.platform.ip_statistics) ? "enable" : "disable")
  platform_ipv6_alpm_carve_value                     = try(local.device_config[each.key].system.platform.ipv6_alpm_carve_value, null)
  platform_ipv6_lpm_max_entries                      = try(local.device_config[each.key].system.platform.ipv6_lpm_max_entries, null)
  platform_lpm_max_limit                             = try(local.device_config[each.key].system.platform.lpm_max_limit, null)
  platform_multicast_dcs_check                       = try(local.device_config[each.key].system.platform.multicast_dcs_check, null) == null ? null : (try(local.device_config[each.key].system.platform.multicast_dcs_check) ? "enable" : "disable")
  platform_multicast_flex_stats                      = try(local.device_config[each.key].system.platform.multicast_flex_stats, null) == null ? null : (try(local.device_config[each.key].system.platform.multicast_flex_stats) ? "enable" : "disable")
  platform_multicast_lpm_max_entries                 = try(local.device_config[each.key].system.platform.multicast_lpm_max_entries, null)
  platform_multicast_max_limit                       = try(local.device_config[each.key].system.platform.multicast_max_limit, null)
  platform_multicast_nlb                             = try(local.device_config[each.key].system.platform.multicast_nlb, null) == null ? null : (try(local.device_config[each.key].system.platform.multicast_nlb) ? "enable" : "disable")
  platform_multicast_racl_bridge                     = try(local.device_config[each.key].system.platform.multicast_racl_bridge, null) == null ? null : (try(local.device_config[each.key].system.platform.multicast_racl_bridge) ? "enabled" : "disabled")
  platform_multicast_rpf_check_optimization          = try(local.device_config[each.key].system.platform.multicast_rpf_check_optimization, null) == null ? null : (try(local.device_config[each.key].system.platform.multicast_rpf_check_optimization) ? "enabled" : "disabled")
  platform_multicast_service_reflect_port            = try(local.device_config[each.key].system.platform.multicast_service_reflect_port, null)
  platform_multicast_syslog_threshold                = try(local.device_config[each.key].system.platform.multicast_syslog_threshold, null)
  platform_mld_snooping                              = try(local.device_config[each.key].system.platform.mld_snooping, null) == null ? null : (try(local.device_config[each.key].system.platform.mld_snooping) ? "enable" : "disable")
  platform_mpls_adjacency_stats_mode                 = try(local.device_config[each.key].system.platform.mpls_adjacency_stats_mode, null)
  platform_mpls_ecmp_mode                            = try(local.device_config[each.key].system.platform.mpls_ecmp, null) == null ? null : (try(local.device_config[each.key].system.platform.mpls_ecmp) ? "enable" : "disable")
  platform_mrouting_disable_l2_update                = try(local.device_config[each.key].system.platform.mrouting_disable_l2_update, null) == null ? null : (try(local.device_config[each.key].system.platform.mrouting_disable_l2_update) ? "enable" : "disable")
  platform_mrouting_disable_second_route_update      = try(local.device_config[each.key].system.platform.mrouting_disable_second_route_update, null) == null ? null : (try(local.device_config[each.key].system.platform.mrouting_disable_second_route_update) ? "enable" : "disable")
  platform_mrouting_performance_mode                 = try(local.device_config[each.key].system.platform.mrouting_performance_mode, null) == null ? null : (try(local.device_config[each.key].system.platform.mrouting_performance_mode) ? "enable" : "disable")
  platform_openflow_forward_pdu                      = try(local.device_config[each.key].system.platform.openflow_forward_pdu, null) == null ? null : (try(local.device_config[each.key].system.platform.openflow_forward_pdu) ? "enabled" : "disabled")
  platform_pbr_skip_self_ip                          = try(local.device_config[each.key].system.platform.pbr_skip_self_ip, null) == null ? null : (try(local.device_config[each.key].system.platform.pbr_skip_self_ip) ? "enabled" : "disabled")
  platform_pic_core_enable                           = try(local.device_config[each.key].system.platform.pic_core, null) == null ? null : (try(local.device_config[each.key].system.platform.pic_core) ? "enabled" : "disabled")
  platform_port_channel_fast_convergence             = try(local.device_config[each.key].system.platform.port_channel_fast_convergence, null) == null ? null : (try(local.device_config[each.key].system.platform.port_channel_fast_convergence) ? "enable" : "disable")
  platform_port_channel_load_balance_algorithm       = try(local.platform_pc_lb_algo_map[try(local.device_config[each.key].system.platform.port_channel_load_balance)], null)
  platform_port_channel_load_balance_resilient       = try(local.device_config[each.key].system.platform.port_channel_load_balance_resilient, null) == null ? null : (try(local.device_config[each.key].system.platform.port_channel_load_balance_resilient) ? "yes" : "no")
  platform_port_channel_mpls_load_balance_label_ip   = try(local.device_config[each.key].system.platform.port_channel_mpls_load_balance_label_ip, null) == null ? null : (try(local.device_config[each.key].system.platform.port_channel_mpls_load_balance_label_ip) ? "LABEL_IP" : "DEFAULT")
  platform_port_channel_mpls_load_balance_label_only = try(local.device_config[each.key].system.platform.port_channel_mpls_load_balance_label_only, null) == null ? null : (try(local.device_config[each.key].system.platform.port_channel_mpls_load_balance_label_only) ? "LABEL_ONLY" : "DEFAULT")
  platform_port_channel_scale_fanout                 = try(local.device_config[each.key].system.platform.port_channel_scale_fanout, null) == null ? null : (try(local.device_config[each.key].system.platform.port_channel_scale_fanout) ? "enable" : "disable")
  platform_profile_front_port_mode                   = try(local.device_config[each.key].system.platform.profile_front_portmode, null)
  platform_profile_mode                              = try(local.device_config[each.key].system.platform.profile_mode, null)
  platform_profile_tuple                             = try(local.device_config[each.key].system.platform.profile_tuple, null) == null ? null : (try(local.device_config[each.key].system.platform.profile_tuple) ? "Enable" : "Disable")
  platform_pstat_configuration                       = try(local.device_config[each.key].system.platform.pstat, null) == null ? null : (try(local.device_config[each.key].system.platform.pstat) ? "PSTAT_ENABLE" : "PSTAT_DISABLE")
  platform_qos_min_buffer                            = try(local.device_config[each.key].system.platform.qos_min_buffer, null)
  platform_routing_mode                              = try(local.platform_routing_map[try(local.device_config[each.key].system.routing)], null)
  platform_service_template_name                     = try(local.device_config[each.key].system.platform.service_template_name, null)
  platform_svi_and_si_flex_stats                     = try(local.device_config[each.key].system.platform.svi_and_si_flex_stats, null) == null ? null : (try(local.device_config[each.key].system.platform.svi_and_si_flex_stats) ? "enable" : "disable")
  platform_svi_flex_stats                            = try(local.device_config[each.key].system.platform.svi_flex_stats, null) == null ? null : (try(local.device_config[each.key].system.platform.svi_flex_stats) ? "enable" : "disable")
  platform_switch_mode                               = try(local.device_config[each.key].system.platform.switch_mode, null)
  platform_switching_fabric_speed                    = try(local.device_config[each.key].system.platform.switching_fabric_speed, null)
  platform_switching_mode                            = try(local.platform_switching_mode_map[try(local.device_config[each.key].system.platform.switching_mode)], null)
  platform_system_fabric_mode                        = try(local.device_config[each.key].system.platform.system_fabric_mode, null)
  platform_tcam_syslog_threshold                     = try(local.device_config[each.key].system.platform.tcam_syslog_threshold, null)
  platform_unicast_max_limit                         = try(local.device_config[each.key].system.platform.unicast_max_limit, null)
  platform_unicast_syslog_threshold                  = try(local.device_config[each.key].system.platform.unicast_syslog_threshold, null)
  platform_unicast_trace                             = try(local.device_config[each.key].system.platform.unicast_trace, null) == null ? null : (try(local.device_config[each.key].system.platform.unicast_trace) ? "enable" : "disable")
  platform_unknown_unicast_flood                     = try(local.device_config[each.key].system.platform.unknown_unicast_flood, null) == null ? null : (try(local.device_config[each.key].system.platform.unknown_unicast_flood) ? "enabled" : "disabled")
  platform_urpf_status                               = try(local.device_config[each.key].system.platform.urpf, null) == null ? null : (try(local.device_config[each.key].system.platform.urpf) ? "enabled" : "disabled")
  platform_wrr_unicast_bandwidth                     = try(local.device_config[each.key].system.platform.wrr_unicast_bandwidth, null)

  # platformEntityExtended attributes
  platform_extended_acl_disable_redirect_share          = try(local.device_config[each.key].system.hardware.acl_redirect_share_disable, null) == null ? null : (try(local.device_config[each.key].system.hardware.acl_redirect_share_disable) ? "enable" : "disable")
  platform_extended_atomic_update                       = try(local.device_config[each.key].system.hardware.tcam_atomic_update, null) == null ? null : (try(local.device_config[each.key].system.hardware.tcam_atomic_update) ? "enable" : "disable")
  platform_extended_atomic_update_strict                = try(local.device_config[each.key].system.hardware.tcam_atomic_update_strict, null) == null ? null : (try(local.device_config[each.key].system.hardware.tcam_atomic_update_strict) ? "enable" : "disable")
  platform_extended_counter_manager_bfd_scale           = try(local.device_config[each.key].system.hardware.counter_bfd_feature_scale, null)
  platform_extended_counter_manager_ecn_scale           = try(local.device_config[each.key].system.hardware.counter_ecn_feature_scale, null)
  platform_extended_counter_manager_egress_acl_scale    = try(local.device_config[each.key].system.hardware.counter_egr_acl_feature_scale, null)
  platform_extended_counter_manager_feature_bfd         = try(local.device_config[each.key].system.hardware.counter_feature_bfd, null)
  platform_extended_counter_manager_feature_ecn         = try(local.device_config[each.key].system.hardware.counter_feature_ecn, null)
  platform_extended_counter_manager_feature_egress_acl  = try(local.device_config[each.key].system.hardware.counter_feature_egr_acl, null)
  platform_extended_counter_manager_feature_ingress_acl = try(local.device_config[each.key].system.hardware.counter_feature_ingr_acl, null)
  platform_extended_counter_manager_feature_l2vni       = try(local.device_config[each.key].system.hardware.counter_feature_l2vni, null)
  platform_extended_counter_manager_feature_l3vni       = try(local.device_config[each.key].system.hardware.counter_feature_l3vni, null)
  platform_extended_counter_manager_feature_si          = try(local.device_config[each.key].system.hardware.counter_feature_si, null)
  platform_extended_counter_manager_feature_svi         = try(local.device_config[each.key].system.hardware.counter_feature_svi, null)
  platform_extended_counter_manager_feature_tunnel      = try(local.device_config[each.key].system.hardware.counter_feature_tunnel, null)
  platform_extended_counter_manager_feature_vlan        = try(local.device_config[each.key].system.hardware.counter_feature_vlan, null)
  platform_extended_counter_manager_feature_voq         = try(local.device_config[each.key].system.hardware.counter_feature_voq, null)
  platform_extended_counter_manager_ingress_acl_scale   = try(local.device_config[each.key].system.hardware.counter_ingr_acl_feature_scale, null)
  platform_extended_counter_manager_l2vni_scale         = try(local.device_config[each.key].system.hardware.counter_l2vni_feature_scale, null)
  platform_extended_counter_manager_l3vni_scale         = try(local.device_config[each.key].system.hardware.counter_l3vni_feature_scale, null)
  platform_extended_counter_manager_si_scale            = try(local.device_config[each.key].system.hardware.counter_si_feature_scale, null)
  platform_extended_counter_manager_svi_scale           = try(local.device_config[each.key].system.hardware.counter_svi_feature_scale, null)
  platform_extended_counter_manager_tunnel_scale        = try(local.device_config[each.key].system.hardware.counter_tunnel_feature_scale, null)
  platform_extended_counter_manager_vlan_scale          = try(local.device_config[each.key].system.hardware.counter_vlan_feature_scale, null)
  platform_extended_counter_manager_voq_scale           = try(local.device_config[each.key].system.hardware.counter_voq_feature_scale, null)
  platform_extended_dme_load_interval                   = try(local.device_config[each.key].system.hardware.dme_load_interval, null)
  platform_extended_egress_l2_qos_ifacl_label_size      = try(local.device_config[each.key].system.hardware.egr_l2_qos_ifacl_label_size, null) == null ? null : (try(local.device_config[each.key].system.hardware.egr_l2_qos_ifacl_label_size) ? "enable" : "disable")
  platform_extended_gpe5_timer_enable                   = try(local.device_config[each.key].system.hardware.gpe_5_timer_enable, null)
  platform_extended_hardware_qos_latency_optimized      = try(local.device_config[each.key].system.hardware.qos_latency_optimized, null)
  platform_extended_ingress_pacl_ifacl_label_size       = try(local.device_config[each.key].system.hardware.ing_ifacl_label_size, null) == null ? null : (try(local.device_config[each.key].system.hardware.ing_ifacl_label_size) ? "enable" : "disable")
  platform_extended_ingress_vrf_nat_bd_label_width      = try(local.device_config[each.key].system.hardware.vrf_nat_label_width, null)
  platform_extended_mpls_qos_pipe_mode                  = try(local.device_config[each.key].system.hardware.mpls_qos_pipe_mode, null) == null ? null : (try(local.device_config[each.key].system.hardware.mpls_qos_pipe_mode) ? "enabled" : "disabled")
  platform_extended_multicast_nlb_stick_port_channel    = try(local.device_config[each.key].system.hardware.multicast_nlb_port_channel, null) == null ? null : (try(local.device_config[each.key].system.hardware.multicast_nlb_port_channel) ? "enable" : "disable")
  platform_extended_multicast_priority                  = try(local.device_config[each.key].system.hardware.multicast_priority, null)
  platform_extended_multicast_stats_disable             = try(local.device_config[each.key].system.hardware.multicast_stats_disable, null) == null ? null : (try(local.device_config[each.key].system.hardware.multicast_stats_disable) ? "enable" : "disable")
  platform_extended_pbr_ecmp_paths                      = try(local.device_config[each.key].system.hardware.pbr_ecmp_paths, null)
  platform_extended_pbr_fast_convergence                = try(local.device_config[each.key].system.hardware.pbr_next_hop_fast_convergence, null) == null ? null : (try(local.device_config[each.key].system.hardware.pbr_next_hop_fast_convergence) ? "enable" : "disable")
  platform_extended_pbr_match_default_route             = try(local.device_config[each.key].system.hardware.pbr_match_default_route, null) == null ? null : (try(local.device_config[each.key].system.hardware.pbr_match_default_route) ? "enable" : "disable")
  platform_extended_ptp_correction_hardware             = try(local.device_config[each.key].system.hardware.ptp_correction_hardware, null)
  platform_extended_si_flex_stats                       = try(local.device_config[each.key].system.hardware.sub_interface_flex_stats, null)
  platform_extended_stats_template                      = try(local.device_config[each.key].system.hardware.tcam_per_entry_stats_template, null)
  platform_extended_storm_control_priority              = try(local.device_config[each.key].system.hardware.storm_control_priority, null)
  platform_extended_tcam_default_result                 = try(local.device_config[each.key].system.hardware.tcam_default_result, null) == null ? null : (try(local.device_config[each.key].system.hardware.tcam_default_result) ? "enable" : "disable")
  platform_extended_udf_netflow_rtp_multicast_enabled   = try(local.device_config[each.key].system.hardware.udf_netflow_rtp_multicast, null)
  platform_extended_vrf_aware_nat_enable                = try(local.device_config[each.key].system.hardware.vrf_aware_nat_enable, null) == null ? null : (try(local.device_config[each.key].system.hardware.vrf_aware_nat_enable) ? "enabled" : "disabled")

  # platformNVE / platformInfraVlan nested maps
  platform_nve_interfaces = (try(local.device_config[each.key].system.nve_ipmc_index_size, null) != null ||
    try(local.device_config[each.key].system.nve_overlay_vlans, null) != null ||
    length(try(local.device_config[each.key].system.nve_infra_vlans, [])) > 0) ? {
    "1" = {
      ipmc_index_size = try(local.device_config[each.key].system.nve_ipmc_index_size, null)
      overlay_vlan_id = try(provider::utils::normalize_vlans(try(local.device_config[each.key].system.nve_overlay_vlans), "string-nxos"), null)
      infra_vlans = length(try(local.device_config[each.key].system.nve_infra_vlans, [])) > 0 ? merge([for group in try(local.device_config[each.key].system.nve_infra_vlans, []) : {
        for vlan_id in try(provider::utils::normalize_vlans(group.vlans, "list"), []) :
        tostring(vlan_id) => {
          force = try(group.force, null) == null ? null : (try(group.force) ? "Enable" : "Disable")
        }
      }]...) : null
    }
  } : null

  # nwVdc nested map
  vdcs = length(try(local.device_config[each.key].system.vdcs, [])) > 0 ? { for vdc in try(local.device_config[each.key].system.vdcs, []) : vdc.id => {
    resource_limits = {
      multicast_ipv4_route_memory_maximum = try(vdc.resource_limits.multicast_ipv4_route_memory_maximum, null)
      multicast_ipv4_route_memory_minimum = try(vdc.resource_limits.multicast_ipv4_route_memory_minimum, null)
      multicast_ipv6_route_memory_maximum = try(vdc.resource_limits.multicast_ipv6_route_memory_maximum, null)
      multicast_ipv6_route_memory_minimum = try(vdc.resource_limits.multicast_ipv6_route_memory_minimum, null)
      port_channel_maximum                = try(vdc.resource_limits.port_channel_maximum, null)
      port_channel_minimum                = try(vdc.resource_limits.port_channel_minimum, null)
      unicast_ipv4_route_memory_maximum   = try(vdc.resource_limits.unicast_ipv4_route_memory_maximum, null)
      unicast_ipv4_route_memory_minimum   = try(vdc.resource_limits.unicast_ipv4_route_memory_minimum, null)
      unicast_ipv6_route_memory_maximum   = try(vdc.resource_limits.unicast_ipv6_route_memory_maximum, null)
      unicast_ipv6_route_memory_minimum   = try(vdc.resource_limits.unicast_ipv6_route_memory_minimum, null)
      vlan_maximum                        = try(vdc.resource_limits.vlan_maximum, null)
      vlan_minimum                        = try(vdc.resource_limits.vlan_minimum, null)
      vrf_maximum                         = try(vdc.resource_limits.vrf_maximum, null)
      vrf_minimum                         = try(vdc.resource_limits.vrf_minimum, null)
    }
  } } : null

  # mgmtMgmtIf nested map
  management_interfaces = length(try(local.device_config[each.key].interfaces.management, [])) > 0 ? { for int in try(local.device_config[each.key].interfaces.management, []) : int.id => {
    admin_state      = try(int.shutdown, null) == null ? null : (try(int.shutdown) ? "down" : "up")
    description      = try(int.description, null)
    duplex           = try(int.duplex, null)
    mtu              = try(int.mtu, null)
    speed            = try(int.speed, null)
    auto_negotiation = try(int.negotiation_auto, null)
    snmp_trap_state  = try(int.snmp_trap_link_status, null) == null ? null : (try(int.snmp_trap_link_status) ? "enable" : "disable")
    vrf_dn           = try(int.vrf, null) != null ? "sys/inst-${try(int.vrf)}" : null
  } } : null

  # cdpInst attributes
  cdp_transmit_frequency = try(local.device_config[each.key].cdp.timer, null)
  cdp_hold_interval      = try(local.device_config[each.key].cdp.holdtime, null)
  cdp_version            = try(local.device_config[each.key].cdp.advertise, null)
  cdp_device_id_type     = try(local.cdp_format_device_id_map[try(local.device_config[each.key].cdp.format_device_id)], null)
  cdp_pnp_startup_vlan   = try(local.device_config[each.key].cdp.pnp_startup_vlan, null)

  # cdpIf nested map
  cdp_interfaces = length(try(local.cdp_interfaces_by_device[each.key], [])) > 0 ? { for entry in try(local.cdp_interfaces_by_device[each.key], []) : entry.interface_id => {
    admin_state = entry.cdp ? "enabled" : "disabled"
  } } : null

  # dnsEntity attributes
  dns_admin_state = try(local.device_config[each.key].dns.domain_lookup, null) == null ? null : (try(local.device_config[each.key].dns.domain_lookup) ? "enabled" : "disabled")
  dns_profiles = try(local.device_config[each.key].dns.domain_name, null) != null ? {
    "default" = {
      domain_name = try(local.device_config[each.key].dns.domain_name, null)
    }
  } : null

  # lldpInst attributes
  lldp_hold_time                   = try(local.device_config[each.key].lldp.holdtime, null)
  lldp_init_delay_time             = try(local.device_config[each.key].lldp.reinit, null)
  lldp_transmit_frequency          = try(local.device_config[each.key].lldp.timer, null)
  lldp_optional_tlv_select         = try(local.device_config[each.key].lldp.tlv_select, null)
  lldp_port_id_sub_type            = try(local.device_config[each.key].lldp.portid_subtype, null)
  lldp_advertise_system_chassis_id = try(local.device_config[each.key].lldp.chassis_id, null) == null ? null : (try(local.device_config[each.key].lldp.chassis_id) ? "enabled" : "disabled")
  lldp_port_channel                = try(local.device_config[each.key].lldp.portchannel, null) == null ? null : (try(local.device_config[each.key].lldp.portchannel) ? "enabled" : "disabled")

  # lldpIf nested map
  lldp_interfaces = length(try(local.lldp_interfaces_by_device[each.key], [])) > 0 ? { for entry in try(local.lldp_interfaces_by_device[each.key], []) : entry.interface_id => {
    admin_receive_state  = try(entry.lldp_receive, null) == null ? null : (entry.lldp_receive ? "enabled" : "disabled")
    admin_transmit_state = try(entry.lldp_transmit, null) == null ? null : (entry.lldp_transmit ? "enabled" : "disabled")
    port_dcbxp_version   = try(entry.lldp_dcbx_version, null)
    tlv_management_ipv4  = try(entry.lldp_tlv_set_management_address_v4, null)
    tlv_management_ipv6  = try(entry.lldp_tlv_set_management_address_v6, null)
    tlv_vlan             = try(entry.lldp_tlv_set_vlan, null)
  } } : null

  # udldInst attributes
  udld_aggressive       = try(local.device_config[each.key].udld.aggressive, null) == null ? null : (try(local.device_config[each.key].udld.aggressive) ? "enabled" : "disabled")
  udld_message_interval = try(local.device_config[each.key].udld.message_time, null)

  # udldPhysIf nested map
  udld_interfaces = length(try(local.udld_interfaces_by_device[each.key], [])) > 0 ? { for entry in try(local.udld_interfaces_by_device[each.key], []) : entry.interface_id => {
    admin_state = try(entry.udld, null) == null ? null : (entry.udld ? "port-enabled" : "port-default")
    aggressive  = try(entry.udld_aggressive, null) == null ? null : (entry.udld_aggressive ? "enabled" : "disabled")
  } } : null

  # nxapiInst attributes
  nxapi_vrf                               = try(local.device_config[each.key].system.nxapi.vrf, null)
  nxapi_http_port                         = try(local.device_config[each.key].system.nxapi.http_port, null)
  nxapi_https_port                        = try(local.device_config[each.key].system.nxapi.https_port, null)
  nxapi_idle_timeout                      = try(local.device_config[each.key].system.nxapi.idle_timeout, null)
  nxapi_certificate_enable                = try(local.device_config[each.key].system.nxapi.certificate_enable, null) == null ? null : try(local.device_config[each.key].system.nxapi.certificate_enable)
  nxapi_certificate_file                  = try(local.device_config[each.key].system.nxapi.certificate_httpscrt, null)
  nxapi_key_file                          = try(local.device_config[each.key].system.nxapi.certificate_httpskey, null)
  nxapi_encrypted_key_passphrase          = try(local.device_config[each.key].system.nxapi.certificate_httpskey_passphrase, null)
  nxapi_trustpoint                        = try(local.device_config[each.key].system.nxapi.certificate_trustpoint, null)
  nxapi_ssl_protocols                     = try(local.device_config[each.key].system.nxapi.ssl_protocols, null)
  nxapi_ssl_ciphers_weak                  = try(local.device_config[each.key].system.nxapi.ssl_ciphers_weak, null) == null ? null : try(local.device_config[each.key].system.nxapi.ssl_ciphers_weak)
  nxapi_client_certificate_authentication = try(local.device_config[each.key].system.nxapi.client_cert_auth, null)
  nxapi_sudi                              = try(local.device_config[each.key].system.nxapi.sudi, null) == null ? null : try(local.device_config[each.key].system.nxapi.sudi)

  # sasSas / sasSvcInstance / sasSController / sasFwSvcPolicy / sasDom (hypershield)
  service_instances = try(local.device_config[each.key].system.hypershield, null) != null ? { "hypershield" = {
    source_interface              = try(local.device_config[each.key].system.hypershield.source_interface_type, null) != null ? "${local.hypershield_source_interface_type_map[local.device_config[each.key].system.hypershield.source_interface_type]}${try(local.device_config[each.key].system.hypershield.source_interface_id, "")}" : null
    controller_https_proxy_server = try(local.device_config[each.key].system.hypershield.https_proxy, null)
    controller_https_proxy_port   = try(local.device_config[each.key].system.hypershield.https_proxy_port, null)
    firewall_policy_admin_state   = try(local.device_config[each.key].system.hypershield.firewall_in_service, null) == null ? null : (try(local.device_config[each.key].system.hypershield.firewall_in_service) ? "in-service" : "out-of-service")
    vrfs = length(try(local.device_config[each.key].system.hypershield.firewall_vrfs, [])) > 0 ? { for vrf in try(local.device_config[each.key].system.hypershield.firewall_vrfs, []) : vrf.name => {
      affinity = try(vrf.module_affinity, null)
    } } : null
  } } : null

  # spanErspanOriginIp attributes
  erspan_origin_ip_is_global      = try(local.device_config[each.key].system.erspan_origin_ip_address, null) != null ? true : null
  erspan_origin_ip_is_global_ipv6 = try(local.device_config[each.key].system.erspan_origin_ipv6_address, null) != null ? true : null
  erspan_origin_ip_address        = try(local.device_config[each.key].system.erspan_origin_ip_address, null)
  erspan_origin_ipv6_address      = try(local.device_config[each.key].system.erspan_origin_ipv6_address, null)

  # ttagTtagEntity / ttagTtagIf attributes
  ttag_marker_interval = try(local.device_config[each.key].system.ttag_marker_interval, null)

  ttag_interfaces = length(try(local.ttag_interfaces_by_device[each.key], [])) > 0 ? { for entry in try(local.ttag_interfaces_by_device[each.key], []) : entry.interface_id => {
    ttag        = try(entry.ttag, null)
    ttag_inner  = try(entry.ttag_inner, null)
    ttag_marker = try(entry.ttag_marker, null)
    ttag_strip  = try(entry.ttag_strip, null)
  } } : null

  # platformTcamRegion attributes
  tcam_region_arp_acl_size               = try(local.device_config[each.key].system.hardware_access_list_tcam_region.arp_acl_size, null)
  tcam_region_copp_size                  = try(local.device_config[each.key].system.hardware_access_list_tcam_region.copp_size, null)
  tcam_region_copp_system_size           = try(local.device_config[each.key].system.hardware_access_list_tcam_region.copp_system_size, null)
  tcam_region_egress_ipv6_qos_size       = try(local.device_config[each.key].system.hardware_access_list_tcam_region.egress_ipv6_qos_size, null)
  tcam_region_egress_ipv6_racl_size      = try(local.device_config[each.key].system.hardware_access_list_tcam_region.egress_ipv6_racl_size, null)
  tcam_region_egress_mac_qos_size        = try(local.device_config[each.key].system.hardware_access_list_tcam_region.egress_mac_qos_size, null)
  tcam_region_egress_qos_lite_size       = try(local.device_config[each.key].system.hardware_access_list_tcam_region.egress_qos_lite_size, null)
  tcam_region_egress_qos_size            = try(local.device_config[each.key].system.hardware_access_list_tcam_region.egress_qos_size, null)
  tcam_region_egress_racl_size           = try(local.device_config[each.key].system.hardware_access_list_tcam_region.egress_racl_size, null)
  tcam_region_egress_vacl_size           = try(local.device_config[each.key].system.hardware_access_list_tcam_region.egress_vacl_size, null)
  tcam_region_fcoe_egress_size           = try(local.device_config[each.key].system.hardware_access_list_tcam_region.fcoe_egress_size, null)
  tcam_region_fcoe_ingress_size          = try(local.device_config[each.key].system.hardware_access_list_tcam_region.fcoe_ingress_size, null)
  tcam_region_fhs_size                   = try(local.device_config[each.key].system.hardware_access_list_tcam_region.fhs_size, null)
  tcam_region_interface_acl_lite_size    = try(local.device_config[each.key].system.hardware_access_list_tcam_region.ifacl_lite_size, null)
  tcam_region_interface_acl_size         = try(local.device_config[each.key].system.hardware_access_list_tcam_region.ifacl_size, null)
  tcam_region_interface_acl_udf_size     = try(local.device_config[each.key].system.hardware_access_list_tcam_region.ifacl_udf_size, null)
  tcam_region_ingress_flow_redirect_size = try(local.device_config[each.key].system.hardware_access_list_tcam_region.ing_flow_redirect_size, null)
  tcam_region_ingress_flow_size          = try(local.device_config[each.key].system.hardware_access_list_tcam_region.ing_flow_size, null)
  tcam_region_ipsg_size                  = try(local.device_config[each.key].system.hardware_access_list_tcam_region.ipsg_size, null)
  tcam_region_ipv6_interface_acl_size    = try(local.device_config[each.key].system.hardware_access_list_tcam_region.ipv6_ifacl_size, null)
  tcam_region_ipv6_l3_qos_size           = try(local.device_config[each.key].system.hardware_access_list_tcam_region.ipv6_l3_qos_size, null)
  tcam_region_ipv6_pbr_size              = try(local.device_config[each.key].system.hardware_access_list_tcam_region.ipv6_pbr_size, null)
  tcam_region_ipv6_qos_size              = try(local.device_config[each.key].system.hardware_access_list_tcam_region.ipv6_qos_size, null)
  tcam_region_ipv6_racl_size             = try(local.device_config[each.key].system.hardware_access_list_tcam_region.ipv6_racl_size, null)
  tcam_region_ipv6_span_l2_size          = try(local.device_config[each.key].system.hardware_access_list_tcam_region.ipv6_span_l2_size, null)
  tcam_region_ipv6_span_size             = try(local.device_config[each.key].system.hardware_access_list_tcam_region.ipv6_span_size, null)
  tcam_region_ipv6_sup_size              = try(local.device_config[each.key].system.hardware_access_list_tcam_region.ipv6_sup_size, null)
  tcam_region_ipv6_vacl_size             = try(local.device_config[each.key].system.hardware_access_list_tcam_region.ipv6_vacl_size, null)
  tcam_region_ipv6_vlan_qos_size         = try(local.device_config[each.key].system.hardware_access_list_tcam_region.ipv6_vqos_size, null)
  tcam_region_l3_qos_intra_lite_size     = try(local.device_config[each.key].system.hardware_access_list_tcam_region.l3_qos_intra_lite_size, null)
  tcam_region_mac_interface_acl_size     = try(local.device_config[each.key].system.hardware_access_list_tcam_region.mac_ifacl_size, null)
  tcam_region_mac_l3_qos_size            = try(local.device_config[each.key].system.hardware_access_list_tcam_region.mac_l3_qos_size, null)
  tcam_region_mac_qos_size               = try(local.device_config[each.key].system.hardware_access_list_tcam_region.mac_qos_size, null)
  tcam_region_mac_vacl_size              = try(local.device_config[each.key].system.hardware_access_list_tcam_region.mac_vacl_size, null)
  tcam_region_mac_vlan_qos_size          = try(local.device_config[each.key].system.hardware_access_list_tcam_region.mac_vqos_size, null)
  tcam_region_multicast_bidir_size       = try(local.device_config[each.key].system.hardware_access_list_tcam_region.mcast_bidir_size, null)
  tcam_region_mpls_doublewide            = try(local.device_config[each.key].system.hardware_access_list_tcam_region.mpls_doublewide, null)
  tcam_region_mpls_size                  = try(local.device_config[each.key].system.hardware_access_list_tcam_region.mpls_size, null)
  tcam_region_mvpn_size                  = try(local.device_config[each.key].system.hardware_access_list_tcam_region.mvpn_size, null)
  tcam_region_n9k_arp_acl_size           = try(local.device_config[each.key].system.hardware_access_list_tcam_region.n9k_arp_acl_size, null)
  tcam_region_nat_size                   = try(local.device_config[each.key].system.hardware_access_list_tcam_region.nat_size, null)
  tcam_region_openflow_doublewide        = try(local.device_config[each.key].system.hardware_access_list_tcam_region.openflow_doublewide, null)
  tcam_region_openflow_lite_size         = try(local.device_config[each.key].system.hardware_access_list_tcam_region.openflow_lite_size, null)
  tcam_region_openflow_size              = try(local.device_config[each.key].system.hardware_access_list_tcam_region.openflow_size, null)
  tcam_region_pbr_size                   = try(local.device_config[each.key].system.hardware_access_list_tcam_region.pbr_size, null)
  tcam_region_qos_intra_lite_size        = try(local.device_config[each.key].system.hardware_access_list_tcam_region.qos_intra_lite_size, null)
  tcam_region_qos_size                   = try(local.device_config[each.key].system.hardware_access_list_tcam_region.qos_size, null)
  tcam_region_qos_label_size             = try(local.device_config[each.key].system.hardware_access_list_tcam_region.qos_label_size, null)
  tcam_region_racl_lite_size             = try(local.device_config[each.key].system.hardware_access_list_tcam_region.racl_lite_size, null)
  tcam_region_racl_size                  = try(local.device_config[each.key].system.hardware_access_list_tcam_region.racl_size, null)
  tcam_region_racl_udf_size              = try(local.device_config[each.key].system.hardware_access_list_tcam_region.racl_udf_size, null)
  tcam_region_sup_size                   = try(local.device_config[each.key].system.hardware_access_list_tcam_region.sup_size, null)
  tcam_region_svi_size                   = try(local.device_config[each.key].system.hardware_access_list_tcam_region.svi_size, null)
  tcam_region_tcp_nat_size               = try(local.device_config[each.key].system.hardware_access_list_tcam_region.tcp_nat_size, null)
  tcam_region_vacl_lite_size             = try(local.device_config[each.key].system.hardware_access_list_tcam_region.vacl_lite_size, null)
  tcam_region_vacl_size                  = try(local.device_config[each.key].system.hardware_access_list_tcam_region.vacl_size, null)
  tcam_region_vpc_convergence_size       = try(local.device_config[each.key].system.hardware_access_list_tcam_region.vpc_convergence_size, null)
  tcam_region_vlan_qos_intra_lite_size   = try(local.device_config[each.key].system.hardware_access_list_tcam_region.vqos_intra_lite_size, null)
  tcam_region_vlan_qos_size              = try(local.device_config[each.key].system.hardware_access_list_tcam_region.vqos_size, null)
  tcam_region_vxlan_p2p_size             = try(local.device_config[each.key].system.hardware_access_list_tcam_region.vxlan_p2p_size, null)

  # platformTcamRegionExtended attributes
  tcam_region_extended_egress_interface_acl_all_per_port_stats = try(local.device_config[each.key].system.hardware_access_list_tcam_region.e_ifacl_all_per_port_stats, null)
  tcam_region_extended_egress_interface_acl_all_size           = try(local.device_config[each.key].system.hardware_access_list_tcam_region.e_ifacl_all_size, null)
  tcam_region_extended_egress_ipv6_racl_per_port_stats         = try(local.device_config[each.key].system.hardware_access_list_tcam_region.e_ipv6_racl_per_port_stats, null)
  tcam_region_extended_egress_racl_per_port_stats              = try(local.device_config[each.key].system.hardware_access_list_tcam_region.e_racl_per_port_stats, null)
  tcam_region_extended_egress_copp_size                        = try(local.device_config[each.key].system.hardware_access_list_tcam_region.egr_copp_size, null)
  tcam_region_extended_egress_flow_size                        = try(local.device_config[each.key].system.hardware_access_list_tcam_region.egr_flow_size, null)
  tcam_region_extended_egress_hardware_telemetry_size          = try(local.device_config[each.key].system.hardware_access_list_tcam_region.e_hw_telemetry_size, null)
  tcam_region_extended_egress_interface_acl_size               = try(local.device_config[each.key].system.hardware_access_list_tcam_region.egr_ifacl_size, null)
  tcam_region_extended_egress_l2_qos_size                      = try(local.device_config[each.key].system.hardware_access_list_tcam_region.egr_l2_qos_size, null)
  tcam_region_extended_egress_l3_vlan_qos_size                 = try(local.device_config[each.key].system.hardware_access_list_tcam_region.egr_l3_vlan_qos_size, null)
  tcam_region_extended_egress_racl_size                        = try(local.device_config[each.key].system.hardware_access_list_tcam_region.egr_racl_size, null)
  tcam_region_extended_egress_sup_size                         = try(local.device_config[each.key].system.hardware_access_list_tcam_region.egr_sup_size, null)
  tcam_region_extended_hardware_telemetry_size                 = try(local.device_config[each.key].system.hardware_access_list_tcam_region.hw_telemetry_size, null)
  tcam_region_extended_interface_acl_all_per_port_stats        = try(local.device_config[each.key].system.hardware_access_list_tcam_region.ifacl_all_per_port_stats, null)
  tcam_region_extended_interface_acl_all_profile               = try(local.device_config[each.key].system.hardware_access_list_tcam_region.ifacl_all_profile, null)
  tcam_region_extended_interface_acl_all_size                  = try(local.device_config[each.key].system.hardware_access_list_tcam_region.ifacl_all_size, null)
  tcam_region_extended_interface_acl_per_port_stats            = try(local.device_config[each.key].system.hardware_access_list_tcam_region.ifacl_per_port_stats, null)
  tcam_region_extended_ingress_dacl_size                       = try(local.device_config[each.key].system.hardware_access_list_tcam_region.ing_dacl_size, null)
  tcam_region_extended_ingress_interface_acl_size              = try(local.device_config[each.key].system.hardware_access_list_tcam_region.ing_ifacl_size, null)
  tcam_region_extended_ingress_interface_acl_wide_size         = try(local.device_config[each.key].system.hardware_access_list_tcam_region.ing_ifacl_wide_size, null)
  tcam_region_extended_ingress_ipv6_interface_acl_lite_size    = try(local.device_config[each.key].system.hardware_access_list_tcam_region.ing_ipv6_ifacl_lite_size, null)
  tcam_region_extended_ingress_l2_l3_qos_size                  = try(local.device_config[each.key].system.hardware_access_list_tcam_region.ing_l2_l3_qos_size, null)
  tcam_region_extended_ingress_l2_qos_size                     = try(local.device_config[each.key].system.hardware_access_list_tcam_region.ing_l2_qos_size, null)
  tcam_region_extended_ingress_l2_span_filter_size             = try(local.device_config[each.key].system.hardware_access_list_tcam_region.ing_l2_span_filter_size, null)
  tcam_region_extended_ingress_l3_span_filter_size             = try(local.device_config[each.key].system.hardware_access_list_tcam_region.ing_l3_span_filter_size, null)
  tcam_region_extended_ingress_pacl_sb_size                    = try(local.device_config[each.key].system.hardware_access_list_tcam_region.ing_pacl_sb_size, null)
  tcam_region_extended_ingress_racl_size                       = try(local.device_config[each.key].system.hardware_access_list_tcam_region.ing_racl_size, null)
  tcam_region_extended_ingress_rbacl_size                      = try(local.device_config[each.key].system.hardware_access_list_tcam_region.ing_rbacl_size, null)
  tcam_region_extended_ingress_redirect_size                   = try(local.device_config[each.key].system.hardware_access_list_tcam_region.ing_redirect_size, null)
  tcam_region_extended_ingress_storm_control_size              = try(local.device_config[each.key].system.hardware_access_list_tcam_region.ing_storm_control_size, null)
  tcam_region_extended_ingress_sup_size                        = try(local.device_config[each.key].system.hardware_access_list_tcam_region.ing_sup_size, null)
  tcam_region_extended_ingress_vacl_nh_size                    = try(local.device_config[each.key].system.hardware_access_list_tcam_region.ing_vacl_nh_size, null)
  tcam_region_extended_ingress_vlan_qos_size                   = try(local.device_config[each.key].system.hardware_access_list_tcam_region.ing_vlan_qos_size, null)
  tcam_region_extended_ipv6_interface_acl_per_port_stats       = try(local.device_config[each.key].system.hardware_access_list_tcam_region.ipv6_ifacl_per_port_stats, null)
  tcam_region_extended_ipv6_racl_per_port_stats                = try(local.device_config[each.key].system.hardware_access_list_tcam_region.ipv6_racl_per_port_stats, null)
  tcam_region_extended_mac_interface_acl_per_port_stats        = try(local.device_config[each.key].system.hardware_access_list_tcam_region.mac_ifacl_per_port_stats, null)
  tcam_region_extended_multicast_nat_size                      = try(local.device_config[each.key].system.hardware_access_list_tcam_region.mcast_nat_size, null)
  tcam_region_extended_multicast_nbm_size                      = try(local.device_config[each.key].system.hardware_access_list_tcam_region.mcast_nbm_size, null)
  tcam_region_extended_racl_all_per_port_stats                 = try(local.device_config[each.key].system.hardware_access_list_tcam_region.racl_all_per_port_stats, null)
  tcam_region_extended_racl_all_profile                        = try(local.device_config[each.key].system.hardware_access_list_tcam_region.racl_all_profile, null)
  tcam_region_extended_racl_all_size                           = try(local.device_config[each.key].system.hardware_access_list_tcam_region.racl_all_size, null)
  tcam_region_extended_racl_per_port_stats                     = try(local.device_config[each.key].system.hardware_access_list_tcam_region.racl_per_port_stats, null)
  tcam_region_extended_redirect_v4_size                        = try(local.device_config[each.key].system.hardware_access_list_tcam_region.redirect_v4_size, null)
  tcam_region_extended_span_size                               = try(local.device_config[each.key].system.hardware_access_list_tcam_region.span_size, null)
  tcam_region_extended_span_tahoe_size                         = try(local.device_config[each.key].system.hardware_access_list_tcam_region.span_tahoe_size, null)

  # commSsh attributes
  ssh_ciphers                      = try(local.device_config[each.key].system.ssh.ciphers_all, null) == null ? null : (try(local.device_config[each.key].system.ssh.ciphers_all) ? "yes" : "no")
  ssh_enable_weak_ciphers          = try(local.device_config[each.key].system.ssh.ciphers_weak, null) == null ? null : (try(local.device_config[each.key].system.ssh.ciphers_weak) ? "yes" : "no")
  ssh_key_exchange_algorithms      = try(local.device_config[each.key].system.ssh.kexalgos_all, null) == null ? null : (try(local.device_config[each.key].system.ssh.kexalgos_all) ? "yes" : "no")
  ssh_key_types                    = try(local.device_config[each.key].system.ssh.keytypes_all, null) == null ? null : (try(local.device_config[each.key].system.ssh.keytypes_all) ? "yes" : "no")
  ssh_login_attempts               = try(local.device_config[each.key].system.ssh.login_attempts, null)
  ssh_login_grace_time             = try(local.device_config[each.key].system.ssh.login_gracetime, null)
  ssh_message_authentication_codes = try(local.device_config[each.key].system.ssh.macs_all, null) == null ? null : (try(local.device_config[each.key].system.ssh.macs_all) ? "yes" : "no")
  ssh_port                         = try(local.device_config[each.key].system.ssh.port, null)

  # commSshKey nested map
  ssh_keys = length(try(local.device_config[each.key].system.ssh.keys, [])) > 0 ? { for key in try(local.device_config[each.key].system.ssh.keys, []) : key.type => {
    key_length = try(key.key_length, null)
  } } : null

  depends_on = [
    nxos_feature.feature,
    nxos_loopback_interface.loopback_interface,
    nxos_physical_interface.physical_interface,
    nxos_port_channel_interface.port_channel_interface,
    nxos_subinterface.subinterface,
    nxos_svi_interface.svi_interface,
    nxos_vrf.vrf,
  ]
}
