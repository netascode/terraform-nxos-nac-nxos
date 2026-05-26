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
        device                               = device.name
        interface_id                         = "eth${int.id}"
        lldp_receive                         = try(int.lldp_receive, null)
        lldp_transmit                        = try(int.lldp_transmit, null)
        lldp_tlv_set_management_address      = try(int.lldp_tlv_set_management_address, null)
        lldp_tlv_set_management_address_ipv6 = try(int.lldp_tlv_set_management_address_ipv6, null)
        lldp_tlv_set_vlan                    = try(int.lldp_tlv_set_vlan, null)
        lldp_dcbx_version                    = try(int.lldp_dcbx_version, null)
        } if try(int.lldp_receive, null) != null ||
        try(int.lldp_transmit, null) != null ||
        try(int.lldp_tlv_set_management_address, null) != null ||
        try(int.lldp_tlv_set_management_address_ipv6, null) != null ||
        try(int.lldp_tlv_set_vlan, null) != null ||
      try(int.lldp_dcbx_version, null) != null],
      [for int in try(local.device_config[device.name].interfaces.port_channels, []) : {
        device                               = device.name
        interface_id                         = "po${int.id}"
        lldp_receive                         = try(int.lldp_receive, null)
        lldp_transmit                        = try(int.lldp_transmit, null)
        lldp_tlv_set_management_address      = try(int.lldp_tlv_set_management_address, null)
        lldp_tlv_set_management_address_ipv6 = try(int.lldp_tlv_set_management_address_ipv6, null)
        lldp_tlv_set_vlan                    = try(int.lldp_tlv_set_vlan, null)
        lldp_dcbx_version                    = try(int.lldp_dcbx_version, null)
        } if try(int.lldp_receive, null) != null ||
        try(int.lldp_transmit, null) != null ||
        try(int.lldp_tlv_set_management_address, null) != null ||
        try(int.lldp_tlv_set_management_address_ipv6, null) != null ||
        try(int.lldp_tlv_set_vlan, null) != null ||
      try(int.lldp_dcbx_version, null) != null],
      [for int in try(local.device_config[device.name].interfaces.management, []) : {
        device                               = device.name
        interface_id                         = int.id
        lldp_receive                         = try(int.lldp_receive, null)
        lldp_transmit                        = try(int.lldp_transmit, null)
        lldp_tlv_set_management_address      = try(int.lldp_tlv_set_management_address, null)
        lldp_tlv_set_management_address_ipv6 = try(int.lldp_tlv_set_management_address_ipv6, null)
        lldp_tlv_set_vlan                    = try(int.lldp_tlv_set_vlan, null)
        lldp_dcbx_version                    = try(int.lldp_dcbx_version, null)
        } if try(int.lldp_receive, null) != null ||
        try(int.lldp_transmit, null) != null ||
        try(int.lldp_tlv_set_management_address, null) != null ||
        try(int.lldp_tlv_set_management_address_ipv6, null) != null ||
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
    try(local.device_config[device.name].system.icam_monitor_history, null) != null ||
    try(local.device_config[device.name].system.icam_monitor_scale, null) != null ||
    try(local.device_config[device.name].system.smart_licensing_transport, null) != null ||
    try(local.device_config[device.name].system.smart_licensing_url_cslu, null) != null ||
    try(local.device_config[device.name].system.line_console_exec_timeout, null) != null ||
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
  length(try(local.device_config[device.name].interfaces.management, [])) > 0 }
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
  arp_unnumbered_svi_software_replication = try(local.device_config[each.key].arp.unnum_svi_sw_replication, null) != null ? (try(local.device_config[each.key].arp.unnum_svi_sw_replication) ? "enabled" : "disabled") : null
  arp_cache_limit                         = try(local.device_config[each.key].arp.cache_limit, null)
  arp_cache_syslog_rate                   = try(local.device_config[each.key].arp.cache_syslog_rate, null)
  arp_evpn_timeout                        = try(local.device_config[each.key].arp.evpn_timeout, null)
  arp_interface_cache_limit               = try(local.device_config[each.key].arp.cache_intf_limit, null)
  arp_ip_adjacency_route_distance         = try(local.device_config[each.key].arp.adjacency_route_distance, null)
  arp_ip_arp_cos                          = try(local.device_config[each.key].arp.cos, null)
  arp_off_list_timeout                    = try(local.device_config[each.key].arp.off_list_timeout, null)
  arp_rarp_fabric_forwarding              = try(local.device_config[each.key].arp.rarp_fabric_forwarding, null) != null ? (try(local.device_config[each.key].arp.rarp_fabric_forwarding) ? "enabled" : "disabled") : null
  arp_rarp_fabric_forwarding_rate         = try(local.device_config[each.key].arp.rarp_fabric_forwarding_rate_limit, null)
  arp_resolve_outside_subnet              = try(local.device_config[each.key].arp.outside_subnet, null) != null ? (try(local.device_config[each.key].arp.outside_subnet) ? "enabled" : "disabled") : null
  arp_suppression_timeout                 = try(local.device_config[each.key].arp.suppression_timeout, null)
  arp_timeout                             = try(local.device_config[each.key].arp.timeout, null)

  # arpVpcDom nested map
  arp_vpc_domains = try(local.device_config[each.key].vpc.ip_arp_synchronize, null) != null ? { tostring(try(local.device_config[each.key].vpc.domain_id)) = {
    arp_sync = try(local.device_config[each.key].vpc.ip_arp_synchronize) ? "enabled" : "disabled"
  } } : null

  # ndEntity / ndInst attributes
  nd_admin_state                         = "enabled"
  nd_instance_admin_state                = "enabled"
  nd_accept_solicit_neighbor_entry       = try(local.device_config[each.key].nd.solicit_na, null)
  nd_aging_interval                      = try(local.device_config[each.key].nd.aging_interval, null)
  nd_cache_limit                         = try(local.device_config[each.key].nd.cache_limit, null)
  nd_cache_syslog_rate                   = try(local.device_config[each.key].nd.cache_syslog_rate, null)
  nd_ipv6_adjacency_route_distance       = try(local.device_config[each.key].nd.adjacency_route_distance, null)
  nd_off_list_timeout                    = try(local.device_config[each.key].nd.off_list_timeout, null)
  nd_probe_interval_for_solicit_neighbor = try(local.device_config[each.key].nd.solicit_na_interval, null)
  nd_solicit_neighbor_advertisement      = try(local.device_config[each.key].nd.solicit_neighbor_advertisement, null) != null ? (try(local.device_config[each.key].nd.solicit_neighbor_advertisement) ? "enabled" : "disabled") : null

  # ndVpcDom nested map
  nd_vpc_domains = try(local.device_config[each.key].vpc.ipv6_nd_synchronize, null) != null ? { tostring(try(local.device_config[each.key].vpc.domain_id)) = {
    nd_sync = try(local.device_config[each.key].vpc.ipv6_nd_synchronize) ? "enabled" : "disabled"
  } } : null

  # ndDom -> ndIf nested maps (VRF -> interfaces)
  nd_vrfs = length(try(local.nd_vrfs_by_device[each.key], {})) > 0 ? { for vrf_name, vrf_data in try(local.nd_vrfs_by_device[each.key], {}) : vrf_name => {
    interfaces = { for int_id, nd in vrf_data.interfaces : int_id => {
      boot_file_url                  = try(nd.ra_bootfile_url, null)
      control                        = length(compact([for flag, value in local.nd_control_values : value if try({ "redirects" = nd.redirects, "managed_cfg" = nd.managed_config_flag, "other_cfg" = nd.other_config_flag, "suppress_ra" = nd.suppress_ra, "suppress_ra_mtu" = nd.suppress_ra_mtu }[flag], false)])) > 0 ? join(",", compact([for flag, value in local.nd_control_values : value if try({ "redirects" = nd.redirects, "managed_cfg" = nd.managed_config_flag, "other_cfg" = nd.other_config_flag, "suppress_ra" = nd.suppress_ra, "suppress_ra_mtu" = nd.suppress_ra_mtu }[flag], false)])) : null
      dad_attempts                   = try(nd.dad_attempts, null)
      dadns_interval                 = try(nd.dadns_interval, null)
      default_ra_lifetime            = try(nd.default_ra_lifetime, null) != null ? (nd.default_ra_lifetime ? "enabled" : "disabled") : null
      delete_adjacency_on_mac_delete = try(nd.delete_adj_on_mac_delete, null) != null ? (nd.delete_adj_on_mac_delete ? "enabled" : "disabled") : null
      dns_search_list_suppress       = try(nd.ra_dns_search_list_suppress, null) != null ? (nd.ra_dns_search_list_suppress ? "enabled" : "disabled") : null
      dns_suppress                   = try(nd.ra_dns_server_suppress, null) != null ? (nd.ra_dns_server_suppress ? "enabled" : "disabled") : null
      hop_limit                      = try(nd.hop_limit, null)
      mac_extract                    = try(nd.mac_extract, null)
      mtu                            = try(nd.mtu, null)
      neighbor_solicit_interval      = try(nd.ns_interval, null)
      ra_interval                    = try(nd.ra_interval, null)
      ra_interval_min                = try(nd.ra_interval_minimum, null)
      ra_lifetime                    = try(nd.ra_lifetime, null)
      reachable_time                 = try(nd.reachable_time, null)
      retransmit_timer               = try(nd.retrans_timer, null)
      route_suppress                 = try(nd.ra_route_suppress, null) != null ? (nd.ra_route_suppress ? "enabled" : "disabled") : null
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
  console_exec_timeout = try(local.device_config[each.key].system.line_console_exec_timeout, null)
  vty_exec_timeout     = try(local.device_config[each.key].system.line_vty_exec_timeout, null)
  vty_session_limit    = try(local.device_config[each.key].system.line_vty_session_limit, null)

  # icamEntity / icamInst / icamScale attributes
  icam_monitor_interval         = try(local.device_config[each.key].system.icam_monitor_interval, null)
  icam_number_of_intervals      = try(local.device_config[each.key].system.icam_monitor_history, null)
  icam_scale_configuration      = try(local.device_config[each.key].system.icam_monitor_scale, null)
  icam_scale_critical_threshold = try(local.device_config[each.key].system.icam_monitor_scale_threshold_critical, null)
  icam_scale_info_threshold     = try(local.device_config[each.key].system.icam_monitor_scale_threshold_info, null)
  icam_scale_warning_threshold  = try(local.device_config[each.key].system.icam_monitor_scale_threshold_warning, null)

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
    auto_negotiation = try(int.negotiate_auto, null)
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
  lldp_port_channel                = try(local.device_config[each.key].lldp.port_channel, null) == null ? null : (try(local.device_config[each.key].lldp.port_channel) ? "enabled" : "disabled")

  # lldpIf nested map
  lldp_interfaces = length(try(local.lldp_interfaces_by_device[each.key], [])) > 0 ? { for entry in try(local.lldp_interfaces_by_device[each.key], []) : entry.interface_id => {
    admin_receive_state  = try(entry.lldp_receive, null) == null ? null : (entry.lldp_receive ? "enabled" : "disabled")
    admin_transmit_state = try(entry.lldp_transmit, null) == null ? null : (entry.lldp_transmit ? "enabled" : "disabled")
    port_dcbxp_version   = try(entry.lldp_dcbx_version, null)
    tlv_management_ipv4  = try(entry.lldp_tlv_set_management_address, null)
    tlv_management_ipv6  = try(entry.lldp_tlv_set_management_address_ipv6, null)
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
